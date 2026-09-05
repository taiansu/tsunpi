#!/bin/bash
# v2.0.4

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 預設語言清單
DEFAULT_LANGS="python,elixir,node"

# 僅控制 tsunpi 的介面；不改變子程序的 locale。
UI_LOCALE=en

# 用 REPLY 回傳文字，避免每則訊息啟動 command substitution。
translate() {
    local key="$1"
    local format
    shift
    case "$UI_LOCALE:$key" in
        en:invalid_locale) format='Unsupported locale: %s (supported: en, zh-TW)' ;;
        zh-TW:invalid_locale) format='不支援的介面語系: %s（支援: en、zh-TW）' ;;
        en:unknown_argument) format='Unknown argument: %s' ;;
        zh-TW:unknown_argument) format='未知參數: %s' ;;
        en:usage) format='Usage: %s [--locale=en|zh-TW] [--interactive] [--langs=python,node,rust] [--ci] [--dry]' ;;
        zh-TW:usage) format='用法: %s [--locale=en|zh-TW] [--interactive] [--langs=python,node,rust] [--ci] [--dry]' ;;
        en:checking_homebrew) format='Checking Homebrew...' ;;
        zh-TW:checking_homebrew) format='檢查 Homebrew...' ;;
        en:homebrew_installed) format='Homebrew is already installed' ;;
        zh-TW:homebrew_installed) format='Homebrew 已安裝' ;;
        en:installing_homebrew) format='Installing Homebrew...' ;;
        zh-TW:installing_homebrew) format='開始安裝 Homebrew...' ;;
        en:homebrew_admin) format='Installing Homebrew requires admin privileges' ;;
        zh-TW:homebrew_admin) format='安裝 Homebrew 需要 admin 權限' ;;
        en:password_prompt) format='Please enter your macOS user password...' ;;
        zh-TW:password_prompt) format='請輸入你的 macOS 使用者密碼...' ;;
        en:admin_failed) format='Unable to obtain admin privileges; installation aborted' ;;
        zh-TW:admin_failed) format='無法取得 admin 權限，安裝中止' ;;
        en:homebrew_complete) format='Homebrew installation complete' ;;
        zh-TW:homebrew_complete) format='Homebrew 安裝完成' ;;
        en:homebrew_failed) format='Homebrew installation failed' ;;
        zh-TW:homebrew_failed) format='Homebrew 安裝失敗' ;;
        en:possible_causes) format='Possible causes:' ;;
        zh-TW:possible_causes) format='可能原因：' ;;
        en:network_issue) format='  %s. Network connection problems' ;;
        zh-TW:network_issue) format='  %s. 網路連線問題' ;;
        en:admin_missing) format='  %s. Missing admin privileges' ;;
        zh-TW:admin_missing) format='  %s. 沒有 admin 權限' ;;
        en:disk_full) format='  %s. Insufficient disk space' ;;
        zh-TW:disk_full) format='  %s. 磁碟空間不足' ;;
        en:homebrew_help) format='Review the errors above, or visit https://brew.sh to install manually' ;;
        zh-TW:homebrew_help) format='請查看上方錯誤訊息，或前往 https://brew.sh 手動安裝' ;;
        en:press_enter_close) format='Press Enter to close...' ;;
        zh-TW:press_enter_close) format='按 Enter 鍵關閉...' ;;
        en:installing_tools) format='Installing development tools...' ;;
        zh-TW:installing_tools) format='開始安裝開發工具...' ;;
        en:tool_installed) format='%s is already installed; skipping' ;;
        zh-TW:tool_installed) format='%s 已安裝，跳過' ;;
        en:installing_tool) format='Installing %s...' ;;
        zh-TW:installing_tool) format='安裝 %s...' ;;
        en:tool_complete) format='%s installation complete' ;;
        zh-TW:tool_complete) format='%s 安裝完成' ;;
        en:tool_failed) format='%s installation failed; continuing...' ;;
        zh-TW:tool_failed) format='%s 安裝失敗，繼續執行...' ;;
        en:select_languages) format='Select language environments to install (enter numbers, e.g. 134)' ;;
        zh-TW:select_languages) format='請選擇要安裝的語言環境 (輸入數字組合，例如 134)' ;;
        en:default_languages) format='Press Enter to use the defaults: Python, Elixir, Node' ;;
        zh-TW:default_languages) format='直接按 Enter 使用預設: Python, Elixir, Node' ;;
        en:elixir_option) format='2) Elixir (automatically installs the corresponding Erlang version)' ;;
        zh-TW:elixir_option) format='2) Elixir (自動安裝對應 Erlang 版本)' ;;
        en:selection_prompt) format='Your selection: ' ;;
        zh-TW:selection_prompt) format='你的選擇: ' ;;
        en:invalid_selection) format='Ignoring invalid option: %s' ;;
        zh-TW:invalid_selection) format='忽略無效選項: %s' ;;
        en:no_languages) format='No languages selected; using the defaults' ;;
        zh-TW:no_languages) format='未選擇任何語言，使用預設設定' ;;
        en:selected_languages) format='Language environments to install: %s' ;;
        zh-TW:selected_languages) format='將安裝以下語言環境: %s' ;;
        en:dry_summary) format='Dry-run summary' ;;
        zh-TW:dry_summary) format='Dry run 摘要' ;;
        en:dry_homebrew) format='Install Homebrew: %s' ;;
        zh-TW:dry_homebrew) format='將安裝 Homebrew: %s' ;;
        en:dry_languages) format='Language environments to install:' ;;
        zh-TW:dry_languages) format='將安裝的語言環境:' ;;
        en:config_preview) format='config.toml preview:' ;;
        zh-TW:config_preview) format='config.toml 預覽:' ;;
        en:config_location) format='  Location: ~/.config/mise/config.toml' ;;
        zh-TW:config_location) format='  位置: ~/.config/mise/config.toml' ;;
        en:config_contents) format='  Contents:' ;;
        zh-TW:config_contents) format='  內容:' ;;
        en:dry_complete) format='Dry run complete; nothing was installed' ;;
        zh-TW:dry_complete) format='Dry run 完成，未進行實際安裝' ;;
        en:generating_config) format='Generating mise configuration...' ;;
        zh-TW:generating_config) format='產生 mise 設定檔...' ;;
        en:config_backup) format='Existing configuration found; backing up to: %s' ;;
        zh-TW:config_backup) format='發現現有設定檔，備份至: %s' ;;
        en:config_created) format='Configuration created: %s' ;;
        zh-TW:config_created) format='設定檔已建立: %s' ;;
        en:setting_shell) format='Configuring mise shell integration...' ;;
        zh-TW:setting_shell) format='設定 mise shell 整合...' ;;
        en:unknown_shell) format='Unable to detect the shell; configure mise activate manually' ;;
        zh-TW:unknown_shell) format='無法偵測 shell 類型，請手動設定 mise activate' ;;
        en:shell_configured) format='mise activate is already configured in %s' ;;
        zh-TW:shell_configured) format='mise activate 已設定於 %s' ;;
        en:shell_written_ci) format='Updated %s (CI mode)' ;;
        zh-TW:shell_written_ci) format='已寫入 %s (CI 模式)' ;;
        en:shell_preview) format='The following will be added to %s:' ;;
        zh-TW:shell_preview) format='即將加入以下內容到 %s:' ;;
        en:confirm_prompt) format='Confirm? (Y/n): ' ;;
        zh-TW:confirm_prompt) format='是否確認? (Y/n): ' ;;
        en:shell_written) format='Updated %s' ;;
        zh-TW:shell_written) format='已寫入 %s' ;;
        en:shell_skipped) format='Skipped writing; run manually: %s' ;;
        zh-TW:shell_skipped) format='跳過寫入，請手動執行: %s' ;;
        en:mise_configured) format='mise configuration complete' ;;
        zh-TW:mise_configured) format='mise 設定完成' ;;
        en:compilation_warning) format='Note: compiling Erlang/Elixir may take 20–40 minutes' ;;
        zh-TW:compilation_warning) format='注意: Erlang/Elixir 編譯可能需要 20–40 分鐘' ;;
        en:installing_languages_ci) format='Installing language environments... (CI mode)' ;;
        zh-TW:installing_languages_ci) format='開始安裝語言環境... (CI 模式)' ;;
        en:languages_complete) format='All language environments installed!' ;;
        zh-TW:languages_complete) format='所有語言環境安裝完成!' ;;
        en:mise_failed) format='mise install failed' ;;
        zh-TW:mise_failed) format='mise install 執行失敗' ;;
        en:build_dependencies_missing) format='  1. Missing build dependencies' ;;
        zh-TW:build_dependencies_missing) format='  1. 編譯依賴套件缺失' ;;
        en:debug_steps) format='Troubleshooting steps:' ;;
        zh-TW:debug_steps) format='除錯步驟：' ;;
        en:run_doctor) format='  1. Run: mise doctor' ;;
        zh-TW:run_doctor) format='  1. 執行: mise doctor' ;;
        en:manual_install) format='  2. Install manually: mise install <language>' ;;
        zh-TW:manual_install) format='  2. 手動安裝: mise install <language>' ;;
        en:verbose_install) format='  3. View detailed logs: mise install -v' ;;
        zh-TW:verbose_install) format='  3. 查看詳細日誌: mise install -v' ;;
        en:install_prompt) format='Run mise install now? (Y/n): ' ;;
        zh-TW:install_prompt) format='是否立即執行 mise install? (Y/n): ' ;;
        en:installing_languages) format='Installing language environments...' ;;
        zh-TW:installing_languages) format='開始安裝語言環境...' ;;
        en:install_later) format='You can run mise install manually later' ;;
        zh-TW:install_later) format='你可以稍後手動執行: mise install' ;;
        en:press_enter_continue) format='Press Enter to continue...' ;;
        zh-TW:press_enter_continue) format='按 Enter 鍵繼續...' ;;
        en:install_skipped) format='Installation skipped; run mise install later' ;;
        zh-TW:install_skipped) format='已跳過安裝，稍後可執行: mise install' ;;
        en:banner) format=' # tsunpi — macOS development environment setup' ;;
        zh-TW:banner) format=' # tsunpi (準備) macOS 開發環境設定' ;;
        en:dry_notice) format='Dry Run - only showing planned actions' ;;
        zh-TW:dry_notice) format='Dry Run - 只顯示將執行的動作' ;;
        en:installation_complete) format='Installation complete!' ;;
        zh-TW:installation_complete) format='安裝完成!' ;;
        en:next_steps) format='Next steps:' ;;
        zh-TW:next_steps) format='下一步:' ;;
        en:restart_shell) format='  1. Restart your terminal or run: source ~/.zshrc (or ~/.bashrc)' ;;
        zh-TW:restart_shell) format='  1. 重新啟動終端機或執行: source ~/.zshrc (或 ~/.bashrc)' ;;
        en:verify_installation) format='  2. Verify installation: mise list' ;;
        zh-TW:verify_installation) format='  2. 驗證安裝: mise list' ;;
        en:check_versions) format='  3. Check versions: python --version, elixir --version, etc.' ;;
        zh-TW:check_versions) format='  3. 檢查版本: python --version, elixir --version 等' ;;
        *)
            printf 'Missing translation: %s:%s\n' "$UI_LOCALE" "$key" >&2
            return 1
            ;;
    esac
    printf -v REPLY "$format" "$@"
}

message() {
    translate "$@" || return
    printf '%s\n' "$REPLY"
}

normalize_locale() {
    local value
    value=$(printf '%s' "$1" | tr '[:upper:]_' '[:lower:]-')
    value=${value%%.*}
    value=${value%%@*}
    case "$value" in
        en|en-*) REPLY=en ;;
        zh-tw|zh-hk|zh-mo|zh-hant|zh-hant-*) REPLY=zh-TW ;;
        *) return 1 ;;
    esac
}

resolve_locale() {
    local argument
    local requested="${TSUNPI_LOCALE-}"
    local explicit="${TSUNPI_LOCALE+x}"
    UI_LOCALE=en
    if normalize_locale "${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}"; then
        UI_LOCALE="$REPLY"
    fi

    # 先掃描語系，讓參數錯誤不受 --locale 所在位置影響。
    for argument in "$@"; do
        case "$argument" in
            --locale=*)
                requested="${argument#*=}"
                explicit=x
                ;;
        esac
    done
    if [[ "$explicit" == x ]]; then
        if normalize_locale "$requested"; then
            UI_LOCALE="$REPLY"
        else
            error invalid_locale "$requested" >&2
            return 1
        fi
    fi
}

# 印出訊息函式
info() {
    translate "$@" || return
    printf '%bℹ%b %s\n' "$BLUE" "$NC" "$REPLY"
}

success() {
    translate "$@" || return
    printf '%b✓%b %s\n' "$GREEN" "$NC" "$REPLY"
}

warning() {
    translate "$@" || return
    printf '%b⚠%b %s\n' "$YELLOW" "$NC" "$REPLY"
}

error() {
    translate "$@" || return
    printf '%b✗%b %s\n' "$RED" "$NC" "$REPLY"
}

# 檢查指令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

reload_shell() {
    source ~/.bash_profile 2>/dev/null || source ~/.zshrc 2>/dev/null
}

# 解析參數
parse_arguments() {
    INTERACTIVE=false
    CUSTOM_LANGS=""
    CI_MODE=false
    DRY_RUN=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --locale=*)
                shift
                ;;
            --interactive)
                INTERACTIVE=true
                shift
                ;;
            --langs=*)
                CUSTOM_LANGS="${1#*=}"
                shift
                ;;
            --languages=*)
                CUSTOM_LANGS="${1#*=}"
                shift
                ;;
            --ci)
                CI_MODE=true
                shift
                ;;
            --dry)
                DRY_RUN=true
                shift
                ;;
            *)
                error unknown_argument "$1" >&2
                message usage "$0" >&2
                exit 1
                ;;
        esac
    done
}

# 檢查並安裝 Homebrew
check_homebrew() {
    INSTALL_HOMEBREW=true
    info checking_homebrew

    if command_exists brew; then
        success homebrew_installed
        INSTALL_HOMEBREW=false
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        INSTALL_HOMEBREW=false
        return 0
    fi

    info installing_homebrew

    warning homebrew_admin
    info password_prompt
    echo ""

    # 先取得 sudo 權限
    if ! sudo -v; then
        error admin_failed
        exit 1
    fi

    if NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        # 設定 Homebrew 環境變數
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        reload_shell

        success homebrew_complete
    else
        error homebrew_failed
        echo ""
        message possible_causes
        message network_issue 1
        message admin_missing 2
        message disk_full 3
        echo ""
        message homebrew_help
        echo ""
        translate press_enter_close
        read -p "$REPLY"
        exit 1
    fi
}

# 安裝基礎工具
install_tools() {
    local tools=("git" "mise" "ripgrep" "fzf" "fd" "uv" "stow" "zoxide")

    if [[ "$DRY_RUN" == true ]]; then
        return 0
    fi

    info installing_tools

    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            success tool_installed "$tool"
        else
            info installing_tool "$tool"
            if brew install "$tool"; then
                success tool_complete "$tool"
            else
                warning tool_failed "$tool"
            fi
        fi
    done
}

# 互動式選擇語言
select_languages_interactive() {
    echo "" >&2
    message select_languages >&2
    translate default_languages
    printf '%b%s%b\n' "$YELLOW" "$REPLY" "$NC" >&2
    echo "" >&2
    echo "1) Python" >&2
    message elixir_option >&2
    echo "3) Node" >&2
    echo "4) Rust" >&2
    echo "5) Ruby" >&2
    echo "6) Zig" >&2
    echo "7) Swift" >&2
    echo "8) Bun" >&2

    echo "" >&2

    translate selection_prompt
    read -p "$REPLY" choice < /dev/tty

    # 如果直接按 Enter，使用預設
    if [[ -z "$choice" ]]; then
        echo "python,elixir,node"
        return
    fi

    # 解析數字並轉換為語言名稱
    local langs=()
    local seen=()

    for (( i=0; i<${#choice}; i++ )); do
        digit="${choice:$i:1}"

        # 檢查是否已處理過此數字
        if [[ " ${seen[@]} " =~ " ${digit} " ]]; then
            continue
        fi
        seen+=("$digit")

        case $digit in
            1) langs+=("python") ;;
            2) langs+=("elixir") ;;
            3) langs+=("node") ;;
            4) langs+=("rust") ;;
            5) langs+=("ruby") ;;
            6) langs+=("zig") ;;
            7) langs+=("swift") ;;
            8) langs+=("bun") ;;
            *)
                warning invalid_selection "$digit" >&2
                ;;
        esac
    done

    if [[ ${#langs[@]} -eq 0 ]]; then
        warning no_languages >&2
        echo "python,elixir,node"
    else
        echo "${langs[@]}" | tr ' ' ','
    fi
}

# 選擇要安裝的語言
select_languages() {
    if [[ "$INTERACTIVE" == true ]]; then
        SELECTED_LANGS=$(select_languages_interactive)
    elif [[ -n "$CUSTOM_LANGS" ]]; then
        SELECTED_LANGS="$CUSTOM_LANGS"
    else
        SELECTED_LANGS="$DEFAULT_LANGS"
    fi

    # 擴展 elixir 為 erlang,elixir
    SELECTED_LANGS=$(expand_elixir_to_erlang "$SELECTED_LANGS")

    info selected_languages "$SELECTED_LANGS"
}

# 擴展 elixir 為 erlang,elixir
expand_elixir_to_erlang() {
    local langs="$1"
    local result=""

    IFS=',' read -ra LANG_ARRAY <<< "$langs"
    local added_erlang=false

    for lang in "${LANG_ARRAY[@]}"; do
        lang=$(echo "$lang" | xargs)  # trim whitespace

        # 如果是 elixir，先加入 erlang
        if [[ "$lang" == "elixir" ]]; then
            if [[ -n "$result" ]]; then
                result="$result,erlang,elixir"
            else
                result="erlang,elixir"
            fi
            added_erlang=true
        else
            if [[ -n "$result" ]]; then
                result="$result,$lang"
            else
                result="$lang"
            fi
        fi
    done

    echo "$result"
}

dry_info() {
  echo ""
  echo "=========================================="
  info dry_summary
  echo "=========================================="
  echo ""
  message dry_homebrew "$INSTALL_HOMEBREW"
  echo ""
  message dry_languages
  IFS=',' read -ra LANGS <<< "$SELECTED_LANGS"
  for lang in "${LANGS[@]}"; do
      echo "  - $lang"
  done
  echo ""
  message config_preview
  message config_location
  message config_contents
  echo "    [tools]"
  for lang in "${LANGS[@]}"; do
      lang=$(echo "$lang" | xargs)
      echo "    $lang = \"latest\""
  done
  echo ""
  info dry_complete
}

# 產生 mise 設定檔
generate_mise_config() {
    local config_dir="$HOME/.config/mise"
    local config_file="$config_dir/config.toml"

    info generating_config

    # 建立目錄
    mkdir -p "$config_dir"

    # 備份現有設定
    if [[ -f "$config_file" ]]; then
        local backup_file="$config_file.backup.$(date +%Y%m%d_%H%M%S)"
        warning config_backup "$backup_file"
        cp "$config_file" "$backup_file"
    fi

    # 寫入新設定
    cat > "$config_file" << EOF
# Generated by tsunpi
# $(date)

[tools]
EOF

    IFS=',' read -ra LANGS <<< "$SELECTED_LANGS"
    for lang in "${LANGS[@]}"; do
        lang=$(echo "$lang" | xargs) # trim whitespace
        echo "$lang = \"latest\"" >> "$config_file"
    done

    success config_created "$config_file"
}

# 設定 mise activate
setup_mise_activate() {
    info setting_shell

    local shell_name=""
    local rc_file=""

    # 偵測 shell
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        shell_name="zsh"
        rc_file="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *"bash"* ]]; then
        shell_name="bash"
        rc_file="$HOME/.bashrc"
        # macOS 預設使用 .zprofile
        if [[ "$OSTYPE" == "darwin"* ]] && [[ -f "$HOME/.zprofile" ]]; then
            rc_file="$HOME/.zprofile"
        fi
    else
        warning unknown_shell
        return
    fi

    local activate_cmd="eval \"\$(mise activate $shell_name)\""

    # 檢查是否已經設定
    if [[ -f "$rc_file" ]] && grep -q "mise activate" "$rc_file"; then
        success shell_configured "$rc_file"
        return
    fi

    # CI 模式：自動寫入不詢問
    if [[ "$CI_MODE" == true ]]; then
        echo "" >> "$rc_file"
        echo "# mise - Generated by tsunpi" >> "$rc_file"
        echo "$activate_cmd" >> "$rc_file"
        success shell_written_ci "$rc_file"
        eval "$activate_cmd"
        return
    fi

    echo ""
    info shell_preview "$rc_file"
    printf '%b%s%b\n' "$YELLOW" "$activate_cmd" "$NC"
    echo ""

    translate confirm_prompt
    read -p "$REPLY" confirm
    confirm=${confirm:-Y}

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "" >> "$rc_file"
        echo "# mise - added by tsunpi" >> "$rc_file"
        echo "$activate_cmd" >> "$rc_file"
        success shell_written "$rc_file"

        # 立即生效
        eval "$activate_cmd"
    else
        warning shell_skipped "$activate_cmd"
    fi
}

# 執行 mise install
prompt_mise_install() {
    echo ""
    info mise_configured

    IFS=',' read -ra LANGS <<< "$SELECTED_LANGS"
    local has_elixir=false
    for lang in "${LANGS[@]}"; do
        if [[ "$lang" == *"elixir"* ]]; then
            has_elixir=true
            break
        fi
    done

    if [[ "$has_elixir" == true ]]; then
        warning compilation_warning
    fi

    # CI 模式：自動執行不詢問
    if [[ "$CI_MODE" == true ]]; then
        info installing_languages_ci
        echo ""

        if mise install; then
            success languages_complete
        else
            error mise_failed
            echo ""
            message possible_causes
            message build_dependencies_missing
            message disk_full 2
            message network_issue 3
            echo ""
            message debug_steps
            message run_doctor
            message manual_install
            message verbose_install
            echo ""
            translate press_enter_close
            read -p "$REPLY"
            exit 1
        fi
        return
    fi

    echo ""
    translate install_prompt
    read -p "$REPLY" install_now
    install_now=${install_now:-Y}

    if [[ "$install_now" =~ ^[Yy]$ ]]; then
        info installing_languages
        echo ""

        if mise install; then
            success languages_complete
        else
            error mise_failed
            echo ""
            message possible_causes
            message build_dependencies_missing
            message disk_full 2
            message network_issue 3
            echo ""
            message debug_steps
            message run_doctor
            message manual_install
            message verbose_install
            echo ""
            warning install_later
            echo ""
            translate press_enter_continue
            read -p "$REPLY"
        fi
    else
        info install_skipped
    fi
}

# 主程式
main() {
    resolve_locale "$@" || exit 1
    parse_arguments "$@"

    echo ""
    echo "=========================================="
    message banner
    echo "=========================================="
    echo ""

    if [[ "$DRY_RUN" == true ]]; then
        info dry_notice
        echo ""
    fi

    check_homebrew
    install_tools
    select_languages

    if [[ "$DRY_RUN" == true ]]; then
        dry_info
        exit 0
    fi

    generate_mise_config
    setup_mise_activate
    prompt_mise_install

    echo ""
    echo "=========================================="
    success installation_complete
    echo "=========================================="
    echo ""
    info next_steps
    message restart_shell
    message verify_installation
    message check_versions
    echo ""
}

# Check if we're source the file or execute it directly
# check by `return` work for bash and zsh
(return 0 2>/dev/null) && sourced=1 || sourced=0

if [ $sourced -eq 0 ]; then
    main "$@"
fi
