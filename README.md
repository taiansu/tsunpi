![Test Status](https://github.com/taiansu/tsunpi/actions/workflows/test.yml/badge.svg)
![License](https://img.shields.io/github/license/taiansu/tsunpi)
![macOS](https://img.shields.io/badge/macOS-13%2B-blue)

# 🍽️ tsún-pī (準備)

**繁體中文** | [English](README.en.md)

> 為你的開發環境做好準備(tsún-pī) 

**tsunpi**（準備，台語 tsún-pī / 日語 じゅんび junbi）- 無論哪種語言，準備工作都是成功的基礎。就像料理前備好食材、出門前整理行囊，我們為你的開發環境做好準備。

一行指令，自動安裝並設定你的 macOS 開發環境。

## ✨ 特色

- 💡 **預設非互動** - 無提示確認，適合 `curl | bash` 與自動化；需要時可用 `--interactive` 開啟數字選單
- 🖥️ **正規環境配置** - 使用 [Homebrew](https://brew.sh)、[mise](https://mise.jdx.dev) 標準慣例，設定寫入 `conf.d` 不污染使用者的 `config.toml`
- 📦 **支援 Brewfile** - 支援 `--brewfile` 一鍵 bundle 安裝
- 🔧 **可選擇語言** - 預設安裝常用語言，也可透過旗標自訂或傳入現有 mise 設定
- ♻️ **冪等性** - 重複執行安全，已安裝的工具與設定自動跳過

## 🚀 快速開始

### 預設安裝（Python, Elixir, Node）

```bash
curl -fsSL https://tsunpi.phx.tw | bash
```

### 自訂語言組合

```bash
curl -fsSL https://tsunpi.phx.tw | bash -s -- --langs=python,rust,ruby
```

### 搭配 Brewfile 與外部 mise 設定

```bash
curl -fsSL https://tsunpi.phx.tw | bash -s -- --brewfile=/path/to/Brewfile --mise-config=/path/to/mise.toml --no-rc
```

## 📦 安裝內容

### 基礎工具

**必要工具**

- **Homebrew** - macOS 套件管理器
- **Git** - 版本控制
- **mise** - 開發工具版本管理

**可選工具（預設全部安裝，亦可透過 `--brewfile` 取代）**

- **ripgrep** - 快速文字搜尋
- **fzf** - 模糊搜尋工具
- **fd** - 檔案搜尋工具
- **uv** - Python 專案管理工具
- **stow** - 透過符號連結管理設定檔（dotfiles）
- **zoxide** - 記住常用目錄，快速切換路徑

### 支援的語言環境

| 選項 | 語言 | 說明 |
|------|------|------|
| `python` | [Python](https://www.python.org/) | 最新穩定版 |
| `elixir` | [Elixir + Erlang](https://elixir-lang.org/) | 同時安裝對應的 Erlang 版本 |
| `node` | [Node.js + npm](https://nodejs.org/en) | JavaScript 執行環境 |
| `rust` | [Rust + Cargo](https://rust-lang.org/) |  |
| `ruby` | [Ruby + gem](https://www.ruby-lang.org/en/) |  |
| `zig` | [Zig](https://ziglang.org/) |  |
| `swift` | [Swift](https://swift.org/) |  |
| `bun` | [Bun](https://bun.com/) |  |

**預設組合**: `python`, `elixir`, `node`

*註*：需要其它語言請見 [FAQ](#faq)

## 🎮 使用方式

### 命令列旗標

| 旗標 | 說明 |
|------|------|
| `--brewfile PATH` | 指定 Brewfile 路徑，透過 `brew bundle --file=PATH` 安裝套件（取代 `--packages`） |
| `--mise-config PATH` | 指定 mise 設定檔路徑，逐字複製至 `~/.config/mise/conf.d/tsunpi.toml` |
| `--no-rc` | 跳過 Shell 整合，不修改 rc 檔（如 `~/.zshrc`、`~/.bashrc`） |
| `--langs=...` / `--langs ...` | 指定要安裝的程式語言（逗號分隔，預設 `python,elixir,node`） |
| `--packages=...` / `--packages ...` | 指定額外 Homebrew 套件（逗號分隔，預設全部安裝；`none` 略過額外套件） |
| `--locale=...` / `--locale ...` | 介面語系（`en` 或 `zh-TW`） |
| `--interactive` | 以數字選單選擇額外套件與程式語言；未指定時完全不互動 |
| `--dry` | Dry run 模式，只顯示安裝計畫而不實際執行 |
| `-h`, `--help` | 顯示使用說明 |

### 基本用法

```bash
# 使用預設語言組合
curl -fsSL https://tsunpi.phx.tw | bash

# 指定語言（逗號分隔，不含空格）
curl -fsSL https://tsunpi.phx.tw | bash -s -- --langs=python,rust

# 搭配 Brewfile 與自訂 mise 設定
curl -fsSL https://tsunpi.phx.tw | bash -s -- --brewfile=/tmp/Brewfile --mise-config=/tmp/mise.toml --no-rc

# Dry run 模式 (只偵測並列印安裝計劃，不實際執行)
curl -fsSL https://tsunpi.phx.tw | bash -s -- --dry
```

### 選擇 Homebrew 套件

Homebrew、Git 與 mise 為必要工具；`--packages` 控制額外工具的選擇：

```bash
# 只選擇 fzf 與 zoxide，仍保留 Git 與 mise
./setup.sh --packages=fzf,zoxide

# 不安裝額外工具，保留必要工具與 Python
./setup.sh --packages=none --langs=python

# 預覽必要套件、選定的額外套件與語言環境
./setup.sh --packages=stow,zoxide --langs=python,rust --dry
```

- 可選套件：`ripgrep`、`fzf`、`fd`、`uv`、`stow`、`zoxide`。
- 若指定 `--brewfile`，tsunpi 會直接執行 `brew bundle` 安裝 Brewfile 內容，不再安裝 `--packages` 中的額外套件。
- 未指定 `--packages` 且未指定 `--brewfile` 時，預設選擇全部額外工具；`none` 只略過額外工具，不會略過語言環境，也不會移除已安裝的套件。
- 名稱以逗號分隔、不含空白。重複名稱只處理一次；列出 `git` 或 `mise` 不影響它們的必要工具身分。
- 透過執行檔偵測已安裝的工具（例如 ripgrep 對應 `rg`），存在時略過安裝。必要套件安裝失敗會中止；額外套件失敗則警告後繼續。

### 介面語言

支援繁體中文（`zh-TW`）與英文（`en`）。`--locale` 控制 tsunpi 的介面語言，`--langs` 仍用於選擇要安裝的程式語言：

```bash
# 英文介面
curl -fsSL https://tsunpi.phx.tw | bash -s -- --locale=en

# 繁體中文介面，安裝 Python 與 Rust
curl -fsSL https://tsunpi.phx.tw | bash -s -- --locale=zh-TW --langs=python,rust

# 設定預設介面語言
export TSUNPI_LOCALE=zh-TW
./setup.sh --dry
```

語系優先順序：`--locale` > `TSUNPI_LOCALE` > `LC_ALL` > `LC_MESSAGES` > `LANG` > 英文。

- 系統語系取第一個非空值；無法辨識時回退英文，不再往下尋找。
- 語系名稱不分大小寫，接受 `-` 或 `_` 分隔，並忽略編碼與 modifier 後綴。英文語系（例如 `en_US.UTF-8`）對應 `en`；`zh_TW`、`zh_HK`、`zh_MO`、`zh-Hant` 與 `zh-Hant-*` 對應 `zh-TW`。
- 其他系統語系（包含 `C`、`POSIX`）回退英文。明確指定不支援或空白的 `--locale`／`TSUNPI_LOCALE` 會報錯；較高優先序的設定會覆蓋較低者。
- 只切換 tsunpi 自己的訊息，不修改 `LANG` 或 `LC_ALL`；Homebrew、mise、sudo 的輸出由各工具決定。

### 互動模式

預設不需要任何互動。加上 `--interactive` 會先選擇額外套件，再選擇程式語言；已用 `--packages`／`--brewfile` 指定的套件與已用 `--langs`／`--mise-config` 指定的語言會略過對應選單。以下為 `--locale=zh-TW` 的範例：

```text
Homebrew 與以下套件為必要工具: git mise
請選擇額外套件 (輸入數字組合，例如 126)
直接按 Enter 選擇全部；輸入 0 不選額外套件
1) ripgrep
2) fzf
3) fd
4) uv
5) stow
6) zoxide

套件選擇: _
```

輸入 `26` 選擇 fzf 與 zoxide；Enter 選擇全部；單獨輸入 `0` 不選額外工具。重複數字會去重；無效數字或混用 `0` 會中止，不會開始安裝。

接著選擇語言環境：

```text
請選擇要安裝的語言環境 (輸入數字組合，例如 134)
直接按 Enter 使用預設: Python, Elixir, Node

1) Python
2) Elixir (自動安裝對應 Erlang 版本)
3) Node
4) Rust
5) Ruby
6) Zig
7) Swift
8) Bun

你的選擇: _
```

輸入 `134` 安裝 Python、Node、Rust；直接按 Enter 安裝預設組合。

`--ci` 自 v2.1 起無作用（預設即為非互動），保留只為相容舊指令。

## 🔒 安全建議

建議首次使用時先檢視腳本內容：

```bash
# 下載腳本
curl -fsSL https://tsunpi.phx.tw > setup.sh

# 檢視內容
less setup.sh

# 確認無誤後執行
bash setup.sh
```

或直接查看 [GitHub 原始碼](https://github.com/taiansu/tsunpi)。

## ⚙️ 運作原理

1. **檢查 Homebrew** - 若未安裝則自動安裝 (可能需要輸入管理者密碼)
2. **安裝基礎工具** - 使用 Homebrew 安裝必要的 git、mise，以及選定的額外套件或 `--brewfile`
3. **產生 mise 設定** - 將設定寫入 `~/.config/mise/conf.d/tsunpi.toml`（或由 `--mise-config` 逐字複製）。永不修改 `~/.config/mise/config.toml`，避免影響使用者的 dotfiles（如 stow 軟連結）
4. **設定 Shell 整合** - 除非指定 `--no-rc`，否則自動將 `eval "$(mise activate <shell>)"` 冪等地加入 shell rc 檔
5. **安裝語言環境** - 自動執行 `mise install` 安裝選定的程式語言

### 設定檔位置

設定檔皆依標準開發者慣例配置：

- mise tsunpi 設定檔：`~/.config/mise/conf.d/tsunpi.toml`
- 語言安裝目錄：`~/.local/share/mise/installs/`
- Shell 設定：`~/.zshrc` 或 `~/.bashrc`

## ⏱️ 安裝時間

| 語言組合 | 預估時間（首次） | 說明 |
|---------|----------------|------|
| Python only | ~3 分鐘 | 較輕量 |
| Python + Node | ~5 分鐘 | 常見組合 |
| Python + Elixir + Node | ~20-30 分鐘 | Erlang 需要編譯 |
| All languages | ~25-60 分鐘 | 包含 Rust 編譯 |

> 💡 **提示**: Erlang 和 Rust 有可能需要從原始碼編譯，首次安裝較慢。後續版本更新會使用預編譯版本，速度較快。

## 🔧 管理已安裝的語言

安裝完成後，你可以使用 mise 管理語言版本：

```bash
# 查看已安裝的語言
mise list

# 更新到最新版本
mise upgrade

# 安裝特定版本
mise install python@3.11

# 設定專案特定版本（在專案目錄下）
mise use python@3.11

# 查看 mise 狀態
mise doctor
```

更詳細的操作請參考 [mise 說明](https://mise.jdx.dev/installing-mise.html)

## 🙋 FAQ

Q: 這個工具可以幫我安裝其它語言嗎？

A: `--langs` 選項可以安裝 `mise` 有 [支援](https://mise.jdx.dev/registry.html)的所有語言與工具。
例如：

```bash
curl -fsSL https://tsunpi.phx.tw | bash -s -- --langs=python,kotlin,clojure
```

<br/>

Q: 承上，如果我在`--langs`選項亂加東西會怎樣？

A: mise registry 內的工具都可以；名稱不存在時會在安裝前中止。tsunpi 會在執行 `mise install` 前對照 [mise registry](https://mise.jdx.dev/registry.html) 檢查所有工具名稱，若有不認識的工具會顯示錯誤並中止安裝，不會安裝任何工具。
<br/>

Q: Windows 可以用嗎？

A: 計劃中

## 🐛 疑難排解

### Homebrew 安裝失敗

```bash
# 檢查網路連線
ping github.com

# 手動安裝 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 重新執行 tsunpi
curl -fsSL https://tsunpi.phx.tw | bash
```

### mise 安裝語言失敗

```bash
# 查看詳細錯誤訊息
mise install -v

# 檢查系統依賴
mise doctor

# 手動安裝特定語言
mise install python@latest
```

### Shell 找不到已安裝的語言

```bash
# 確認 mise activate 已設定
grep "mise activate" ~/.zshrc  # 或 ~/.bashrc

# 手動載入 mise
eval "$(mise activate zsh)"  # 或 bash

# 重新啟動終端機
```

### 權限問題

某些操作需要 sudo 權限（例如安裝 Homebrew）。如果遇到權限錯誤：

```bash
# 確認你有 admin 權限
groups | grep admin

# 清除 Homebrew cache（如果磁碟空間不足）
brew cleanup
```

## 🤝 貢獻

歡迎貢獻！請查看 [貢獻指南](CONTRIBUTING.md)。

### 開發

```bash
# Clone repository
git clone https://github.com/taiansu/tsunpi.git
cd tsunpi

# 測試腳本
./setup.sh --langs=python --dry

# 執行本機函式檢查、語系與套件選擇回歸測試（不進行安裝）
/bin/bash test.sh
# GitHub Actions 另外執行完整安裝測試
```

### 測試

專案使用 GitHub Actions 進行自動化測試：

- ✅ 預設安裝測試
- ✅ 自訂語言組合測試
- ✅ 冪等性測試
- ✅ 跨 macOS 版本相容性
- 介面語系優先順序、正規化、回退與參數錯誤
- 套件選擇、必要工具保留、去重與安裝失敗處理
- `--brewfile`、`--mise-config`、`--no-rc` 與 `conf.d` 隔離測試

查看 [.github/workflows/test.yml](.github/workflows/test.yml) 了解測試詳情。

### Cloudflare Worker 部署

[`worker.js`](worker.js) 將請求以 HTTP 302 轉址至 GitHub 上的 `main/setup.sh`，不會在 Cloudflare 執行安裝腳本。部署入口由 [`wrangler.jsonc`](wrangler.jsonc) 指定，Worker 名稱為 `tsunpi`。

Cloudflare 的 **Settings → Build → Build Configuration**：

| 欄位 | 設定 |
|------|------|
| Root directory | Repo 根目錄 |
| Build command | 留空 |
| Deploy command | `npx --yes wrangler@4.129.0 deploy` |

不要把 `setup.sh` 設為 build command；它是使用者的 macOS 安裝程式。

本機驗證需要 Node.js 與 npm：

```bash
# 驗證打包，不部署到 Cloudflare
npx --yes wrangler@4.129.0 deploy --dry-run

# 啟動本機 Worker
npx --yes wrangler@4.129.0 dev --local --port 8799
```

在另一個終端機檢查轉址，不執行安裝：

```bash
curl -sSI http://localhost:8799/
```

預期為 `302`，且 `Location` 為 `https://raw.githubusercontent.com/taiansu/tsunpi/main/setup.sh`。提交並推送後，由 Cloudflare Git 整合部署；再以 `curl -sSI https://tsunpi.phx.tw` 檢查線上回應。

此設計會下載 GitHub `main` 的最新腳本，而不是綁定某次 Worker 部署的版本。

## 📄 授權

MIT License - 詳見 [LICENSE](LICENSE)

## 🙏 致謝

- [mise](https://mise.jdx.dev) - 優秀的開發工具版本管理器
- [Homebrew](https://brew.sh) - macOS 必備套件管理器

## 📚 相關資源

- [mise 官方文件](https://mise.jdx.dev)
- [Homebrew 文件](https://docs.brew.sh)

---

**tsunpi** - 為你的開發環境做好準備 🍽️

Made with ❤️ for developers who value preparation
