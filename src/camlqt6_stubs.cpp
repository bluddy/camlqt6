#include <QApplication>
#include <QWidget>
#include <QPushButton>
#include <QLabel>
#include <QLineEdit>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QGridLayout>
#include <QCheckBox>
#include <QRadioButton>
#include <QComboBox>
#include <QSpinBox>
#include <QSlider>
#include <QProgressBar>
#include <QTextEdit>
#include <QMainWindow>
#include <QMenuBar>
#include <QMenu>
#include <QAction>
#include <QStatusBar>
#include <QDialog>
#include <QMessageBox>
#include <QFileDialog>
#include <QPainter>
#include <QColor>
#include <QFont>
#include <QPen>
#include <QBrush>
#include <QPaintEvent>
#include <QMouseEvent>
#include <QKeyEvent>
#include <QResizeEvent>
#include <QTimer>
#include <QString>
#include <QPointer>
#include <QAbstractItemModel>
#include <QAbstractTableModel>
#include <QStandardItemModel>
#include <QStandardItem>
#include <QTableView>
#include <QTreeView>
#include <QListView>
#include <QHeaderView>
#include <QItemSelectionModel>
#include <QModelIndex>
#include <QStringList>
#include <QList>
#include <QTabWidget>
#include <QStackedWidget>
#include <QSplitter>
#include <QScrollArea>
#include <QGroupBox>
#include <QToolBar>
#include <QDockWidget>
#include <QColorDialog>
#include <QFontDialog>
#include <QInputDialog>
#include <QProgressDialog>
#include <QPixmap>
#include <QIcon>
#include <QCursor>
#include <QClipboard>
#include <QDrag>
#include <QMimeData>
#include <QUrl>
#include <QDropEvent>
#include <QDragEnterEvent>
#include <QDragMoveEvent>
#include <QDragLeaveEvent>
#include <new>

#include <cstring>
#include <vector>

#include <QEvent>

#include "camlqt6_stubs.h"

static void finalize_qobject(value v) {
    OCamlQObject* holder = QObject_holder(v);
    if (holder->owned && !holder->ptr.isNull()) {
        holder->ptr.data()->deleteLater();
    }
    holder->~OCamlQObject();
}

static int compare_qobject(value v1, value v2) {
    OCamlQObject* h1 = QObject_holder(v1);
    OCamlQObject* h2 = QObject_holder(v2);
    QObject* p1 = h1->ptr.data();
    QObject* p2 = h2->ptr.data();
    if (p1 == p2) return 0;
    return (p1 < p2) ? -1 : 1;
}

static intnat hash_qobject(value v) {
    OCamlQObject* h = QObject_holder(v);
    return (intnat)h->ptr.data();
}

const struct custom_operations camlqt6_qobject_ops = {
    (char*)"org.oqt6.qobject",
    finalize_qobject,
    compare_qobject,
    hash_qobject,
    custom_serialize_default,
    custom_deserialize_default,
    custom_compare_ext_default,
    custom_fixed_length_default
};

value alloc_qobject(QObject* obj, bool owned) {
    /* Returning Val_unit here would hand an immediate back to OCaml code typed
       as Core.t; the first accessor call would then dereference it as a custom
       block. Raise instead. */
    if (!obj) {
        caml_failwith("CamlQt6: internal error, tried to wrap a null Qt object");
    }
    value v = caml_alloc_custom(&camlqt6_qobject_ops, sizeof(OCamlQObject), 0, 1);
    OCamlQObject* holder = new (Data_custom_val(v)) OCamlQObject();
    holder->ptr = obj;
    holder->owned = owned;
    return v;
}

void mark_parented(value v) {
    check_custom(v, &camlqt6_qobject_ops, "CamlQt6: expected a Qt object handle");
    OCamlQObject* holder = QObject_holder(v);
    holder->owned = false;
}

thread_local int thread_domain_lock_depth = 0;
thread_local bool thread_is_registered = false;

static void connect_root_cleanup(QObject* sender, value* root) {
    QObject::connect(sender, &QObject::destroyed, [root](QObject*) {
        CamlDomainLockGuard guard;
        caml_remove_global_root(root);
        delete root;
    });
}

/* Allocate (once) a registered global root cell and store [v] in it. Lets a
   callback be replaced later without leaking the previous registration. */
static void set_root(value** slot, value v) {
    if (*slot == nullptr) {
        *slot = new value;
        caml_register_global_root(*slot);
    }
    **slot = v;
}

// QColor custom operations
const struct custom_operations camlqt6_qcolor_ops = {
    (char*)"org.oqt6.qcolor",
    custom_finalize_default,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default,
    custom_compare_ext_default,
    custom_fixed_length_default
};

static value alloc_color(const QColor& c) {
    value v = caml_alloc_custom(&camlqt6_qcolor_ops, sizeof(QColor), 0, 1);
    new (Data_custom_val(v)) QColor(c);
    return v;
}

inline QColor& QColor_val(value v) {
    check_custom(v, &camlqt6_qcolor_ops, "CamlQt6: expected a Color.t");
    return *((QColor*)Data_custom_val(v));
}

// QFont custom operations
static void finalize_font(value v) {
    ((QFont*)Data_custom_val(v))->~QFont();
}

const struct custom_operations camlqt6_qfont_ops = {
    (char*)"org.oqt6.qfont",
    finalize_font,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default,
    custom_compare_ext_default,
    custom_fixed_length_default
};

static value alloc_font(const QFont& f) {
    value v = caml_alloc_custom(&camlqt6_qfont_ops, sizeof(QFont), 0, 1);
    new (Data_custom_val(v)) QFont(f);
    return v;
}

inline QFont& Font_val(value v) {
    check_custom(v, &camlqt6_qfont_ops, "CamlQt6: expected a Font.t");
    return *((QFont*)Data_custom_val(v));
}

// QPen custom operations
static void finalize_pen(value v) {
    ((QPen*)Data_custom_val(v))->~QPen();
}

const struct custom_operations camlqt6_qpen_ops = {
    (char*)"org.oqt6.qpen",
    finalize_pen,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default,
    custom_compare_ext_default,
    custom_fixed_length_default
};

static value alloc_pen(const QPen& p) {
    value v = caml_alloc_custom(&camlqt6_qpen_ops, sizeof(QPen), 0, 1);
    new (Data_custom_val(v)) QPen(p);
    return v;
}

inline QPen& Pen_val(value v) {
    check_custom(v, &camlqt6_qpen_ops, "CamlQt6: expected a Pen.t");
    return *((QPen*)Data_custom_val(v));
}

// QBrush custom operations
static void finalize_brush(value v) {
    ((QBrush*)Data_custom_val(v))->~QBrush();
}

const struct custom_operations camlqt6_qbrush_ops = {
    (char*)"org.oqt6.qbrush",
    finalize_brush,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default,
    custom_compare_ext_default,
    custom_fixed_length_default
};

static value alloc_brush(const QBrush& b) {
    value v = caml_alloc_custom(&camlqt6_qbrush_ops, sizeof(QBrush), 0, 1);
    new (Data_custom_val(v)) QBrush(b);
    return v;
}

inline QBrush& Brush_val(value v) {
    check_custom(v, &camlqt6_qbrush_ops, "CamlQt6: expected a Brush.t");
    return *((QBrush*)Data_custom_val(v));
}

// QPixmap custom operations
static void finalize_pixmap(value v) {
    ((QPixmap*)Data_custom_val(v))->~QPixmap();
}

const struct custom_operations camlqt6_qpixmap_ops = {
    (char*)"org.oqt6.qpixmap",
    finalize_pixmap,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default,
    custom_compare_ext_default,
    custom_fixed_length_default
};

static value alloc_pixmap(const QPixmap& p) {
    value v = caml_alloc_custom(&camlqt6_qpixmap_ops, sizeof(QPixmap), 0, 1);
    new (Data_custom_val(v)) QPixmap(p);
    return v;
}

inline QPixmap& Pixmap_val(value v) {
    check_custom(v, &camlqt6_qpixmap_ops, "CamlQt6: expected a Pixmap.t");
    return *((QPixmap*)Data_custom_val(v));
}

// QIcon custom operations
static void finalize_icon(value v) {
    ((QIcon*)Data_custom_val(v))->~QIcon();
}

const struct custom_operations camlqt6_qicon_ops = {
    (char*)"org.oqt6.qicon",
    finalize_icon,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default,
    custom_compare_ext_default,
    custom_fixed_length_default
};

static value alloc_icon(const QIcon& ic) {
    value v = caml_alloc_custom(&camlqt6_qicon_ops, sizeof(QIcon), 0, 1);
    new (Data_custom_val(v)) QIcon(ic);
    return v;
}

inline QIcon& Icon_val(value v) {
    check_custom(v, &camlqt6_qicon_ops, "CamlQt6: expected an Icon.t");
    return *((QIcon*)Data_custom_val(v));
}

// QPainter holder
struct OCamlPainterHolder {
    QPainter* painter;
};

#define Painter_holder(v) ((OCamlPainterHolder*)Data_custom_val(v))

const struct custom_operations camlqt6_qpainter_ops = {
    (char*)"org.oqt6.qpainter",
    custom_finalize_default,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default,
    custom_compare_ext_default,
    custom_fixed_length_default
};

static value alloc_painter(QPainter* p) {
    value v = caml_alloc_custom(&camlqt6_qpainter_ops, sizeof(OCamlPainterHolder), 0, 1);
    Painter_holder(v)->painter = p;
    return v;
}

static QPainter* get_painter(value v) {
    check_custom(v, &camlqt6_qpainter_ops, "CamlQt6: expected a Painter.t");
    OCamlPainterHolder* h = Painter_holder(v);
    if (!h->painter) {
        caml_failwith("CamlQt6: QPainter is no longer active (only valid during paint event)");
    }
    return h->painter;
}

// OCamlCanvas trampoline widget
class OCamlCanvas : public QWidget {
public:
    using QWidget::QWidget;

    value* paint_cb = nullptr;
    value* mouse_press_cb = nullptr;
    value* mouse_release_cb = nullptr;
    value* mouse_move_cb = nullptr;
    value* key_press_cb = nullptr;
    value* resize_cb = nullptr;
    value* drag_enter_cb = nullptr;
    value* drag_move_cb = nullptr;
    value* drag_leave_cb = nullptr;
    value* drop_cb = nullptr;

    ~OCamlCanvas() {
        CamlDomainLockGuard guard;
        cleanup_root(&paint_cb);
        cleanup_root(&mouse_press_cb);
        cleanup_root(&mouse_release_cb);
        cleanup_root(&mouse_move_cb);
        cleanup_root(&key_press_cb);
        cleanup_root(&resize_cb);
        cleanup_root(&drag_enter_cb);
        cleanup_root(&drag_move_cb);
        cleanup_root(&drag_leave_cb);
        cleanup_root(&drop_cb);
    }

private:
    void cleanup_root(value** r) {
        if (*r) {
            caml_remove_global_root(*r);
            delete *r;
            *r = nullptr;
        }
    }

protected:
    void paintEvent(QPaintEvent* event) override {
        if (paint_cb) {
            QPainter painter(this);
            CamlDomainLockGuard guard;
            CAMLparam0();
            CAMLlocal1(v_p);
            v_p = alloc_painter(&painter);
            value res = caml_callback_exn(*paint_cb, v_p);
            handle_callback_result(res);
            Painter_holder(v_p)->painter = nullptr;
            CAMLdrop;
        } else {
            QWidget::paintEvent(event);
        }
    }

    void mousePressEvent(QMouseEvent* event) override {
        if (mouse_press_cb) {
            CamlDomainLockGuard guard;
            int btn = 3;
            if (event->button() == Qt::LeftButton) btn = 0;
            else if (event->button() == Qt::RightButton) btn = 1;
            else if (event->button() == Qt::MiddleButton) btn = 2;

            value args[3] = {
                Val_int((int)event->position().x()),
                Val_int((int)event->position().y()),
                Val_int(btn)
            };
            value res = caml_callbackN_exn(*mouse_press_cb, 3, args);
            handle_callback_result(res);
        } else {
            QWidget::mousePressEvent(event);
        }
    }

    void mouseReleaseEvent(QMouseEvent* event) override {
        if (mouse_release_cb) {
            CamlDomainLockGuard guard;
            int btn = 3;
            if (event->button() == Qt::LeftButton) btn = 0;
            else if (event->button() == Qt::RightButton) btn = 1;
            else if (event->button() == Qt::MiddleButton) btn = 2;

            value args[3] = {
                Val_int((int)event->position().x()),
                Val_int((int)event->position().y()),
                Val_int(btn)
            };
            value res = caml_callbackN_exn(*mouse_release_cb, 3, args);
            handle_callback_result(res);
        } else {
            QWidget::mouseReleaseEvent(event);
        }
    }

    void mouseMoveEvent(QMouseEvent* event) override {
        if (mouse_move_cb) {
            CamlDomainLockGuard guard;
            int btn = 3;
            if (event->buttons() & Qt::LeftButton) btn = 0;
            else if (event->buttons() & Qt::RightButton) btn = 1;
            else if (event->buttons() & Qt::MiddleButton) btn = 2;

            value args[3] = {
                Val_int((int)event->position().x()),
                Val_int((int)event->position().y()),
                Val_int(btn)
            };
            value res = caml_callbackN_exn(*mouse_move_cb, 3, args);
            handle_callback_result(res);
        } else {
            QWidget::mouseMoveEvent(event);
        }
    }

    void keyPressEvent(QKeyEvent* event) override {
        if (key_press_cb) {
            CamlDomainLockGuard guard;
            CAMLparam0();
            CAMLlocal1(v_str);
            QByteArray utf8 = event->text().toUtf8();
            v_str = caml_copy_string(utf8.constData());
            value args[2] = {
                Val_int(event->key()),
                v_str
            };
            value res = caml_callbackN_exn(*key_press_cb, 2, args);
            handle_callback_result(res);
            CAMLdrop;
        } else {
            QWidget::keyPressEvent(event);
        }
    }

    void resizeEvent(QResizeEvent* event) override {
        if (resize_cb) {
            CamlDomainLockGuard guard;
            value args[4] = {
                Val_int(event->size().width()),
                Val_int(event->size().height()),
                Val_int(event->oldSize().width()),
                Val_int(event->oldSize().height())
            };
            value res = caml_callbackN_exn(*resize_cb, 4, args);
            handle_callback_result(res);
        }
        QWidget::resizeEvent(event);
    }

    void dragEnterEvent(QDragEnterEvent* event) override {
        if (drag_enter_cb) {
            CamlDomainLockGuard guard;
            CAMLparam0();
            CAMLlocal1(v_mime);
            v_mime = alloc_qobject(const_cast<QMimeData*>(event->mimeData()), false);
            value args[3] = {
                Val_int((int)event->position().x()),
                Val_int((int)event->position().y()),
                v_mime
            };
            value res = caml_callbackN_exn(*drag_enter_cb, 3, args);
            handle_callback_result(res);
            bool accepted = callback_to_bool(res);
            CAMLdrop;
            if (accepted) {
                event->acceptProposedAction();
                return;
            }
        }
        QWidget::dragEnterEvent(event);
    }

    void dragMoveEvent(QDragMoveEvent* event) override {
        if (drag_move_cb) {
            CamlDomainLockGuard guard;
            CAMLparam0();
            CAMLlocal1(v_mime);
            v_mime = alloc_qobject(const_cast<QMimeData*>(event->mimeData()), false);
            value args[3] = {
                Val_int((int)event->position().x()),
                Val_int((int)event->position().y()),
                v_mime
            };
            value res = caml_callbackN_exn(*drag_move_cb, 3, args);
            handle_callback_result(res);
            bool accepted = callback_to_bool(res);
            CAMLdrop;
            if (accepted) {
                event->acceptProposedAction();
                return;
            }
        }
        QWidget::dragMoveEvent(event);
    }

    void dragLeaveEvent(QDragLeaveEvent* event) override {
        if (drag_leave_cb) {
            CamlDomainLockGuard guard;
            value res = caml_callback_exn(*drag_leave_cb, Val_unit);
            handle_callback_result(res);
        }
        QWidget::dragLeaveEvent(event);
    }

    void dropEvent(QDropEvent* event) override {
        if (drop_cb) {
            CamlDomainLockGuard guard;
            CAMLparam0();
            CAMLlocal1(v_mime);
            v_mime = alloc_qobject(const_cast<QMimeData*>(event->mimeData()), false);
            value args[3] = {
                Val_int((int)event->position().x()),
                Val_int((int)event->position().y()),
                v_mime
            };
            value res = caml_callbackN_exn(*drop_cb, 3, args);
            handle_callback_result(res);
            CAMLdrop;
            event->acceptProposedAction();
        } else {
            QWidget::dropEvent(event);
        }
    }
};

class OCamlTableModel : public QAbstractTableModel {
public:
    value* row_count_cb = nullptr;
    value* col_count_cb = nullptr;
    value* data_cb = nullptr;
    value* header_data_cb = nullptr;
    value* sort_cb = nullptr;
    value* foreground_cb = nullptr;
    value* background_cb = nullptr;
    value* alignment_cb = nullptr;
    value* decoration_cb = nullptr;
    value* tooltip_cb = nullptr;

    explicit OCamlTableModel(QObject* parent = nullptr) : QAbstractTableModel(parent) {}

    ~OCamlTableModel() override {
        /* Must hold the runtime system before touching the global roots table:
           this destructor can run from finalize_qobject's deleteLater(), which
           is processed inside exec()/processEvents() after the runtime system
           has been released. */
        CamlDomainLockGuard guard;
        cleanup_root(&row_count_cb);
        cleanup_root(&col_count_cb);
        cleanup_root(&data_cb);
        cleanup_root(&header_data_cb);
        cleanup_root(&sort_cb);
        cleanup_root(&foreground_cb);
        cleanup_root(&background_cb);
        cleanup_root(&alignment_cb);
        cleanup_root(&decoration_cb);
        cleanup_root(&tooltip_cb);
    }

private:
    void cleanup_root(value** r) {
        if (*r) {
            caml_remove_global_root(*r);
            delete *r;
            *r = nullptr;
        }
    }

    /* The OCaml closures below are user-supplied and their return types are
       unchecked at the C boundary, so validate before coercing. */
    static int callback_to_int(value res) {
        if (Is_exception_result(res)) {
            handle_callback_result(res);
            return 0;
        }
        if (res >= Val_unit && res <= Camlqt6_Max_int) return Int_val(res);
        fprintf(stderr, "[CamlQt6] TableModel callback must return an int\n");
        return 0;
    }

    static QString callback_to_string(value res) {
        if (Is_exception_result(res)) {
            handle_callback_result(res);
            return QString();
        }
        if (Is_block(res) && Tag_val(res) == String_tag) {
            return QString::fromUtf8(
                String_val(res), caml_string_length(res));
        }
        fprintf(stderr, "[CamlQt6] TableModel callback must return a string\n");
        return QString();
    }

public:
    int rowCount(const QModelIndex& parent = QModelIndex()) const override {
        if (parent.isValid() || !row_count_cb) return 0;
        CamlDomainLockGuard guard;
        return callback_to_int(caml_callback_exn(*row_count_cb, Val_unit));
    }

    int columnCount(const QModelIndex& parent = QModelIndex()) const override {
        if (parent.isValid() || !col_count_cb) return 0;
        CamlDomainLockGuard guard;
        return callback_to_int(caml_callback_exn(*col_count_cb, Val_unit));
    }

    /* Role helpers. Each optional OCaml callback has the shape
       (row, col) -> payload, and returning nothing means "no opinion", so the
       view falls back to its own styling. */
    template <typename F>
    QVariant call_cell_role(value* cb, const QModelIndex& index, F&& convert) const {
        if (!cb || !index.isValid()) return QVariant();
        CamlDomainLockGuard guard;
        value args[2] = { Val_int(index.row()), Val_int(index.column()) };
        value res = caml_callbackN_exn(*cb, 2, args);
        if (Is_exception_result(res)) {
            handle_callback_result(res);
            return QVariant();
        }
        if (res == Val_none) return QVariant();
        if (Is_block(res) && Wosize_val(res) >= 1) return convert(Field(res, 0));
        return QVariant();
    }

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override {
        if (!index.isValid()) return QVariant();
        if (role == Qt::ForegroundRole) {
            return call_cell_role(foreground_cb, index, [](value v) {
                return QVariant(QColor_val(v));
            });
        }
        if (role == Qt::BackgroundRole) {
            return call_cell_role(background_cb, index, [](value v) {
                return QVariant(QColor_val(v));
            });
        }
        if (role == Qt::TextAlignmentRole) {
            return call_cell_role(alignment_cb, index, [](value v) {
                /* Encoded as Qt::Alignment flags by the OCaml layer. */
                return QVariant(Int_val(v));
            });
        }
        if (role == Qt::DecorationRole) {
            return call_cell_role(decoration_cb, index, [](value v) {
                return QVariant(Icon_val(v));
            });
        }
        if (role == Qt::ToolTipRole) {
            return call_cell_role(tooltip_cb, index, [](value v) {
                return QVariant(QString::fromUtf8(String_val(v)));
            });
        }
        if (role != Qt::DisplayRole && role != Qt::EditRole) return QVariant();
        if (!data_cb) return QVariant();
        CamlDomainLockGuard guard;
        value args[2] = { Val_int(index.row()), Val_int(index.column()) };
        return QVariant(callback_to_string(caml_callbackN_exn(*data_cb, 2, args)));
    }

    /* QAbstractItemModel::sort is a no-op unless overridden, which is why
       TableView.set_sorting_enabled used to appear to work and silently did
       nothing for this model. */
    void sort(int column, Qt::SortOrder order = Qt::AscendingOrder) override {
        if (!sort_cb) {
            QAbstractTableModel::sort(column, order);
            return;
        }
        {
            CamlDomainLockGuard guard;
            value args[2] = { Val_int(column), Val_int(order == Qt::DescendingOrder ? 1 : 0) };
            value res = caml_callbackN_exn(*sort_cb, 2, args);
            if (Is_exception_result(res)) handle_callback_result(res);
        }
        beginResetModel();
        endResetModel();
    }

    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override {
        if (role != Qt::DisplayRole || !header_data_cb) {
            return QAbstractTableModel::headerData(section, orientation, role);
        }
        CamlDomainLockGuard guard;
        int orient = (orientation == Qt::Horizontal) ? 0 : 1;
        value args[2] = { Val_int(section), Val_int(orient) };
        return QVariant(callback_to_string(caml_callbackN_exn(*header_data_cb, 2, args)));
    }

    void notify_reset() {
        beginResetModel();
        endResetModel();
    }

    void notify_data_changed(int top_row, int left_col, int bottom_row, int right_col) {
        QModelIndex top_left = index(top_row, left_col);
        QModelIndex bottom_right = index(bottom_row, right_col);
        emit dataChanged(top_left, bottom_right);
    }
};

extern "C" {

/* QObject primitives */

CAMLprim value caml_oqt6_qobject_delete(value v_obj) {
    CAMLparam1(v_obj);
    check_custom(v_obj, &camlqt6_qobject_ops, "CamlQt6: expected a Qt object handle");
    OCamlQObject* holder = QObject_holder(v_obj);
    if (holder->ptr.isNull()) {
        CAMLreturn(Val_unit);
    }
    if (!holder->owned) {
        /* Qt owns this object (it is a QObject child, a cached getter result such
           as QMainWindow::menuBar(), or ownership was transferred by an add* /
           set* call). Deleting it would corrupt Qt's child list. */
        holder->ptr = nullptr;
        caml_invalid_argument("CamlQt6: Object.delete on an object owned by Qt");
    }
    delete holder->ptr.data();
    holder->ptr = nullptr;
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qobject_is_valid(value v_obj) {
    CAMLparam1(v_obj);
    check_custom(v_obj, &camlqt6_qobject_ops, "CamlQt6: expected a Qt object handle");
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

CAMLprim value caml_oqt6_qobject_connect_destroyed(value v_obj, value v_cb) {
    CAMLparam2(v_obj, v_cb);
    QObject* obj = get_qobject<QObject>(v_obj);
    value* root = new value;
    *root = v_cb;
    caml_register_global_root(root);

    QObject::connect(obj, &QObject::destroyed, [root]() {
        CamlDomainLockGuard guard;
        value res = caml_callback_exn(*root, Val_unit);
        handle_callback_result(res);
    });
    connect_root_cleanup(obj, root);

    CAMLreturn(Val_unit);
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
        value res = caml_callback_exn(*root, Val_unit);
        handle_callback_result(res);
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
        value res = caml_callback_exn(*root, Val_unit);
        handle_callback_result(res);
    });
    connect_root_cleanup(timer, root);

    CAMLreturn(Val_unit);
}

/* QApplication primitives */

static int global_argc = 0;
static std::vector<char*> global_argv;
static QApplication* global_app = nullptr;

static void qt_message_handler(QtMsgType type, const QMessageLogContext &context, const QString &msg) {
    Q_UNUSED(context);
    if (msg.contains("propagateSizeHints") || msg.contains("QThreadStorage")) return;
    QByteArray localMsg = msg.toLocal8Bit();
    switch (type) {
    case QtDebugMsg:
        fprintf(stdout, "Debug: %s\n", localMsg.constData());
        break;
    case QtInfoMsg:
        fprintf(stdout, "Info: %s\n", localMsg.constData());
        break;
    case QtWarningMsg:
        fprintf(stderr, "Warning: %s\n", localMsg.constData());
        break;
    case QtCriticalMsg:
        fprintf(stderr, "Critical: %s\n", localMsg.constData());
        break;
    case QtFatalMsg:
        fprintf(stderr, "Fatal: %s\n", localMsg.constData());
        abort();
    }
}

class OCamlTaskEvent : public QEvent {
public:
    static const QEvent::Type TaskEventType = static_cast<QEvent::Type>(QEvent::User + 100);
    value* task_root;
    OCamlTaskEvent(value* root) : QEvent(TaskEventType), task_root(root) {}
    ~OCamlTaskEvent() {
        if (task_root) {
            CamlDomainLockGuard guard;
            caml_remove_global_root(task_root);
            delete task_root;
        }
    }
};

class OCamlUiDispatcher : public QObject {
public:
    static OCamlUiDispatcher* instance() {
        static OCamlUiDispatcher* disp = nullptr;
        if (!disp) {
            disp = new OCamlUiDispatcher();
            if (QCoreApplication::instance()) {
                disp->moveToThread(QCoreApplication::instance()->thread());
            }
        }
        return disp;
    }
protected:
    void customEvent(QEvent* event) override {
        if (event->type() == OCamlTaskEvent::TaskEventType) {
            OCamlTaskEvent* task = static_cast<OCamlTaskEvent*>(event);
            if (task->task_root) {
                CamlDomainLockGuard guard;
                value res = caml_callback_exn(*(task->task_root), Val_unit);
                handle_callback_result(res);
                caml_remove_global_root(task->task_root);
                delete task->task_root;
                task->task_root = nullptr;
            }
        }
    }
};

CAMLprim value caml_oqt6_qapplication_create(value v_args) {
    CAMLparam1(v_args);
    if (global_app != nullptr) {
        caml_failwith("CamlQt6: QApplication has already been created");
    }
    /* The QApplication must be created on the OCaml main domain, i.e. the thread
       that will run the Qt event loop. Creating it from a secondary domain would
       make the lock bookkeeping below (and therefore every CamlDomainLockGuard
       on that thread) lie about the runtime system. */
    if (Caml_state->id != 0) {
        caml_failwith(
            "CamlQt6: App.create must be called from the main OCaml domain "
            "(the thread that runs the Qt event loop)");
    }
    /* Correct for this thread: an OCaml -> C++ call is in progress, so the
       calling OCaml frame already holds the runtime system. The blocking
       sections below decrement this to 0 for their duration. */
    thread_domain_lock_depth = 1;
    /* The OCaml main thread is already registered with the runtime; calling
       caml_c_thread_register() here would deadlock on the systhreads mutex.
       CamlDomainLockGuard still registers lazily for foreign threads. */
    thread_is_registered = true;
    qInstallMessageHandler(qt_message_handler);

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
        global_argv[0] = strdup("camlqt6_app");
        global_argv[1] = nullptr;
    }

    global_app = new QApplication(global_argc, global_argv.data());
    OCamlUiDispatcher::instance();
    CAMLreturn(alloc_qobject(global_app, false));
}

CAMLprim value caml_oqt6_qapplication_exec(value v_app) {
    CAMLparam1(v_app);
    QApplication* app = get_qobject<QApplication>(v_app);
    int ret;
    {
        CamlBlockingSection blocking_section;
        ret = app->exec();
    }
    CAMLreturn(Val_int(ret));
}

CAMLprim value caml_oqt6_qapplication_process_events(value v_unit) {
    CAMLparam1(v_unit);
    {
        CamlBlockingSection blocking_section;
        QCoreApplication::processEvents();
    }
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qapplication_process_events_wait(value v_timeout_ms) {
    CAMLparam1(v_timeout_ms);
    int timeout = Is_block(v_timeout_ms) ? Int_val(Field(v_timeout_ms, 0)) : 100;
    {
        CamlBlockingSection blocking_section;
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents, timeout);
    }
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qapplication_is_ui_thread(value v_unit) {
    CAMLparam1(v_unit);
    if (!QCoreApplication::instance()) {
        CAMLreturn(Val_bool(true));
    }
    bool is_ui = (QThread::currentThread() == QCoreApplication::instance()->thread());
    CAMLreturn(Val_bool(is_ui));
}

CAMLprim value caml_oqt6_qapplication_post_task(value v_task) {
    CAMLparam1(v_task);
    if (!QCoreApplication::instance()) {
        value res = caml_callback_exn(v_task, Val_unit);
        handle_callback_result(res);
        CAMLreturn(Val_unit);
    }
    value* root = new value;
    *root = v_task;
    caml_register_global_root(root);
    OCamlTaskEvent* event = new OCamlTaskEvent(root);
    QCoreApplication::postEvent(OCamlUiDispatcher::instance(), event);
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

CAMLprim value caml_oqt6_qwidget_set_accept_drops(value v_w, value v_accept) {
    CAMLparam2(v_w, v_accept);
    QWidget* w = get_qobject<QWidget>(v_w);
    w->setAcceptDrops(Bool_val(v_accept));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qwidget_accept_drops(value v_w) {
    CAMLparam1(v_w);
    QWidget* w = get_qobject<QWidget>(v_w);
    CAMLreturn(Val_bool(w->acceptDrops()));
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
        value res = caml_callback_exn(*root, Val_unit);
        handle_callback_result(res);
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
        value res = caml_callback_exn(*root, v_str);
        handle_callback_result(res);
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
        value res = caml_callback_exn(*root, Val_unit);
        handle_callback_result(res);
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

CAMLprim value caml_oqt6_qlayout_set_spacing(value v_layout, value v_spacing) {
    CAMLparam2(v_layout, v_spacing);
    QLayout* l = get_qobject<QLayout>(v_layout);
    l->setSpacing(Int_val(v_spacing));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qlayout_set_contents_margins(value v_layout, value v_left, value v_top, value v_right, value v_bottom) {
    CAMLparam5(v_layout, v_left, v_top, v_right, v_bottom);
    QLayout* l = get_qobject<QLayout>(v_layout);
    l->setContentsMargins(Int_val(v_left), Int_val(v_top), Int_val(v_right), Int_val(v_bottom));
    CAMLreturn(Val_unit);
}

/* QCheckBox primitives */

CAMLprim value caml_oqt6_qcheckbox_create(value v_text, value v_parent) {
    CAMLparam2(v_text, v_parent);
    QWidget* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QWidget>(Field(v_parent, 0));
    }
    QCheckBox* cb = new QCheckBox(parent);
    if (Is_block(v_text)) {
        cb->setText(QString::fromUtf8(String_val(Field(v_text, 0))));
    }
    CAMLreturn(alloc_qobject(cb, !has_parent));
}

CAMLprim value caml_oqt6_qcheckbox_set_checked(value v_cb, value v_checked) {
    CAMLparam2(v_cb, v_checked);
    QCheckBox* cb = get_qobject<QCheckBox>(v_cb);
    cb->setChecked(Bool_val(v_checked));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qcheckbox_is_checked(value v_cb) {
    CAMLparam1(v_cb);
    QCheckBox* cb = get_qobject<QCheckBox>(v_cb);
    CAMLreturn(Val_bool(cb->isChecked()));
}

CAMLprim value caml_oqt6_qcheckbox_set_text(value v_cb, value v_text) {
    CAMLparam2(v_cb, v_text);
    QCheckBox* cb = get_qobject<QCheckBox>(v_cb);
    cb->setText(QString::fromUtf8(String_val(v_text)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qcheckbox_text(value v_cb) {
    CAMLparam1(v_cb);
    QCheckBox* cb = get_qobject<QCheckBox>(v_cb);
    QByteArray utf8 = cb->text().toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

CAMLprim value caml_oqt6_qcheckbox_connect_toggled(value v_cb, value v_fn) {
    CAMLparam2(v_cb, v_fn);
    QCheckBox* cb = get_qobject<QCheckBox>(v_cb);
    value* root = new value;
    *root = v_fn;
    caml_register_global_root(root);

    QObject::connect(cb, &QCheckBox::toggled, [root](bool checked) {
        CamlDomainLockGuard guard;
        value res = caml_callback_exn(*root, Val_bool(checked));
        handle_callback_result(res);
    });
    connect_root_cleanup(cb, root);

    CAMLreturn(Val_unit);
}

/* QRadioButton primitives */

CAMLprim value caml_oqt6_qradiobutton_create(value v_text, value v_parent) {
    CAMLparam2(v_text, v_parent);
    QWidget* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QWidget>(Field(v_parent, 0));
    }
    QRadioButton* rb = new QRadioButton(parent);
    if (Is_block(v_text)) {
        rb->setText(QString::fromUtf8(String_val(Field(v_text, 0))));
    }
    CAMLreturn(alloc_qobject(rb, !has_parent));
}

CAMLprim value caml_oqt6_qradiobutton_set_checked(value v_rb, value v_checked) {
    CAMLparam2(v_rb, v_checked);
    QRadioButton* rb = get_qobject<QRadioButton>(v_rb);
    rb->setChecked(Bool_val(v_checked));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qradiobutton_is_checked(value v_rb) {
    CAMLparam1(v_rb);
    QRadioButton* rb = get_qobject<QRadioButton>(v_rb);
    CAMLreturn(Val_bool(rb->isChecked()));
}

CAMLprim value caml_oqt6_qradiobutton_set_text(value v_rb, value v_text) {
    CAMLparam2(v_rb, v_text);
    QRadioButton* rb = get_qobject<QRadioButton>(v_rb);
    rb->setText(QString::fromUtf8(String_val(v_text)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qradiobutton_text(value v_rb) {
    CAMLparam1(v_rb);
    QRadioButton* rb = get_qobject<QRadioButton>(v_rb);
    QByteArray utf8 = rb->text().toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

CAMLprim value caml_oqt6_qradiobutton_connect_toggled(value v_rb, value v_fn) {
    CAMLparam2(v_rb, v_fn);
    QRadioButton* rb = get_qobject<QRadioButton>(v_rb);
    value* root = new value;
    *root = v_fn;
    caml_register_global_root(root);

    QObject::connect(rb, &QRadioButton::toggled, [root](bool checked) {
        CamlDomainLockGuard guard;
        value res = caml_callback_exn(*root, Val_bool(checked));
        handle_callback_result(res);
    });
    connect_root_cleanup(rb, root);

    CAMLreturn(Val_unit);
}

/* QComboBox primitives */

CAMLprim value caml_oqt6_qcombobox_create(value v_parent) {
    CAMLparam1(v_parent);
    QWidget* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QWidget>(Field(v_parent, 0));
    }
    QComboBox* cb = new QComboBox(parent);
    CAMLreturn(alloc_qobject(cb, !has_parent));
}

CAMLprim value caml_oqt6_qcombobox_add_item(value v_cb, value v_text) {
    CAMLparam2(v_cb, v_text);
    QComboBox* cb = get_qobject<QComboBox>(v_cb);
    cb->addItem(QString::fromUtf8(String_val(v_text)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qcombobox_count(value v_cb) {
    CAMLparam1(v_cb);
    QComboBox* cb = get_qobject<QComboBox>(v_cb);
    CAMLreturn(Val_int(cb->count()));
}

CAMLprim value caml_oqt6_qcombobox_current_index(value v_cb) {
    CAMLparam1(v_cb);
    QComboBox* cb = get_qobject<QComboBox>(v_cb);
    CAMLreturn(Val_int(cb->currentIndex()));
}

CAMLprim value caml_oqt6_qcombobox_set_current_index(value v_cb, value v_idx) {
    CAMLparam2(v_cb, v_idx);
    QComboBox* cb = get_qobject<QComboBox>(v_cb);
    cb->setCurrentIndex(Int_val(v_idx));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qcombobox_current_text(value v_cb) {
    CAMLparam1(v_cb);
    QComboBox* cb = get_qobject<QComboBox>(v_cb);
    QByteArray utf8 = cb->currentText().toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

CAMLprim value caml_oqt6_qcombobox_item_text(value v_cb, value v_idx) {
    CAMLparam2(v_cb, v_idx);
    QComboBox* cb = get_qobject<QComboBox>(v_cb);
    QByteArray utf8 = cb->itemText(Int_val(v_idx)).toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

CAMLprim value caml_oqt6_qcombobox_clear(value v_cb) {
    CAMLparam1(v_cb);
    QComboBox* cb = get_qobject<QComboBox>(v_cb);
    cb->clear();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qcombobox_connect_current_index_changed(value v_cb, value v_fn) {
    CAMLparam2(v_cb, v_fn);
    QComboBox* cb = get_qobject<QComboBox>(v_cb);
    value* root = new value;
    *root = v_fn;
    caml_register_global_root(root);

    QObject::connect(cb, &QComboBox::currentIndexChanged, [root](int idx) {
        CamlDomainLockGuard guard;
        value res = caml_callback_exn(*root, Val_int(idx));
        handle_callback_result(res);
    });
    connect_root_cleanup(cb, root);

    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qcombobox_connect_current_text_changed(value v_cb, value v_fn) {
    CAMLparam2(v_cb, v_fn);
    QComboBox* cb = get_qobject<QComboBox>(v_cb);
    value* root = new value;
    *root = v_fn;
    caml_register_global_root(root);

    QObject::connect(cb, &QComboBox::currentTextChanged, [root](const QString& text) {
        CamlDomainLockGuard guard;
        QByteArray utf8 = text.toUtf8();
        value v_str = caml_copy_string(utf8.constData());
        value res = caml_callback_exn(*root, v_str);
        handle_callback_result(res);
    });
    connect_root_cleanup(cb, root);

    CAMLreturn(Val_unit);
}

/* QSpinBox primitives */

CAMLprim value caml_oqt6_qspinbox_create(value v_parent) {
    CAMLparam1(v_parent);
    QWidget* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QWidget>(Field(v_parent, 0));
    }
    QSpinBox* sb = new QSpinBox(parent);
    CAMLreturn(alloc_qobject(sb, !has_parent));
}

CAMLprim value caml_oqt6_qspinbox_value(value v_sb) {
    CAMLparam1(v_sb);
    QSpinBox* sb = get_qobject<QSpinBox>(v_sb);
    CAMLreturn(Val_int(sb->value()));
}

CAMLprim value caml_oqt6_qspinbox_set_value(value v_sb, value v_val) {
    CAMLparam2(v_sb, v_val);
    QSpinBox* sb = get_qobject<QSpinBox>(v_sb);
    sb->setValue(Int_val(v_val));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qspinbox_set_minimum(value v_sb, value v_min) {
    CAMLparam2(v_sb, v_min);
    QSpinBox* sb = get_qobject<QSpinBox>(v_sb);
    sb->setMinimum(Int_val(v_min));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qspinbox_set_maximum(value v_sb, value v_max) {
    CAMLparam2(v_sb, v_max);
    QSpinBox* sb = get_qobject<QSpinBox>(v_sb);
    sb->setMaximum(Int_val(v_max));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qspinbox_set_range(value v_sb, value v_min, value v_max) {
    CAMLparam3(v_sb, v_min, v_max);
    QSpinBox* sb = get_qobject<QSpinBox>(v_sb);
    sb->setRange(Int_val(v_min), Int_val(v_max));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qspinbox_set_single_step(value v_sb, value v_step) {
    CAMLparam2(v_sb, v_step);
    QSpinBox* sb = get_qobject<QSpinBox>(v_sb);
    sb->setSingleStep(Int_val(v_step));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qspinbox_set_prefix(value v_sb, value v_prefix) {
    CAMLparam2(v_sb, v_prefix);
    QSpinBox* sb = get_qobject<QSpinBox>(v_sb);
    sb->setPrefix(QString::fromUtf8(String_val(v_prefix)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qspinbox_set_suffix(value v_sb, value v_suffix) {
    CAMLparam2(v_sb, v_suffix);
    QSpinBox* sb = get_qobject<QSpinBox>(v_sb);
    sb->setSuffix(QString::fromUtf8(String_val(v_suffix)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qspinbox_connect_value_changed(value v_sb, value v_fn) {
    CAMLparam2(v_sb, v_fn);
    QSpinBox* sb = get_qobject<QSpinBox>(v_sb);
    value* root = new value;
    *root = v_fn;
    caml_register_global_root(root);

    QObject::connect(sb, &QSpinBox::valueChanged, [root](int val) {
        CamlDomainLockGuard guard;
        value res = caml_callback_exn(*root, Val_int(val));
        handle_callback_result(res);
    });
    connect_root_cleanup(sb, root);

    CAMLreturn(Val_unit);
}

/* QSlider primitives */

CAMLprim value caml_oqt6_qslider_create(value v_orient, value v_parent) {
    CAMLparam2(v_orient, v_parent);
    QWidget* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QWidget>(Field(v_parent, 0));
    }
    Qt::Orientation orient = Qt::Horizontal;
    if (Is_block(v_orient)) {
        orient = (Int_val(Field(v_orient, 0)) == 0) ? Qt::Horizontal : Qt::Vertical;
    }
    QSlider* s = new QSlider(orient, parent);
    CAMLreturn(alloc_qobject(s, !has_parent));
}

CAMLprim value caml_oqt6_qslider_value(value v_s) {
    CAMLparam1(v_s);
    QSlider* s = get_qobject<QSlider>(v_s);
    CAMLreturn(Val_int(s->value()));
}

CAMLprim value caml_oqt6_qslider_set_value(value v_s, value v_val) {
    CAMLparam2(v_s, v_val);
    QSlider* s = get_qobject<QSlider>(v_s);
    s->setValue(Int_val(v_val));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qslider_set_minimum(value v_s, value v_min) {
    CAMLparam2(v_s, v_min);
    QSlider* s = get_qobject<QSlider>(v_s);
    s->setMinimum(Int_val(v_min));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qslider_set_maximum(value v_s, value v_max) {
    CAMLparam2(v_s, v_max);
    QSlider* s = get_qobject<QSlider>(v_s);
    s->setMaximum(Int_val(v_max));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qslider_set_range(value v_s, value v_min, value v_max) {
    CAMLparam3(v_s, v_min, v_max);
    QSlider* s = get_qobject<QSlider>(v_s);
    s->setRange(Int_val(v_min), Int_val(v_max));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qslider_set_single_step(value v_s, value v_step) {
    CAMLparam2(v_s, v_step);
    QSlider* s = get_qobject<QSlider>(v_s);
    s->setSingleStep(Int_val(v_step));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qslider_set_orientation(value v_s, value v_orient) {
    CAMLparam2(v_s, v_orient);
    QSlider* s = get_qobject<QSlider>(v_s);
    Qt::Orientation orient = (Int_val(v_orient) == 0) ? Qt::Horizontal : Qt::Vertical;
    s->setOrientation(orient);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qslider_connect_value_changed(value v_s, value v_fn) {
    CAMLparam2(v_s, v_fn);
    QSlider* s = get_qobject<QSlider>(v_s);
    value* root = new value;
    *root = v_fn;
    caml_register_global_root(root);

    QObject::connect(s, &QSlider::valueChanged, [root](int val) {
        CamlDomainLockGuard guard;
        value res = caml_callback_exn(*root, Val_int(val));
        handle_callback_result(res);
    });
    connect_root_cleanup(s, root);

    CAMLreturn(Val_unit);
}

/* QProgressBar primitives */

CAMLprim value caml_oqt6_qprogressbar_create(value v_parent) {
    CAMLparam1(v_parent);
    QWidget* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QWidget>(Field(v_parent, 0));
    }
    QProgressBar* pb = new QProgressBar(parent);
    CAMLreturn(alloc_qobject(pb, !has_parent));
}

CAMLprim value caml_oqt6_qprogressbar_value(value v_pb) {
    CAMLparam1(v_pb);
    QProgressBar* pb = get_qobject<QProgressBar>(v_pb);
    CAMLreturn(Val_int(pb->value()));
}

CAMLprim value caml_oqt6_qprogressbar_set_value(value v_pb, value v_val) {
    CAMLparam2(v_pb, v_val);
    QProgressBar* pb = get_qobject<QProgressBar>(v_pb);
    pb->setValue(Int_val(v_val));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qprogressbar_set_minimum(value v_pb, value v_min) {
    CAMLparam2(v_pb, v_min);
    QProgressBar* pb = get_qobject<QProgressBar>(v_pb);
    pb->setMinimum(Int_val(v_min));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qprogressbar_set_maximum(value v_pb, value v_max) {
    CAMLparam2(v_pb, v_max);
    QProgressBar* pb = get_qobject<QProgressBar>(v_pb);
    pb->setMaximum(Int_val(v_max));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qprogressbar_set_range(value v_pb, value v_min, value v_max) {
    CAMLparam3(v_pb, v_min, v_max);
    QProgressBar* pb = get_qobject<QProgressBar>(v_pb);
    pb->setRange(Int_val(v_min), Int_val(v_max));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qprogressbar_set_format(value v_pb, value v_fmt) {
    CAMLparam2(v_pb, v_fmt);
    QProgressBar* pb = get_qobject<QProgressBar>(v_pb);
    pb->setFormat(QString::fromUtf8(String_val(v_fmt)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qprogressbar_reset(value v_pb) {
    CAMLparam1(v_pb);
    QProgressBar* pb = get_qobject<QProgressBar>(v_pb);
    pb->reset();
    CAMLreturn(Val_unit);
}

/* QTextEdit primitives */

CAMLprim value caml_oqt6_qtextedit_create(value v_text, value v_parent) {
    CAMLparam2(v_text, v_parent);
    QWidget* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QWidget>(Field(v_parent, 0));
    }
    QTextEdit* te = new QTextEdit(parent);
    if (Is_block(v_text)) {
        te->setText(QString::fromUtf8(String_val(Field(v_text, 0))));
    }
    CAMLreturn(alloc_qobject(te, !has_parent));
}

CAMLprim value caml_oqt6_qtextedit_to_plain_text(value v_te) {
    CAMLparam1(v_te);
    QTextEdit* te = get_qobject<QTextEdit>(v_te);
    QByteArray utf8 = te->toPlainText().toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

CAMLprim value caml_oqt6_qtextedit_set_plain_text(value v_te, value v_text) {
    CAMLparam2(v_te, v_text);
    QTextEdit* te = get_qobject<QTextEdit>(v_te);
    te->setPlainText(QString::fromUtf8(String_val(v_text)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtextedit_to_html(value v_te) {
    CAMLparam1(v_te);
    QTextEdit* te = get_qobject<QTextEdit>(v_te);
    QByteArray utf8 = te->toHtml().toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

CAMLprim value caml_oqt6_qtextedit_set_html(value v_te, value v_html) {
    CAMLparam2(v_te, v_html);
    QTextEdit* te = get_qobject<QTextEdit>(v_te);
    te->setHtml(QString::fromUtf8(String_val(v_html)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtextedit_append(value v_te, value v_text) {
    CAMLparam2(v_te, v_text);
    QTextEdit* te = get_qobject<QTextEdit>(v_te);
    te->append(QString::fromUtf8(String_val(v_text)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtextedit_clear(value v_te) {
    CAMLparam1(v_te);
    QTextEdit* te = get_qobject<QTextEdit>(v_te);
    te->clear();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtextedit_set_read_only(value v_te, value v_ro) {
    CAMLparam2(v_te, v_ro);
    QTextEdit* te = get_qobject<QTextEdit>(v_te);
    te->setReadOnly(Bool_val(v_ro));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtextedit_is_read_only(value v_te) {
    CAMLparam1(v_te);
    QTextEdit* te = get_qobject<QTextEdit>(v_te);
    CAMLreturn(Val_bool(te->isReadOnly()));
}

CAMLprim value caml_oqt6_qtextedit_connect_text_changed(value v_te, value v_fn) {
    CAMLparam2(v_te, v_fn);
    QTextEdit* te = get_qobject<QTextEdit>(v_te);
    value* root = new value;
    *root = v_fn;
    caml_register_global_root(root);

    QObject::connect(te, &QTextEdit::textChanged, [root]() {
        CamlDomainLockGuard guard;
        value res = caml_callback_exn(*root, Val_unit);
        handle_callback_result(res);
    });
    connect_root_cleanup(te, root);

    CAMLreturn(Val_unit);
}

/* QGridLayout primitives */

CAMLprim value caml_oqt6_qgridlayout_create(value v_parent) {
    CAMLparam1(v_parent);
    QWidget* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QWidget>(Field(v_parent, 0));
    }
    QGridLayout* gl = new QGridLayout(parent);
    CAMLreturn(alloc_qobject(gl, !has_parent));
}

CAMLprim value caml_oqt6_qgridlayout_add_widget(value v_gl, value v_row, value v_col, value v_row_span, value v_col_span, value v_w) {
    CAMLparam5(v_gl, v_row, v_col, v_row_span, v_col_span);
    CAMLxparam1(v_w);
    QGridLayout* gl = get_qobject<QGridLayout>(v_gl);
    QWidget* w = get_qobject<QWidget>(v_w);
    int row = Int_val(v_row);
    int col = Int_val(v_col);
    int row_span = Is_block(v_row_span) ? Int_val(Field(v_row_span, 0)) : 1;
    int col_span = Is_block(v_col_span) ? Int_val(Field(v_col_span, 0)) : 1;
    gl->addWidget(w, row, col, row_span, col_span);
    mark_parented(v_w);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qgridlayout_add_widget_byte(value * argv, int argn) {
    (void)argn;
    return caml_oqt6_qgridlayout_add_widget(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}

CAMLprim value caml_oqt6_qgridlayout_add_layout(value v_gl, value v_row, value v_col, value v_row_span, value v_col_span, value v_sub) {
    CAMLparam5(v_gl, v_row, v_col, v_row_span, v_col_span);
    CAMLxparam1(v_sub);
    QGridLayout* gl = get_qobject<QGridLayout>(v_gl);
    QLayout* sub = get_qobject<QLayout>(v_sub);
    int row = Int_val(v_row);
    int col = Int_val(v_col);
    int row_span = Is_block(v_row_span) ? Int_val(Field(v_row_span, 0)) : 1;
    int col_span = Is_block(v_col_span) ? Int_val(Field(v_col_span, 0)) : 1;
    gl->addLayout(sub, row, col, row_span, col_span);
    mark_parented(v_sub);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qgridlayout_add_layout_byte(value * argv, int argn) {
    (void)argn;
    return caml_oqt6_qgridlayout_add_layout(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}

CAMLprim value caml_oqt6_qgridlayout_set_row_stretch(value v_gl, value v_row, value v_stretch) {
    CAMLparam3(v_gl, v_row, v_stretch);
    QGridLayout* gl = get_qobject<QGridLayout>(v_gl);
    gl->setRowStretch(Int_val(v_row), Int_val(v_stretch));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qgridlayout_set_column_stretch(value v_gl, value v_col, value v_stretch) {
    CAMLparam3(v_gl, v_col, v_stretch);
    QGridLayout* gl = get_qobject<QGridLayout>(v_gl);
    gl->setColumnStretch(Int_val(v_col), Int_val(v_stretch));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qgridlayout_set_spacing(value v_gl, value v_spacing) {
    CAMLparam2(v_gl, v_spacing);
    QGridLayout* gl = get_qobject<QGridLayout>(v_gl);
    gl->setSpacing(Int_val(v_spacing));
    CAMLreturn(Val_unit);
}

/* QMainWindow primitives */

CAMLprim value caml_oqt6_qmainwindow_create(value v_parent) {
    CAMLparam1(v_parent);
    QWidget* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QWidget>(Field(v_parent, 0));
    }
    QMainWindow* mw = new QMainWindow(parent);
    CAMLreturn(alloc_qobject(mw, !has_parent));
}

CAMLprim value caml_oqt6_qmainwindow_set_central_widget(value v_mw, value v_w) {
    CAMLparam2(v_mw, v_w);
    QMainWindow* mw = get_qobject<QMainWindow>(v_mw);
    QWidget* w = get_qobject<QWidget>(v_w);
    mw->setCentralWidget(w);
    mark_parented(v_w);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qmainwindow_central_widget(value v_mw) {
    CAMLparam1(v_mw);
    QMainWindow* mw = get_qobject<QMainWindow>(v_mw);
    QWidget* w = mw->centralWidget();
    if (!w) {
        CAMLreturn(Val_int(0)); // None
    }
    CAMLlocal2(v_w, some);
    v_w = alloc_qobject(w, false);
    some = caml_alloc_some(v_w);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qmainwindow_menu_bar(value v_mw) {
    CAMLparam1(v_mw);
    QMainWindow* mw = get_qobject<QMainWindow>(v_mw);
    QMenuBar* mb = mw->menuBar();
    CAMLreturn(alloc_qobject(mb, false));
}

CAMLprim value caml_oqt6_qmainwindow_status_bar(value v_mw) {
    CAMLparam1(v_mw);
    QMainWindow* mw = get_qobject<QMainWindow>(v_mw);
    QStatusBar* sb = mw->statusBar();
    CAMLreturn(alloc_qobject(sb, false));
}

CAMLprim value caml_oqt6_qmainwindow_set_status_bar(value v_mw, value v_sb) {
    CAMLparam2(v_mw, v_sb);
    QMainWindow* mw = get_qobject<QMainWindow>(v_mw);
    QStatusBar* sb = get_qobject<QStatusBar>(v_sb);
    mw->setStatusBar(sb);
    mark_parented(v_sb);
    CAMLreturn(Val_unit);
}

/* QMenuBar primitives */

CAMLprim value caml_oqt6_qmenubar_add_menu(value v_mb, value v_title) {
    CAMLparam2(v_mb, v_title);
    QMenuBar* mb = get_qobject<QMenuBar>(v_mb);
    QMenu* menu = mb->addMenu(QString::fromUtf8(String_val(v_title)));
    CAMLreturn(alloc_qobject(menu, false));
}

CAMLprim value caml_oqt6_qmenubar_add_action(value v_mb, value v_act) {
    CAMLparam2(v_mb, v_act);
    QMenuBar* mb = get_qobject<QMenuBar>(v_mb);
    QAction* act = get_qobject<QAction>(v_act);
    mb->addAction(act);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qmenubar_clear(value v_mb) {
    CAMLparam1(v_mb);
    QMenuBar* mb = get_qobject<QMenuBar>(v_mb);
    mb->clear();
    CAMLreturn(Val_unit);
}

/* QMenu primitives */

CAMLprim value caml_oqt6_qmenu_add_action(value v_menu, value v_act) {
    CAMLparam2(v_menu, v_act);
    QMenu* menu = get_qobject<QMenu>(v_menu);
    QAction* act = get_qobject<QAction>(v_act);
    menu->addAction(act);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qmenu_add_menu(value v_menu, value v_sub) {
    CAMLparam2(v_menu, v_sub);
    QMenu* menu = get_qobject<QMenu>(v_menu);
    QMenu* sub = get_qobject<QMenu>(v_sub);
    menu->addMenu(sub);
    mark_parented(v_sub);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qmenu_add_action_text(value v_menu, value v_text) {
    CAMLparam2(v_menu, v_text);
    QMenu* menu = get_qobject<QMenu>(v_menu);
    QAction* act = menu->addAction(QString::fromUtf8(String_val(v_text)));
    CAMLreturn(alloc_qobject(act, false));
}

CAMLprim value caml_oqt6_qmenu_add_separator(value v_menu) {
    CAMLparam1(v_menu);
    QMenu* menu = get_qobject<QMenu>(v_menu);
    menu->addSeparator();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qmenu_clear(value v_menu) {
    CAMLparam1(v_menu);
    QMenu* menu = get_qobject<QMenu>(v_menu);
    menu->clear();
    CAMLreturn(Val_unit);
}

/* QAction primitives */

CAMLprim value caml_oqt6_qaction_create(value v_text, value v_parent) {
    CAMLparam2(v_text, v_parent);
    QObject* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QObject>(Field(v_parent, 0));
    }
    QAction* act = new QAction(parent);
    if (Is_block(v_text)) {
        act->setText(QString::fromUtf8(String_val(Field(v_text, 0))));
    }
    CAMLreturn(alloc_qobject(act, !has_parent));
}

CAMLprim value caml_oqt6_qaction_set_text(value v_act, value v_text) {
    CAMLparam2(v_act, v_text);
    QAction* act = get_qobject<QAction>(v_act);
    act->setText(QString::fromUtf8(String_val(v_text)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qaction_text(value v_act) {
    CAMLparam1(v_act);
    QAction* act = get_qobject<QAction>(v_act);
    QByteArray utf8 = act->text().toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

CAMLprim value caml_oqt6_qaction_set_checkable(value v_act, value v_b) {
    CAMLparam2(v_act, v_b);
    QAction* act = get_qobject<QAction>(v_act);
    act->setCheckable(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qaction_is_checkable(value v_act) {
    CAMLparam1(v_act);
    QAction* act = get_qobject<QAction>(v_act);
    CAMLreturn(Val_bool(act->isCheckable()));
}

CAMLprim value caml_oqt6_qaction_set_checked(value v_act, value v_b) {
    CAMLparam2(v_act, v_b);
    QAction* act = get_qobject<QAction>(v_act);
    act->setChecked(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qaction_is_checked(value v_act) {
    CAMLparam1(v_act);
    QAction* act = get_qobject<QAction>(v_act);
    CAMLreturn(Val_bool(act->isChecked()));
}

CAMLprim value caml_oqt6_qaction_set_enabled(value v_act, value v_b) {
    CAMLparam2(v_act, v_b);
    QAction* act = get_qobject<QAction>(v_act);
    act->setEnabled(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qaction_is_enabled(value v_act) {
    CAMLparam1(v_act);
    QAction* act = get_qobject<QAction>(v_act);
    CAMLreturn(Val_bool(act->isEnabled()));
}

CAMLprim value caml_oqt6_qaction_set_shortcut(value v_act, value v_sc) {
    CAMLparam2(v_act, v_sc);
    QAction* act = get_qobject<QAction>(v_act);
    act->setShortcut(QKeySequence(QString::fromUtf8(String_val(v_sc))));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qaction_connect_triggered(value v_act, value v_fn) {
    CAMLparam2(v_act, v_fn);
    QAction* act = get_qobject<QAction>(v_act);
    value* root = new value;
    *root = v_fn;
    caml_register_global_root(root);

    QObject::connect(act, &QAction::triggered, [root](bool checked) {
        CamlDomainLockGuard guard;
        value res = caml_callback_exn(*root, Val_bool(checked));
        handle_callback_result(res);
    });
    connect_root_cleanup(act, root);

    CAMLreturn(Val_unit);
}

/* QStatusBar primitives */

CAMLprim value caml_oqt6_qstatusbar_show_message(value v_sb, value v_timeout, value v_msg) {
    CAMLparam3(v_sb, v_timeout, v_msg);
    QStatusBar* sb = get_qobject<QStatusBar>(v_sb);
    int timeout = Is_block(v_timeout) ? Int_val(Field(v_timeout, 0)) : 0;
    sb->showMessage(QString::fromUtf8(String_val(v_msg)), timeout);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qstatusbar_clear_message(value v_sb) {
    CAMLparam1(v_sb);
    QStatusBar* sb = get_qobject<QStatusBar>(v_sb);
    sb->clearMessage();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qstatusbar_current_message(value v_sb) {
    CAMLparam1(v_sb);
    QStatusBar* sb = get_qobject<QStatusBar>(v_sb);
    QByteArray utf8 = sb->currentMessage().toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

/* QDialog primitives */

CAMLprim value caml_oqt6_qdialog_create(value v_parent) {
    CAMLparam1(v_parent);
    QWidget* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QWidget>(Field(v_parent, 0));
    }
    QDialog* dlg = new QDialog(parent);
    CAMLreturn(alloc_qobject(dlg, !has_parent));
}

CAMLprim value caml_oqt6_qdialog_exec(value v_dlg) {
    CAMLparam1(v_dlg);
    QDialog* dlg = get_qobject<QDialog>(v_dlg);
    int ret;
    {
        CamlBlockingSection blocking_section;
        ret = dlg->exec();
    }
    /* QDialog::DialogCode: 1 = Accepted, 0 = Rejected (also returned when the
       dialog is deleted while running). Expose a closed 0/1/2 encoding rather
       than Qt's enum so OCaml does not depend on Qt's numbering. */
    CAMLreturn(Val_int(ret == QDialog::Accepted ? 1 : 2));
}

CAMLprim value caml_oqt6_qdialog_accept(value v_dlg) {
    CAMLparam1(v_dlg);
    QDialog* dlg = get_qobject<QDialog>(v_dlg);
    dlg->accept();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qdialog_reject(value v_dlg) {
    CAMLparam1(v_dlg);
    QDialog* dlg = get_qobject<QDialog>(v_dlg);
    dlg->reject();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qdialog_set_modal(value v_dlg, value v_m) {
    CAMLparam2(v_dlg, v_m);
    QDialog* dlg = get_qobject<QDialog>(v_dlg);
    dlg->setModal(Bool_val(v_m));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qdialog_is_modal(value v_dlg) {
    CAMLparam1(v_dlg);
    QDialog* dlg = get_qobject<QDialog>(v_dlg);
    CAMLreturn(Val_bool(dlg->isModal()));
}

/* QMessageBox primitives */

/* Button-set and answer codes shared with the OCaml layer. Kept as small ints
   so the OCaml side owns the variant mapping. */
static QMessageBox::StandardButtons messagebox_buttons_from_int(int code) {
    switch (code) {
    case 2: return QMessageBox::Ok | QMessageBox::Cancel;
    case 3: return QMessageBox::Yes | QMessageBox::No;
    case 4: return QMessageBox::Yes | QMessageBox::No | QMessageBox::Cancel;
    case 5: return QMessageBox::Save | QMessageBox::Discard | QMessageBox::Cancel;
    case 6: return QMessageBox::Abort | QMessageBox::Retry | QMessageBox::Ignore;
    case 7: return QMessageBox::Ok | QMessageBox::Apply | QMessageBox::Cancel;
    case 8: return QMessageBox::Save | QMessageBox::Apply | QMessageBox::Cancel;
    default: return QMessageBox::Ok;
    }
}

/* Returns 0 when the dialog was dismissed with no button (window closed). */
static int messagebox_answer_to_int(QMessageBox::StandardButton b) {
    if (b == QMessageBox::Ok)      return 1;
    if (b == QMessageBox::Cancel)  return 2;
    if (b == QMessageBox::Yes)     return 3;
    if (b == QMessageBox::No)      return 4;
    if (b == QMessageBox::Save)    return 5;
    if (b == QMessageBox::Discard) return 6;
    if (b == QMessageBox::Apply)   return 7;
    if (b == QMessageBox::Reset)   return 8;
    if (b == QMessageBox::Abort)   return 9;
    if (b == QMessageBox::Retry)   return 10;
    if (b == QMessageBox::Ignore)  return 11;
    if (b == QMessageBox::Help)    return 12;
    return 0;
}

static inline int opt_int(value v, int fallback) {
    return Is_block(v) ? Int_val(Field(v, 0)) : fallback;
}

static value messagebox_show(
    value v_parent, value v_title, value v_text, value v_buttons,
    QMessageBox::Icon icon, bool destructive_default)
{
    CAMLparam4(v_parent, v_title, v_text, v_buttons);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QString title = QString::fromUtf8(String_val(v_title), caml_string_length(v_title));
    QString text = QString::fromUtf8(String_val(v_text), caml_string_length(v_text));
    QMessageBox::StandardButtons buttons =
        messagebox_buttons_from_int(opt_int(v_buttons, 1));

    QMessageBox::StandardButton pressed = QMessageBox::NoButton;
    {
        CamlBlockingSection blocking_section;
        QMessageBox box(icon, title, text, buttons, parent);
        /* No default button: the user must make an explicit choice rather than
           dismissing the dialog with Return and accepting an implicit answer. */
        box.setDefaultButton(QMessageBox::NoButton);
        if (destructive_default) box.setEscapeButton(QMessageBox::Cancel);
        pressed = static_cast<QMessageBox::StandardButton>(box.exec());
    }
    CAMLreturn(Val_int(messagebox_answer_to_int(pressed)));
}

/* messagebox_show owns its own CAML frame, so these forwarders must not wrap it
   in CAMLreturn (that would emit a CAMLdrop with no frame in scope). */
CAMLprim value caml_oqt6_qmessagebox_information(value v_parent, value v_title, value v_text, value v_buttons) {
    return messagebox_show(v_parent, v_title, v_text, v_buttons, QMessageBox::Information, false);
}

CAMLprim value caml_oqt6_qmessagebox_warning(value v_parent, value v_title, value v_text, value v_buttons) {
    return messagebox_show(v_parent, v_title, v_text, v_buttons, QMessageBox::Warning, true);
}

CAMLprim value caml_oqt6_qmessagebox_critical(value v_parent, value v_title, value v_text, value v_buttons) {
    return messagebox_show(v_parent, v_title, v_text, v_buttons, QMessageBox::Critical, true);
}

CAMLprim value caml_oqt6_qmessagebox_question(value v_parent, value v_title, value v_text, value v_buttons) {
    return messagebox_show(v_parent, v_title, v_text, v_buttons, QMessageBox::Question, true);
}


/* QFileDialog primitives */

CAMLprim value caml_oqt6_qfiledialog_get_open_file_name(value v_parent, value v_caption, value v_dir, value v_filter) {
    CAMLparam4(v_parent, v_caption, v_dir, v_filter);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QString caption = Is_block(v_caption) ? QString::fromUtf8(String_val(Field(v_caption, 0))) : QString();
    QString dir = Is_block(v_dir) ? QString::fromUtf8(String_val(Field(v_dir, 0))) : QString();
    QString filter = Is_block(v_filter) ? QString::fromUtf8(String_val(Field(v_filter, 0))) : QString();

    QString result;
    {
        CamlBlockingSection blocking_section;
        result = QFileDialog::getOpenFileName(parent, caption, dir, filter);
    }

    if (result.isEmpty()) {
        CAMLreturn(Val_int(0)); // None
    }
    CAMLlocal2(v_str, some);
    QByteArray utf8 = result.toUtf8();
    v_str = caml_copy_string(utf8.constData());
    some = caml_alloc_some(v_str);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qfiledialog_get_save_file_name(value v_parent, value v_caption, value v_dir, value v_filter) {
    CAMLparam4(v_parent, v_caption, v_dir, v_filter);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QString caption = Is_block(v_caption) ? QString::fromUtf8(String_val(Field(v_caption, 0))) : QString();
    QString dir = Is_block(v_dir) ? QString::fromUtf8(String_val(Field(v_dir, 0))) : QString();
    QString filter = Is_block(v_filter) ? QString::fromUtf8(String_val(Field(v_filter, 0))) : QString();

    QString result;
    {
        CamlBlockingSection blocking_section;
        result = QFileDialog::getSaveFileName(parent, caption, dir, filter);
    }

    if (result.isEmpty()) {
        CAMLreturn(Val_int(0)); // None
    }
    CAMLlocal2(v_str, some);
    QByteArray utf8 = result.toUtf8();
    v_str = caml_copy_string(utf8.constData());
    some = caml_alloc_some(v_str);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qfiledialog_get_existing_directory(value v_parent, value v_caption, value v_dir) {
    CAMLparam3(v_parent, v_caption, v_dir);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QString caption = Is_block(v_caption) ? QString::fromUtf8(String_val(Field(v_caption, 0))) : QString();
    QString dir = Is_block(v_dir) ? QString::fromUtf8(String_val(Field(v_dir, 0))) : QString();

    QString result;
    {
        CamlBlockingSection blocking_section;
        result = QFileDialog::getExistingDirectory(parent, caption, dir);
    }

    if (result.isEmpty()) {
        CAMLreturn(Val_int(0)); // None
    }
    CAMLlocal2(v_str, some);
    QByteArray utf8 = result.toUtf8();
    v_str = caml_copy_string(utf8.constData());
    some = caml_alloc_some(v_str);
    CAMLreturn(some);
}

/* QColor primitives */

CAMLprim value caml_oqt6_qcolor_rgb(value v_r, value v_g, value v_b, value v_a) {
    CAMLparam4(v_r, v_g, v_b, v_a);
    int r = Int_val(v_r);
    int g = Int_val(v_g);
    int b = Int_val(v_b);
    int a = Is_block(v_a) ? Int_val(Field(v_a, 0)) : 255;
    CAMLreturn(alloc_color(QColor(r, g, b, a)));
}

CAMLprim value caml_oqt6_qcolor_name(value v_name) {
    CAMLparam1(v_name);
    CAMLreturn(alloc_color(QColor(QString::fromUtf8(String_val(v_name)))));
}

CAMLprim value caml_oqt6_qcolor_red(value v_c) {
    CAMLparam1(v_c);
    CAMLreturn(Val_int(QColor_val(v_c).red()));
}

CAMLprim value caml_oqt6_qcolor_green(value v_c) {
    CAMLparam1(v_c);
    CAMLreturn(Val_int(QColor_val(v_c).green()));
}

CAMLprim value caml_oqt6_qcolor_blue(value v_c) {
    CAMLparam1(v_c);
    CAMLreturn(Val_int(QColor_val(v_c).blue()));
}

CAMLprim value caml_oqt6_qcolor_alpha(value v_c) {
    CAMLparam1(v_c);
    CAMLreturn(Val_int(QColor_val(v_c).alpha()));
}

/* An unparsable name must not yield a plausible-looking invalid colour. */
CAMLprim value caml_oqt6_qcolor_name_checked(value v_name) {
    CAMLparam1(v_name);
    QString s = QString::fromUtf8(String_val(v_name));
    QColor c(s);
    if (!c.isValid()) {
        caml_invalid_argument("CamlQt6.Color.name: unrecognised colour name");
    }
    CAMLreturn(alloc_color(c));
}

CAMLprim value caml_oqt6_qcolor_to_hex(value v_c) {
    CAMLparam1(v_c);
    QByteArray hex = QColor_val(v_c).name(QColor::HexArgb).toUtf8();
    CAMLreturn(caml_alloc_initialized_string((mlsize_t)hex.size(), hex.constData()));
}

CAMLprim value caml_oqt6_qcolor_lighter(value v_c, value v_factor) {
    CAMLparam2(v_c, v_factor);
    int f = Int_val(v_factor);
    QColor out = QColor_val(v_c).lighter(f);
    if (f <= 0) out = QColor_val(v_c).darker(-f);
    CAMLreturn(alloc_color(out));
}

CAMLprim value caml_oqt6_qcolor_darker(value v_c, value v_factor) {
    CAMLparam2(v_c, v_factor);
    CAMLreturn(alloc_color(QColor_val(v_c).darker(Int_val(v_factor))));
}

CAMLprim value caml_oqt6_qcolor_hsv(value v_c) {
    CAMLparam1(v_c);
    int h, s, vv;
    QColor_val(v_c).getHsv(&h, &s, &vv);
    CAMLlocal1(v_triple);
    v_triple = caml_alloc_tuple(3);
    Store_field(v_triple, 0, Val_int(h));
    Store_field(v_triple, 1, Val_int(s));
    Store_field(v_triple, 2, Val_int(vv));
    CAMLreturn(v_triple);
}

CAMLprim value caml_oqt6_qcolor_hsl(value v_c) {
    CAMLparam1(v_c);
    int h, s, l;
    QColor_val(v_c).getHsl(&h, &s, &l);
    CAMLlocal1(v_triple);
    v_triple = caml_alloc_tuple(3);
    Store_field(v_triple, 0, Val_int(h));
    Store_field(v_triple, 1, Val_int(s));
    Store_field(v_triple, 2, Val_int(l));
    CAMLreturn(v_triple);
}

CAMLprim value caml_oqt6_qcolor_from_hsv(value v_h, value v_s, value v_v) {
    CAMLparam3(v_h, v_s, v_v);
    CAMLreturn(alloc_color(QColor::fromHsv(Int_val(v_h), Int_val(v_s), Int_val(v_v))));
}

CAMLprim value caml_oqt6_qcolor_from_hsl(value v_h, value v_s, value v_l) {
    CAMLparam3(v_h, v_s, v_l);
    CAMLreturn(alloc_color(QColor::fromHsl(Int_val(v_h), Int_val(v_s), Int_val(v_l))));
}

CAMLprim value caml_oqt6_qcolor_is_valid(value v_c) {
    CAMLparam1(v_c);
    CAMLreturn(Val_bool(QColor_val(v_c).isValid()));
}

/* QFont primitives */

CAMLprim value caml_oqt6_qfont_create(value v_family, value v_size, value v_bold, value v_italic) {
    CAMLparam4(v_family, v_size, v_bold, v_italic);
    QFont font;
    if (Is_block(v_family)) {
        font.setFamily(QString::fromUtf8(String_val(Field(v_family, 0))));
    }
    if (Is_block(v_size)) {
        font.setPointSize(Int_val(Field(v_size, 0)));
    }
    if (Is_block(v_bold)) {
        font.setBold(Bool_val(Field(v_bold, 0)));
    }
    if (Is_block(v_italic)) {
        font.setItalic(Bool_val(Field(v_italic, 0)));
    }
    CAMLreturn(alloc_font(font));
}

CAMLprim value caml_oqt6_qfont_family(value v_f) {
    CAMLparam1(v_f);
    QByteArray utf8 = Font_val(v_f).family().toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

CAMLprim value caml_oqt6_qfont_set_family(value v_f, value v_name) {
    CAMLparam2(v_f, v_name);
    Font_val(v_f).setFamily(QString::fromUtf8(String_val(v_name)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qfont_point_size(value v_f) {
    CAMLparam1(v_f);
    CAMLreturn(Val_int(Font_val(v_f).pointSize()));
}

CAMLprim value caml_oqt6_qfont_bold(value v_f) {
    CAMLparam1(v_f);
    CAMLreturn(Val_bool(Font_val(v_f).bold()));
}

CAMLprim value caml_oqt6_qfont_italic(value v_f) {
    CAMLparam1(v_f);
    CAMLreturn(Val_bool(Font_val(v_f).italic()));
}

CAMLprim value caml_oqt6_qfont_set_point_size(value v_f, value v_s) {
    CAMLparam2(v_f, v_s);
    Font_val(v_f).setPointSize(Int_val(v_s));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qfont_set_bold(value v_f, value v_b) {
    CAMLparam2(v_f, v_b);
    Font_val(v_f).setBold(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qfont_set_italic(value v_f, value v_b) {
    CAMLparam2(v_f, v_b);
    Font_val(v_f).setItalic(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qfont_weight(value v_f) {
    CAMLparam1(v_f);
    CAMLreturn(Val_int((int)Font_val(v_f).weight()));
}

CAMLprim value caml_oqt6_qfont_set_weight(value v_f, value v_w) {
    CAMLparam2(v_f, v_w);
    Font_val(v_f).setWeight((QFont::Weight)Int_val(v_w));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qfont_underline(value v_f) {
    CAMLparam1(v_f);
    CAMLreturn(Val_bool(Font_val(v_f).underline()));
}

CAMLprim value caml_oqt6_qfont_set_underline(value v_f, value v_b) {
    CAMLparam2(v_f, v_b);
    Font_val(v_f).setUnderline(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qfont_strikeout(value v_f) {
    CAMLparam1(v_f);
    CAMLreturn(Val_bool(Font_val(v_f).strikeOut()));
}

CAMLprim value caml_oqt6_qfont_set_strikeout(value v_f, value v_b) {
    CAMLparam2(v_f, v_b);
    Font_val(v_f).setStrikeOut(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qfont_point_size_f(value v_f) {
    CAMLparam1(v_f);
    CAMLreturn(caml_copy_double(Font_val(v_f).pointSizeF()));
}

CAMLprim value caml_oqt6_qfont_set_letter_spacing(value v_f, value v_spacing) {
    CAMLparam2(v_f, v_spacing);
    Font_val(v_f).setLetterSpacing(QFont::AbsoluteSpacing, Double_val(v_spacing));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qfont_letter_spacing(value v_f) {
    CAMLparam1(v_f);
    CAMLreturn(caml_copy_double(Font_val(v_f).letterSpacing()));
}

/* QPen primitives */

/* QPen primitives */

/* CamlQt6 uses its own small integer encodings for enums so the OCaml side owns
   the variant mapping; these helpers are the single place they are translated. */
static Qt::PenStyle pen_style_from_int(int code) {
    switch (code) {
    case 1: return Qt::DashLine;
    case 2: return Qt::DotLine;
    case 3: return Qt::NoPen;
    case 4: return Qt::DashDotLine;
    case 5: return Qt::DashDotDotLine;
    default: return Qt::SolidLine;
    }
}

static int pen_style_to_int(Qt::PenStyle s) {
    switch (s) {
    case Qt::DashLine: return 1;
    case Qt::DotLine: return 2;
    case Qt::NoPen: return 3;
    case Qt::DashDotLine: return 4;
    case Qt::DashDotDotLine: return 5;
    default: return 0;
    }
}

static Qt::BrushStyle brush_style_from_int(int code) {
    switch (code) {
    case 1: return Qt::NoBrush;
    case 2: return Qt::Dense5Pattern;
    case 3: return Qt::Dense7Pattern;
    case 4: return Qt::CrossPattern;
    case 5: return Qt::VerPattern;
    case 6: return Qt::HorPattern;
    default: return Qt::SolidPattern;
    }
}

static int brush_style_to_int(Qt::BrushStyle s) {
    switch (s) {
    case Qt::NoBrush: return 1;
    case Qt::Dense5Pattern: return 2;
    case Qt::Dense7Pattern: return 3;
    case Qt::CrossPattern: return 4;
    case Qt::VerPattern: return 5;
    case Qt::HorPattern: return 6;
    default: return 0;
    }
}

static Qt::PenCapStyle cap_style_from_int(int code) {
    switch (code) {
    case 1: return Qt::FlatCap;
    case 2: return Qt::SquareCap;
    default: return Qt::RoundCap;
    }
}

static int cap_style_to_int(Qt::PenCapStyle s) {
    switch (s) {
    case Qt::FlatCap: return 1;
    case Qt::SquareCap: return 2;
    default: return 0;
    }
}

static Qt::PenJoinStyle join_style_from_int(int code) {
    switch (code) {
    case 1: return Qt::BevelJoin;
    case 2: return Qt::MiterJoin;
    default: return Qt::RoundJoin;
    }
}

static int join_style_to_int(Qt::PenJoinStyle s) {
    switch (s) {
    case Qt::BevelJoin: return 1;
    case Qt::MiterJoin: return 2;
    default: return 0;
    }
}

CAMLprim value caml_oqt6_qpen_create(value v_color, value v_width, value v_style) {
    CAMLparam3(v_color, v_width, v_style);
    QPen pen;
    if (Is_block(v_color)) {
        pen.setColor(QColor_val(Field(v_color, 0)));
    }
    if (Is_block(v_width)) {
        pen.setWidth(Int_val(Field(v_width, 0)));
    }
    if (Is_block(v_style)) {
        pen.setStyle(pen_style_from_int(Int_val(Field(v_style, 0))));
    }
    CAMLreturn(alloc_pen(pen));
}

CAMLprim value caml_oqt6_qpen_set_color(value v_p, value v_c) {
    CAMLparam2(v_p, v_c);
    Pen_val(v_p).setColor(QColor_val(v_c));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpen_set_width(value v_p, value v_w) {
    CAMLparam2(v_p, v_w);
    Pen_val(v_p).setWidth(Int_val(v_w));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpen_set_style(value v_p, value v_style) {
    CAMLparam2(v_p, v_style);
    Pen_val(v_p).setStyle(pen_style_from_int(Int_val(v_style)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpen_style(value v_p) {
    CAMLparam1(v_p);
    CAMLreturn(Val_int(pen_style_to_int(Pen_val(v_p).style())));
}

CAMLprim value caml_oqt6_qpen_color(value v_p) {
    CAMLparam1(v_p);
    CAMLreturn(alloc_color(Pen_val(v_p).color()));
}

CAMLprim value caml_oqt6_qpen_width(value v_p) {
    CAMLparam1(v_p);
    CAMLreturn(Val_int(Pen_val(v_p).width()));
}

CAMLprim value caml_oqt6_qpen_set_cap_style(value v_p, value v_style) {
    CAMLparam2(v_p, v_style);
    Pen_val(v_p).setCapStyle(cap_style_from_int(Int_val(v_style)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpen_cap_style(value v_p) {
    CAMLparam1(v_p);
    CAMLreturn(Val_int(cap_style_to_int(Pen_val(v_p).capStyle())));
}

CAMLprim value caml_oqt6_qpen_set_join_style(value v_p, value v_style) {
    CAMLparam2(v_p, v_style);
    Pen_val(v_p).setJoinStyle(join_style_from_int(Int_val(v_style)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpen_join_style(value v_p) {
    CAMLparam1(v_p);
    CAMLreturn(Val_int(join_style_to_int(Pen_val(v_p).joinStyle())));
}

CAMLprim value caml_oqt6_qpen_set_dash_pattern(value v_p, value v_pattern) {
    CAMLparam2(v_p, v_pattern);
    QList<qreal> dashes;
    CAMLlocal2(cur, head);
    head = v_pattern;
    while (Is_block(head) && Tag_val(head) == 0) {
        cur = Field(head, 0);
        dashes.append(Double_val(cur));
        head = Field(head, 1);
    }
    Pen_val(v_p).setDashPattern(dashes);
    CAMLreturn(Val_unit);
}

/* QBrush primitives */

CAMLprim value caml_oqt6_qbrush_create(value v_color, value v_style) {
    CAMLparam2(v_color, v_style);
    QBrush brush;
    if (Is_block(v_color)) {
        brush.setColor(QColor_val(Field(v_color, 0)));
        brush.setStyle(Qt::SolidPattern);
    }
    if (Is_block(v_style)) {
        int s = Int_val(Field(v_style, 0));
        brush.setStyle(brush_style_from_int(s));
    }
    CAMLreturn(alloc_brush(brush));
}

CAMLprim value caml_oqt6_qbrush_set_color(value v_b, value v_c) {
    CAMLparam2(v_b, v_c);
    Brush_val(v_b).setColor(QColor_val(v_c));
    Brush_val(v_b).setStyle(Qt::SolidPattern);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qbrush_set_style(value v_b, value v_s) {
    CAMLparam2(v_b, v_s);
    Brush_val(v_b).setStyle(brush_style_from_int(Int_val(v_s)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qbrush_style(value v_b) {
    CAMLparam1(v_b);
    CAMLreturn(Val_int(brush_style_to_int(Brush_val(v_b).style())));
}

CAMLprim value caml_oqt6_qbrush_color(value v_b) {
    CAMLparam1(v_b);
    CAMLreturn(alloc_color(Brush_val(v_b).color()));
}

/* QPainter primitives */

CAMLprim value caml_oqt6_qpainter_set_pen(value v_p, value v_pen) {
    CAMLparam2(v_p, v_pen);
    get_painter(v_p)->setPen(Pen_val(v_pen));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpainter_set_brush(value v_p, value v_brush) {
    CAMLparam2(v_p, v_brush);
    get_painter(v_p)->setBrush(Brush_val(v_brush));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpainter_set_font(value v_p, value v_font) {
    CAMLparam2(v_p, v_font);
    get_painter(v_p)->setFont(Font_val(v_font));
    CAMLreturn(Val_unit);
}

static QPainter::RenderHint render_hint_from_int(int code) {
    switch (code) {
    case 1: return QPainter::TextAntialiasing;
    case 2: return QPainter::SmoothPixmapTransform;
    default: return QPainter::Antialiasing;
    }
}

CAMLprim value caml_oqt6_qpainter_set_render_hint(value v_p, value v_hint, value v_on) {
    CAMLparam3(v_p, v_hint, v_on);
    get_painter(v_p)->setRenderHint(render_hint_from_int(Int_val(v_hint)), Bool_val(v_on));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpainter_set_opacity(value v_p, value v_opacity) {
    CAMLparam2(v_p, v_opacity);
    get_painter(v_p)->setOpacity(Double_val(v_opacity));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpainter_draw_line(value v_p, value v_x1, value v_y1, value v_x2, value v_y2) {
    CAMLparam5(v_p, v_x1, v_y1, v_x2, v_y2);
    get_painter(v_p)->drawLine(Int_val(v_x1), Int_val(v_y1), Int_val(v_x2), Int_val(v_y2));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpainter_draw_rect(value v_p, value v_x, value v_y, value v_w, value v_h) {
    CAMLparam5(v_p, v_x, v_y, v_w, v_h);
    get_painter(v_p)->drawRect(Int_val(v_x), Int_val(v_y), Int_val(v_w), Int_val(v_h));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpainter_fill_rect(value v_p, value v_x, value v_y, value v_w, value v_h, value v_c) {
    CAMLparam5(v_p, v_x, v_y, v_w, v_h);
    CAMLxparam1(v_c);
    get_painter(v_p)->fillRect(Int_val(v_x), Int_val(v_y), Int_val(v_w), Int_val(v_h), QColor_val(v_c));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpainter_fill_rect_byte(value* argv, int argn) {
    (void)argn;
    return caml_oqt6_qpainter_fill_rect(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}

CAMLprim value caml_oqt6_qpainter_draw_rounded_rect(value v_p, value v_x, value v_y, value v_w, value v_h, value v_xr, value v_yr) {
    CAMLparam5(v_p, v_x, v_y, v_w, v_h);
    CAMLxparam2(v_xr, v_yr);
    get_painter(v_p)->drawRoundedRect(Int_val(v_x), Int_val(v_y), Int_val(v_w), Int_val(v_h), Double_val(v_xr), Double_val(v_yr));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpainter_draw_rounded_rect_byte(value* argv, int argn) {
    (void)argn;
    return caml_oqt6_qpainter_draw_rounded_rect(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6]);
}

CAMLprim value caml_oqt6_qpainter_draw_ellipse(value v_p, value v_x, value v_y, value v_w, value v_h) {
    CAMLparam5(v_p, v_x, v_y, v_w, v_h);
    get_painter(v_p)->drawEllipse(Int_val(v_x), Int_val(v_y), Int_val(v_w), Int_val(v_h));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpainter_draw_text(value v_p, value v_x, value v_y, value v_text) {
    CAMLparam4(v_p, v_x, v_y, v_text);
    get_painter(v_p)->drawText(Int_val(v_x), Int_val(v_y), QString::fromUtf8(String_val(v_text)));
    CAMLreturn(Val_unit);
}

/* int -> int -> int -> int -> int */
/* Walk an OCaml list of points into a QPolygonF.

   These helpers deliberately use no CAMLparam/CAMLlocal. They allocate only
   through Qt's allocator, never the OCaml heap, and a CAMLparam with no
   matching CAMLreturn/CAMLdrop leaves the local-roots frame unbalanced, which
   corrupts the caller's frame. The incoming values are already rooted by the
   caller's CAMLparamN. */
static void read_points_i(value v, QPolygon* out) {
    out->clear();
    value head = v;
    while (Is_block(head) && Tag_val(head) == 0) {
        value pair = Field(head, 0);
        if (Is_block(pair) && Wosize_val(pair) >= 2) {
            out->append(QPoint(Int_val(Field(pair, 0)), Int_val(Field(pair, 1))));
        }
        head = Field(head, 1);
    }
}

static void read_points_f(value v, QPolygonF* out) {
    out->clear();
    value head = v;
    while (Is_block(head) && Tag_val(head) == 0) {
        value pair = Field(head, 0);
        if (Is_block(pair) && Wosize_val(pair) >= 2) {
            out->append(QPointF(Double_val(Field(pair, 0)), Double_val(Field(pair, 1))));
        }
        head = Field(head, 1);
    }
}

CAMLprim value caml_oqt6_qpainter_draw_polyline(value v_p, value v_points) {
    CAMLparam2(v_p, v_points);
    QPolygonF poly;
    read_points_f(v_points, &poly);
    get_painter(v_p)->drawPolyline(poly);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpainter_draw_polygon(value v_p, value v_points) {
    CAMLparam2(v_p, v_points);
    QPolygonF poly;
    read_points_f(v_points, &poly);
    get_painter(v_p)->drawPolygon(poly);
    CAMLreturn(Val_unit);
}

/* rect (x, y, w, h) + start angle + span angle, all in 1/16th degree */
CAMLprim value caml_oqt6_qpainter_fill_rect_with_brush(value v_p, value v_x, value v_y,
                                                      value v_w, value v_h) {
    /* Fill using the current brush; Painter.fill_rect takes an explicit colour.
       Qt 6 has no fillRect(x, y, w, h) overload, so pass a QRectF plus the
       painter's current brush. */
    CAMLparam5(v_p, v_x, v_y, v_w, v_h);
    QPainter* p = get_painter(v_p);
    p->fillRect(
        QRectF(Int_val(v_x), Int_val(v_y), Int_val(v_w), Int_val(v_h)), p->brush());
    CAMLreturn(Val_unit);
}

/* rect (x, y, w, h) as a 4-tuple + start angle + span angle in degrees.
   Four OCaml arguments keeps this within the 5-argument limit for native stubs,
   and the degrees -> 1/16th-degree conversion lives here. */
static void draw_arc_or_pie(bool pie, value v_p, value v_rect,
                            value v_start_deg, value v_span_deg) {
    if (!Is_block(v_rect) || Wosize_val(v_rect) < 4) {
        caml_invalid_argument(
            pie ? "CamlQt6.Painter.draw_pie: expected (x, y, width, height)"
            : "CamlQt6.Painter.draw_arc: expected (x, y, width, height)");
    }
    int x = Int_val(Field(v_rect, 0)), y = Int_val(Field(v_rect, 1));
    int w = Int_val(Field(v_rect, 2)), h = Int_val(Field(v_rect, 3));
    int start = (int)(Double_val(v_start_deg) * 16.0);
    int span = (int)(Double_val(v_span_deg) * 16.0);
    QPainter* p = get_painter(v_p);
    if (pie) p->drawPie(x, y, w, h, start, span);
    else p->drawArc(x, y, w, h, start, span);
}

CAMLprim value caml_oqt6_qpainter_draw_arc(value v_p, value v_rect,
                                           value v_start_deg, value v_span_deg) {
    CAMLparam4(v_p, v_rect, v_start_deg, v_span_deg);
    draw_arc_or_pie(false, v_p, v_rect, v_start_deg, v_span_deg);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpainter_draw_pie(value v_p, value v_rect,
                                          value v_start_deg, value v_span_deg) {
    CAMLparam4(v_p, v_rect, v_start_deg, v_span_deg);
    draw_arc_or_pie(true, v_p, v_rect, v_start_deg, v_span_deg);
    CAMLreturn(Val_unit);
}

/* Returns the bounding box as (x, y, width, height).
   Qt 6 removed QPainter::boundingRect(QString), so this goes through
   QFontMetricsF with the painter's current font. */
CAMLprim value caml_oqt6_qpainter_bounding_rect(value v_p, value v_text) {
    CAMLparam2(v_p, v_text);
    QPainter* p = get_painter(v_p);
    QFontMetricsF fm(p->font());
    QRectF r = fm.boundingRect(QString::fromUtf8(String_val(v_text)));
    CAMLlocal1(v_pair);
    v_pair = caml_alloc_tuple(4);
    Store_field(v_pair, 0, Val_int((int)r.x()));
    Store_field(v_pair, 1, Val_int((int)r.y()));
    Store_field(v_pair, 2, Val_int((int)r.width()));
    Store_field(v_pair, 3, Val_int((int)r.height()));
    CAMLreturn(v_pair);
}

CAMLprim value caml_oqt6_qpainter_save(value v_p) {
    CAMLparam1(v_p);
    get_painter(v_p)->save();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpainter_restore(value v_p) {
    CAMLparam1(v_p);
    get_painter(v_p)->restore();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpainter_translate(value v_p, value v_dx, value v_dy) {
    CAMLparam3(v_p, v_dx, v_dy);
    get_painter(v_p)->translate(Double_val(v_dx), Double_val(v_dy));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpainter_scale(value v_p, value v_sx, value v_sy) {
    CAMLparam3(v_p, v_sx, v_sy);
    get_painter(v_p)->scale(Double_val(v_sx), Double_val(v_sy));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpainter_rotate(value v_p, value v_angle) {
    CAMLparam2(v_p, v_angle);
    get_painter(v_p)->rotate(Double_val(v_angle));
    CAMLreturn(Val_unit);
}

/* QCanvas primitives */

CAMLprim value caml_oqt6_qcanvas_create(value v_parent) {
    CAMLparam1(v_parent);
    QWidget* parent = nullptr;
    bool has_parent = Is_block(v_parent);
    if (has_parent) {
        parent = get_qobject<QWidget>(Field(v_parent, 0));
    }
    OCamlCanvas* c = new OCamlCanvas(parent);
    CAMLreturn(alloc_qobject(c, !has_parent));
}

CAMLprim value caml_oqt6_qcanvas_on_paint(value v_c, value v_cb) {
    CAMLparam2(v_c, v_cb);
    OCamlCanvas* c = get_qobject<OCamlCanvas>(v_c);
    if (!c->paint_cb) {
        c->paint_cb = new value;
        caml_register_global_root(c->paint_cb);
    }
    *c->paint_cb = v_cb;
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qcanvas_on_mouse_press(value v_c, value v_cb) {
    CAMLparam2(v_c, v_cb);
    OCamlCanvas* c = get_qobject<OCamlCanvas>(v_c);
    if (!c->mouse_press_cb) {
        c->mouse_press_cb = new value;
        caml_register_global_root(c->mouse_press_cb);
    }
    *c->mouse_press_cb = v_cb;
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qcanvas_on_mouse_release(value v_c, value v_cb) {
    CAMLparam2(v_c, v_cb);
    OCamlCanvas* c = get_qobject<OCamlCanvas>(v_c);
    if (!c->mouse_release_cb) {
        c->mouse_release_cb = new value;
        caml_register_global_root(c->mouse_release_cb);
    }
    *c->mouse_release_cb = v_cb;
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qcanvas_on_mouse_move(value v_c, value v_cb) {
    CAMLparam2(v_c, v_cb);
    OCamlCanvas* c = get_qobject<OCamlCanvas>(v_c);
    if (!c->mouse_move_cb) {
        c->mouse_move_cb = new value;
        caml_register_global_root(c->mouse_move_cb);
    }
    *c->mouse_move_cb = v_cb;
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qcanvas_on_key_press(value v_c, value v_cb) {
    CAMLparam2(v_c, v_cb);
    OCamlCanvas* c = get_qobject<OCamlCanvas>(v_c);
    if (!c->key_press_cb) {
        c->key_press_cb = new value;
        caml_register_global_root(c->key_press_cb);
    }
    *c->key_press_cb = v_cb;
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qcanvas_on_resize(value v_c, value v_cb) {
    CAMLparam2(v_c, v_cb);
    OCamlCanvas* c = get_qobject<OCamlCanvas>(v_c);
    if (!c->resize_cb) {
        c->resize_cb = new value;
        caml_register_global_root(c->resize_cb);
    }
    *c->resize_cb = v_cb;
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qcanvas_on_drag_enter(value v_c, value v_cb) {
    CAMLparam2(v_c, v_cb);
    OCamlCanvas* c = get_qobject<OCamlCanvas>(v_c);
    c->setAcceptDrops(true);
    if (!c->drag_enter_cb) {
        c->drag_enter_cb = new value;
        caml_register_global_root(c->drag_enter_cb);
    }
    *c->drag_enter_cb = v_cb;
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qcanvas_on_drag_move(value v_c, value v_cb) {
    CAMLparam2(v_c, v_cb);
    OCamlCanvas* c = get_qobject<OCamlCanvas>(v_c);
    c->setAcceptDrops(true);
    if (!c->drag_move_cb) {
        c->drag_move_cb = new value;
        caml_register_global_root(c->drag_move_cb);
    }
    *c->drag_move_cb = v_cb;
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qcanvas_on_drag_leave(value v_c, value v_cb) {
    CAMLparam2(v_c, v_cb);
    OCamlCanvas* c = get_qobject<OCamlCanvas>(v_c);
    c->setAcceptDrops(true);
    if (!c->drag_leave_cb) {
        c->drag_leave_cb = new value;
        caml_register_global_root(c->drag_leave_cb);
    }
    *c->drag_leave_cb = v_cb;
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qcanvas_on_drop(value v_c, value v_cb) {
    CAMLparam2(v_c, v_cb);
    OCamlCanvas* c = get_qobject<OCamlCanvas>(v_c);
    c->setAcceptDrops(true);
    if (!c->drop_cb) {
        c->drop_cb = new value;
        caml_register_global_root(c->drop_cb);
    }
    *c->drop_cb = v_cb;
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qwidget_update(value v_w) {
    CAMLparam1(v_w);
    QWidget* w = get_qobject<QWidget>(v_w);
    w->update();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qwidget_set_mouse_tracking(value v_w, value v_b) {
    CAMLparam2(v_w, v_b);
    QWidget* w = get_qobject<QWidget>(v_w);
    w->setMouseTracking(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

/* OCamlTableModel primitives */

CAMLprim value caml_oqt6_tablemodel_create(value v_parent) {
    CAMLparam1(v_parent);
    QObject* parent = Is_block(v_parent) ? get_qobject<QObject>(Field(v_parent, 0)) : nullptr;
    OCamlTableModel* m = new OCamlTableModel(parent);
    CAMLreturn(alloc_qobject(m, !Is_block(v_parent)));
}

/* The optional per-cell role callbacks all follow the same shape, so they share
   one setter. Each returns an option; [None] means "no opinion" and the view
   falls back to its own styling. */
static void set_opt_root(value** slot, value v) {
    if (Is_block(v)) set_root(slot, Field(v, 0));
}

CAMLprim value caml_oqt6_tablemodel_set_callbacks(value v_m, value v_rc, value v_cc, value v_data, value v_header) {
    CAMLparam5(v_m, v_rc, v_cc, v_data, v_header);
    OCamlTableModel* m = get_qobject<OCamlTableModel>(v_m);
    set_root(&m->row_count_cb, v_rc);
    set_root(&m->col_count_cb, v_cc);
    set_root(&m->data_cb, v_data);
    set_opt_root(&m->header_data_cb, v_header);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_tablemodel_set_sort(value v_m, value v_cb) {
    CAMLparam2(v_m, v_cb);
    OCamlTableModel* m = get_qobject<OCamlTableModel>(v_m);
    set_opt_root(&m->sort_cb, v_cb);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_tablemodel_set_foreground(value v_m, value v_cb) {
    CAMLparam2(v_m, v_cb);
    OCamlTableModel* m = get_qobject<OCamlTableModel>(v_m);
    set_opt_root(&m->foreground_cb, v_cb);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_tablemodel_set_background(value v_m, value v_cb) {
    CAMLparam2(v_m, v_cb);
    OCamlTableModel* m = get_qobject<OCamlTableModel>(v_m);
    set_opt_root(&m->background_cb, v_cb);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_tablemodel_set_alignment(value v_m, value v_cb) {
    CAMLparam2(v_m, v_cb);
    OCamlTableModel* m = get_qobject<OCamlTableModel>(v_m);
    set_opt_root(&m->alignment_cb, v_cb);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_tablemodel_set_decoration(value v_m, value v_cb) {
    CAMLparam2(v_m, v_cb);
    OCamlTableModel* m = get_qobject<OCamlTableModel>(v_m);
    set_opt_root(&m->decoration_cb, v_cb);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_tablemodel_set_tooltip(value v_m, value v_cb) {
    CAMLparam2(v_m, v_cb);
    OCamlTableModel* m = get_qobject<OCamlTableModel>(v_m);
    set_opt_root(&m->tooltip_cb, v_cb);
    CAMLreturn(Val_unit);
}

/* Trigger a sort from OCaml, e.g. after the underlying data changed. */
CAMLprim value caml_oqt6_tablemodel_sort(value v_m, value v_col, value v_desc) {
    CAMLparam3(v_m, v_col, v_desc);
    OCamlTableModel* m = get_qobject<OCamlTableModel>(v_m);
    m->sort(Int_val(v_col), Bool_val(v_desc) ? Qt::DescendingOrder : Qt::AscendingOrder);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_tablemodel_notify_reset(value v_m) {
    CAMLparam1(v_m);
    OCamlTableModel* m = get_qobject<OCamlTableModel>(v_m);
    m->notify_reset();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_tablemodel_notify_data_changed(value v_m, value v_tr, value v_lc, value v_br, value v_rc) {
    CAMLparam5(v_m, v_tr, v_lc, v_br, v_rc);
    OCamlTableModel* m = get_qobject<OCamlTableModel>(v_m);
    m->notify_data_changed(Int_val(v_tr), Int_val(v_lc), Int_val(v_br), Int_val(v_rc));
    CAMLreturn(Val_unit);
}

/* Read-only accessors that go through Qt's own dispatch (rowCount / data /
   headerData) rather than calling the OCaml closures directly. This is the same
   code path a view uses when painting, which makes the zero-copy contract
   observable and testable from OCaml instead of only from C++. */

static value qvariant_to_string_option(const QVariant& v) {
    CAMLparam0();
    /* OCamlTableModel only ever produces a QString QVariant or an invalid one,
       so validity is the only check needed (QVariant::type() is deprecated). */
    if (!v.isValid()) {
        CAMLreturn(Val_int(0));
    }
    QByteArray utf8 = v.toString().toUtf8();
    CAMLlocal2(v_str, some);
    v_str = caml_alloc_initialized_string((mlsize_t)utf8.size(), utf8.constData());
    some = caml_alloc_some(v_str);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_tablemodel_row_count(value v_m) {
    CAMLparam1(v_m);
    OCamlTableModel* m = get_qobject<OCamlTableModel>(v_m);
    int n;
    {
        CamlBlockingSection blocking_section;
        n = m->rowCount();
    }
    CAMLreturn(Val_int(n));
}

CAMLprim value caml_oqt6_tablemodel_column_count(value v_m) {
    CAMLparam1(v_m);
    OCamlTableModel* m = get_qobject<OCamlTableModel>(v_m);
    int n;
    {
        CamlBlockingSection blocking_section;
        n = m->columnCount();
    }
    CAMLreturn(Val_int(n));
}

CAMLprim value caml_oqt6_tablemodel_data(value v_m, value v_row, value v_col) {
    CAMLparam3(v_m, v_row, v_col);
    OCamlTableModel* m = get_qobject<OCamlTableModel>(v_m);
    QVariant res;
    {
        CamlBlockingSection blocking_section;
        res = m->data(m->index(Int_val(v_row), Int_val(v_col)), Qt::DisplayRole);
    }
    CAMLreturn(qvariant_to_string_option(res));
}

CAMLprim value caml_oqt6_tablemodel_header_data(value v_m, value v_section, value v_orient) {
    CAMLparam3(v_m, v_section, v_orient);
    OCamlTableModel* m = get_qobject<OCamlTableModel>(v_m);
    Qt::Orientation orient = Int_val(v_orient) == 0 ? Qt::Horizontal : Qt::Vertical;
    QVariant res;
    {
        CamlBlockingSection blocking_section;
        res = m->headerData(Int_val(v_section), orient, Qt::DisplayRole);
    }
    CAMLreturn(qvariant_to_string_option(res));
}

/* QStandardItemModel primitives */

CAMLprim value caml_oqt6_qstandarditemmodel_create(value v_rows, value v_cols, value v_parent) {
    CAMLparam3(v_rows, v_cols, v_parent);
    QObject* parent = Is_block(v_parent) ? get_qobject<QObject>(Field(v_parent, 0)) : nullptr;
    int rows = Is_block(v_rows) ? Int_val(Field(v_rows, 0)) : 0;
    int cols = Is_block(v_cols) ? Int_val(Field(v_cols, 0)) : 0;
    QStandardItemModel* m = new QStandardItemModel(rows, cols, parent);
    CAMLreturn(alloc_qobject(m, !Is_block(v_parent)));
}

CAMLprim value caml_oqt6_qstandarditemmodel_set_item(value v_m, value v_r, value v_c, value v_text) {
    CAMLparam4(v_m, v_r, v_c, v_text);
    QStandardItemModel* m = get_qobject<QStandardItemModel>(v_m);
    QStandardItem* item = new QStandardItem(QString::fromUtf8(String_val(v_text)));
    m->setItem(Int_val(v_r), Int_val(v_c), item);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qstandarditemmodel_item_text(value v_m, value v_r, value v_c) {
    CAMLparam3(v_m, v_r, v_c);
    QStandardItemModel* m = get_qobject<QStandardItemModel>(v_m);
    QStandardItem* item = m->item(Int_val(v_r), Int_val(v_c));
    if (!item) {
        CAMLreturn(caml_copy_string(""));
    }
    QByteArray utf8 = item->text().toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

CAMLprim value caml_oqt6_qstandarditemmodel_set_horizontal_header_labels(value v_m, value v_labels) {
    CAMLparam2(v_m, v_labels);
    QStandardItemModel* m = get_qobject<QStandardItemModel>(v_m);
    QStringList qlabels;
    value cur = v_labels;
    while (Is_block(cur)) {
        qlabels.append(QString::fromUtf8(String_val(Field(cur, 0))));
        cur = Field(cur, 1);
    }
    m->setHorizontalHeaderLabels(qlabels);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qstandarditemmodel_set_vertical_header_labels(value v_m, value v_labels) {
    CAMLparam2(v_m, v_labels);
    QStandardItemModel* m = get_qobject<QStandardItemModel>(v_m);
    QStringList qlabels;
    value cur = v_labels;
    while (Is_block(cur)) {
        qlabels.append(QString::fromUtf8(String_val(Field(cur, 0))));
        cur = Field(cur, 1);
    }
    m->setVerticalHeaderLabels(qlabels);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qstandarditemmodel_row_count(value v_m) {
    CAMLparam1(v_m);
    QStandardItemModel* m = get_qobject<QStandardItemModel>(v_m);
    CAMLreturn(Val_int(m->rowCount()));
}

CAMLprim value caml_oqt6_qstandarditemmodel_column_count(value v_m) {
    CAMLparam1(v_m);
    QStandardItemModel* m = get_qobject<QStandardItemModel>(v_m);
    CAMLreturn(Val_int(m->columnCount()));
}

CAMLprim value caml_oqt6_qstandarditemmodel_clear(value v_m) {
    CAMLparam1(v_m);
    QStandardItemModel* m = get_qobject<QStandardItemModel>(v_m);
    m->clear();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qstandarditemmodel_append_row(value v_m, value v_items) {
    CAMLparam2(v_m, v_items);
    QStandardItemModel* m = get_qobject<QStandardItemModel>(v_m);
    QList<QStandardItem*> row_items;
    value cur = v_items;
    while (Is_block(cur)) {
        row_items.append(new QStandardItem(QString::fromUtf8(String_val(Field(cur, 0)))));
        cur = Field(cur, 1);
    }
    m->appendRow(row_items);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qstandarditemmodel_remove_row(value v_m, value v_r) {
    CAMLparam2(v_m, v_r);
    QStandardItemModel* m = get_qobject<QStandardItemModel>(v_m);
    m->removeRow(Int_val(v_r));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qstandarditemmodel_remove_column(value v_m, value v_c) {
    CAMLparam2(v_m, v_c);
    QStandardItemModel* m = get_qobject<QStandardItemModel>(v_m);
    m->removeColumn(Int_val(v_c));
    CAMLreturn(Val_unit);
}

/* QTableView primitives */

CAMLprim value caml_oqt6_qtableview_create(value v_parent) {
    CAMLparam1(v_parent);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QTableView* v = new QTableView(parent);
    CAMLreturn(alloc_qobject(v, !Is_block(v_parent)));
}

CAMLprim value caml_oqt6_qtableview_set_model(value v_v, value v_m) {
    CAMLparam2(v_v, v_m);
    QTableView* v = get_qobject<QTableView>(v_v);
    QAbstractItemModel* m = get_qobject<QAbstractItemModel>(v_m);
    v->setModel(m);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtableview_set_selection_behavior(value v_v, value v_beh) {
    CAMLparam2(v_v, v_beh);
    QTableView* v = get_qobject<QTableView>(v_v);
    v->setSelectionBehavior(static_cast<QAbstractItemView::SelectionBehavior>(Int_val(v_beh)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtableview_set_selection_mode(value v_v, value v_mode) {
    CAMLparam2(v_v, v_mode);
    QTableView* v = get_qobject<QTableView>(v_v);
    v->setSelectionMode(static_cast<QAbstractItemView::SelectionMode>(Int_val(v_mode)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtableview_set_sorting_enabled(value v_v, value v_b) {
    CAMLparam2(v_v, v_b);
    QTableView* v = get_qobject<QTableView>(v_v);
    v->setSortingEnabled(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtableview_set_show_grid(value v_v, value v_b) {
    CAMLparam2(v_v, v_b);
    QTableView* v = get_qobject<QTableView>(v_v);
    v->setShowGrid(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtableview_set_alternating_row_colors(value v_v, value v_b) {
    CAMLparam2(v_v, v_b);
    QTableView* v = get_qobject<QTableView>(v_v);
    v->setAlternatingRowColors(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtableview_resize_columns_to_contents(value v_v) {
    CAMLparam1(v_v);
    QTableView* v = get_qobject<QTableView>(v_v);
    v->resizeColumnsToContents();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtableview_resize_rows_to_contents(value v_v) {
    CAMLparam1(v_v);
    QTableView* v = get_qobject<QTableView>(v_v);
    v->resizeRowsToContents();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtableview_horizontal_header(value v_v) {
    CAMLparam1(v_v);
    QTableView* v = get_qobject<QTableView>(v_v);
    CAMLreturn(alloc_qobject(v->horizontalHeader(), false));
}

CAMLprim value caml_oqt6_qtableview_vertical_header(value v_v) {
    CAMLparam1(v_v);
    QTableView* v = get_qobject<QTableView>(v_v);
    CAMLreturn(alloc_qobject(v->verticalHeader(), false));
}

CAMLprim value caml_oqt6_qtableview_selection_model(value v_v) {
    CAMLparam1(v_v);
    QTableView* v = get_qobject<QTableView>(v_v);
    /* selectionModel() is null once the view's model has been torn down;
       report that as None rather than handing back a dangling handle. */
    QItemSelectionModel* sm = v->selectionModel();
    if (sm == nullptr) {
        CAMLreturn(Val_int(0));
    }
    CAMLlocal2(v_sm, some);
    v_sm = alloc_qobject(sm, false);
    some = caml_alloc_some(v_sm);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qtableview_connect_clicked(value v_v, value v_cb) {
    CAMLparam2(v_v, v_cb);
    QTableView* v = get_qobject<QTableView>(v_v);
    value* root = new value;
    *root = v_cb;
    caml_register_global_root(root);

    QObject::connect(v, &QTableView::clicked, [root](const QModelIndex& index) {
        CamlDomainLockGuard guard;
        value args[2] = { Val_int(index.row()), Val_int(index.column()) };
        value res = caml_callbackN_exn(*root, 2, args);
        handle_callback_result(res);
    });
    connect_root_cleanup(v, root);

    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtableview_connect_double_clicked(value v_v, value v_cb) {
    CAMLparam2(v_v, v_cb);
    QTableView* v = get_qobject<QTableView>(v_v);
    value* root = new value;
    *root = v_cb;
    caml_register_global_root(root);

    QObject::connect(v, &QTableView::doubleClicked, [root](const QModelIndex& index) {
        CamlDomainLockGuard guard;
        value args[2] = { Val_int(index.row()), Val_int(index.column()) };
        value res = caml_callbackN_exn(*root, 2, args);
        handle_callback_result(res);
    });
    connect_root_cleanup(v, root);

    CAMLreturn(Val_unit);
}

/* QTreeView primitives */

CAMLprim value caml_oqt6_qtreeview_create(value v_parent) {
    CAMLparam1(v_parent);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QTreeView* v = new QTreeView(parent);
    CAMLreturn(alloc_qobject(v, !Is_block(v_parent)));
}

CAMLprim value caml_oqt6_qtreeview_set_model(value v_v, value v_m) {
    CAMLparam2(v_v, v_m);
    QTreeView* v = get_qobject<QTreeView>(v_v);
    QAbstractItemModel* m = get_qobject<QAbstractItemModel>(v_m);
    v->setModel(m);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtreeview_set_selection_behavior(value v_v, value v_beh) {
    CAMLparam2(v_v, v_beh);
    QTreeView* v = get_qobject<QTreeView>(v_v);
    v->setSelectionBehavior(static_cast<QAbstractItemView::SelectionBehavior>(Int_val(v_beh)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtreeview_set_selection_mode(value v_v, value v_mode) {
    CAMLparam2(v_v, v_mode);
    QTreeView* v = get_qobject<QTreeView>(v_v);
    v->setSelectionMode(static_cast<QAbstractItemView::SelectionMode>(Int_val(v_mode)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtreeview_set_sorting_enabled(value v_v, value v_b) {
    CAMLparam2(v_v, v_b);
    QTreeView* v = get_qobject<QTreeView>(v_v);
    v->setSortingEnabled(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtreeview_set_alternating_row_colors(value v_v, value v_b) {
    CAMLparam2(v_v, v_b);
    QTreeView* v = get_qobject<QTreeView>(v_v);
    v->setAlternatingRowColors(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtreeview_expand_all(value v_v) {
    CAMLparam1(v_v);
    QTreeView* v = get_qobject<QTreeView>(v_v);
    v->expandAll();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtreeview_collapse_all(value v_v) {
    CAMLparam1(v_v);
    QTreeView* v = get_qobject<QTreeView>(v_v);
    v->collapseAll();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtreeview_header(value v_v) {
    CAMLparam1(v_v);
    QTreeView* v = get_qobject<QTreeView>(v_v);
    CAMLreturn(alloc_qobject(v->header(), false));
}

CAMLprim value caml_oqt6_qtreeview_selection_model(value v_v) {
    CAMLparam1(v_v);
    QTreeView* v = get_qobject<QTreeView>(v_v);
    /* selectionModel() is null once the view's model has been torn down;
       report that as None rather than handing back a dangling handle. */
    QItemSelectionModel* sm = v->selectionModel();
    if (sm == nullptr) {
        CAMLreturn(Val_int(0));
    }
    CAMLlocal2(v_sm, some);
    v_sm = alloc_qobject(sm, false);
    some = caml_alloc_some(v_sm);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qtreeview_connect_clicked(value v_v, value v_cb) {
    CAMLparam2(v_v, v_cb);
    QTreeView* v = get_qobject<QTreeView>(v_v);
    value* root = new value;
    *root = v_cb;
    caml_register_global_root(root);

    QObject::connect(v, &QTreeView::clicked, [root](const QModelIndex& index) {
        CamlDomainLockGuard guard;
        value args[2] = { Val_int(index.row()), Val_int(index.column()) };
        value res = caml_callbackN_exn(*root, 2, args);
        handle_callback_result(res);
    });
    connect_root_cleanup(v, root);

    CAMLreturn(Val_unit);
}

/* QListView primitives */

CAMLprim value caml_oqt6_qlistview_create(value v_parent) {
    CAMLparam1(v_parent);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QListView* v = new QListView(parent);
    CAMLreturn(alloc_qobject(v, !Is_block(v_parent)));
}

CAMLprim value caml_oqt6_qlistview_set_model(value v_v, value v_m) {
    CAMLparam2(v_v, v_m);
    QListView* v = get_qobject<QListView>(v_v);
    QAbstractItemModel* m = get_qobject<QAbstractItemModel>(v_m);
    v->setModel(m);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qlistview_set_selection_behavior(value v_v, value v_beh) {
    CAMLparam2(v_v, v_beh);
    QListView* v = get_qobject<QListView>(v_v);
    v->setSelectionBehavior(static_cast<QAbstractItemView::SelectionBehavior>(Int_val(v_beh)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qlistview_set_selection_mode(value v_v, value v_mode) {
    CAMLparam2(v_v, v_mode);
    QListView* v = get_qobject<QListView>(v_v);
    v->setSelectionMode(static_cast<QAbstractItemView::SelectionMode>(Int_val(v_mode)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qlistview_selection_model(value v_v) {
    CAMLparam1(v_v);
    QListView* v = get_qobject<QListView>(v_v);
    /* selectionModel() is null once the view's model has been torn down;
       report that as None rather than handing back a dangling handle. */
    QItemSelectionModel* sm = v->selectionModel();
    if (sm == nullptr) {
        CAMLreturn(Val_int(0));
    }
    CAMLlocal2(v_sm, some);
    v_sm = alloc_qobject(sm, false);
    some = caml_alloc_some(v_sm);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qlistview_connect_clicked(value v_v, value v_cb) {
    CAMLparam2(v_v, v_cb);
    QListView* v = get_qobject<QListView>(v_v);
    value* root = new value;
    *root = v_cb;
    caml_register_global_root(root);

    QObject::connect(v, &QListView::clicked, [root](const QModelIndex& index) {
        CamlDomainLockGuard guard;
        value res = caml_callback_exn(*root, Val_int(index.row()));
        handle_callback_result(res);
    });
    connect_root_cleanup(v, root);

    CAMLreturn(Val_unit);
}

/* QHeaderView primitives */

CAMLprim value caml_oqt6_qheaderview_set_stretch_last_section(value v_h, value v_b) {
    CAMLparam2(v_h, v_b);
    QHeaderView* h = get_qobject<QHeaderView>(v_h);
    h->setStretchLastSection(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qheaderview_is_stretch_last_section(value v_h) {
    CAMLparam1(v_h);
    QHeaderView* h = get_qobject<QHeaderView>(v_h);
    CAMLreturn(Val_bool(h->stretchLastSection()));
}

CAMLprim value caml_oqt6_qheaderview_set_section_resize_mode(value v_h, value v_mode) {
    CAMLparam2(v_h, v_mode);
    QHeaderView* h = get_qobject<QHeaderView>(v_h);
    h->setSectionResizeMode(static_cast<QHeaderView::ResizeMode>(Int_val(v_mode)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qheaderview_set_section_resize_mode_section(value v_h, value v_logical_index, value v_mode) {
    CAMLparam3(v_h, v_logical_index, v_mode);
    QHeaderView* h = get_qobject<QHeaderView>(v_h);
    h->setSectionResizeMode(Int_val(v_logical_index), static_cast<QHeaderView::ResizeMode>(Int_val(v_mode)));
    CAMLreturn(Val_unit);
}

/* QItemSelectionModel primitives */

CAMLprim value caml_oqt6_qitemselectionmodel_clear_selection(value v_s) {
    CAMLparam1(v_s);
    QItemSelectionModel* s = get_qobject<QItemSelectionModel>(v_s);
    s->clearSelection();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qitemselectionmodel_has_selection(value v_s) {
    CAMLparam1(v_s);
    QItemSelectionModel* s = get_qobject<QItemSelectionModel>(v_s);
    CAMLreturn(Val_bool(s->hasSelection()));
}

CAMLprim value caml_oqt6_qitemselectionmodel_selected_rows(value v_s) {
    CAMLparam1(v_s);
    CAMLlocal2(list, cons);
    QItemSelectionModel* s = get_qobject<QItemSelectionModel>(v_s);
    QModelIndexList indexes = s->selectedRows();
    list = Val_emptylist;
    for (int i = indexes.size() - 1; i >= 0; --i) {
        cons = caml_alloc(2, 0);
        Store_field(cons, 0, Val_int(indexes[i].row()));
        Store_field(cons, 1, list);
        list = cons;
    }
    CAMLreturn(list);
}

CAMLprim value caml_oqt6_qitemselectionmodel_current_row(value v_s) {
    CAMLparam1(v_s);
    QItemSelectionModel* s = get_qobject<QItemSelectionModel>(v_s);
    CAMLreturn(Val_int(s->currentIndex().row()));
}

CAMLprim value caml_oqt6_qitemselectionmodel_current_column(value v_s) {
    CAMLparam1(v_s);
    QItemSelectionModel* s = get_qobject<QItemSelectionModel>(v_s);
    CAMLreturn(Val_int(s->currentIndex().column()));
}

CAMLprim value caml_oqt6_qitemselectionmodel_connect_selection_changed(value v_s, value v_cb) {
    CAMLparam2(v_s, v_cb);
    QItemSelectionModel* s = get_qobject<QItemSelectionModel>(v_s);
    value* root = new value;
    *root = v_cb;
    caml_register_global_root(root);

    QObject::connect(s, &QItemSelectionModel::selectionChanged, [root](const QItemSelection&, const QItemSelection&) {
        CamlDomainLockGuard guard;
        value res = caml_callback_exn(*root, Val_unit);
        handle_callback_result(res);
    });
    connect_root_cleanup(s, root);

    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qitemselectionmodel_connect_current_changed(value v_s, value v_cb) {
    CAMLparam2(v_s, v_cb);
    QItemSelectionModel* s = get_qobject<QItemSelectionModel>(v_s);
    value* root = new value;
    *root = v_cb;
    caml_register_global_root(root);

    QObject::connect(s, &QItemSelectionModel::currentChanged, [root](const QModelIndex& current, const QModelIndex&) {
        CamlDomainLockGuard guard;
        value args[2] = { Val_int(current.row()), Val_int(current.column()) };
        value res = caml_callbackN_exn(*root, 2, args);
        handle_callback_result(res);
    });
    connect_root_cleanup(s, root);

    CAMLreturn(Val_unit);
}

/* Helpers */
static Qt::CursorShape get_cursor_shape(int shape) {
    switch (shape) {
        case 0: return Qt::ArrowCursor;
        case 1: return Qt::UpArrowCursor;
        case 2: return Qt::CrossCursor;
        case 3: return Qt::WaitCursor;
        case 4: return Qt::IBeamCursor;
        case 5: return Qt::SizeVerCursor;
        case 6: return Qt::SizeHorCursor;
        case 7: return Qt::SizeBDiagCursor;
        case 8: return Qt::SizeFDiagCursor;
        case 9: return Qt::SizeAllCursor;
        case 10: return Qt::BlankCursor;
        case 11: return Qt::SplitVCursor;
        case 12: return Qt::SplitHCursor;
        case 13: return Qt::PointingHandCursor;
        case 14: return Qt::ForbiddenCursor;
        case 15: return Qt::OpenHandCursor;
        case 16: return Qt::ClosedHandCursor;
        default: return Qt::ArrowCursor;
    }
}

static Qt::DockWidgetArea get_dock_area(int area) {
    switch (area) {
        case 0: return Qt::LeftDockWidgetArea;
        case 1: return Qt::RightDockWidgetArea;
        case 2: return Qt::TopDockWidgetArea;
        case 3: return Qt::BottomDockWidgetArea;
        default: return Qt::LeftDockWidgetArea;
    }
}

/* QTabWidget primitives */

CAMLprim value caml_oqt6_qtabwidget_create(value v_parent) {
    CAMLparam1(v_parent);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QTabWidget* tw = new QTabWidget(parent);
    CAMLreturn(alloc_qobject(tw, !Is_block(v_parent)));
}

CAMLprim value caml_oqt6_qtabwidget_add_tab(value v_tw, value v_w, value v_label) {
    CAMLparam3(v_tw, v_w, v_label);
    QTabWidget* tw = get_qobject<QTabWidget>(v_tw);
    QWidget* w = get_qobject<QWidget>(v_w);
    int idx = tw->addTab(w, QString::fromUtf8(String_val(v_label)));
    mark_parented(v_w);
    CAMLreturn(Val_int(idx));
}

CAMLprim value caml_oqt6_qtabwidget_insert_tab(value v_tw, value v_idx, value v_w, value v_label) {
    CAMLparam4(v_tw, v_idx, v_w, v_label);
    QTabWidget* tw = get_qobject<QTabWidget>(v_tw);
    QWidget* w = get_qobject<QWidget>(v_w);
    int idx = tw->insertTab(Int_val(v_idx), w, QString::fromUtf8(String_val(v_label)));
    mark_parented(v_w);
    CAMLreturn(Val_int(idx));
}

CAMLprim value caml_oqt6_qtabwidget_remove_tab(value v_tw, value v_idx) {
    CAMLparam2(v_tw, v_idx);
    QTabWidget* tw = get_qobject<QTabWidget>(v_tw);
    tw->removeTab(Int_val(v_idx));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtabwidget_current_index(value v_tw) {
    CAMLparam1(v_tw);
    QTabWidget* tw = get_qobject<QTabWidget>(v_tw);
    CAMLreturn(Val_int(tw->currentIndex()));
}

CAMLprim value caml_oqt6_qtabwidget_set_current_index(value v_tw, value v_idx) {
    CAMLparam2(v_tw, v_idx);
    QTabWidget* tw = get_qobject<QTabWidget>(v_tw);
    tw->setCurrentIndex(Int_val(v_idx));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtabwidget_count(value v_tw) {
    CAMLparam1(v_tw);
    QTabWidget* tw = get_qobject<QTabWidget>(v_tw);
    CAMLreturn(Val_int(tw->count()));
}

CAMLprim value caml_oqt6_qtabwidget_tab_text(value v_tw, value v_idx) {
    CAMLparam2(v_tw, v_idx);
    QTabWidget* tw = get_qobject<QTabWidget>(v_tw);
    QByteArray utf8 = tw->tabText(Int_val(v_idx)).toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

CAMLprim value caml_oqt6_qtabwidget_set_tab_text(value v_tw, value v_idx, value v_txt) {
    CAMLparam3(v_tw, v_idx, v_txt);
    QTabWidget* tw = get_qobject<QTabWidget>(v_tw);
    tw->setTabText(Int_val(v_idx), QString::fromUtf8(String_val(v_txt)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtabwidget_set_tabs_closable(value v_tw, value v_b) {
    CAMLparam2(v_tw, v_b);
    QTabWidget* tw = get_qobject<QTabWidget>(v_tw);
    tw->setTabsClosable(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtabwidget_set_movable(value v_tw, value v_b) {
    CAMLparam2(v_tw, v_b);
    QTabWidget* tw = get_qobject<QTabWidget>(v_tw);
    tw->setMovable(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtabwidget_set_tab_icon(value v_tw, value v_idx, value v_ic) {
    CAMLparam3(v_tw, v_idx, v_ic);
    QTabWidget* tw = get_qobject<QTabWidget>(v_tw);
    tw->setTabIcon(Int_val(v_idx), Icon_val(v_ic));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtabwidget_connect_current_changed(value v_tw, value v_cb) {
    CAMLparam2(v_tw, v_cb);
    QTabWidget* tw = get_qobject<QTabWidget>(v_tw);
    value* root = new value;
    *root = v_cb;
    caml_register_global_root(root);

    QObject::connect(tw, &QTabWidget::currentChanged, [root](int index) {
        CamlDomainLockGuard guard;
        value res = caml_callback_exn(*root, Val_int(index));
        handle_callback_result(res);
    });
    connect_root_cleanup(tw, root);

    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtabwidget_connect_tab_close_requested(value v_tw, value v_cb) {
    CAMLparam2(v_tw, v_cb);
    QTabWidget* tw = get_qobject<QTabWidget>(v_tw);
    value* root = new value;
    *root = v_cb;
    caml_register_global_root(root);

    QObject::connect(tw, &QTabWidget::tabCloseRequested, [root](int index) {
        CamlDomainLockGuard guard;
        value res = caml_callback_exn(*root, Val_int(index));
        handle_callback_result(res);
    });
    connect_root_cleanup(tw, root);

    CAMLreturn(Val_unit);
}

/* QStackedWidget primitives */

CAMLprim value caml_oqt6_qstackedwidget_create(value v_parent) {
    CAMLparam1(v_parent);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QStackedWidget* sw = new QStackedWidget(parent);
    CAMLreturn(alloc_qobject(sw, !Is_block(v_parent)));
}

CAMLprim value caml_oqt6_qstackedwidget_add_widget(value v_sw, value v_w) {
    CAMLparam2(v_sw, v_w);
    QStackedWidget* sw = get_qobject<QStackedWidget>(v_sw);
    QWidget* w = get_qobject<QWidget>(v_w);
    int idx = sw->addWidget(w);
    mark_parented(v_w);
    CAMLreturn(Val_int(idx));
}

CAMLprim value caml_oqt6_qstackedwidget_remove_widget(value v_sw, value v_w) {
    CAMLparam2(v_sw, v_w);
    QStackedWidget* sw = get_qobject<QStackedWidget>(v_sw);
    QWidget* w = get_qobject<QWidget>(v_w);
    sw->removeWidget(w);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qstackedwidget_current_index(value v_sw) {
    CAMLparam1(v_sw);
    QStackedWidget* sw = get_qobject<QStackedWidget>(v_sw);
    CAMLreturn(Val_int(sw->currentIndex()));
}

CAMLprim value caml_oqt6_qstackedwidget_set_current_index(value v_sw, value v_idx) {
    CAMLparam2(v_sw, v_idx);
    QStackedWidget* sw = get_qobject<QStackedWidget>(v_sw);
    sw->setCurrentIndex(Int_val(v_idx));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qstackedwidget_count(value v_sw) {
    CAMLparam1(v_sw);
    QStackedWidget* sw = get_qobject<QStackedWidget>(v_sw);
    CAMLreturn(Val_int(sw->count()));
}

CAMLprim value caml_oqt6_qstackedwidget_connect_current_changed(value v_sw, value v_cb) {
    CAMLparam2(v_sw, v_cb);
    QStackedWidget* sw = get_qobject<QStackedWidget>(v_sw);
    value* root = new value;
    *root = v_cb;
    caml_register_global_root(root);

    QObject::connect(sw, &QStackedWidget::currentChanged, [root](int index) {
        CamlDomainLockGuard guard;
        value res = caml_callback_exn(*root, Val_int(index));
        handle_callback_result(res);
    });
    connect_root_cleanup(sw, root);

    CAMLreturn(Val_unit);
}

/* QSplitter primitives */

CAMLprim value caml_oqt6_qsplitter_create(value v_orient, value v_parent) {
    CAMLparam2(v_orient, v_parent);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    Qt::Orientation o = (Is_block(v_orient) && Int_val(Field(v_orient, 0)) == 1) ? Qt::Vertical : Qt::Horizontal;
    QSplitter* sp = new QSplitter(o, parent);
    CAMLreturn(alloc_qobject(sp, !Is_block(v_parent)));
}

CAMLprim value caml_oqt6_qsplitter_add_widget(value v_sp, value v_w) {
    CAMLparam2(v_sp, v_w);
    QSplitter* sp = get_qobject<QSplitter>(v_sp);
    QWidget* w = get_qobject<QWidget>(v_w);
    sp->addWidget(w);
    mark_parented(v_w);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qsplitter_set_orientation(value v_sp, value v_orient) {
    CAMLparam2(v_sp, v_orient);
    QSplitter* sp = get_qobject<QSplitter>(v_sp);
    sp->setOrientation(Int_val(v_orient) == 1 ? Qt::Vertical : Qt::Horizontal);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qsplitter_orientation(value v_sp) {
    CAMLparam1(v_sp);
    QSplitter* sp = get_qobject<QSplitter>(v_sp);
    CAMLreturn(Val_int(sp->orientation() == Qt::Vertical ? 1 : 0));
}

CAMLprim value caml_oqt6_qsplitter_set_sizes(value v_sp, value v_sizes) {
    CAMLparam2(v_sp, v_sizes);
    QSplitter* sp = get_qobject<QSplitter>(v_sp);
    QList<int> sizes;
    value cur = v_sizes;
    while (Is_block(cur)) {
        sizes.append(Int_val(Field(cur, 0)));
        cur = Field(cur, 1);
    }
    sp->setSizes(sizes);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qsplitter_sizes(value v_sp) {
    CAMLparam1(v_sp);
    CAMLlocal2(list, cons);
    QSplitter* sp = get_qobject<QSplitter>(v_sp);
    QList<int> sizes = sp->sizes();
    list = Val_emptylist;
    for (int i = sizes.size() - 1; i >= 0; --i) {
        cons = caml_alloc(2, 0);
        Store_field(cons, 0, Val_int(sizes[i]));
        Store_field(cons, 1, list);
        list = cons;
    }
    CAMLreturn(list);
}

CAMLprim value caml_oqt6_qsplitter_set_stretch_factor(value v_sp, value v_idx, value v_stretch) {
    CAMLparam3(v_sp, v_idx, v_stretch);
    QSplitter* sp = get_qobject<QSplitter>(v_sp);
    sp->setStretchFactor(Int_val(v_idx), Int_val(v_stretch));
    CAMLreturn(Val_unit);
}

/* QScrollArea primitives */

CAMLprim value caml_oqt6_qscrollarea_create(value v_parent) {
    CAMLparam1(v_parent);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QScrollArea* sa = new QScrollArea(parent);
    CAMLreturn(alloc_qobject(sa, !Is_block(v_parent)));
}

CAMLprim value caml_oqt6_qscrollarea_set_widget(value v_sa, value v_w) {
    CAMLparam2(v_sa, v_w);
    QScrollArea* sa = get_qobject<QScrollArea>(v_sa);
    QWidget* w = get_qobject<QWidget>(v_w);
    sa->setWidget(w);
    mark_parented(v_w);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qscrollarea_widget(value v_sa) {
    CAMLparam1(v_sa);
    QScrollArea* sa = get_qobject<QScrollArea>(v_sa);
    QWidget* w = sa->widget();
    if (!w) {
        CAMLreturn(Val_int(0));
    }
    CAMLlocal2(v_w, some);
    v_w = alloc_qobject(w, false);
    some = caml_alloc_some(v_w);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qscrollarea_set_widget_resizable(value v_sa, value v_b) {
    CAMLparam2(v_sa, v_b);
    QScrollArea* sa = get_qobject<QScrollArea>(v_sa);
    sa->setWidgetResizable(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qscrollarea_is_widget_resizable(value v_sa) {
    CAMLparam1(v_sa);
    QScrollArea* sa = get_qobject<QScrollArea>(v_sa);
    CAMLreturn(Val_bool(sa->widgetResizable()));
}

/* QGroupBox primitives */

CAMLprim value caml_oqt6_qgroupbox_create(value v_title, value v_parent) {
    CAMLparam2(v_title, v_parent);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QGroupBox* gb = new QGroupBox(parent);
    if (Is_block(v_title)) {
        gb->setTitle(QString::fromUtf8(String_val(Field(v_title, 0))));
    }
    CAMLreturn(alloc_qobject(gb, !Is_block(v_parent)));
}

CAMLprim value caml_oqt6_qgroupbox_title(value v_gb) {
    CAMLparam1(v_gb);
    QGroupBox* gb = get_qobject<QGroupBox>(v_gb);
    QByteArray utf8 = gb->title().toUtf8();
    CAMLreturn(caml_copy_string(utf8.constData()));
}

CAMLprim value caml_oqt6_qgroupbox_set_title(value v_gb, value v_title) {
    CAMLparam2(v_gb, v_title);
    QGroupBox* gb = get_qobject<QGroupBox>(v_gb);
    gb->setTitle(QString::fromUtf8(String_val(v_title)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qgroupbox_is_checkable(value v_gb) {
    CAMLparam1(v_gb);
    QGroupBox* gb = get_qobject<QGroupBox>(v_gb);
    CAMLreturn(Val_bool(gb->isCheckable()));
}

CAMLprim value caml_oqt6_qgroupbox_set_checkable(value v_gb, value v_b) {
    CAMLparam2(v_gb, v_b);
    QGroupBox* gb = get_qobject<QGroupBox>(v_gb);
    gb->setCheckable(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qgroupbox_is_checked(value v_gb) {
    CAMLparam1(v_gb);
    QGroupBox* gb = get_qobject<QGroupBox>(v_gb);
    CAMLreturn(Val_bool(gb->isChecked()));
}

CAMLprim value caml_oqt6_qgroupbox_set_checked(value v_gb, value v_b) {
    CAMLparam2(v_gb, v_b);
    QGroupBox* gb = get_qobject<QGroupBox>(v_gb);
    gb->setChecked(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qgroupbox_connect_toggled(value v_gb, value v_cb) {
    CAMLparam2(v_gb, v_cb);
    QGroupBox* gb = get_qobject<QGroupBox>(v_gb);
    value* root = new value;
    *root = v_cb;
    caml_register_global_root(root);

    QObject::connect(gb, &QGroupBox::toggled, [root](bool on) {
        CamlDomainLockGuard guard;
        value res = caml_callback_exn(*root, Val_bool(on));
        handle_callback_result(res);
    });
    connect_root_cleanup(gb, root);

    CAMLreturn(Val_unit);
}

/* QToolBar primitives */

CAMLprim value caml_oqt6_qtoolbar_create(value v_title, value v_parent) {
    CAMLparam2(v_title, v_parent);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QToolBar* tb = new QToolBar(parent);
    if (Is_block(v_title)) {
        tb->setWindowTitle(QString::fromUtf8(String_val(Field(v_title, 0))));
    }
    CAMLreturn(alloc_qobject(tb, !Is_block(v_parent)));
}

CAMLprim value caml_oqt6_qtoolbar_add_action(value v_tb, value v_act) {
    CAMLparam2(v_tb, v_act);
    QToolBar* tb = get_qobject<QToolBar>(v_tb);
    QAction* act = get_qobject<QAction>(v_act);
    tb->addAction(act);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtoolbar_add_action_text(value v_tb, value v_txt) {
    CAMLparam2(v_tb, v_txt);
    QToolBar* tb = get_qobject<QToolBar>(v_tb);
    QAction* act = tb->addAction(QString::fromUtf8(String_val(v_txt)));
    CAMLreturn(alloc_qobject(act, false));
}

CAMLprim value caml_oqt6_qtoolbar_add_widget(value v_tb, value v_w) {
    CAMLparam2(v_tb, v_w);
    QToolBar* tb = get_qobject<QToolBar>(v_tb);
    QWidget* w = get_qobject<QWidget>(v_w);
    tb->addWidget(w);
    mark_parented(v_w);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtoolbar_add_separator(value v_tb) {
    CAMLparam1(v_tb);
    QToolBar* tb = get_qobject<QToolBar>(v_tb);
    tb->addSeparator();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtoolbar_set_movable(value v_tb, value v_b) {
    CAMLparam2(v_tb, v_b);
    QToolBar* tb = get_qobject<QToolBar>(v_tb);
    tb->setMovable(Bool_val(v_b));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qtoolbar_is_movable(value v_tb) {
    CAMLparam1(v_tb);
    QToolBar* tb = get_qobject<QToolBar>(v_tb);
    CAMLreturn(Val_bool(tb->isMovable()));
}

CAMLprim value caml_oqt6_qmainwindow_add_toolbar(value v_win, value v_tb) {
    CAMLparam2(v_win, v_tb);
    QMainWindow* win = get_qobject<QMainWindow>(v_win);
    QToolBar* tb = get_qobject<QToolBar>(v_tb);
    win->addToolBar(tb);
    mark_parented(v_tb);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qmainwindow_add_toolbar_title(value v_win, value v_title) {
    CAMLparam2(v_win, v_title);
    QMainWindow* win = get_qobject<QMainWindow>(v_win);
    QToolBar* tb = win->addToolBar(QString::fromUtf8(String_val(v_title)));
    CAMLreturn(alloc_qobject(tb, false));
}

/* QDockWidget primitives */

CAMLprim value caml_oqt6_qdockwidget_create(value v_title, value v_parent) {
    CAMLparam2(v_title, v_parent);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QDockWidget* dw = new QDockWidget(parent);
    if (Is_block(v_title)) {
        dw->setWindowTitle(QString::fromUtf8(String_val(Field(v_title, 0))));
    }
    CAMLreturn(alloc_qobject(dw, !Is_block(v_parent)));
}

CAMLprim value caml_oqt6_qdockwidget_set_widget(value v_dw, value v_w) {
    CAMLparam2(v_dw, v_w);
    QDockWidget* dw = get_qobject<QDockWidget>(v_dw);
    QWidget* w = get_qobject<QWidget>(v_w);
    dw->setWidget(w);
    mark_parented(v_w);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qdockwidget_widget(value v_dw) {
    CAMLparam1(v_dw);
    QDockWidget* dw = get_qobject<QDockWidget>(v_dw);
    QWidget* w = dw->widget();
    if (!w) {
        CAMLreturn(Val_int(0));
    }
    CAMLlocal2(v_w, some);
    v_w = alloc_qobject(w, false);
    some = caml_alloc_some(v_w);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qmainwindow_add_dockwidget(value v_win, value v_area, value v_dw) {
    CAMLparam3(v_win, v_area, v_dw);
    QMainWindow* win = get_qobject<QMainWindow>(v_win);
    QDockWidget* dw = get_qobject<QDockWidget>(v_dw);
    win->addDockWidget(get_dock_area(Int_val(v_area)), dw);
    mark_parented(v_dw);
    CAMLreturn(Val_unit);
}

/* QColorDialog, QFontDialog, QInputDialog, QProgressDialog primitives */

CAMLprim value caml_oqt6_qcolordialog_get_color(value v_parent, value v_initial, value v_title) {
    CAMLparam3(v_parent, v_initial, v_title);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QColor initial = Is_block(v_initial) ? QColor_val(Field(v_initial, 0)) : Qt::white;
    QString title = Is_block(v_title) ? QString::fromUtf8(String_val(Field(v_title, 0))) : QString();

    QColor res;
    {
        CamlBlockingSection blocking_section;
        res = QColorDialog::getColor(initial, parent, title);
    }

    if (!res.isValid()) {
        CAMLreturn(Val_int(0));
    }
    CAMLlocal2(v_c, some);
    v_c = alloc_color(res);
    some = caml_alloc_some(v_c);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qfontdialog_get_font(value v_parent, value v_initial, value v_title) {
    CAMLparam3(v_parent, v_initial, v_title);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QFont initial = Is_block(v_initial) ? Font_val(Field(v_initial, 0)) : QFont();
    QString title = Is_block(v_title) ? QString::fromUtf8(String_val(Field(v_title, 0))) : QString();

    bool ok = false;
    QFont res;
    {
        CamlBlockingSection blocking_section;
        res = QFontDialog::getFont(&ok, initial, parent, title);
    }

    if (!ok) {
        CAMLreturn(Val_int(0));
    }
    CAMLlocal2(v_f, some);
    v_f = alloc_font(res);
    some = caml_alloc_some(v_f);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qinputdialog_get_text(value v_parent, value v_title, value v_label, value v_initial) {
    CAMLparam4(v_parent, v_title, v_label, v_initial);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QString title = QString::fromUtf8(String_val(v_title));
    QString label = QString::fromUtf8(String_val(v_label));
    QString initial = Is_block(v_initial) ? QString::fromUtf8(String_val(Field(v_initial, 0))) : QString();

    bool ok = false;
    QString res;
    {
        CamlBlockingSection blocking_section;
        res = QInputDialog::getText(parent, title, label, QLineEdit::Normal, initial, &ok);
    }

    if (!ok) {
        CAMLreturn(Val_int(0));
    }
    CAMLlocal2(v_str, some);
    QByteArray utf8 = res.toUtf8();
    v_str = caml_copy_string(utf8.constData());
    some = caml_alloc_some(v_str);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qinputdialog_get_int(value v_parent, value v_title, value v_label, value v_val, value v_min, value v_max, value v_step) {
    CAMLparam5(v_parent, v_title, v_label, v_val, v_min);
    CAMLxparam2(v_max, v_step);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QString title = QString::fromUtf8(String_val(v_title));
    QString label = QString::fromUtf8(String_val(v_label));
    int val = Is_block(v_val) ? Int_val(Field(v_val, 0)) : 0;
    int min_val = Is_block(v_min) ? Int_val(Field(v_min, 0)) : -2147483647;
    int max_val = Is_block(v_max) ? Int_val(Field(v_max, 0)) : 2147483647;
    int step = Is_block(v_step) ? Int_val(Field(v_step, 0)) : 1;

    bool ok = false;
    int res;
    {
        CamlBlockingSection blocking_section;
        res = QInputDialog::getInt(parent, title, label, val, min_val, max_val, step, &ok);
    }

    if (!ok) {
        CAMLreturn(Val_int(0));
    }
    CAMLlocal1(some);
    some = caml_alloc_some(Val_int(res));
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qinputdialog_get_int_byte(value* argv, int argn) {
    (void)argn;
    return caml_oqt6_qinputdialog_get_int(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6]);
}

CAMLprim value caml_oqt6_qinputdialog_get_item(value v_parent, value v_title, value v_label, value v_items, value v_cur, value v_editable) {
    CAMLparam5(v_parent, v_title, v_label, v_items, v_cur);
    CAMLxparam1(v_editable);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QString title = QString::fromUtf8(String_val(v_title));
    QString label = QString::fromUtf8(String_val(v_label));
    int current = Is_block(v_cur) ? Int_val(Field(v_cur, 0)) : 0;
    bool editable = Is_block(v_editable) ? Bool_val(Field(v_editable, 0)) : false;

    QStringList items;
    value cur = v_items;
    while (Is_block(cur)) {
        items.append(QString::fromUtf8(String_val(Field(cur, 0))));
        cur = Field(cur, 1);
    }

    bool ok = false;
    QString res;
    {
        CamlBlockingSection blocking_section;
        res = QInputDialog::getItem(parent, title, label, items, current, editable, &ok);
    }

    if (!ok) {
        CAMLreturn(Val_int(0));
    }
    CAMLlocal2(v_str, some);
    QByteArray utf8 = res.toUtf8();
    v_str = caml_copy_string(utf8.constData());
    some = caml_alloc_some(v_str);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qinputdialog_get_item_byte(value* argv, int argn) {
    (void)argn;
    return caml_oqt6_qinputdialog_get_item(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}

CAMLprim value caml_oqt6_qprogressdialog_create(value v_label, value v_cancel, value v_min, value v_max, value v_parent) {
    CAMLparam5(v_label, v_cancel, v_min, v_max, v_parent);
    QWidget* parent = Is_block(v_parent) ? get_qobject<QWidget>(Field(v_parent, 0)) : nullptr;
    QString label = QString::fromUtf8(String_val(v_label));
    QString cancel = QString::fromUtf8(String_val(v_cancel));
    int min_val = Int_val(v_min);
    int max_val = Int_val(v_max);
    QProgressDialog* pd = new QProgressDialog(label, cancel, min_val, max_val, parent);
    CAMLreturn(alloc_qobject(pd, !Is_block(v_parent)));
}

CAMLprim value caml_oqt6_qprogressdialog_set_value(value v_pd, value v_val) {
    CAMLparam2(v_pd, v_val);
    QProgressDialog* pd = get_qobject<QProgressDialog>(v_pd);
    pd->setValue(Int_val(v_val));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qprogressdialog_value(value v_pd) {
    CAMLparam1(v_pd);
    QProgressDialog* pd = get_qobject<QProgressDialog>(v_pd);
    CAMLreturn(Val_int(pd->value()));
}

CAMLprim value caml_oqt6_qprogressdialog_was_canceled(value v_pd) {
    CAMLparam1(v_pd);
    QProgressDialog* pd = get_qobject<QProgressDialog>(v_pd);
    CAMLreturn(Val_bool(pd->wasCanceled()));
}

CAMLprim value caml_oqt6_qprogressdialog_cancel(value v_pd) {
    CAMLparam1(v_pd);
    QProgressDialog* pd = get_qobject<QProgressDialog>(v_pd);
    pd->cancel();
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qprogressdialog_set_range(value v_pd, value v_min, value v_max) {
    CAMLparam3(v_pd, v_min, v_max);
    QProgressDialog* pd = get_qobject<QProgressDialog>(v_pd);
    pd->setRange(Int_val(v_min), Int_val(v_max));
    CAMLreturn(Val_unit);
}

/* QPixmap primitives */

CAMLprim value caml_oqt6_qpixmap_create(value v_w, value v_h) {
    CAMLparam2(v_w, v_h);
    QPixmap pm(Int_val(v_w), Int_val(v_h));
    CAMLreturn(alloc_pixmap(pm));
}

CAMLprim value caml_oqt6_qpixmap_load(value v_path) {
    CAMLparam1(v_path);
    QPixmap pm;
    bool ok = pm.load(QString::fromUtf8(String_val(v_path)));
    if (!ok) {
        CAMLreturn(Val_int(0));
    }
    CAMLlocal2(v_pm, some);
    v_pm = alloc_pixmap(pm);
    some = caml_alloc_some(v_pm);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qpixmap_width(value v_pm) {
    CAMLparam1(v_pm);
    CAMLreturn(Val_int(Pixmap_val(v_pm).width()));
}

CAMLprim value caml_oqt6_qpixmap_height(value v_pm) {
    CAMLparam1(v_pm);
    CAMLreturn(Val_int(Pixmap_val(v_pm).height()));
}

CAMLprim value caml_oqt6_qpixmap_is_null(value v_pm) {
    CAMLparam1(v_pm);
    CAMLreturn(Val_bool(Pixmap_val(v_pm).isNull()));
}

CAMLprim value caml_oqt6_qpixmap_fill(value v_pm, value v_c) {
    CAMLparam2(v_pm, v_c);
    Pixmap_val(v_pm).fill(QColor_val(v_c));
    CAMLreturn(Val_unit);
}

/* QIcon primitives */

CAMLprim value caml_oqt6_qicon_from_file(value v_path) {
    CAMLparam1(v_path);
    QIcon ic(QString::fromUtf8(String_val(v_path)));
    CAMLreturn(alloc_icon(ic));
}

CAMLprim value caml_oqt6_qicon_from_pixmap(value v_pm) {
    CAMLparam1(v_pm);
    QIcon ic(Pixmap_val(v_pm));
    CAMLreturn(alloc_icon(ic));
}

CAMLprim value caml_oqt6_qicon_from_theme(value v_name) {
    CAMLparam1(v_name);
    QIcon ic = QIcon::fromTheme(QString::fromUtf8(String_val(v_name)));
    CAMLreturn(alloc_icon(ic));
}

CAMLprim value caml_oqt6_qicon_is_null(value v_ic) {
    CAMLparam1(v_ic);
    CAMLreturn(Val_bool(Icon_val(v_ic).isNull()));
}

CAMLprim value caml_oqt6_qicon_available_sizes(value v_ic) {
    CAMLparam1(v_ic);
    CAMLlocal3(head, cons, pair);
    /* QIcon::availableSizes() is empty when the icon has no usable content,
       which is the only reliable cross-platform way to ask "did this actually
       load?". QIcon::isNull() is not: on Linux, QIcon("missing.png") constructs
       a loader engine entry anyway and reports isNull() == false, so is_null
       cannot be used to validate a path. Verified on Linux and Windows. */
    QList<QSize> sizes = Icon_val(v_ic).availableSizes();
    head = Val_int(0);
    for (qsizetype i = sizes.size() - 1; i >= 0; --i) {
        pair = caml_alloc_tuple(2);
        Store_field(pair, 0, Val_int(sizes[i].width()));
        Store_field(pair, 1, Val_int(sizes[i].height()));
        cons = caml_alloc(2, 0);
        Store_field(cons, 0, pair);
        Store_field(cons, 1, head);
        head = cons;
    }
    CAMLreturn(head);
}

CAMLprim value caml_oqt6_qpushbutton_set_icon(value v_btn, value v_ic) {
    CAMLparam2(v_btn, v_ic);
    QPushButton* btn = get_qobject<QPushButton>(v_btn);
    btn->setIcon(Icon_val(v_ic));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qaction_set_icon(value v_act, value v_ic) {
    CAMLparam2(v_act, v_ic);
    QAction* act = get_qobject<QAction>(v_act);
    act->setIcon(Icon_val(v_ic));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qmainwindow_set_window_icon(value v_win, value v_ic) {
    CAMLparam2(v_win, v_ic);
    QMainWindow* win = get_qobject<QMainWindow>(v_win);
    win->setWindowIcon(Icon_val(v_ic));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qpainter_draw_pixmap(value v_p, value v_x, value v_y, value v_pm) {
    CAMLparam4(v_p, v_x, v_y, v_pm);
    get_painter(v_p)->drawPixmap(Int_val(v_x), Int_val(v_y), Pixmap_val(v_pm));
    CAMLreturn(Val_unit);
}

/* QCursor primitives */

CAMLprim value caml_oqt6_qwidget_set_cursor(value v_w, value v_shape) {
    CAMLparam2(v_w, v_shape);
    QWidget* w = get_qobject<QWidget>(v_w);
    w->setCursor(QCursor(get_cursor_shape(Int_val(v_shape))));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qwidget_unset_cursor(value v_w) {
    CAMLparam1(v_w);
    QWidget* w = get_qobject<QWidget>(v_w);
    w->unsetCursor();
    CAMLreturn(Val_unit);
}

/* QMimeData primitives */

CAMLprim value caml_oqt6_qmimedata_create(value v_unit) {
    CAMLparam1(v_unit);
    QMimeData* m = new QMimeData();
    CAMLreturn(alloc_qobject(m, true));
}

CAMLprim value caml_oqt6_qmimedata_has_text(value v_m) {
    CAMLparam1(v_m);
    QMimeData* m = get_qobject<QMimeData>(v_m);
    CAMLreturn(Val_bool(m->hasText()));
}

CAMLprim value caml_oqt6_qmimedata_text(value v_m) {
    CAMLparam1(v_m);
    QMimeData* m = get_qobject<QMimeData>(v_m);
    if (!m->hasText()) {
        CAMLreturn(Val_int(0));
    }
    CAMLlocal2(v_str, some);
    QByteArray utf8 = m->text().toUtf8();
    v_str = caml_copy_string(utf8.constData());
    some = caml_alloc_some(v_str);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qmimedata_set_text(value v_m, value v_text) {
    CAMLparam2(v_m, v_text);
    QMimeData* m = get_qobject<QMimeData>(v_m);
    m->setText(QString::fromUtf8(String_val(v_text)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qmimedata_has_urls(value v_m) {
    CAMLparam1(v_m);
    QMimeData* m = get_qobject<QMimeData>(v_m);
    CAMLreturn(Val_bool(m->hasUrls()));
}

CAMLprim value caml_oqt6_qmimedata_urls(value v_m) {
    CAMLparam1(v_m);
    CAMLlocal3(head, cons, str);
    QMimeData* m = get_qobject<QMimeData>(v_m);
    QList<QUrl> urls = m->urls();
    head = Val_int(0);
    for (qsizetype i = urls.size() - 1; i >= 0; --i) {
        QByteArray utf8 = urls[i].toString().toUtf8();
        str = caml_copy_string(utf8.constData());
        cons = caml_alloc(2, 0);
        Store_field(cons, 0, str);
        Store_field(cons, 1, head);
        head = cons;
    }
    CAMLreturn(head);
}

CAMLprim value caml_oqt6_qmimedata_set_urls(value v_m, value v_urls) {
    CAMLparam2(v_m, v_urls);
    QMimeData* m = get_qobject<QMimeData>(v_m);
    QList<QUrl> urls;
    value cur = v_urls;
    while (Is_block(cur)) {
        value str_val = Field(cur, 0);
        urls.append(QUrl(QString::fromUtf8(String_val(str_val))));
        cur = Field(cur, 1);
    }
    m->setUrls(urls);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qmimedata_has_html(value v_m) {
    CAMLparam1(v_m);
    QMimeData* m = get_qobject<QMimeData>(v_m);
    CAMLreturn(Val_bool(m->hasHtml()));
}

CAMLprim value caml_oqt6_qmimedata_html(value v_m) {
    CAMLparam1(v_m);
    QMimeData* m = get_qobject<QMimeData>(v_m);
    if (!m->hasHtml()) {
        CAMLreturn(Val_int(0));
    }
    CAMLlocal2(v_str, some);
    QByteArray utf8 = m->html().toUtf8();
    v_str = caml_copy_string(utf8.constData());
    some = caml_alloc_some(v_str);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qmimedata_set_html(value v_m, value v_html) {
    CAMLparam2(v_m, v_html);
    QMimeData* m = get_qobject<QMimeData>(v_m);
    m->setHtml(QString::fromUtf8(String_val(v_html)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qmimedata_formats(value v_m) {
    CAMLparam1(v_m);
    CAMLlocal3(head, cons, str);
    QMimeData* m = get_qobject<QMimeData>(v_m);
    QStringList fmts = m->formats();
    head = Val_int(0);
    for (qsizetype i = fmts.size() - 1; i >= 0; --i) {
        QByteArray utf8 = fmts[i].toUtf8();
        str = caml_copy_string(utf8.constData());
        cons = caml_alloc(2, 0);
        Store_field(cons, 0, str);
        Store_field(cons, 1, head);
        head = cons;
    }
    CAMLreturn(head);
}

CAMLprim value caml_oqt6_qmimedata_data(value v_m, value v_fmt) {
    CAMLparam2(v_m, v_fmt);
    QMimeData* m = get_qobject<QMimeData>(v_m);
    QString fmt = QString::fromUtf8(String_val(v_fmt));
    if (!m->hasFormat(fmt)) {
        CAMLreturn(Val_int(0));
    }
    QByteArray ba = m->data(fmt);
    CAMLlocal2(str, some);
    str = caml_alloc_initialized_string((mlsize_t)ba.size(), ba.constData());
    some = caml_alloc_some(str);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qmimedata_set_data(value v_m, value v_fmt, value v_data) {
    CAMLparam3(v_m, v_fmt, v_data);
    QMimeData* m = get_qobject<QMimeData>(v_m);
    QString fmt = QString::fromUtf8(String_val(v_fmt));
    QByteArray ba(String_val(v_data), (int)caml_string_length(v_data));
    m->setData(fmt, ba);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qmimedata_clear(value v_m) {
    CAMLparam1(v_m);
    QMimeData* m = get_qobject<QMimeData>(v_m);
    m->clear();
    CAMLreturn(Val_unit);
}

/* QDrag primitives */

CAMLprim value caml_oqt6_qdrag_create(value v_parent) {
    CAMLparam1(v_parent);
    QWidget* parent = get_qobject<QWidget>(v_parent);
    QDrag* drag = new QDrag(parent);
    /* The parent widget owns it: a GC finalizer calling deleteLater() on a QDrag
       that is mid-exec() aborts an in-progress drag. */
    CAMLreturn(alloc_qobject(drag, false));
}

CAMLprim value caml_oqt6_qdrag_set_mime_data(value v_drag, value v_mime) {
    CAMLparam2(v_drag, v_mime);
    QDrag* drag = get_qobject<QDrag>(v_drag);
    QMimeData* mime = get_qobject<QMimeData>(v_mime);
    mark_parented(v_mime);
    drag->setMimeData(mime);
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qdrag_mime_data(value v_drag) {
    CAMLparam1(v_drag);
    QDrag* drag = get_qobject<QDrag>(v_drag);
    QMimeData* mime = drag->mimeData();
    if (!mime) {
        CAMLreturn(Val_int(0));
    }
    CAMLlocal2(v_mime, some);
    v_mime = alloc_qobject(mime, false);
    some = caml_alloc_some(v_mime);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_qdrag_set_pixmap(value v_drag, value v_pix) {
    CAMLparam2(v_drag, v_pix);
    QDrag* drag = get_qobject<QDrag>(v_drag);
    drag->setPixmap(Pixmap_val(v_pix));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qdrag_set_hot_spot(value v_drag, value v_x, value v_y) {
    CAMLparam3(v_drag, v_x, v_y);
    QDrag* drag = get_qobject<QDrag>(v_drag);
    drag->setHotSpot(QPoint(Int_val(v_x), Int_val(v_y)));
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_qdrag_exec(value v_drag, value v_actions) {
    CAMLparam2(v_drag, v_actions);
    QDrag* drag = get_qobject<QDrag>(v_drag);
    int act_int = Int_val(v_actions);
    Qt::DropActions actions = Qt::CopyAction;
    if (act_int == 1) actions = Qt::MoveAction;
    else if (act_int == 2) actions = Qt::LinkAction;
    else if (act_int == 3) actions = Qt::CopyAction | Qt::MoveAction;

    Qt::DropAction res;
    {
        CamlBlockingSection blocking_section;
        res = drag->exec(actions);
    }

    int out = 0; // Ignore
    if (res == Qt::CopyAction) out = 1;
    else if (res == Qt::MoveAction) out = 2;
    else if (res == Qt::LinkAction) out = 3;
    CAMLreturn(Val_int(out));
}

/* QClipboard primitives */

CAMLprim value caml_oqt6_clipboard_text(value v_mode) {
    CAMLparam1(v_mode);
    QClipboard* cb = QGuiApplication::clipboard();
    if (!cb) {
        CAMLreturn(Val_int(0));
    }
    int mode_int = Int_val(v_mode);
    QClipboard::Mode mode = QClipboard::Clipboard;
    if (mode_int == 1) mode = QClipboard::Selection;
    else if (mode_int == 2) mode = QClipboard::FindBuffer;

    const QMimeData* md = cb->mimeData(mode);
    if (!md || !md->hasText()) {
        CAMLreturn(Val_int(0));
    }
    QString s = cb->text(mode);
    CAMLlocal2(v_str, some);
    QByteArray utf8 = s.toUtf8();
    v_str = caml_copy_string(utf8.constData());
    some = caml_alloc_some(v_str);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_clipboard_set_text(value v_text, value v_mode) {
    CAMLparam2(v_text, v_mode);
    QClipboard* cb = QGuiApplication::clipboard();
    if (cb) {
        int mode_int = Int_val(v_mode);
        QClipboard::Mode mode = QClipboard::Clipboard;
        if (mode_int == 1) mode = QClipboard::Selection;
        else if (mode_int == 2) mode = QClipboard::FindBuffer;
        cb->setText(QString::fromUtf8(String_val(v_text)), mode);
    }
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_clipboard_pixmap(value v_mode) {
    CAMLparam1(v_mode);
    QClipboard* cb = QGuiApplication::clipboard();
    if (!cb) {
        CAMLreturn(Val_int(0));
    }
    int mode_int = Int_val(v_mode);
    QClipboard::Mode mode = QClipboard::Clipboard;
    if (mode_int == 1) mode = QClipboard::Selection;
    else if (mode_int == 2) mode = QClipboard::FindBuffer;

    QPixmap p = cb->pixmap(mode);
    if (p.isNull()) {
        CAMLreturn(Val_int(0));
    }
    CAMLlocal2(v_pm, some);
    v_pm = alloc_pixmap(p);
    some = caml_alloc_some(v_pm);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_clipboard_set_pixmap(value v_pix, value v_mode) {
    CAMLparam2(v_pix, v_mode);
    QClipboard* cb = QGuiApplication::clipboard();
    if (cb) {
        int mode_int = Int_val(v_mode);
        QClipboard::Mode mode = QClipboard::Clipboard;
        if (mode_int == 1) mode = QClipboard::Selection;
        else if (mode_int == 2) mode = QClipboard::FindBuffer;
        cb->setPixmap(Pixmap_val(v_pix), mode);
    }
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_clipboard_mime_data(value v_mode) {
    CAMLparam1(v_mode);
    QClipboard* cb = QGuiApplication::clipboard();
    if (!cb) {
        CAMLreturn(Val_int(0));
    }
    int mode_int = Int_val(v_mode);
    QClipboard::Mode mode = QClipboard::Clipboard;
    if (mode_int == 1) mode = QClipboard::Selection;
    else if (mode_int == 2) mode = QClipboard::FindBuffer;

    const QMimeData* m = cb->mimeData(mode);
    if (!m) {
        CAMLreturn(Val_int(0));
    }
    CAMLlocal2(v_mime, some);
    v_mime = alloc_qobject(const_cast<QMimeData*>(m), false);
    some = caml_alloc_some(v_mime);
    CAMLreturn(some);
}

CAMLprim value caml_oqt6_clipboard_set_mime_data(value v_mime, value v_mode) {
    CAMLparam2(v_mime, v_mode);
    QClipboard* cb = QGuiApplication::clipboard();
    if (cb) {
        int mode_int = Int_val(v_mode);
        QClipboard::Mode mode = QClipboard::Clipboard;
        if (mode_int == 1) mode = QClipboard::Selection;
        else if (mode_int == 2) mode = QClipboard::FindBuffer;

        QMimeData* m = get_qobject<QMimeData>(v_mime);
        mark_parented(v_mime);
        cb->setMimeData(m, mode);
    }
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_clipboard_clear(value v_mode) {
    CAMLparam1(v_mode);
    QClipboard* cb = QGuiApplication::clipboard();
    if (cb) {
        int mode_int = Int_val(v_mode);
        QClipboard::Mode mode = QClipboard::Clipboard;
        if (mode_int == 1) mode = QClipboard::Selection;
        else if (mode_int == 2) mode = QClipboard::FindBuffer;
        cb->clear(mode);
    }
    CAMLreturn(Val_unit);
}

CAMLprim value caml_oqt6_clipboard_connect_changed(value v_cb) {
    CAMLparam1(v_cb);
    QClipboard* cb = QGuiApplication::clipboard();
    if (!cb) {
        caml_failwith("CamlQt6: QClipboard is not available (QApplication not initialized)");
    }
    value* root = new value;
    *root = v_cb;
    caml_register_global_root(root);

    QObject::connect(cb, &QClipboard::dataChanged, [root]() {
        CamlDomainLockGuard guard;
        value res = caml_callback_exn(*root, Val_unit);
        handle_callback_result(res);
    });
    connect_root_cleanup(cb, root);

    CAMLreturn(Val_unit);
}

} // extern "C"
