buildLayoutForPanels: panels
	| layout |
	layout := SpBoxLayout newTopToBottom.
	panels do: [ :panel | layout add: panel ].
	^ layout
