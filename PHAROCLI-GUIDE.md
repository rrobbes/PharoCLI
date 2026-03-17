# PharoCLI Guide

PharoCLI is a utility class for programmatic navigation and inspection of the Pharo image. It provides convenient methods to query packages, classes, protocols, methods, and their relationships.

## Querying Packages

### List all top-level packages (filtered)

Excludes BaselineOf packages and _UnpackagedPackage.

```smalltalk
PharoCLI topLevelPackages
"Returns: Set of symbols like #Kernel, #Collections, #Spec2, etc."

PharoCLI topLevelPackagesString
"Returns: Formatted string with one package per line"
```

### Find sub-packages of top-level packages

```smalltalk
PharoCLI subPackagesOf: #('NewTools' 'Spec2')
"Returns: Set of all sub-packages matching NewTools-* and Spec2-*"

PharoCLI subPackagesOfString: #('NewTools')
"Returns: Formatted string output"
```

### Get classes in a package

```smalltalk
PharoCLI classesInPackage: 'Kernel'
"Returns: Set of all classes in the Kernel package"

PharoCLI classesInPackages: #('Kernel' 'Collections-Abstract')
"Returns: Set combining classes from multiple packages"

PharoCLI classesInPackagesString: #('Kernel')
"Returns: Formatted string output (one class per line)"
```

### Find classes extended by a package

```smalltalk
PharoCLI extendedClassesInPackage: 'Ring-Core'
"Returns: Set of classes that Ring-Core adds extension methods to"

PharoCLI extendedClassesInPackageString: 'Ring-Core'
"Returns: Formatted string output"
```

### Get all extension methods in a package

```smalltalk
PharoCLI extensionMethodsInPackage: 'Ring-Core'
"Returns: Set of all methods Ring-Core adds to other classes"

PharoCLI extensionMethodsInPackageString: 'Ring-Core'
"Returns: Formatted string (ClassName>>methodName per line)"
```

## Querying Protocols

### Get protocols in a class

```smalltalk
PharoCLI protocolsInClass: Object
"Returns: Set of all protocol names in Object"

PharoCLI protocolsInClasses: {Object. String}
"Returns: Set combining protocols from multiple classes"

PharoCLI protocolsInClassesString: {Object}
"Returns: Formatted string output"
```

### Filter extension vs. local protocols

Extension protocols start with `*` (e.g., `#'*Ring-Core'`).

```smalltalk
"Get only local protocols (exclude extensions)"
PharoCLI protocolsInClass: Object withoutExtensions: true

"Get only extension protocols"
PharoCLI protocolsInClass: Object extensionsOnly: true
```

## Querying Methods

### Get methods from classes

```smalltalk
PharoCLI methodsInClasses: {Object}
"Returns: Set of all methods in Object"

"Filter by specific protocols"
PharoCLI methodsInClasses: {Object} protocols: #(accessing)
"Returns: Methods in the 'accessing' protocol only"

"Empty protocols array means all methods"
PharoCLI methodsInClasses: {Object} protocols: #()

PharoCLI methodsInClassesString: {Object} protocols: #(accessing)
"Returns: Formatted string output"
```

## Method Relationships

### Find implementors of a selector

```smalltalk
PharoCLI implementorsOf: #yourself
"Returns: Set of all methods implementing #yourself"

"Restrict to specific package(s)"
PharoCLI implementorsOf: #yourself inPackage: 'Kernel'
PharoCLI implementorsOf: #yourself inPackages: #('Kernel' 'Collections')

PharoCLI implementorsOfString: #yourself
"Returns: Formatted string (ClassName>>methodName per line)"
```

### Find senders of a selector

```smalltalk
PharoCLI sendersOf: #yourself
"Returns: Set of all methods calling #yourself"

"Restrict to specific package(s)"
PharoCLI sendersOf: #class inPackage: 'Kernel'
PharoCLI sendersOf: #class inPackages: #('Kernel')
```

## Source Code and Information

### Get source code of methods

```smalltalk
| methods |
methods := (PharoCLI implementorsOf: #yourself) asOrderedCollection first: 3.
PharoCLI sourceOfMethods: methods
"Returns: Formatted source with headers for each method"

PharoCLI sourceOfMethod: (Object >> #yourself)
"Returns: Source of a single method with separator"
```

### Get detailed method information

```smalltalk
PharoCLI methodInfoString: (Object >> #yourself)
"Returns: Multi-line info including:
  - Method selector and class
  - Protocol
  - Lines of code
  - Source code length
  - Number of senders
  - Number of implementors
  - Overridden/overriding status"

| methods |
methods := (Smalltalk at: #PharoCLI) class methods select: [:m | m selector asString beginsWith: 'top'].
PharoCLI methodsInfoString: methods
"Returns: Combined info for multiple methods"
```

## Creating Classes and Packages

### Create a package

```smalltalk
PharoCLI createPackageNamed: 'My-Package'
"Returns: the created Package"
```

### Create a class in a package

```smalltalk
PharoCLI createClassNamed: 'MyClass' inPackage: 'My-Package'
"Returns: the created class"
```

## Working with Results

Most query methods return either:
- **Sets** - for flexible filtering and further manipulation
- **Strings** - for formatted display with readable output

### Filter results further

```smalltalk
| methods |
methods := PharoCLI implementorsOf: #yourself.
"Filter to only those in a specific package"
methods select: [:m | m methodClass package name = #Kernel]

"Count them"
methods size

"Sort them"
methods sorted: [:a :b | a methodClass name < b methodClass name]
```

### Example: Find all public methods in a package

```smalltalk
| classes methods |
classes := PharoCLI classesInPackage: 'Kernel'.
methods := PharoCLI methodsInClasses: classes protocols: #(accessing printing).
"Now you have all accessing and printing methods in Kernel"
```

### Example: Find which packages extend a core class

```smalltalk
| extensionProtos |
extensionProtos := PharoCLI protocolsInClass: Object extensionsOnly: true.
extensionProtos
  "Returns something like: #('*Ring-Core' '*Spec2-Adapters-Morphic' '*Morphic-Core')"
```

## Tips

- Use the `String` variants (`*String` methods) for readable terminal output
- Use the Set-returning methods for further programmatic filtering
- Empty collections as filters typically mean "no filter" (e.g., empty protocols = all protocols)
- All methods work with packages specified as symbols or strings (automatic conversion)
- Extension methods are marked with `*` prefix followed by package name
- "Overridden" means the method is redefined in a subclass
- "Overriding" means the method redefines a superclass method
