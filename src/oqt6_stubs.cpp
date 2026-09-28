#include <QApplication>
#include <QWidget>
#include <QPushButton>
#include <QLabel>
#include <QLineEdit>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QTimer>
#include <QString>
#include <QPointer>

#include <cstring>
#include <vector>

#include "oqt6_stubs.h"

static void finalize_qobject(value v) {
    OCamlQObject* holder = QObject_holder(v);
    if (holder->owned && !holder->ptr.isNull()) {
        delete holder->ptr.data();
    }
    holder->ptr = nullptr;
}

static struct custom_operations qobject_custom_ops = {
    (char*)"org.oqt6.qobject",
    finalize_qobject,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default,
    custom_compare_ext_default,
    custom_fixed_length_default
};

value alloc_qobject(QObject* obj, bool owned) {
    if (!obj) return Val_unit;
    value v = caml_alloc_custom(&qobject_custom_ops, sizeof(OCamlQObject), 0, 1);
    OCamlQObject* holder = QObject_holder(v);
    holder->ptr = obj;
    holder->owned = owned;
    return v;
}

void mark_parented(value v) {
    OCamlQObject* holder = QObject_holder(v);
    holder->owned = false;
}

thread_local int thread_domain_lock_depth = 1;

static void connect_root_cleanup(QObject* sender, value* root) {
    QObject::connect(sender, &QObject::destroyed, [root](QObject*) {
        CamlDomainLockGuard guard;
        caml_remove_global_root(root);
        delete root;
    });
}

extern "C" {

/* QObject primitives */

CAMLprim value caml_oqt6_qobject_delete(value v_obj) {
    CAMLparam1(v_obj);
    OCamlQObject* holder = QObject_holder(v_obj);
    if (!holder->ptr.isNull()) {
        delete holder->ptr.data();
        holder->ptr = nullptr;
    }
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qobject_is_valid(value v_obj) {
    CAMLparam1(v_obj);
    OCamlQObject* holder = QObject_holder(v_obj);
    CAMLreturn(Val_bool(!holder->ptr.isNull()));
}

CAMLprim value caml_oqt6_qobject_set_object_name(value v_obj, value v_name) {
    CAMLparam2(v_obj, v_name);
    QObject* obj = get_qobject<QObject>(v_obj);
    obj->setObjectName(QString::fromUtf8(String_val(v_name)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qobject_object_name(value v_obj) {
    CAMLparam1(v_obj);
    QObject* obj = get_qobject<QObject>(v_obj);
    QByteArray utf8 = obj->objectName().toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

/* QTimer primitives */

CAMLprim value caml_oqt6_qtimer_single_shot(value v_msec, value v_cb) {
    CAMLparam2(v_msec, v_cb);
    int msec = Int_val(v_msec);
    value* root = new value;
    *root = v_cb;
    caml_register_global_root(root);

    QTimer::singleShot(msec, [root]() {
        CamlDomainLockGuard guard;
        caml_callback_exn(*root, Val_unit);
        caml_remove_global_root(root);
        delete root;
    });

    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtimer_create(value v_parent) {
    CAMLparam1(v_parent);
    QObject* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QObject>(Field(v_parent, 0));
    }
    QTimer* timer = new QTimer(parent);
    CAMLreturn(alloc_qobject(timer, !has_parent));
}

CAMLprim value caml_oqt6_qtimer_start(value v_timer, value v_msec) {
    CAMLparam2(v_timer, v_msec);
    QTimer* timer = get_qobject<QTimer>(v_timer);
    timer->start(Int_val(v_msec));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtimer_stop(value v_timer) {
    CAMLparam1(v_timer);
    QTimer* timer = get_qobject<QTimer>(v_timer);
    timer->stop();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtimer_connect_timeout(value v_timer, value v_cb) {
    CAMLparam2(v_timer, v_cb);
    QTimer* timer = get_qobject<QTimer>(v_timer);
    value* root = new value;
    *root = v_cb;
    caml_register_global_root(root);

    QObject::connect(timer, &QTimer::timeout, [root]() {
        CamlDomainLockGuard guard;
        caml_callback_exn(*root, Val_unit);
    });
    connect_root_cleanup(timer, root);

    CAMLreturn(Val_unit);
}

/* QApplication primitives */

static int global_argc = 0;
static std::vector<char*> global_argv;
static QApplication* global_app = nullptr;

CAMLprim value caml_oqt6_qapplication_create(value v_args) {
    CAMLparam1(v_args);
    if (global_app != nullptr) {
        caml_failwith("Oqt6: QApplication has already been created");
    }

    if (Is_block(v_args)) {
        value arr = Field(v_args, 0);
        mlsize_t len = Wosize_val(arr);
        global_argc = (int)len;
        global_argv.resize(global_argc + 1);
        for (int i = 0; i < global_argc; ++i) {
            global_argv[i] = strdup(String_val(Field(arr, i)));
        }
        global_argv[global_argc] = nullptr;
    } else {
        global_argc = 1;
        global_argv.resize(2);
        global_argv[0] = strdup("oqt6_app");
        global_argv[1] = nullptr;
    }

    global_app = new QApplication(global_argc, global_argv.data());
    CAMLreturn(alloc_qobject(global_app, false));
}

CAMLprim value caml_oqt6_qapplication_exec(value v_app) {
    CAMLparam1(v_app);
    QApplication* app = get_qobject<QApplication>(v_app);
    thread_domain_lock_depth--;
    caml_release_runtime_system();
    int ret = app->exec();
    caml_acquire_runtime_system();
    thread_domain_lock_depth++;
    CAMLreturn(Val_int(ret));
}

CAMLprim value caml_oqt6_qapplication_process_events(value v_unit) {
    CAMLparam1(v_unit);
    thread_domain_lock_depth--;
    caml_release_runtime_system();
    QCoreApplication::processEvents();
    caml_acquire_runtime_system();
    thread_domain_lock_depth++;
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qapplication_quit(value v_unit) {
    CAMLparam1(v_unit);
    QCoreApplication::quit();
    CAMLreturn(Val_unit);
}

/* QWidget primitives */

CAMLprim value caml_oqt6_qwidget_create(value v_parent) {
    CAMLparam1(v_parent);
    QWidget* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QWidget>(Field(v_parent, 0));
    }
    QWidget* w = new QWidget(parent);
    CAMLreturn(alloc_qobject(w, !has_parent));
}

CAMLprim value caml_oqt6_qwidget_show(value v_w) {
    CAMLparam1(v_w);
    QWidget* w = get_qobject<QWidget>(v_w);
    w->show();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qwidget_hide(value v_w) {
    CAMLparam1(v_w);
    QWidget* w = get_qobject<QWidget>(v_w);
    w->hide();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qwidget_close(value v_w) {
    CAMLparam1(v_w);
    QWidget* w = get_qobject<QWidget>(v_w);
    bool res = w->close();
    CAMLreturn(Val_bool(res));
}

CAMLprim value caml_oqt6_qwidget_set_window_title(value v_w, value v_title) {
    CAMLparam2(v_w, v_title);
    QWidget* w = get_qobject<QWidget>(v_w);
    w->setWindowTitle(QString::fromUtf8(String_val(v_title)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qwidget_window_title(value v_w) {
    CAMLparam1(v_w);
    QWidget* w = get_qobject<QWidget>(v_w);
    QByteArray utf8 = w->windowTitle().toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

CAMLprim value caml_oqt6_qwidget_resize(value v_w, value v_width, value v_height) {
    CAMLparam3(v_w, v_width, v_height);
    QWidget* w = get_qobject<QWidget>(v_w);
    w->resize(Int_val(v_width), Int_val(v_height));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qwidget_set_fixed_size(value v_w, value v_width, value v_height) {
    CAMLparam3(v_w, v_width, v_height);
    QWidget* w = get_qobject<QWidget>(v_w);
    w->setFixedSize(Int_val(v_width), Int_val(v_height));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qwidget_width(value v_w) {
    CAMLparam1(v_w);
    QWidget* w = get_qobject<QWidget>(v_w);
    CAMLreturn(Val_int(w->width()));
}

CAMLprim value caml_oqt6_qwidget_height(value v_w) {
    CAMLparam1(v_w);
    QWidget* w = get_qobject<QWidget>(v_w);
    CAMLreturn(Val_int(w->height()));
}

CAMLprim value caml_oqt6_qwidget_set_enabled(value v_w, value v_b) {
    CAMLparam2(v_w, v_b);
    QWidget* w = get_qobject<QWidget>(v_w);
    w->setEnabled(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qwidget_is_enabled(value v_w) {
    CAMLparam1(v_w);
    QWidget* w = get_qobject<QWidget>(v_w);
    CAMLreturn(Val_bool(w->isEnabled()));
}

CAMLprim value caml_oqt6_qwidget_set_visible(value v_w, value v_b) {
    CAMLparam2(v_w, v_b);
    QWidget* w = get_qobject<QWidget>(v_w);
    w->setVisible(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qwidget_is_visible(value v_w) {
    CAMLparam1(v_w);
    QWidget* w = get_qobject<QWidget>(v_w);
    CAMLreturn(Val_bool(w->isVisible()));
}

CAMLprim value caml_oqt6_qwidget_set_layout(value v_w, value v_layout) {
    CAMLparam2(v_w, v_layout);
    QWidget* w = get_qobject<QWidget>(v_w);
    QLayout* l = get_qobject<QLayout>(v_layout);
    w->setLayout(l);
    mark_parented(v_layout);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qwidget_set_style_sheet(value v_w, value v_style) {
    CAMLparam2(v_w, v_style);
    QWidget* w = get_qobject<QWidget>(v_w);
    w->setStyleSheet(QString::fromUtf8(String_val(v_style)));
    CAMLreturn(Val_unit);
}

/* QPushButton primitives */

CAMLprim value caml_oqt6_qpushbutton_create(value v_text, value v_parent) {
    CAMLparam2(v_text, v_parent);
    QWidget* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QWidget>(Field(v_parent, 0));
    }
    QPushButton* btn = new QPushButton(parent);
    if (Is_block(v_text)) {
        btn->setText(QString::fromUtf8(String_val(Field(v_text, 0))));
    }
    CAMLreturn(alloc_qobject(btn, !has_parent));
}

CAMLprim value caml_oqt6_qpushbutton_set_text(value v_btn, value v_text) {
    CAMLparam2(v_btn, v_text);
    QPushButton* btn = get_qobject<QPushButton>(v_btn);
    btn->setText(QString::fromUtf8(String_val(v_text)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpushbutton_text(value v_btn) {
    CAMLparam1(v_btn);
    QPushButton* btn = get_qobject<QPushButton>(v_btn);
    QByteArray utf8 = btn->text().toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

CAMLprim value caml_oqt6_qpushbutton_connect_clicked(value v_btn, value v_cb) {
    CAMLparam2(v_btn, v_cb);
    QPushButton* btn = get_qobject<QPushButton>(v_btn);
    value* root = new value;
    *root = v_cb;
    caml_register_global_root(root);

    QObject::connect(btn, &QPushButton::clicked, [root]() {
        CamlDomainLockGuard guard;
        caml_callback_exn(*root, Val_unit);
    });
    connect_root_cleanup(btn, root);

    CAMLreturn(Val_unit);
}

/* QLabel primitives */

CAMLprim value caml_oqt6_qlabel_create(value v_text, value v_parent) {
    CAMLparam2(v_text, v_parent);
    QWidget* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QWidget>(Field(v_parent, 0));
    }
    QLabel* lbl = new QLabel(parent);
    if (Is_block(v_text)) {
        lbl->setText(QString::fromUtf8(String_val(Field(v_text, 0))));
    }
    CAMLreturn(alloc_qobject(lbl, !has_parent));
}

CAMLprim value caml_oqt6_qlabel_set_text(value v_lbl, value v_text) {
    CAMLparam2(v_lbl, v_text);
    QLabel* lbl = get_qobject<QLabel>(v_lbl);
    lbl->setText(QString::fromUtf8(String_val(v_text)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qlabel_text(value v_lbl) {
    CAMLparam1(v_lbl);
    QLabel* lbl = get_qobject<QLabel>(v_lbl);
    QByteArray utf8 = lbl->text().toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

CAMLprim value caml_oqt6_qlabel_set_word_wrap(value v_lbl, value v_wrap) {
    CAMLparam2(v_lbl, v_wrap);
    QLabel* lbl = get_qobject<QLabel>(v_lbl);
    lbl->setWordWrap(Bool_val(v_wrap));
    CAMLreturn(Val_unit);
}

/* QLineEdit primitives */

CAMLprim value caml_oqt6_qlineedit_create(value v_text, value v_parent) {
    CAMLparam2(v_text, v_parent);
    QWidget* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QWidget>(Field(v_parent, 0));
    }
    QLineEdit* edit = new QLineEdit(parent);
    if (Is_block(v_text)) {
        edit->setText(QString::fromUtf8(String_val(Field(v_text, 0))));
    }
    CAMLreturn(alloc_qobject(edit, !has_parent));
}

CAMLprim value caml_oqt6_qlineedit_set_text(value v_edit, value v_text) {
    CAMLparam2(v_edit, v_text);
    QLineEdit* edit = get_qobject<QLineEdit>(v_edit);
    edit->setText(QString::fromUtf8(String_val(v_text)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qlineedit_text(value v_edit) {
    CAMLparam1(v_edit);
    QLineEdit* edit = get_qobject<QLineEdit>(v_edit);
    QByteArray utf8 = edit->text().toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

CAMLprim value caml_oqt6_qlineedit_set_placeholder_text(value v_edit, value v_text) {
    CAMLparam2(v_edit, v_text);
    QLineEdit* edit = get_qobject<QLineEdit>(v_edit);
    edit->setPlaceholderText(QString::fromUtf8(String_val(v_text)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qlineedit_placeholder_text(value v_edit) {
    CAMLparam1(v_edit);
    QLineEdit* edit = get_qobject<QLineEdit>(v_edit);
    QByteArray utf8 = edit->placeholderText().toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

CAMLprim value caml_oqt6_qlineedit_connect_text_changed(value v_edit, value v_cb) {
    CAMLparam2(v_edit, v_cb);
    QLineEdit* edit = get_qobject<QLineEdit>(v_edit);
    value* root = new value;
    *root = v_cb;
    caml_register_global_root(root);

    QObject::connect(edit, &QLineEdit::textChanged, [root](const QString& text) {
        CamlDomainLockGuard guard;
        QByteArray utf8 = text.toUtf8();
        value v_str = caml_copy_string(utf8.constData());
        caml_callback_exn(*root, v_str);
    });
    connect_root_cleanup(edit, root);

    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qlineedit_connect_return_pressed(value v_edit, value v_cb) {
    CAMLparam2(v_edit, v_cb);
    QLineEdit* edit = get_qobject<QLineEdit>(v_edit);
    value* root = new value;
    *root = v_cb;
    caml_register_global_root(root);

    QObject::connect(edit, &QLineEdit::returnPressed, [root]() {
        CamlDomainLockGuard guard;
        caml_callback_exn(*root, Val_unit);
    });
    connect_root_cleanup(edit, root);

    CAMLreturn(Val_unit);
}

/* Layout primitives */

CAMLprim value caml_oqt6_qvboxlayout_create(value v_parent) {
    CAMLparam1(v_parent);
    QWidget* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QWidget>(Field(v_parent, 0));
    }
    QVBoxLayout* l = new QVBoxLayout(parent);
    CAMLreturn(alloc_qobject(l, !has_parent));
}

CAMLprim value caml_oqt6_qhboxlayout_create(value v_parent) {
    CAMLparam1(v_parent);
    QWidget* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QWidget>(Field(v_parent, 0));
    }
    QHBoxLayout* l = new QHBoxLayout(parent);
    CAMLreturn(alloc_qobject(l, !has_parent));
}

CAMLprim value caml_oqt6_qboxlayout_add_widget(value v_layout, value v_stretch, value v_w) {
    CAMLparam3(v_layout, v_stretch, v_w);
    QBoxLayout* l = get_qobject<QBoxLayout>(v_layout);
    QWidget* w = get_qobject<QWidget>(v_w);
    int stretch = Is_block(v_stretch) ? Int_val(Field(v_stretch, 0)) : 0;
    l->addWidget(w, stretch);
    mark_parented(v_w);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qboxlayout_add_layout(value v_layout, value v_stretch, value v_sub) {
    CAMLparam3(v_layout, v_stretch, v_sub);
    QBoxLayout* l = get_qobject<QBoxLayout>(v_layout);
    QLayout* sub = get_qobject<QLayout>(v_sub);
    int stretch = Is_block(v_stretch) ? Int_val(Field(v_stretch, 0)) : 0;
    l->addLayout(sub, stretch);
    mark_parented(v_sub);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qboxlayout_add_stretch(value v_layout, value v_stretch) {
    CAMLparam2(v_layout, v_stretch);
    QBoxLayout* l = get_qobject<QBoxLayout>(v_layout);
    int stretch = Is_block(v_stretch) ? Int_val(Field(v_stretch, 0)) : 0;
    l->addStretch(stretch);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qboxlayout_add_spacing(value v_layout, value v_size) {
    CAMLparam2(v_layout, v_size);
    QBoxLayout* l = get_qobject<QBoxLayout>(v_layout);
    l->addSpacing(Int_val(v_size));
    CAMLreturn(Val_unit);
}

} // extern "C"
