## [4.0.0] - 2026-08-10

Peekaboo 4 is a ground-up cleanup of the command surface: fewer commands, one spelling
per operation, grammars your agent already knows, and honest machine-readable results.
It is a breaking release — see `docs/v4-migration.md` for the complete old→new table.

### Highlights

- **A smaller, sharper CLI.** 40 root commands became exactly 33, and thousands of lines of
  duplicate surface are gone. Everything a stock macOS tool already does well (`sleep`,
  `open`, the `.peekaboo.json` script runner) was removed — Peekaboo now assumes your
  automation runs in a shell and focuses on what only Peekaboo can do.
- **One verb per operation.** `press` absorbs `hotkey` with xdotool chord syntax
  (`press cmd+shift+t`); `drag` absorbs `swipe` with dual-typed `--from`/`--to`
  (element IDs or coordinates); `see` absorbs `image` and `inspect-ui`
  (`--no-elements` for fast screenshots, `--tree` for AX text trees); `perform-action`
  is now simply `action`.
- **`verify` replaces sleep-polling.** Assert window/element predicates with a timeout
  and stability sampling; results are satisfied / unsatisfied / unknown — and unknown
  never implies success.
- **One flag grammar.** Every duration accepts `500`, `500ms`, or `2s` (bare = ms) and
  unit-suffixed flag names are gone; coordinates are `--at x,y` with `--global` for
  screen space; modifiers are comma-separated lists; the focus-flag matrix is identical
  across all interaction commands.
- **Quiet visual feedback.** Fourteen animation types became three feedback categories:
  a natural agent cursor with eased curved motion, a compact input HUD, and thin capture
  borders. Targeted background input stays overlay-free even when its target is visible
  or frontmost; only untargeted or explicitly foreground work may show the cursor or HUD.
  The settings retain a master switch and playback controls around those three categories.
- **Honest results.** Once an action request has been parsed and classified, its JSON
  result reports `effect: confirmed | partial | unverifiable | suspected_noop | refused`,
  and errors carry an actionable `hint`. Argument parse/bind failures happen before that
  classification and may omit `effect`. "The process exited 0" no longer stands in for
  "the click landed."
- **Background-first safety.** Launch, open, observation, capture, and targeted input
  are background by default; focus stealing, global keys, and physical pointer gestures
  require explicit foreground consent. Ambiguous or targetless background operations
  are refused instead of falling through to whatever app happens to be frontmost.

### Added

- `verify` command and `verify_state` stability contracts; `tools describe <name>` for
  on-demand tool schemas.
- `app focus`, positional app targets across app subcommands, `app launch --wait-ready`
  with repeatable `--open` targets; `window restore` (CLI/MCP/Bridge) with
  exact-window receipts; `window` tool `list` action.
- Native exact-window background right/double clicks with owner/generation validation;
  distinct background app instances with WindowServer readiness receipts.
- Recently-automated app icons beside the Peekaboo menu bar item (with settings toggle).

### Changed

- Standardize CLI JSON on one result envelope with an action-only effect vocabulary after
  request parsing/classification, actionable error hints, and nonzero exits for failed
  actions; pre-dispatch parse/bind failures may omit `effect`.
- Management commands restructured into real subcommand trees: `clipboard
  get|set|clear|save|restore`, `menubar list|click`, `config provider …` /
  `config credential set`, `agent run|resume|sessions|chat`,
  `permissions request <kind>`.
- `type` is text-only (plus `--clear`); use `press` for Return/Tab/Escape/Delete.
- Cross-process coordination for concurrent CLI/agent/GUI/daemon desktop operations
  with generation-scoped lanes; strict bridge 1.11 capability gating.
- Clipboard paste is serialized across processes, fails closed without touching the
  pasteboard when unsafe, and restores partial writes.
- Swift Subprocess 1.0.0, pnpm 11.21.0; CI on macOS 26 / Xcode 26.6.

### Removed (breaking)

- Commands: `sleep`, `open`, `run` (+ `.peekaboo.json` format), `commander`, root
  `list`, `image`, `hotkey`, `swipe`, `inspect-ui`, `perform-action`, `capture watch`,
  `menu click-extra`, `menu list-all`, `agent permission`.
- Flags: `--coords`/`--global-coords` (→ `--at`/`--global`), `--id`, `--image-path`,
  `--app-target`, `--timeout-seconds`, `--focus-timeout-seconds`, `--restore-delay-ms`
  and the whole unit-suffixed family, `type --return/--escape/--delete/--tab`,
  clipboard `-a/--action` + `load`, agent mode flags, compound
  `permissions request-*` names.
- MCP surface: `list` tool, `hotkey`/`swipe` tools, agent shims `list_apps` /
  `list_screens` / `launch_app`; `perform_action` renamed `action`; ClipboardTool
  params are snake_case (`file_path`, `data_base64`). MCP keeps screenshot-only
  `image`, AX-only `inspect_ui`, and `sleep` (MCP clients may lack a shell).

### Fixed

- Normalize agent failures and `see` success JSON under the shared result envelope,
  with nonzero terminal failures, specific validation/credential/session/runtime codes,
  and no duplicate inner `success` field.
- Add actionable text and JSON migration hints for removed v4 commands and flags,
  reject ambiguous press input shapes, and align `see`/`type`/`press` help with the
  accepted grammar.
- Stop cancelled on-demand daemon idle timers from rescheduling one another,
  preventing runaway CPU and memory use after repeated Bridge activity.
- Reject conflicting app/PID and window selectors across interaction CLI and MCP
  entry points before focus, observation, or mutation.
- Require explicit `--foreground` for long-press clicks so the shared physical cursor
  cannot be used through an implicit delivery-mode promotion.
- Pin background `press` sequences to one process generation, stop before a recycled
  PID can receive later chords, and report partial delivery as retry-unsafe.
- Keep direct `action` and `set-value` targets in the background by default, including
  web-content discovery, unless `--foreground` is explicit.
- Non-US keyboard layouts preserve requested characters during background typing.
  Thanks @canvascoding for #330.
- Phantom-success accessibility actions are rejected; typed `set-value` results are
  verified against live AX state; app quit/window close verify disappearance before
  reporting success; minimized windows report from live AX state.
- Window mutations bind to immutable capture-time bounds, reject recycled
  CGWindowID/PID generations, and never activate apps or enter full screen from
  background maximize; background `window restore` verifies the same exact window
  reappears with original bounds.
- OpenAI Responses tool errors no longer abort the next agent turn; multi-part native
  tool responses return all content items; tool summaries regain rich detail in agent
  chat and the Mac activity feed.
- ScreenCaptureKit contention routes through a bounded isolated fallback; menu-extra
  selection failures and failed app quits exit nonzero; Dock removal uses native AX.
- Return exact window-sized pixels from automatic and modern ScreenCaptureKit capture
  instead of accepting a display-sized transparent canvas, without continuation-leak
  diagnostics when a quarantined screenshot callback never arrives.
