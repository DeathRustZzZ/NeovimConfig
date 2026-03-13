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
| `<leader>q` | Закрыть текущее окно | `n` |
| `jk` | Выйти из insert mode | `i` |
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
| `gr` | Показать использования (references) |
| `K` | Hover-документация |
| `<leader>rn` | Переименовать символ |
| `<leader>ca` | Code action |
| `<leader>uh` | Вкл/выкл inlay hints |

### Rust-специфично
| Клавиша | Что делает |
|---|---|
| `<leader>rh` | Hover docs (Rust) |
| `<leader>ra` | Code action (Rust) |
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

### Gitsigns
| Клавиша | Что делает |
|---|---|
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame current line |

### Diffview
| Клавиша | Что делает |
|---|---|
| `<leader>gd` | Открыть git diff view |
| `<leader>gD` | Закрыть git diff view |
| `<leader>gH` | История текущего файла |

### Neogit (как в IDE)
| Клавиша | Что делает |
|---|---|
| `<leader>gg` | Открыть Git Status (staging, commit, push, pull, stash, rebase) |
| `<leader>gc` | Быстрый вход в commit flow |
| `<leader>gp` | Push |
| `<leader>gP` | Pull |
| `<leader>gl` | Log |

### LazyGit
| Клавиша | Что делает |
|---|---|
| `<leader>lg` | Открыть LazyGit в Neovim |

### Git conflicts
| Клавиша | Что делает |
|---|---|
| `<leader>gco` | Принять `ours` |
| `<leader>gct` | Принять `theirs` |
| `<leader>gcb` | Принять обе версии |
| `<leader>gcn` | Следующий конфликт |
| `<leader>gcp` | Предыдущий конфликт |

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
| `<leader>at` | Открыть/закрыть терминал |
| `<leader>tg` | Float-терминал |
| `<leader>tf` | Горизонтальный терминал |

### Форматирование и пакеты
| Клавиша | Что делает |
|---|---|
| `<leader>f` | Форматировать текущий файл |
| `<leader>pm` | Открыть Mason (LSP/инструменты) |

### Переводчик
| Клавиша | Что делает |
|---|---|
| `<leader>tr` | Перевести слово под курсором на RU |
| `<leader>tl` | Перевести текущую строку на RU |

### Буфер обмена
| Клавиша | Что делает |
|---|---|
| `<leader>cl` | Скопировать весь буфер в системный clipboard |

---

## 9. AI-команды

### Copilot (inline)
| Клавиша | Что делает | Режим |
|---|---|---|
| `<C-l>` | Принять подсказку Copilot | `i` |
| `<M-]>` | Следующая подсказка Copilot | `i` |
| `<M-[>` | Предыдущая подсказка Copilot | `i` |
| `<C-]>` | Скрыть подсказку Copilot | `i` |

### Copilot Chat / Codex
| Клавиша | Что делает | Режим |
|---|---|---|
| `<leader>ac` | Открыть/закрыть Copilot Chat | `n` |
| `<leader>ae` | Explain selection/code | `n`,`x` |
| `<leader>ar` | Review code | `n`,`x` |
| `<leader>af` | Fix code | `n`,`x` |
| `<leader>ax` | Переключить Codex панель | `n` |

---

## 10. Rust / Cargo

| Клавиша | Что делает |
|---|---|
| `<leader>cp` | Popup по crate |
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
- `ferris.nvim`: дополнительные rust-analyzer utilities.
- `overseer.nvim`: task runner в стиле IDE.

---

## 11. Отладка (DAP)

| Клавиша | Что делает |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>du` | Показать/скрыть DAP UI |

---

## 12. Тесты (Neotest)

| Клавиша | Что делает |
|---|---|
| `<leader>tn` | Запустить ближайший тест |
| `<leader>tf` | Запустить тесты текущего файла |
| `<leader>ts` | Показать/скрыть summary |
| `<leader>to` | Показать/скрыть output panel |

---

## 13. Trouble-панель

| Клавиша | Что делает |
|---|---|
| `<leader>xx` | Все diagnostics |
| `<leader>xw` | Diagnostics текущего буфера |
| `<leader>xd` | LSP symbols/references/definitions |
| `<leader>xq` | Quickfix list |
| `<leader>xl` | Location list |

---

## 14. Автодополнение (nvim-cmp)

Работает в insert-mode:

| Клавиша | Что делает |
|---|---|
| `<CR>` | Подтвердить выбранный completion |
| `<Tab>` | Следующий completion / следующий snippet placeholder |
| `<S-Tab>` | Предыдущий completion / предыдущий snippet placeholder |

---

## 15. Практический сценарий для новичка

1. `Space ff` — открой файл.
2. `i` — войди в режим ввода.
3. Печатай код, `jk` — выйти в normal mode.
4. `Space f` — форматнуть файл.
5. `gd` / `K` — перейти к определению и посмотреть документацию.
6. `Space dn` / `Space dd` — пройтись по ошибкам.
7. `Space w` — сохранить.

---

## 16. Если не срабатывает клавиша

| Проблема | Что проверить |
|---|---|
| `Alt`-комбинации не работают | Настройки терминала (Meta/Alt as Esc) |
| Не работает Copilot | Выполнить `:Copilot setup`, проверить Node.js |
| Не работает переводчик | Установить `translate-shell` (`trans`) |
| Не работает поиск по проекту | Нужен `ripgrep` (`rg`) |
| Нет иконок | Нужен Nerd Font в терминале |

---

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
