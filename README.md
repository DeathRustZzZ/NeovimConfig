# Neovim config: Arch Linux + macOS

Один конфиг и одна основная ветка `main` используются на Arch Linux и MacBook Air.
Операционная система определяется автоматически в Lua; отдельные постоянные ветки для
каждой машины не нужны.

## Установка

```bash
git clone https://github.com/DeathRustZzZ/NeovimConfig ~/.config/nvim
nvim
```

При первом запуске `lazy.nvim` установит плагины согласно `lazy-lock.json`.
После старта Mason автоматически проверит обязательные CLI-инструменты, а Treesitter
установит парсеры для настроенных языков. После первой установки инструментов перезапустите
Neovim один раз.

### Arch Linux

```bash
sudo pacman -S neovim git ripgrep fd lazygit base-devel
```

Автоматическое переключение US/RU раскладки работает в KDE через `qdbus6` и
`kreadconfig6`, если они доступны в системе.

### macOS (Apple Silicon)

```bash
xcode-select --install
brew install neovim git ripgrep fd lazygit translate-shell
```

Путь Apple Silicon Homebrew (`/opt/homebrew/bin`) добавляется в Neovim автоматически,
включая запуск из GUI-клиента. Для автоматического переключения раскладки установите
опциональный `im-select`:

```bash
brew tap daipeihust/tap
brew install im-select
```

Подробности о US ANSI-клавиатуре, Option/Meta и необходимых инструментах находятся в
[`MACOS_M1_MIGRATION.md`](MACOS_M1_MIGRATION.md). Полный список сочетаний — в
[`KEYMAPS_GUIDE.md`](KEYMAPS_GUIDE.md).

## Как разделены настройки

- `lua/config/platform.lua` — определение ОС, PATH и системное открытие URL;
- `lua/config/input_method.lua` — macOS `im-select` и Arch/KDE D-Bus backends;
- остальные options, mappings и plugin specs общие для обеих систем;
- `lazy-lock.json` фиксирует одинаковые версии плагинов на обеих машинах.

Обновление на любой машине выполняется одинаково:

```bash
cd ~/.config/nvim
git pull --ff-only
```

Фоновая проверка новых версий плагинов выключена. Разово включить её можно так:

```bash
NVIM_PLUGIN_CHECK=1 nvim
```

## Проверка изменений

```bash
nvim --headless -u init.lua +qa
nvim -n --headless -u NONE -l scripts/check-keymaps.lua
nvim --headless -u NONE -l scripts/check-plugins.lua
```

Для диагностики окружения используйте `:checkhealth config` (зависимости этого конфига)
и общий `:checkhealth`. Python, Ruby, Perl и Node remote
providers намеренно отключены: плагины этого конфига работают с CLI напрямую и не требуют их.
