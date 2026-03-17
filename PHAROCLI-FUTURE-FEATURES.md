# PharoCLI - Future Features Backlog

Features identified during development that should be implemented later.

## Navigation & Hierarchy

### ✅ IMPLEMENTED: hierarchy CLASS
Show class hierarchy (superclass chain and direct subclasses)

```bash
pharocli hierarchy Object
# Output:
# Object
# ======
# 
# Superclass: ProtoObject
# 
# Subclasses: (hundreds of classes listed)
```

**Use case:** Understanding class relationships and inheritance chains

**PharoCLI methods implemented:**
- `hierarchyOf: aClass` - Returns a Set containing superclass and direct subclasses
- `hierarchyOfString: aClass` - Formatted output showing class name, superclass, and alphabetically-sorted subclasses

**Tests:**
- `testHierarchyOfClass` - Validates Set-returning variant
- `testHierarchyOfClassString` - Validates formatted String variant

---

### ✅ IMPLEMENTED: variables CLASS
List instance variables, class variables, and object slots

```bash
pharocli variables Point
# Output (space-separated, grep-friendly):
# Point instance x
# Point instance y
# Point slot x
# Point slot y
```

**Use case:** Understanding object structure and data layout

**PharoCLI methods implemented:**
- `variablesOf: aClass` - Returns Set of {className, type, name} tuples
- `variablesOfString: aClass` - Space-separated output (grep-friendly)

**Tests:**
- `testVariablesOfClass` - Validates collection return
- `testVariablesOfClassString` - Validates formatted output

---

### traits CLASS
Show traits composed into a class

```bash
pharocli traits MyClass
# Output:
# TMyTrait
# TAnotherTrait
```

**Use case:** Understanding trait composition and method resolution

**PharoCLI methods needed:**
- `traitsOf: aClass` - Returns traits
- `traitsOfString: aClass` - Formatted output

---

## Documentation

### ✅ IMPLEMENTED: comment CLASS
Get class comment

```bash
pharocli comment String
# Output: (full class comment with header)
```

**Use case:** Reading class documentation without opening IDE

**PharoCLI methods implemented:**
- `commentOf: aClass` - Returns raw comment string
- `commentOfString: aClass` - Formatted output with class name header

**Tests:**
- `testCommentOfClass` - Validates comment retrieval
- `testCommentOfClassString` - Validates formatted output

---

### comment CLASS>> METHOD
Get method comment (if docstring/pragma exists)

```bash
pharocli comment "Object>> yourself"
# Output: (method comment if available)
```

**Use case:** Reading method documentation inline

**PharoCLI methods needed:**
- `commentOfMethod: aCompiledMethod` - Returns comment string
- `commentOfMethodString: aCompiledMethod` - Formatted output

---

## Testing

### tests PACKAGE
Find test classes related to a package

```bash
pharocli tests Kernel
# Output:
# KernelTest
# ObjectTest
# BehaviorTest
```

**Use case:** Locating test suite for a package

**PharoCLI methods needed:**
- `testClassesForPackage: packageName` - Returns test classes
- `testClassesForPackageString: packageName` - Formatted output

---

### tests CLASS
Find test methods related to a class

```bash
pharocli tests String testClass
# Output:
# testSize
# testCopy
# testAt:put:
```

**Use case:** Finding tests for specific functionality

**PharoCLI methods needed:**
- `testMethodsForClass: aClass` - Returns test methods
- `testMethodsForClassString: aClass` - Formatted output

---

## Dependencies & References

### references CLASS
Find all references to a class (not just senders)

```bash
pharocli references MyClass
# Output:
# (all methods that reference MyClass, not just send messages)
```

**Use case:** Impact analysis - "what breaks if I remove/change this class?"

**Complexity:** High - requires parsing source code and annotations

**PharoCLI methods needed:**
- `referencesOf: aClass` - Returns methods referencing the class
- `referencesOfString: aClass` - Formatted output

---

### dependencies PACKAGE
Show what packages this package depends on

```bash
pharocli dependencies Spec2
# Output:
# Kernel
# Collections-Abstract
# FFI (optional)
```

**Use case:** Understanding package coupling

**PharoCLI methods needed:**
- `dependenciesOf: packageName` - Returns dependency packages
- `dependenciesOfString: packageName` - Formatted output

---

### dependents PACKAGE
Show what packages depend on this package

```bash
pharocli dependents Kernel
# Output:
# Collections-Abstract
# AST
# Metacello
# (hundreds of results typically)
```

**Use case:** Understanding how critical a package is

**PharoCLI methods needed:**
- `dependentsOf: packageName` - Returns dependent packages
- `dependentsOfString: packageName` - Formatted output

---

## Search & Discovery

### ✅ IMPLEMENTED: search KEYWORD
Full-text search in method names, source code, and comments

```bash
pharocli search "cache" Kernel
# Output:
# (all methods matching "cache" in Kernel)
```

**Use case:** Finding methods when you only remember a partial name or concept

**PharoCLI methods implemented:**
- `searchFor:inPackages:inClasses:searchFields:caseSensitive:` - Returns matching methods
- `matchesMethod:keyword:fields:caseSensitive:` - Helper to match method against keyword
- `searchForString:inPackages:inClasses:searchFields:caseSensitive:` - Formatted output

**Tests:**
- `testSearchForKeywordInAllPackages` - Search across all packages
- `testSearchForKeywordInSpecificPackage` - Search in one package
- `testSearchForKeywordInMultiplePackages` - Search in multiple packages
- `testSearchForKeywordInSpecificClass` - Search in one class
- `testSearchForKeywordInMultipleClasses` - Search in multiple classes
- `testSearchByNameOnly` - Filter to method names only
- `testSearchBySourceOnly` - Filter to source code only
- `testSearchString` - String output formatting
- `testSearchCaseSensitive` - Case sensitivity control

---

### ✅ IMPLEMENTED: references CLASS
Find all methods that reference a class

```bash
pharocli references String
# Output:
# (all methods that reference String)
```

**Use case:** Impact analysis - "what breaks if I remove/change this class?"

**Complexity:** Low - uses existing SystemNavigation infrastructure

**PharoCLI methods implemented:**
- `referencesOf: className` - Returns methods referencing the class
- `referencesOf:inPackage:` - Restrict to one package
- `referencesOf:inPackages:` - Restrict to multiple packages
- `referencesOfString:` - Formatted output
- `referencesOfString:inPackage:` - Formatted output, single package
- `referencesOfString:inPackages:` - Formatted output, multiple packages

**Tests:**
- `testReferencesOfClass` - Find references to class
- `testReferencesOfClassInPackage` - Filter by package
- `testReferencesOfClassInMultiplePackages` - Filter by multiple packages
- `testReferencesOfString` - String formatting
- `testReferencesOfStringInPackage` - String formatting, single package

---

### slots CLASS
Show object layout - slots/fields and their types

```bash
pharocli slots String
# Output:
# string (ByteString | String)
# size (SmallInteger)
```

**Use case:** Understanding memory layout and field types

**Complexity:** High - requires reflection on object layout

**PharoCLI methods needed:**
- `slotsOf: aClass` - Returns slot definitions
- `slotsOfString: aClass` - Formatted output

---

## Priority Ranking

**HIGH PRIORITY** (implement first):
1. ✅ hierarchy - Essential for navigation [IMPLEMENTED]
2. ✅ comment CLASS - Essential documentation access [IMPLEMENTED]
3. ✅ variables - Understanding object structure [IMPLEMENTED]
4. ✅ search - Powerful discovery tool [IMPLEMENTED]
5. ✅ references - Impact analysis and dependencies [IMPLEMENTED]

**MEDIUM PRIORITY** (nice to have):
6. traits - Composition understanding
7. tests CLASS - Test discovery
8. dependencies - Package structure
9. comment METHOD - Method documentation

**LOW PRIORITY** (complex, less common):
10. dependents - Complex analysis
11. slots - Advanced reflection
12. tests PACKAGE - Less common than tests CLASS

---

## Implementation Notes

- All features should follow existing patterns: non-String method returning Set/Collection, String variant for formatted output
- Quoting requirements for class/method references should be consistent
- Default limits (like recentChanges default 10) should be configurable
- Performance considerations for large search spaces (all dependents of Kernel = potentially all packages)
