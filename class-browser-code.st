ClassAndMethodBrowser class comment 'A three-panel browser for navigating Classes -> Methods -> Source Code'.

defaultIconName.
	^ #add.

defaultName.
	^ 'Class And Method Browser'.

initialize.
	super initialize.
	classList := self newList.
		items: Smalltalk allClasses select: [:c | c isClass];
		display: [ :cls | cls name ];
		beMultipleSelection;
		yourself.

	methodLists := SpPresenter new.
		layout: (SpBoxLayout newTopToBottom);
		yourself.

	codePanels := SpPresenter new.
		layout: (SpBoxLayout newTopToBottom);
		yourself.

	shownMethods := Dictionary new.
	classMethodLists: Dictionary new.
	previousClassSelection := OrderedCollection new.

	"Set up observers for each panel"
	classList whenSelectionChangedDo: [ :selection | self handleClassSelectionChange: selection selectedItems ].
	methodLists whenSelectionChangedDo: [ :selection | self handleMethodListSelectionChange: selection selectedItems ].
	codePanels whenSelectionChangedDo: [ :selection | self handleCodePanelSelectionChange: selection selectedItems ].

	codePanels layout.
	methodLists layout.

	title := SpTextPresenter new text: 'Class And Method Browser (3 panels)'.
	codePanels add: title.

	methodLists add: (SpTextPresenter new text: 'Select classes from the left panel').
	codePanels add: (SpTextPresenter new text: 'Select methods from the middle panel').
	codePanels add: (SpTextPresenter new text: 'Select methods from the right panel').

	self openWindow.