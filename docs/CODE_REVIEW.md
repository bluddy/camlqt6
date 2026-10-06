# CamlQt6 Code Review — Findings & Remediation Plan

Status: **open** — Waves 1–6 complete and verified; 54 findings remain open
Reviewed: entire tree (`src/`, `test/`, `examples/`, `config/`, `scripts/`, docs, packaging)
Scope: correctness, soundness, threading, API design, missing features, build, tests, docs.

Progress: `[x]` done · `[~]` partial · `[ ]` open. Waves are described in §0.

**Remaining after Wave 6.** 54 open items, concentrated in four groups:

| Group | Items | Why deferred |
| :--- | :--- | :--- |
| `TreeModel` / `QImage` / `Painter.begin`+`end` | GAP-1, GAP-9, GAP-15, GAP-16 | Each is a new C++ class or custom block with its own lifetime story. See §6.1. |
| Disconnect handles | GAP-43, GAP-41, GAP-42 | ~40 signatures across four modules plus a `QMetaObject::Connection` custom block. |
| Widget / desktop surface | GAP-20..GAP-31, GAP-33..GAP-40 | Individually small; they batch cleanly but are pure feature work, not correctness. |
| Correctness hardening | CRIT-7, CRIT-9, HIGH-6/7/9..12, BEH-8..16 | Real but non-crashing: Qt assertion reachability, unvalidated ints, range checks, NUL truncation, inconsistent view arities. |

The README's *Honest caveats* section was written specifically so that none of the deferred items
is a hidden surprise; the outstanding work is therefore documented for users, not just here.

---

## 0. Remediation waves

| Wave | Scope | Status |
| :--- | :--- | :--- |
| 1 | C++ safety core: CRIT-2/3/4/5/6/8, HIGH-5, HIGH-13 | **done** |
| 2 | API breaks: CRIT-1, HIGH-1, HIGH-2, BEH-4/5/6, DSL-1 | **done** |
| 3 | Build/packaging: BUILD-1..26 | **done** (BUILD-10 left open on purpose) |
| 4 | Tests: TEST-1..14 | **done** (TEST-4 still partial: no leak detection) |
| 5 | Features | **partly done** - graphics + model roles shipped; TreeModel/QImage/begin-end deferred (see below) |
| 6 | Docs: DOC-1, DOC-2, DOC-10, DOC-11, DOC-12 | **done** |

### Corrections made during implementation
Findings in the original review that turned out to be wrong, and are withdrawn:

| Item | Claim | Reality |
| :--- | :--- | :--- |
| HIGH-3 | `addAction` should transfer ownership | Qt's `addAction` does **not** take ownership. `mark_parented` would have leaked. |
| HIGH-4 | `removeTab` leaks the page | `removeTab` leaves the page parented, so it stays Qt-owned. Not a leak. |
| HIGH-2 | `App.create` fabricates lock state | Re-scoped: `depth = 1` is *correct* and `thread_is_registered = true` is *necessary*. Only the off-main-thread case is a real bug. |
| BUILD-15 | `(libraries threads)` is dead weight | Required: removing it fails linking with `Cannot resolve symbols: caml_c_thread_register`. |
| TEST-1 | `-noassert` would silently neuter the suite | **Wrong on OCaml 5.** `ocamlopt -noassert` is a documented no-op on 5.3.0 — `assert false` still raises. Severity was overstated; the harness still ships, for isolation and explicit exit codes. |

New findings that emerged from implementation: **HIGH-13** (RAII guard must be destroyed before
`CAMLreturn`) and **CRIT-7** (Qt assertions reachable from unvalidated indices). Recording these
matters: acting on the withdrawn items would have introduced a leak and a double free respectively.

Five of my own findings have now been falsified by testing rather than by reading. That is the
argument for verifying claims in this codebase rather than trusting a plausible-looking reading of
the source.

## 0.1 Breaking API changes shipped in Wave 2

For a `0.1.0` unreleased package. Listed here so they can go in a CHANGELOG.

| Change | Before | After |
| :--- | :--- | :--- |
| `Core.cast` | `external cast : 'a t -> 'b t` | removed; `Core.Internal.cast` |
| `TableView/TreeView/ListView.selection_model` | `qitem_selection_model Core.t` | `... option` |
| `MessageBox.information/warning/critical` | `unit` | `MessageBox.answer` (callers may ignore) |
| `MessageBox.question` | `bool` | `MessageBox.answer` |
| `MessageBox.*` buttons | not configurable | new `?buttons:MessageBox.buttons` |
| `Dialog.exec` | `int` (raw `QDialog.DialogCode`) | `[ `Accepted | `Rejected ]` |
| `State.create` | `create : 'a -> 'a t` | `create : ?eq:('a -> 'a -> bool) -> 'a -> 'a t` |
| `State.map` / `State.map2` | no `eq` | optional `?eq` |

Behavioural changes worth noting:
- `MessageBox` no longer sets a default button (`setDefaultButton(NoButton)`), so pressing Return
  dismisses rather than silently accepting an implicit answer. Escape maps to `Cancel` for
  warning/critical/question.
- `MessageBox.answer` distinguishes `` `Dismissed `` (closed with no button) from `` `Cancel ``.
- `Object.delete` on a Qt-owned object now raises `Invalid_argument` and invalidates the handle
  instead of double-freeing.
- Calling any method on a destroyed handle raises `Failure` (previously reachable with `Val_unit`
  from a null `alloc_qobject`).
- `App.create` from a secondary OCaml domain now raises instead of corrupting lock state.

Legend: **CRIT** = crash / memory corruption · **HIGH** = unsound or silently wrong ·
**MED** = design or robustness defect · **LOW** = polish · **GAP** = missing feature.

Ownership column is for tracking. Checkbox per item so the file doubles as the worklist.

---

## Executive summary

The library is unusually broad for a hand-written binding (43 public modules, ~4400 lines of C++
stubs, no code generator). The FFI plumbing is more careful than most bindings — `QPointer`
tracking, global-root tracking, typed enum variants, labeled arguments are all real.

However, **the three claims the README leads with are not enforced by the code**:

| Claim | Reality |
| :--- | :--- |
| "Memory Safety via Guarded Pointers" | `alloc_qobject` returns `Val_unit` for null; no custom-tag validation on any accessor; `Object.delete` ignores the `owned` flag. |
| "Compile-Time Subtyping via Phantom Variants" | Defeated by `Core.cast : 'a t -> 'b t = "%identity"`, exported from `core.mli`. |
| "OCaml 5 Multicore & Domain-Lock Safe" | `App.create` fabricates lock state instead of registering the thread; no thread marshalling in the imperative API. |

The enum encodings, by contrast, are **correct** — see [Appendix A](#appendix-a--verified-enum-encodings).
Do not spend effort there.

Counts: 9 CRIT, 12 HIGH, 21 MED, 14 LOW, 47 GAP.

---

## 1. CRIT — correctness bugs that crash or corrupt memory

### [x] CRIT-1 `alloc_qobject` returns `Val_unit` for a null pointer
`src/camlqt6_stubs.cpp:113`

```cpp
if (!obj) return Val_unit;
```

**Fixed in two parts.** `alloc_qobject` now calls `caml_failwith` instead of returning `Val_unit`,
which closes the type-confusion hole for every caller at once. The *reachable* null sources were
then fixed at the API level: the three `selection_model` stubs return `None` when
`QAbstractItemView::selectionModel()` is null, and `widgets.mli` now declares them as
`option`. The drag-event `mimeData()` wrappers are safe because a null there now raises through
`get_qobject` instead of being dereferenced.

```cpp
if (!obj) return Val_unit;
```

`Val_unit` is the immediate `1`. Every OCaml function typed as returning `Core.t` can therefore
return an immediate, and the first `Data_custom_val` / `get_qobject` call on it dereferences wild
memory. Must `caml_failwith` instead.

Reachable callers that can actually produce null:
- `:464`, `:487`, `:519` — `dragEnterEvent` / `dragMoveEvent` / `dropEvent` `mimeData()` (documented nullable), passed to the OCaml callback as a `QMimeData Core.t`.
- `:2948`, `:3055`, `:3110` — `TableView` / `TreeView` / `ListView` `selectionModel()`, declared **non-`option`** in `widgets.mli:369,384,393`.

**Fix:** `caml_failwith("CamlQt6: null Qt object")` in `alloc_qobject`; change the three
`selection_model` externals and their `.mli`/`.ml` signatures to return `option`. **API break** (see §9.1).

### [x] CRIT-2 `Core.Object.delete` deletes Qt-owned pointers (double free)
`src/camlqt6_stubs.cpp:629-637` — ignores `holder->owned` entirely.

`Core.Object.delete` is public (`core.ml:10,17`). All of these return Qt-owned objects wrapped
`owned=false`, whose flag is stored correctly and then never consulted:

| Line | Producer |
| :--- | :--- |
| `:1911` | `QMainWindow::menuBar()` |
| `:1918` | `QMainWindow::statusBar()` |
| `:1902` | `QMainWindow::centralWidget()` |
| `:2936` / `:2942` | `QTableView` horizontal / vertical header |
| `:3049` | `QTreeView::header()` |
| `:2948` / `:3055` / `:3110` | the three `selectionModel()`s |
| `:1936` | `QMenuBar::addMenu()` result |
| `:1977` | `QMenu::addAction()` result |
| `:3658` | `QToolBar::addAction()` result |
| `:3703` | `QMainWindow::addToolBar(title)` result |
| `:4211` | `QDrag::mimeData()` |
| `:4340` | `QClipboard::mimeData()` |
| `:464` / `:487` / `:519` | drag-event mime wrappers |

**Fix:** check `owned` and refuse (raise `Invalid_argument`) when false.

### [x] CRIT-3 No custom-tag validation on any value accessor
`src/camlqt6_stubs.h:43` (`QObject_holder`), `:84` (`get_qobject`), and
`src/camlqt6_stubs.cpp:155` (`QColor_val`), `:179` (`Font_val`), `:203` (`Pen_val`),
`:227` (`Brush_val`), `:251` (`Pixmap_val`), `:275` (`Icon_val`), `:282` (`Painter_holder`).

No `Is_block(v)` check, no check that the block's `custom_operations` is the expected one.
All these blocks are one word, so `Pen.set_color pen (Pen.create ())` — reachable because
`Color.t` / `Pen.t` are abstract in the `.mli` with no runtime guard — reinterprets a `QPen`'s
refcount and atomics as a `QColor`. Result: heap corruption, not an exception.

Unguarded call sites include `:2401`, `:2446`, `:3754`, `:3775`, `:3969`, `:4219`, `:4319`,
`:3354`, `:4001`, `:4008`, `:4015`, `:4021`, `:2474`, `:2480`, `:2486`, `:2419`, `:2425`,
`:2436`, `:2458`, `:2466`, `:2352`, `:2358`, `:2312`, `:2317`, `:2322`, `:2327`, `:3954`,
`:3959`, `:3964`, `:3995`, and every `get_qobject<...>` site.

**Fix:** add `Is_block` + `*((custom_operations**)Data_custom_val(v)) == &xxx_custom_ops` guards
that `caml_invalid_argument` on mismatch. Each custom ops struct is already file-static, so this
is mechanical.

### [x] CRIT-4 `~OCamlTableModel` touches the global-roots table with no runtime system
`src/camlqt6_stubs.cpp:544-561`

`~OCamlCanvas` correctly wraps cleanup in `CamlDomainLockGuard` (`:326-337`); the table model does
not. The model is destroyed either from `finalize_qobject`'s `deleteLater` (`:82`, processed inside
`exec()`/`processEvents()` where `:843`/`:853`/`:864` have *released* the runtime system) or from a
parent's destructor. Mutating the roots table with no runtime system is undefined behaviour.

**Fix:** wrap the destructor body in `CamlDomainLockGuard`, matching `~OCamlCanvas`.

### [x] CRIT-5 `Bool_val` applied to arbitrary callback results (drag accept)
`src/camlqt6_stubs.cpp:472`, `:495`

`drag_enter` / `drag_move` OCaml callbacks are typed `-> bool`, but the C side only checks
`Is_exception_result`. `Bool_val` on a pointer or block reads field 0 as a tag → a garbage value
decides whether the drop is accepted.

**Fix:** require `Is_block(res) && Tag_val(res) == 0` (i.e. an OCaml bool) before `Bool_val`;
treat anything else as `false`.

### [x] CRIT-6 `Int_val` / `String_val` on unchecked `TableModel` callback results
`src/camlqt6_stubs.cpp:571`, `:582`, `:595`, `:610`

`rowCount`, `columnCount`, `data`, `headerData` call user closures whose OCaml return types are
arbitrary. `Int_val` on a tuple reads a pointer field as an `intnat`; `String_val` on a non-string
block reads a bogus length.

**Fix:** validate with a helper (`caml_is_int`-style check / `Is_block` + tag check for strings)
and return 0 / `QVariant()` on mismatch.

### [ ] CRIT-7 Qt assertions reachable from unvalidated OCaml ints
`src/camlqt6_stubs.cpp:3155`, `:3517`, `:1822`, `:1841`, `:3292`, `:3300`, `:3326`, `:3333`, `:3354`

- `QHeaderView::setSectionResizeMode(int, …)` — `Q_ASSERT(0 <= i && i < count())`
- `QSplitter::setStretchFactor(int, …)` — `Q_ASSERT(0 <= i && i < count())`
- `QGridLayout::addWidget/addLayout` — negative row/col, or span <= 0
- `insertTab` — valid range is `[-count, count]`

`abort()` against a debug Qt build; UB otherwise.

### [x] CRIT-8 Manual lock release/acquire is not exception-safe (17 sites)
`src/camlqt6_stubs.cpp:842-846`, `:852-856`, `:863-867`, `:2127-2131`, `:2170-2174`, `:2185-2189`,
`:2200-2204`, `:2215-2219`, `:2233-2237`, `:2256-2260`, `:2278-2282`, `:3757-3761`,
`:3779-3783`, `:3802-3806`, `:3830-3834`, `:3866-3870`, `:4239-4243`

```cpp
thread_domain_lock_depth--;
caml_release_runtime_system();
<Qt call that can throw / abort / longjmp>
caml_acquire_runtime_system();
thread_domain_lock_depth++;
```

If anything between release and acquire throws, longjmps, or hits `qt_message_handler`'s
`abort()` on `QtFatalMsg` (`:761-763`), the domain's lock state is permanently corrupted.
These should be `caml_enter_blocking_section` / `caml_leave_blocking_section`, or an RAII guard.

### [ ] CRIT-9 `dropEvent` accepts unconditionally
`src/camlqt6_stubs.cpp:528` — `event->acceptProposedAction()` is called even when the OCaml
callback raised, and the return type gives the callback no way to reject.

---

## 2. HIGH — unsoundness holes

### [x] HIGH-1 `Core.cast` defeated the entire phantom-subtyping design

**Fixed.** `Core.cast` no longer exists. `src/core.mli` now exposes only

```ocaml
module Internal : sig
  val cast : 'a t -> 'b t
end
```

documented as unsound and out of the supported surface. The two internal users (`Widget.as_widget`
at `widgets.ml:151`, `Dsl.bind_ui` at `dsl.ml:99`) go through `Core.Internal.cast`.

**Residual hole, stated honestly:** this reduces the accident surface but does not make the
phantom variants airtight — `Core.Internal.cast` is still reachable and still `%identity`. Making it
genuinely sound is not possible while the tag is a zero-cost phantom: the representation is shared
by construction, so forging a tag is always possible in principle. The practical guarantee is now
"the documented API has no unsound cast, and every internal use is greppable and commented".
Closing it fully would need `Core.t` to carry a runtime-checked tag, which trades away the
zero-overhead property the design is built on.

### [x] HIGH-2 `App.create` asserts lock state on a thread that must be the OCaml main thread — RE-SCOPED
`src/camlqt6_stubs.cpp:814-815`

```cpp
thread_domain_lock_depth = 1;
thread_is_registered = true;
```

**Re-scoped after tracing the invariant.** `thread_domain_lock_depth` is a per-thread count of
nested references this thread holds on the runtime system: `> 0` means "an OCaml→C++ call is in
progress, the calling OCaml frame already holds the lock, a nested
`CamlDomainLockGuard` must not re-acquire"; `== 0` means "inside a Qt callback or inside a
`CamlBlockingSection`, acquire explicitly". Setting it to 1 in `App.create` is therefore **correct**
for the thread that creates the application, and the `depth--` / `depth++` around each blocking Qt
call transitions it properly. Likewise `thread_is_registered = true` is correct, and *necessary*:
`caml_c_thread_register()` acquires the systhreads mutex, which the OCaml main thread already
holds, so calling it there would deadlock. `CamlDomainLockGuard` still registers lazily for any
foreign thread that reaches it.

The genuine remaining defect is narrower: nothing prevents `App.create` from being called on a
secondary OCaml domain, where the fabricated `depth = 1` would suppress lock acquisition for that
thread.

**Fix (Wave 2):** detect the non-main-thread case and raise a clear error, and document the
requirement. Not a memory-safety issue.

> **Shipped.** `caml_oqt6_qapplication_create` now checks `Caml_state->id != 0` and raises
> `Failure "CamlQt6: App.create must be called from the main OCaml domain"`. The invariant itself
> is documented at length in `src/camlqt6_stubs.h`, so the next reader does not have to re-derive
> it.

### [x] HIGH-13 `CamlBlockingSection` must be destroyed before `CAMLreturn`
Found *during* the Wave 1 implementation, not present in the original code.

Converting the 17 explicit release/acquire pairs to an RAII guard (`CamlBlockingSection`) crashed
the multicore test with `0xC0000005` (access violation). Cause: a guard declared at function scope
has its destructor run after `CAMLreturn` has begun the function epilogue, so
`caml_acquire_runtime_system()` executes with the OCaml frame's state half torn down. Every site
now uses an explicit inner scope that closes before `CAMLreturn`; the constraint is documented at
`src/camlqt6_stubs.h` with correct/incorrect examples. This also gives CRIT-8 for free: a throw out
of the guarded Qt call can no longer leave the domain with a corrupt lock state.

### [x] ~~HIGH-3~~ WITHDRAWN — `QAction` ownership on `addAction` is correct as written
Originally claimed `QMenuBar::addAction` (`:1943`), `QMenu::addAction` (`:1960`) and
`QToolBar::addAction` (`:3650`) should call `mark_parented`, leaving a use-after-free.

**Withdrawn on verification.** `QWidget::addAction`, `QMenu::addAction` and `QToolBar::addAction`
all explicitly do **not** take ownership (Qt documents this for `QWidget::addAction`). Keeping
`owned = true` is therefore correct: the action is destroyed when the OCaml handle is collected and
Qt removes it from the menu/toolbar automatically. Calling `mark_parented` would have *introduced* a
leak. No change made.

### [x] ~~HIGH-4~~ WITHDRAWN — `removeTab` / `removeWidget` do not leak
Originally claimed the removed page's `owned` flag is never restored, leaking the widget
(`:3297-3302`, `:3410-3416`).

**Withdrawn on verification.** `QTabWidget::removeTab` neither deletes nor unparents the page; it
stays a child of the tab widget and therefore remains Qt-owned. This is stock Qt behaviour (the page
becomes an invisible retained child), not a leak, and restoring `owned = true` would risk a
double free. No change made. Tracked separately as a UX question in §6 if desired.

### [x] HIGH-5 `QDrag` created with a parent is still wrapped `owned=true`
`src/camlqt6_stubs.cpp:4189-4191`. A GC finalizer can issue `deleteLater()` on a `QDrag` that is
mid-`exec()` (`:4241`), aborting an in-progress drag. Should be `false`.

### [ ] HIGH-6 `Qt::Orientation` decoding silently defaults on bad input
`src/camlqt6_stubs.cpp:1579`, `:1629`, `:3459`, `:3476` — `== 0 ? Horizontal : Vertical`.
Any nonzero int becomes `Qt::Vertical` instead of raising.

### [ ] HIGH-7 Non-`option` payloads used without a type check
`src/camlqt6_stubs.cpp:2342`, `:2345` (`Font.create` bold/italic), `:3856` (`InputDialog.get_item`
editable), and every `*_create` that uses `Is_block(v_parent)` to detect `Some` (`:1035`, `:1040`,
`:1082`, `:1124`, `:1199`, `:1272`, `:1332`, `:1392`, `:1488`, `:1573`, `:1717`, `:1805`, `:1877`,
`:1999`, `:2126`, `:2713`, `:2769`, `:2871`, `:2991`, `:3080`, `:3274`, `:3396`, `:3458`, `:3525`,
`:3569`, `:3638`, `:3710`, `:3889`) — a malformed argument is silently reinterpreted.

`String_val(Field(x,0))` on an unverified option payload appears at `:1041`, `:1088`, `:1125`,
`:1278`, `:1338`, `:1540`, `:1547`, `:1701`, `:1723`, `:1738`, `:1752`, `:1759`, `:1935`,
`:1976`, `:2005`, `:2013`, `:2093`, `:2799-2803`, `:2812-2816`, `:2846`, `:3489-3494`, `:3572`,
`:3587`, `:3641`, `:3713`, `:3853`, `:3861`, `:3890-3891`, `:4105`.

### [x] HIGH-8 `Color.name` never validates — **shipped in Wave 5**
`src/camlqt6_stubs.cpp` — `QColor(QString)` result was returned without `isValid()`, so
`Color.name "not-a-colour"` produced a `Color.t` indistinguishable from a valid one.

`caml_oqt6_qcolor_name_checked` now calls `caml_invalid_argument` for an unrecognised name, which
surfaces as `Color.name` raising. Covered by `color/name_rejects_garbage`; see GAP-19 for the
wider `Color` additions that shipped alongside it.

### [ ] HIGH-9 `Color.rgb` does not range-check
`src/camlqt6_stubs.cpp:2298-2301` — out-of-range channels produce a Qt warning + silent clamp.

### [ ] HIGH-10 OCaml lists consumed without cons-tag validation
`src/camlqt6_stubs.cpp:2799-2803`, `:2812-2816`, `:2844-2848`, `:3490-3494`, `:3859-3863`, `:4102-4107`

`while (Is_block(cur)) { ...; cur = Field(cur,1); }` — terminates early on a list of immediate
values (payloads silently dropped), and loops forever / crashes on a cyclic or non-cons block.
Needs a `Tag_val(cur) == 0` guard plus an explicit `Val_emptylist` check.

### [ ] HIGH-11 `Int_val` narrows 63-bit to `int` without range checking (~90 sites)
Every `Int_val(...)` outside `Val_int` truncates without a check. A user passing `max_int` to
`Widget.resize`, `set_width`, or any index argument gets silent wraparound.

### [ ] HIGH-12 `*_byte` wrappers ignore `argn` and read uninitialised stack slots
`src/camlqt6_stubs.cpp:3846`, `:3884`, `:2511`, `:2523`, `:1829`, `:1848` — `(void)argn;` then
blindly reads `argv[0..N]`. A bytecode caller passing too few arguments reads garbage.

---

## 3. HIGH/MED — threading and multicore

### [ ] THR-1 No thread marshalling exists
`src/camlqt6_stubs.cpp:871` — `is_ui_thread` exists purely to *detect* the problem. Not one
primitive in the file dispatches to the Qt thread. `App.run_on_ui_thread` (`widgets.ml:102`)
routes correctly through `post_task`, but the imperative API has no equivalent, so a `State`
updated from a worker domain that touches a widget directly executes Qt calls off the GUI thread.

**Fix:** add `App.run_on_ui_thread` usage (or a marshalling helper) at every widget-mutating entry
point, or document the constraint loudly and expose a checked variant that raises off-thread.

### [x] THR-2 `QThread` / `QRunnable` / `QThreadPool` binding — explicitly out of scope

OCaml has its own domain/thread system (`Domain.spawn`, `Thread.create`, `Eio`, `Async`, `Lwt`). 
Binding Qt's threading primitives would duplicate functionality, add cognitive overhead (two 
incompatible threading models), and not solve a real problem: the cooperative model 
(`App.run_on_ui_thread` + OCaml domains) covers all practical use cases. If a user truly 
needs a native Qt thread (e.g. for a long-running blocking C++ call), they can write a 
minimal FFI wrapper themselves. This is not a gap we intend to fill.

### [ ] THR-3 `OCamlUiDispatcher::instance()` is not thread-safe and moves itself
`src/camlqt6_stubs.cpp:783-792` — the singleton's `moveToThread` uses whichever thread first
calls it, not necessarily the Qt thread. Also leaks by design.

### [ ] THR-4 Global roots never released
- `src/camlqt6_stubs.cpp:4380-4389` — `Clipboard.on_changed` uses `QClipboard` as the sender, which
  lives for the whole process, so **every** call permanently leaks a `value*` and pins the closure.
- `:671` and every `connect_root_cleanup` call site (`:733`, `:1072`, `:1172`, `:1189`, `:1322`,
  `:1382`, `:1459`, `:1478`, `:1563`, `:1646`, `:1795`, `:2082`, `:2964`, `:2982`, `:3071`,
  `:3125`, `:3213`, `:3231`, `:3370`, `:3387`, `:3449`, `:3629`) — same when the sender is an
  application-lifetime object.
- `:680-691` — `QTimer::singleShot` leaks forever if `msec < 0` (timer never fires).
- `:887-891` — `post_task` leaks if the event is never delivered.

**Fix:** give `Clipboard.on_changed` (and friends) an explicit subscription handle, and register a
process-exit cleanup.

### [ ] THR-5 `strdup`'d argv never freed
`src/camlqt6_stubs.cpp:824-831`, and `global_argv` is resized without freeing the previous
allocation.

### [ ] THR-6 `finalize_qobject` uses `deleteLater()`
`src/camlqt6_stubs.cpp:82-83` — owned objects are only reclaimed if an event loop runs on the owning
thread; every owned widget collected after `QApplication` is destroyed leaks. A `deleteLater()`
issued from a GC finalizer on a non-Qt thread is itself dubious.

### [ ] THR-7 `qt_message_handler` hides diagnostics and calls `abort()`
`src/camlqt6_stubs.cpp:744-765` — silently drops any message containing `"propagateSizeHints"` or
`"QThreadStorage"` (`:746`); `abort()` on `QtFatalMsg` (`:761-763`) kills the OCaml runtime with no
diagnostic. No way to install your own handler or query severity.

### [ ] THR-8 `on_changed` wires only `dataChanged`
`src/camlqt6_stubs.cpp:4384` — `QClipboard::changed` and `selectionChanged` are not exposed, despite
`gui.mli:172` documenting "signals".

---

## 4. MED — `State` and `Dsl` design

### [x] DSL-1 Polymorphic `<>` is load-bearing for change detection
`src/dsl.ml:34`, `:52`; documented as the oscillation-prevention mechanism in
`docs/ARCHITECTURE.md:194-198`. Fails for: `nan` (notifies on every write), values containing
closures (always notifies), cyclic structures (diverges), and large values (deep compare per write).

**Fix:** make the equality function explicit — `State.create ?(eq (fun a b -> a = b)) initial`, or
require a `compare`/`equal` witness. **API change** (§9.2).


> **Shipped (Wave 2).** `State.create` now takes `?eq:('a -> 'a -> bool)` (defaulting to
> polymorphic `=`), stored in the state record and used by both `set` and `update`; `map` and
> `map2` take a matching `?eq`. The `.mli` and `.ml` document the four cases where the default is
> wrong (`nan`, closures, cycles, large values) and name `Float.equal` as the fix. Backwards
> compatible: the new argument is optional and the last positional argument is not erasable, so no
> trailing unit was needed.
>
> Regression test added at `test/test_camlqt6.ml` ("State custom equality"): asserts that the
> default `=` notifies twice on a `nan` write, and that `~eq:Float.equal` notifies once and still
> propagates genuine changes through `map`. This test fails against the old implementation.

### [ ] DSL-2 `State.map` / `map2` leak subscriptions unconditionally
`src/dsl.ml:87`, `:93-94`. The derived state's subscriber is never removable, so the source pins the
derived state and its entire downstream closure chain forever. No `Effect` composition.

### [ ] DSL-3 A `Mutex` per signal
`src/dsl.ml:19`. Allocated eagerly at `create`, locked on every `get`. `State.get` in a paint
callback is a lock/unlock per frame. Consider a lock-free read of an immutable field.

### [ ] DSL-4 Listener dispatch order is nondeterministic
`src/dsl.ml:70` prepends, so subscribers run in reverse registration order. The test at
`test_camlqt6.ml:660-674` asserts a specific order and will break on the second subscriber.

### [ ] DSL-5 Recursive `State.set` from a listener is unbounded
No re-entrancy guard; `src/dsl.ml:45`, `:63`.

### [ ] DSL-6 `Dsl.mount` of `Spacing`/`Stretch` silently creates a stray widget
`src/dsl.ml:453-456` — should raise.

### [ ] DSL-7 Non-`Widget` children are silently dropped
`src/dsl.ml:162` (`grid`), `:177` (`split`), `:190` (`tabs`), `:202` (`scroll`), `:224` (`group`),
`:444` (`window`), `:242` (`match_s`). `Dsl.grid [ (0,0, Dsl.spacing 10) ]` type-checks and vanishes.
These constructors should either support spacing/stretch or raise.

### [ ] DSL-8 `Dsl.canvas` argument bug
`src/dsl.ml:412-415` — `~height` is honoured only when `~width` is also supplied, and the value is
applied via `resize` (a hard set) rather than a minimum size.

### [ ] DSL-9 `Dsl.canvas` is missing `~on_resize`, `~on_drag_enter`, `~on_drag_move`,
`~on_drag_leave`, `~on_drop`, `~style` — all supported by `Canvas` (`widgets.mli:201-215`).

### [ ] DSL-10 No radio-button group
`src/dsl.ml:309-320` — `radio_button` two-way binding to a shared `bool State.t` cannot uncheck
siblings. Mutually-exclusive radio groups are impossible declaratively.

### [ ] DSL-11 `bind_ui` installs a permanent `destroyed` connection + global root per binding
`src/dsl.ml:106` — never fires for widgets that live to program exit.

### [ ] DSL-12 The "declarative" claim is thin
No reconciliation, no diffing, no node identity, no `list`/`foreach`, no `key`, no `effect`/
`on_mount`, no `State.of_ref`. `Dsl.mount` is imperative construction with automatic two-way wiring;
only the leaf bindings are reactive, not the tree. `docs/ARCHITECTURE.md:177-201` oversells this as
an FRP framework.

### [ ] DSL-13 `cond` / `match_s` mount every branch eagerly
`src/dsl.ml:240-245`. The zero-flicker win is real, but every hidden branch's widgets and `State`
subscriptions stay live forever.

---

## 5. MED — behaviour and API gaps in what exists

### [ ] BEH-1 `TableView.set_sorting_enabled` is a no-op for `TableModel`
`src/camlqt6_stubs.cpp` — `OCamlTableModel` does not override `sort()`, so
`QAbstractItemModel::sort()` does nothing. `examples/table_view_demo.ml:112` enables it. ROADMAP
Phase 3 lists "Sorting" as complete.

### [ ] BEH-2 `TableModel` supports only `DisplayRole` / `EditRole`
`src/camlqt6_stubs.cpp:587`. No foreground, background, decoration, alignment, font, tooltip,
check-state → no per-cell colouring, no in-cell icons, no right-aligned numbers.

### [ ] BEH-3 `TableModel` is read-only and undelegatable
No `flags` / `setData`, no `QStyledItemDelegate` support → no editing, no in-cell progress bars,
sliders or checkboxes.

### [x] BEH-4 `MessageBox` results are discarded
`src/camlqt6_stubs.cpp:2164-2177`, `:2179-2192` — `information`/`warning`/`critical` return
`QMessageBox::StandardButton` which is thrown away (`widgets.ml:511-513`). Callers cannot
distinguish Ok/Cancel/Save/Discard.

### [x] BEH-5 `MessageBox.question` collapses the answer
`src/camlqt6_stubs.cpp:2217-2221` — hardcodes `Yes|No`, returns `btn == Yes`, losing No vs Cancel.

### [x] BEH-6 `Dialog.exec` leaks a raw `QDialog::DialogCode` int
`src/camlqt6_stubs.cpp:2132`; surfaced as `int` in `widgets.ml:495`. Undocumented in the `.mli`.

### [ ] BEH-7 No `set_shortcut` validation
`Action.set_shortcut` takes a bare string (`widgets.mli:255`); a typo silently produces no shortcut.

### [ ] BEH-8 Unvalidated index/range arguments reach Qt
`src/camlqt6_stubs.cpp:1222`, `:1232`, `:1241` (negative stretch), `:1249`, `:1256`, `:1263`
(negative spacing/margins), `:1422` (`setCurrentIndex`), `:1436` (`itemText`), `:1854`, `:1861`
(negative row/column stretch), `:1512`, `:1519`, `:1526` (`min > max`), `:1673` (`setValue` out of
range), `:2404`, `:2425` (negative pen width), `:2770-2772` (negative rows/cols), `:2761`
(inverted `notify_data_changed` rect), `:2779-2780` (`setItem` out of range → `new QStandardItem`
leaks and OCaml sees `()` as success), `:2856`, `:2863` (`removeRow`/`removeColumn`), `:3486-3495`
(negative splitter sizes), `:3824-3827` (`getInt` with `min > max` or `step <= 0`),
`:3935` (negative/zero pixmap size).

### [ ] BEH-9 `QBrush` style collapses all nonzero to `NoBrush`
`src/camlqt6_stubs.cpp:2449-2452`, `:2465-2466` — `s == 0 ? Qt::SolidPattern : Qt::NoBrush`. No
validation, no other `Qt::BrushStyle` reachable.

### [ ] BEH-10 `ListView.on_clicked` arity is inconsistent with the other views
`src/camlqt6_stubs.cpp:3120-3123` passes only `index.row()`; `TableView` (`:2958-2962`) and
`TreeView` (`:3065-3070`) pass `(row, column)`. Reflected in the differing `.mli` arities
(`widgets.mli:394` vs `:370`, `:385`).

### [ ] BEH-11 `ItemSelectionModel.on_current_changed` does not check index validity
`src/camlqt6_stubs.cpp:3225-3229` — a model reset yields a callback with `-1, -1`.

### [ ] BEH-12 `compare_qobject` / `hash_qobject` break after destruction
`src/camlqt6_stubs.cpp:87-99` — keyed on the raw `QObject*`. Once destroyed, every wrapper hashes to
0 and compares equal to every other dead wrapper. `Hashtbl` / `Set` invariants break.

### [ ] BEH-13 `QAction::triggered` never fires for programmatic `setChecked`
`src/camlqt6_stubs.cpp:2077-2081` — binds `triggered(bool)`; expected Qt behaviour, but worth
documenting since the DSL relies on signals.

### [ ] BEH-14 `String_val` → `QString::fromUtf8` truncates at embedded NULs (systemic)
`src/camlqt6_stubs.cpp` — ~60 sites including `:1013`, `:1041`, `:1088`, `:1096`, `:1125`, `:1133`,
`:1147`, `:1278`, `:1299`, `:1338`, `:1359`, `:1403`, `:1540`, `:1547`, `:1701`, `:1723`, `:1738`,
`:1752`, `:1759`, `:1935`, `:1976`, `:2005`, `:2013`, `:2093`, `:2167-2168`, `:2182-2183`,
`:2197-2198`, `:2212-2213`, `:2229-2231`, `:2252-2254`, `:2275-2276`, `:2307`, `:2336`, `:2358`,
`:2534`, `:2801`, `:2814`, `:3572`, `:3587`, `:3641`, `:3713`, `:3755`, `:3776`, `:3797-3798`,
`:3861`, `:3890-3891`, `:3942`, `:3977`, `:3989`, `:4071`, `:4105`, `:4134`, `:4158`, `:4172`,
`:4285`; plus `:824` for argv.

The codebase already has the correct idiom at `:4164` (`caml_alloc_initialized_string`) and `:4173`
(`QByteArray(String_val, caml_string_length)`) — apply it consistently.

### [ ] BEH-15 `Color.red_color` is an awkward workaround
`src/gui.mli:16` — the accessor `Color.red` shadows the constant.

### [ ] BEH-16 `qobject_custom_ops` is declared `static` but referenced across the file
`src/camlqt6_stubs.cpp:101` — fine today, but blocks the custom-tag checks required by CRIT-3
(needs file-static access, which it already has — just confirm before restructuring).

---

## 6. GAP — missing features

### Model / view
- [ ] GAP-1 **`TreeModel`** — a zero-copy `QAbstractItemModel` counterpart to `TableModel`. Without
  it `QTreeView` requires the copying `StandardItemModel`, directly undercutting the "zero-copy"
  claim in `README.md:20`. **Deferred from Wave 5** — see §6.1.
- [x] GAP-2 `TableModel.sort` so sorting actually works (see BEH-1). **Shipped.** `TableModel.create`
  takes `~sort:(int -> [ `Ascending | `Descending ] -> unit)`; `OCamlTableModel::sort` is now
  overridden (Qt's default is a no-op, which is why `set_sorting_enabled` silently did nothing), it
  resets the view, and `TableModel.sort ~column ~descending` triggers it from OCaml. Verified by
  neutering the override: 4 sort assertions fail without it.
- [ ] GAP-3 `setData` + `flags` + `QStyledItemDelegate` for editing and custom cell rendering.
- [x] GAP-4 Per-cell roles. **Partly shipped:** `~foreground`, `~background`, `~alignment`,
  `~decoration` and `~tooltip` callbacks, each `(row, col) -> payload option` where `None` means
  "no opinion". `~alignment` takes OR'd `TableModel.align_*` flags. Still missing: check-state,
  font, and a general `UserRole` payload channel.
- [ ] GAP-5 `QStandardItem` API — nested child items, per-cell icons/colors/checkstate.
- [ ] GAP-6 `QPersistentModelIndex`; model signals beyond the two hand-rolled notifiers.
- [ ] GAP-7 `QSortFilterProxyModel` — essential for real tables.

### 2D graphics
- [x] GAP-8 **`QPainter.set_render_hint`** (`Antialiasing`, `TextAntialiasing`,
  `SmoothPixmapTransform`). **Shipped**, as `Painter.set_render_hint` / `set_hint`, plus
  `Painter.enable_antialiasing` for the common case. `Dsl.canvas` now takes `?antialiasing`
  (default `true`) and enables both shape and text antialiasing before invoking the user's
  closure, so the declarative path is smooth out of the box. This is what makes
  `README.md:21` / `:40` ("Full QPainter support", "Custom 2D Vector Painting") true.
- [ ] GAP-9 `QPainter.begin` / `end` — without them you **cannot paint into a `QPixmap`** at all.
  **Deferred** — see §6.1.
- [ ] GAP-10 Clipping: `set_clip_rect`, `set_clip_region`, `set_clipping`.
- [x] GAP-11 `set_opacity`. **Shipped** as `Painter.set_opacity` (0.0-1.0).
- [x] GAP-12 Missing primitives. **Partly shipped:** `draw_polyline`, `draw_polygon`, `draw_arc_deg`,
  `draw_pie_deg`, and `fill_rect_brush` (fill using the current brush). Arc/pie take a single
  `(x, y, w, h)` rect tuple to stay within the 5-argument native-stub limit, with angles in
  degrees. Still missing: `draw_path`, `draw_image`, `draw_points`, `fill_path`.
- [x] GAP-13 `bounding_rect` via `QFontMetricsF` (Qt 6 removed `QPainter::boundingRect(QString)`).
  Still missing: `draw_text` with a rect/alignment/wrap, and `font_metrics`.
- [ ] GAP-14 Gradient brushes (`QLinearGradient`, `QRadialGradient`, `QConicalGradient`).

### Imaging
- [ ] GAP-15 **No `QImage` type at all.** `Pixmap` cannot be loaded from raw bytes, scaled, rotated,
  saved, or converted — so `Pixmap` cannot round-trip a canvas render. **Deferred** — see §6.1.
- [ ] GAP-16 `Pixmap.to_file` / `save`, `scaled`, `transformed`, `copy`, `create_from_image`.

### Styling objects
- [x] GAP-17 `Pen` / `Brush` getters, cap style, join style, dash pattern. **Shipped.** Also
  completed the pen-style variant: `Dash_dot_line` and `Dash_dot_dot_line` were missing (only 4 of
  Qt's 6 styles were reachable), and the brush now exposes 6 patterns instead of 2. Note BEH-9 is
  resolved: every style is now mapped symbolically rather than "any nonzero int is `No_brush`".
- [x] GAP-18 `Font` weight, underline, strikeout, letter spacing, `point_size_f`. **Shipped**
  (added to `Font.create` as optional args, plus accessors). Weight constants are exposed as
  `Font.thin` .. `Font.black_weight` — `bold_weight`/`black_weight` are suffixed because `bold` is
  already the boolean accessor. Still missing: style strategy, kerning.
- [x] GAP-19 `Color` HSV/HSL (both directions), `lighter`/`darker`, `to_hex`, `is_valid`.
  **Shipped.** Closes HIGH-8 as well: `Color.name` now raises `Invalid_argument` on an unparsable
  string instead of returning an invalid-but-plausible colour.

### Widgets
- [ ] GAP-20 Window state: `show_maximized`, `show_minimized`, `show_full_screen`, `show_normal`,
  `window_state`, `set_window_flag`.
- [ ] GAP-21 Geometry: `move`, `set_geometry`, `geometry`, `set_minimum_size`,
  `set_maximum_size`, `set_size_increment` (only `set_fixed_size` exists — `widgets.mli:79`).
- [ ] GAP-22 `set_window_icon` on plain `Widget` (only `MainWindow` has it — `widgets.mli:224`).
- [ ] GAP-23 `set_tool_tip`, `set_status_tip`, `set_whats_this`, `set_focus`, `clear_focus`,
  `set_tab_order`, `set_size_grip`, `set_window_modality`, `set_attribute`.
- [ ] GAP-24 `QLayout.remove_widget`, `QLayout.invalidate`, `QLayout.activate`; `QWidget.set_layout`
  is not guarded against being called twice.
- [ ] GAP-25 `QComboBox.set_item_data`, `set_editable`, `set_icon_size`; `QLineEdit` echo mode,
  input mask, max length, validators.
- [ ] GAP-26 `QTextEdit` cursor / selection / undo / `QTextCursor` — currently text-only.
- [ ] GAP-27 Convenience widgets: `QListWidget`, `QTreeWidget`, `QScrollBar`, `QDateEdit`,
  `QTimeEdit`, `QDateTimeEdit`, `QLCDNumber`, `QDial`.
- [ ] GAP-28 `QKeySequence` as a first-class type (shortcuts are bare strings today).
- [ ] GAP-29 `QActionGroup` — no exclusive radio menu actions.
- [ ] GAP-30 `QShortcut` as a standalone object.
- [ ] GAP-31 `Widget.grab` / `Widget.render` — no screenshot capability.

### Application / platform
- [ ] GAP-32 Application style / palette control (`QStyleFactory::Fusion`, dark mode).
- [ ] GAP-33 `QProcess` — cannot spawn a subprocess. Large gap for a desktop toolkit.
- [ ] GAP-34 `QDesktopServices` — cannot open a URL in the system browser.
- [ ] GAP-35 `QStandardPaths`.
- [ ] GAP-36 `QSettings`.
- [ ] GAP-37 `QTranslator` / i18n.
- [ ] GAP-38 `QUndoStack`.
- [ ] GAP-39 `QLoggingCategory` / `QMessageLogger` — cannot integrate with Qt's logging.
- [ ] GAP-40 `QFileSystemWatcher`.

### Signals and reflection
- [ ] GAP-41 No generic connect-by-name (`connect ~signal:"clicked"`).
- [ ] GAP-42 No `QMetaObject.invokeMethod`.
- [ ] GAP-43 **No way to disconnect a specific handler** — every `on_*` returns `unit`, so
  subscriptions are permanent. Interacts with THR-4.
- [ ] GAP-44 No `QObject.property` / `set_property`.
- [ ] GAP-45 No queued connections with explicit types.

### DSL
- [ ] GAP-46 `list` / `foreach` combinator; `key` for reconciliation.
- [ ] GAP-47 `effect` / `on_mount` / `on_cleanup`.
- [ ] GAP-48 `State.of_ref`, `State.batch`, `map3`, `State.eq` (see DSL-1).
- [ ] GAP-49 DSL widgets that have no combinator at all: `list_view`, `table`, `menu`,
  `toolbar`, `menu_bar` actions, `dock`, `dialog`, `file_picker`, `color_button`.

---

## 6.1 Wave 5: what shipped and what was deliberately deferred

Shipped in Wave 5 (all verified, 224 checks green):

| Item | Summary |
| :--- | :--- |
| GAP-8 | `Painter.set_render_hint` / `set_hint` / `enable_antialiasing`; `Dsl.canvas ?antialiasing` defaults to on |
| GAP-11 | `Painter.set_opacity` |
| GAP-12 (part) | `draw_polyline`, `draw_polygon`, `draw_arc_deg`, `draw_pie_deg`, `fill_rect_brush` |
| GAP-13 (part) | `Painter.bounding_rect` via `QFontMetricsF` |
| GAP-17 | Pen/Brush getters, cap/join styles, dash pattern; all 6 pen styles and 6 brush patterns |
| GAP-18 | `Font` weight/underline/strikeout/letter_spacing/`point_size_f` + weight constants |
| GAP-19 + HIGH-8 | `Color` HSV/HSL both ways, `lighter`/`darker`/`to_hex`/`is_valid`; `Color.name` now raises on garbage |
| GAP-2 | `TableModel ~sort` + `OCamlTableModel::sort` override + `TableModel.sort` |
| GAP-4 (part) | `~foreground`, `~background`, `~alignment`, `~decoration`, `~tooltip` cell roles |

**Deferred, with reasons.** These are the largest remaining items and none of them is a
false claim *on its own*; each needs its own wave:

- **GAP-1 `TreeModel`** — a new `QAbstractItemModel` subclass with a child-index protocol
  (`parent`, `rowCount(parent)`, `index(parent, row, col)`). This is a genuinely new C++ class plus
  a new OCaml shape type; it does not belong in the same change as the graphics work, and shipping
  it half-finished would be worse than not shipping it. Until it exists, `README.md:20`'s
  "zero-copy ... into `QTableView`, `QTreeView`, and `QListView`" remains **overstated for
  `TreeView`** and Wave 6 should say so.
- **GAP-15 `QImage` + GAP-16 `Pixmap` save/scale** — needed before GAP-9 is meaningful, since
  `Painter.begin` needs a paint device that is not a widget. Also a new custom block type with its
  own finalizer.
- **GAP-9 `Painter.begin`/`end`** — depends on the two above.
- **GAP-43 disconnect handles** — requires changing every `on_*` to return a handle backed by a
  `QMetaObject::Connection` with a custom-block finalizer. Mechanical but touches ~40 signatures
  across four modules; it deserves its own change with its own review.
- **GAP-20..GAP-31 widget additions** (window state, geometry, tooltips, focus, key sequences,
  `QActionGroup`, `QShortcut`, …) are individually small and can be batched freely.

---

## 7. Build and packaging

### [x] BUILD-1 `discover.ml` accepts an MSYS2 prefix on directory existence alone
`config/discover.ml:19-27` — `<prefix>/include` exists on **every** MSYS2 install, with or without
Qt. Result: bogus `-I` flags and a cryptic `QtCore/QObject: No such file or directory` instead of
the good message at `:141-145`. `run.ps1:19-25` and `run.bat:4-5` *cause* this by setting `QTDIR`
the same way.

**Fix:** probe `<prefix>/include/QtWidgets/QWidget` (or `include/qt6/QtWidgets`).

### [x] BUILD-2 No compiler/toolchain cross-check
`config/discover.ml:33` hardcodes the `C:\Qt` toolchain order with no reference to `is_msvc`
(computed at `:71`), and MSYS2 candidates are probed first. An MSVC/DkML OCaml with MSYS2 Qt
installed gets `"/LIBPATH:C:\msys64\ucrt64\lib" "Qt6Widgets.lib"` — MinGW import libs requested
with MSVC syntax: guaranteed link failure. Same in reverse.

### [x] BUILD-3 Can select a Qt 5 prefix on macOS
`config/discover.ml:44-51` — `/opt/homebrew/opt/qt` and `/usr/local/opt/qt` are the Homebrew
**Qt 5** formulae. Discovery succeeds, then links `-lQt6Widgets`.

### [x] BUILD-4 `Qt6_DIR` and a wrong `QTDIR` are silently discarded
`config/discover.ml:107-112` — `Qt6_DIR` conventionally points at `…/lib/cmake/Qt6`, which has no
`include` subdir, so the guard at `:112` fails and the setting is ignored with no diagnostic.

### [x] BUILD-5 Env override requires *both* variables
`config/discover.ml:96-101` — setting only `CAMLQT6_CFLAGS` (or only `CAMLQT6_LIBS`) silently
reverts to discovery.

### [x] BUILD-6 `split_ws` breaks on paths with spaces
`config/discover.ml:3-6` — splits on `' '` only, so
`CAMLQT6_CFLAGS="-I/C:/Program Files/Qt/…/include"` is shredded into nonsense.

### [x] BUILD-7 No `qmake6 -query` fallback
`config/discover.ml` — no `qmake`/`qmake6` reference anywhere. A Qt install without `.pc` files
(official Linux installer, `aqt`, Homebrew without pkgconfig) has no discovery path.

### [x] BUILD-8 C++ standard hardcoded to C++17, contradicting the docs
`config/discover.ml:73-80` — no override hook, while `examples/kitchen_sink.ml:149` advertises
"direct **C++20** FFI". The demo is wrong; pick one.

### [x] BUILD-9 Discovery output is cached against the environment
`src/dune:1-6` — no `(deps (env …))`, so `cxxflags.sexp` / `clibs.sexp` are cached. Changing
`QTDIR` or `CAMLQT6_CFLAGS` does nothing until `dune clean`. Classic footgun.

### [x] ~~BUILD-15 `(libraries threads)` is dead weight~~ **WITHDRAWN — it is required**
Originally claimed `src/dune:11` was a no-op placeholder in OCaml 5 and should be removed.

**Withdrawn by test.** Removing it fails at link time on the verified toolchain (OCaml 5.3.0,
dune 3.20.2, MinGW):

```
** Cannot resolve symbols for descriptor object: caml_c_thread_register
Error: Error during linking (exit code 2)
```

`caml_c_thread_register` — used by `CamlDomainLockGuard` to register foreign threads — resolves
from the `threads` library here. The stanza is retained with a comment explaining why, so the next
person does not repeat the experiment.

### [ ] BUILD-10 OCaml version constraint is 5.0.0, not 5.5+
`dune-project`, `camlqt6.opam`, `README.md:63`. **Left as-is deliberately**: the verified toolchain
here is OCaml **5.3.0**, so raising the floor to 5.5 would make the package uninstallable on the
machine it is being developed on. Raise it when the project actually requires 5.5 features, or
leave it at 5.0 — the code uses nothing newer than 5.0.

### [x] BUILD-11 `dune-project` package stanza is missing every release field
`dune-project:5-12` — no `authors`, `maintainers`, `license`, `homepage`, `bug-reports`, `doc`,
`dirs`. `opam lint` fails; not publishable.

### [x] BUILD-12 No `conf-qt6` or `pkg-config` in `depends`
`dune-project:9-12`, `camlqt6.opam:7-12` — Qt appears only in `depexts`, which opam silently
ignores when the filter does not match.

### [x] BUILD-13 No warning policy
`dune-project` — no `(env …)` stanza, so no `-warn-error` and no `dune fmt`; `.ocamlformat` is absent
and there is no `(using fmt …)`.

### [x] BUILD-14 depexts filters are unreliable
`camlqt6.opam.template:1-10` / `camlqt6.opam:27-36`
- `{os-distribution = "debian"}` misses Mint / Pop!_OS / Kali — use `os-family = "debian"`.
- No `{os = "macos"}` entry for a Homebrew-from-`opam-init` user.
- No MSVC / official-installer Windows entry, despite MSVC being the documented recommendation.
- Only the `ucrt64` MSYS2 package name is listed; `mingw64` is not.

### [x] ~~BUILD-15 `(libraries threads)` is dead weight~~ **WITHDRAWN — see the withdrawal note in §7**

### [x] BUILD-16 All 7 demos build in `@default`
`examples/dune:2` — was `byte` and `exe`, so 14 binaries on every `dune build`.

**Half-fixed, deliberately.** `examples/dune` now sets `(modes exe)`, halving the binaries. The
demos stay in `@default` on purpose: they compile against the public API only, and that is how the
Wave 2 `MessageBox` and `selection_model` signature changes were validated. Gating them behind an
alias would silently lose that check. Move them out of `@default` only if build time actually
becomes a problem.

### [x] BUILD-17 `run.bat` skips the `.exe` suffix for `examples/` targets
`run.bat:13` — `goto run` jumps **past** the append at `:16`, so `run.bat examples/hello` (no
extension) fails. `run.ps1:11-16` handles both correctly.

### [x] BUILD-18 `run.bat:4-5` / `run.ps1:19-25` trigger BUILD-1
Both set `QTDIR` when a `bin` directory merely exists.

### [x] BUILD-19 `run.ps1` hardcodes `%LOCALAPPDATA%\opam\default\bin`
`run.ps1:31-34`, `run.bat:8` — wrong for any non-default switch or a relocated `OPAMROOT`.

### [x] BUILD-20 `run.ps1` has no `dune`-on-PATH check and no `Set-Location $PSScriptRoot`
`run.ps1:36-37` — only works when invoked from the repo root.

### [x] BUILD-21 `bundle_windows.ps1` cannot target `name.exe`
`scripts/bundle_windows.ps1:12-14` — guard is `-notlike "*.*"` rather than "contains no path
separator", so `.\bundle_windows.ps1 hello.exe` fails at `:48`. `run.ps1` gets this right.

### [x] BUILD-22 `bundle_windows.ps1` cannot deploy an official Qt install
`scripts/bundle_windows.ps1:25-33` — supports only `QTDIR` and MSYS2 `ucrt64`/`mingw64`, not
`C:\Qt\<ver>\msvc2022_64` (which `discover.ml:29-43` supports and the docs advertise), and not
`clang64`.

### [x] BUILD-23 `bundle_windows.ps1` never checks `windeployqt`'s exit code
`scripts/bundle_windows.ps1:63` — `$ErrorActionPreference` does not apply to native exes, so a
partial deploy is reported as success at `:75`.

### [x] BUILD-24 `bundle_windows.ps1` bundles only the exe
`scripts/bundle_windows.ps1:46`, `:58` — nothing copies `dllcamlqt6_stubs.dll`. Safe only because
the native exe links `libcamlqt6_stubs.a`; a bytecode target would produce a broken bundle. No
check of which mode was built.

### [x] BUILD-25 `.gitignore` is ad hoc
`.gitignore:6` `*.sexp` is over-broad; `:8-11` are debugging debris; `_opam/` and `*.opam.lock`
are missing.

### [x] BUILD-26 `config/dune` builds `discover` in both modes
Byte mode is dead weight; `(modes exe)` would do.

---

## 8. Tests

### [x] TEST-1 Bare `assert` suite with no `-noassert` protection - **premise corrected by test**
`test/test_camlqt6.ml` was one monolithic `let ()` with 188 bare `assert`s and no harness.

**Shipped.** Replaced with `test/harness.ml` plus a rewritten suite: named tests, per-test
isolation, a failure count, and an explicit `exit 1`. Verified by injecting deliberate faults
(wrong value, and a non-raising `check_raises_any`) - each was named with actual-vs-expected, the
other 193 checks still ran, and the process exited 1.

**Correction - the `-noassert` premise was wrong for OCaml 5.** The original claim was that a
release build would silently neuter all 188 assertions. Tested on the verified toolchain (OCaml
5.3.0): `ocamlopt -noassert` still compiles `assert false` into a raising `Assert_failure`,
despite `-noassert` being documented as "Do not compile assertion checks". It is a no-op there.
So the risk was overstated for an OCaml-5-only library - though it remains real on any compiler
where the flag works.

The harness therefore no longer tries to detect `-noassert`. It instead self-tests the mechanism
the suite relies on - that a raising check is actually observed as a failure
(`Harness.check_harness_sanity`) - which is the property that would silently invalidate every
check if it broke. The suite now contains no bare `assert` at all.
### [x] TEST-2 Test numbering is wrong
43 numbered blocks; `15` appears **twice** (`:166` "Test QDialog" and `:617` "Test memory model"),
and `34` is missing (`:463` is `33`, `:529` is `35`).

### [x] TEST-3 The three headline features have no real assertions
- `TableModel`'s `~data` / `~header_data` closures are never observed (`:271-286`).
- DSL two-way binding is never observed — `:517-527` only re-reads the `State.t`, never the widget,
  and it could not anyway since `bind_ui` pushes through `run_on_ui_thread` asynchronously.
- `Dsl.cond`'s page swap is never asserted (`:501-503` builds it, `:523` sets the state, nothing checks).

### [~] TEST-4 No memory-model tests at all — **coverage added, harness still missing**
No `Gc.compact`, no allocation loop, no `Obj.reachable_words` / `Gc.quick_stat`, no call on a
destroyed handle to assert the `Failure` from `camlqt6_stubs.h:86`. For a library whose entire
selling point is `QPointer`-based lifetime safety, this is the largest coverage hole.

> **Covered in Waves 2 and 4.** `test/test_camlqt6.ml` now asserts that:
> - calling a method on a destroyed handle raises `Failure` rather than crashing;
> - `Object.delete` on a Qt-owned object raises `Invalid_argument` and invalidates the handle
>   instead of double-freeing (uses `MainWindow.status_bar`);
> - 60 parented widgets with children survive `Gc.full_major ()` + `Gc.compact ()` and are still
>   valid afterwards (`test_gc_survival`).
>
> Still missing: leak *detection* — nothing measures RSS or `Gc.quick_stat` deltas over an
> allocation loop, so a slow leak would not be caught. That needs a long-running test outside the
> normal suite.

### [x] TEST-5 Assertions inside Qt signal callbacks
`test/test_camlqt6.ml:239`, `:246` — a failure throws through C++ rather than failing the test cleanly.

### [x] TEST-6 Tautological signal assertions
`test/test_camlqt6.ml:52` + `:613-614` — `text_changed_fired` / `received_text` are set **before**
`App.exec` (`:607`), so they do not test signal delivery through the event loop at all.

### [x] TEST-7 Platform-fragile assertion with no watchdog
`test/test_camlqt6.ml:615` — `assert (!paint_count > 0)` depends on the offscreen plugin delivering
a paint event. If the timer at `:599` never fires, `App.exec` hangs forever instead of failing.

### [x] TEST-8 Listener-order-coupled assertion
`test/test_camlqt6.ml:660-674` — asserts `!log = [20; 10]`; breaks as soon as a second subscriber is
added (see DSL-4).

### [x] TEST-9 `App.post_task` is never called
`test/test_camlqt6.ml:676` — the comment claims "App.post_task and App.run_on_ui_thread" but only
`run_on_ui_thread` is called (`:686`). `:678-679` / `:687-688` write plain `ref`s across domains
with no synchronisation. `process_events` runs *after* `Domain.join` (`:691`), so only
"join then drain" is proven.

### [x] TEST-10 Untested API surface
`Icon.from_theme` (zero coverage anywhere, including examples), `App.process_events_wait`,
`Clipboard` URL round-trip, all memory-model error paths, `MimeData.urls` through `Clipboard`.

### [x] TEST-11 `Pixmap` allocated per paint event
`test/test_camlqt6.ml:226-228` inside `on_paint`; the pattern is copied into
`examples/workbench_demo.ml:103-106`.

### [x] TEST-12 No `QT_QPA_PLATFORM=offscreen` in `test/dune`
Relies on `-platform offscreen` in argv (`test_camlqt6.ml:7`), which does not apply to anything Qt
reads from the environment. On a box with no offscreen plugin you get a Qt abort with no hint.

### [x] TEST-13 The new polygon primitives were never actually executed
Found during the Wave 6 test commit, not during Wave 5. The graphics test created its window but
never showed it, and Qt delivers no paint events to an unshown widget, so the whole drawing body
skipped. Showing the window and driving the loop directly exposed two latent faults that had shipped
in `504fbc4`:

- `read_points_i` / `read_points_f` opened a local-roots frame with `CAMLparam`/`CAMLlocal` and
  returned with a plain `}`, with no `CAMLreturn`/`CAMLdrop`. Unbalanced frames corrupt the caller.
  Fixed in `f481458`: the helpers allocate only through Qt's allocator, so they need no frame.
- Both callers did `Field(v_points, 0)` before walking the list. `[]` is an immediate, so
  `Painter.draw_polyline painter []` read address 8 and faulted. Fixed in `f481458` by passing the
  list straight through, which is also what the helper already expected.

The lesson generalises: an `on_paint` body is only tested once something actually paints. Any
future test that constructs a canvas must show the window, or it is asserting nothing about the
drawing code.

### [x] TEST-14 `Icon.is_null` was used as a "the file loaded" check, and is wrong on Linux
Found by the first Linux CI run, not locally. `test_camlqt6.ml` asserted that `Icon.from_file` on a
missing path returns a null icon. That holds on Windows and fails on Linux, where Qt constructs a
loader engine entry for any filename and reports `isNull() == false`. The test had been green on the
author's Windows machine and would have been red for every Linux user.

This was an API bug, not just a test bug: `Icon.is_null` is the obvious way to check whether an
icon path is valid, and it silently gives the wrong answer on Linux. Added
`Icon.available_sizes : t -> (int * int) list`, which is empty when nothing loaded on both
platforms, documented the `is_null` caveat in `gui.mli`, and changed the test to assert
`available_sizes = []` for the missing file and `available_sizes <> []` for the one that loaded.

The general lesson, alongside TEST-13: a suite that only ever ran on one operating system is not a
green suite, it is a single-platform suite. Two of the first three CI failures were platform
assumptions in tests rather than defects in the library.

---

## 9. Breaking changes requiring a decision

Three fixes are API breaks. They are worth doing, but they are versioned decisions, not drive-by
edits.

### 9.1 Return types
- `TableView.selection_model` / `TreeView.selection_model` / `ListView.selection_model` →
  `option` (required by CRIT-1).
- `Color.name` → raise on invalid, or return `option`.
- `MessageBox.information` / `warning` / `critical` → return the button (required by BEH-4);
  `question` → return a 3-way answer (BEH-5).
- `Dialog.exec` → return a typed `[ `Accepted | `Rejected ]`.
- `ListView.on_clicked` → unify arity with the other views (BEH-10).

Recommendation: do all of these, bump to `0.2.0`, and note them in a CHANGELOG.

### 9.2 `Core.cast` removal (HIGH-1)
Removing `Core.cast` from `core.mli` breaks any user who used it — but since it is an unsound escape
hatch that defeats the library's central design claim, and the library is `0.1.0` and unpublished,
removing it now is clearly right. Implementation: keep an internal `Core.unsafe_cast` exposed only
through a `private` module or a functor so `Widgets`/`Gui`/`Dsl` can still use it internally.

### 9.3 `State` equality (DSL-1)
Making equality explicit is a breaking change to `State.create`. Alternative that is
non-breaking: keep `<>` as the default but add `State.create ~eq`, and document the caveat.

---

## 10. Docs

### [x] DOC-1 Cross-doc links were absolute `file:///home/<user>/...` paths
`README.md:27-28`, `:185-188`; `ROADMAP.md:96`, `:113`, `:139`, `:160`;
`docs/ARCHITECTURE.md:27-28`, `:96-100`, `:141`. Broken for every reader.
**Resolved:** all cross-doc links are now repository-relative
(`docs/ARCHITECTURE.md`, `ROADMAP.md`, ...), verified by grepping for links
targeting `/`, `file:` or a drive letter. The machine-specific path is no
longer in the document.

### [x] DOC-2 The test count is stated three different ways
Badge "39/39" (`README.md:5`), "34-case test suite" (`README.md:77`), "34-case" again
(`docs/WINDOWS_TESTING.md:108`). Actual: 43.

### [ ] DOC-3 Naming is inconsistent: `CamlQt6` vs `OQt6`
Doc comments still say **OQt6** (`src/camlqt6.mli:1-4`, `src/dsl.mli:1`), and every C++ error string
says `"Oqt6: ..."`. Also `QCanvas`/`qcanvas` in OCaml vs `OCamlCanvas` in C++
(`widgets.mli:29`, `camlqt6_stubs.cpp:310`).

### [ ] DOC-4 `ARCHITECTURE.md` documents a `CamlDomainLockGuard` that is not the real one
`docs/ARCHITECTURE.md:73-91` vs `src/camlqt6_stubs.h:61-80`. The documented version increments depth
outside the `if`, so a nested guard misbehaves; the real one increments inside. Fix the doc to match
the (correct) implementation.

### [ ] DOC-5 `ARCHITECTURE.md` presents polymorphic `<>` as a soundness mechanism
`docs/ARCHITECTURE.md:194-198` — "oscillation-free bidirectional data binding" with no mention that the
mechanism is polymorphic compare. See DSL-1.

### [ ] DOC-6 The "C++20" claim contradicts the build
`examples/kitchen_sink.ml:149` vs `config/discover.ml:73-80`.

### [ ] DOC-7 `ROADMAP.md` contradicts itself and the shipped state
`ROADMAP.md:41` still describes the unbuilt Clang generator pipeline; the Phase 4 title
(`ROADMAP.md:117`) is "Clang / Metadata Generator Pipeline" while `README.md:52-56` claims
"No Generator Dependencies".

### [ ] DOC-8 `ROADMAP.md` Phase 3 marks "Sorting" complete
`ROADMAP.md:104` — but `TableModel` has no `sort` (BEH-1).

### [ ] DOC-9 `README.md` overstates `QPainter` coverage
`README.md:21`, `:40` — "Full `QPainter` support", "Full `QPainter` support (lines, shapes, text,
affine transforms, pixmap blitting)". No render hints, no clipping, no opacity, ~12 missing
primitives (GAP-8 … GAP-14).

### [x] DOC-10 `README.md` overstates model/view coverage
`README.md:20`, `:39` — "Zero-Copy Functional Model/View … into `QTableView`, `QTreeView`, and
`QListView` with zero C++ data duplication". `TreeView` cannot use `TableModel` at all (GAP-1), and
`ListView` has no functional model.

### [x] DOC-11 `README.md` overstates multicore safety
`README.md:17`, `:42` — "Multicore Safety … coordinates safely with OCaml 5 runtime domains". See
THR-1, THR-2.

### [x] DOC-12 README badge links are empty
`README.md:5-6` — `[![Build & Test](...)]()` and a LICENSE badge pointing at `LICENSE`, which does
not exist in the repo despite `README.md:194` claiming MIT.

---

## Appendix A — verified enum encodings

**These are correct. Do not spend effort here.** (Audited against Qt 6.)

| Encoding | C++ lines | Verdict |
| :--- | :--- | :--- |
| `Qt::Orientation` | `:1579`, `:1629`, `:3459`, `:3476` | correct (uses named constants; OCaml `0/1` → `widgets.ml:3-5`). Silent-fallback issue only → HIGH-6 |
| `Qt::CursorShape` | `:3237-3258`, used `:4030` | correct, all 17 shapes |
| `Qt::DockWidgetArea` | `:3260-3268`, used `:3744` | correct |
| `Qt::SelectionBehavior` | `:2887`, `:3007`, `:3096` | values correct; unvalidated raw cast → HIGH-7 |
| `Qt::SelectionMode` | `:2894`, `:3014`, `:3103` | values correct; unvalidated raw cast → HIGH-7 |
| `QHeaderView::ResizeMode` | `:3148`, `:3155` | correct — Qt 6 is `Interactive=0, Stretch=1, Fixed=2, ResizeToContents=3`, exactly `widgets.ml:22-26` |
| `Qt::PenStyle` | `:2406-2412`, `:2431-2436` | correct; CamlQt6 uses its own `0..3` encoding mapped symbolically. Only 4 of 6 styles exposed → GAP-17 |
| `Qt::BrushStyle` | `:2449-2452`, `:2465-2466` | correct for the 2 exposed values; all other ints collapse to `NoBrush` → BEH-9 |
| `Qt::DropActions` / `Qt::DropAction` | `:4233-4248` | correct; `gui.ml:246-256` agrees with the C++ mapping |
| `QClipboard::Mode` | `:4260-4368` | correct; `gui.ml:270-273` |
| `QMessageBox::StandardButton` | `:2164-2221` | **not parameterised at all**; result discarded → BEH-4, BEH-5 |
| `QDialog::DialogCode` | `:2132` | **raw int leaked to OCaml** → BEH-6 |
| `QFileDialog::FileMode` | `:2226-2292` | **not exposed**; static helpers only |

Also verified correct, for the record: `caml_oqt6_qdrag_mime_data`'s null check returning
`Val_int(0)` = `None` (`:4207-4209`), and the ~20 `CAMLreturn(Val_int(0))`-as-`None` sites
(`:2240`, `:2263`, `:2285`, `:3764`, `:3786`, `:3809`, `:3837`, `:3873`, `:3944`, `:4059`, `:4122`,
`:4160`, `:4258`, `:4267`, `:4294`, `:4303`, `:4328`, `:4337`).

The bug at CRIT-1 is that `alloc_qobject` returns `Val_unit` (`1`) for a custom type — a *different*
immediate from `Val_int(0)` — so the two are distinguishable in principle but not by the runtime.

---

## Appendix B — what is already solid

Worth recording so these are not "fixed" by accident:

- The `QPointer` + `owned` design (`camlqt6_stubs.h:38-41`, `camlqt6_stubs.cpp:112-124`) is the
  right shape; it just needs its flags honoured (CRIT-2) and its accessors validated (CRIT-3).
- `connect_root_cleanup` (`camlqt6_stubs.cpp:129-135`) correctly relies on `QObject::destroyed`
  firing its lambda *after* the user callback's lambda (QObject invokes slots in connection order),
  so `caml_remove_global_root` happens after `caml_callback_exn` returns. Subtle and correct.
- `~OCamlCanvas` correctly acquires the runtime system before touching global roots (`:326`).
  `~OCamlTableModel` does not (CRIT-4).
- Painter lifetime is handled properly: `alloc_painter` (`:295`), null-out after the callback
  (`:358`), and `get_painter` raising on use-after-scope (`:301-307`).
- `caml_oqt6_qobject_is_valid` (`:639-643`) and the `get_qobject` null check
  (`camlqt6_stubs.h:85-87`) mean destroyed-object use raises rather than segfaults — the right
  behaviour, and it is what TEST-4 should be exercising.
- `OCamlUiDispatcher` / `OCamlTaskEvent` (`:767-807`) is a sound post-to-Qt-thread mechanism with
  correct root lifetime handling on both the delivered and undelivered paths.
- The typed-variant + labeled-argument API surface is genuinely idiomatic; the enum table in
  Appendix A is clean.
- `examples/` use only the public `CamlQt6` API and none of them call `Object.delete`.
