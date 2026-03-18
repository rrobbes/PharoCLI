sourceOfMethod: aMethod
	^ String streamContents: [:s |
		s << aMethod methodClass name; << '>>'; << aMethod selector; << String lf.
		s << '========================================' << String lf.
		s << aMethod sourceCode; << String lf; << String lf
	]classesInPackages: packageNames
	| result |
	result := Set new.
	packageNames do: [:pkgName |
		(self classesInPackage: pkgName) do: [:cls | result add: cls]
	].
	^ resultsendersOfString: aSelector inPackage: packageName
	| senders |
	senders := (self sendersOf: aSelector inPackage: packageName) sorted: [:a :b | 
		(a methodClass name, '>>' , a selector asString) < (b methodClass name, '>>' , b selector asString)
	].
	^ String streamContents: [:s | senders do: [:m | 
		s << m methodClass name; << '>>' ; << m selector; << String lf
	]]topLevelPackages
	^ (SystemOrganization packageNames 
		collect: [:name | 
			| parts |
			parts := name asString splitOn: '-'.
			parts first asSymbol
		]) asSet
		reject: [:name | 
			(name asString beginsWith: 'BaselineOf') or: [
				name asString = '_UnpackagedPackage'
			]]sourceOfMethodFormatted: aMethod
	| source |
	source := aMethod sourceCode.
	^ String streamContents: [:s |
		s << aMethod methodClass name; << '>>' ; << aMethod selector; << String lf.
		s << (String withAll: (Array new: 40 withAll: $=)); << String lf.
		(source lines) do: [:line | s << line; << String lf]
	]protocolsInClasses: classes
	| result |
	result := Set new.
	classes do: [:cls |
		(self protocolsInClass: cls) do: [:proto | result add: proto]
	].
	^ resultsourceOfMethodsFormatted: methods
	^ String streamContents: [:s |
		methods do: [:m |
			s << m methodClass name; << '>>' ; << m selector; << String lf.
			s << (String withAll: (Array new: 40 withAll: $=)); << String lf.
			(m sourceCode lines) do: [:line | s << line; << String lf].
			s << String lf
		] separatedBy: [s << String lf]
	]classFromName: className
	"Convert a class name string to a class object.
	 Handles 'ClassName class' syntax for metaclasses."
	| name actualClass |
	name := className asString.
	(name endsWith: ' class') ifTrue: [
		actualClass := Smalltalk at: (name allButLast: 6) asSymbol.
		^ actualClass class
	] ifFalse: [
		^ Smalltalk at: name asSymbol
	]createPackageNamed: packageName
	^ SystemOrganization ensurePackage: packageNameprotocolsInClassesString: classes withoutExtensions: aBoolean
	| allProtocols |
	allProtocols := Set new.
	classes do: [:cls | allProtocols addAll: (self protocolsInClass: cls withoutExtensions: aBoolean)].
	^ String streamContents: [:s | 
		(allProtocols sorted: [:a :b | a asString < b asString]) do: [:p | 
			s << p asString; << String lf
		]
	]extendedClassesInPackage: packageName
	| result packagePrefix allClasses |
	result := Set new.
	packagePrefix := '*', packageName asString.
	allClasses := Smalltalk allClasses.
	allClasses do: [:cls |
		| extensionProtocols |
		extensionProtocols := (PharoCLI protocolsInClass: cls extensionsOnly: true) 
			select: [:p | p asString beginsWith: packagePrefix].
		extensionProtocols isNotEmpty ifTrue: [result add: cls]
	].
	^ resultextendedClassesInPackageString: packageName
	| classes |
	classes := (self extendedClassesInPackage: packageName) sorted: [:a :b | a name < b name].
	^ String streamContents: [:s | classes do: [:cls | s << cls name; << String lf]]methodsInClassesString: classes protocols: protocols
	| methods |
	methods := (self methodsInClasses: classes protocols: protocols) sorted: [:a :b | a selector < b selector].
	^ String streamContents: [:s | methods do: [:method | s << method selector; << String lf]]recentChangesInPackage: packageName limit: limit
	| log results packageSym |
	packageSym := packageName asSymbol.
	log := EpMonitor current log.
	results := OrderedCollection new.
	log entriesDo: [:entry |
		(entry content isEpMethodChange) ifTrue: [
			(entry content methodAffected methodClass package name = packageSym) ifTrue: [
				results add: entry content methodAffected.
				(results size >= limit) ifTrue: [^ results]
			]
		]
	].
	^ results
commentOfString: aClass
	"Return formatted comment preserving paragraph breaks"
	| comment |
	comment := aClass comment.
	
	^ String streamContents: [:stream |
		stream nextPutAll: aClass name; lf.
		stream nextPutAll: (String new: aClass name size withAll: $=); lf; lf.
		"Preserve paragraph structure by converting CR (sent by server) to LF"
		(comment asString replaceAll: Character cr asString with: Character lf asString)
			do: [:char | stream nextPut: char]
	]
variablesOfString: aClass
	"Return formatted variables output (space-separated, grep-friendly)"
	| lines |
	lines := OrderedCollection new.
	
	"Add instance variables"
	(aClass instVarNames) do: [:name |
		lines add: (String streamContents: [:stream |
			stream nextPutAll: aClass name; space; nextPutAll: 'instance'; space; nextPutAll: name
		])
	].
	
	"Add class variables"
	(aClass classVarNames) do: [:name |
		lines add: (String streamContents: [:stream |
			stream nextPutAll: aClass name; space; nextPutAll: 'class'; space; nextPutAll: name asString
		])
	].
	
	"Add slots"
	(aClass slots) do: [:slot |
		lines add: (String streamContents: [:stream |
			stream nextPutAll: aClass name; space; nextPutAll: 'slot'; space; nextPutAll: slot name
		])
	].
	
	^ (lines size = 0)
		ifTrue: [aClass name, ' (no variables)']
		ifFalse: [lines joinUsing: Character lf asString]
searchFor: keyword inPackages: packageNames inClasses: classNameSymbols searchFields: fieldArray caseSensitive: isCaseSensitive
	| targetClasses matchingMethods classSet classSymbols |
	
	"Determine target classes"
	classSet := classNameSymbols isNil
		ifTrue: [Smalltalk allClasses]
		ifFalse: [
			| classSyms |
			classSyms := classNameSymbols collect: [:sym | sym asSymbol].
			classSyms collect: [:sym | Smalltalk at: sym ifAbsent: [nil]] thenSelect: [:cls | cls notNil]
		].
	
	"Filter by packages if specified"
	classSet := packageNames isNil
		ifTrue: [classSet]
		ifFalse: [
			| pkgSymbols |
			pkgSymbols := (packageNames collect: #asSymbol) asSet.
			classSet select: [:cls | pkgSymbols includes: cls package name]
		].
	
	"Search for matches"
	matchingMethods := Set new.
	classSet do: [:cls |
		(self allMethodsInClass: cls) do: [:method |
			(self matchesMethod: method keyword: keyword fields: fieldArray caseSensitive: isCaseSensitive)
				ifTrue: [matchingMethods add: method]
		]
	].
	
	^ matchingMethodscommentOf: aClass
	"Return the comment string of a class"
	^ aClass comment
implementorsOfString: aSelector
	| implementors |
	implementors := (self implementorsOf: aSelector) sorted: [:a :b | 
		(a methodClass name, '>>', a selector asString) < (b methodClass name, '>>', b selector asString)
	].
	^ String streamContents: [:s | implementors do: [:m | 
		s << m methodClass name; << '>>'; << m selector; << String lf
	]]implementorsOf: aSelector inPackages: packageNames
	| allImplementors packageNameSet |
	packageNameSet := (packageNames collect: #asSymbol) asSet.
	allImplementors := self implementorsOf: aSelector.
	^ allImplementors select: [:m | packageNameSet includes: m methodClass package name]timeAllTests
	"Run all tests and report timing for each"
	| testClass tests |
	testClass := PharoCLITest.
	tests := testClass suite tests.
	
	^ String streamContents: [:s |
		tests do: [:test |
			| result time |
			time := Time millisecondsToRun: [result := test run].
			s << test selector asString; << ': '; << time asString; << ' ms'; lf
		]
	]protocolsInClass: aClass extensionsOnly: aBoolean
	| protocols |
	protocols := self protocolsInClass: aClass.
	^ aBoolean
		ifTrue: [protocols select: [:p | p asString beginsWith: '*']]
		ifFalse: [protocols]subPackagesOf: topLevelNames
	| allPkgNames result |
	allPkgNames := SystemOrganization packageNames.
	result := Set new.
	topLevelNames do: [:topLevel |
		| prefix |
		prefix := topLevel asString, '-'.
		allPkgNames do: [:pkgName |
			(pkgName asString beginsWith: prefix) ifTrue: [
				result add: pkgName
			]
		]
	].
	^ resultsearchForString: keyword inPackages: packageNames inClasses: classNames searchFields: fieldArray caseSensitive: isCaseSensitive
	| results |
	results := (self searchFor: keyword inPackages: packageNames inClasses: classNames searchFields: fieldArray caseSensitive: isCaseSensitive).
	results := results asOrderedCollection sort: [:a :b | 
		(a methodClass name, a selector asString) < (b methodClass name, b selector asString)
	].
	^ String streamContents: [:s | results do: [:m | 
		s << m methodClass name.
		s nextPutAll: '>>'.
		s << m selector; << String lf
	]]
sourceOfMethods: methods
	^ String streamContents: [:s |
		methods do: [:method |
			s << (self sourceOfMethod: method)
		]
	]savePackagesToFile: filePathString
	"Save both PharoCLI packages to a file"
	| pkg1 pkg2 file stream |
	pkg1 := PackageOrganizer default packageNamed: 'PharoCLI'.
	pkg2 := PackageOrganizer default packageNamed: 'PharoCLI-Tests'.
	file := filePathString asFileReference.
	
	stream := file writeStream.
	[
		(pkg1 methods) do: [:m | 
			stream nextPutAll: m sourceCode; cr; cr.
		].
		(pkg2 methods) do: [:m |
			stream nextPutAll: m sourceCode; cr; cr.
		]
	] ensure: [stream close].
	
	^ 'Saved ', (pkg1 methods size + pkg2 methods size) asString, ' methods to ', filePathString
methodInfoString: aMethod
	| senders implementors |
	senders := self sendersOf: aMethod selector.
	implementors := self implementorsOf: aMethod selector.
	^ String streamContents: [:s |
		s << aMethod methodClass name; << '>>'; << aMethod selector asString; << ' | '.
		s << 'protocol:' << aMethod protocol name asString; << ' '.
		s << 'loc:' << aMethod linesOfCode asString; << ' '.
		s << 'len:' << aMethod sourceCode size asString; << ' '.
		s << 'senders:' << senders size asString; << ' '.
		s << 'implementors:' << implementors size asString; << ' '.
		s << 'overridden:' << aMethod isOverridden asString; << ' '.
		s << 'overriding:' << (aMethod overriddenMethods size > 0) asString
	]implementorsOf: aSelector
	^ (SystemNavigation new allImplementorsOf: aSelector) asSetclassesInPackagesString: packageNames
	| classes |
	classes := (self classesInPackages: packageNames) sorted: [:a :b | a name < b name].
	^ String streamContents: [:s | classes do: [:cls | s << cls name; << String lf]]referencesToInstanceVariableString: varNameSymbol inClass: aClassName
	"Return formatted references to an instance variable (grep-friendly)"
	| methods sorted |
	methods := self referencesToInstanceVariable: varNameSymbol inClass: aClassName.
	
	(methods isEmpty) ifTrue: [^ aClassName, ':' , varNameSymbol asString, ' (no references)'].
	
	sorted := methods sorted: [:a :b | a methodClass name < b methodClass name].
	^ String streamContents: [:stream |
		sorted do: [:method | 
			stream nextPutAll: aClassName asString; space; 
					nextPutAll: varNameSymbol asString; space;
					nextPutAll: method methodClass name; nextPutAll: '>>' ; 
					nextPutAll: method selector asString; lf
		]
	]
topLevelPackagesString
	| topLevel |
	topLevel := self topLevelPackages sorted.
	^ String streamContents: [:s | topLevel do: [:p | s << p asString; << String lf]]allMethodsInClass: aClass
	"Return all methods in a class, both instance and class side"
	| result |
	result := Set new.
	result addAll: aClass methods.
	result addAll: aClass class methods.
	^ resultmethodsInfoString: methods
	^ String streamContents: [:s |
		methods do: [:method |
			s << (self methodInfoString: method); << String lf
		]
	]sendersOfString: aSelector
	| senders |
	senders := (self sendersOf: aSelector) sorted: [:a :b | 
		(a methodClass name, '>>' , a selector asString) < (b methodClass name, '>>' , b selector asString)
	].
	^ String streamContents: [:s | senders do: [:m | 
		s << m methodClass name; << '>>' ; << m selector; << String lf
	]]lastModifiedOf: aCompiledMethod
	| log lastEntry |
	log := EpMonitor current log.
	lastEntry := nil.
	log entriesDo: [:entry |
		(entry content isEpMethodChange) ifTrue: [
			(entry content methodAffected == aCompiledMethod) ifTrue: [
				lastEntry := entry
			]
		]
	].
	lastEntry ifNil: [^ 'Never modified in this session' asString].
	^ (EpMonitor current time) asString
referencesOf: className
	"Find all methods that reference a given class by name"
	| classAssociation |
	classAssociation := Smalltalk globals associationAt: className asSymbol ifAbsent: [nil].
	classAssociation isNil ifTrue: [^ Set new].
	^ SystemNavigation new allReferencesTo: classAssociation
protocolsInClass: aClass withoutExtensions: aBoolean
	| protocols |
	protocols := self protocolsInClass: aClass.
	^ aBoolean
		ifTrue: [protocols reject: [:p | p asString beginsWith: '*']]
		ifFalse: [protocols]referencesOf: className inPackage: packageName
	| refs packageSym |
	packageSym := packageName asSymbol.
	refs := self referencesOf: className.
	^ refs select: [:m | m methodClass package name = packageSym]
extensionMethodsInPackage: packageName
	| extendedClasses result packagePrefix |
	extendedClasses := self extendedClassesInPackage: packageName.
	result := Set new.
	packagePrefix := '*', packageName asString.
	extendedClasses do: [:cls |
		| ringProtos |
		ringProtos := (self protocolsInClass: cls extensionsOnly: true)
			select: [:p | p asString beginsWith: packagePrefix].
		(self methodsInClasses: {cls} protocols: ringProtos) do: [:m | result add: m]
	].
	^ resultreferencesToInstanceVariable: varNameSymbol inClass: aClassName
	"Return all methods that access an instance variable"
	| class |
	class := Smalltalk at: aClassName.
	^ class slotNamed: varNameSymbol ifFound: [:s | s usingMethods] ifNone: [Set new]
classesInPackage: packageName
	^ (SystemOrganization packageNamed: packageName) classessendersOfString: aSelector inPackages: packageNames
	| senders |
	senders := (self sendersOf: aSelector inPackages: packageNames) sorted: [:a :b | 
		(a methodClass name, '>>' , a selector asString) < (b methodClass name, '>>' , b selector asString)
	].
	^ String streamContents: [:s | senders do: [:m | 
		s << m methodClass name; << '>>' ; << m selector; << String lf
	]]createClassNamed: className inPackage: packageName
	| pkg cls |
	pkg := SystemOrganization ensurePackage: packageName.
	cls := (Object << className asSymbol
		superclass: Object;
		slots: {};
		package: packageName) build.
	Smalltalk at: className asSymbol put: cls.
	pkg addClass: cls.
	^ clshierarchyOf: aClass
	"Return a Set containing the superclass and direct subclasses of aClass"
	| hierarchy |
	hierarchy := Set new.
	"Add superclass (or nil if none)"
	hierarchy add: aClass superclass.
	"Add all direct subclasses"
	hierarchy addAll: aClass subclasses.
	^ hierarchy
hierarchyOfString: aClass
	"Return formatted string showing class hierarchy (superclass and subclasses)"
	| superClass subClassesList |
	superClass := aClass superclass.
	subClassesList := aClass subclasses asOrderedCollection sort: [:a :b | a name < b name].
	
	^ String streamContents: [:stream |
		stream nextPutAll: aClass name; lf; nextPutAll: (String new: aClass name size withAll: $=); lf; lf.
		
		stream nextPutAll: 'Superclass: '.
		(superClass isNil)
			ifTrue: [stream nextPutAll: '(none)']
			ifFalse: [stream nextPutAll: superClass name].
		stream lf; lf.
		
		stream nextPutAll: 'Subclasses: '.
		(subClassesList isEmpty)
			ifTrue: [stream nextPutAll: '(none)']
			ifFalse: [
				subClassesList do: [:each | stream nextPutAll: each name] separatedBy: [stream lf; nextPutAll: '  ']
			].
		stream lf
	]
referencesOfString: className inPackages: packageNames
	| refs |
	refs := (self referencesOf: className inPackages: packageNames) sorted: [:a :b | 
		(a methodClass name, a selector asString) < (b methodClass name, b selector asString)
	].
	^ String streamContents: [:s | refs do: [:m | 
		s << m methodClass name.
		s nextPutAll: '>>'.
		s << m selector; << String lf
	]]
protocolsInClassesString: classes extensionsOnly: aBoolean
	| allProtocols |
	allProtocols := Set new.
	classes do: [:cls | allProtocols addAll: (self protocolsInClass: cls extensionsOnly: aBoolean)].
	^ String streamContents: [:s | 
		(allProtocols sorted: [:a :b | a asString < b asString]) do: [:p | 
			s << p asString; << String lf
		]
	]protocolsInClassesString: classes
	| protocols |
	protocols := (self protocolsInClasses: classes) sorted.
	^ String streamContents: [:s | protocols do: [:proto | s << proto asString; << String lf]]extensionMethodsInPackageString: packageName
	| methods |
	methods := (self extensionMethodsInPackage: packageName) sorted: [:a :b | 
		(a methodClass name, '>>', a selector asString) < (b methodClass name, '>>', b selector asString)
	].
	^ String streamContents: [:s | methods do: [:m | 
		s << m methodClass name; << '>>'; << m selector; << String lf
	]]subPackagesOfString: topLevelNames
	| subPkgs |
	subPkgs := (self subPackagesOf: topLevelNames) sorted.
	^ String streamContents: [:s | subPkgs do: [:p | s << p asString; << String lf]]matchesMethod: method keyword: keyword fields: fieldArray caseSensitive: isCaseSensitive
	| searchKeyword methodSelector methodSource classComment |
	
	searchKeyword := isCaseSensitive
		ifTrue: [keyword]
		ifFalse: [keyword asLowercase].
	
	"Search method name"
	((fieldArray includes: #names) or: [fieldArray includes: #name]) ifTrue: [
		methodSelector := isCaseSensitive
			ifTrue: [method selector asString]
			ifFalse: [method selector asString asLowercase].
		(methodSelector includesSubstring: searchKeyword) ifTrue: [^ true]
	].
	
	"Search method source code"
	((fieldArray includes: #source) or: [fieldArray includes: #sources]) ifTrue: [
		methodSource := isCaseSensitive
			ifTrue: [method sourceCode]
			ifFalse: [method sourceCode asLowercase].
		(methodSource includesSubstring: searchKeyword) ifTrue: [^ true]
	].
	
	"Search class comment"
	((fieldArray includes: #comment) or: [fieldArray includes: #comments]) ifTrue: [
		classComment := isCaseSensitive
			ifTrue: [method methodClass comment]
			ifFalse: [method methodClass comment asLowercase].
		(classComment includesSubstring: searchKeyword) ifTrue: [^ true]
	].
	
	^ false
referencesOfString: className inPackage: packageName
	| refs |
	refs := (self referencesOf: className inPackage: packageName) sorted: [:a :b | 
		(a methodClass name, a selector asString) < (b methodClass name, b selector asString)
	].
	^ String streamContents: [:s | refs do: [:m | 
		s << m methodClass name.
		s nextPutAll: '>>'.
		s << m selector; << String lf
	]]
protocolsInClass: aClass
	"Return all protocols in a class (both instance and class side)"
	^ ((self allMethodsInClass: aClass) collect: #protocol) asSet 
		collect: #name 
		thenReject: [:p | p isNil]referencesOf: className inPackages: packageNames
	| allRefs packageNameSet |
	packageNameSet := (packageNames collect: #asSymbol) asSet.
	allRefs := self referencesOf: className.
	^ allRefs select: [:m | packageNameSet includes: m methodClass package name]
implementorsOf: aSelector inPackage: packageName
	^ self implementorsOf: aSelector inPackages: {packageName}recentChangesInPackageString: packageName limit: limit
	| methods |
	methods := self recentChangesInPackage: packageName limit: limit.
	^ String streamContents: [:s |
		methods do: [:m |
			s << m methodClass name; << '>>' ; << m selector; << String lf
		]
	]
referencesOfString: className
	| refs |
	refs := (self referencesOf: className) sorted: [:a :b | 
		(a methodClass name, a selector asString) < (b methodClass name, b selector asString)
	].
	^ String streamContents: [:s | refs do: [:m | 
		s << m methodClass name.
		s nextPutAll: '>>'.
		s << m selector; << String lf
	]]
methodsInClasses: classes
	^ self methodsInClasses: classes protocols: #()methodsInClasses: classes protocols: protocols
	| result protocolNames |
	result := Set new.
	protocolNames := protocols asSet.
	classes do: [:cls |
		(self allMethodsInClass: cls) do: [:method |
			| match |
			match := protocolNames isEmpty 
				ifTrue: [true]
				ifFalse: [protocolNames includes: method protocol name].
			match ifTrue: [result add: method]
		]
	].
	^ resultsendersOf: aSelector inPackage: packageName
	^ self sendersOf: aSelector inPackages: {packageName}variablesOf: aClass
	"Return a Set of all variables (instance, class, and slots)"
	| variables |
	variables := Set new.
	"Add instance variables"
	variables addAll: (aClass instVarNames collect: [:name | {aClass name. #instance. name} ]).
	"Add class variables"
	variables addAll: (aClass classVarNames collect: [:name | {aClass name. #class. name} ]).
	"Add slots"
	variables addAll: (aClass slots collect: [:slot | {aClass name. #slot. slot name} ]).
	^ variables
sendersOf: aSelector inPackages: packageNames
	| allSenders packageNameSet |
	packageNameSet := (packageNames collect: #asSymbol) asSet.
	allSenders := self sendersOf: aSelector.
	^ allSenders select: [:m | packageNameSet includes: m methodClass package name]sendersOf: aSelector
	^ (SystemNavigation new allSendersOf: aSelector) asSettestHierarchyOfClass
	| hierarchy |
	hierarchy := PharoCLI hierarchyOf: String.
	self assert: hierarchy isNotEmpty.
	"Should contain nil (superclass of root) or an actual superclass"
	self assert: (hierarchy includes: ArrayedCollection).
	"Should include subclasses"
	self assert: (hierarchy anySatisfy: [:c | c isClass or: [c isNil]])
testMethodInfoStringOneLine
	| method result |
	method := Object >> #yourself.
	result := PharoCLI methodInfoString: method.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'yourself').
	self assert: (result includesSubstring: 'senders')testProtocolsInClassesStringExtensionsOnly
	| result |
	result := PharoCLI protocolsInClassesString: {Object} extensionsOnly: true.
	self assert: result isString.
	self assert: result isNotEmptytestSourceOfMethodFormatted
	| result |
	result := PharoCLI sourceOfMethodFormatted: (Object >> #yourself).
	self assert: result isString.
	self assert: (result includesSubstring: 'Object>>yourself').
	self assert: (result includesSubstring: '========').
	self assert: (result includesSubstring: 'Answer self')testMethodsInClassesWithProtocols
	| methods |
	methods := PharoCLI methodsInClasses: {Object} protocols: #(accessing).
	self assert: methods isNotEmpty.
	self assert: (methods allSatisfy: [:m | m protocol name = #accessing])testCommentOfClass
	| comment |
	comment := PharoCLI commentOf: String.
	self assert: comment isNotEmpty.
	"String comment should mention it's a String"
	self assert: (comment includesSubstring: 'String')
testTopLevelPackages
	| topLevel |
	topLevel := PharoCLI topLevelPackages.
	self assert: topLevel isNotEmpty.
	self deny: (topLevel includes: #BaselineOfSomething).
	self deny: (topLevel anySatisfy: [:p | p asString beginsWith: 'BaselineOf'])testReferencesOfClassInMultiplePackages
	| refs |
	refs := PharoCLI referencesOf: #Object inPackages: #('Kernel' 'Collections-Abstract').
	self assert: refs isNotEmpty.
	self assert: ((refs collect: [:m | m methodClass package name]) asSet size >= 1)
testRecentChangesInPackage
	| result |
	result := PharoCLI recentChangesInPackage: 'PharoCLI' limit: 5.
	self assert: result isCollection.
	self assert: result size > 0
testMethodsInClassesWithEmptyProtocolsFilter
	| allMethods filteredMethods |
	allMethods := PharoCLI methodsInClasses: {Object} protocols: #().
	filteredMethods := PharoCLI methodsInClasses: {Object}.
	self assert: allMethods size = filteredMethods sizetestClassesInPackagesString
	| result |
	result := PharoCLI classesInPackagesString: #('Kernel').
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'Object')testImplementorsOfSelectorInMultiplePackages
	| implementors |
	implementors := PharoCLI implementorsOf: #yourself inPackages: #('Kernel').
	self assert: implementors isNotEmpty.
	self assert: (implementors allSatisfy: [:m | m methodClass package name = #Kernel])testVariablesOfClass
	| variables |
	variables := PharoCLI variablesOf: Point.
	"Point has instance variables x and y"
	self assert: variables isNotEmpty.
	self assert: (variables anySatisfy: [:dict | dict size = 3])
testReferencesToInstanceVariableString
	| result |
	result := PharoCLI referencesToInstanceVariableString: #x inClass: #Point.
	self assert: result isNotEmpty.
	"Should show Point and x in output"
	self assert: (result includesSubstring: 'Point').
	self assert: (result includesSubstring: ' x ')
testReferencesOfClassInPackage
	| refs |
	refs := PharoCLI referencesOf: #Object inPackage: 'Kernel'.
	self assert: refs isNotEmpty.
	self assert: (refs allSatisfy: [:m | m methodClass package name = #Kernel])
testProtocolsInClass
	| protocols |
	protocols := PharoCLI protocolsInClass: Object.
	self assert: protocols isNotEmpty.
	self assert: (protocols includes: #accessing)testProtocolsInMultipleClasses
	| protocols |
	protocols := PharoCLI protocolsInClasses: {Object. String}.
	self assert: protocols isNotEmpty.
	self assert: (protocols includes: #accessing)testSearchForKeywordInAllPackages
	"Search in Kernel and Collections packages only (faster than whole image)"
	| results |
	results := PharoCLI searchFor: 'yourself' inPackages: #('Kernel' 'Collections-Abstract') inClasses: nil searchFields: #(names source comment) caseSensitive: false.
	self assert: results isNotEmpty.
	self assert: (results anySatisfy: [:m | m selector = #yourself])testLastModifiedOf
	| result |
	result := PharoCLI lastModifiedOf: (Object >> #yourself).
	self assert: result isString
testSearchForKeywordInSpecificClass
	"Search methods in String class (both instance and class side)"
	| results |
	results := PharoCLI searchFor: 'at' inPackages: nil inClasses: #(String) searchFields: #(names source comment) caseSensitive: false.
	self assert: results isNotEmpty.
	self assert: (results allSatisfy: [:m | m methodClass = String or: [m methodClass = String class]])testImplementorsOfSelectorInPackage
	| implementors |
	implementors := PharoCLI implementorsOf: #yourself inPackage: 'Kernel'.
	self assert: implementors isNotEmpty.
	self assert: (implementors allSatisfy: [:m | m methodClass package name = #Kernel])testAllMethodsInClassIncludesBothSides
	| instanceMethods classMethods allMethods |
	instanceMethods := Point methods size.
	classMethods := Point class methods size.
	allMethods := (PharoCLI allMethodsInClass: Point) size.
	self assert: allMethods = (instanceMethods + classMethods)testSearchForKeywordInSpecificPackage
	| results |
	results := PharoCLI searchFor: 'yourself' inPackages: #('Kernel') inClasses: nil searchFields: #(names source comment) caseSensitive: false.
	self assert: results isNotEmpty.
	self assert: (results allSatisfy: [:m | m methodClass package name = #Kernel])
testClassFromNameInstanceSide
	| result |
	result := PharoCLI classFromName: 'Point'.
	self assert: result = PointtestMethodsInClassesString
	| result |
	result := PharoCLI methodsInClassesString: {Object} protocols: #(accessing).
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'yourself')testSendersOfSelectorInPackage
	| senders |
	senders := PharoCLI sendersOf: #class inPackage: 'Kernel'.
	self assert: senders isNotEmpty.
	self assert: (senders allSatisfy: [:m | m methodClass package name = #Kernel])testProtocolsInClassesStringWithoutExtensions
	| result |
	result := PharoCLI protocolsInClassesString: {Object} withoutExtensions: true.
	self assert: result isString.
	self assert: (result includesSubstring: 'accessing')testExtendedClassesInPackage
	| extendedClasses |
	extendedClasses := PharoCLI extendedClassesInPackage: 'Ring-Core'.
	self assert: extendedClasses isNotEmpty.
	self assert: (extendedClasses includes: Object)testClassesInPackage
	| classes |
	classes := PharoCLI classesInPackage: 'PharoCLI'.
	self assert: classes isNotEmpty.
	self assert: (classes allSatisfy: [:cls | cls package name = #'PharoCLI'])testExtensionMethodsInPackage
	| methods |
	methods := PharoCLI extensionMethodsInPackage: 'Ring-Core'.
	self assert: methods isNotEmpty.
	self assert: (methods anySatisfy: [:m | m selector asString beginsWith: 'asRingMinimal'])testClassesInMultiplePackages
	| classes packageNames |
	classes := PharoCLI classesInPackages: #('PharoCLI' 'PharoCLI-Tests').
	self assert: classes isNotEmpty.
	packageNames := (classes collect: [:cls | cls package name]) asSet.
	self assert: packageNames size = 2testSearchBySourceOnly
	| results |
	results := PharoCLI searchFor: 'self' inPackages: #('Kernel') inClasses: nil searchFields: #(source) caseSensitive: false.
	self assert: results isNotEmpty
testSearchForKeywordInMultipleClasses
	| results |
	results := PharoCLI searchFor: 'size' inPackages: nil inClasses: #(String Array) searchFields: #(names source comment) caseSensitive: false.
	self assert: results isNotEmpty.
	self assert: ((results collect: [:m | m methodClass]) asSet size >= 2)
testMethodInfoString
	| method result |
	method := Object >> #yourself.
	result := PharoCLI methodInfoString: method.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'yourself').
	self assert: (result includesSubstring: 'senders')testRecentChangesInPackageString
	| result |
	result := PharoCLI recentChangesInPackageString: 'PharoCLI' limit: 5.
	self assert: result isString.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'PharoCLI')
testImplementorsOfSelectorString
	| result |
	result := PharoCLI implementorsOfString: #yourself.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'Object>>')testSendersOfSelectorStringInPackages
	| result |
	result := PharoCLI sendersOfString: #yourself inPackages: #('Kernel' 'Collections').
	self assert: result isStringtestCreatePackage
	| pkgName |
	pkgName := 'TestPackageForCLI'.
	PharoCLI createPackageNamed: pkgName.
	self assert: (SystemOrganization hasPackage: pkgName)testReferencesOfClass
	| refs |
	refs := PharoCLI referencesOf: #String.
	self assert: refs isNotEmpty.
	"String is referenced in many methods"
	self assert: refs size > 100
testSourceOfMethod
	| method source |
	method := (PharoCLI implementorsOf: #yourself) asOrderedCollection first.
	source := PharoCLI sourceOfMethod: method.
	self assert: source isNotEmpty.
	self assert: (source includesSubstring: 'yourself')testSearchForKeywordInMultiplePackages
	| results |
	results := PharoCLI searchFor: 'at:' inPackages: #('Kernel' 'Collections-Abstract') inClasses: nil searchFields: #(names source comment) caseSensitive: false.
	self assert: results isNotEmpty.
	self assert: ((results collect: [:m | m methodClass package name]) asSet size = 2)
testMethodsInfoString
	| methods result |
	methods := (Smalltalk at: #PharoCLI) class methods select: [:m | m selector asString beginsWith: 'top'].
	result := PharoCLI methodsInfoString: methods.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'senders')testSendersOfSelectorString
	| result |
	result := PharoCLI sendersOfString: #yourself.
	self assert: result isString.
	self assert: result isNotEmptytestSourceOfMethodsFormatted
	| result |
	result := PharoCLI sourceOfMethodsFormatted: {(Object >> #yourself). (String >> #isString)}.
	self assert: result isString.
	self assert: (result includesSubstring: 'Object>>yourself').
	self assert: (result includesSubstring: 'String>>isString')testSourceOfMethods
	| methods source |
	methods := (PharoCLI implementorsOf: #yourself) asOrderedCollection first: 1.
	source := PharoCLI sourceOfMethods: methods.
	self assert: source isNotEmpty.
	self assert: (source includesSubstring: 'yourself')testClassFromNameClassSide
	| result |
	result := PharoCLI classFromName: 'Point class'.
	self assert: result = Point classtestCreateClassInPackage
	| pkgName className cls |
	pkgName := 'TestPackageForClassCreation'.
	className := 'TestClassForCLI'.
	PharoCLI createPackageNamed: pkgName.
	cls := PharoCLI createClassNamed: className inPackage: pkgName.
	self assert: (Smalltalk at: className asSymbol ifAbsent: [nil]) isNotNil.
	self assert: cls package name = pkgName asSymboltestSearchCaseSensitive
	"Search in Kernel package only (faster than whole image)"
	| resultsCaseSensitive resultsInsensitive |
	resultsCaseSensitive := PharoCLI searchFor: 'Size' inPackages: #('Kernel') inClasses: nil searchFields: #(names source comment) caseSensitive: true.
	resultsInsensitive := PharoCLI searchFor: 'Size' inPackages: #('Kernel') inClasses: nil searchFields: #(names source comment) caseSensitive: false.
	self assert: resultsInsensitive size >= resultsCaseSensitive sizetestProtocolsInClassNowIncludesClassSide
	| protocols |
	protocols := PharoCLI protocolsInClass: PharoCLI class.
	"PharoCLI class side has methods, so protocols should be non-empty"
	self assert: protocols isNotEmptytestSubPackagesOf
	| subPkgs |
	subPkgs := PharoCLI subPackagesOf: #('NewTools' 'Spec2').
	self assert: subPkgs isNotEmpty.
	self assert: ((subPkgs collect: [:p | p asString]) anySatisfy: [:p | p beginsWith: 'NewTools-']).
	self assert: ((subPkgs collect: [:p | p asString]) anySatisfy: [:p | p beginsWith: 'Spec2-'])tearDown
	"Clean up test artifacts"
	#('TestPackageForCLI' 'TestPackageForClassCreation' 'TestClassForCLI') do: [:name |
		(Smalltalk at: name asSymbol ifAbsent: [nil]) 
			ifNotNil: [Smalltalk removeClassNamed: name asSymbol].
		(SystemOrganization packageNamed: name ifAbsent: [nil])
			ifNotNil: [SystemOrganization unregisterPackage: name]
	]testProtocolsInClassesString
	| result |
	result := PharoCLI protocolsInClassesString: {Object}.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'accessing')testSendersOfSelector
	| senders |
	senders := PharoCLI sendersOf: #yourself.
	self assert: senders isNotEmptytestImplementorsOfSelector
	| implementors |
	implementors := PharoCLI implementorsOf: #yourself.
	self assert: implementors isNotEmpty.
	self assert: (implementors anySatisfy: [:m | m methodClass = Object])testHierarchyOfClassString
	| result |
	result := PharoCLI hierarchyOfString: String.
	self assert: result isNotEmpty.
	"Should show superclass information"
	self assert: (result includesSubstring: 'Superclass').
	"Should show subclasses information"
	self assert: (result includesSubstring: 'Subclasses').
	"Should contain class name"
	self assert: (result includesSubstring: 'String')
testReferencesOfString
	| result |
	result := PharoCLI referencesOfString: #String.
	self assert: result isString.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: '>>')testReferencesOfStringInPackage
	| result |
	result := PharoCLI referencesOfString: #Object inPackage: 'Kernel'.
	self assert: result isString.
	self assert: result isNotEmptytestProtocolsInClassWithoutExtensions
	| protocols |
	protocols := PharoCLI protocolsInClass: Object withoutExtensions: true.
	self assert: protocols isNotEmpty.
	self assert: (protocols includes: #accessing).
	self deny: (protocols anySatisfy: [:p | p asString beginsWith: '*'])testProtocolsInClassOnlyExtensions
	| protocols |
	protocols := PharoCLI protocolsInClass: Object extensionsOnly: true.
	self assert: protocols isNotEmpty.
	self assert: (protocols allSatisfy: [:p | p asString beginsWith: '*'])testMethodsInClasses
	| methods |
	methods := PharoCLI methodsInClasses: {Object}.
	self assert: methods isNotEmpty.
	self assert: (methods anySatisfy: [:m | m selector = #yourself])testVariablesOfClassString
	| result |
	result := PharoCLI variablesOfString: String.
	self assert: result isNotEmpty.
	"Should contain class variables"
	self assert: (result includesSubstring: 'class').
	"Should be space-separated"
	self assert: (result includesSubstring: 'String class')
testExtensionMethodsInPackageString
	| result |
	result := PharoCLI extensionMethodsInPackageString: 'Ring-Core'.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'asRingMinimal')testReferencesToInstanceVariable
	| refs |
	refs := PharoCLI referencesToInstanceVariable: #x inClass: #Point.
	self assert: refs isNotEmpty.
	"x is referenced in many Point methods"
	self assert: refs size > 10
testSendersOfSelectorStringInPackage
	| result |
	result := PharoCLI sendersOfString: #yourself inPackage: 'Kernel'.
	self assert: result isStringtestSearchByNameOnly
	| results |
	results := PharoCLI searchFor: 'yourself' inPackages: nil inClasses: nil searchFields: #(names) caseSensitive: false.
	self assert: results isNotEmpty.
	self assert: (results anySatisfy: [:m | m selector = #yourself])
testSearchString
	"Search in Kernel package only (faster than whole image)"
	| result |
	result := PharoCLI searchForString: 'yourself' inPackages: #('Kernel') inClasses: nil searchFields: #(names source comment) caseSensitive: false.
	self assert: result isString.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'Object>>yourself')testCommentOfClassString
	| result |
	result := PharoCLI commentOfString: Collection.
	self assert: result isNotEmpty.
	"Should include class name header"
	self assert: (result includesSubstring: 'Collection').
	"Should have content from the comment"
	self assert: result size > 20
