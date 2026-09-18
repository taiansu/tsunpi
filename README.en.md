![Test Status](https://github.com/taiansu/tsunpi/actions/workflows/test.yml/badge.svg)
![License](https://img.shields.io/github/license/taiansu/tsunpi)
![macOS](https://img.shields.io/badge/macOS-13%2B-blue)

# tsún-pī (Preparation)

[繁體中文](README.md) | **English**

> Get your development environment ready (tsún-pī).

**tsunpi** means “preparation” (Taiwanese: *tsún-pī*; Japanese: *junbi*). Whatever the language, preparation is the foundation of success. Just as you prepare ingredients before cooking or pack before a trip, we help you get your development environment ready.

Install and configure your macOS development environment with a single command.

## Features

- **Non-interactive by default** - No prompt pauses; safe for `curl | bash` and automation. Opt into numbered menus with `--interactive`.
- **Standard environment setup** - Follows [Homebrew](https://brew.sh) and [mise](https://mise.jdx.dev) conventions; writes to `conf.d` without polluting user dotfiles.
- **Brewfile support** - Use `--brewfile` to install all packages via `brew bundle`.
- **Selectable languages** - Install default languages or supply custom ones via flags or existing mise configs.
- **Idempotent** - Safe to run repeatedly; already-installed tools are skipped automatically.

## Quick Start

### Default Installation (Python, Elixir, Node)

```bash
curl -fsSL https://tsunpi.phx.tw | bash
```

### Custom Language Selection

```bash
curl -fsSL https://tsunpi.phx.tw | bash -s -- --langs=python,rust,ruby
```

### With Brewfile and External mise Config

```bash
curl -fsSL https://tsunpi.phx.tw | bash -s -- --brewfile=/path/to/Brewfile --mise-config=/path/to/mise.toml --no-rc
```

## What Gets Installed

### Core Tools

**Required tools**

- **Homebrew** - Package manager for macOS
- **Git** - Version control
- **mise** - Development tool version manager

**Optional tools (all selected by default, or replaced by `--brewfile`)**

- **ripgrep** - Fast text search
- **fzf** - Fuzzy finder
- **fd** - File search tool
- **uv** - Python project manager
- **stow** - Manage configuration files (dotfiles) through symbolic links
- **zoxide** - Remember frequently used directories and jump to them quickly

### Supported Language Environments

| Option | Language | Notes |
|--------|----------|-------|
| `python` | [Python](https://www.python.org/) | Latest stable release |
| `elixir` | [Elixir + Erlang](https://elixir-lang.org/) | Also installs the corresponding Erlang version |
| `node` | [Node.js + npm](https://nodejs.org/en) | JavaScript runtime |
| `rust` | [Rust + Cargo](https://rust-lang.org/) | |
| `ruby` | [Ruby + gem](https://www.ruby-lang.org/en/) | |
| `zig` | [Zig](https://ziglang.org/) | |
| `swift` | [Swift](https://swift.org/) | |
| `bun` | [Bun](https://bun.com/) | |

**Default selection**: `python`, `elixir`, `node`

*Note*: See the [FAQ](#faq) for other languages.

## Usage

### CLI Flags

| Flag | Description |
|------|-------------|
| `--brewfile PATH` | Path to a Brewfile to install via `brew bundle --file=PATH` (replaces `--packages`) |
| `--mise-config PATH` | Path to a mise configuration file, copied verbatim to `~/.config/mise/conf.d/tsunpi.toml` |
| `--no-rc` | Skip shell integration; do not modify shell rc files (e.g. `~/.zshrc`, `~/.bashrc`) |
| `--langs=...` / `--langs ...` | Specify programming languages (comma-separated, default: `python,elixir,node`) |
| `--packages=...` / `--packages ...` | Specify optional Homebrew packages (comma-separated, default: all; `none` skips optional packages) |
| `--locale=...` / `--locale ...` | Interface language (`en` or `zh-TW`) |
| `--interactive` | Pick optional packages and languages from numbered menus; without it nothing prompts |
| `--dry` | Dry-run mode; show the execution plan without making changes |
| `-h`, `--help` | Show help and usage information |

### Basic Usage

```bash
# Use the default language selection
curl -fsSL https://tsunpi.phx.tw | bash

# Specify languages (comma-separated, without spaces)
curl -fsSL https://tsunpi.phx.tw | bash -s -- --langs=python,rust

# With Brewfile and custom mise configuration
curl -fsSL https://tsunpi.phx.tw | bash -s -- --brewfile=/tmp/Brewfile --mise-config=/tmp/mise.toml --no-rc

# Dry-run mode (detect and print the installation plan without installing)
curl -fsSL https://tsunpi.phx.tw | bash -s -- --dry
```

### Selecting Homebrew Packages

Homebrew, Git, and mise are required. `--packages` selects additional tools:

```bash
# Select only fzf and zoxide, while retaining Git and mise
./setup.sh --packages=fzf,zoxide

# Skip optional tools, keeping required tools and Python
./setup.sh --packages=none --langs=python

# Preview required packages, selected optional packages, and language environments
./setup.sh --packages=stow,zoxide --langs=python,rust --dry
```

- Available optional packages: `ripgrep`, `fzf`, `fd`, `uv`, `stow`, and `zoxide`.
- When `--brewfile` is specified, tsunpi runs `brew bundle` and skips the individual `--packages` list.
- Without `--packages` or `--brewfile`, all optional tools are selected by default. `none` skips only optional tools, not language environments, and never uninstalls existing packages.
- Use comma-separated names without spaces. Duplicate names are processed once; listing `git` or `mise` does not change their required status.
- Existing tools are detected by executable name (for example, `rg` for ripgrep) and skipped. Failure to install a required package aborts installation; an optional package failure produces a warning and continues.

### Interface Language

Traditional Chinese (`zh-TW`) and English (`en`) are supported. `--locale` controls tsunpi's interface language; `--langs` still selects the programming languages to install:

```bash
# English interface
curl -fsSL https://tsunpi.phx.tw | bash -s -- --locale=en

# Traditional Chinese interface, installing Python and Rust
curl -fsSL https://tsunpi.phx.tw | bash -s -- --locale=zh-TW --langs=python,rust

# Set the default interface language
export TSUNPI_LOCALE=zh-TW
./setup.sh --dry
```

Locale precedence: `--locale` > `TSUNPI_LOCALE` > `LC_ALL` > `LC_MESSAGES` > `LANG` > English.

- The first nonempty system locale is used. If unsupported, tsunpi falls back to English rather than trying a lower-priority variable.
- Locale names are case-insensitive, accept `-` or `_` separators, and ignore encoding and modifier suffixes. English locales (such as `en_US.UTF-8`) map to `en`; `zh_TW`, `zh_HK`, `zh_MO`, `zh-Hant`, and `zh-Hant-*` map to `zh-TW`.
- Other system locales (including `C` and `POSIX`) fall back to English. Explicitly setting an unsupported or empty `--locale` / `TSUNPI_LOCALE` is an error; a higher-priority setting overrides a lower-priority one.
- Only tsunpi's own messages are localized. `LANG` and `LC_ALL` are not changed; Homebrew, mise, and sudo control their own output.

### Interactive Mode

No interaction is required by default. With `--interactive`, tsunpi first asks for optional packages, then for programming languages; a menu is skipped when its answer was already given by `--packages`/`--brewfile` or `--langs`/`--mise-config`. The following example uses `--locale=en`:

```text
Homebrew and these packages are required: git mise
Select optional packages (enter numbers, e.g. 126)
Press Enter to select all; enter 0 for no optional packages
1) ripgrep
2) fzf
3) fd
4) uv
5) stow
6) zoxide

Package selection: _
```

Enter `26` to select fzf and zoxide, press Enter to select all, or enter `0` alone for no optional tools. Duplicate digits are ignored; invalid digits or combinations containing `0` abort before installation.

Next, select language environments:

```text
Select language environments to install (enter numbers, e.g. 134)
Press Enter to use the defaults: Python, Elixir, Node

1) Python
2) Elixir (automatically installs the corresponding Erlang version)
3) Node
4) Rust
5) Ruby
6) Zig
7) Swift
8) Bun

Your selection: _
```

Enter `134` to install Python, Node, and Rust; press Enter for the defaults.

`--ci` is a no-op since v2.1 (non-interactive is the default) and is kept only for compatibility with older commands.

## Safety Recommendations

Before running the script for the first time, review its contents:

```bash
# Download the script
curl -fsSL https://tsunpi.phx.tw > setup.sh

# Review its contents
less setup.sh

# Run it after reviewing
bash setup.sh
```

You can also browse the [source code on GitHub](https://github.com/taiansu/tsunpi).

## How It Works

1. **Check Homebrew** - Install it automatically if missing (admin password may be required).
2. **Install core tools** - Use Homebrew to install required git and mise, plus selected optional packages or `--brewfile`.
3. **Generate mise configuration** - Write configuration to `~/.config/mise/conf.d/tsunpi.toml` (or copy from `--mise-config` verbatim). Never modifies `~/.config/mise/config.toml`, keeping user dotfiles (such as stow symlinks) untouched.
4. **Configure shell integration** - Unless `--no-rc` is specified, append `eval "$(mise activate <shell>)"` to the shell rc file idempotently.
5. **Install language environments** - Run `mise install` automatically to install selected languages.

### Configuration Locations

Configuration follows standard development environment conventions:

- mise configuration: `~/.config/mise/conf.d/tsunpi.toml`
- Language installation directory: `~/.local/share/mise/installs/`
- Shell configuration: `~/.zshrc` or `~/.bashrc`

## Installation Time

| Language Combination | Estimated Time (First Installation) | Notes |
|----------------------|------------------------------------|-------|
| Python only | ~3 minutes | Lightweight |
| Python + Node | ~5 minutes | Common combination |
| Python + Elixir + Node | ~20–30 minutes | Erlang requires compilation |
| All languages | ~25–60 minutes | Includes Rust compilation |

> **Tip**: Erlang and Rust may need to be compiled from source, making the first installation slower. Subsequent updates use precompiled versions for faster installation.

## Managing Installed Languages

After installation, use mise to manage language versions:

```bash
# List installed languages
mise list

# Upgrade to the latest versions
mise upgrade

# Install a specific version
mise install python@3.11

# Set a project-specific version (run in the project directory)
mise use python@3.11

# Check mise's status
mise doctor
```

For more details, see the [mise documentation](https://mise.jdx.dev/installing-mise.html).

## FAQ

Q: Can this tool install other languages?

A: The `--langs` option can install any language (or tool) [supported by mise](https://mise.jdx.dev/registry.html).
For example:

```bash
curl -fsSL https://tsunpi.phx.tw | bash -s -- --langs=python,kotlin,clojure
```

<br/>

Q: What happens if I put invalid entries in `--langs`?

A: Any tool in the mise registry works; unknown names abort the install before anything is installed. tsunpi validates all tool names against the [mise registry](https://mise.jdx.dev/registry.html) before running `mise install`.
<br/>

Q: Does this work on Windows?

A: Windows support is planned.

## Troubleshooting

### Homebrew Installation Fails

```bash
# Check your network connection
ping github.com

# Install Homebrew manually
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Run tsunpi again
curl -fsSL https://tsunpi.phx.tw | bash
```

### Language Installation with mise Fails

```bash
# View detailed error logs
mise install -v

# Check system dependencies
mise doctor

# Install specific language manually
mise install python@latest
```

### Shell Cannot Find Installed Languages

```bash
# Verify mise activate is configured
grep "mise activate" ~/.zshrc  # or ~/.bashrc

# Load mise manually
eval "$(mise activate zsh)"  # or bash

# Restart your terminal
```

### Permissions Issues

Some operations require sudo privileges (such as installing Homebrew). If you encounter permission errors:

```bash
# Verify you have admin privileges
groups | grep admin

# Clean Homebrew cache (if disk space is low)
brew cleanup
```

## Contributing

Contributions are welcome! Please see the [Contributing Guide](CONTRIBUTING.md).

### Development

```bash
# Clone repository
git clone https://github.com/taiansu/tsunpi.git
cd tsunpi

# Test script (dry-run)
./setup.sh --langs=python --dry

# Run local function checks, locale tests, and package selection tests
/bin/bash test.sh
# GitHub Actions runs complete end-to-end installation tests
```

### Testing

The project uses GitHub Actions for automated testing:

- ✅ Default installation test
- ✅ Custom language combination test
- ✅ Idempotency test
- ✅ Cross-version compatibility
- Locale precedence, normalization, fallback, and argument error handling
- Package selection, required tool preservation, deduplication, and failure handling
- `--brewfile`, `--mise-config`, `--no-rc`, and `conf.d` isolation tests

See [.github/workflows/test.yml](.github/workflows/test.yml) for details.

### Cloudflare Worker Deployment

[`worker.js`](worker.js) redirects requests with HTTP 302 to `main/setup.sh` on GitHub; it does not run the install script inside Cloudflare. Deployment entry is specified by [`wrangler.jsonc`](wrangler.jsonc), with worker name `tsunpi`.

Cloudflare **Settings → Build → Build Configuration**:

| Field | Value |
|-------|-------|
| Root directory | Repository root |
| Build command | (Leave empty) |
| Deploy command | `npx --yes wrangler@4.129.0 deploy` |

Do not set `setup.sh` as the build command; it is the user's macOS installer.

Local verification requires Node.js and npm:

```bash
# Verify bundle without deploying to Cloudflare
npx --yes wrangler@4.129.0 deploy --dry-run

# Start local worker
npx --yes wrangler@4.129.0 dev --local --port 8799
```

In another terminal, check the redirect without running the install:

```bash
curl -sSI http://localhost:8799/
```

Expect `302` with `Location` pointing to `https://raw.githubusercontent.com/taiansu/tsunpi/main/setup.sh`. Once committed and pushed, Cloudflare Git integration deploys; verify live response with `curl -sSI https://tsunpi.phx.tw`.

## License

MIT License - see [LICENSE](LICENSE).

## Acknowledgments

- [mise](https://mise.jdx.dev) - Excellent dev tool version manager
- [Homebrew](https://brew.sh) - Essential macOS package manager

## Resources

- [mise Documentation](https://mise.jdx.dev)
- [Homebrew Documentation](https://docs.brew.sh)

---

**tsunpi** - Get your development environment ready 🍽️

Made with ❤️ for developers who value preparation
