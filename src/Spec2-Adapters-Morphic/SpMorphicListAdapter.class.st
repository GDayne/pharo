"
I am the adapter used to bridge a ListPresenter and a PluggableListMorph
"
Class {
	#name : #SpMorphicListAdapter,
	#superclass : #SpAbstractMorphicAdapter,
	#category : #'Spec2-Adapters-Morphic-List'
}

{ #category : #'widget API' }
SpMorphicListAdapter >> acceptDroppingMorph: draggedMorph event: event inMorph: source [
	| item index |
	
	index := source rowAtLocation: event position.
	item := self presenter model at: index ifAbsent: [ nil ].
	
	^ self acceptDropBlock valueWithEnoughArguments: { draggedMorph model model . event. source model model. item. index }
]

{ #category : #'spec protocol' }
SpMorphicListAdapter >> autoDeselect: aBoolean [

	self widgetDo: [ :w | w autoDeselect: aBoolean ]
]

{ #category : #'widget API' }
SpMorphicListAdapter >> backgroundColorFor: anItem [
	^ self model backgroundColorFor: anItem
]

{ #category : #'widget API' }
SpMorphicListAdapter >> backgroundColorFor: anItem at: index [

	^ self model backgroundColorFor: anItem at: index
]

{ #category : #factory }
SpMorphicListAdapter >> buildWidget [
	| datasource |
	datasource := SpListFastTableDataSource new.
	datasource model: self model.
	widget := FTTableMorph new
		dataSource: datasource;
		hideColumnHeaders;
		beResizable;
		columns: {self newListColumn};
		setMultipleSelection: self model isMultipleSelection;
		dragEnabled: self dragEnabled;
		dropEnabled: self dropEnabled;
		setBalloonText: self help;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		onAnnouncement: FTSelectionChanged send: #selectionChanged: to: self;
		onAnnouncement: FTStrongSelectionChanged send: #strongSelectionChanged: to: self;
		yourself.
	self presenter whenModelChangedDo: [ widget refresh ].
	self presenter whenSelectionChangedDo: [ self refreshWidgetSelection ].
	self presenter selection whenChangedDo: [ self refreshWidgetSelection ].
	self refreshWidgetHeaderTitle.
	self refreshWidgetSelection.
	self presenter whenItemFilterBlockChangedDo: [ :block | self updateItemFilterBlockWith: block ].
	self updateItemFilterBlockWith: self itemFilter.

	widget bindKeyCombination: Character space toAction: [ self model clickOnSelectedItem ].

	^ widget
]

{ #category : #emulating }
SpMorphicListAdapter >> hasFilter [
	^ self widget submorphs anySatisfy: [ :each | each isKindOf: RubTextFieldMorph	"This morph is the explicit filter of the list" ]
]

{ #category : #accessing }
SpMorphicListAdapter >> isShowColumnHeaders [
	
	^ widget isShowColumnHeaders 
]

{ #category : #'widget API' }
SpMorphicListAdapter >> itemFilter [
	^ self model itemFilter
]

{ #category : #'widget API' }
SpMorphicListAdapter >> listElementAt: anIndex ifAbsent: aBlock [

	^ self model listElementAt: anIndex ifAbsent: aBlock
]

{ #category : #'widget API' }
SpMorphicListAdapter >> listSize [

	^ self model listSize
]

{ #category : #factory }
SpMorphicListAdapter >> newListColumn [
	
	^ SpMorphicTableColumn new 
		model: (SpStringTableColumn
			title: self presenter headerTitle
			evaluated: self presenter displayBlock);
		yourself
]

{ #category : #'widget API' }
SpMorphicListAdapter >> refreshList [

	^ self widget refresh
]

{ #category : #'widget API' }
SpMorphicListAdapter >> refreshWidgetHeaderTitle [
	
	self presenter hasHeaderTitle 
		ifTrue: [ 
			self widget columns first model title: self presenter headerTitle.
			self widget
				showColumnHeaders;
				refresh. ]
		ifFalse: [ 
			self widget columns first model title: nil.
			self widget
				hideColumnHeaders;
				refresh ].
]

{ #category : #'widget API' }
SpMorphicListAdapter >> refreshWidgetList [
	(self widget showIndex < self widget dataSource numberOfRows
		and: [ self widget isIndexVisible: self widget showIndex ])
		ifFalse: [ self widget resetPosition ].
	self refreshWidgetSelection.
	(self widget hasSelection
		and: [ self widget isIndexVisible: self widget selectedIndex ])
		ifFalse: [ self widget resetPosition.
			self widget ensureVisibleFirstSelection ].
	self widget refresh
]

{ #category : #'widget API' }
SpMorphicListAdapter >> refreshWidgetSelection [
	| rowIndexes |
	rowIndexes := self presenter selection selectedIndexes.
	rowIndexes = self widget selectedIndexes
		ifTrue: [ ^ self ].
	rowIndexes isEmpty
		ifTrue: [ self widget basicSelectIndexes: #() ]
		ifFalse: [ self widget basicSelectIndexes: rowIndexes ].
	^ self widget refresh
]

{ #category : #emulating }
SpMorphicListAdapter >> rightClicked [
	| evt |

	evt := MouseButtonEvent new 
		setType: nil 
		position: widget center 
		which: MouseButtonEvent yellowButton 
		buttons: MouseButtonEvent yellowButton 
		hand: nil 
		stamp: nil.
	
	self widget click: evt
]

{ #category : #selecting }
SpMorphicListAdapter >> selectIndex: anInteger [ 
	
	(anInteger = 0 and: [ widget selectedIndexes isEmpty ]) ifTrue: [ ^ self ].	
	(widget selectedIndexes includes: anInteger) ifTrue: [^self].
	widget selectIndex: anInteger
]

{ #category : #factory }
SpMorphicListAdapter >> selectionChanged: ann [
	| diff |
	self presenter selection isMultipleSelection
		ifTrue: [ self presenter selection
				selectIndexes: (ann newSelectedIndexes reject: [ :e | e = 0 ]) ].
	self presenter selection isMultipleSelection
		ifFalse: [ self presenter selection
				selectIndex:
					(ann newSelectedIndexes
						ifNotEmpty: [ :indexes | indexes first ]
						ifEmpty: [ 0 ]) ].
	diff := ann newSelectedIndexes difference: ann oldSelectedIndexes.
	(diff notEmpty and: [ self presenter activatesOnSingleClick ])
		ifTrue: [ self presenter doActivateAtIndex: diff last ].
	ann newSelectedIndexes ifNotEmpty: [ ^ self ].
	self presenter selection unselectAll
]

{ #category : #events }
SpMorphicListAdapter >> strongSelectionChanged: aFTStrongSelectionChanged [
	self presenter activatesOnDoubleClick
		ifTrue: [ self presenter
				doubleClickAtIndex: aFTStrongSelectionChanged selectedIndex ]
]

{ #category : #factory }
SpMorphicListAdapter >> updateItemFilterBlockWith: block [
	^ block
		ifNotNil: [ widget
				enableFilter: (SpFTSpecFilter block: block);
				explicitFunction ]
		ifNil: [ widget disableFunction ]
]

{ #category : #events }
SpMorphicListAdapter >> updateMenu [
	
	"there is no need to updateMenu here because it will be resolved at the dataSource"
]
