SpPresenter << #WhiskerBrowser
	slots: { #methodList . #methodPanels . #shownMethods . #previousSelection }
	package: 'WhiskersAtLast'

WhiskerBrowser >> initializePresenters
	methodList := self newList
		items: String methods;
		display: [ :m | m selector ];
		beMultipleSelection;
		yourself.
	
	methodPanels := SpPresenter new
		layout: (SpBoxLayout newTopToBottom);
		yourself.
	
	shownMethods := Dictionary new.
	previousSelection := OrderedCollection new.
	
	methodList whenSelectionChangedDo: [ :selection |
		self handleSelectionChange: selection selectedItems ]

WhiskerBrowser >> defaultLayout
	^ SpPanedLayout newLeftToRight
		positionOfSlider: 0.3;
		add: methodList;
		add: methodPanels;
		yourself

WhiskerBrowser >> handleSelectionChange: newSelection
	| newSelectors prevSelectors added removed |
	newSelectors := (newSelection collect: #selector) asOrderedCollection.
	prevSelectors := (previousSelection collect: #selector) asOrderedCollection.
	
	added := newSelectors reject: [ :sel | prevSelectors includes: sel ].
	removed := prevSelectors reject: [ :sel | newSelectors includes: sel ].
	
	"Add panels for newly selected methods"
	added do: [ :sel |
		| method panel |
		method := newSelection detect: [ :m | m selector = sel ].
		panel := self newText
			text: method sourceCode;
			yourself.
		shownMethods at: sel put: panel ].
	
	"Remove panels for deselected methods"
	removed do: [ :sel | shownMethods removeKey: sel ].
	
	"Rebuild layout"
	methodPanels layout: (self buildLayoutForPanels: (shownMethods values asArray)).
	
	previousSelection := newSelection

WhiskerBrowser >> buildLayoutForPanels: panels
	| layout |
	layout := SpBoxLayout newTopToBottom.
	panels do: [ :panel | layout add: panel ].
	^ layout
