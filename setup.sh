#!/bin/bash
# v2.1.0

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 預設語言清單
DEFAULT_LANGS="python,elixir,node"

# Homebrew 本身由 check_homebrew 管理；套件清單同時用於驗證與安裝。
REQUIRED_PACKAGES=(git mise)
OPTIONAL_PACKAGES=(ripgrep fzf fd uv stow zoxide)

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
        en:usage) format='Usage: %s [--locale=en|zh-TW] [--brewfile=PATH] [--mise-config=PATH] [--no-rc] [--packages=ripgrep,fzf,...|none] [--langs=python,node,rust] [--interactive] [--dry] [-h|--help]' ;;
        zh-TW:usage) format='用法: %s [--locale=en|zh-TW] [--brewfile=PATH] [--mise-config=PATH] [--no-rc] [--packages=ripgrep,fzf,...|none] [--langs=python,node,rust] [--interactive] [--dry] [-h|--help]' ;;
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
        en:selected_languages) format='Language environments to install: %s' ;;
        zh-TW:selected_languages) format='將安裝以下語言環境: %s' ;;
        en:dry_summary) format='Dry-run summary' ;;
        zh-TW:dry_summary) format='Dry run 摘要' ;;
        en:dry_homebrew) format='Install Homebrew: %s' ;;
        zh-TW:dry_homebrew) format='將安裝 Homebrew: %s' ;;
        en:dry_languages) format='Language environments to install:' ;;
        zh-TW:dry_languages) format='將安裝的語言環境:' ;;
        en:brewfile_preview) format='Brewfile preview:' ;;
        zh-TW:brewfile_preview) format='Brewfile 預覽:' ;;
        en:brewfile_location) format='  Location: %s' ;;
        zh-TW:brewfile_location) format='  位置: %s' ;;
        en:brewfile_contents) format='  Contents:' ;;
        zh-TW:brewfile_contents) format='  內容:' ;;
        en:installing_brewfile) format='Installing Homebrew bundle from %s...' ;;
        zh-TW:installing_brewfile) format='從 %s 安裝 Homebrew bundle...' ;;
        en:brewfile_complete) format='Homebrew bundle installation complete' ;;
        zh-TW:brewfile_complete) format='Homebrew bundle 安裝完成' ;;
        en:brewfile_failed) format='Homebrew bundle installation failed' ;;
        zh-TW:brewfile_failed) format='Homebrew bundle 安裝失敗' ;;
        en:brewfile_not_found) format='Brewfile not found: %s' ;;
        zh-TW:brewfile_not_found) format='找不到 Brewfile: %s' ;;
        en:mise_config_not_found) format='mise configuration file not found: %s' ;;
        zh-TW:mise_config_not_found) format='找不到 mise 設定檔: %s' ;;
        en:config_preview) format='mise configuration preview:' ;;
        zh-TW:config_preview) format='mise 設定檔預覽:' ;;
        en:config_location) format='  Location: ~/.config/mise/conf.d/tsunpi.toml' ;;
        zh-TW:config_location) format='  位置: ~/.config/mise/conf.d/tsunpi.toml' ;;
        en:config_contents) format='  Contents:' ;;
        zh-TW:config_contents) format='  內容:' ;;
        en:dry_complete) format='Dry run complete; nothing was installed' ;;
        zh-TW:dry_complete) format='Dry run 完成，未進行實際安裝' ;;
        en:generating_config) format='Generating mise configuration...' ;;
        zh-TW:generating_config) format='產生 mise 設定檔...' ;;
        en:config_created) format='Configuration created: %s' ;;
        zh-TW:config_created) format='設定檔已建立: %s' ;;
        en:setting_shell) format='Configuring mise shell integration...' ;;
        zh-TW:setting_shell) format='設定 mise shell 整合...' ;;
        en:unknown_shell) format='Unable to detect the shell; configure mise activate manually' ;;
        zh-TW:unknown_shell) format='無法偵測 shell 類型，請手動設定 mise activate' ;;
        en:shell_configured) format='mise activate is already configured in %s' ;;
        zh-TW:shell_configured) format='mise activate 已設定於 %s' ;;
        en:shell_written) format='Updated %s' ;;
        zh-TW:shell_written) format='已寫入 %s' ;;
        en:mise_configured) format='mise configuration complete' ;;
        zh-TW:mise_configured) format='mise 設定完成' ;;
        en:compilation_warning) format='Note: compiling Erlang/Elixir may take 20–40 minutes' ;;
        zh-TW:compilation_warning) format='注意: Erlang/Elixir 編譯可能需要 20–40 分鐘' ;;
        en:installing_languages) format='Installing language environments...' ;;
        zh-TW:installing_languages) format='開始安裝語言環境...' ;;
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
        en:invalid_package_list) format='Invalid package list: %s (use comma-separated names without spaces, or none)' ;;
        zh-TW:invalid_package_list) format='無效的套件清單: %s（請使用逗號分隔名稱、不含空白，或使用 none）' ;;
        en:unknown_package) format='Unsupported package: %s' ;;
        zh-TW:unknown_package) format='不支援的套件: %s' ;;
        en:required_packages) format='Required Homebrew packages:' ;;
        zh-TW:required_packages) format='必要的 Homebrew 套件:' ;;
        en:optional_packages) format='Selected optional Homebrew packages:' ;;
        zh-TW:optional_packages) format='選定的額外 Homebrew 套件:' ;;
        en:no_optional_packages) format='  (none)' ;;
        zh-TW:no_optional_packages) format='  （無）' ;;
        en:required_tool_failed) format='Required package %s failed to install; installation aborted' ;;
        zh-TW:required_tool_failed) format='必要套件 %s 安裝失敗，安裝中止' ;;
        en:unknown_mise_tools) format='Unknown mise tools: %s — see https://mise.jdx.dev/registry.html' ;;
        zh-TW:unknown_mise_tools) format='mise 不認識這些工具：%s — 參考 https://mise.jdx.dev/registry.html' ;;
        en:dry_validate_tools) format='Would validate mise tools against registry' ;;
        zh-TW:dry_validate_tools) format='將向 registry 驗證 mise 工具' ;;
        en:required_packages_notice) format='Homebrew and these packages are required: %s' ;;
        zh-TW:required_packages_notice) format='Homebrew 與以下套件為必要工具: %s' ;;
        en:package_menu) format='Select optional packages (enter numbers, e.g. 126)' ;;
        zh-TW:package_menu) format='請選擇額外套件 (輸入數字組合，例如 126)' ;;
        en:package_menu_default) format='Press Enter to select all; enter 0 for no optional packages' ;;
        zh-TW:package_menu_default) format='直接按 Enter 選擇全部；輸入 0 不選額外套件' ;;
        en:package_prompt) format='Package selection: ' ;;
        zh-TW:package_prompt) format='套件選擇: ' ;;
        en:invalid_package_selection) format='Invalid package selection: %s' ;;
        zh-TW:invalid_package_selection) format='無效的套件選擇: %s' ;;
        en:package_input_failed) format='Unable to read package selection from the terminal; use --packages instead' ;;
        zh-TW:package_input_failed) format='無法從終端機讀取套件選擇；請改用 --packages' ;;
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
        en:language_input_failed) format='Unable to read language selection from the terminal; use --langs instead' ;;
        zh-TW:language_input_failed) format='無法從終端機讀取語言選擇；請改用 --langs' ;;
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
    local requested="${TSUNPI_LOCALE-}"
    local explicit="${TSUNPI_LOCALE+x}"
    UI_LOCALE=en
    if normalize_locale "${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}"; then
        UI_LOCALE="$REPLY"
    fi

    # 先掃描語系，讓參數錯誤不受 --locale 所在位置影響。
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --locale=*)
                requested="${1#*=}"
                explicit=x
                shift
                ;;
            --locale)
                if [[ $# -ge 2 ]]; then
                    requested="$2"
                    explicit=x
                    shift 2
                else
                    requested=""
                    explicit=x
                    shift
                fi
                ;;
            *)
                shift
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
    CUSTOM_LANGS=""
    INTERACTIVE=false
    DRY_RUN=false
    NO_RC=false
    BREWFILE_PATH=""
    MISE_CONFIG_PATH=""
    PACKAGES_SPECIFIED=false
    SELECTED_PACKAGES=("${OPTIONAL_PACKAGES[@]}")

    while [[ $# -gt 0 ]]; do
        case $1 in
            --locale=*)
                shift
                ;;
            --locale)
                shift 2
                ;;
            --brewfile=*)
                BREWFILE_PATH="${1#*=}"
                shift
                ;;
            --brewfile)
                if [[ $# -ge 2 ]]; then
                    BREWFILE_PATH="$2"
                    shift 2
                else
                    error unknown_argument "$1" >&2
                    message usage "$0" >&2
                    exit 1
                fi
                ;;
            --mise-config=*)
                MISE_CONFIG_PATH="${1#*=}"
                shift
                ;;
            --mise-config)
                if [[ $# -ge 2 ]]; then
                    MISE_CONFIG_PATH="$2"
                    shift 2
                else
                    error unknown_argument "$1" >&2
                    message usage "$0" >&2
                    exit 1
                fi
                ;;
            --no-rc)
                NO_RC=true
                shift
                ;;
            --packages=*)
                parse_packages "${1#*=}" || exit 1
                PACKAGES_SPECIFIED=true
                shift
                ;;
            --packages)
                if [[ $# -ge 2 ]]; then
                    parse_packages "$2" || exit 1
                    PACKAGES_SPECIFIED=true
                    shift 2
                else
                    error unknown_argument "$1" >&2
                    message usage "$0" >&2
                    exit 1
                fi
                ;;
            --langs=*)
                CUSTOM_LANGS="${1#*=}"
                shift
                ;;
            --langs)
                if [[ $# -ge 2 ]]; then
                    CUSTOM_LANGS="$2"
                    shift 2
                else
                    error unknown_argument "$1" >&2
                    message usage "$0" >&2
                    exit 1
                fi
                ;;
            --languages=*)
                CUSTOM_LANGS="${1#*=}"
                shift
                ;;
            --languages)
                if [[ $# -ge 2 ]]; then
                    CUSTOM_LANGS="$2"
                    shift 2
                else
                    error unknown_argument "$1" >&2
                    message usage "$0" >&2
                    exit 1
                fi
                ;;
            --interactive)
                INTERACTIVE=true
                shift
                ;;
            --ci)
                # v2.0 相容：v2.1 起預設即為非互動，此旗標無作用。
                shift
                ;;
            --dry)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                message usage "$0"
                exit 0
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
        exit 1
    fi
}

# 驗證明確指定的清單；必要套件可重複列出，但無法排除。
parse_packages() {
    local requested="$1"
    local package
    local packages=()
    SELECTED_PACKAGES=()

    if [[ "$requested" == none ]]; then
        return 0
    fi
    if [[ ! "$requested" =~ ^[a-z]+(,[a-z]+)*$ ]]; then
        error invalid_package_list "$requested" >&2
        return 1
    fi

    local old_ifs="$IFS"
    IFS=','
    packages=($requested)
    IFS="$old_ifs"
    for package in "${packages[@]}"; do
        if [[ " ${REQUIRED_PACKAGES[*]} " == *" $package "* ]]; then
            continue
        fi
        if [[ " ${OPTIONAL_PACKAGES[*]} " != *" $package "* ]]; then
            error unknown_package "$package" >&2
            return 1
        fi
        if [[ " ${SELECTED_PACKAGES[*]} " != *" $package "* ]]; then
            SELECTED_PACKAGES+=("$package")
        fi
    done
}

# 互動式選擇額外套件；--packages 與 --brewfile 優先於選單
select_packages_interactive() {
    local choice digit index i
    local packages=""
    echo "" >&2
    message required_packages_notice "${REQUIRED_PACKAGES[*]}" >&2
    message package_menu >&2
    message package_menu_default >&2
    for (( i=0; i<${#OPTIONAL_PACKAGES[@]}; i++ )); do
        printf '%s) %s\n' "$((i + 1))" "${OPTIONAL_PACKAGES[$i]}" >&2
    done
    echo "" >&2
    translate package_prompt
    if ! IFS= read -r -p "$REPLY" choice < /dev/tty; then
        error package_input_failed >&2
        return 1
    fi

    case "$choice" in
        "")
            SELECTED_PACKAGES=("${OPTIONAL_PACKAGES[@]}")
            return 0
            ;;
        0)
            SELECTED_PACKAGES=()
            return 0
            ;;
    esac

    for (( i=0; i<${#choice}; i++ )); do
        digit="${choice:$i:1}"
        if [[ "$digit" != [1-9] ]] || (( digit > ${#OPTIONAL_PACKAGES[@]} )); then
            error invalid_package_selection "$choice" >&2
            return 1
        fi
        index=$((digit - 1))
        packages="${packages:+$packages,}${OPTIONAL_PACKAGES[$index]}"
    done
    parse_packages "$packages"
}

select_packages() {
    if [[ "$INTERACTIVE" == true && "$PACKAGES_SPECIFIED" != true && -z "$BREWFILE_PATH" ]]; then
        select_packages_interactive || return 1
    fi
}

# 安裝 Brewfile
install_brewfile() {
    if [[ "$DRY_RUN" == true ]]; then
        return 0
    fi

    info installing_brewfile "$BREWFILE_PATH"

    if [[ ! -f "$BREWFILE_PATH" ]]; then
        error brewfile_not_found "$BREWFILE_PATH" >&2
        return 1
    fi

    if brew bundle --file="$BREWFILE_PATH"; then
        success brewfile_complete
    else
        error brewfile_failed >&2
        return 1
    fi
}

# 安裝基礎工具
install_tools() {
    local tool
    local executable

    if [[ "$DRY_RUN" == true ]]; then
        return 0
    fi

    info installing_tools

    for tool in "${REQUIRED_PACKAGES[@]}"; do
        executable="$tool"
        if command_exists "$executable"; then
            success tool_installed "$tool"
        else
            info installing_tool "$tool"
            if brew install "$tool"; then
                success tool_complete "$tool"
            else
                error required_tool_failed "$tool" >&2
                return 1
            fi
        fi
    done

    if [[ -n "$BREWFILE_PATH" ]]; then
        install_brewfile || return 1
    else
        for tool in "${SELECTED_PACKAGES[@]}"; do
            executable="$tool"
            if [[ "$tool" == ripgrep ]]; then
                executable=rg
            fi
            if command_exists "$executable"; then
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
    fi
}

# 互動式選擇語言（輸出逗號分隔清單）
select_languages_interactive() {
    local choice digit i
    local langs=()
    local seen=()

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
    if ! IFS= read -r -p "$REPLY" choice < /dev/tty; then
        error language_input_failed >&2
        return 1
    fi

    if [[ -z "$choice" ]]; then
        echo "$DEFAULT_LANGS"
        return 0
    fi

    for (( i=0; i<${#choice}; i++ )); do
        digit="${choice:$i:1}"
        if [[ " ${seen[*]} " == *" $digit "* ]]; then
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
            *) warning invalid_selection "$digit" >&2 ;;
        esac
    done

    if [[ ${#langs[@]} -eq 0 ]]; then
        warning no_languages >&2
        echo "$DEFAULT_LANGS"
    else
        local old_ifs="$IFS"
        IFS=','
        echo "${langs[*]}"
        IFS="$old_ifs"
    fi
}

# 選擇要安裝的語言；--langs 與 --mise-config 優先於互動選單
select_languages() {
    if [[ -n "$MISE_CONFIG_PATH" ]]; then
        SELECTED_LANGS=""
        return 0
    fi

    if [[ -n "$CUSTOM_LANGS" ]]; then
        SELECTED_LANGS="$CUSTOM_LANGS"
    elif [[ "$INTERACTIVE" == true ]]; then
        SELECTED_LANGS=$(select_languages_interactive) || exit 1
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
    local lang

    local old_ifs="$IFS"
    IFS=','
    local LANG_ARRAY=($langs)
    IFS="$old_ifs"

    for lang in "${LANG_ARRAY[@]}"; do
        lang=$(echo "$lang" | xargs)  # trim whitespace

        # 如果是 elixir，先加入 erlang
        if [[ "$lang" == "elixir" ]]; then
            if [[ -n "$result" ]]; then
                result="$result,erlang,elixir"
            else
                result="erlang,elixir"
            fi
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
  message required_packages
  printf '  - %s\n' "${REQUIRED_PACKAGES[@]}"

  if [[ -n "$BREWFILE_PATH" ]]; then
      echo ""
      message brewfile_preview
      message brewfile_location "$BREWFILE_PATH"
      message brewfile_contents
      if [[ -f "$BREWFILE_PATH" ]]; then
          sed 's/^/    /' "$BREWFILE_PATH"
      else
          printf '    (file: %s)\n' "$BREWFILE_PATH"
      fi
  else
      echo ""
      message optional_packages
      if [[ ${#SELECTED_PACKAGES[@]} -eq 0 ]]; then
          message no_optional_packages
      else
          printf '  - %s\n' "${SELECTED_PACKAGES[@]}"
      fi
  fi

  if [[ -n "$MISE_CONFIG_PATH" ]]; then
      echo ""
      message config_preview
      message config_location
      message config_contents
      if [[ -f "$MISE_CONFIG_PATH" ]]; then
          sed 's/^/    /' "$MISE_CONFIG_PATH"
      else
          printf '    (file: %s)\n' "$MISE_CONFIG_PATH"
      fi
  else
      echo ""
      message dry_languages
      local old_ifs="$IFS"
      IFS=','
      local LANGS=($SELECTED_LANGS)
      IFS="$old_ifs"
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
  fi
  echo ""
  validate_mise_tools
  echo ""
  info dry_complete
}

# 產生或複製 mise 設定檔至 conf.d/tsunpi.toml
write_mise_conf() {
    local config_dir="$HOME/.config/mise/conf.d"
    local config_file="$config_dir/tsunpi.toml"

    info generating_config

    mkdir -p "$config_dir"

    if [[ -n "$MISE_CONFIG_PATH" ]]; then
        if [[ ! -f "$MISE_CONFIG_PATH" ]]; then
            error mise_config_not_found "$MISE_CONFIG_PATH" >&2
            return 1
        fi
        cp "$MISE_CONFIG_PATH" "$config_file"
    else
        cat > "$config_file" << EOF
# Generated by tsunpi
# $(date)

[tools]
EOF
        local old_ifs="$IFS"
        IFS=','
        local LANGS=($SELECTED_LANGS)
        IFS="$old_ifs"
        for lang in "${LANGS[@]}"; do
            lang=$(echo "$lang" | xargs) # trim whitespace
            echo "$lang = \"latest\"" >> "$config_file"
        done
    fi

    success config_created "$config_file"
}

# 驗證 mise 設定檔中的工具清單是否皆存在於 registry
validate_mise_tools() {
    if [[ "$DRY_RUN" == true ]]; then
        message dry_validate_tools
        return 0
    fi

    local config_file="${1:-$HOME/.config/mise/conf.d/tsunpi.toml}"
    if [[ ! -f "$config_file" ]]; then
        return 0
    fi

    local in_tools=false
    local tools=()
    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%$'\r'}"
        local trimmed="${line#"${line%%[![:space:]]*}"}"
        trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"

        if [[ "$trimmed" =~ ^\[[[:space:]]*([^]]+)[[:space:]]*\] ]]; then
            local section="${BASH_REMATCH[1]}"
            section="${section#"${section%%[![:space:]]*}"}"
            section="${section%"${section##*[![:space:]]}"}"
            if [[ "$section" == "tools" ]]; then
                in_tools=true
            else
                in_tools=false
            fi
            continue
        fi

        if [[ "$in_tools" != true ]]; then
            continue
        fi

        if [[ -z "$trimmed" || "$trimmed" == \#* ]]; then
            continue
        fi

        if [[ "$line" == *"="* ]]; then
            local key="${line%%=*}"
            key="${key#"${key%%[![:space:]]*}"}"
            key="${key%"${key##*[![:space:]]}"}"
            key="${key#\"}"
            key="${key%\"}"
            key="${key#\'}"
            key="${key%\'}"
            if [[ -n "$key" ]]; then
                tools+=("$key")
            fi
        fi
    done < "$config_file"

    if [[ ${#tools[@]} -eq 0 ]]; then
        return 0
    fi

    local mise_cmd="${TSUNPI_MISE_EXEC:-mise}"
    local registry_output
    registry_output=$("$mise_cmd" registry 2>/dev/null | awk 'NF {print $1}')

    local padded_registry=$'\n'"$registry_output"$'\n'
    local unknown_tools=()
    local tool
    for tool in "${tools[@]}"; do
        if [[ "$padded_registry" != *$'\n'"$tool"$'\n'* ]]; then
            local padded_unknown=$'\n'"$(printf '%s\n' "${unknown_tools[@]}")"$'\n'
            if [[ "$padded_unknown" != *$'\n'"$tool"$'\n'* ]]; then
                unknown_tools+=("$tool")
            fi
        fi
    done

    if [[ ${#unknown_tools[@]} -gt 0 ]]; then
        local old_ifs="$IFS"
        IFS=', '
        local unknown_str="${unknown_tools[*]}"
        IFS="$old_ifs"
        error unknown_mise_tools "$unknown_str" >&2
        exit 1
    fi
}

# 設定 mise activate
setup_mise_activate() {
    if [[ "$NO_RC" == true ]]; then
        return 0
    fi

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
        return 0
    fi

    local activate_cmd="eval \"\$(mise activate $shell_name)\""

    # 檢查是否已經設定
    if [[ -f "$rc_file" ]] && grep -q "mise activate" "$rc_file"; then
        success shell_configured "$rc_file"
        return 0
    fi

    echo "" >> "$rc_file"
    echo "# mise - added by tsunpi" >> "$rc_file"
    echo "$activate_cmd" >> "$rc_file"
    success shell_written "$rc_file"

    eval "$activate_cmd" 2>/dev/null || true
}

# 執行 mise install
prompt_mise_install() {
    if [[ "$DRY_RUN" == true ]]; then
        return 0
    fi

    echo ""
    info mise_configured

    local old_ifs="$IFS"
    IFS=','
    local LANGS=($SELECTED_LANGS)
    IFS="$old_ifs"
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

    info installing_languages
    echo ""

    local mise_bin="${TSUNPI_MISE_EXEC:-mise}"
    if "$mise_bin" install; then
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
        exit 1
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

    select_packages || exit 1
    select_languages
    check_homebrew
    install_tools || exit 1

    if [[ "$DRY_RUN" == true ]]; then
        dry_info
        exit 0
    fi

    write_mise_conf || exit 1
    validate_mise_tools || exit 1
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

# Check if we're sourcing the file or executing it directly
# check by `return` work for bash and zsh
(return 0 2>/dev/null) && sourced=1 || sourced=0

if [ $sourced -eq 0 ]; then
    main "$@"
fi
