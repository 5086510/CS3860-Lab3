Object subclass: Board [  
    | rows cols grid generations |

    "Getter for grid"
    grid [
        ^ grid.
    ]

    "Getter for generations"
    getGenerations [
        ^ generations.
    ]

    "Setter for generations"
    setGenerations: g [
        generations := g.
    ]

    "Class method to create a new board"
    Board class >> new: r with: c [
        ^ self new initializeRows: r cols: c.
    ]

    "Initialize the board with empty (dead) cells"
    initializeRows: r cols: c [
        rows := r asInteger.
        cols := c asInteger.
        generations := 0.  

        Transcript show: 'Initializing board with '; show: rows printString; show: ' rows and '; show: cols printString; show: ' columns.'; cr; flush.

        grid := Array new: rows.
        1 to: rows do: [ :i |
            grid at: i put: (Array new: cols).
            1 to: cols do: [ :j |
                (grid at: i) at: j put: (Cell newDead).
            ].
        ].

        Transcript show: '✅ Board initialized successfully.'; cr; flush.
    ]

    "Read configuration file and set board state"
    readConfigFile: fileName [
        | file line row columns gens rowIndex |

        file := FileStream open: fileName mode: #read.

        "Read the first line containing board dimensions and generations"
        line := file nextLine.
        row := ((line subStrings: ' ') at: 1) asInteger.
        columns := ((line subStrings: ' ') at: 2) asInteger.
        gens := ((line subStrings: ' ') at: 3) asInteger.

        Transcript show: 'Read dimensions: Rows='; show: row printString; show: ', Cols='; show: columns printString; show: ', Generations='; show: gens printString; cr; flush.

        "Initialize the board"
        self setGenerations: gens.
        Transcript show: '[DEBUG] Generations set to: '; show: self getGenerations printString; cr; flush.

        "Read board configuration from file"
        rowIndex := 1.
        [ file atEnd not and: [ rowIndex <= row ] ] whileTrue: [
            line := file nextLine.

            1 to: (line size min: columns) do: [ :colIndex |
                ((line at: colIndex) = $*) ifTrue: [
                    Transcript show: 'Setting cell alive at ('; show: rowIndex printString; show: ', '; show: colIndex printString; show: ')'; cr; flush.
                    self setCellAlive: rowIndex column: colIndex.
                ].
            ].

            rowIndex := rowIndex + 1.
        ].

        file close.
    ]

    "Get a cell at a specific position"
    getCell: row column: col [
        ((grid isNil) or: [(grid at: row) isNil]) ifTrue: [
            Transcript show: '[ERROR] getCell: Accessing invalid grid at ('; show: row printString; show: ', '; show: col printString; show: ')'; cr; flush.
            ^ nil.
        ].
        ^ (grid at: row) at: col.
    ]

    "Set a cell alive at the given row and column"
    setCellAlive: row column: col [
        ((grid at: row) at: col) makeAlive.
        Transcript show: '✅ setCellAlive: Cell at ('; show: row printString; show: ', '; show: col printString; show: ') is now alive.'; cr; flush.
    ]

    "Set a cell dead at the given row and column"
    setCellDead: row column: col [
        (grid at: row) at: col put: (Cell newDead).
    ]

    "Count the number of live neighbors for a given cell"
    countNeighbours: row column: col [
        | liveNeighbours directions |
        liveNeighbours := 0.
        directions := #((-1 -1) (-1 0) (-1 1) (0 -1) (0 1) (1 -1) (1 0) (1 1)).

        directions do: [ :d |
            | newRow newCol |
            newRow := row + (d at: 1).
            newCol := col + (d at: 2).

            (newRow >= 1 and: [ newRow <= rows ]) ifTrue: [
                (newCol >= 1 and: [ newCol <= cols ]) ifTrue: [
                    ((self getCell: newRow column: newCol) isAlive) ifTrue: [
                        liveNeighbours := liveNeighbours + 1.
                    ].
                ].
            ].
        ].
        ^ liveNeighbours.
    ]

    "Compute the next generation of cells"
    computeNextGeneration [
        | newGrid newCell |

        "Create a new board instance"
        newGrid := Board new: rows with: cols.

        1 to: rows do: [ :r |
            1 to: cols do: [ :c |
                | liveCount cell |
                liveCount := self countNeighbours: r column: c.
                cell := self getCell: r column: c.

                "Determine the new cell state"
                newCell := Cell newDead.  
                (cell isAlive)
                    ifTrue: [
                        (liveCount = 2 or: [ liveCount = 3 ])
                            ifTrue: [ newCell := Cell newAlive ].
                    ]
                    ifFalse: [
                        (liveCount = 3) ifTrue: [ newCell := Cell newAlive ].
                    ].

                "Set new cell in new board"
                (newGrid grid at: r) at: c put: newCell.
            ].
        ].

        "Replace the current grid with the new one"
        grid := newGrid grid.
    ]

    "Display the board"
    display [

        Transcript show: '\033[2J\033[H'.  "ANSI escape sequence to clear screen"
        Transcript show: '>>> Board Display Function Reached'; cr; flush.

        (self grid isNil) ifTrue: [
            Transcript show: '[ERROR] Grid is nil!'; cr; flush.
            ^ self.
        ].

        1 to: rows do: [ :r |
            1 to: cols do: [ :c |
                Transcript show: (self getCell: r column: c) display.
            ].
            Transcript cr; flush.
        ].

        (Delay forMilliseconds: 500) wait. "Pause for 500 milliseconds"
    ]
]
