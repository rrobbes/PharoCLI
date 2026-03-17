# Project Setup

We are working in a Pharo image with Smalltalk code evaluation via netcat on port 4044.

## Pharo Code Execution

```bash
echo "3 + 4" | nc localhost 4044
```

## PharoCLI

A bash script providing command-line interface to Pharo image inspection. Located at: `pharocli`

**Key documentation:**
- `PHAROCLI-DOCUMENTATION.md` - Full user guide with examples
- `PHAROCLI-GUIDE.md` - Original PharoCLI class reference (Pharo side)
- `PHAROCLI-FUTURE-FEATURES.md` - Planned features and backlog

**Quick reference:**
```bash
pharocli packages                                # List packages
pharocli methods Object --protocols accessing    # Find methods
pharocli implementors yourself                   # Find implementations
pharocli recentChanges Kernel 10                 # See recent changes
pharocli source "Object>> yourself"              # View source (requires quotes)
```

## Development Approach

We use **Red/Green TDD** for all new features:

1. **RED** - Write test(s) that fail (method doesn't exist yet)
2. **GREEN** - Implement method to make test pass
3. **TEST** - Add unit tests to PharoCLITest
4. **VERIFY** - Run full test suite: `(PharoCLITest suite run)`

All PharoCLI methods follow this pattern:
- Non-String variant returns Set/Collection for programmatic use
- String variant returns formatted output for CLI display
- Example: `implementorsOf:` vs `implementorsOfString:`
