# PharoCLI Test Suite

Automated regression tests for the PharoCLI Python version.

## Quick Start

```bash
# Run all tests
./test-pharocli.sh

# Run with verbose output
VERBOSE=1 ./test-pharocli.sh

# Check exit code
./test-pharocli.sh && echo "All tests passed" || echo "Some tests failed"
```

## What It Tests

### Fixed Bugs (8 tests)
- Bug #1 & #8: Operator methods (`+`, `*`, `>>`)
- Bug #2 & #3: Package filtering for implementors

**Examples:**
```bash
pharocli sources "Integer>> +" "Integer>> *"
pharocli implementors yourself --in-package Kernel
pharocli implementors yourself --in-packages Kernel Collections
```

### Core Functionality (16 tests)

#### Package Commands
- `packages` - list packages
- `packages classes` - list classes in packages
- `packages sub` - list sub-packages

#### Method Commands
- `methods` - get methods
- `methods` with protocol filter
- `protocols` - get class protocols

#### Search Commands
- `implementors` - find implementors
- `senders` - find senders
- `search` - search with filters

#### Class Inspection
- `hierarchy` - class hierarchy
- `comment` - class documentation
- `variables` - class variables

#### Object Inspection
- `inspect tree` - basic tree inspection
- `inspect tree` with depth parameter

### Bash Integration (4 tests)

Tests integration with common bash tools:

```bash
pharocli methods Object | grep "as"           # grep filtering
pharocli implementors yourself | wc -l        # counting
pharocli implementors yourself | sed 's/>>.*//'  # sed extraction
pharocli senders yourself | sort | uniq       # sorting and deduplication
```

### Edge Cases (2 tests)
- Multiple classes in one command
- Multiple protocols in one command

## Test Output

### Success
```
✓ test_name
```

### Failure
```
✗ test_name (output didn't match expected pattern)
```

## Running Specific Tests

The test script can be modified to run specific test sections:

```bash
# Run just the fixed bugs tests
grep -A 20 "## Testing Fixed Bugs" test-pharocli.sh | head -40

# Run with verbose output for debugging
VERBOSE=1 ./test-pharocli.sh
```

## Test Count

- **Total Tests:** 28
- **Fixed Bugs:** 8
- **Core Functionality:** 16
- **Bash Integration:** 4

## CI/CD Integration

The test suite can be integrated into CI/CD:

```bash
#!/bin/bash
cd /path/to/pharocli

# Run tests
./test-pharocli.sh
if [ $? -ne 0 ]; then
    echo "PharoCLI tests failed"
    exit 1
fi
echo "All PharoCLI tests passed"
exit 0
```

## Adding New Tests

To add a new test, follow the pattern:

```bash
test_command \
    "description of test" \
    "command to run" \
    "expected output pattern"
```

Example:
```bash
test_command \
    "source with custom operator" \
    "python3 pharocli.py source \"Integer>> &\" 2>&1" \
    "bitShift"
```

## Troubleshooting

### Test fails with "command failed"
Check if the Pharo image is running on port 4044:
```bash
echo "3 + 4" | nc localhost 4044
```

### Test fails with "pattern not found"
Run with verbose output to see actual vs expected:
```bash
VERBOSE=1 ./test-pharocli.sh 2>&1 | grep -A 5 "failing_test_name"
```

### Test timeout
Some search operations can be slow. The test script has a 5-second timeout per command.

## Known Limitations

1. **Error handling tests** - Not all error conditions are tested (e.g., invalid depth) due to exit code handling complexity
2. **Performance tests** - No performance benchmarks included
3. **Pharo bugs** - Tests don't cover Pharo-side bugs (#4, #5, #6, #7, #10)

## Coverage

The test suite covers:
- ✅ All fixed Python bugs
- ✅ All basic commands
- ✅ All major command flags
- ✅ Bash integration patterns
- ❌ Error handling edge cases
- ❌ Performance/timeout behavior
- ❌ Pharo-side bugs

## Future Improvements

1. Add error handling tests
2. Add performance benchmarks
3. Add integration tests with real Pharo projects
4. Add tests for Pharo-side bugs when fixed
5. Generate coverage reports
6. Add CI/CD hooks

## Related Documentation

- `PHAROCLI-PYTHON-USAGE.md` - User guide
- `pharocli-python-bugs.md` - Bug report and fixes
- `AGENTS.md` - Project setup guide
