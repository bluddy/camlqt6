#ifndef CAMLQT6_STUBS_H
#define CAMLQT6_STUBS_H

#ifndef NOMINMAX
#define NOMINMAX
#endif
#ifdef __cplusplus

#include <QPointer>
#include <QObject>
#include <QThread>
#ifdef _WIN32
#include <windows.h>
#else
#include <pthread.h>
#endif
#endif

#define CAML_NAME_SPACE
#ifdef __cplusplus
extern "C" {
#endif

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/threads.h>
#include <caml/printexc.h>

#ifdef __cplusplus
}
#endif

#ifdef Byte
#undef Byte
#endif

#ifdef __cplusplus

struct OCamlQObject {
    QPointer<QObject> ptr;
    bool owned;
};

/* The custom_operations pointer of a custom block sits immediately below its data.
   Used to reject cross-type confusion (e.g. a Color.t passed where a Pen.t is
   expected) before the payload is reinterpreted. */
#define Custom_operations_val(v) \
    (*((struct custom_operations**)((char*)Data_custom_val(v) - sizeof(value))))

extern const struct custom_operations camlqt6_qobject_ops;
extern const struct custom_operations camlqt6_qcolor_ops;
extern const struct custom_operations camlqt6_qfont_ops;
extern const struct custom_operations camlqt6_qpen_ops;
extern const struct custom_operations camlqt6_qbrush_ops;
extern const struct custom_operations camlqt6_qpixmap_ops;
extern const struct custom_operations camlqt6_qicon_ops;
extern const struct custom_operations camlqt6_qpainter_ops;

inline void check_custom(value v, const struct custom_operations* ops, const char* name) {
    if (!Is_block(v) || Custom_operations_val(v) != ops) {
        caml_invalid_argument(name);
    }
}

#define QObject_holder(v) ((OCamlQObject*)Data_custom_val(v))

value alloc_qobject(QObject* obj, bool owned = true);
void mark_parented(value v);

extern thread_local int thread_domain_lock_depth;
extern thread_local bool thread_is_registered;
extern uintptr_t gui_thread_id;
extern bool gui_thread_id_set;

/* Platform-specific function to get current thread ID as a numeric value. */
inline uintptr_t get_current_thread_id() {
#ifdef _WIN32
    return static_cast<uintptr_t>(GetCurrentThreadId());
#else
    return reinterpret_cast<uintptr_t>(pthread_self());
#endif
}

/* Record the GUI thread ID at App.create time. */
inline void set_gui_thread_id() {
    gui_thread_id = get_current_thread_id();
    gui_thread_id_set = true;
}

/* Check that we're on the GUI thread. Raises Failure if not. */
inline void check_gui_thread(const char* where) {
    if (gui_thread_id_set && get_current_thread_id() != gui_thread_id) {
        caml_failwith(where);
    }
}

/* thread_domain_lock_depth is a per-thread count of nested references this
   thread holds on the OCaml 5 runtime system:
     > 0  an OCaml -> C++ call is in progress on this thread, so the runtime
           system is already held by the calling OCaml frame, and a nested
           CamlDomainLockGuard must not re-acquire it;
     == 0 we are either inside a Qt -> OCaml callback or inside a
           CamlBlockingSection, so the runtime system must be acquired to touch
           OCaml state. */
inline void handle_callback_result(value res) {
    if (Is_exception_result(res)) {
        value exn = Extract_exception(res);
        char* msg = caml_format_exception(exn);
        fprintf(stderr, "[CamlQt6 Callback Exception]: %s\n", msg);
        fflush(stderr);
        free(msg);
    }
}

/* OCaml 5's mlvalues.h does not expose Val_max_int, so define the immediates'
   bounds here: values at or below Max_int are integers, values above it are
   pointers. Needed to tell an unboxed OCaml int from a block pointer. */
#define Camlqt6_Max_long (((mlsize_t)1 << (8 * sizeof(value) - 1)) - 1)
#define Camlqt6_Max_int  (Camlqt6_Max_long - ((mlsize_t)1 << (8 * sizeof(value) - 10)))

/* Coerce an untrusted OCaml callback result to bool. Only a genuine OCaml bool
   (or int 0/1) is accepted; anything else is rejected rather than read as a
   pointer and dereferenced by Bool_val.

   Deliberately non-raising: this is called from inside Qt virtual method
   overrides (dragEnterEvent/dragMoveEvent) where there is no OCaml frame to
   catch an exception, and raising here would longjmp through C++ frames. */
inline bool callback_to_bool(value res) {
    if (Is_exception_result(res)) return false;
    if (res == Val_false || res == Val_true) return res == Val_true;
    if (res >= Val_unit && res <= Camlqt6_Max_int) return res != 0;
    fprintf(stderr, "[CamlQt6] drag callback must return a bool; rejecting drop\n");
    return false;
}

/* Acquires the runtime system when entering OCaml code from a Qt callback. */
struct CamlDomainLockGuard {
    bool need_release;
    CamlDomainLockGuard() : need_release(false) {
        if (!thread_is_registered) {
            caml_c_thread_register();
            thread_is_registered = true;
        }
        if (thread_domain_lock_depth == 0) {
            caml_acquire_runtime_system();
            thread_domain_lock_depth++;
            need_release = true;
        }
    }
    ~CamlDomainLockGuard() {
        if (need_release) {
            thread_domain_lock_depth--;
            caml_release_runtime_system();
        }
    }
};

/* Releases the runtime system around a Qt call that may block or run a nested
   event loop, restoring the depth on scope exit. Exception-safe: a throw, a
   longjmp, or abort() inside the guarded Qt call can no longer leave the domain
   with a permanently corrupt lock state.

   IMPORTANT: this must be declared in an explicit inner scope that closes
   BEFORE the CAMLreturn of the enclosing primitive. Letting it live until
   function-scope exit makes its destructor run after CAMLreturn has begun the
   function epilogue, which tears down the OCaml frame's state underneath the
   caml_acquire_runtime_system() call and crashes with an access violation.

   Correct:
       CAMLparam1(v);
       { CamlBlockingSection bs; blocking_qt_call(); }
       CAMLreturn(Val_unit);

   Incorrect (access violation):
       CAMLparam1(v);
       CamlBlockingSection bs;
       blocking_qt_call();
       CAMLreturn(Val_unit);            // bs destroyed after CAMLreturn
*/
struct CamlBlockingSection {
    int saved_depth;
    CamlBlockingSection() : saved_depth(thread_domain_lock_depth) {
        /* Order matters: clear the depth first, exactly as the previous
           explicit release/acquire pairs did, so that a CamlDomainLockGuard
           entered from a callback inside the guarded Qt call behaves
           identically. */
        thread_domain_lock_depth = 0;
        caml_release_runtime_system();
    }
    ~CamlBlockingSection() {
        caml_acquire_runtime_system();
        thread_domain_lock_depth = saved_depth;
    }
};

template <typename T>
T* get_qobject(value v) {
    check_custom(v, &camlqt6_qobject_ops, "CamlQt6: expected a Qt object handle");
    OCamlQObject* holder = QObject_holder(v);
    if (holder->ptr.isNull()) {
        caml_failwith("CamlQt6: object has already been destroyed or is null");
    }
    if (gui_thread_id_set && get_current_thread_id() != gui_thread_id) {
        caml_failwith("CamlQt6: GUI operation called from non-GUI thread; use App.run_on_ui_thread to marshal");
    }
    T* casted = dynamic_cast<T*>(holder->ptr.data());
    if (!casted) {
        caml_failwith("CamlQt6: invalid object type cast");
    }
    return casted;
}

#endif // __cplusplus

#endif // CAMLQT6_STUBS_H
