# Pharo Image Interaction Snippets

Working code snippets for direct image manipulation and management via port 4044.

## Class and Package Creation

### Creating a class with a proper package

The key is to use `pkg addClass:` to move the class into the package after creation, since specifying the package in the class builder does not guarantee correct placement.

```smalltalk
| pkg cls |
pkg := SystemOrganization ensurePackage: 'My-Package-Name'.
cls := (Object << #MyClassName
	superclass: Object;
	slots: {};
	package: 'My-Package-Name') build.
Smalltalk at: #MyClassName put: cls.
pkg addClass: cls.
cls package name
```

Returns: `#'My-Package-Name'`

### Removing a class

```smalltalk
Smalltalk removeClassNamed: #MyClassName
```

### Checking a class's package

```smalltalk
(Smalltalk at: #MyClassName) package name
```

### Listing all classes in a package

```smalltalk
(SystemOrganization packageNamed: 'My-Package-Name') classes
```

## Package Management

### Ensuring a package exists

```smalltalk
SystemOrganization ensurePackage: 'My-Package-Name'
```

### Getting a package by name

```smalltalk
SystemOrganization packageNamed: 'My-Package-Name'
```

### Listing all package names

```smalltalk
SystemOrganization packageNames
```

## Dynamic Method Compilation

### Compiling an instance method

```smalltalk
(Smalltalk at: #MyClassName) compile: 'myMethod
	^ 42' classified: 'accessing'
```

### Compiling a class-side method

```smalltalk
(Smalltalk at: #MyClassName) class compile: 'myClassMethod
	^ 100' classified: 'class accessing'
```

## Navigation and Inspection

### Opening the class browser on a class

```smalltalk
Smalltalk tools browser openOnClass: (Smalltalk at: #MyClassName)
```

### Opening the class browser on a specific method

```smalltalk
Smalltalk tools browser openOnClass: (Smalltalk at: #MyClassName) selector: #myMethod
```

### Verifying class exists

```smalltalk
(Smalltalk at: #MyClassName ifAbsent: [nil]) isNotNil
```

## Notes

- Always ensure the package exists with `SystemOrganization ensurePackage:` before creating the class
- Use `pkg addClass: cls` after class creation to properly register it in the package
- The `package:` parameter in the class builder does not guarantee package placement; use `addClass:` instead
- All code is sent via `echo "code" | nc localhost 4044`
