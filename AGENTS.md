# Project Setup

We are working in a Pharo image with Smalltalk code evaluation via netcat on port 4044.

## Pharo Code Execution

```bash
echo "3 + 4" | nc localhost 4044
```

## PharoCLI (Python Version)

A Python CLI for inspecting and navigating Pharo image code. Located at: `pharocli.py`

**Usage:**
```bash
python3 pharocli.py [command] [options]
# Or with alias: pharocli [command] [options]
```

**Key documentation:**
- `PHAROCLI-PYTHON-USAGE.md` - Full usage guide with examples and bash integration
- `PHAROCLI-GUIDE.md` - Pharo-side PharoCLI class reference
- `pharocli-python-bugs.md` - Known issues and fixes applied
- `PHAROCLI-DOCUMENTATION.md` - Original bash version (deprecated, for reference only)

**Quick reference:**
```bash
pharocli packages                                # List packages
pharocli methods Object --protocols accessing    # Find methods
pharocli implementors yourself                   # Find implementations (with package filters)
pharocli source "Object>> yourself"              # View source (works with operators!)
pharocli source "Integer>> +"                    # Operator methods supported
pharocli info "Object>> yourself"                # Method info
pharocli search test --in-packages Kernel       # Search with filters
pharocli hierarchy Object                        # Show class hierarchy
pharocli references Object --in-package Kernel  # Find references
pharocli debugger stack                          # Show debugger stack
pharocli inspect tree "Point x: 10 y: 20" 2     # Object tree inspection
```

**Bash integration examples:**
```bash
# Find methods and filter results
pharocli methods Object | grep "as"

# Count implementors in a package
pharocli implementors yourself --in-package Kernel | wc -l

# Search and extract data
pharocli search test | grep -E "^\w+>>" | sort | uniq

# Chain with other tools
pharocli implementors "+" --in-packages Kernel | sed 's/>>.*//' | sort | uniq
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
