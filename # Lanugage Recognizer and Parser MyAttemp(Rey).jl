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

# Variables Defined in the Global Scope..

# BNF is used to track working BNF string to be displayed on screen
BNF = nothing
# line count goes alongside BNF to show what line of decomposition we're at
line_count = 0
# max_width is used for parsetree printing
max_width = 0

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

function printparsetree(input)
    input = strip(input)
    component = "<LANG>"
    
    global max_width == length(component)
    parseLANG(input)
end

function parseLANG(input)
    component = "RUN <CMDS> QUIT"
    if global maxwidth < length(component)
        global maxwidth == length(component)
    end
    parseCMD(input)
end

function parseCMDS(input)
    component = "<CMDS>"
end

function parseCMD(input)

end


# Tree Structure for if we want to go that route
#=
struct TreeNode
    comp
    left::Union{TreeNode, Nothing}
    middle::Union{TreeNode,Nothing}
    right::Union{TreeNode,Nothing}
end

function TreeNode(input)
    return TreeNode(input, nothing, nothing, nothing)
end

function insert(root::Union{TreeNode, Nothing}, comp)
    if root === nothing
        return TreeNode(comp)
    end

    if global pos == "left"
        root.left = insert(root.left, comp)
    elseif global pos == "mid"
        root.middle = insert(root.middle, comp)
    elseif global pos == "right"
        root.right = insert(root.right, comp)
    else
        println("Don't know where to put (left, mid or right)")
    end

    return root
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
    input = ""

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
            global max_width = 0
            #PrintParse(input)
        end
    end
    println("\nExiting program..")
end

main()