![Test Status](https://github.com/taiansu/tsunpi/actions/workflows/test.yml/badge.svg)
![License](https://img.shields.io/github/license/taiansu/tsunpi)
![macOS](https://img.shields.io/badge/macOS-13%2B-blue)

# tsún-pī (Preparation)

[繁體中文](README.md) | **English**

> Get your development environment ready (tsún-pī).

**tsunpi** means “preparation” (Taiwanese: *tsún-pī*; Japanese: *junbi*). Whatever the language, preparation is the foundation of success. Just as you prepare ingredients before cooking or pack before a trip, we help you get your development environment ready.

Install and configure your macOS development environment with a single command.

## Features

- **Zero-configuration installation** - Set everything up with one command.
- **Standard environment setup** - Follow the conventions of [Homebrew](https://brew.sh) and [mise](https://mise.jdx.dev) for a maintainable development environment.
- **Essential development tools** - Git, ripgrep, fzf, and other everyday tools.
- **Selectable languages** - Install the default languages or choose your own combination.
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

### Interactive Selection

```bash
curl -fsSL https://tsunpi.phx.tw | bash -s -- --interactive
```

## What Gets Installed

### Core Tools

**Required tools**

- **Homebrew** - Package manager for macOS
- **Git** - Version control
- **mise** - Development tool version manager

**Optional tools (all selected by default)**

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

### Basic Usage

```bash
# Use the default language selection
curl -fsSL https://tsunpi.phx.tw | bash

# Specify languages (comma-separated, without spaces)
curl -fsSL https://tsunpi.phx.tw | bash -s -- --langs=python,rust

# Interactive mode
curl -fsSL https://tsunpi.phx.tw | bash -s -- --interactive

# Dry-run mode (detect and print the installation plan without installing)
curl -fsSL https://tsunpi.phx.tw | bash -s -- --dry
```

### Selecting Homebrew Packages

Homebrew, Git, and mise are required. `--packages` selects additional tools independently of `--langs`:

```bash
# Select only fzf and zoxide, while retaining Git and mise
./setup.sh --packages=fzf,zoxide

# Skip optional tools, keeping required tools and Python
./setup.sh --packages=none --langs=python

# Preview required packages, selected optional packages, and language environments
./setup.sh --packages=stow,zoxide --langs=python,rust --dry
```

- Available optional packages: `ripgrep`, `fzf`, `fd`, `uv`, `stow`, and `zoxide`. Arbitrary Homebrew formulae, casks, and taps are not accepted.
- Without `--packages`, all optional tools are selected by default. `none` skips only optional tools, not language environments, and never uninstalls existing packages.
- Use comma-separated names without spaces. Duplicate names are processed once; listing `git` or `mise` does not change their required status.
- Empty lists, unknown names, and lists combining `none` with other entries are rejected before any installation.
- `--packages` takes precedence over the package menu; `--interactive` still prompts for programming languages. `--ci` skips both menus and uses explicit arguments or defaults.
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
- Both interfaces use numeric menus and `Y/n` answers. Commands, tool names, and generated configuration contents do not change with the interface language.

### Interactive Mode

With `--interactive`, select optional packages first, then programming languages. Specifying `--packages` skips the package menu. The following example uses `--locale=en`:

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

Enter a combination of numbers, for example:
- Enter `134` to install Python, Node, and Rust.
- Press Enter to install the defaults (Python, Elixir, Node).

### CI/CD Mode

Use `--ci` to skip all interactive prompts in continuous integration environments:

```bash
./setup.sh --ci
./setup.sh --langs=python,node --ci
```

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

1. **Check Homebrew** - Install it automatically if missing (your user password may be required).
2. **Install core tools** - Use Homebrew to install the required git and mise packages, plus the selected optional packages.
3. **Generate mise configuration** - Create `~/.config/mise/config.toml`.
4. **Configure shell integration** - Add `mise activate` to your shell's rc file automatically.
5. **Install language environments** - Use mise to install the selected programming languages.

### Configuration Locations

Configuration follows standard development environment conventions:

- mise configuration: `~/.config/mise/config.toml`
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

A: The `--langs` option can install any language (or tool) [supported by mise](https://mise.jdx.dev/registry.html#tools).
For example:

```bash
curl -fsSL https://tsunpi.phx.tw | bash -s -- --langs=python,kotlin,clojure
```

<br/>

Q: What happens if I put invalid entries in `--langs`?

A: Your computer won't break. If mise keeps complaining, open `~/.config/mise/config.toml` in an editor and remove the offending entries.

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
# Show detailed error messages
mise install -v

# Check system dependencies
mise doctor

# Install a specific language manually
mise install python@latest
```

### Shell Cannot Find Installed Languages

```bash
# Check that mise activate is configured
grep "mise activate" ~/.zshrc  # or ~/.bashrc

# Activate mise manually
eval "$(mise activate zsh)"  # or bash

# Restart your terminal
```

### Permission Issues

Some operations require sudo privileges (such as installing Homebrew). If you encounter permission errors:

```bash
# Check that you have admin privileges
groups | grep admin

# Clear the Homebrew cache (if disk space is low)
brew cleanup
```

## Contributing

Contributions are welcome! See the [contribution guide](CONTRIBUTING.md) (in Traditional Chinese).

### Development

```bash
# Clone the repository
git clone https://github.com/taiansu/tsunpi.git
cd tsunpi

# Try the setup script
./setup.sh --langs=python --ci

# Run local function checks, locale and package selection regressions (without installing)
/bin/bash test.sh
# GitHub Actions also runs full installation tests
```

### Testing

The project uses GitHub Actions for automated testing:

- Default installation
- Custom language combinations
- Idempotency
- Compatibility across macOS versions
- Interface locale precedence, normalization, fallback, and argument errors
- Package selection, required tools, deduplication, and installation failure handling

See [.github/workflows/test.yml](.github/workflows/test.yml) for details.

### Cloudflare Worker Deployment

[`worker.js`](worker.js) returns an HTTP 302 redirect to `main/setup.sh` on GitHub; it never runs the installer on Cloudflare. [`wrangler.jsonc`](wrangler.jsonc) specifies the deployment entrypoint and the Worker name, `tsunpi`.

Under Cloudflare **Settings → Build → Build Configuration**, use:

| Field | Setting |
|-------|---------|
| Root directory | Repository root |
| Build command | Leave empty |
| Deploy command | `npx --yes wrangler@4.129.0 deploy` |

Do not use `setup.sh` as the build command; it is the installer for users' macOS environments.

Local verification requires Node.js and npm:

```bash
# Verify packaging without deploying to Cloudflare
npx --yes wrangler@4.129.0 deploy --dry-run

# Start the local Worker
npx --yes wrangler@4.129.0 dev --local --port 8799
```

In another terminal, inspect the redirect without running the installer:

```bash
curl -sSI http://localhost:8799/
```

Expect `302` with `Location: https://raw.githubusercontent.com/taiansu/tsunpi/main/setup.sh`. After committing and pushing, Cloudflare's Git integration deploys the Worker; check the live response with `curl -sSI https://tsunpi.phx.tw`.

This design downloads the latest script from GitHub `main`, rather than a version pinned to a particular Worker deployment.

## License

MIT License - See [LICENSE](LICENSE) for details.

## Acknowledgments

- [mise](https://mise.jdx.dev) - An excellent development tool version manager
- [Homebrew](https://brew.sh) - An essential package manager for macOS

## Related Resources

- [mise documentation](https://mise.jdx.dev)
- [Homebrew documentation](https://docs.brew.sh)

---

**tsunpi** - Get your development environment ready.

Made with care for developers who value preparation.
