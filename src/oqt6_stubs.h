#ifndef OQT6_STUBS_H
#define OQT6_STUBS_H

#ifndef NOMINMAX
#define NOMINMAX
#endif

#ifdef __cplusplus
#include <QPointer>
#include <QObject>
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

#define QObject_holder(v) ((OCamlQObject*)Data_custom_val(v))

value alloc_qobject(QObject* obj, bool owned = true);
void mark_parented(value v);

extern thread_local int thread_domain_lock_depth;

struct CamlDomainLockGuard {
    bool need_release;
    CamlDomainLockGuard() : need_release(false) {
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

template <typename T>
T* get_qobject(value v) {
    OCamlQObject* holder = QObject_holder(v);
    if (holder->ptr.isNull()) {
        caml_failwith("Oqt6: Object has already been destroyed or is null");
    }
    T* casted = dynamic_cast<T*>(holder->ptr.data());
    if (!casted) {
        caml_failwith("Oqt6: Invalid object type cast");
    }
    return casted;
}

#endif // __cplusplus

#endif // OQT6_STUBS_H
