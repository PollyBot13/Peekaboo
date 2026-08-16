### Added
- Add Bridge protocol 1.29 peer-bound signed operation sessions and exact target/result receipts, with bounded rollover, replay protection, and fail-closed recovery for long-running background automation.
- Make protocol 1.29 browser receipts require a fully resolved explicit DevTools endpoint, and make exact dialog text entry use background Accessibility value mutation while refusing receipt-incapable legacy dialog mutations before dispatch.
- Add Bridge protocol 1.26 exact browser connection receipts, binding persistent Chrome DevTools MCP sessions to one process generation or validated loopback DevTools browser identity.
- Add Bridge protocol 1.25 one-shot dialog receipts that uniquely bind an exact process/window, raw dialog or sheet, and semantic AXPress button for background click/dismiss, with read-only targeted listing and canonical postcondition outcomes.
- Add a background-first native Bridge host runtime for signed macOS apps, with explicit caller allowlists, shared mutation/snapshot state, checked lifecycle, and no Core, provider, browser, daemon, or AppleScript surface.
- Add capability-gated exact-window background wheel delivery for opaque WKWebView/Tauri scroll targets, preserving the foreground app and physical cursor while refusing hidden, stale, Electron, Chromium, Catalyst, or AX-only routes.
### Changed
- Build branded release disk images from pinned direct Finder-metadata tooling, preserving the signed and notarized drag-to-Applications layout without GUI automation.
### Fixed
- Require explicit foreground consent for Space switching and followed window moves across CLI and MCP, and compose their native move/switch receipts without synthesizing success or dispatch counts.
- Establish and verify a window's destination Space before removing prior memberships, and retain its exact generation-bound identity through Space-aware focus.
- Let later exact maximize readbacks supersede transient poll errors while preserving cancellation and identity contradictions, and route idempotent no-change receipts by the actual execution host.
- Return canonical retry-safe pre-dispatch refusals when window owner-generation or bounds-provenance evidence does not match the selected mutation target.
- Bind protocol 1.29 window and frontmost capture receipts to the exact captured process/window, reject missing or contradictory target metadata, and keep screen/area captures explicitly global.
- Keep root help and version order-independent across canonical kebab- and camel-case runtime-option aliases while preserving correct missing-value errors.
- Treat `capture video` as caller-local media ingestion so valid files and typed media failures bypass Screen Recording and ScreenCaptureKit-owner preflight while live capture remains gated.
- Refuse exact-window and dialog Accessibility reads when macOS cannot arm their per-element messaging deadline, and surface timeout reset failures instead of continuing unbounded.
- Treat Finder's role-inapplicable `AXWindow` value failure as sparse descriptor data so normal exact-window combined observations retain usable Accessibility elements, while every other hard AX read and genuinely incomplete window remains fail-closed.
- Refuse exact-window combined observations when Accessibility returns no usable elements, preserving the requested raster and retry-safe `ACCESSIBILITY_INCOMPLETE` semantics across current and legacy Bridge hosts while explicit screenshot-only capture remains successful.
- Validate request-only `click`, `move`, `type`, and `drag` arguments before runtime-host selection so malformed requests cannot be masked by Bridge availability or trigger unnecessary host startup.
- Keep concrete interaction snapshots out of ScreenCaptureKit-owner preflight because they cannot refresh or capture, and give omitted/latest snapshot flows an actionable `see --capture-engine classic` recovery.
- Add Bridge protocol 1.26 explicit-reference-only coordinate receipts for exact-window `see --no-elements`, making the documented background coordinate-click workflow consumable without Accessibility traversal or replacing the prior implicit element snapshot while older hosts fail before receipt allocation.
- Honor cancellation while draining and reaping MCP ShellTool subprocesses so canceled commands cannot linger behind pipe cleanup. Thanks @SebTardif for #454.
- Reject unknown and non-object MCP `tools/call` arguments as JSON-RPC invalid params before policy checks or tool dispatch, recursively honoring the closed schemas advertised by `tools/list`.
- Probe Chrome before reporting browser connection success, reject ambiguous same-channel profiles, preserve structured Bridge failures, never silently rediscover another profile after a session or endpoint is lost, and atomically focus the exact snapshot uid before browser typing or key presses.
- Stage browser uploads from race-checked, current-user regular files into one private per-session Chrome MCP temporary root, without unrestricted filesystem access, and terminate the exact child before cancellation cleanup.
- Classify an exact standard window with a live attached sheet as dialog-active during observation, sharing native role evidence with dialog actions while keeping the parent window receipt exact.
- Report exact ScreenCaptureKit owner PID, process generation, safe build identity, and selected-versus-owner Bridge sockets when available; automatic capture can still use an owner-aware host's classic-only path around an auxiliary legacy owner, while explicit modern and ambiguous legacy ownership remain fail-closed without unsafe process-stop guidance.
- Centralize canonical application/window outcomes across Foundation, services, Bridge, CLI, and MCP while preserving legacy JSON fields and v4.1.0 public APIs, and keep minimize verification exact when retained AX window IDs disappear transiently.
