Class {
	#name : 'PLUtils',
	#superclass : 'Object',
	#instVars : [
		'model'
	],
	#category : 'PythonLintUtils',
	#package : 'PythonLintUtils'
}

{ #category : 'actions api' }
PLUtils class >> load: aFilereference [

	^ self new
	  model: (FamixPythonImporter import: aFilereference);
		yourself.
	  
]

{ #category : 'testing' }
PLUtils >> allFuncOrMethodsInvocationWithArg: anArg [

	| invocations func |
	invocations := model allInvocations.
	invocations := invocations select: [ :i | i isArg: anArg ].
	func := invocations flatCollect: [ :i |
		  i candidates reject: [ :c | c isShadowed ] ].
	^func "Voir pour renvoyer l'objet directment si size = 1"
]

{ #category : 'testing' }
PLUtils >> allInvocationsWithArg: anArg [

	| invocations |
	invocations := model allInvocations.
	^invocations select: [ :i | i isArg: anArg ]
]

{ #category : 'as yet unclassified' }
PLUtils >> checkFromImportUsage [

	| imports unusedImport |
	imports := self getFromImport collect: [ :i | i importedEntity name ].
	imports isEmpty ifTrue: [ self halt: 'Pas de from import' ].


	unusedImport := imports select: [ :i |
		                 (self getSpecificInvocation: i) isNil ].

	^ unusedImport isEmpty
		  ifTrue: [ 'All from imports used' ]
		  ifFalse: [ unusedImport ]
]

{ #category : 'as yet unclassified' }
PLUtils >> getFromImport [

	^ model allImports select: [ :i | i isFromImport ]
]

{ #category : 'as yet unclassified' }
PLUtils >> getFunctionWithUnusedParams [

	^ model allFunctions select: [ :m | m isStub not and: [m signature includesSubstring: '*_'] ]
]

{ #category : 'as yet unclassified' }
PLUtils >> getFunctionsWithName: aFunctionName [

	^ model allFunctions select: [ :i | i name = aFunctionName ]
]

{ #category : 'as yet unclassified' }
PLUtils >> getMethodsWithUnusedParams [

	^ model allMethods select: [ :m |
		  m signature includesSubstring: '*_' ] "A voir pour le backslash"
]

{ #category : 'as yet unclassified' }
PLUtils >> getMultipleAccessedVars [

	^ (self getVarAccessesOccurence valuesAndCounts reject: [ :assoc |
		   assoc value = 1 ]) keys
]

{ #category : 'as yet unclassified' }
PLUtils >> getSpecificInvocation: aFunctionName [

	^ model allInvocations detect: [ :i | i invokedEntity name = aFunctionName ] ifNone: [ nil ]
]

{ #category : 'as yet unclassified' }
PLUtils >> getTTSFunction [

	^ self getFunctionsWithName: 'train_test_split'
]

{ #category : 'as yet unclassified' }
PLUtils >> getTTSInvocationPos [

	| ttsFunction |
	ttsFunction := self getTTSFunction.
	^ ttsFunction collect: [ :f |
		  (f incomingInvocations at: 1) sourceAnchor endPos ]
]

{ #category : 'as yet unclassified' }
PLUtils >> getTestVarAccess [

	^ model allAccesses select: [ :a |
		  a isWrite and: [
			  a variable name endsWithAnyOf: { 'test'. 'TEST'. 'Test' } ] ]
]

{ #category : 'as yet unclassified' }
PLUtils >> getTestVarAccessPos [

	| access |
	access := self getTestVarAccess.	
	^ access collect: [ :a | a sourceAnchor endPos ]
]

{ #category : 'as yet unclassified' }
PLUtils >> getVarAccessesOccurence [

	^ (model allAccesses collect: #variable) asBag
]

{ #category : 'as yet unclassified' }
PLUtils >> isTestSetOverwrite [
	"Utiliser isEmpty plutot que > "
	| testVarPos ttsPos overwrite |
	testVarPos := self getTestVarAccessPos.
	testVarPos isEmpty ifTrue: [ self halt ].
	
	ttsPos := self getTTSInvocationPos.
	ttsPos isEmpty ifTrue: [ self halt ].
	
	overwrite := testVarPos reject: [ :w | ttsPos includes: w  ].
	
	^ overwrite isNotEmpty. 
	
	
	 
]

{ #category : 'accessing' }
PLUtils >> model [

	^model 
]

{ #category : 'accessing' }
PLUtils >> model: aModel [

	model := aModel
]
