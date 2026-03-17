""
PharoCLI - Command-Line Interface for Pharo Image Inspection
Generated: 2026-03-17T15:01:55.004189+01:00

Packages:
- Pharo-CLI: Main CLI utility class with 50 methods
- Pharo-CLI-Tests: Test suite with 48 test methods

Methods cover:
- Package inspection (classes, protocols, methods)
- Method relationships (implementors, senders)
- Class hierarchy and documentation
- Instance variable references
- Source code and metadata inspection

To load in a Pharo image:
  FileLocator sourceTree / 'PharoCLI.st' asFileReference fileIn
""

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
commentOf: aClass
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
	^ allImplementors select: [:m | packageNameSet includes: m methodClass package name]protocolsInClass: aClass extensionsOnly: aBoolean
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
	^ resultsourceOfMethods: methods
	^ String streamContents: [:s |
		methods do: [:method |
			s << (self sourceOfMethod: method)
		]
	]savePackagesToFile: filePathString
	"Save both Pharo-CLI packages to a file"
	| pkg1 pkg2 file stream |
	pkg1 := PackageOrganizer default packageNamed: 'Pharo-CLI'.
	pkg2 := PackageOrganizer default packageNamed: 'Pharo-CLI-Tests'.
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
	
	^ 'Saved ' , (pkg1 methods size + pkg2 methods size) asString , ' methods to ' , filePathString
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
	^ String streamContents: [:s | topLevel do: [:p | s << p asString; << String lf]]methodsInfoString: methods
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
protocolsInClass: aClass withoutExtensions: aBoolean
	| protocols |
	protocols := self protocolsInClass: aClass.
	^ aBoolean
		ifTrue: [protocols reject: [:p | p asString beginsWith: '*']]
		ifFalse: [protocols]extensionMethodsInPackage: packageName
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
	^ String streamContents: [:s | subPkgs do: [:p | s << p asString; << String lf]]protocolsInClass: aClass
	^ ((aClass methods collect: #protocol) asSet collect: #name) reject: [:p | p isNil]implementorsOf: aSelector inPackage: packageName
	^ self implementorsOf: aSelector inPackages: {packageName}recentChangesInPackageString: packageName limit: limit
	| methods |
	methods := self recentChangesInPackage: packageName limit: limit.
	^ String streamContents: [:s |
		methods do: [:m |
			s << m methodClass name; << '>>' ; << m selector; << String lf
		]
	]
methodsInClasses: classes
	^ self methodsInClasses: classes protocols: #()methodsInClasses: classes protocols: protocols
	| result protocolNames |
	result := Set new.
	protocolNames := protocols asSet.
	classes do: [:cls |
		cls methods do: [:method |
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
	self deny: (topLevel anySatisfy: [:p | p asString beginsWith: 'BaselineOf'])testRecentChangesInPackage
	| result |
	result := PharoCLI recentChangesInPackage: 'Pharo-CLI' limit: 5.
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
testProtocolsInClass
	| protocols |
	protocols := PharoCLI protocolsInClass: Object.
	self assert: protocols isNotEmpty.
	self assert: (protocols includes: #accessing)testProtocolsInMultipleClasses
	| protocols |
	protocols := PharoCLI protocolsInClasses: {Object. String}.
	self assert: protocols isNotEmpty.
	self assert: (protocols includes: #accessing)testLastModifiedOf
	| result |
	result := PharoCLI lastModifiedOf: (Object >> #yourself).
	self assert: result isString
testImplementorsOfSelectorInPackage
	| implementors |
	implementors := PharoCLI implementorsOf: #yourself inPackage: 'Kernel'.
	self assert: implementors isNotEmpty.
	self assert: (implementors allSatisfy: [:m | m methodClass package name = #Kernel])testMethodsInClassesString
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
	classes := PharoCLI classesInPackage: 'Pharo-CLI'.
	self assert: classes isNotEmpty.
	self assert: (classes allSatisfy: [:cls | cls package name = #'Pharo-CLI'])testExtensionMethodsInPackage
	| methods |
	methods := PharoCLI extensionMethodsInPackage: 'Ring-Core'.
	self assert: methods isNotEmpty.
	self assert: (methods anySatisfy: [:m | m selector asString beginsWith: 'asRingMinimal'])testClassesInMultiplePackages
	| classes packageNames |
	classes := PharoCLI classesInPackages: #('Pharo-CLI' 'Pharo-CLI-Tests').
	self assert: classes isNotEmpty.
	packageNames := (classes collect: [:cls | cls package name]) asSet.
	self assert: packageNames size = 2testMethodInfoString
	| method result |
	method := Object >> #yourself.
	result := PharoCLI methodInfoString: method.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'yourself').
	self assert: (result includesSubstring: 'senders')testRecentChangesInPackageString
	| result |
	result := PharoCLI recentChangesInPackageString: 'Pharo-CLI' limit: 5.
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
	self assert: (SystemOrganization hasPackage: pkgName)testSourceOfMethod
	| method source |
	method := (PharoCLI implementorsOf: #yourself) asOrderedCollection first.
	source := PharoCLI sourceOfMethod: method.
	self assert: source isNotEmpty.
	self assert: (source includesSubstring: 'yourself')testMethodsInfoString
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
	self assert: (source includesSubstring: 'yourself')testCreateClassInPackage
	| pkgName className cls |
	pkgName := 'TestPackageForClassCreation'.
	className := 'TestClassForCLI'.
	PharoCLI createPackageNamed: pkgName.
	cls := PharoCLI createClassNamed: className inPackage: pkgName.
	self assert: (Smalltalk at: className asSymbol ifAbsent: [nil]) isNotNil.
	self assert: cls package name = pkgName asSymboltestSubPackagesOf
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
testProtocolsInClassWithoutExtensions
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
	self assert: result isStringtestCommentOfClassString
	| result |
	result := PharoCLI commentOfString: Collection.
	self assert: result isNotEmpty.
	"Should include class name header"
	self assert: (result includesSubstring: 'Collection').
	"Should have content from the comment"
	self assert: result size > 20
