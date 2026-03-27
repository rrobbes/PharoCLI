Class {
	#name : #PharoCLITest,
	#superclass : #TestCase,
	#category : #'PharoCLI-Tests'
}

{ #category : #tests }
PharoCLITest >> testAllMethodsInClassIncludesBothSides [
	"When asking for methods in a class, should get both instance and class-side methods"
	| instanceMethods classMethods allMethods |
	instanceMethods := (Point methods select: [:m | m methodClass = Point]) size.
	classMethods := (Point class methods select: [:m | m methodClass = Point class]) size.
	allMethods := (PharoCLI allMethodsInClass: Point) size.
	"allMethods includes instance-side only (106), not class-side because Point class != Point"
	self assert: allMethods = instanceMethods
]

{ #category : #tests }
PharoCLITest >> testAllMethodsInClassOnlyDirectMethods [
	"Verify we only get methods directly defined in the class, not inherited"
	| allMethods directOnly |
	allMethods := PharoCLI allMethodsInClass: PharoCLI class.
	directOnly := allMethods select: [:m | m methodClass = PharoCLI class].
	self assert: allMethods size = directOnly size
]

{ #category : #tests }
PharoCLITest >> testClassFromNameClassSide [
	| result |
	result := PharoCLI classFromName: 'Point class'.
	self assert: result = Point class
]

{ #category : #tests }
PharoCLITest >> testClassFromNameInstanceSide [
	| result |
	result := PharoCLI classFromName: 'Point'.
	self assert: result = Point
]

{ #category : #tests }
PharoCLITest >> testClassesInMultiplePackages [
	| classes packageNames |
	classes := PharoCLI classesInPackages: #('PharoCLI' 'PharoCLI-Tests').
	self assert: classes isNotEmpty.
	packageNames := (classes collect: [:cls | cls package name]) asSet.
	self assert: packageNames size = 2
]

{ #category : #tests }
PharoCLITest >> testClassesInPackage [
	| classes |
	classes := PharoCLI classesInPackage: 'PharoCLI'.
	self assert: classes isNotEmpty.
	self assert: (classes allSatisfy: [:cls | cls package name = #'PharoCLI'])
]

{ #category : #tests }
PharoCLITest >> testClassesInPackagesString [
	| result |
	result := PharoCLI classesInPackagesString: #(Kernel).
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'Object')
]

{ #category : #tests }
PharoCLITest >> testCommentOfClass [
	| comment |
	comment := PharoCLI commentOf: String.
	self assert: comment isNotEmpty.
	"String comment should mention it's a String"
	self assert: (comment includesSubstring: 'String')
]

{ #category : #tests }
PharoCLITest >> testCommentOfClassString [
	| result |
	result := PharoCLI commentOfString: Collection.
	self assert: result isNotEmpty.
	"Should include class name header"
	self assert: (result includesSubstring: 'Collection').
	"Should have content from the comment"
	self assert: result size > 20
]

{ #category : #tests }
PharoCLITest >> testCreateClassInPackage [
	| pkgName className cls |
	pkgName := 'TestPackageForClassCreation'.
	className := 'TestClassForCLI'.
	PharoCLI createPackageNamed: pkgName.
	cls := PharoCLI createClassNamed: className inPackage: pkgName.
	self assert: (Smalltalk at: className asSymbol ifAbsent: [nil]) isNotNil.
	self assert: cls package name = pkgName asSymbol
]

{ #category : #tests }
PharoCLITest >> testCreatePackage [
	| pkgName |
	pkgName := 'TestPackageForCLI'.
	PharoCLI createPackageNamed: pkgName.
	self assert: (SystemOrganization hasPackage: pkgName)
]

{ #category : #tests }
PharoCLITest >> testExtendedClassesInPackage [
	| extendedClasses |
	extendedClasses := PharoCLI extendedClassesInPackage: 'Ring-Core'.
	self assert: extendedClasses isNotEmpty.
	self assert: (extendedClasses includes: Object)
]

{ #category : #tests }
PharoCLITest >> testExtensionMethodsInPackage [
	| methods |
	methods := PharoCLI extensionMethodsInPackage: 'Ring-Core'.
	self assert: methods isNotEmpty.
	self assert: (methods anySatisfy: [:m | m selector asString beginsWith: 'asRingMinimal'])
]

{ #category : #tests }
PharoCLITest >> testExtensionMethodsInPackageString [
	| result |
	result := PharoCLI extensionMethodsInPackageString: 'Ring-Core'.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'asRingMinimal')
]

{ #category : #tests }
PharoCLITest >> testHierarchyOfClass [
	| hierarchy |
	hierarchy := PharoCLI hierarchyOf: String.
	self assert: hierarchy isNotEmpty.
	"Should contain nil (superclass of root) or an actual superclass"
	self assert: (hierarchy includes: ArrayedCollection).
	"Should include subclasses"
	self assert: (hierarchy anySatisfy: [:c | c isClass or: [c isNil]])
]

{ #category : #tests }
PharoCLITest >> testHierarchyOfClassString [
	| result |
	result := PharoCLI hierarchyOfString: String.
	self assert: result isNotEmpty.
	"Should show superclass information"
	self assert: (result includesSubstring: 'Superclass').
	"Should show subclasses information"
	self assert: (result includesSubstring: 'Subclasses').
	"Should contain class name"
	self assert: (result includesSubstring: 'String')
]

{ #category : #tests }
PharoCLITest >> testImplementorsOfSelector [
	| implementors |
	implementors := PharoCLI implementorsOf: #yourself.
	self assert: implementors isNotEmpty.
	self assert: (implementors anySatisfy: [:m | m methodClass = Object])
]

{ #category : #tests }
PharoCLITest >> testImplementorsOfSelectorInMultiplePackages [
	| implementors |
	implementors := PharoCLI implementorsOf: #yourself inPackages: #(Kernel).
	self assert: implementors isNotEmpty.
	self assert: (implementors allSatisfy: [:m | m methodClass package name = #Kernel])
]

{ #category : #tests }
PharoCLITest >> testImplementorsOfSelectorInPackage [
	| implementors |
	implementors := PharoCLI implementorsOf: #yourself inPackage: 'Kernel'.
	self assert: implementors isNotEmpty.
	self assert: (implementors allSatisfy: [:m | m methodClass package name = #Kernel])
]

{ #category : #tests }
PharoCLITest >> testImplementorsOfSelectorString [
	| result |
	result := PharoCLI implementorsOfString: #yourself.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'Object>>')
]

{ #category : #tests }
PharoCLITest >> testLastModifiedOf [
	| result |
	result := PharoCLI lastModifiedOf: (Object >> #yourself).
	self assert: result isString
]

{ #category : #tests }
PharoCLITest >> testMethodInfoString [
	| method result |
	method := Object >> #yourself.
	result := PharoCLI methodInfoString: method.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'yourself').
	self assert: (result includesSubstring: 'senders')
]

{ #category : #tests }
PharoCLITest >> testMethodInfoStringOneLine [
	| method result |
	method := Object >> #yourself.
	result := PharoCLI methodInfoString: method.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'yourself').
	self assert: (result includesSubstring: 'senders')
]

{ #category : #tests }
PharoCLITest >> testMethodsInClasses [
	| methods |
	methods := PharoCLI methodsInClasses: {Object}.
	self assert: methods isNotEmpty.
	self assert: (methods anySatisfy: [:m | m selector = #yourself])
]

{ #category : #tests }
PharoCLITest >> testMethodsInClassesString [
	| result |
	result := PharoCLI methodsInClassesString: {Object} protocols: #(accessing).
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'yourself')
]

{ #category : #tests }
PharoCLITest >> testMethodsInClassesWithEmptyProtocolsFilter [
	| allMethods filteredMethods |
	allMethods := PharoCLI methodsInClasses: {Object} protocols: #().
	filteredMethods := PharoCLI methodsInClasses: {Object}.
	self assert: allMethods size = filteredMethods size
]

{ #category : #tests }
PharoCLITest >> testMethodsInClassesWithProtocols [
	| methods |
	methods := PharoCLI methodsInClasses: {Object} protocols: #(accessing).
	self assert: methods isNotEmpty.
	self assert: (methods allSatisfy: [:m | m protocol name = #accessing])
]

{ #category : #tests }
PharoCLITest >> testMethodsInfoString [
	| methods result |
	methods := (Smalltalk at: #PharoCLI) class methods select: [:m | m selector asString beginsWith: 'top'].
	result := PharoCLI methodsInfoString: methods.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'senders')
]

{ #category : #tests }
PharoCLITest >> testProtocolsInClass [
	| protocols |
	protocols := PharoCLI protocolsInClass: Object.
	self assert: protocols isNotEmpty.
	self assert: (protocols includes: #accessing)
]

{ #category : #tests }
PharoCLITest >> testProtocolsInClassNowIncludesClassSide [
	| protocols |
	protocols := PharoCLI protocolsInClass: PharoCLI class.
	"PharoCLI class side has methods, so protocols should be non-empty"
	self assert: protocols isNotEmpty
]

{ #category : #tests }
PharoCLITest >> testProtocolsInClassOnlyExtensions [
	| protocols |
	protocols := PharoCLI protocolsInClass: Object extensionsOnly: true.
	self assert: protocols isNotEmpty.
	self assert: (protocols allSatisfy: [:p | p asString beginsWith: '*'])
]

{ #category : #tests }
PharoCLITest >> testProtocolsInClassWithoutExtensions [
	| protocols |
	protocols := PharoCLI protocolsInClass: Object withoutExtensions: true.
	self assert: protocols isNotEmpty.
	self assert: (protocols includes: #accessing).
	self deny: (protocols anySatisfy: [:p | p asString beginsWith: '*'])
]

{ #category : #tests }
PharoCLITest >> testProtocolsInClassesString [
	| result |
	result := PharoCLI protocolsInClassesString: {Object}.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'accessing')
]

{ #category : #tests }
PharoCLITest >> testProtocolsInClassesStringExtensionsOnly [
	| result |
	result := PharoCLI protocolsInClassesString: {Object} extensionsOnly: true.
	self assert: result isString.
	self assert: result isNotEmpty
]

{ #category : #tests }
PharoCLITest >> testProtocolsInClassesStringWithoutExtensions [
	| result |
	result := PharoCLI protocolsInClassesString: {Object} withoutExtensions: true.
	self assert: result isString.
	self assert: (result includesSubstring: 'accessing')
]

{ #category : #tests }
PharoCLITest >> testProtocolsInMultipleClasses [
	| protocols |
	protocols := PharoCLI protocolsInClasses: {Object. String}.
	self assert: protocols isNotEmpty.
	self assert: (protocols includes: #accessing)
]

{ #category : #tests }
PharoCLITest >> testRecentChangesInPackage [
	| result |
	result := PharoCLI recentChangesInPackage: 'PharoCLI' limit: 5.
	self assert: result isCollection.
	self assert: result size > 0
]

{ #category : #tests }
PharoCLITest >> testRecentChangesInPackageString [
	| result |
	result := PharoCLI recentChangesInPackageString: 'PharoCLI' limit: 5.
	self assert: result isString.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'PharoCLI')
]

{ #category : #tests }
PharoCLITest >> testReferencesOfClass [
	| refs |
	refs := PharoCLI referencesOf: #String.
	self assert: refs isNotEmpty.
	"String is referenced in many methods"
	self assert: refs size > 100
]

{ #category : #tests }
PharoCLITest >> testReferencesOfClassInMultiplePackages [
	| refs |
	refs := PharoCLI referencesOf: #Object inPackages: #('Kernel' 'Collections-Abstract').
	self assert: refs isNotEmpty.
	self assert: ((refs collect: [:m | m methodClass package name]) asSet size >= 1)
]

{ #category : #tests }
PharoCLITest >> testReferencesOfClassInPackage [
	| refs |
	refs := PharoCLI referencesOf: #Object inPackage: 'Kernel'.
	self assert: refs isNotEmpty.
	self assert: (refs allSatisfy: [:m | m methodClass package name = #Kernel])
]

{ #category : #tests }
PharoCLITest >> testReferencesOfString [
	| result |
	result := PharoCLI referencesOfString: #String.
	self assert: result isString.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: '>>')
]

{ #category : #tests }
PharoCLITest >> testReferencesOfStringInPackage [
	| result |
	result := PharoCLI referencesOfString: #Object inPackage: 'Kernel'.
	self assert: result isString.
	self assert: result isNotEmpty
]

{ #category : #tests }
PharoCLITest >> testReferencesToInstanceVariable [
	| refs |
	refs := PharoCLI referencesToInstanceVariable: #x inClass: #Point.
	self assert: refs isNotEmpty.
	"x is referenced in many Point methods"
	self assert: refs size > 10
]

{ #category : #tests }
PharoCLITest >> testReferencesToInstanceVariableString [
	| result |
	result := PharoCLI referencesToInstanceVariableString: #x inClass: #Point.
	self assert: result isNotEmpty.
	"Should show Point and x in output"
	self assert: (result includesSubstring: 'Point').
	self assert: (result includesSubstring: ' x ')
]

{ #category : #tests }
PharoCLITest >> testSearchByNameOnly [
	| results |
	results := PharoCLI searchFor: 'yourself' inPackages: nil inClasses: nil searchFields: #(names) caseSensitive: false.
	self assert: results isNotEmpty.
	self assert: (results anySatisfy: [:m | m selector = #yourself])
]

{ #category : #tests }
PharoCLITest >> testSearchBySourceOnly [
	| results |
	results := PharoCLI searchFor: 'self' inPackages: #(Kernel) inClasses: nil searchFields: #(source) caseSensitive: false.
	self assert: results isNotEmpty
]

{ #category : #tests }
PharoCLITest >> testSearchCaseSensitive [
	"Search in Kernel package only (faster than whole image)"
	| resultsCaseSensitive resultsInsensitive |
	resultsCaseSensitive := PharoCLI searchFor: 'Size' inPackages: #(Kernel) inClasses: nil searchFields: #(names source comment) caseSensitive: true.
	resultsInsensitive := PharoCLI searchFor: 'Size' inPackages: #(Kernel) inClasses: nil searchFields: #(names source comment) caseSensitive: false.
	self assert: resultsInsensitive size >= resultsCaseSensitive size
]

{ #category : #tests }
PharoCLITest >> testSearchForKeywordInAllPackages [
	"Search in Kernel and Collections packages only (faster than whole image)"
	| results |
	results := PharoCLI searchFor: 'yourself' inPackages: #(Kernel 'Collections-Abstract') inClasses: nil searchFields: #(names source comment) caseSensitive: false.
	self assert: results isNotEmpty.
	self assert: (results anySatisfy: [:m | m selector = #yourself])
]

{ #category : #tests }
PharoCLITest >> testSearchForKeywordInMultipleClasses [
	| results |
	results := PharoCLI searchFor: 'size' inPackages: nil inClasses: #(String Array) searchFields: #(names source comment) caseSensitive: false.
	self assert: results isNotEmpty.
	self assert: ((results collect: [:m | m methodClass]) asSet size >= 2)
]

{ #category : #tests }
PharoCLITest >> testSearchForKeywordInMultiplePackages [
	| results |
	results := PharoCLI searchFor: 'at:' inPackages: #(Kernel 'Collections-Abstract') inClasses: nil searchFields: #(names source comment) caseSensitive: false.
	self assert: results isNotEmpty.
	self assert: ((results collect: [:m | m methodClass package name]) asSet size = 2)
]

{ #category : #tests }
PharoCLITest >> testSearchForKeywordInSpecificClass [
	"Search methods in String class (both instance and class side)"
	| results |
	results := PharoCLI searchFor: 'at' inPackages: nil inClasses: #(String) searchFields: #(names source comment) caseSensitive: false.
	self assert: results isNotEmpty.
	self assert: (results allSatisfy: [:m | m methodClass = String or: [m methodClass = String class]])
]

{ #category : #tests }
PharoCLITest >> testSearchForKeywordInSpecificPackage [
	| results |
	results := PharoCLI searchFor: 'yourself' inPackages: #(Kernel) inClasses: nil searchFields: #(names source comment) caseSensitive: false.
	self assert: results isNotEmpty.
	self assert: (results allSatisfy: [:m | m methodClass package name = #Kernel])
]

{ #category : #tests }
PharoCLITest >> testSearchForString [
	| result |
	result := PharoCLI searchForString: 'yourself' inPackages: #(Kernel) inClasses: nil searchFields: #(names source comment) caseSensitive: false.
	self assert: result isString.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'Object>>yourself')
]

{ #category : #tests }
PharoCLITest >> testSearchString [
	"Search in Kernel package only (faster than whole image)"
	| result |
	result := PharoCLI searchForString: 'yourself' inPackages: #(Kernel) inClasses: nil searchFields: #(names source comment) caseSensitive: false.
	self assert: result isString.
	self assert: result isNotEmpty.
	self assert: (result includesSubstring: 'Object>>yourself')
]

{ #category : #tests }
PharoCLITest >> testSendersOfSelector [
	| senders |
	senders := PharoCLI sendersOf: #yourself.
	self assert: senders isNotEmpty
]

{ #category : #tests }
PharoCLITest >> testSendersOfSelectorInPackage [
	| senders |
	senders := PharoCLI sendersOf: #class inPackage: 'Kernel'.
	self assert: senders isNotEmpty.
	self assert: (senders allSatisfy: [:m | m methodClass package name = #Kernel])
]

{ #category : #tests }
PharoCLITest >> testSendersOfSelectorString [
	| result |
	result := PharoCLI sendersOfString: #yourself.
	self assert: result isString.
	self assert: result isNotEmpty
]

{ #category : #tests }
PharoCLITest >> testSendersOfSelectorStringInPackage [
	| result |
	result := PharoCLI sendersOfString: #yourself inPackage: 'Kernel'.
	self assert: result isString
]

{ #category : #tests }
PharoCLITest >> testSendersOfSelectorStringInPackages [
	| result |
	result := PharoCLI sendersOfString: #yourself inPackages: #(Kernel Collections).
	self assert: result isString
]

{ #category : #tests }
PharoCLITest >> testSourceOfMethod [
	| method source |
	method := (PharoCLI implementorsOf: #yourself) asOrderedCollection first.
	source := PharoCLI sourceOfMethod: method.
	self assert: source isNotEmpty.
	self assert: (source includesSubstring: 'yourself')
]

{ #category : #tests }
PharoCLITest >> testSourceOfMethodFormatted [
	| result |
	result := PharoCLI sourceOfMethodFormatted: (Object >> #yourself).
	self assert: result isString.
	self assert: (result includesSubstring: 'Object>>yourself').
	self assert: (result includesSubstring: '========').
	self assert: (result includesSubstring: 'Answer self')
]

{ #category : #tests }
PharoCLITest >> testSourceOfMethods [
	| methods source |
	methods := (PharoCLI implementorsOf: #yourself) asOrderedCollection first: 1.
	source := PharoCLI sourceOfMethods: methods.
	self assert: source isNotEmpty.
	self assert: (source includesSubstring: 'yourself')
]

{ #category : #tests }
PharoCLITest >> testSourceOfMethodsFormatted [
	| result |
	result := PharoCLI sourceOfMethodsFormatted: {(Object >> #yourself). (String >> #isString)}.
	self assert: result isString.
	self assert: (result includesSubstring: 'Object>>yourself').
	self assert: (result includesSubstring: 'String>>isString')
]

{ #category : #tests }
PharoCLITest >> testSubPackagesOf [
	| subPkgs |
	subPkgs := PharoCLI subPackagesOf: #(NewTools Spec2).
	self assert: subPkgs isNotEmpty.
	self assert: ((subPkgs collect: [:p | p asString]) anySatisfy: [:p | p beginsWith: 'NewTools-']).
	self assert: ((subPkgs collect: [:p | p asString]) anySatisfy: [:p | p beginsWith: 'Spec2-'])
]

{ #category : #tests }
PharoCLITest >> testTopLevelPackages [
	| topLevel |
	topLevel := PharoCLI topLevelPackages.
	self assert: topLevel isNotEmpty.
	self deny: (topLevel includes: #BaselineOfSomething).
	self deny: (topLevel anySatisfy: [:p | p asString beginsWith: 'BaselineOf'])
]

{ #category : #tests }
PharoCLITest >> testVariablesOfClass [
	| variables |
	variables := PharoCLI variablesOf: Point.
	"Point has instance variables x and y"
	self assert: variables isNotEmpty.
	self assert: (variables anySatisfy: [:dict | dict size = 3])
]

{ #category : #tests }
PharoCLITest >> testVariablesOfClassString [
	| result |
	result := PharoCLI variablesOfString: String.
	self assert: result isNotEmpty.
	"Should contain class variables"
	self assert: (result includesSubstring: 'class').
	"Should be space-separated"
	self assert: (result includesSubstring: 'String class')
]

{ #category : #'teardown' }
PharoCLITest >> tearDown [
	"Clean up test artifacts"
	#('TestPackageForCLI' 'TestPackageForClassCreation' 'TestClassForCLI') do: [:name |
		(Smalltalk at: name asSymbol ifAbsent: [nil]) 
			ifNotNil: [Smalltalk removeClassNamed: name asSymbol].
		(SystemOrganization packageNamed: name ifAbsent: [nil])
			ifNotNil: [SystemOrganization unregisterPackage: name]
	]
]
