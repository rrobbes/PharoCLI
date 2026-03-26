BaselineOf << #BaselineOfPharoCLI	slots: {};	package: 'BaselineOfPharoCLI'baseline: spec
	<baseline>
	spec for: #common do: [
		self definePackages: spec.
		self defineGroups: spec
	]definePackages: spec
	spec 
		package: #PharoCLI;
		package: #'PharoCLI-Tests' with: [spec requires: #(#PharoCLI)]
defineGroups: spec
	spec 
		group: #default with: #(#PharoCLI #'PharoCLI-Tests');
		group: #core with: #(#PharoCLI)
