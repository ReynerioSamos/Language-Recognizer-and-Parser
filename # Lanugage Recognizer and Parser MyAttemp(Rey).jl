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

#leftderiv() function - is a boolean function to determine whether parse tree is drawn or not
function leftderiv(input)
    println("\nDeriving: [$input]...")
    if LANG(input) == true
        return true
    else
        return false
    end
end

# LANG() function - 
function LANG(input)
    input = strip(input)
    if startswith(input, "RUN") & endswith(input, "QUIT")
        global line_count +=1
        global BNF = " <LANG>   -> RUN <CMDS> QUIT"
        println(line_count," ",BNF)
        input = replace(input,"RUN"=>"")
        input = replace(input,"QUIT"=>"")
        input = strip(input)
        CMDS(input)
    else
        println("Error: [$input] Invalid <LANG> Sentence")
        return false
    end
end
# CMDS() function -
function CMDS(input)
    input = strip(input)
    if count(i->(i==';'),input)==0
        global line_count +=1
        global BNF = replace(BNF,"<LANG>"=>"      ",count=1)
        global BNF = replace(BNF,"<CMDS>"=>"<CMD>",count=1)
        println(line_count," ",BNF)
        CMD(input)
    elseif count(i->(i==';'),input)>=1
        global line_count +=1
        global BNF = replace(BNF,"<LANG>"=>"      ",count=1)
        global BNF = replace(BNF,"<CMDS>"=>"<CMD> ; <CMDS>",count=1)
        println(line_count," ",BNF)
        # block for spliting CMDS to go to CMD and then recursive call into CMDS
        pair_of_input = split(input,';',limit=2)
        left = pair_of_input[1]
        right = pair_of_input[2]
        CMD(left)
        CMDS(right)
    else
        println("Error: [$input] Invalid <CMDS> Set")
        return false
    end
end

# CMD() function -
function CMD(input)
    input = strip(input)
    # conditional block to determine if <IF> Statement
    if contains(input,"IF")
        global line_count+=1
        global BNF = replace(BNF,"<CMD>"=>"<IF>",count=1)
        println(line_count," ",BNF)
        IF(input)

    # conditional block to determine <CALC> Statement
    elseif contains(input,'+') | contains(input,'-') | contains(input,'*') | contains(input,'/') | contains(input,'^') | contains(input,'%')
        global line_count+=1
        global BNF = replace(BNF,"<CMD>"=>"<CALC>",count=1)
        println(line_count," ",BNF)
        CALC(input)
        return true

    #two cases for EXP as an EXP can be just a <VAR> by itself
    elseif contains(input,'=')
        global line_count+=1
        global BNF = replace(BNF,"<CMD>"=>"<EXP>",count=1)
        println(line_count," ",BNF)
        EXP(input)
        return true
    # conditional block to determine if <EXP> is just a single <VAR>
    elseif input == "X" || input == "Y" || input == "Z"
        global line_count+=1
        global BNF = replace(BNF,"<CMD>"=>"<EXP>",count=1)
        println(line_count," ",BNF)
        # does it a 2nd time since we're skipping <EXP> function call in this instance
        # Done this way because realtalks, idk how it would pattern match a var from within an <EXP> and not just go straight to <VAR>
        global line_count+=1
        global BNF = replace(BNF,"<EXP>"=>"<VAR>",count=1)
        println(line_count," ",BNF)
        VAR(input)
        return true
    else
        println("Error: [$input] Invalid <CMD>, not recognized.")
        return false
    end
end


function IF(input)
    if contains(input,"THEN")
        global line_count+=1
        global BNF = replace(BNF,"<IF>"=>"IF <EXP> THEN <CMDS>",count=1)
        println(line_count," ",BNF)
        # block for spliting CMD to <EXP> and call back <CMDS>
        pair_of_input = split(input,"THEN",limit=2)
        left = pair_of_input[1]
        # need to get rid of IF from input
        left = replace(left,"IF"=>"",count=1)
        right = pair_of_input[2]
        EXP(left)
        CMDS(right)
        return true
    else
        println("Error: [$input] Invalid <IF> Statement, no THEN block")
        return false
    end
end

function CALC(input)
    input = strip(input)
    if contains(input,'+')
        global line_count+=1
        global BNF = replace(BNF,"<CALC>"=>"<VAR> + <VAR>",count=1)
        println(line_count," ",BNF)
        # block for splitting <CALC> into two <VAR> calls
        pair_of_input = split(input, '+', limit=2)
        left = pair_of_input[1]
        right = pair_of_input[2]
        VAR(left)
        VAR(right)
        return true
    elseif contains(input, '-')
        global line_count+=1
        global BNF = replace(BNF,"<CALC>"=>"<VAR> - <VAR>",count=1)
        println(line_count," ",BNF)
        # block for splitting <CALC> into two <VAR> calls
        pair_of_input = split(input, '-', limit=2)
        left = pair_of_input[1]
        right = pair_of_input[2]
        VAR(left)
        VAR(right)
        return true
    else
        println("Error: [$input] Invalid <CALC> Statement")
        # kinda brute force but the operator (assuming its a single char) should be at index 3 of array string
        char = input[3]
        println("'$char' is not a valid calculation operator")
        return false
    end
end

# EXP() Function - only derives in <VAR> = <VAR> portion of program since 
function EXP(input)
    input = strip(input)
    global line_count+=1
    global BNF = replace(BNF,"<EXP>"=>"<VAR> = <VAR>",count=1)
     println(line_count," ",BNF)
    pair_of_input = split(input,'=',limit=2)
    left = pair_of_input[1]
    right = pair_of_input[2]
    VAR(left)
    VAR(right)
    return true
end

#function VAR() - 
function VAR(input)
    input = strip(input)
    if input == "X"
        global line_count+=1
        global BNF = replace(BNF,"<VAR>"=>"X",count=1)
        println(line_count," ",BNF)
        return true
    elseif input == "Y"
        global line_count+=1
        global BNF = replace(BNF,"<VAR>"=>"Y",count=1)
        println(line_count," ",BNF)
        return true
    elseif input == "Z"
        global line_count+=1
        global BNF = replace(BNF,"<VAR>"=>"Z",count=1)
        println(line_count," ",BNF)
        return true
    else
        println("Error: [$input] Invalid <VAR>")
        return false
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