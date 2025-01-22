Extension { #name : 'FamixPythonInvocation' }

{ #category : '*PythonLintUtils' }
FamixPythonInvocation >> arguments [

	| text start end paramsAsString res |
	text := self sourceAnchor sourceText.
	start := text indexOf: $(.
	end := text indexOf: $).
	paramsAsString := text copyFrom: start + 1 to: end - 1.
	res := paramsAsString splitOn: $,.
	^ res collect: [ :each | each trim ]
]

{ #category : '*PythonLintUtils' }
FamixPythonInvocation >> isArg: anArgName [

	^ self arguments anySatisfy: [ :a | a = anArgName ]
]
