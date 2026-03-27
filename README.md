# PharoCLI

Command-line interface for Pharo image inspection and code analysis.

## Installation

```smalltalk
Metacello new
    githubUser: 'rrobbes'
    project: 'PharoCLI'
    commitish: 'main'
    path: 'src'
    baseline: 'PharoCLI'
    load
```

## Features

- Query classes, methods, and packages via command-line
- Inspect method implementations and sources
- Search for references and senders
- Analyze package structure and dependencies
- Access debugging information

## Documentation

See `PHAROCLI-DOCUMENTATION.md` for full user guide and examples.

See `PHAROCLI-GUIDE.md` for class reference documentation.

See `PHAROCLI-FUTURE-FEATURES.md` for planned features.
