#!/bin/bash

# 測試 setup.sh 中的特定函式
# 可以在 bash 或 zsh 中執行

# 載入 setup.sh 的所有函式（不執行 main）
source ./setup.sh

# 顏色定義（如果還沒定義）
CYAN='\033[0;36m'
NC='\033[0m'

echo "=========================================="
echo "  測試 tsunpi 函式"
echo "=========================================="
echo ""

# ============================================
# 測試 expand_elixir_to_erlang 函式
# ============================================
echo -e "${CYAN}測試 expand_elixir_to_erlang:${NC}"
echo ""

test_cases=(
    "python,elixir,node"
    "elixir"
    "erlang,elixir"
    "python,erlang,elixir,rust"
    "ruby,elixir,python"
    "python,node"
    "elixir,python,elixir"
)

for test in "${test_cases[@]}"; do
    result=$(expand_elixir_to_erlang "$test")
    echo "輸入: $test"
    echo "輸出: $result"
    echo ""
done

# ============================================
# 測試語言選擇邏輯
# ============================================
echo ""
echo -e "${CYAN}測試語言選擇邏輯:${NC}"
echo ""

echo "1. 預設值測試"
INTERACTIVE=false
CUSTOM_LANGS=""
DEFAULT_LANGS="python,elixir,node"
select_languages
echo "結果: $SELECTED_LANGS"
echo ""

echo "2. 自訂語言測試"
CUSTOM_LANGS="python,rust"
select_languages
echo "結果: $SELECTED_LANGS"
echo ""

echo "3. 只選 Elixir"
CUSTOM_LANGS="elixir"
select_languages
echo "結果: $SELECTED_LANGS"
echo ""

echo "4. 已包含 Erlang"
CUSTOM_LANGS="erlang,python"
select_languages
echo "結果: $SELECTED_LANGS"
echo ""

# ============================================
# 測試 config.toml 產生（預覽模式）
# ============================================
echo ""
echo -e "${CYAN}測試 config.toml 產生預覽:${NC}"
echo ""

CUSTOM_LANGS="python,elixir,rust"
select_languages

echo "[tools]"
IFS=',' read -ra LANGS <<< "$SELECTED_LANGS"
for lang in "${LANGS[@]}"; do
    lang=$(echo "$lang" | xargs)
    echo "$lang = \"latest\""
done
echo ""

# Locale routing is checked against live explicit-locale output, not fixed wording.
# Each invocation is a dry run; no tools or user configuration are changed.
locale_output() (
    unset TSUNPI_LOCALE LC_ALL LC_MESSAGES LANG
    while [[ "$1" != -- ]]; do
        export "$1"
        shift
    done
    shift
    /bin/bash ./setup.sh --dry --langs=python,rust "$@"
)

assert_locale_output() {
    local expected="$1"
    local description="$2"
    local actual
    shift 2
    if ! actual=$(locale_output "$@"); then
        printf 'FAIL: %s (command failed)\n' "$description" >&2
        exit 1
    fi
    if [[ "$actual" != "$expected" ]]; then
        printf 'FAIL: %s\n' "$description" >&2
        exit 1
    fi
}

english_output=$(locale_output -- --locale=en) || exit 1
chinese_output=$(locale_output -- --locale=zh-TW) || exit 1
if [[ "$english_output" == "$chinese_output" ]]; then
    printf 'FAIL: switching locale did not change the interface\n' >&2
    exit 1
fi
assert_locale_output "$english_output" "English fallback without a locale" --
assert_locale_output "$chinese_output" "LANG normalization" LANG=zh_TW.UTF-8 --
assert_locale_output "$english_output" "LC_MESSAGES overrides LANG" LC_MESSAGES=en_US.UTF-8 LANG=zh_TW.UTF-8 --
assert_locale_output "$chinese_output" "LC_ALL overrides LC_MESSAGES" LC_ALL=zh_TW.UTF-8 LC_MESSAGES=en_US.UTF-8 --
assert_locale_output "$english_output" "Unsupported first locale does not fall through" LC_ALL=C LANG=zh_TW.UTF-8 --
assert_locale_output "$chinese_output" "Empty system locales are skipped" LC_ALL= LC_MESSAGES= LANG=zh_TW.UTF-8 --
assert_locale_output "$chinese_output" "Application locale overrides system locale" TSUNPI_LOCALE=ZH_hAnT_TW.UTF-8@custom LC_ALL=C --
assert_locale_output "$english_output" "CLI overrides invalid application locale" TSUNPI_LOCALE=unsupported LANG=zh_TW.UTF-8 -- --locale=en

# A locale flag after an invalid argument must still determine the error language.
for locale in en zh-TW; do
    if error_before=$(locale_output -- "--locale=$locale" --invalid 2>&1); then
        printf 'FAIL: unknown argument accepted\n' >&2
        exit 1
    fi
    if error_after=$(locale_output -- --invalid "--locale=$locale" 2>&1); then
        printf 'FAIL: unknown argument accepted\n' >&2
        exit 1
    fi
    if [[ "$error_before" != "$error_after" ]]; then
        printf 'FAIL: error locale depends on argument order\n' >&2
        exit 1
    fi
done

if locale_output -- --locale=unsupported >/dev/null 2>&1 ||
   locale_output -- --locale= >/dev/null 2>&1 ||
   locale_output TSUNPI_LOCALE=unsupported -- >/dev/null 2>&1 ||
   locale_output TSUNPI_LOCALE= -- >/dev/null 2>&1; then
    printf 'FAIL: unsupported explicit locale accepted\n' >&2
    exit 1
fi
printf 'PASS: locale precedence, normalization, fallback, and argument errors\n'

# Observe installation requests at the Homebrew boundary without installing tools.
package_installation() (
    parse_arguments "$@"
    command_exists() {
        [[ " ${AVAILABLE_TOOLS:-} " == *" $1 "* ]]
    }
    brew() {
        printf '%s\n' "$2" >&3
        [[ "$2" != "${FAILING_PACKAGE:-}" ]]
    }
    install_tools 3>&1 >/dev/null
)

assert_package_installation() {
    local expected="$1"
    local description="$2"
    local actual
    shift 2
    if ! actual=$(package_installation "$@"); then
        printf 'FAIL: %s (installation failed)\n' "$description" >&2
        exit 1
    fi
    if [[ "$actual" != "$expected" ]]; then
        printf 'FAIL: %s\n' "$description" >&2
        exit 1
    fi
}

assert_package_installation $'git\nmise\nripgrep\nfzf\nfd\nuv\nstow\nzoxide' "Default package installation"
assert_package_installation $'git\nmise' "none preserves required packages" --packages=none
assert_package_installation $'git\nmise\nzoxide\nstow' "Explicit selection excludes unselected tools and deduplicates" --packages=zoxide,git,stow,zoxide,mise
AVAILABLE_TOOLS="git mise rg" assert_package_installation fd "Existing rg satisfies ripgrep" --packages=ripgrep,fd
FAILING_PACKAGE=fd assert_package_installation $'git\nmise\nfd\nzoxide' "Optional failure does not stop later tools" --packages=fd,zoxide
if failed_install=$(FAILING_PACKAGE=git package_installation --packages=zoxide 2>/dev/null); then
    printf 'FAIL: required package failure did not abort\n' >&2
    exit 1
fi
if [[ "$failed_install" != git ]]; then
    printf 'FAIL: installation continued after required package failure\n' >&2
    exit 1
fi

for invalid_packages in "" "unknown" "fzf," "none,fzf"; do
    if rejected_install=$(package_installation "--packages=$invalid_packages" 2>/dev/null); then
        printf 'FAIL: invalid package list accepted: %s\n' "$invalid_packages" >&2
        exit 1
    fi
    if [[ -n "$rejected_install" ]]; then
        printf 'FAIL: invalid package list caused installation\n' >&2
        exit 1
    fi
done

ci_packages_output=$(locale_output -- --locale=en --packages=none --ci) || exit 1
assert_locale_output "$ci_packages_output" "CI skips both interactive menus" -- --locale=en --packages=none --interactive --ci
printf 'PASS: package selection, required tools, executable detection, failure handling, and CI precedence\n'

echo "=========================================="
echo "  測試完成"
echo "=========================================="
