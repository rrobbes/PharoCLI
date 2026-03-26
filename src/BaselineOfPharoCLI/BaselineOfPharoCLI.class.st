Class {
	#name : #BaselineOfPharoCLI,
	#superclass : #BaselineOf,
	#category : #BaselineOfPharoCLI
}

{ #category : #baseline }
BaselineOfPharoCLI >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
			self definePackages: spec.
			self defineGroups: spec
		]
]

{ #category : #accessing }
BaselineOfPharoCLI >> defineGroups: spec [
	spec 
		group: #default with: #(#PharoCLI #'PharoCLI-Tests');
		group: #core with: #(#PharoCLI)
]

{ #category : #accessing }
BaselineOfPharoCLI >> definePackages: spec [
	spec 
		package: #PharoCLI;
		package: #'PharoCLI-Tests' with: [spec requires: #(#PharoCLI)]
]
