# chineselinter.nvim - AI Coding Assistant Guide

中文文档语言规范检查工具，用于在 Neovim 中检查中文文案的排版规范。

---

## File Operations

### One rule: always use `action="overwrite"`

`replace` / `insert` / `delete` are **forbidden** - line numbers drift after each operation, causing duplicates and syntax errors.

### Workflow for any file change

```
1. @read_file filepath="target"           # Read complete file
2. Edit in reply                          # Modify what's needed
3. @write_file action="overwrite"         # Write complete content
4. @read_file filepath="target"           # Verify: check syntax, duplicates, correctness
5. @make test                             # Run tests - MUST pass before committing
6. @git_add -> @git_commit -> @git_push   # One at a time, wait for each result
```

### Git tools: one at a time

Never batch git calls. Send `@git_add`, wait for result, then `@git_commit`, wait, then `@git_push`.

---

## Development Workflow

After any code change, auto-execute without asking:

```
Modify -> Verify -> make test -> git_add -> git_commit -> git_push -> Done
```

**Never:** skip verification, skip tests, read only partial file, modify without commit, commit without push.

---

## Project Structure

```
chineselinter.nvim/
├── lua/
│   └── chineselinter/
│       └── init.lua          # Main module: rules, check(), setup()
├── plugin/
│   └── chineselinter.lua     # User command: :CheckChinese
├── test/
│   ├── minimal_init.lua      # Headless test config
│   ├── run.lua               # luaunit test runner
│   ├── install_deps.lua      # Cross-platform dep installer
│   ├── logger.lua            # Mock logger module
│   ├── example_spec.lua      # Example test
│   └── *_spec.lua            # Test files
├── .github/
│   ├── workflows/
│   │   ├── test.yml          # CI test workflow
│   │   ├── luarocks.yml      # LuaRocks publish
│   │   └── release-please.yml # Automated release
│   ├── release-please-config.json
│   └── release-please-manifest.json
├── .stylua.toml
├── Makefile
├── README.md
├── AGENTS.md
└── CHANGELOG.md              # Auto-generated, DO NOT EDIT
```

## Coding Style

Follow `.stylua.toml` settings:
- Column width: 100
- Indent: Spaces, width 4
- Quote style: AutoPreferSingle
- Call parentheses: Always
- Line endings: Unix

### Naming Conventions

- Module: `chineselinter` (lowercase, no underscores)
- Variables: `snake_case`
- Constants: `UPPER_CASE`
- Error codes: `E001`-`E021` (uppercase E + zero-padded number)
- Rules table: key is error code, value is array of `{ description, pattern }`

---

## Testing

Framework: **luaunit**. Files: `test/*_spec.lua`.

### Running tests

Run all tests:

```
@make target="test"
```

Run specific test file(s) with PATTERN:

```
@make target="test" args=["PATTERN=example"]
```

PATTERN supports shorthand - `example` expands to `test/**/*example*_spec.lua`. Full paths also work:

```
@make target="test" args=["PATTERN=test/example_spec.lua"]
```

### Writing tests

```lua
local lu = require('luaunit')
local chineselinter = require('chineselinter')

TestExample = {}

function TestExample:setUp()
    -- Setup if needed
end

function TestExample:tearDown()
    -- Cleanup if needed
end

function TestExample:test_something()
    lu.assertEquals(1 + 1, 2)
end

return TestExample
```

CI runs on push to main/master and PRs, across Neovim nightly/stable, ubuntu/windows/macos.

### Test configuration

Tests use a mock `logger` module (`test/logger.lua`) to avoid external dependencies. The `test/minimal_init.lua` sets up `package.path` to include:
1. `lua/?.lua` - Main plugin source code
2. `test/?.lua` - Mock modules (logger.lua)
3. `test/.deps/?.lua` - Test dependencies (luaunit)

---

## Commit Style

Follow [Conventional Commits](https://www.conventionalcommits.org/). Format: `type(scope): subject`

| Type | For | Release |
|------|-----|---------|
| `feat` | New feature | Minor |
| `fix` | Bug fix | Patch |
| `refactor` | Code restructure | None* |
| `docs` | Documentation | None |
| `test` | Tests | None |
| `ci` | CI/CD | None |
| `chore` | Maintenance | None |
| `perf` | Performance | Patch |
| `style` | Formatting | None |
| `build` | Build system | None |
| `security` | Security fix | Patch |

\* Unless `BREAKING CHANGE` footer or `Release-As` is set.

**Rules:** imperative mood, lowercase, no period, under 72 chars. Use `!` for breaking: `refactor!: change API`.

---

## Release

Release-please creates a PR on branch `release-please--branches--master`. To re-trigger or fix the release PR version, use git tools one at a time:

1. `@git_fetch remote="origin"` - fetch latest from origin
2. `@git_checkout branch="release-please--branches--master"` - switch to release PR branch
3. `@git_reset commit="origin/release-please--branches--master" mode="hard"` - reset to remote release branch state
4. `@git_rebase branch="master"` - rebase release PR branch onto latest master
5. `@git_push branch="release-please--branches--master" force=true` - force push to update PR
6. `@git_checkout branch="master"` - switch back to master
7. `@git_merge branch="release-please--branches--master"` - merge release PR into master

### 禁止手动创建或推送 tags

Release-please 在 release PR 合并后会**自动创建** git tags 和 GitHub Releases。在此过程中：

- **不要**使用 `@git_tag` 创建任何 tag
- **不要**使用 `@git_push tags=true` 推送 tags

手动 tag 会与 release-please 的自动化冲突，导致版本混乱或重复 release。

---

## Forbidden Files

**Never modify:** `CHANGELOG.md`, `CHANGELOG.*.md` - auto-generated by release-please. Redirect to source code or docs instead.

