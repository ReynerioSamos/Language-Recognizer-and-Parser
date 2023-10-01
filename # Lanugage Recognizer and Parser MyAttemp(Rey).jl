# Lanugage Recognizer and Parser Redo
# Coded in Julia 1.9.3
# Julia Compiler based on LLVM Compiler Infrastructure : https://llvm.org/

# "BNF Grammar for the Language Recognizer:"
# "<LANG> ::= RUN <CMDS> QUIT"
# "<CMDS> ::= <CMD> | <CMD> ; <CMDS>"
# "<CMD> ::= <IF> | <EXP> | <CALC>"
# "<IF> ::= IF <EXP> THEN <CMDS>"
# "<EXP> ::= <VAR> | <VAR> = <VAR>"
# "<CALC> ::= <VAR> + <VAR> | <VAR> - <VAR>"
# "<VAR> ::= X | Y | Z"

# Example Instruction Set :
# RUN X = Y; IF Z = X THEN Y = Z QUIT

# Defined in the Global Scope..

BNF = nothing
line_count = 0

#---------------------------------------------------------------------------------------------------------
# Functions Prototypes

#PrintBNF() Program to print the Initial BNF Grammar (Done incase we want to recall)
function PrintGram()
    println("BNF Grammar for the Language Recognizer:")
    println("<LANG> ::=  RUN <CMDS> QUIT")
    println("<CMDS> ::=  <CMD> | <CMD> ; <CMDS>")
    println("<CMD>  ::=  <IF> | <EXP> | <CALC>")
    println("<IF>   ::=   IF <EXP> THEN <CMDS>")
    println("<EXP>  ::=  <VAR> | <VAR> = <VAR>")
    println("<CALC> ::=  <VAR> + <VAR> | <VAR> - <VAR>")
    println("<VAR>  ::=  X | Y | Z")
end

#leftderiv is a boolean function to determine whether parse tree is drawn or not
function leftderiv(input)
    println("\nDeriving: [$input]...")
    if LANG(input) == true
        return true
    else
        return false
    end
end

function LANG(input)
    input = strip(input)
    if startswith(input, "RUN") & endswith(input, "QUIT")
        global line_count +=1
        global BNF = " <LANG>   -> RUN <CMDS> QUIT"
        println(line_count," ",BNF)
        input = strip(input[3:end-4])
        CMDS(input)
        return true
    else
        println("Error: $input , invalid sentence")
        return false
    end
end

function CMDS(input)
    input = strip(input)
    if count(i->(i==';'),input)==0
        global line_count +=1
        global BNF = replace(BNF,"<LANG>"=>"      ",count=1)
        global BNF = replace(BNF,"<CMDS>"=>"<CMD>",count=1)
        println(line_count," ",BNF)
        # CMD(input)
    elseif count(i->(i==';'),input)>=1
        global line_count +=1
        global BNF = replace(BNF,"<LANG>"=>"      ",count=1)
        global BNF = replace(BNF,"<CMDS>"=>"<CMD> ; <CMDS>",count=1)
        println(line_count," ",BNF)
        #= block for spliting commands
        pair_of_input = split(input,";";2)
        CMD(pair_of_input[1])
        CMDS(pair_of_input[2])
        =#
    end
end

function CMD(input)
    if startswith(input,"IF")
    end
end
#=
# <LANG> -> Should recognize if sentence is accepted into language (Starts with Run and Ends with Quit)
function LANG(input)
    input = strip(input)
    if startswith(input, "RUN") && endswith(input, "QUIT")
        return true
    else
        return false
    end
end

# <CMDS> -> Should recognize if it's either one <CMD> or <CMD> ; <CMDS>
function CMDS(str)
#prints BNF at this point (Used for compounding instruction sets)
    println("        ->$BNF")
# conditional check to see if ';' character is in currently working string, if not then <CMD> only is called
# if  more than 1 then BNF
    if count(i->(i==';'), str) == 0
        BNF = replace(global BNF, "<CMDS>" => "<CMD>", 1)
        println("         ->$BNF")
        CMD(global curr_str)
    elseif count(i->(i==';'), input) >= 1
        global BNF = global BNF*" ; <CMDS>"
        println("         ->$BNF")
        pair_of_string = split(global curr_str,";";2)
        global curr_str = pair_of_string[1]
        global right_str = pair_of_string[2]
        CMDS(global right_str[])
    else
        error("Invalid input at [$str], not valid Command Set")
        println("Unsuccessful, Exiting derivation...")
    end
end
# <CMD> -> should recognize if its an if-then statememnt, expressional statememnt or calculation statememnt
function CMD(str)
    str = strip(str)
    println("        ->$BNF")
    if startswith(str,"IF") && contains(str,"THEN")
        global BNF = replace(global BNF, "<CMD>", "IF <EXP> THEN <CMDS>", 1)
        IF_THEN(str)
    elseif startswith(str, "IF")
        error("Starts with IF Conditional block but no single THEN execution block detected")
        println("Detected at $str")
        println("Unsuccessful, Exiting derivation")
    elseif contains(str,"+") || contains(str, "-")
        global BNF = replace(global BNF, "<CMD>", "<CALC>", 1)
        CALC(str)
    elseif contains(str,"=")
        global BNF = replace(global BNF, "<CMD>", "<CALC>", 1)
        EXP(str)
    else
        error("Invalid input at $str, not valid Command")
        println("Unsuccessful, Exiting Derivation...")
    end
end
# <IF> -> Should recognize if valid if then statmenet (If <EXP> then <CMD>)
function IF_THEN(str)
    println("         ->$BNF")
    pair_of_string = split(str,"THEN";2)
    pair_of_string[1] = replace(pair_of_string[1],"IF ","")
    pair_of_string[1] = strip(pair_of_string[1])
    EXP(pair_of_string[1])
    pair_of_string[2] = strip(pair_of_string[2])
    CMDS(pair_of_string[2])
end
# <EXP> -> Should recognize if valid expresion statment (<VAR> or <VAR> = <VAR>)
function EXP(str)
    str = strip(str)
        if count(i->i->(i=="="),str) == 0
            global BNF = replace(global BNF, "<CMD>", "<VAR>", 1)
            println("         ->$BNF")
            VAR(str)
        elseif count(i->(i=='='), str) == 1
            global BNF = replace(global BNF, "<CMD>", "<VAR> = <VAR>", 1)
            println("         ->$BNF")
            pair_of_string = split(str,"=";2)
            pair_of_string[1] = strip(pair_of_string[1])
            left_var = VAR(pair_of_string[1])
            pair_of_string[2] = strip(pair_of_string[2])
            right_var = VAR(pair_of_string[2])
            global BNF = replace(global BNF, "<VAR>", "$left_var")
            println("        ->$BNF")
            global BNF = replace(global BNF, "<VAR>", "$right_var")
        else
            error("Invalid input at $str, not valid expression")
            println("Unsuccessful, Exiting Derivation")
        end
end
# <CALC> -> Shoudl recognize if valid calculation statememnt (<VAR> + <VAR> OR <VAR> - <VAR>)
function CALC(str)
    if contains(str,"+")
        global BNF = replace(global BNF,"<CALC>","<VAR> - <VAR>", 1)
        println("        ->$BNF")
        pair_of_string = split(str,"+";2)
        pair_of_string[1] = strip(pair_of_string[1])
        left_var = VAR(pair_of_string[1])
        pair_of_string[2] = strip(pair_of_string[2])
        right_var = VAR(pair_of_string[2])
        global BNF = replace(global BNF, "<VAR>", "$left_var", 1)
        println("       ->$BNF")
        global BNF = replace(global BNF, "<VAR>", "$right_var", 1)
        println("        ->$BNF")
    elseif contains(str,"-")
        global BNF = replace(global BNF,"<CALC>","<VAR> - <VAR>", 1)
        println("        ->$BNF")
        pair_of_string = split(str,"-";2)
        pair_of_string[1] = strip(pair_of_string[1])
        left_var = VAR(pair_of_string[1])
        pair_of_string[2] = strip(pair_of_string[2])
        right_var = VAR(pair_of_string[2])
        global BNF = replace(global BNF, "<VAR>", "$left_var", 1)
        println("       ->$BNF")
        global BNF = replace(global BNF, "<VAR>", "$right_var", 1)
        println("        ->$BNF")
    else
        error("Invalid input at $str, no valid calculation operator")
        # compounding replace() function call to replace all X Y OR Z with blank spaces to try to find invalid operator 
        str = replace(replace(replace(str,"X"=>""),"Y"=>""),"Z"=>"")
        str = strip(str)
        println("$str is an invalid operator")
    end
end
    
# <VAR> -> Should recognize if valid variable is used (X, Y OR Z)
function VAR(str)
    if contains(str,"X")
        return "X"
    elseif contains(str,"Y")
        return "Y"
    elseif contains(str,"Z")
        return "Z"
    else
        error("Invalid input at $str, no valid variable found")
        str = replace(replace(replace(str,"X"=>""),"Y"=>""),"Z"=>"")
        str = replace(replace(str,"+"=>""),"-"=>"")
        str = strip(str)
        println("$str is an invalid variable")
        return str
    end
end
=#
#---------------------------------------------------------------------------------------------------------
#Main Prototype 
function main()
    # Cheeky println to display version ("Couldn't find a more verbose way")
    println("Julia Version ", VERSION)
    println("/-------------------------/\n")

    # print Function to display BNF
    PrintGram()
    println("\nYou can type QUIT as input to exit.")
    input = " "

    # while loop to keep asking for string to be derived and parsed
    while input != "QUIT"
        # reinitializing line_count and BNF for next derivation
        global line_count = 0
        global BNF = nothing
        
        # asking user for string and stripping possible leading and ending whitespace
        println("\nPlease enter a input string to begin :")
        input = readline()
        if input == "QUIT"
            break
        end
        input = strip(input)
        
        # if leftmost derivation returns true, parse tree is generated
        if leftderiv(input) == true
            println("\nPrinting Parse tree for [$input]...")
            #PrintParse(input)
        end
    end
    println("\nExiting program..")
end

# Old Main, used here as reference
#=
# boolean check if input is recognized in language grammar def
    while LANG(input) == false && input != "QUIT"
    println("Invalid Syntax, please re-enter CMD(s) or type QUIT: ")
    input = readline()
    end

# Successful Program Start
    if LANG(input) == true
    #Stripping input string of RUN and QUIT for derivation
    global input = strip(global input[3:end-4])
    println("Deriving and Parsing Instruction set [$input]...")
    #stripping of leading and ending whitespaces

    global input = strip(global input)
    # setting BNF to RUN <CMDS> QUIT as every instruction set derives from this
    global BNF = "RUN <CMDS> QUIT"
    # printing begining of derivation
    println("<LANG>  ->$BNF")
    # stripping BNF of RUN and QUIT and white space before and after to make derivation easier
    global BNF = strip(BNF[3:end-4])
    global BNF = strip(BNF)
    CMDS(curr_str)
    end
end
=#

main()