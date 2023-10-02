# Lanugage Recognizer and Parser for Group 3
# CMPS 3111 - Programming Languages
# 2023-10-02

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

# LANG() function - determines if valid RUN <CMDS> QUIT if starts with RUN and endwith QUIT
function LANG(input)
    input = strip(input)
    if startswith(input, "RUN") & endswith(input, "QUIT")
        # this block occurs everytime the BNF derivation is updated
        # 1) updates line count by 1, updates BNF based on appropriate composition 3) prints current BNF pos
        global line_count +=1
        global BNF = " <LANG>   -> RUN <CMDS> QUIT"
        println(line_count," ",BNF)
        input = replace(input,"RUN"=>"")
        input = replace(input,"QUIT"=>"")
        input = strip(input)
        CMDS(input)
    else
        # for all functions, if the bools return false meaning derivation didnt happen, prints approriate error message and substring where error occured
        println("Error: [$input] Invalid <LANG> Sentence")
        return false
    end
end
# CMDS() function - derives based on if a ';' is present, if none only calls <CMD> if there is >1 then calls left substring <CMD> and remaining substring <CMDS>
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
        if CMD(left) == true && CMDS(right) == true
            return true
        else
            return false
        end
    else
        println("Error: [$input] Invalid <CMDS> Set")
        return false
    end
end

# CMD() function - derives based on pattern matching of whether its an <IF>, <CALC> or <EXP> syntax statememnt and updates BNF and calls functions accordingly
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

    #two cases for EXP as an EXP can be just a <VAR> by itself
    elseif contains(input,'=')
        global line_count+=1
        global BNF = replace(BNF,"<CMD>"=>"<EXP>",count=1)
        println(line_count," ",BNF)
        EXP(input)
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
    else
        println("Error: [$input] Invalid <CMD>, not recognized.")
        return false
    end
end

# IF() function - pattern match done in <CMD> so now it's only worried about THEN substring, if the IF portion makes it through without THEN block it prints accoding error
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
        if EXP(left) == true && CMDS(right) == true
            return true
        else
            return false
        end
    else
        println("Error: [$input] Invalid <IF> Statement, no THEN block")
        return false
    end
end

# CALC() function - derives based on if valid operators [+,-] are present, if not, strips substring to only operator to display in error
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
        if VAR(left) == true && VAR(right) == true
            return true
        else
            return false
        end
    elseif contains(input, '-')
        global line_count+=1
        global BNF = replace(BNF,"<CALC>"=>"<VAR> - <VAR>",count=1)
        println(line_count," ",BNF)
        # block for splitting <CALC> into two <VAR> calls
        pair_of_input = split(input, '-', limit=2)
        left = pair_of_input[1]
        right = pair_of_input[2]
        if VAR(left) == true && VAR(right) == true
            return true
        else
            return false
        end
    else
        println("Error: [$input] Invalid <CALC> Statement")
        # kinda brute force but the operator (assuming its a single char) should be at index 3 of array string
        char = input[3]
        println("'$char' is not a valid calculation operator")
        return false
    end
end

# EXP() Function - only derives in <VAR> = <VAR> portion of program since <VAR> portion is detected in <CMD> and accounted for
function EXP(input)
    input = strip(input)
    global line_count+=1
    global BNF = replace(BNF,"<EXP>"=>"<VAR> = <VAR>",count=1)
     println(line_count," ",BNF)
    pair_of_input = split(input,'=',limit=2)
    left = pair_of_input[1]
    right = pair_of_input[2]
    if VAR(left) == true && VAR(right) == true
        return true
    else
        return false
    end
end

#function VAR() - checks if substring or in this case var is a valid recognized variable and replaces in BNF accordingly
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

#const variables for denoting which direct tree goes
const left = "/"
const mid = "|"
const right = "\\"
const w_unit = 6
const single_space = " "

function PrintParse(input)
    component = "<LANG>"
    input = strip(input)
    global max_width = 8
    half_max = div(max_width,2)
    left_space = single_space^Int(half_max*w_unit)
    right_space = single_space^Int(half_max*w_unit)
    mid_component = single_space^div(length(component),2)*mid*single_space^div(length(component),2)
    println(left_space,component,right_space)
    println(left_space,mid_component,right_space)
    parseLANG(input)
end



function parseLANG(input)
    component = "RUN <CMDS> QUIT"
    mid_component = single_space^div(length(component),2)*mid*single_space^div(length(component),2)
    input = replace(input,"RUN"=>"")
    input = replace(input,"QUIT"=>"")
    input = strip(input)
    half_max = div(max_width,2)
    left_space = single_space^Int(half_max*w_unit)
    right_space = single_space^Int(half_max*w_unit)
    println(left_space,component,right_space)
    println(left_space, mid_component,right_space)
    global max_width += 2
    parseCMDS(input)
end

function parseCMDS(input)
    if count(i->(i==';'),input) == 0
        component = "<CMD>"
        mid_component = single_space^div(length(component),2)*mid*single_space^div(length(component),2)
        half_max = div(max_width,2)
        left_space = single_space^Int(half_max*w_unit)
        right_space = single_space^Int(half_max*w_unit)
        println(left_space,component,right_space)
        println(left_space, mid_component,right_space)
        #parseCMD(input)
    elseif count(i->(i==';'),input) >= 1
        component = "<CMD> ; <CMDS>"
        
        # mid component here becomes a left, and right sub-component
        left_sub_comp = "<CMD>"
        left_mid_comp = single_space^div(length(left_sub_comp),2)*left*single_space^div(length(left_sub_comp),2)
        right_sub_comp = "<CMDS>"
        right_mid_comp = single_space^div(length(right_sub_comp),2)*right*single_space^div(length(right_sub_comp),2)
        half_max = div(max_width,2)
        left_space = single_space^Int(half_max*w_unit)
        right_space = single_space^Int(half_max*w_unit)
        println(left_space,left_mid_comp,right_mid_comp,right_space)
        println(left_space,component,right_space)
        pair_of_input = split(input,';',limit=2)
        left_inp = pair_of_input[1]
        right_inp = pair_of_input[2]
        global max_width += 2
        #parseCMD(left_inp)
        #parseCMDS(right_inp)
    end
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
            println("Successful derivation!")
            println("\nPrinting Parse tree for [$input]...\n")
            global max_width = 0
            PrintParse(input)
        end
    end
    println("\nExiting program..")
end

main()