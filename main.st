FileStream fileIn: 'Cell.st'.
FileStream fileIn: 'Board.st'.

"Create the board and ask for file input"
| board fileName generations |

"Prompt user for configuration file name"
Transcript show: 'Enter the configuration file name: '; flush.
fileName := (FileStream stdin nextLine) asString.

"Initialize board and load configuration"
board := Board new: 30 with: 30.
board readConfigFile: fileName.

board display.

"Retrieve number of generations from file"
generations := board getGenerations.

"Run the Game of Life simulation"
1 to: generations do: [ :i |
    board computeNextGeneration.
    board display.
].

Transcript show: 'Simulation complete!'; cr.
