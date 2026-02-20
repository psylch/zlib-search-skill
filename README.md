# zlib-search-skill

[中文文档](README.zh.md)

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill for searching and downloading books. Supports multiple backends with a unified CLI — full workflow from search to download in one skill.

| Backend | Source | Auth | Best For |
|---------|--------|------|----------|
| **Z-Library** | EAPI (reverse-engineered Android API) | Email + Password | Largest catalog, direct download, Chinese books |
| **Anna's Archive** | annas-mcp Go binary | API Key (donation) | Aggregated sources, multiple mirrors |

## Installation

### Via skills.sh (recommended)

```bash
npx skills add psylch/zlib-search-skill -g -y
```

### Via Claude Code Plugin Marketplace

```shell
/plugin marketplace add psylch/zlib-search-skill
/plugin install zlib-search-skill@psylch-zlib-search-skill
```

Restart Claude Code after installation.

## Prerequisites

- **Python 3** with `requests` library (`pip install requests`)
- **Z-Library account** (email + password) for search and download
- **annas-mcp binary** (optional) — for Anna's Archive backend

## Setup

### 1. Configure Credentials

```bash
mkdir -p ~/.claude/book-tools
cp ~/.agents/skills/book-tools/scripts/.env.example ~/.claude/book-tools/.env
```

Edit `~/.claude/book-tools/.env` with your Z-Library email and password:

```
ZLIB_EMAIL=your_email@example.com
ZLIB_PASSWORD=your_password_here
```

> **Important**: Do not share credentials in chat. The skill reads them from the `.env` file only.

### 2. (Optional) Install Anna's Archive

```bash
bash ~/.agents/skills/book-tools/scripts/setup.sh install-annas
```

Then add your API key (obtained via donation to Anna's Archive) to `.env`:

```
ANNAS_SECRET_KEY=your_api_key_here
```

### 3. Verify

```bash
python3 ~/.agents/skills/book-tools/scripts/book.py setup
```

## Usage

In Claude Code, use any of these trigger phrases:

```
find book about deep learning
search for machine learning textbooks
找一本关于强化学习的书
帮我搜几本莱姆的科幻小说
下载这本书
```

The skill handles the full workflow: **search → present results → user picks → download**.

## How It Works

1. **Search** — queries the selected backend (or auto-detects) with filters (language, format, year)
2. **Present** — shows results as a numbered table grouped by language/edition
3. **Pick** — user selects by number
4. **Download** — fetches the file to `~/Downloads/` and reports path + size

### CLI Reference

```bash
# Search (auto-detect backend)
python3 book.py search "deep learning" --limit 10

# Search with filters
python3 book.py search "machine learning" --source zlib --lang english --ext pdf --limit 5

# Download from Z-Library
python3 book.py download --source zlib --id <id> --hash <hash> -o ~/Downloads/

# Download from Anna's Archive
python3 book.py download --source annas --hash <md5> --filename book.pdf

# Book details
python3 book.py info --source zlib --id <id> --hash <hash>

# Config management
python3 book.py config show
python3 book.py config set --zlib-email <email> --zlib-password <pw>
python3 book.py setup
```

### Credential Storage

| Source | Path | Priority |
|--------|------|----------|
| `.env` file | `~/.claude/book-tools/.env` | Higher (overrides JSON) |
| Config JSON | `~/.claude/book-tools/config.json` | Lower (auto-managed) |

On first successful Z-Library login, remix tokens are cached in `config.json` — subsequent calls use tokens directly, skipping email/password login.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| "Z-Library not configured" | Edit `~/.claude/book-tools/.env` with credentials |
| "Z-Library login failed" | Verify credentials. Z-Library domains change frequently — vendored `Zlibrary.py` may need a domain update |
| "annas-mcp binary not found" | Run `setup.sh install-annas` |
| "No backend available" | Configure at least one backend in `.env` |

## File Structure

```
zlib-search-skill/
├── .claude-plugin/
│   └── plugin.json                  # Plugin manifest
├── skills/
│   └── book-tools/
│       ├── SKILL.md                 # Main skill definition
│       ├── scripts/
│       │   ├── book.py              # Unified CLI wrapper
│       │   ├── Zlibrary.py          # Vendored Z-Library API (MIT)
│       │   ├── setup.sh             # Dependency check & install
│       │   └── .env.example         # Credential template
│       └── references/
│           └── api_reference.md     # API quick reference
├── README.md
├── README.zh.md
└── .gitignore
```

## Credits

- [Zlibrary-API](https://github.com/bipinkrish/Zlibrary-API) by bipinkrish (MIT) — vendored Z-Library Python wrapper
- [annas-mcp](https://github.com/iosifache/annas-mcp) by iosifache — Anna's Archive CLI + MCP server

## License

MIT
