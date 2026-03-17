# Pharo/Smalltalk Code Snippets

Working code snippets from interactions with the Pharo image via port 4044.

## Basic Evaluation & Arithmetic

```smalltalk
6 + 72
```
Returns: `78`

## Exploring Classes & Methods

### Getting all methods of a class
```smalltalk
ReImageRuleBaner selectors
```

### Getting class-side methods
```smalltalk
ReImageRuleBaner class selectors
```

### Finding methods that contain a substring
```smalltalk
(SindarinDebugger methods select: [:m | m sourceCode includesSubstring: 'pop' caseSensitive: false]) collect: #selector
```

### Finding methods by selector name
```smalltalk
#(topStack messageReceiver assignmentValue stack currentContextStackSize) collect: [:sel | 
  (SindarinDebugger >> sel) sourceCode first: 80
]
```

## Exploring Class Hierarchies

### Getting all subclasses
```smalltalk
Exception allSubclasses
```

### Getting direct subclasses
```smalltalk
SindarinCommand allSubclasses
```

## Querying Object State

### Checking if source code contains text
```smalltalk
(SindarinDebugger >> #assignmentValue) sourceCode includesSubstring: 'top'
```

### Getting method selector names
```smalltalk
#(skipMessageNodeWith: skipAssignmentNodeCompletely cleanStack skipMessageNode skipJump skipAssignmentNodeWith:) 
  collect: [:sel | ((SindarinDebugger >> sel) methodClass organization categoryOfElement: sel) ]
```

### Finding objects by identity hash
```smalltalk
| debugger |
debugger := StDebugger allInstances detect: [:d | d identityHash = 454036992].
debugger
```

### Getting all instances of a class with their hashes
```smalltalk
StDebugger allInstances collect: [:d | d identityHash]
```

## Debugger Control

### Stepping into execution
```smalltalk
| debugger |
debugger := StDebugger allInstances detect: [:d | d identityHash = 454036992].
debugger stepInto
```

### Stepping until a condition
```smalltalk
| debugger |
debugger := StDebugger allInstances detect: [:d | d identityHash = 454036992].
debugger sindarinDebugger stepUntil: [
  (debugger sindarinDebugger isMessageSend) and: [
    debugger sindarinDebugger messageSelector = #add: and: [
      debugger sindarinDebugger messageArguments first = 8
    ]
  ]
]
```

## Dynamic Class Creation

### Creating a new class
```smalltalk
| cls |
cls := (Object << #SindarinAddEightCommand
	superclass: SindarinCommand;
	slots: {};
	package: 'Sindarin-Custom-Commands') build.
Smalltalk at: #SindarinAddEightCommand put: cls.
cls
```

## Dynamic Method Compilation

### Compiling a class-side method
```smalltalk
(Smalltalk at: #SindarinAddEightCommand) class compile: 'defaultIconName
	^ #add' classified: 'accessing'
```

### Compiling a method with pragma
```smalltalk
(Smalltalk at: #SindarinAddEightCommand) class compile: 'defaultName
	<codeExtensionDebugCommand:1>
	^ ''Step Until add: 8''' classified: 'accessing'
```

### Compiling an instance method
```smalltalk
(Smalltalk at: #SindarinAddEightCommand) compile: 'execute
	| sindarin |
	sindarin := self context sindarinDebugger.
	self context debuggerClientModel preventUpdatesDuring: [
		sindarin stepUntil: [
			(sindarin isMessageSend) and: [
				sindarin messageSelector = #add: and: [
					sindarin messageArguments first = 8
				]
			]
		]
	]' classified: 'executing'
```

## Querying Debugger API

### Finding methods in a class that match a pattern
```smalltalk
SindarinDebugger selectors includes: #assignmentValue
```

### Getting class selectors matching a pattern
```smalltalk
SindarinDebugger class selectors select: [:sel | sel asString includesSubstring: 'step' caseSensitive: false]
```

### Accessing debugger internals
```smalltalk
StDebugger allInstances first debuggerClientModel class selectors select: [:sel | sel asString includesSubstring: 'prevent' caseSensitive: false]
```

## Roassal Visualization

### Creating a visualization with colored boxes and flow layout
```smalltalk
| canvas groups colors allBoxes |
colors := { Color blue. Color green. Color orange. Color purple }.
groups := {
	('Step Commands' -> #(
		'StepBytecode'
		'Step'
		'StepOver'
		'StepToMethodEntry'
		'StepToNextExecution'
		'StepToReturn'
	)).
	('Skip Commands' -> #(
		'Skip'
		'SkipAllToSelection'
		'SkipUpTo'
	)).
	('Script Commands' -> #(
		'CreateFromScript'
		'LoadScript'
		'RunScript'
		'SaveScript'
		'RemoveCommand'
	)).
	('Other' -> #(
		'JumpToCaret'
		'Refresh'
	))
}.

canvas := RSCanvas new.
allBoxes := OrderedCollection new.

groups doWithIndex: [:group :groupIndex | 
	| groupName cmdNames |
	groupName := group key.
	cmdNames := group value.
	cmdNames do: [:cmdName | 
		| box label |
		box := RSBox new
			width: 200;
			height: 35;
			color: (colors at: groupIndex);
			model: cmdName.
		label := RSLabel new
			text: cmdName;
			fontSize: 10.
		canvas add: box.
		canvas add: label.
		allBoxes add: box.
		label position: box position.
	].
].

RSFlowLayout new gapSize: 60; on: allBoxes.

canvas @ RSCanvasController.
canvas open.
```

## Spec UI Builders - Layouts and Presenters

### Multi-selection list with paned layout
```smalltalk
| list textPanel |
list := SpListPresenter new
	items: String methods;
	display: [ :m | m selector ];
	beMultipleSelection;
	yourself.

textPanel := SpTextPresenter new.

list whenSelectionChangedDo: [ :selection |
	textPanel text: (selection selectedItems 
		collect: #sourceCode) joinedBy: String cr ].

SpPresenter new
	layout: (SpPanedLayout newLeftToRight
		positionOfSlider: 0.3;
		add: list;
		add: textPanel;
		yourself);
	open
```

### Dynamically rebuilding layouts
```smalltalk
| presenter panels layout |
presenter := SpPresenter new.
panels := OrderedCollection new.

layout := SpBoxLayout newTopToBottom.
presenter layout: layout.

"Add a panel dynamically"
panels add: (presenter newText text: 'Panel 1').

"Rebuild layout with new panels"
presenter layout: (SpBoxLayout newTopToBottom
	yourself).
panels do: [ :p | presenter layout add: p ].
presenter open
```

### Finding implementors of a message
```smalltalk
SystemNavigation new allImplementorsOf: #beMultipleSelection
```

### Closing all open windows
```smalltalk
(Smalltalk at: #SpWindowPresenter) allInstances do: [ :w | w window close ]
```

## Opening Browser

### Opening browser on a class
```smalltalk
Smalltalk tools browser openOnClass: SindarinCommand
```

### Opening browser on a specific method
```smalltalk
Smalltalk tools browser openOnClass: SindarinDebugger selector: #assignmentValue
```

## Notes

- All snippets use the network protocol (nc localhost 4044) for evaluation
- Multiline code should be properly formatted with correct indentation
- String literals in Smalltalk use single quotes; to include quotes use doubled single quotes ('')
- Blocks are delimited with square brackets: `[:var | code]`
- Multiple statements are separated by periods (.)
- Multi-selection in lists requires holding Shift while clicking
- Paned layouts use `positionOfSlider:` with floats (0.0-1.0) to set initial split position
