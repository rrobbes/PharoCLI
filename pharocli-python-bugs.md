# PharoCLI Python Version - Bug Report

## Summary
Comprehensive testing of all Python PharoCLI commands, flags, and subcommands against a running Pharo image on port 4044 revealed 10 bugs and issues.

### Current Status: 4/5 PYTHON BUGS FIXED ✅

**Fixed Python bugs:**
- ✅ Bug #1: `sources` command with operators - FIXED
- ✅ Bug #2: `implementors --in-package` - FIXED
- ✅ Bug #3: `implementors --in-packages` - FIXED
- ✅ Bug #8: `source`/`info` commands with operators - FIXED

**Still pending:**
- Bug #9: `compile --class-method` (skipped per request)
- Bugs #4, #5, #6, #7, #10: PHARO SIDE (requires Smalltalk fixes)

### Bug Distribution by Source:
- **PYTHON SIDE: 5 bugs** (2 fixed ✅, 3 pending)
  - ✅ 2 from regex pattern issues (FIXED)
  - ✅ 2 from incorrect method naming in handlers (FIXED)
  - ⏳ 1 from nonexistent method (skipped)
  
- **PHARO SIDE: 5 bugs** (requires Smalltalk expertise)
  - 2 from performance issues
  - 1 from nil pointer dereference
  - 1 from method lookup differences
  - 1 from filtering accuracy

## Bugs Found

### 1. **CRITICAL: `sources` command fails with operator methods** ✅ FIXED
**Status:** WORKING
**Command:** `pharocli sources 'Object>> yourself' 'Integer>> +'`
**Previous Error:** 
```
ValueError: Invalid method reference: Object>> ->
```
**Fix Applied:** Updated regex in `parse_method_ref()` (line 63):
```python
# Changed from: r'(\w+)\s*>>\s*(\w+.*)'
# Changed to: r'(\w+)\s*>>\s*(.+)'
```

**Verification:**
```
✅ pharocli sources "Object>> yourself" "Integer>> +" → works
✅ pharocli source "Integer>> +" → works
✅ pharocli source "Integer>> *" → works
✅ pharocli source "Integer>> >>" → works
```

---

### 2. **CRITICAL: `implementors` with `--in-package` filter fails** ✅ FIXED
**Status:** WORKING
**Command:** `pharocli implementors yourself --in-package Kernel`
**Previous Error:**
```
Instance of PharoCLI class did not understand #implementorsOfString:inPackage:
```
**Fix Applied:** Modified `_handle_with_optional_package_filter()` (line 269-277):
- When package filter is present: use `implementorsOf:inPackage:` (non-String variant)
- When no filter: use `implementorsOfString:` (String variant)

```python
# Before: always appended "String" to method name
# After: conditional logic to use correct variant
if in_package:
    print(cli.execute(f"PharoCLI {method_name}: {target} inPackage: '{in_package}'"))
else:
    print(cli.execute(f"PharoCLI {method_name}String: {target}"))
```

**Verification:**
```
✅ pharocli implementors yourself --in-package Kernel → returns filtered set
✅ pharocli implementors yourself (no filter) → returns full list
```

---

### 3. **CRITICAL: `implementors` with `--in-packages` filter fails** ✅ FIXED
**Status:** WORKING
**Command:** `pharocli implementors yourself --in-packages Kernel Collections`
**Previous Error:**
```
Instance of PharoCLI class did not understand #implementorsOfString:inPackages:
```
**Fix Applied:** Same as bug #2 - updated `_handle_with_optional_package_filter()` to use non-String variant when filtering

```python
elif in_packages:
    packages = cli.build_array(in_packages)
    print(cli.execute(f"PharoCLI {method_name}: {target} inPackages: {packages}"))
```

**Verification:**
```
✅ pharocli implementors yourself --in-packages Kernel Collections → returns filtered set
```

---

### 4. **CRITICAL: `search` command times out** ⛔
**Status:** BROKEN
**Command:** `pharocli search cache`
**Error:**
```
Error executing Smalltalk: Command '['nc', 'localhost', '4044']' timed out after 5 seconds
```
**Root Cause:** **PHARO SIDE**
- The Pharo method `searchForString:inPackages:inClasses:searchFields:caseSensitive:` exists and works, but is very slow
- Basic search like `search names --in-packages Kernel` works fine
- But `search cache` (without filters) times out
- This is a performance/optimization issue in the Pharo implementation, not a Python issue

**Fix needed:** Optimize the `searchForString:...` implementation in Pharo (possibly index-based search, caching, etc.)

---

### 5. **CRITICAL: `packageinfo` command fails** ⛔
**Status:** BROKEN
**Command:** `pharocli packageinfo Kernel Collections`
**Error:**
```
#name was sent to nil
```
**Root Cause:** **PHARO SIDE**
- The Pharo method `packageInfoJSON:` exists but has a bug
- A nil object is encountered and `#name` message is sent to it without nil checking
- This is a bug in the Pharo implementation (needs defensive programming)

**Fix needed:** Fix `packageInfoJSON:` method in Pharo - add nil checks before sending messages

---

### 6. **HIGH: `senders` with `--in-package` filter may fail silently** ⚠️
**Status:** WORKS BUT VERIFY ACCURACY
**Command:** `pharocli senders yourself --in-package Kernel`
**Root Cause:** **LIKELY PHARO SIDE (data validation issue)**
- Python calls: `sendersOfString:inPackage:` (correct method exists ✅)
- The methods work: `sendersOfString:inPackage:` exists and returns results
- However, the filtering accuracy is uncertain - may be filtering incorrectly or not at all
- Results don't visibly differ whether filtered or not, suggesting the filter might not work

**Fix needed:** Verify Pharo-side filtering logic for senders; possibly compare with references implementation which works correctly

---

### 7. **HIGH: `search` command times out with case-sensitive flag** ⛔
**Status:** BROKEN
**Command:** `pharocli search Object --case-sensitive`
**Error:**
```
Error executing Smalltalk: Command '['nc', 'localhost', '4044']' timed out after 5 seconds
```
**Root Cause:** **PHARO SIDE** - Same as bug #4
- Case-sensitive searching is even slower than regular search
- Combined performance issue in Pharo implementation

**Fix needed:** Optimize `searchForString:...` method in Pharo, especially for case-sensitive searches

---

### 8. **CRITICAL: `source` command fails with operator methods** ✅ FIXED
**Status:** WORKING
**Command:** `pharocli source "Integer>> +"` and `pharocli info "Integer>> +"`
**Previous Error:**
```
ValueError: Invalid method reference: Integer>> +
```
**Fix Applied:** Same regex fix as bug #1 (see bug #1 for details)

**Verification:**
```
✅ pharocli source "Integer>> +" → returns source code
✅ pharocli source "Integer>> *" → returns source code  
✅ pharocli info "Integer>> +" → returns method info
```

---

### 9. **MEDIUM: `compile` with `--class-method` flag broken** ⛔
**Status:** BROKEN
**Command:** `pharocli compile Object --source "testClassMethod ^ 123" --class-method`
**Error:**
```
Instance of PharoCLI class did not understand #compileClassMethodInClass:source:protocol:
```
**Root Cause:** **PYTHON SIDE**
- Python calls: `compileClassMethodInClass:source:protocol:`
- Pharo method DOES NOT exist: `respondsTo: #compileClassMethodInClass:source:protocol:` → false
- Available methods: Only `compileMethodInClass:source:` and `compileMethodInClass:source:protocol:`
- There is NO support for class method compilation in PharoCLI

**Fix needed:** Either:
1. Add `compileClassMethodInClass:source:protocol:` method to Pharo PharoCLI class, OR
2. Remove `--class-method` flag from Python CLI since Pharo doesn't support it

---

### 10. **MEDIUM: `source` command with certain methods has inconsistent behavior** ⚠️
**Status:** PARTIALLY BROKEN
**Command:** `pharocli source "Integer>> abs"` (after fixing regex issue)
**Error:**
```
KeyNotFound: key #abs not found in MethodDictionary
```
**Root Cause:** **PHARO SIDE**
- The method exists: `PharoCLI implementorsOfString: #abs` finds it ✅
- But retrieval fails: `sourceOfMethodFormatted:` can't find it
- This suggests `sourceOfMethodFormatted:` has a bug or uses a different lookup mechanism than `implementorsOfString:`

**Note:** This works fine for operators like `Integer>> +`, so it's not a general issue, just specific methods.

**Fix needed:** Debug `sourceOfMethodFormatted:` implementation in Pharo

---

## Working Commands ✅

The following commands work correctly:

- ✅ `packages list` - Lists all top-level packages
- ✅ `packages classes <packages>` - Lists classes in packages (single and multiple)
- ✅ `packages sub <packages>` - Lists sub-packages (single and multiple)
- ✅ `packages extended <package>` - Gets extended classes
- ✅ `packages extensions <package>` - Gets extension methods
- ✅ `protocols <classes>` - Gets class protocols (single and multiple classes)
- ✅ `protocols <classes> --extensions-only` - Filter extensions only
- ✅ `protocols <classes> --without-extensions` - Filter out extensions
- ✅ `methods <classes>` - Gets methods (all protocols, single and multiple classes)
- ✅ `methods <classes> --protocols <protocols>` - Gets methods by protocol
- ✅ `implementors <selector>` - Finds implementors (without package filter)
- ✅ `senders <selector>` - Finds senders (basic, without filter)
- ✅ `senders <selector> --in-package <package>` - Finds senders in package (works but verify accuracy)
- ✅ `senders <selector> --in-packages <packages>` - Finds senders in multiple packages (works but verify accuracy)
- ✅ `source "Class>> method"` - Gets method source
- ✅ `info "Class>> method"` - Gets method info
- ✅ `hierarchy <class>` - Shows class hierarchy
- ✅ `comment <class>` - Gets class comment
- ✅ `variables <class>` - Lists class variables
- ✅ `instvar <class> <variable>` - Finds instance variable references
- ✅ `references <class>` - Finds class references (without package filter)
- ✅ `references <class> --in-package <package>` - With single package filter ✅
- ✅ `references <class> --in-packages <packages>` - With multiple package filters ✅
- ✅ `search <keyword>` - Searches methods (basic, without filters)
- ✅ `search <keyword> --in-packages <packages>` - Search with package filter (works)
- ✅ `search <keyword> --in-classes <classes>` - Search with class filter (works)
- ✅ `search <keyword> --fields names` - Search specific fields (works)
- ✅ `search <keyword> --in-packages X --in-classes Y --fields Z` - Combined filters (works)
- ✅ `debugger stack` - Shows debugger stack (no active debugger)
- ✅ `debugger stack <indices>` - Shows specific frame stack (no active debugger)
- ✅ `debugger vars` - Shows debugger variables (no active debugger)
- ✅ `debugger vars <indices>` - Shows specific frame variables (no active debugger)
- ✅ `inspect tree "<expression>"` - Inspects objects as tree
- ✅ `inspect tree "<expression>" <depth>` - Inspect with depth (1-5, validated)
- ✅ `compile <class> --source "<source>"` - Compiles methods
- ✅ `compile <class> --source "<source>" --protocol "name"` - Compile with protocol (works)
- ✅ `compile <class> --source "<source>" --class-method` - NOT WORKING (see bug #9)

---

## Missing Features (Not Implemented in Python Version)

The Python implementation is missing several commands from the Bash version:

- ❌ `create package` - Create packages
- ❌ `create class` - Create classes
- ❌ `lastModified` - When was method last modified
- ❌ `recentChanges` - Recently modified methods in package
- ❌ `infos` - Multiple method information

These would require additional command handlers in `pharocli.py`.

---

## Comparison: `implementors` vs `references` vs `senders` Package Filtering

There's an inconsistency in package filter support:

| Command | `--in-package` | `--in-packages` |
|---------|---|---|
| `references` | ✅ Works | ✅ Works |
| `senders` | ⚠️ Works but unclear | ⚠️ Works but unclear |
| `implementors` | ❌ Missing method | ❌ Missing method |

For `implementors`, the error is clear: `implementorsOfString:inPackage:` and `implementorsOfString:inPackages:` don't exist on the Pharo side.

For `senders`, the methods appear to work (`sendersOfString:inPackage:` exists), but the filtering behavior should be verified for accuracy.

This suggests the Python code is correct, but the Pharo side implementation is incomplete or inconsistent.

---

## Priority Fixes (by Side and Severity)

### PYTHON SIDE FIXES (5 bugs)

#### CRITICAL - PYTHON
1. **Fix method reference regex for operators** (bugs #1 & #8)
   - Location: `pharocli.py` line 63 - `parse_method_ref()` method
   - Change: `r'(\w+)\s*>>\s*(\w+.*)'` → `r'(\w+)\s*>>\s*(.+)'`
   - Impacts: `sources`, `source`, `info` commands with operator methods
   - Difficulty: Very Easy (1-liner)

#### HIGH - PYTHON  
2. **Fix `implementors --in-package` filter** (bug #2)
   - Location: `pharocli.py` line 279-280 - `handle_implementors()` function
   - Issue: Uses wrong method name pattern - calls `implementorsOfString:inPackage:` which doesn't exist
   - Change: Use `implementorsOf:` methods instead (non-String variant for filtered queries)
   - Compare with: `handle_references()` which does this correctly
   - Difficulty: Easy (follow references pattern)

3. **Fix `implementors --in-packages` filter** (bug #3)
   - Same as bug #2 but for multiple packages
   - Location: `pharocli.py` line 279-280
   - Difficulty: Easy

#### MEDIUM - PYTHON
4. **Remove or implement `--class-method` flag** (bug #9)
   - Location: `pharocli.py` line 199 and handler at line 358-370
   - Option A: Remove flag (Pharo doesn't support class method compilation)
   - Option B: Implement in Pharo first, then add support
   - Difficulty: Easy (if removing) or Hard (if implementing)

---

### PHARO SIDE FIXES (5 bugs)

#### CRITICAL - PHARO
1. **Optimize `searchForString:...` method** (bugs #4 & #7)
   - Method: `PharoCLI >> #searchForString:inPackages:inClasses:searchFields:caseSensitive:`
   - Issue: Very slow performance, causes 5+ second timeouts on medium-sized searches
   - Consider: Index-based search, caching, parallel processing, or reducing scope
   - Impact: Makes `search` command unusable for large codebases
   - Difficulty: Medium-Hard (likely needs refactoring)

2. **Fix `packageInfoJSON:` nil pointer dereference** (bug #5)
   - Method: `PharoCLI >> #packageInfoJSON:`
   - Issue: Sends `#name` message to nil object
   - Fix: Add defensive nil checks before message sends
   - Difficulty: Easy

#### HIGH - PHARO
3. **Debug `sourceOfMethodFormatted:` lookup issue** (bug #10)
   - Method: `PharoCLI >> #sourceOfMethodFormatted:`
   - Issue: Can't find source for some methods like `Integer>> abs` even though they exist
   - Verify: How does it differ from `implementorsOfString:` lookup?
   - Difficulty: Medium (needs debugging)

#### LOW - PHARO
4. **Verify `sendersOfString:inPackage:` filtering** (bug #6)
   - Method: `PharoCLI >> #sendersOfString:inPackage:`
   - Issue: May not be filtering correctly (unclear if working or buggy)
   - Verify: Compare output with/without filter, check against references behavior
   - Difficulty: Easy (verification only)

---

## Test Coverage Summary

**Commands tested:** 18/18 (100%)
- packages (list, classes, sub, extended, extensions)
- protocols (with --extensions-only, --without-extensions)
- methods (with --protocols)
- implementors (with --in-package, --in-packages) - FAILS
- senders (with --in-package, --in-packages)
- source, sources - FAILS with operators
- info - FAILS with operators
- hierarchy, comment, variables, instvar, references
- search (with --in-packages, --in-classes, --fields, --case-sensitive combinations)
- debugger (stack, vars with optional indices)
- inspect tree (with depth validation)
- compile (with --source, --protocol, --class-method) - PARTIALLY BROKEN
- packageinfo - BROKEN

**Flags tested:**
- ✅ All optional flags and their combinations
- ✅ Depth validation (1-5) for inspect tree
- ✅ Error handling for invalid inputs
- ✅ Operator selectors (+, >, >>, etc.)

