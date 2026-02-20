# zlib-search-skill

[English](README.md)

一个 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill，用于搜索和下载书籍。支持多个后端，统一 CLI——在一个 skill 内完成从搜索到下载的全链路。

| 后端 | 数据源 | 认证方式 | 适合场景 |
|------|--------|----------|----------|
| **Z-Library** | EAPI（逆向安卓 API） | 邮箱 + 密码 | 最大书库，直接下载，中文书籍 |
| **Anna's Archive** | annas-mcp Go 二进制 | API Key（需捐赠） | 聚合多源，多镜像 |

## 安装

### 通过 skills.sh 安装（推荐）

```bash
npx skills add psylch/zlib-search-skill -g -y
```

### 通过 Claude Code Plugin Marketplace 安装

```shell
/plugin marketplace add psylch/zlib-search-skill
/plugin install zlib-search-skill@psylch-zlib-search-skill
```

安装后重启 Claude Code。

## 前置要求

- **Python 3** 及 `requests` 库（`pip install requests`）
- **Z-Library 账号**（邮箱 + 密码），用于搜索和下载
- **annas-mcp 二进制**（可选）——用于 Anna's Archive 后端

## 配置

### 1. 配置凭证

```bash
mkdir -p ~/.claude/book-tools
cp ~/.agents/skills/book-tools/scripts/.env.example ~/.claude/book-tools/.env
```

编辑 `~/.claude/book-tools/.env`，填入你的 Z-Library 邮箱和密码：

```
ZLIB_EMAIL=your_email@example.com
ZLIB_PASSWORD=your_password_here
```

> **重要**：不要在聊天中直接提供凭证。skill 只从 `.env` 文件读取。

### 2.（可选）安装 Anna's Archive

```bash
bash ~/.agents/skills/book-tools/scripts/setup.sh install-annas
```

然后在 `.env` 中添加 API key（通过向 Anna's Archive 捐赠获取）：

```
ANNAS_SECRET_KEY=your_api_key_here
```

### 3. 验证

```bash
python3 ~/.agents/skills/book-tools/scripts/book.py setup
```

## 使用方式

在 Claude Code 中使用以下触发短语：

```
find book about deep learning
search for machine learning textbooks
找一本关于强化学习的书
帮我搜几本莱姆的科幻小说
下载这本书
```

Skill 自动处理全流程：**搜索 → 展示结果 → 用户选择 → 下载**。

## 工作原理

1. **搜索** — 查询选定后端（或自动检测），支持语言、格式、年份过滤
2. **展示** — 以编号表格呈现结果，按语言/版本分组
3. **选择** — 用户报编号
4. **下载** — 将文件下载到 `~/Downloads/` 并报告路径和大小

### CLI 参考

```bash
# 搜索（自动检测后端）
python3 book.py search "deep learning" --limit 10

# 带过滤条件搜索
python3 book.py search "机器学习" --source zlib --lang chinese --ext pdf --limit 5

# 从 Z-Library 下载
python3 book.py download --source zlib --id <id> --hash <hash> -o ~/Downloads/

# 从 Anna's Archive 下载
python3 book.py download --source annas --hash <md5> --filename book.pdf

# 书籍详情
python3 book.py info --source zlib --id <id> --hash <hash>

# 配置管理
python3 book.py config show
python3 book.py config set --zlib-email <email> --zlib-password <pw>
python3 book.py setup
```

### 凭证存储

| 来源 | 路径 | 优先级 |
|------|------|--------|
| `.env` 文件 | `~/.claude/book-tools/.env` | 高（覆盖 JSON） |
| Config JSON | `~/.claude/book-tools/config.json` | 低（自动管理） |

首次 Z-Library 登录成功后，remix token 会缓存到 `config.json`——后续调用直接用 token，跳过邮箱密码登录。

## 故障排除

| 症状 | 修复方法 |
|------|----------|
| "Z-Library not configured" | 编辑 `~/.claude/book-tools/.env` 填入凭证 |
| "Z-Library login failed" | 检查凭证。Z-Library 域名经常变更——vendored 的 `Zlibrary.py` 可能需要更新域名 |
| "annas-mcp binary not found" | 运行 `setup.sh install-annas` |
| "No backend available" | 在 `.env` 中至少配置一个后端 |

## 文件结构

```
zlib-search-skill/
├── .claude-plugin/
│   └── plugin.json                  # 插件清单
├── skills/
│   └── book-tools/
│       ├── SKILL.md                 # 主 skill 定义
│       ├── scripts/
│       │   ├── book.py              # 统一 CLI
│       │   ├── Zlibrary.py          # Vendored Z-Library API (MIT)
│       │   ├── setup.sh             # 依赖检测与安装
│       │   └── .env.example         # 凭证模板
│       └── references/
│           └── api_reference.md     # API 快速参考
├── README.md
├── README.zh.md
└── .gitignore
```

## 致谢

- [Zlibrary-API](https://github.com/bipinkrish/Zlibrary-API) by bipinkrish (MIT) — vendored Z-Library Python 封装
- [annas-mcp](https://github.com/iosifache/annas-mcp) by iosifache — Anna's Archive CLI + MCP server

## 许可

MIT
