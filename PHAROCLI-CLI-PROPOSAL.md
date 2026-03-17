# PharoCLI Bash Script - Proposed Interface

## Query Packages

### List all top-level packages
```bash
pharocli --port 4044 packages
```

### List classes in packages
```bash
pharocli --port 4044 packages classes Kernel
pharocli --port 4044 packages classes Kernel Collections-Abstract
```

### List sub-packages of top-level packages
```bash
pharocli --port 4044 packages sub Spec2
pharocli --port 4044 packages sub Spec2 NewTools
```

### Get extended classes in a package
```bash
pharocli --port 4044 packages extended Ring-Core
```

### Get extension methods in a package
```bash
pharocli --port 4044 packages extensions Ring-Core
```

## Query Protocols

### Get protocols in classes
```bash
pharocli --port 4044 protocols Object
pharocli --port 4044 protocols Object String
```

### Get protocols with filters
```bash
pharocli --port 4044 protocols Object --extensions-only
pharocli --port 4044 protocols Object --without-extensions
pharocli --port 4044 protocols Object String --extensions-only
```

## Query Methods

### Get methods in classes
```bash
pharocli --port 4044 methods Object
pharocli --port 4044 methods Object String
```

### Get methods with protocol filter
```bash
pharocli --port 4044 methods Object --protocols accessing
pharocli --port 4044 methods Object String --protocols accessing printing
```

## Method Relationships

### Find implementors of a selector
```bash
pharocli --port 4044 implementors yourself
pharocli --port 4044 implementors yourself --in-package Kernel
pharocli --port 4044 implementors yourself --in-packages Kernel Collections
```

### Find senders of a selector
```bash
pharocli --port 4044 senders yourself
pharocli --port 4044 senders class --in-package Kernel
pharocli --port 4044 senders class --in-packages Kernel Collections
```

## Source Code and Information

### Get source code of a method
```bash
pharocli --port 4044 source Object>> yourself
```

### Get source code of multiple methods
```bash
pharocli --port 4044 sources Object>> yourself String>> size
```

### Get detailed method information
```bash
pharocli --port 4044 info Object>> yourself
```

### Get information for multiple methods
```bash
pharocli --port 4044 infos Object>> yourself String>> size
```

## Create

### Create a package
```bash
pharocli --port 4044 create package My-Package
```

### Create a class in a package
```bash
pharocli --port 4044 create class MyClass --in-package My-Package
```

## Port Specification

Port can be specified with `--port` or `-p`:
```bash
pharocli -p 4044 packages
pharocli --port 4044 packages
```

## Output Format

All commands output line-by-line for easy grepping:
```bash
pharocli --port 4044 packages | grep -i collections
pharocli --port 4044 implementors yourself | grep Kernel
pharocli --port 4044 methods Object --protocols accessing | head -5
```

## Implementation Notes

- Multiple items passed as separate positional arguments (packages, classes, protocols, selectors)
- Filters use flags: `--in-package`, `--in-packages`, `--protocols`, `--extensions-only`, `--without-extensions`, `--in-package`
- Uses `*String` variants of PharoCLI methods for line-by-line output
- Method references use `ClassName>> methodName` syntax
