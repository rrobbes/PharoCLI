initializePresenters
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
