# Simple goto/go back scripts

## Installation

 - Clone the repo `git clone https://github.com/FacuM/shellscripts`.
 - Run `bash install`.
 - Restart your shell or run `. ~/.bashrc`

## Usage
 
### goto

Go to another directory, then export the previous one in a variable.

`goto /path/to/another/directory`

### back

Go back to the previous directory. `back` will also loop your request if ran multiple times without issuing `goto` again.

`back`
