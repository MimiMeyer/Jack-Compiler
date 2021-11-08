# Tzipora Bamberon
# Mimi Meyer
function Tokens(filePath::String)
    filelist = readdir(filePath) #makes a list of the file names
    for i in filelist #going over the file names
        if occursin(".", i)#if contains dot
            arr::Array=split(i,".")#splliting by the dot
            if arr[2]=="jack" #checks if its a vm file
             nameOffile=string("our",arr[1],"T.xml")#xml file
             GoOverJack(i,filePath,nameOffile)
            end
           
        end
    end
end
function KeyWord(nameOffile::String,KW::String)#keyword token
    result=string("<keyword> ",KW ," </keyword>","\n")
    open(nameOffile,"a")do f2
        write(f2,result)
    end
end
function Identifier(nameOffile::String,i::String)#identifier token
    result=string("<identifier> ", i, " </identifier>","\n")
    open(nameOffile,"a")do f2
        write(f2,result)
    end
end
function StringConstant(nameOffile::String,stringC::String)#stringConstant token
    result=string("<stringConstant> ", stringC," </stringConstant>","\n")
    open(nameOffile,"a")do f2
        write(f2,result)
    end   
end
function IntegerConstant(nameOffile::String,intC::String)#integerConstant token
    result=string("<integerConstant> ", intC," </integerConstant>","\n")
    open(nameOffile,"a")do f2
        write(f2,result)
    end
end
function Symbol(nameOffile::String,s::String)#symbol token
    result=string("<symbol> ", s," </symbol>","\n")
    open(nameOffile,"a")do f2
        write(f2,result)
    end

end
function checkword(nameOffile::String,s::String)#checks word and sends to the right token
   
    if s=="~"|| s=="|"||s==";"||s==","||s=="."||s=="]"||s=="["||s==")"||s=="("||s=="/"||s=="}"||s=="{"||s=="-" ||s=="*"|| s=="="||s=="+"
        Symbol(nameOffile,s)#sends to symbol token
    elseif  s=="static"||s=="field"||s=="method"||s=="constructor"||s=="class"|| s=="function"|| s=="void"||s== "var"|| s=="int"||s== "let"||s=="this"||s=="null"|| s=="false"|| s=="true"||s=="boolean"||s=="char"|| s=="while"|| s=="do"|| s=="return"|| s=="if"|| s=="else"
        KeyWord(nameOffile,s)#sends to keyword token
    elseif  s=="<"#sends to symbol token
        Symbol(nameOffile,"&lt;")

    elseif  s==">"
        
        Symbol(nameOffile,"&gt;")#sends to symbol token

    elseif  s=="&"
      Symbol(nameOffile,"&amp;")#sends to symbol token

    elseif tryparse(Int,s)!=nothing&&0<=tryparse(Int,s)&&tryparse(Int,s)<=32767
      IntegerConstant(nameOffile,s)#sends to integerConstant token
    else
        Identifier(nameOffile,s)#sends to identifier token
    end
    
end

function GoOverJack(x::String,filePath::String,nameOffile::String)

    f1=open(filePath*"\\"*x) #opens jack file
    name=filePath*"\\"*nameOffile
    f2=open(name,"w")#open xml file to write too
    result= string("<tokens>","\n")
    open(name,"a")do f2
        write(f2,result)
    end
    for j in eachline(f1)#goes over each line in file
        if j!=""&&j!="\t"#not an empty line
            word::Array=split(j,"")#splits each line
            comment::Array=split(j)
            if !(isempty(comment))#not an empty line
                if comment[1]!="//"&& comment[1]!="*" && comment[1]!="/**" && comment[1]!="*/"#not a comment
                    i=1
                    x=true
                    result::String=""
                    if length(word)==1
                        checkword(name,String(word[i]))
                    end
                    while  i!=length(word)&& x#goes over line 
                        #if its not at the end of a word
                       
                        if word[i]!="\t"&& word[i]!=" "&& word[i]!=","&& word[i]!="."&& word[i]!="(" && word[i]!=")" && word[i]!="[" && word[i]!="]" && word[i]!="\"" && word[i]!=";"&& word[i]!="~"&& word[i]!="|"&&  word[i]!="/"&& word[i]!="}"&& word[i]!="{"&& word[i]!="-" && word[i]!="*"&&  word[i]!="="&& word[i]!="+"&&word[i]!="<"&&word[i]!=">"
                            result=result*word[i]#getting the next part of the word
                            if i!=length(word)#if not at the end of line
                                i=i+1
                            else i==length(word)
                                checkword(name,result)   
                                result=""
                                x=false#at the end of the line
                        
                            end
                        end
                        if word[i]==" "||word[i]=="\t"#end of word
                            if result!=""#if there was a word before
                                checkword(name,result)
                            end
                            i=i+1
                            result=""
                        
                        end
                        
                       if word[i]=="/"&& word[i+1]=="/"#checking for comments
                        if result!=""#if there was a word before
                            checkword(name,result)
                        end
                           x=false
                          
                       else
                            if word[i]==","|| word[i]=="."|| word[i]=="("|| word[i]==")"||word[i]=="["||word[i]=="]"|| word[i]==";"||word[i]=="~"|| word[i]=="|"||word[i]==";"||word[i]==","||word[i]=="."||word[i]=="]"||word[i]=="["||word[i]==")"||word[i]=="("||word[i]=="/"||word[i]=="}"||word[i]=="{"||word[i]=="-" ||word[i]=="*"|| word[i]=="="||word[i]=="+"||word[i]=="<"||word[i]==">"
                                if result!=""#if there was a word before
                                    checkword(name,result)
                                end
                                checkword(name,String(word[i]))#send the symbol
                                result=""
                                if i!=length(word)
                                i=i+1
                                if  i==length(word)&&(word[i]==","|| word[i]=="."|| word[i]=="("|| word[i]==")"||word[i]=="["||word[i]=="]"|| word[i]==";"||word[i]=="~"|| word[i]=="|"||word[i]==";"||word[i]==","||word[i]=="."||word[i]=="]"||word[i]=="["||word[i]==")"||word[i]=="("||word[i]=="/"||word[i]=="}"||word[i]=="{"||word[i]=="-" ||word[i]=="*"|| word[i]=="="||word[i]=="+"||word[i]=="<"||word[i]==">")
                                    checkword(name,String(word[i]))#send the symbol
                                end
                                else
                                    
                                    x=false#end of word
                                end
                            
                            end
                       end
                        if word[i]=="\""#for stringConstant
                            i=i+1
                            while word[i]!="\""
                                result=result*word[i]
                                i=i+1
                            end
                            StringConstant(name,result)
                            result=""
                            i=i+1
                        end
                        
                       
                    end 
                    
                end
            end
        end
    end
    result= string("</tokens>","\n")
    open(name,"a")do f2
        write(f2,result)
    end
end
function main()#going over project 10
    filePath="C:\\Users\\Hp\\Downloads\\Exercises\\Exercises\\Targil5\\project 11"
    filelist = readdir(filePath) #makes a list of the file names
    for i in filelist
        if isdir(filePath*"\\"*i)
          Tokens(filePath*"\\"*i)
        end
    end
end
main()
# Tokens("C:\\Users\\Hp\\Downloads\\Exercises\\Exercises\\Targil3 - TziporaAndMimi/")



