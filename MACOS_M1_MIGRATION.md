# Перенос моего Neovim-конфига с Arch Linux на macOS M1

Этот конфиг рассчитан на Neovim 0.12+ и переносится на Mac почти без переделок. Основной путь конфига такой же:

```bash
~/.config/nvim
```

## 1. Что перенести

На Arch у тебя уже есть этот каталог:

```bash
~/.config/nvim
```

На Mac нужно перенести его целиком, включая:

- `init.lua`
- `lua/`
- `lazy-lock.json`
- `KEYMAPS_GUIDE.md`

`startup.log` и `.nvimlog` переносить не нужно.

Самый простой способ:

```bash
scp -r ~/.config/nvim user@macbook:~/.config/
```

Или через git, если этот конфиг хранится в репозитории.

## 2. Что установить на macOS

Если Homebrew еще не установлен:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Дальше поставить базу:

```bash
brew install neovim git ripgrep fd lazygit make
```

Что из этого нужно:

- `neovim` нужен обязательно
- `git` нужен обязательно, потому что `lazy.nvim` ставится через `git clone`
- `ripgrep` нужен для `Telescope live_grep`
- `fd` полезен для быстрого поиска файлов
- `make` нужен для сборки `telescope-fzf-native.nvim`
- `lazygit` нужен только для хоткея `<leader>gg`

## 3. Шрифт

В конфиге для GUI задан:

```lua
vim.opt.guifont = "JetBrainsMono Nerd Font:h12"
```

Поэтому на Mac желательно поставить Nerd Font:

```bash
brew install --cask font-jetbrains-mono-nerd-font
```

Если используешь терминал, а не GUI-клиент Neovim, тоже лучше выбрать этот шрифт в настройках терминала.

## 4. Rust-окружение для этого конфига

У тебя конфиг сильно завязан на Rust:

- `rustaceanvim`
- `rust-analyzer`
- `rustfmt`
- `clippy`
- `codelldb`

Rust-тесты используют адаптер из `rustaceanvim`, отдельный `neotest-rust` не нужен. `rust-analyzer` лучше устанавливать через `rustup`, чтобы его версия соответствовала Rust toolchain:

Поставь `rustup`:

```bash
brew install rustup-init
rustup-init
source ~/.cargo/env
rustup component add rustfmt clippy
rustup component add rust-analyzer
```

После этого внутри Neovim можно открыть:

```vim
:Mason
```

И установить/проверить остальные инструменты:

- `codelldb`
- `taplo`
- `stylua`
- `lua_ls`

`codelldb` и CLI-инструменты описаны в `mason-tool-installer.nvim`, а LSP-серверы — в `mason-lspconfig.nvim`.

## 5. Опциональные утилиты

Некоторые хоткеи зависят от внешних программ:

- `trans` для перевода слова/строки (`translate-shell`)
- `rustowl` для Rust ownership hints

Если они не установлены, конфиг не сломается, просто часть функций не будет работать.

Для `translate-shell`:

```bash
brew install translate-shell
```

## 6. Куда macOS складывает данные Neovim

Сам конфиг лежит в:

```bash
~/.config/nvim
```

Но плагины, кеш и состояние на macOS обычно лежат отдельно:

- `~/Library/Application Support/nvim`
- `~/Library/Caches/nvim`
- `~/Library/State/nvim`

Обычно переносить их не нужно. Достаточно перенести конфиг и дать `lazy.nvim` заново скачать плагины.

Если хочешь полностью чистый старт на Mac, можно просто удалить старые данные Neovim перед первым запуском:

```bash
rm -rf ~/Library/Application\ Support/nvim
rm -rf ~/Library/Caches/nvim
rm -rf ~/Library/State/nvim
```

## 7. Первый запуск на Mac

После копирования конфига:

```bash
nvim
```

При первом запуске:

- `lazy.nvim` сам поставится через `git`
- плагины подтянутся по `lazy-lock.json`
- `Treesitter` может начать докачивать парсеры

Потом проверь:

```vim
:checkhealth
:Lazy
:Mason
:MasonToolsInstall
```

## 8. Возможные отличия на macOS

### Открытие ссылок

В одном месте конфиг использует fallback через `xdg-open`. На macOS аналогичная команда:

```bash
open
```

Но чаще это не понадобится, потому что сначала вызывается `vim.ui.open`.

Если заметишь, что открытие `docs.rs` не работает, замени в конфиге `xdg-open` на `open`.

### Clipboard

На macOS системный буфер обмена обычно работает из коробки лучше, чем на Linux. Строка:

```lua
vim.opt.clipboard = "unnamedplus"
```

обычно будет работать без дополнительной настройки.

## 9. Короткий чеклист

1. Скопировать `~/.config/nvim` на Mac.
2. Установить Homebrew.
3. Поставить `neovim git ripgrep fd lazygit make`.
4. Поставить `JetBrainsMono Nerd Font`.
5. Поставить `rustup`, затем `rustfmt`, `clippy` и `rust-analyzer`.
6. Запустить `nvim`.
7. Проверить `:checkhealth`, `:Lazy`, `:Mason`.

## 10. Команды одним блоком

```bash
brew install neovim git ripgrep fd lazygit make rustup-init translate-shell
rustup-init
source ~/.cargo/env
rustup component add rustfmt clippy rust-analyzer
mkdir -p ~/.config
```

Потом просто скопируй сюда свой конфиг:

```bash
~/.config/nvim
```

Если хочешь, я могу следующим сообщением еще сделать отдельный короткий `README`-вариант на 10-15 строк без лишних пояснений.
