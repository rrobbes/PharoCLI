# PharoCLI - Command-Line Interface for Pharo Image Inspection

PharoCLI is a bash script that provides convenient command-line access to Pharo image inspection and navigation. It bridges shell scripting with Pharo's reflective capabilities, enabling powerful code exploration workflows.

## Installation

```bash
# Make the script executable
chmod +x pharocli

# Optionally add to PATH for global access
cp pharocli /usr/local/bin/
```

## Usage Basics

```bash
pharocli [--port PORT] COMMAND [ARGUMENTS...]

# Default port: 4044
pharocli packages                    # List packages
pharocli -p 5555 packages           # Custom port
pharocli --help                     # Full help
```

## Commands

### Packages

```bash
pharocli packages                           # List all top-level packages
pharocli packages classes Kernel           # Classes in package
pharocli packages classes Kernel Collections-Abstract  # Multiple packages
pharocli packages sub Spec2 NewTools       # Sub-packages of packages
pharocli packages extended Ring-Core       # Classes extended by package
pharocli packages extensions Ring-Core     # Extension methods in package
```

### Protocols

```bash
pharocli protocols Object                          # All protocols in class
pharocli protocols Object String                   # Protocols from multiple classes
pharocli protocols Object --without-extensions     # Local protocols only
pharocli protocols Object --extensions-only       # Extension protocols only (*)
```

### Methods

```bash
pharocli methods Object                                    # All methods
pharocli methods Object String                             # Methods in multiple classes
pharocli methods Object --protocols accessing printing     # Methods in specific protocols
```

### Find Implementors & Senders

```bash
pharocli implementors yourself                              # All implementors
pharocli implementors yourself --in-package Kernel          # In one package
pharocli implementors yourself --in-packages Kernel Collections  # In multiple packages

pharocli senders yourself                                   # All senders
pharocli senders yourself --in-package Kernel               # In one package
pharocli senders yourself --in-packages Kernel Collections  # In multiple packages
```

### Source Code & Info

```bash
pharocli source "Object>> yourself"                         # View source (requires quotes)
pharocli sources "Object>> yourself" "String>> isString"    # Multiple methods
pharocli info "Object>> yourself"                           # Method information
pharocli infos "Object>> yourself" "String>> isString"      # Multiple methods info
```

### Create

```bash
pharocli create package My-Package                          # Create package
pharocli create class MyClass --in-package My-Package       # Create class
```

### Change History (Epicea)

```bash
pharocli lastModified "Object>> yourself"                   # When was method last modified (requires quotes)
pharocli recentChanges Kernel                               # Recently modified methods in package (default: 10)
pharocli recentChanges Kernel 20                            # Limit to 20 results
pharocli recentChanges Pharo-CLI-Tests 5                    # Last 5 changes
```

### Class Hierarchy

```bash
pharocli hierarchy String                                   # Show superclass and subclasses
pharocli hierarchy Object                                   # Show hierarchy for any class
```

### Class Documentation

```bash
pharocli comment String                                     # Get class comment/documentation
pharocli comment Collection                                 # Works for any class
```

### Class Variables & Structure

```bash
pharocli variables Point                                    # List instance/class variables and slots
pharocli variables String                                   # Works for any class
pharocli variables Point | grep instance                    # Grep-friendly: filter by type
```

### Instance Variable References

```bash
pharocli instvar Point x                                    # Find all methods accessing Point's x variable
pharocli instvar Point y | wc -l                           # Count how many methods use y
pharocli instvar String size | grep ">>at"                 # Find specific accessor methods
```

### Class References

```bash
pharocli references String                                  # Find all methods that reference String
pharocli references Object --in-package Kernel             # Find references in specific package
pharocli references String --in-packages Kernel Collections # Find references in multiple packages
```

### Search

```bash
pharocli search "yourself"                                  # Search all methods by keyword
pharocli search "yourself" --in-packages Kernel             # Search in specific packages
pharocli search "size" --in-classes String Array            # Search in specific classes
pharocli search "at" --fields names source                 # Search specific fields only
pharocli search "Size" --case-sensitive                    # Case-sensitive search
```

## Practical Examples

### Find all methods in Kernel's accessing protocol
```bash
pharocli methods Object --protocols accessing | grep -i size
```

### Explore which packages extend Object
```bash
pharocli protocols Object --extensions-only | cut -d'*' -f2 | sort -u
```

### Find senders of a selector across specific packages
```bash
pharocli senders at: --in-packages Kernel Collections-Abstract | head -10
```

### Get class information and source
```bash
pharocli packages classes Kernel | head -5 | while read class; do
  echo "=== $class ==="
  pharocli implementors initialize --in-package Kernel | grep "^$class"
done
```

### Find extension methods added to Object
```bash
pharocli protocols Object --extensions-only | while read proto; do
  echo "Extension protocol: $proto"
  pharocli methods Object --protocols "$proto" | wc -l
done
```

### Browse methods and look for specific implementation
```bash
pharocli methods String --protocols accessing | while read method; do
  pharocli senders "$method" | wc -l | xargs echo "$method:" 
done | sort -t: -k2 -rn | head -5
```

### Track recent changes in a package
```bash
# See what was recently modified
pharocli recentChanges Pharo-CLI-Tests 10

# Get source of recently changed methods
pharocli recentChanges Kernel 3 | while read method; do
   echo "=== $method ==="
   class="${method%%>>*}"
   sel="${method##*>>}"
   pharocli source "\"$class>> $sel\""
done
```

### Explore class hierarchy
```bash
# See what a class inherits from and what inherits from it
pharocli hierarchy String

# Check multiple classes
for class in String Symbol Boolean; do
  echo "=== $class ==="
  pharocli hierarchy "$class"
done
```

### Read class documentation
```bash
# Get documentation for a class
pharocli comment String

# Read multiple class comments
for class in Collection Array Dictionary; do
  echo "=== $class ==="
  pharocli comment "$class" | head -5
done
```

### Explore class structure
```bash
# See what variables a class has
pharocli variables Point

# List only instance variables
pharocli variables Point | grep instance

# List only class variables
pharocli variables String | grep class

# Filter by exact field name
pharocli variables Point | grep ' y$'
```

### Find usage of instance variables
```bash
# See all methods that access an instance variable
pharocli instvar Point x

# Count how many methods access a variable
pharocli instvar Point x | wc -l

# Find which methods in a specific class access it
pharocli instvar Point x | grep "^Point"

# Find methods with specific patterns
pharocli instvar Point x | grep ">>[+*/-]$"
```

## Output Format

All commands output **line-by-line** for easy piping:
- Packages and classes: one per line
- Methods: `ClassName>>methodName` format
- Protocols: protocol name per line (extensions prefixed with `*`)
- Source code: properly formatted with newlines

## Change History (Epicea)

PharoCLI integrates with Epicea, the event log in Pharo, to track method modifications:

- `lastModified` shows when a method was last changed (in current session)
- `recentChanges` lists methods modified in a package, ordered by recency
- Both commands work with Epicea's session-based tracking

**Limitations:**
- Only tracks changes made **after** monitoring started
- Resets on image restart (unless explicitly saved)
- Shows current session time as modification indicator

## Tips

- **Quoting method references**: Always quote method references due to bash `>>` redirection: `pharocli source "Object>> yourself"`
- **Pipe output**: All results are line-by-line, making them grep/awk/cut friendly
- **Multiple items**: Pass multiple packages/classes/selectors as separate arguments
- **Filters are flexible**: Combine `--in-package`, `--in-packages`, `--protocols`, `--extensions-only`, `--without-extensions` as needed
- **Performance**: Commands with large results (all senders of common messages) may take a moment
- **Change tracking**: Use `recentChanges` to audit what was modified in a package

## Advanced Example: Keyword-Based Method Discovery

Search for methods across packages using multiple keywords to find relevant functionality:

```bash
#!/bin/bash
# Find cache-related methods in Collections packages

PACKAGES="Collections-Abstract Collections-Sequenceable"
KEYWORDS="cache flush clear reset"

for keyword in $KEYWORDS; do
  echo "=== Methods matching '$keyword' ==="
  for pkg in $PACKAGES; do
    pharocli packages classes "$pkg" | while read class; do
      pharocli methods "$class" | grep -i "$keyword" | \
        sed "s/^/$class>>/" 
    done
  done
done | sort -u
```

This workflow:
1. Lists all classes in target packages
2. Gets all methods from each class
3. Filters by keywords (case-insensitive)
4. Shows which class each method belongs to
5. Removes duplicates and sorts

Output shows methods like `ArrayedCollection>>cacheSize`, `WeakSet>>flushCaches`, etc.

Extend this to:
- Get sender counts: pipe matches through `pharocli senders`
- Get source: `pharocli source "ClassName>> methodName"`
- Filter by protocol: add `--protocols streaming` to methods command
- Search multiple families: expand the PACKAGES variable

## Environment

The script communicates with a Pharo image via netcat on port 4044 (configurable). Ensure your Pharo image is running and listening on this port.

```bash
# In Pharo (or startup script):
(Smalltalk wordPointersInMemory < 2000000)
  ifTrue: [ ZnServer startDefaultOn: 4044 ]
```
