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
# 測試 tsunpi.toml 產生（預覽模式）
# ============================================
echo ""
echo -e "${CYAN}測試 tsunpi.toml 產生預覽:${NC}"
echo ""

CUSTOM_LANGS="python,elixir,rust"
select_languages

echo "[tools]"
(
    IFS=','
    langs=($SELECTED_LANGS)
    for lang in "${langs[@]}"; do
        lang=$(echo "$lang" | xargs)
        echo "$lang = \"latest\""
    done
)
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
printf 'PASS: package selection, required tools, executable detection, and failure handling\n'

# --ci 自 v2.1 起無作用，但舊指令仍須被接受
ci_output=$(locale_output -- --locale=en --packages=none --ci) || exit 1
assert_locale_output "$ci_output" "--ci is accepted as a no-op" -- --locale=en --packages=none

# --interactive 在套件與語言都已由旗標指定時不需要終端機（stdin 關閉也能完成）
if ! interactive_flags_output=$(locale_output -- --locale=en --packages=none --langs=python --interactive </dev/null); then
    printf 'FAIL: --interactive prompted although --packages and --langs were given\n' >&2
    exit 1
fi
assert_locale_output "$interactive_flags_output" "--interactive defers to explicit flags" -- --locale=en --packages=none --langs=python
printf 'PASS: --ci compatibility and --interactive precedence\n'

# ============================================
# 測試 --brewfile、--mise-config、--no-rc 與 conf.d
# ============================================
echo ""
echo -e "${CYAN}測試 --brewfile、--mise-config 與 --no-rc:${NC}"
echo ""

TEST_TMPDIR=$(mktemp -d)
trap 'rm -rf "$TEST_TMPDIR"' EXIT

# 1. 測試 --brewfile 調用 brew bundle --file=... (mock brew via PATH)
BREW_MOCK_DIR="$TEST_TMPDIR/mock_bin"
mkdir -p "$BREW_MOCK_DIR"
BREW_INVOCATIONS="$TEST_TMPDIR/brew_invocations.log"
cat > "$BREW_MOCK_DIR/brew" << 'EOF'
#!/bin/bash
printf '%s\n' "$*" >> "$BREW_INVOCATIONS"
EOF
chmod +x "$BREW_MOCK_DIR/brew"

TEST_BREWFILE="$TEST_TMPDIR/Brewfile"
echo 'brew "ripgrep"' > "$TEST_BREWFILE"

# dry run 不應該呼叫 brew bundle
(
    export PATH="$BREW_MOCK_DIR:$PATH"
    export BREW_INVOCATIONS
    /bin/bash ./setup.sh --brewfile="$TEST_BREWFILE" --no-rc --dry >/dev/null
)
if [[ -f "$BREW_INVOCATIONS" ]]; then
    printf 'FAIL: dry run invoked brew\n' >&2
    exit 1
fi

# 非 dry run 下 install_tools 調用 brew bundle --file=...
(
    export PATH="$BREW_MOCK_DIR:$PATH"
    export BREW_INVOCATIONS
    /bin/bash -c "
        source ./setup.sh
        parse_arguments --brewfile=\"$TEST_BREWFILE\"
        command_exists() { return 0; }
        install_tools
    " >/dev/null
)

expected_bundle_call="bundle --file=$TEST_BREWFILE"
if ! grep -Fq "$expected_bundle_call" "$BREW_INVOCATIONS" 2>/dev/null; then
    printf 'FAIL: --brewfile did not invoke brew bundle with expected arguments\n' >&2
    printf 'Got:\n' >&2
    cat "$BREW_INVOCATIONS" 2>/dev/null >&2
    exit 1
fi
printf 'PASS: --brewfile invokes brew bundle --file=...\n'

# 2. 測試 --mise-config 逐字複製至 $HOME/.config/mise/conf.d/tsunpi.toml 且永不寫入 config.toml
TEST_HOME="$TEST_TMPDIR/home"
mkdir -p "$TEST_HOME"

TEST_MISE_SRC="$TEST_TMPDIR/custom_mise.toml"
cat > "$TEST_MISE_SRC" << 'EOF'
# custom mise config for test
[tools]
python = "3.12"
node = "20"
rust = "1.80.0"
EOF

(
    export HOME="$TEST_HOME"
    source ./setup.sh
    parse_arguments --mise-config="$TEST_MISE_SRC"
    write_mise_conf >/dev/null
)

CONF_TARGET="$TEST_HOME/.config/mise/conf.d/tsunpi.toml"
OLD_CONFIG="$TEST_HOME/.config/mise/config.toml"

if [[ ! -f "$CONF_TARGET" ]]; then
    printf 'FAIL: --mise-config was not written to %s\n' "$CONF_TARGET" >&2
    exit 1
fi

if ! cmp -s "$TEST_MISE_SRC" "$CONF_TARGET"; then
    printf 'FAIL: %s was not copied verbatim from %s\n' "$CONF_TARGET" "$TEST_MISE_SRC" >&2
    exit 1
fi

if [[ -f "$OLD_CONFIG" ]]; then
    printf 'FAIL: config.toml was created but should never be written\n' >&2
    exit 1
fi

# 測試預設語言產生至 conf.d/tsunpi.toml 且永不寫入 config.toml
rm -f "$CONF_TARGET"
(
    export HOME="$TEST_HOME"
    source ./setup.sh
    parse_arguments --langs=python,node
    select_languages >/dev/null
    write_mise_conf >/dev/null
)

if [[ ! -f "$CONF_TARGET" ]]; then
    printf 'FAIL: default config was not written to %s\n' "$CONF_TARGET" >&2
    exit 1
fi

if [[ -f "$OLD_CONFIG" ]]; then
    printf 'FAIL: config.toml was created on default generation but should never be written\n' >&2
    exit 1
fi

if ! grep -q 'python = "latest"' "$CONF_TARGET" || ! grep -q 'node = "latest"' "$CONF_TARGET"; then
    printf 'FAIL: default config does not contain expected tools\n' >&2
    exit 1
fi
printf 'PASS: --mise-config copied verbatim to conf.d/tsunpi.toml and config.toml never written\n'

# 3. 測試 --no-rc 保持 rc 檔不被修改
RC_TEST_HOME="$TEST_TMPDIR/rc_home"
mkdir -p "$RC_TEST_HOME"
TEST_ZSHRC="$RC_TEST_HOME/.zshrc"
echo "# existing zshrc" > "$TEST_ZSHRC"

(
    export HOME="$RC_TEST_HOME"
    export SHELL="/bin/zsh"
    source ./setup.sh
    parse_arguments --no-rc
    setup_mise_activate >/dev/null
)

if grep -q "mise activate" "$TEST_ZSHRC"; then
    printf 'FAIL: --no-rc modified rc file\n' >&2
    exit 1
fi

# 驗證沒有 --no-rc 時會寫入且冪等
(
    export HOME="$RC_TEST_HOME"
    export SHELL="/bin/zsh"
    source ./setup.sh
    parse_arguments
    setup_mise_activate >/dev/null
)

if ! grep -q "mise activate" "$TEST_ZSHRC"; then
    printf 'FAIL: setup_mise_activate did not write to rc file\n' >&2
    exit 1
fi

count_before=$(grep -c "mise activate" "$TEST_ZSHRC")
(
    export HOME="$RC_TEST_HOME"
    export SHELL="/bin/zsh"
    source ./setup.sh
    parse_arguments
    setup_mise_activate >/dev/null
)
count_after=$(grep -c "mise activate" "$TEST_ZSHRC")
if [[ "$count_before" -ne "$count_after" ]]; then
    printf 'FAIL: setup_mise_activate is not idempotent\n' >&2
    exit 1
fi
printf 'PASS: --no-rc leaves rc untouched and shell integration is idempotent\n'

# ============================================
# 測試 validate_mise_tools
# ============================================
echo ""
echo -e "${CYAN}測試 validate_mise_tools:${NC}"
echo ""

FAKE_MISE_DIR="$TEST_TMPDIR/fake_mise_bin"
mkdir -p "$FAKE_MISE_DIR"
FAKE_MISE="$FAKE_MISE_DIR/mise"
MISE_LOG="$TEST_TMPDIR/mise_calls.log"

cat > "$FAKE_MISE_DIR/brew" << 'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$FAKE_MISE_DIR/brew"

cat > "$FAKE_MISE" << 'EOF'
#!/bin/bash
printf '%s\n' "$*" >> "$MISE_LOG"
case "$1" in
    registry)
        cat << 'REG_EOF'
python                        asdf:asdf-community/asdf-python
node                          asdf:asdf-vm/asdf-nodejs
elixir                        asdf:asdf-vm/asdf-elixir
erlang                        asdf:asdf-vm/asdf-erlang
rust                          asdf:code-lever/asdf-rust
REG_EOF
        ;;
    install)
        exit 0
        ;;
    *)
        exit 0
        ;;
esac
EOF
chmod +x "$FAKE_MISE"

# 1. 測試合法工具清單通過驗證（支援 TSUNPI_MISE_EXEC 與 PATH 覆寫）
KNOWN_CONF="$TEST_TMPDIR/known_tools.toml"
cat > "$KNOWN_CONF" << 'EOF'
[tools]
python = "latest"
node = "latest"
rust = "latest"
EOF

(
    export TSUNPI_MISE_EXEC="$FAKE_MISE"
    export MISE_LOG
    validate_mise_tools "$KNOWN_CONF"
)
if [[ $? -ne 0 ]]; then
    printf 'FAIL: validate_mise_tools failed for known tools with TSUNPI_MISE_EXEC\n' >&2
    exit 1
fi

(
    unset TSUNPI_MISE_EXEC
    export PATH="$FAKE_MISE_DIR:$PATH"
    export MISE_LOG
    validate_mise_tools "$KNOWN_CONF"
)
if [[ $? -ne 0 ]]; then
    printf 'FAIL: validate_mise_tools failed for known tools with PATH\n' >&2
    exit 1
fi
printf 'PASS: conf with known tools passes (TSUNPI_MISE_EXEC and PATH)\n'

# 2. 測試包含未知工具 'foo' 時失敗（exit 1 且訊息包含工具名稱）
UNKNOWN_CONF="$TEST_TMPDIR/unknown_tools.toml"
cat > "$UNKNOWN_CONF" << 'EOF'
[tools]
python = "latest"
foo = "latest"
EOF

unknown_out=$(
    export TSUNPI_MISE_EXEC="$FAKE_MISE"
    (validate_mise_tools "$UNKNOWN_CONF") 2>&1
)
unknown_status=$?
if [[ "$unknown_status" -ne 1 ]]; then
    printf 'FAIL: validate_mise_tools with unknown tool did not exit 1 (got %d)\n' "$unknown_status" >&2
    exit 1
fi
if [[ "$unknown_out" != *"foo"* ]]; then
    printf 'FAIL: error message does not contain unknown tool name "foo": %s\n' "$unknown_out" >&2
    exit 1
fi
if [[ "$unknown_out" != *"https://mise.jdx.dev/registry.html"* ]]; then
    printf 'FAIL: error message does not contain registry link: %s\n' "$unknown_out" >&2
    exit 1
fi
printf 'PASS: conf with foo fails with exit 1 and the name in the message\n'

# 3. 測試驗證失敗時絕不執行 mise install
FAIL_HOME="$TEST_TMPDIR/fail_home"
mkdir -p "$FAIL_HOME"
rm -f "$MISE_LOG"

run_out=$(
    export PATH="$FAKE_MISE_DIR:$PATH"
    export HOME="$FAIL_HOME"
    export TSUNPI_MISE_EXEC="$FAKE_MISE"
    export MISE_LOG
    /bin/bash ./setup.sh --packages=none --mise-config="$UNKNOWN_CONF" --no-rc 2>&1
)
run_status=$?
if [[ "$run_status" -ne 1 ]]; then
    printf 'FAIL: full run with unknown tool should exit 1 (got %d)\n' "$run_status" >&2
    exit 1
fi
if [[ "$run_out" != *"foo"* ]]; then
    printf 'FAIL: full run output does not contain "foo": %s\n' "$run_out" >&2
    exit 1
fi
if [[ -f "$MISE_LOG" ]] && grep -q "install" "$MISE_LOG"; then
    printf 'FAIL: mise install was called despite validation failure!\n' >&2
    exit 1
fi
printf 'PASS: mise install never called when validation fails\n'

# 4. 測試驗證成功時會正常呼叫 mise install
PASS_HOME="$TEST_TMPDIR/pass_home"
mkdir -p "$PASS_HOME"
rm -f "$MISE_LOG"

pass_out=$(
    export PATH="$FAKE_MISE_DIR:$PATH"
    export HOME="$PASS_HOME"
    export TSUNPI_MISE_EXEC="$FAKE_MISE"
    export MISE_LOG
    /bin/bash ./setup.sh --packages=none --mise-config="$KNOWN_CONF" --no-rc 2>&1
)
pass_status=$?
if [[ "$pass_status" -ne 0 ]]; then
    printf 'FAIL: full run with known tools should exit 0 (got %d): %s\n' "$pass_status" "$pass_out" >&2
    exit 1
fi
if ! grep -q "install" "$MISE_LOG"; then
    printf 'FAIL: mise install was not called for known tools\n' >&2
    exit 1
fi
printf 'PASS: mise install called when validation passes\n'

# 5. 測試 --dry 模式印出 'Would validate mise tools against registry'
dry_out=$(
    export PATH="$FAKE_MISE_DIR:$PATH"
    export HOME="$PASS_HOME"
    export TSUNPI_MISE_EXEC="$FAKE_MISE"
    /bin/bash ./setup.sh --dry --langs=python,node --no-rc
)
if ! echo "$dry_out" | grep -q "Would validate mise tools against registry"; then
    printf 'FAIL: --dry did not print "Would validate mise tools against registry"\n' >&2
    exit 1
fi
printf 'PASS: --dry prints Would validate mise tools against registry\n'

echo "=========================================="
echo "  測試完成"
echo "=========================================="
