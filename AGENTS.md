# Repository Guidelines

## Project Structure & Module Organization

This repository is a personal Neovim configuration written in Lua. `init.lua` is the entry point and loads modules from `lua/config/` in order: options, UI settings, Lazy.nvim bootstrap, plugins, autocommands, and keymaps.

- `lua/config/options.lua`: editor defaults and indentation.
- `lua/config/ui.lua`: UI presets and appearance helpers.
- `lua/config/keymaps.lua`: global mappings and small mapping helpers.
- `lua/config/autocmds.lua`: event-based editor behavior.
- `lua/config/plugins.lua`: plugin import list for Lazy.nvim.
- `lua/config/plugins/*.lua`: grouped plugin specs by domain (`ui`, `editor`, `tools`, `lsp_rust`, `debug`).
- `lua/config/snippets/rust.lua`: Rust snippets.
- `lazy-lock.json`: pinned Lazy.nvim plugin versions.
- `KEYMAPS_GUIDE.md` and `MACOS_M1_MIGRATION.md`: user-facing reference notes.

## Build, Test, and Development Commands

- `nvim --headless "+Lazy! sync" +qa`: install or update plugins from `lazy-lock.json`.
- `nvim --headless "+checkhealth" +qa`: run Neovim health checks.
- `nvim --headless -u init.lua +qa`: smoke-test that the config loads without opening the UI.
- `nvim --headless -u NONE -l scripts/check-plugins.lua`: force-load plugin specs and validate commands.
- `nvim .`: run the configuration interactively during development.

There is no separate build system; changes take effect when Neovim starts or the relevant Lua module is reloaded.

## Coding Style & Naming Conventions

Use Lua with 4-space indentation, matching `lua/config/options.lua`. Prefer small local helper functions near their call sites, as in `keymaps.lua`. Module filenames should be lowercase with underscores when needed, and plugin spec files should remain grouped by feature area. Keep keymap descriptions clear; existing descriptions are Russian, so preserve that language unless changing a broader documentation convention.

## Testing Guidelines

No formal test framework is configured. Validate changes with the headless smoke command and, for plugin changes, `:Lazy` inside Neovim. For UI, keymap, or LSP changes, manually verify the affected workflow in an interactive Neovim session. Keep `lazy-lock.json` changes only when plugin versions intentionally change.

## Commit & Pull Request Guidelines

Git history currently contains a single broad commit (`My cfg neovim`), so there is no established convention. Use concise, imperative commit messages such as `Add Rust debug keymaps` or `Update Lazy plugin pins`. Pull requests should describe the affected Neovim behavior, list manual validation commands, and include screenshots only for visible UI/theme changes.

## Agent-Specific Instructions

Keep edits scoped to this configuration. Do not rewrite unrelated plugin groups or regenerate `lazy-lock.json` unless the task specifically requires dependency updates.
