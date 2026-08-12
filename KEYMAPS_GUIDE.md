# Neovim Keymap Guide (RU)

> Подробный гид по вашему конфигу для человека, который никогда не работал с Vim/Neovim.

---

## 1. Быстрый старт за 3 минуты

### Главная идея Vim
- В Vim есть **режимы**.
- Вы не печатаете текст постоянно: сначала выбираете режим, потом действуете.

### Режимы, которые вам нужны сразу
| Режим | Что делает | Как войти | Как выйти |
|---|---|---|---|
| `Normal` | Навигация, команды, хоткеи | `Esc` | - |
| `Insert` | Ввод текста | `i` | `Esc` или `jk` |
| `Visual` | Выделение текста | `v` | `Esc` |
| `Terminal` | Работа внутри встроенного терминала | открыть терминал | `Ctrl+\` затем `Ctrl+n` |

### Самое важное про ваш конфиг
- `Leader` = `Space` (пробел).
- Запись `<leader>ff` означает: `Space`, потом `f`, потом `f`.
- Ваш быстрый выход из insert-режима: `jk`.

---

## 2. Обозначения клавиш

| Запись | Значение |
|---|---|
| `<leader>` | `Space` |
| `<C-x>` | `Ctrl + x` |
| `<S-Tab>` | `Shift + Tab` |
| `<M-x>` | `Alt + x` (Meta) |
| `n` mode | normal mode |
| `i` mode | insert mode |
| `x` mode | visual mode |
| `t` mode | terminal mode |

---

## 3. Базовые клавиши (каждый день)

| Клавиша | Что делает | Режим |
|---|---|---|
| `<leader>w` | Сохранить файл | `n` |
| `<M-s>` | Сохранить файл (Cmd+S в текущем терминале) | `n` `i` `x` |
| `<leader>q` | Закрыть текущее окно | `n` |
| `jk` | Выйти из insert mode | `i` |
| `<M-h>` `<M-j>` `<M-k>` `<M-l>` | Перейти между окнами (Cmd+H/J/K/L) | `n` |
| `<M-h>` `<M-j>` `<M-k>` `<M-l>` | Перейти между окнами из терминала (Cmd+H/J/K/L) | `t` |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | Перейти между окнами | `n` |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | Перейти между окнами из терминала | `t` |

---

## 4. Диагностика и LSP

### Глобальные diagnostics
| Клавиша | Что делает |
|---|---|
| `<leader>dn` | Следующая диагностика |
| `<leader>dp` | Предыдущая диагностика |
| `<leader>dd` | Диагностика под курсором |

### LSP (когда сервер подключен)
| Клавиша | Что делает |
|---|---|
| `gd` | Перейти к определению |
| `gD` | Перейти к объявлению |
| `gi` | Перейти к реализации |
| `gr` | Показать использования (references) |
| `gy` | Перейти к определению типа |
| `K` | Hover-документация |
| `<leader>uh` | Вкл/выкл inlay hints |
| `<leader>lt` | Запросить LSP hover и открыть его перевод на RU в постоянном окне |
| `<leader>ls` | Символы текущего документа |
| `<leader>lS` | Символы workspace |
| `<leader>lf` | LSP finder: type/reference/implementation/definition (Lspsaga) |
| `<leader>lp` | Peek definition (Lspsaga) |
| `<leader>lP` | Peek type definition (Lspsaga) |
| `<leader>lh` | Hover-документация (Lspsaga) |
| `<leader>la` | Code action (Lspsaga) |
| `<leader>ln` | Rename (Lspsaga) |
| `<leader>lc` | Incoming calls (Lspsaga) |
| `<leader>lC` | Outgoing calls (Lspsaga) |

### Rust-специфично
| Клавиша | Что делает |
|---|---|
| `<leader>rr` | Rust runnables |
| `<leader>rd` | Rust debuggables |

---

## 5. Файлы, поиск, навигация

### Файловое дерево / структура
| Клавиша | Что делает |
|---|---|
| `<leader>e` | Показать/скрыть Neo-tree |
| `<leader>E` | Показать текущий файл в Neo-tree |
| `<leader>o` | Outline (Aerial) |
| `<leader>O` | Навигационное окно Aerial |
| `[o` | Предыдущий символ Aerial |
| `]o` | Следующий символ Aerial |

### Telescope
| Клавиша | Что делает |
|---|---|
| `<leader>ff` | Поиск файлов |
| `<leader>fg` | Поиск текста по проекту (live grep) |
| `<leader>fb` | Список буферов |
| `<leader>fh` | Поиск по help-тегам |

### Быстрые переходы
| Клавиша | Что делает |
|---|---|
| `<leader>jj` | Быстрый jump по экрану (Flash) |
| `<leader>jt` | Jump по syntax-узлам (Flash Treesitter) |
| `<leader>un` | Следующее совпадение символа под курсором |
| `<leader>up` | Предыдущее совпадение символа под курсором |

### Harpoon (избранные файлы)
| Клавиша | Что делает |
|---|---|
| `<leader>ha` | Добавить текущий файл в Harpoon |
| `<leader>hh` | Открыть меню Harpoon |
| `<leader>h1`..`<leader>h4` | Перейти к файлу 1..4 |

---

## 6. Буферы, UI, внешний вид

### Bufferline
| Клавиша | Что делает |
|---|---|
| `<leader>bp` | Предыдущий буфер |
| `<leader>bn` | Следующий буфер |
| `<leader>bd` | Закрыть буфер |
| `<leader>bP` | Закрепить/открепить буфер |

### UI presets
| Клавиша | Что делает |
|---|---|
| `<leader>ut` | Переключить пресет по кругу |
| `<leader>u1` | Пресет `glass` |
| `<leader>u2` | Пресет `solid` |
| `<leader>u3` | Пресет `high_contrast` |

---

## 7. Git и код-ревью

### Основной Git UI
| Клавиша | Что делает |
|---|---|
| `<leader>gg` | Открыть LazyGit |
| `<leader>gf` | Открыть LazyGit для текущего файла |

### Gitsigns / hunks
| Клавиша | Что делает |
|---|---|
| `]h` | Следующий hunk |
| `[h` | Предыдущий hunk |
| `<leader>ghs` | Stage hunk / выделенные hunks |
| `<leader>ghr` | Reset hunk / выделенные hunks |
| `<leader>ghS` | Stage весь буфер |
| `<leader>ghR` | Reset весь буфер |
| `<leader>ghu` | Undo stage hunk |
| `<leader>ghp` | Preview hunk |
| `<leader>ghb` | Blame current line |
| `<leader>ghB` | Вкл/выкл inline blame |
| `<leader>ghd` | Diff текущего файла |
| `<leader>ghD` | Diff текущего файла с `~` |
| `<leader>ghq` | Отправить hunks в quickfix |

### Diffview
| Клавиша | Что делает |
|---|---|
| `<leader>gdw` | Открыть git diff workspace |
| `<leader>gds` | Открыть diff staged changes |
| `<leader>gdm` | Diff текущей ветки с upstream |
| `<leader>gdf` | История текущего файла |
| `<leader>gdh` | История проекта |
| `<leader>gD` | Закрыть git diff view |

### Telescope / Neo-tree Git
| Клавиша | Что делает |
|---|---|
| `<leader>gs` | Changed files через Telescope |
| `<leader>gb` | Git branches через Telescope |
| `<leader>gc` | Git commits через Telescope |
| `<leader>gC` | Commits текущего файла через Telescope |
| `<leader>gS` | Git status view в Neo-tree |

### Git conflicts
| Клавиша | Что делает |
|---|---|
| `<leader>gxo` | Принять `ours` |
| `<leader>gxt` | Принять `theirs` |
| `<leader>gxb` | Принять обе версии |
| `<leader>gxn` | Следующий конфликт |
| `<leader>gxp` | Предыдущий конфликт |

### Worktree и GitHub review
| Клавиша | Что делает |
|---|---|
| `<leader>gw` | Список git worktree |
| `<leader>gW` | Создать новый git worktree |
| `<leader>go` | Открыть Octo (GitHub PR/issues) |
| `<leader>gr` | Начать review в Octo |

### TODO comments
| Клавиша | Что делает |
|---|---|
| `<leader>td` | Открыть TODO/FIXME список через Telescope |

---

## 8. Терминал, форматирование, инструменты

### Терминал
| Клавиша | Что делает |
|---|---|
| `<leader>tg` | Float-терминал |
| `<leader>th` | Горизонтальный терминал |

### Форматирование и пакеты
| Клавиша | Что делает |
|---|---|
| `<leader>cf` | Форматировать текущий файл |
| `<leader>pm` | Открыть Mason (LSP/инструменты) |

### Переводчик
| Клавиша | Что делает |
|---|---|
| `<leader>tr` | Перевести слово под курсором на RU |
| `<leader>tl` | Перевести текущую строку на RU в отдельном окне |
| `<leader>tv` | Перевести выделенный текст на RU |

Окно перевода не закрывается по таймеру: его можно прокручивать обычными клавишами и закрыть через `q` или `Esc`. Буквальные `\n` в ответе преобразуются в настоящие переносы строк.

> Перевод выполняет внешняя команда `trans`: содержимое строки, выделения или LSP hover отправляется выбранному ею сетевому сервису перевода.

### Буфер обмена
| Клавиша | Что делает |
|---|---|
| `<leader>cl` | Скопировать весь буфер в системный clipboard |

---

## 9. AI-команды

### GitHub Copilot (только inline autocomplete)
| Клавиша | Что делает | Режим |
|---|---|---|
| `<M-;>` | Показать inline/ghost-text подсказку Copilot (Alt+;) | `i` |
| `<M-g>` | Показать подсказку Copilot (Cmd+G) | `i` |
| `<M-l>` | Принять подсказку Copilot (Cmd+L) | `i` |
| `<C-l>` | Принять подсказку Copilot | `i` |
| `<M-]>` | Следующая подсказка Copilot | `i` |
| `<M-[>` | Предыдущая подсказка Copilot | `i` |
| `<C-]>` | Скрыть подсказку Copilot | `i` |

Copilot Chat не используется: все чат-команды и действия с кодом выполняет Codex.

### OpenAI Codex (Sidekick)
| Клавиша | Что делает | Режим |
|---|---|---|
| `<C-.>` | Перейти в панель Codex; повторно — вернуться в редактор | `n`,`i`,`x`,`t` |
| `<leader>ac` | Открыть/скрыть чат Codex | `n` |
| `<leader>ae` | Объяснить код в текущей позиции или выделении | `n`,`x` |
| `<leader>af` | Исправить код в текущей позиции или выделении | `n`,`x` |
| `<leader>ar` | Провести code review файла или выделения | `n`,`x` |
| `<leader>aR` | Выполнить рефакторинг файла или выделения | `n`,`x` |
| `<leader>ag` | Подготовить запрос для задачи по всему проекту | `n` |
| `<leader>ai` | Подготовить запрос на генерацию или изменение кода | `n`,`x` |
| `<leader>as` | Выбрать существующую сессию Codex | `n` |
| `<leader>at` | Добавить позицию курсора или диапазон выделения | `n`,`x` |
| `<leader>av` | Вставить в запрос сам выделенный текст | `x` |
| `<leader>ab` | Добавить текущий файл как контекст | `n` |
| `<leader>ap` | Выбрать готовый промпт (review, fix, tests и т. д.) | `n`,`x` |

В окне агента `<C-p>` открывает список контекста/промптов, `<C-f>` — файлы,
`<C-b>` — открытые буферы, `<C-z>` возвращает фокус в редактор, а `<C-.>`
скрывает панель. Если установлен `tmux`, сессия Codex остаётся живой после
закрытия Neovim и снова обнаруживается через `<leader>as`.

Sidekick используется только для CLI-агентов, поэтому его NES отключён. Сообщение
`No Copilot LSP server` в `:checkhealth sidekick` не влияет на Codex и ожидаемо,
пока inline-подсказки обслуживает отдельный `copilot.vim`.

### Graphify
| Команда/клавиша | Что делает |
|---|---|
| `<leader>cg` | Построить knowledge graph текущего проекта |
| `:Graphify` | Построить knowledge graph для текущей директории |
| `:Graphify path/to/project` | Построить graph для выбранной директории |

---

## 10. Rust / Cargo

| Клавиша | Что делает |
|---|---|
| `<leader>ch` | Popup по crate |
| `<leader>cd` | Открыть docs.rs для crate под курсором |
| `<leader>cu` | Обновить текущий crate |
| `<leader>cU` | Обновить все crates |
| `<leader>rR` | `cargo run` через Overseer |
| `<leader>rb` | `cargo build` через Overseer |
| `<leader>rt` | `cargo test` через Overseer |
| `<leader>rc` | `cargo clippy --all-targets --all-features` через Overseer |
| `<leader>rp` | Открыть/скрыть панель задач Overseer |

### Rust tooling (без отдельных хоткеев)
- `rustaceanvim`: основной Rust LSP/IDE.
- `rustowl`: подсветка ownership/lifetimes.
- `overseer.nvim`: task runner в стиле IDE.
- Rust-тесты Neotest используют встроенный адаптер `rustaceanvim`.

## 11. Go

| Клавиша | Что делает |
|---|---|
| `<leader>Gt` | Запустить `go test ./...` |
| `<leader>Gn` | Тест текущей функции |
| `<leader>Gf` | Тест текущего файла |
| `<leader>Gp` | Тест текущего пакета |
| `<leader>Gb` | Запустить benchmarks |
| `<leader>Gc` | Показать coverage |
| `<leader>GG` | Выполнить `go generate` |
| `<leader>Gv` | Выполнить `go vet` |
| `<leader>Gm` | Выполнить `go mod tidy` |
| `<leader>Gi` | Организовать imports |
| `<leader>Gs` | Заполнить struct |
| `<leader>GI` | Реализовать interface |
| `<leader>Ga` | Добавить struct tags |
| `<leader>GA` | Удалить struct tags |

Для rename и inlay hints используются общие LSP-команды `<leader>ln` и `<leader>uh`.

---

## 12. Отладка (DAP)

| Клавиша | Что делает |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Условный breakpoint |
| `<leader>dc` | Continue |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Показать/скрыть DAP REPL |
| `<leader>du` | Показать/скрыть DAP UI |

---

## 13. Тесты (Neotest)

| Клавиша | Что делает |
|---|---|
| `<leader>tn` | Запустить ближайший тест |
| `<leader>tf` | Запустить тесты текущего файла |
| `<leader>ts` | Показать/скрыть summary |
| `<leader>to` | Показать/скрыть output panel |

---

## 14. Trouble-панель

| Клавиша | Что делает |
|---|---|
| `<leader>xx` | Все diagnostics |
| `<leader>xw` | Diagnostics текущего буфера |
| `<leader>xd` | LSP symbols/references/definitions |
| `<leader>xq` | Quickfix list |
| `<leader>xl` | Location list |

---

## 15. Автодополнение и комментарии

Работает в insert-mode:

| Клавиша | Что делает |
|---|---|
| `<CR>` | Подтвердить выбранный completion |
| `<Tab>` | Следующий completion / следующий snippet placeholder |
| `<S-Tab>` | Предыдущий completion / предыдущий snippet placeholder |

Для комментариев используются встроенные команды Neovim: `gcc` комментирует строку, `gc` работает как оператор или с выделением.

---

## 16. Практический сценарий для новичка

1. `Space ff` — открой файл.
2. `i` — войди в режим ввода.
3. Печатай код, `jk` — выйти в normal mode.
4. `Space cf` — форматнуть файл.
5. `gd` / `K` — перейти к определению и посмотреть документацию.
6. `Space dn` / `Space dd` — пройтись по ошибкам.
7. `Space w` — сохранить.

---

## 17. Если не срабатывает клавиша

| Проблема | Что проверить |
|---|---|
| `Alt`-комбинации не работают | Настройки терминала (Meta/Alt as Esc) |
| Не работает Copilot | Выполнить `:Copilot setup`, проверить Node.js |
| Не запускается Codex в Neovim | Проверить `codex --version`, `codex login status` и CLI-секцию `:checkhealth sidekick` |
| Не работает переводчик | Установить `translate-shell` (`trans`) |
| Не работает поиск по проекту | Нужен `ripgrep` (`rg`) |
| Нет иконок | Нужен Nerd Font в терминале |

---

## 18. Проверка конфликтов keymap

После изменения mappings запустите:

```bash
nvim -n --headless -u NONE -l scripts/check-keymaps.lua
```

Команда завершится с ошибкой и покажет обе регистрации, если одна комбинация назначена повторно в том же режиме и scope.

## 17. Полезные команды Neovim

| Команда | Назначение |
|---|---|
| `:Lazy` | Менеджер плагинов |
| `:Mason` | Менеджер LSP/DAP/линтеров |
| `:checkhealth` | Общая диагностика окружения |
| `:map` | Показать активные маппинги |
| `:Telescope keymaps` | Найти маппинг через Telescope |

---

## 18. Памятка

- `Esc` всегда возвращает вас в безопасный `Normal mode`.
- Если запутались: нажмите `Esc`, затем начните заново.
- Основные “ежедневные” клавиши:
  `Space ff`, `Space w`, `Space f`, `gd`, `K`, `Space dd`, `Space e`.
