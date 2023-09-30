# Language Recognizer: Leftmost Derivation and Parser Program in Julia
**Due Date:** Monday Oct. 1st 2023 **BEFORE** 2:45 PM

Group Members: 
- Arthur Butler
- George Kotch
- Reynerio Samos
- Francisco Tun
- Cahlil Tillet

Resources : 
- [Julia Documentation](https://docs.julialang.org/en/v1/)
- [Geeks for Geeks: Julia string manipulation](https://www.geeksforgeeks.org/string-manipulation-in-julia/)

Project Files: 
- [Working Branch of Code on GitHub](https://github.com/ReynerioSamos/Language-Recognizer-and-Parser)
- [Google Document for Report](https://docs.google.com/document/d/1Z34kGi6K_qYZ40BChvjn9h25pJNla69RQ7_wkEx3pVE/edit)
- [Google Slide for Presentation](https://docs.google.com/presentation/d/19IWdbifIbKpmQcPXu6dAXGsEVy753vKEg_Z0pGt-qJg/edit#slide=id.g1e82dd15846_1_423)

Project Components:
- [Main Program Flow Chart](https://lucid.app/lucidchart/ff0dca1b-8c85-4707-82bc-0f31cbf6c182/edit?viewport_loc=-174%2C-749%2C2932%2C1729%2C0_0&invitationId=inv_3b62a08e-3b47-4d02-ba2b-a59255fe1521)

**ALL TO BE SUBMITTED AS A .ZIP BEFORE PRESENTATION @2:45 to**
dgarcia@ub.edubz
## Problem:
### A. Write a program for a LANGUAGE RECOGNIZER that will ONLY accept strings based on the following grammar: 
![[Pasted image 20230930161057.png]]

Example of accepted string:
- `RUN X = Y; IF Z = X THEN Y = Z QUIT`

### B. The program should execute a LEFTMOST derivation of the inputted string showing each sentential form and the final generated sentence. 
If the derivation cannot complete successfully - i.e. an error exists that the lexical and syntax checker detected - the program should generate an appropriate error message.

Examples:
- `Error: X = A contains an error – variable ‘A’ is not valid`
- `Error: Unrecognized variable ‘A’`
- `Error: Calculation operator ‘*’ is invalid`
## Solution
### A. Write a computer program that:
- Upon starting, display the BNF grammar for the language recognizer
- Accepts an input string
- Attempts a LEFTMOST derivation on the input string
	- If the derivation is not successful, it generates an appropriate error and then prompts for another string (loops)
	- If the derivation is successful, it indicates this, proceeds to draw the PARSE TREE for the input string, displays the tree, and then prompts for another string (loops)
- If the user enters “QUIT” when prompted for an input string, the program terminates.


## Program (43 Points)
### A. The program should comprise:
- A MAIN that displays the BNF grammar for the language recognizer and then prompts for an input string. If the input string is “QUIT”, the program terminates, else MAIN should call:
	- A subprogram that executes a LEFTMOST derivation of the input string, displaying each sentential form and the final generated sentence. The program should generate an appropriate error message if the derivation cannot complete successfully - i.e. the string is not recognized by the grammar.
		- Example : `Error: X = Y * Z - invalid operator'*'`
		- Example of Leftmost Derivations : ![[Pasted image 20230930161159.png]]
	- A subprogram that draws the PARSE TREE for the input string if the derivation is successful. ![[Pasted image 20230930161219.png]]
### B. The program should be written in the designated language: Julia

## Program Presentation:
### A. In class, your team will conduct a PowerPoint presentation of the program code and provide a brief overview/explanation of its logic. 
This part of your presentation should not be longer than three minutes
### B. Your team will then demonstrate the compilation and execution of the program (the lecturer will provide input strings)
Before the demo, the required compiler/interpreter must be installed on the computer used for the demonstration
### C. Your entire presentation will not last longer than 13 minutes. Practice before class since you will be graded on your timing. 
Come prepared since the clock starts when your team is called to present.

## Project Submission
The report document should be assembled with the cover page containing the signature block in a professional format and will comprise three sections:
### A. Descriptions and explanations for:
- the BNF grammar for the language recognizer with a brief description of what it represents
- the language used (flavor, version, compiler/interpreter, etc.)
- the program objectives, the program's process flow, and the program's main and subprograms.
### B. A concise but easily readable flow chart of the program. Be sure to check that you are using the correct symbols.

### C. The printed program code which contains appropriate comments and remarks for improved readability (important for grading).

Submit **BEFORE** start of class on the due date:
- Via Email;
- In a zip containing:
	- Report as PDF
	- PowerPoint Presentation
	- Program Code (This case: Julia .jl)

## GRADING CRITERIA
![[Pasted image 20230930153900.png]]