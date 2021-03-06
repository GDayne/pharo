Extension { #name : #ListPresenter }

{ #category : #'*Spec-Examples' }
ListPresenter class >> example [
	<sampleInstance>
	^ self new
		items: Smalltalk globals allClasses;
		openWithSpec;
		yourself
]

{ #category : #'*Spec-Examples' }
ListPresenter class >> exampleMultipleSelection [
	<sampleInstance>
	^ self new
		items: Smalltalk globals allClasses;
		beMultipleSelection;
		openWithSpec;
		yourself
]

{ #category : #'*Spec-Examples' }
ListPresenter class >> exampleWithHeaderTitle [
	<sampleInstance>
	^ self new
		items: Smalltalk globals allClasses;
		headerTitle: 'Title';
		openWithSpec;
		yourself
]

{ #category : #'*Spec-Examples' }
ListPresenter class >> exampleWithIcons [
	<sampleInstance>
	^ self new
		icons: [ :e | self iconNamed: #forwardIcon ];
		items: (1 to: 10) asArray;
		openWithSpec;
		yourself
]
