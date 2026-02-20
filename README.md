# zlib-search-skill

A Claude Code skill for searching and downloading books from Z-Library and Anna's Archive.

## Install

### Via skills.sh (recommended)

```bash
npx skills add psylch/zlib-search-skill -g -y
```

### Via Claude Code plugin system

```
/plugin install psylch/zlib-search-skill
```

## Setup

After installation, configure your credentials:

1. Create the config file:
```bash
mkdir -p ~/.claude/book-tools
cp ~/.agents/skills/book-tools/scripts/.env.example ~/.claude/book-tools/.env
```

2. Edit `~/.claude/book-tools/.env` with your Z-Library email and password.

3. (Optional) Install Anna's Archive CLI:
```bash
bash ~/.agents/skills/book-tools/scripts/setup.sh install-annas
```

## Usage

Once configured, just tell Claude to find books:

- "帮我找一本关于深度学习的书"
- "search for books about machine learning"
- "下载这本书"

The skill handles: **search → pick → download** automatically.

## Backends

| Backend | Auth | Best For |
|---------|------|----------|
| Z-Library (EAPI) | Email + Password | Largest catalog, direct download |
| Anna's Archive | API Key (donation) | Aggregated sources, multiple mirrors |

## CLI Reference

```bash
# Search
python3 book.py search "query" --source zlib|annas|auto --lang english --ext pdf --limit 10

# Download
python3 book.py download --source zlib --id <id> --hash <hash> -o ~/Downloads/
python3 book.py download --source annas --hash <md5> --filename book.pdf

# Book info
python3 book.py info --source zlib --id <id> --hash <hash>

# Config
python3 book.py config show
python3 book.py config set --zlib-email <email> --zlib-password <pw>
python3 book.py setup
```

## Credits

- [Zlibrary-API](https://github.com/bipinkrish/Zlibrary-API) by bipinkrish (MIT) — vendored Z-Library Python wrapper
- [annas-mcp](https://github.com/iosifache/annas-mcp) by iosifache — Anna's Archive CLI + MCP server
