## [3.9.9] - 2026-08-02

### Changed
- Refresh Swift package locks, AXorcist, Tachikoma, and the pnpm toolchain to their latest compatible releases.

### Fixed
- OpenAI OAuth (ChatGPT login) sessions with an expired access token but valid refresh token are no longer reported unavailable; vision/`--analyze` now routes through the Codex Responses OAuth transport. Thanks @scotthuang for #293.
- MCP shell commands now support an opt-in timeout that safely terminates the launch-owned process group and bounds pipe draining without changing the legacy unlimited default. Thanks @SebTardif for #298.
- Publish the Ollama provider guides referenced throughout the generated documentation instead of emitting broken links.
- Refresh Screen Recording and Event Synthesizing grants in the Mac app's permissions checklist without requiring an app restart.
