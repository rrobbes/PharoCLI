# PharoCLI Python Version - Usage Guide

PharoCLI is a command-line interface for inspecting and navigating Pharo image code. The Python version provides convenient access to Pharo's reflective capabilities from your shell.

## Installation

```bash
# Make the script executable
chmod +x pharocli.py

# Run directly
python3 pharocli.py [command] [options]

# Or create an alias for convenience
alias pharocli="python3 /path/to/pharocli.py"
```

## Architecture

- **Python client** (`pharocli.py`): Parses CLI arguments and builds Smalltalk queries
- **Pharo image**: Runs on port 4044 (default), processes queries via netcat
- **Communication**: Simple text protocol over netcat

## Quick Start

```bash
# List all packages
pharocli packages

# Find implementors of a method
pharocli implementors yourself

# Get method source code
pharocli source "Object>> yourself"

# Search for methods containing "test"
pharocli search test

# Get class hierarchy
pharocli hierarchy String
```

## Commands

### Package Management

```bash
# List all top-level packages
pharocli packages

# List classes in packages
pharocli packages classes Kernel Collections

# List sub-packages
pharocli packages sub Spec2

# Show classes extended by a package
pharocli packages extended Ring-Core

# Show extension methods in a package
pharocli packages extensions Ring-Core
```

### Class Inspection

```bash
# Show class hierarchy (superclass & subclasses)
pharocli hierarchy Object

# Get class comment/documentation
pharocli comment Object

# List class instance/slot variables
pharocli variables Point

# Find methods accessing instance variable
pharocli instvar Point x
```

### Method Inspection

```bash
# Get all methods in a class
pharocli methods Object

# Get methods in specific protocols
pharocli methods Object --protocols accessing printing

# Get protocols in a class
pharocli protocols Object

# Filter extension protocols only
pharocli protocols Object --extensions-only

# Filter out extension protocols
pharocli protocols Object --without-extensions

# Get method source code
pharocli source "Object>> yourself"

# Get source for multiple methods
pharocli sources "Object>> yourself" "String>> isString"

# Get method info (protocol, location, senders, implementors)
pharocli info "Object>> yourself"
```

### Method Finding & Code Navigation

```bash
# Find all implementors of a selector
pharocli implementors yourself

# Find implementors in specific package
pharocli implementors yourself --in-package Kernel

# Find implementors in multiple packages
pharocli implementors yourself --in-packages Kernel Collections

# Find all senders of a selector
pharocli senders yourself

# Find senders in specific package
pharocli senders yourself --in-package Kernel

# Find class references
pharocli references Object

# Find references in package
pharocli references Object --in-package Kernel

# Search for methods by keyword
pharocli search cache

# Search with filters
pharocli search test --in-packages Kernel --in-classes Object String --fields names

# Case-sensitive search
pharocli search MyClass --case-sensitive
```

### Object Inspection

```bash
# Inspect object structure as tree
pharocli inspect tree "Point x: 10 y: 20"

# Inspect with depth limit (1-5)
pharocli inspect tree "Array with: 1 with: 2 with: 3" 2
```

### Method Compilation

```bash
# Compile a method
pharocli compile Object --source "myMethod ^ 42"

# Compile with specific protocol
pharocli compile Object --source "myMethod ^ 42" --protocol "my protocol"
```

### Debugger Access

```bash
# Show current debugger stack with source
pharocli debugger stack

# Show specific stack frames
pharocli debugger stack 0 1 2

# Show stack frame variables
pharocli debugger vars

# Show specific frame variables
pharocli debugger vars 0 1
```

## Advanced: Integration with Bash

### Find all methods containing a pattern

```bash
# Find all methods with "test" in name in Kernel package
pharocli search test --in-packages Kernel | grep -i test
```

### Extract method locations

```bash
# Get all methods in Object, filter to just "accessing" protocol
pharocli methods Object --protocols accessing | head -20
```

### Parse results with jq (if output is JSON)

```bash
# Get package info as JSON
pharocli packageinfo Kernel Collections | jq '.packages[] | .name'
```

### Chain multiple queries

```bash
# Find all implementors of yourself, check which ones are in Kernel
pharocli implementors yourself | grep -E "^[A-Z]" | while read method; do
  class=$(echo "$method" | cut -d'>' -f1)
  if pharocli references $class --in-package Kernel > /dev/null 2>&1; then
    echo "$class is in Kernel"
  fi
done
```

### Search and extract specific columns

```bash
# Find senders of a method and count them
pharocli senders yourself | wc -l

# Find implementors in specific packages
pharocli implementors + --in-packages Kernel Collections | grep -v "^'"
```

### Build method call chains

```bash
# Find all methods an object responds to, filter for specific names
pharocli methods Object | grep "as" | head -10

# Find all extension methods in Collections package
pharocli packages extensions Collections | grep -E "^\w+>>" | wc -l
```

### Complex analysis pipeline

```bash
# Find all senders of '+' operator in Kernel, extract unique classes
pharocli senders "+" --in-package Kernel | \
  sed 's/>>.*//' | \
  sort | uniq | \
  wc -l
```

## Operator Methods

The Python version fully supports operator methods (fixed in recent version):

```bash
# Get source of arithmetic operators
pharocli source "Integer>> +"
pharocli source "Integer>> *"
pharocli source "Integer>> >>"

# Find implementors of operators
pharocli implementors "+"
pharocli implementors ">>"
pharocli implementors "<<"

# Get info on operators
pharocli info "Number>> +"
```

## Common Workflows

### Explore a class hierarchy

```bash
# Get class hierarchy
pharocli hierarchy MyClass

# Get all methods
pharocli methods MyClass

# Get methods by protocol
pharocli methods MyClass --protocols 'private' 'public'

# Check what the class extends
pharocli variables MyClass
```

### Find where something is used

```bash
# Find all senders of a method
pharocli senders mySelector

# Narrow down to a package
pharocli senders mySelector --in-package MyPackage

# Find classes that reference another class
pharocli references MyClass --in-package MyPackage
```

### Understand method implementations

```bash
# Find all implementors
pharocli implementors mySelector

# Get source for each
pharocli sources "Class1>> mySelector" "Class2>> mySelector" "Class3>> mySelector"

# Compare protocols
pharocli protocols Class1 Class2 Class3
```

### Search code for patterns

```bash
# Find all methods with "test" in name
pharocli search test --in-packages MyTestPackage

# Search in specific classes
pharocli search cache --in-classes MyClass AnotherClass

# Case-sensitive search
pharocli search MyExactName --case-sensitive
```

## Configuration

Default settings:

```bash
# Port (can be overridden)
pharocli -p 5555 packages  # Use port 5555 instead of default 4044
```

## Troubleshooting

### "Command timed out"

The default timeout is 5 seconds. This can happen with large searches:

```bash
# Large searches may time out
pharocli search cache  # ❌ Timeout

# Use filters to narrow results
pharocli search test --in-packages Kernel  # ✅ Works
```

### "KeyNotFound" errors

Method doesn't exist in that class:

```bash
# Check if the method exists
pharocli implementors abs  # Check implementors first

# Get source for a real implementor
pharocli source "Integer>> abs"
```

### "Instance of PharoCLI did not understand"

The Pharo method doesn't exist. This should not happen with recent versions. Report if encountered.

## Recent Fixes

- ✅ Operator methods now supported (e.g., `"Integer>> +"`)
- ✅ `implementors --in-package` and `--in-packages` filters work
- ✅ `sources` command works with operators

See `pharocli-python-bugs.md` for detailed bug reports and fixes applied.

## Performance Tips

1. **Use filters**: Add `--in-package` or `--in-packages` to narrow search scope
2. **Specify classes**: Use `--in-classes` to search specific classes only
3. **Avoid global searches**: `pharocli search test` may timeout; use `pharocli search test --in-packages Kernel`
4. **Use protocols**: Filter methods by protocol to reduce results

## See Also

- `pharocli-python-bugs.md` - Bug report and fixes applied
- `PHAROCLI-DOCUMENTATION.md` - Original bash version documentation (deprecated)
- `PHAROCLI-GUIDE.md` - Pharo-side PharoCLI class reference
