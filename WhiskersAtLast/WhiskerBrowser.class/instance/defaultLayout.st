defaultLayout
	^ SpPanedLayout newLeftToRight
		positionOfSlider: 0.3;
		add: methodList;
		add: methodPanels;
		yourself
