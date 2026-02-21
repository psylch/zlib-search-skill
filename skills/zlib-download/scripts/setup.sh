#!/usr/bin/env bash
# setup.sh - Check and install dependencies for book-tools skill
#
# Usage:
#   bash setup.sh check          # Check all dependencies (JSON output)
#   bash setup.sh install-annas  # Download and install annas-mcp binary
#   bash setup.sh install-deps   # Install Python dependencies (requests)

set -euo pipefail

ANNAS_VERSION="v0.0.4"
INSTALL_DIR="$HOME/.local/bin"

# ── JSON output helpers ──────────────────────────────────────────────

json_error() {
    local msg="$1"
    local hint="${2:-}"
    local recoverable="${3:-true}"
    echo "{\"error\":\"$msg\",\"hint\":\"$hint\",\"recoverable\":$recoverable}" >&2
    if [ "$recoverable" = "true" ]; then
        exit 1
    else
        exit 2
    fi
}

# ── check subcommand ────────────────────────────────────────────────

do_check() {
    local python_ok=false
    local python_path=""
    local python_ver=""
    local requests_ok=false
    local annas_ok=false
    local annas_path=""

    # Python
    if command -v python3 &>/dev/null; then
        python_ok=true
        python_path="$(command -v python3)"
        python_ver="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}")')"
    fi

    # Requests
    if python3 -c "import requests" 2>/dev/null; then
        requests_ok=true
    fi

    # annas-mcp binary
    if command -v annas-mcp &>/dev/null; then
        annas_ok=true
        annas_path="$(command -v annas-mcp)"
    elif [ -f "$INSTALL_DIR/annas-mcp" ]; then
        annas_ok=true
        annas_path="$INSTALL_DIR/annas-mcp"
    elif [ -f "/usr/local/bin/annas-mcp" ]; then
        annas_ok=true
        annas_path="/usr/local/bin/annas-mcp"
    fi

    # Build JSON
    local ready=true
    if [ "$python_ok" = false ]; then ready=false; fi
    if [ "$requests_ok" = false ]; then ready=false; fi

    local python_json
    if [ "$python_ok" = true ]; then
        python_json="{\"ok\":true,\"path\":\"$python_path\",\"version\":\"$python_ver\"}"
    else
        python_json='{"ok":false,"error":"python3 not found"}'
    fi

    local requests_json
    if [ "$requests_ok" = true ]; then
        requests_json='{"ok":true}'
    else
        requests_json='{"ok":false,"error":"not installed"}'
    fi

    local annas_json
    if [ "$annas_ok" = true ]; then
        annas_json="{\"ok\":true,\"path\":\"$annas_path\"}"
    else
        annas_json='{"ok":false,"error":"not found"}'
    fi

    local hint
    if [ "$ready" = true ]; then
        hint="All core dependencies are available."
    else
        hint="Run: bash setup.sh install-deps to install missing Python packages."
    fi

    echo "{\"ready\":$ready,\"dependencies\":{\"python\":$python_json,\"requests\":$requests_json,\"annas_mcp\":$annas_json},\"hint\":\"$hint\"}"
    exit 0
}

# ── install subcommands ─────────────────────────────────────────────

do_install_deps() {
    if ! command -v python3 &>/dev/null; then
        json_error "python3 not found" "Install Python 3.8+ first." "false"
    fi

    echo "Installing Python requests..." >&2
    if python3 -m pip install --user requests >&2; then
        echo '{"status":"ok","hint":"Python requests installed successfully."}'
    else
        json_error "pip install failed" "Check pip installation and network connectivity." "true"
    fi
}

do_install_annas() {
    local arch
    arch="$(uname -m)"
    local os_name
    os_name="$(uname -s | tr '[:upper:]' '[:lower:]')"

    # Map arch
    case "$arch" in
        x86_64|amd64) arch="amd64" ;;
        arm64|aarch64) arch="arm64" ;;
        *) json_error "Unsupported architecture: $arch" "Only amd64 and arm64 are supported." "false" ;;
    esac

    # Release filenames use version without 'v' prefix
    local ver_no_v="${ANNAS_VERSION#v}"
    local filename="annas-mcp_${ver_no_v}_${os_name}_${arch}.tar.xz"
    if [ "$os_name" = "windows" ]; then
        filename="annas-mcp_${ver_no_v}_${os_name}_${arch}.zip"
    fi
    local url="https://github.com/iosifache/annas-mcp/releases/download/${ANNAS_VERSION}/${filename}"

    echo "Downloading $url ..." >&2
    mkdir -p "$INSTALL_DIR"

    local tmpdir
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "${tmpdir:-}"' EXIT

    if ! curl -fsSL "$url" -o "$tmpdir/$filename"; then
        json_error "Download failed: $url" "Check network connectivity or try a different version." "true"
    fi

    tar -xJf "$tmpdir/$filename" -C "$tmpdir"

    # Find the binary in extracted files
    local binary
    binary="$(find "$tmpdir" -name 'annas-mcp' -type f | head -1)"
    if [ -z "$binary" ]; then
        json_error "annas-mcp binary not found in archive" "The release archive format may have changed." "false"
    fi

    cp "$binary" "$INSTALL_DIR/annas-mcp"
    chmod +x "$INSTALL_DIR/annas-mcp"

    local path_hint=""
    if ! echo "$PATH" | tr ':' '\n' | grep -q "$INSTALL_DIR"; then
        path_hint=" Add $INSTALL_DIR to your PATH."
    fi

    echo "{\"status\":\"ok\",\"path\":\"$INSTALL_DIR/annas-mcp\",\"version\":\"$ANNAS_VERSION\",\"hint\":\"Installed annas-mcp ${ANNAS_VERSION}.$path_hint\"}"
}

case "${1:-check}" in
    check)         do_check ;;
    install-deps)  do_install_deps ;;
    install-annas) do_install_annas ;;
    *)
        json_error "Unknown subcommand: ${1}" "Usage: setup.sh [check|install-deps|install-annas]" "false"
        ;;
esac
