# PharoCLI Script - Fixes Summary

## Issues Fixed

### 1. Method Reference Parsing (`>>` redirection issue)
**Problem**: Bash was interpreting `>>` as output redirection.
**Solution**: 
- Updated help text to require quoting method references: `"Object>> yourself"`
- Fixed parsing to handle spaces: `Object>> yourself` or `Object>>yourself`
- Applied consistent parsing in `source`, `sources`, `info`, and `infos` commands

### 2. Protocol Filters for Multiple Classes
**Problem**: `protocolsInClass:extensionsOnly:` only worked on single classes
**Solution**: Added two new PharoCLI methods:
- `protocolsInClassesString:extensionsOnly:` - Multi-class protocols, extensions only
- `protocolsInClassesString:withoutExtensions:` - Multi-class protocols, local only

Updated script to use the new methods instead of trying to pass collections.

### 3. Senders Without String Variant
**Problem**: `sendersOfString:` and variants didn't exist
**Solution**: Added three new PharoCLI methods:
- `sendersOfString:` - Basic senders formatted output
- `sendersOfString:inPackage:` - Senders in package, formatted
- `sendersOfString:inPackages:` - Senders in packages, formatted

Updated script to use the new methods directly instead of collecting results.

## New PharoCLI Methods (Red/Green TDD)

All methods implemented and tested:

```smalltalk
"Senders - formatted output variants"
PharoCLI sendersOfString: aSelector
PharoCLI sendersOfString: aSelector inPackage: packageName
PharoCLI sendersOfString: aSelector inPackages: packageNames

"Protocols - multi-class filter variants"
PharoCLI protocolsInClassesString: classes extensionsOnly: aBoolean
PharoCLI protocolsInClassesString: classes withoutExtensions: aBoolean
```

All 35 tests in PharoCLITest pass (including 5 new ones for these methods).

## Updated Usage Examples

```bash
# Protocols with filters (now works correctly)
pharocli protocols Object --without-extensions
pharocli protocols Object String --extensions-only

# Senders with package filtering (now returns formatted output)
pharocli senders yourself --in-package Kernel
pharocli senders yourself --in-packages Kernel Collections

# Method source/info (requires quoting due to bash >> redirection)
pharocli source "Object>> yourself"
pharocli sources "Object>> yourself" "String>> size"
pharocli info "Object>> yourself"
pharocli infos "Object>> yourself" "String>> size"
```

## Testing

All functionality tested:
- ✅ `packages` commands
- ✅ `protocols` with filters (both `--without-extensions` and `--extensions-only`)
- ✅ `methods` with protocol filtering
- ✅ `implementors` with package filtering
- ✅ `senders` with package filtering (formatted output)
- ✅ `source` / `sources` (with proper quoting)
- ✅ `info` / `infos` (with proper quoting)
- ✅ `create` package and class
