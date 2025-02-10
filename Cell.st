Object subclass: Cell [
    | state |
    Cell class >> newAlive [
        ^ self new initialize: true.
    ]

    Cell class >> newDead [
        ^ self new initialize: false.
    ]

    initialize: aState [
        state := aState.
    ]

    isAlive [
        ^ state.
    ]

    makeAlive [
        state := true.
    ]

    makeDead [
        state := false.
    ]

    "Fix: Ensure Cell displays correct character"
    display [
        ^ state ifTrue: [ '*' ] ifFalse: [ ' ' ].
    ]
]
