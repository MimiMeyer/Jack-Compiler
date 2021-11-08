using Base: Char

# Tzipora Bamberon
# Mimi Meyer
operators = ["+", "-", "*", "/", "&", "|", "<", ">", "=", "&lt;", "&gt;", "&quot;", "&amp;"]
unaryOperators = ["~", "-"]


function VmWriter(filePath::String)#going over the files and sending to GoOverXML
    filelist = readdir(filePath) #makes a list of the file names
    for i in filelist #going over the file names
        if occursin("T.xml", i)&& occursin("our", i)#if containts T.xml  and our
        # if occursin("ourBallT.xml", i)
        arr::Array=split(i,"T")#splliting by the T
        name::Array=split(arr[1],"our")
        nameOffile=string(name[2],".vm")#xml file
         GoOverXML(i,filePath,nameOffile)
        end
    
    end
end
function ProgramStructure(i::Int64, filePath::String, list::Array{String,1},className::SubString{String},count_static::Int64,count_field::Int64,class_Scope::Dict{Any,Any},num_of_locals::Dict{Any,Any} )
    if i<length(list)
     if occursin("field", list[i])||occursin("static", list[i])
      
         classVarDec(i,filePath, list,className,count_static,count_field,class_Scope,num_of_locals)
      end
        if occursin("constructor", list[i])||occursin("method", list[i])||occursin("function", list[i])
            
            subRoutineDec(i,filePath, list,className,num_of_locals,class_Scope)
            i=i+1
            while i<length(list)&&!occursin("constructor", list[i]) && !occursin("method", list[i])&& !occursin("function", list[i])
                i=i+1
            end
            
            ProgramStructure(i,filePath,list,className,count_static,count_field,class_Scope,num_of_locals)
              
                
        end 
     
       
    end
  
end
  
  

function classVarDec(i::Int64, filePath::String, list::Array{String,1},className::SubString{String},count_static::Int64,count_field::Int64,class_Scope::Dict{Any,Any},num_of_locals::Dict{Any,Any})
  if i<length(list)#not at the end of the list
        while ! occursin(";", list[i])
            kind_array= split(list[i])#   static or field
            kind=kind_array[2]
            type_array= split(list[i+1])#   type of 
            type=type_array[2]
            
            name_array= split(list[i+2])#   name of varible
            name=name_array[2]
       
            if kind=="static"
                push!(class_Scope,name=>[type,kind,count_static])
            
                count_static+=1
            else
                
                push!(class_Scope,name=>[type,kind,count_field])
                count_field+=1
            end

            i=i+3
            help=true
            while help
                if occursin(",",list[i])
                    i=i+1
                    name_array= split(list[i])#   name of varible
                    name=name_array[2]
                    if kind=="static"
                        push!(class_Scope,name=>[type,kind,count_static])
                
                        count_static+=1
                        
                    else
                        
                        push!(class_Scope,name=>[type,kind,count_field])
                        count_field+=1
                        
                    end 
                    i=i+1
                else
                    help=false
                end
            end 
            
        end
       
        i=i+1
        ProgramStructure(i, filePath, list,className,count_static,count_field,class_Scope,num_of_locals)
    end
end

function subRoutineDec(i::Int64, filePath::String, list::Array{String,1},className::SubString{String},num_of_locals::Dict{Any,Any},class_Scope::Dict{Any,Any})
    count_argument=0
    count_var=0 
    method_Scope=Dict()
    
    if i<length(list)#not at the end of the list
        while !occursin("(",list[i])
           
            i=i+1
        end
       
        i=i+1
        ParameterList(i,filePath,list,method_Scope,num_of_locals,count_var,count_argument,className,class_Scope)#sending to parameterList
      

    end
end

function SubRoutineBody(i::Int64, filePath::String, list::Array{String,1},method_Scope::Dict{Any,Any},num_of_locals::Dict{Any,Any},count_var::Int64,count_argument::Int64,func_name::SubString{String},type_of_method::SubString{String},className::SubString{String},class_Scope::Dict{Any,Any})
    if i<length(list)#not at the end of the list
        if occursin("{",list[i])
           
            i=i+1
        end
        if !(haskey(num_of_locals,func_name))# if the doesnt exits then create new key
            push!(num_of_locals,func_name=>count_var)
        end
        if occursin("var",list[i]) # if there is vardec
            
           VarDec(i,filePath,list,method_Scope,num_of_locals,count_var,count_argument,func_name,type_of_method,className,class_Scope)
         
        else 
            num=num_of_locals[func_name]
            result=string("function"," ",className,".",func_name," ",num,"\n")
            open(filePath,"a")do f2
                write(f2,result)
            end
            count=0
            for (i, j) in class_Scope
                if j[2]=="field"
                    count+=1
                end
            end
                
            
            if type_of_method=="constructor"
                result=string("push constant ",count,"\n","call Memory.alloc 1","\n","pop pointer 0","\n")
                open(filePath,"a")do f2
                    write(f2,result)
                end
            end
            if type_of_method=="method"
                result=string("push argument 0","\n","pop pointer 0","\n")
                open(filePath,"a")do f2
                    write(f2,result)
                end
                
            end
            Statement(i,filePath,list,class_Scope,method_Scope,num_of_locals,className)#send to Statement
           
    
        end
    end
      
end
function VarDec(i::Int64, filePath::String, list::Array{String,1},method_Scope::Dict{Any,Any},num_of_locals::Dict{Any,Any},count_var::Int64,count_argument::Int64,func_name::SubString{String},type_of_method::SubString{String},className::SubString{String},class_Scope::Dict{Any,Any})
    if i<length(list)#not at the end of the list
      while ! occursin(";", list[i])
   
        kind_array= split(list[i])#   var
        kind=kind_array[2]
        type_array= split(list[i+1])#   type of 
        type=type_array[2]
        
        name_array= split(list[i+2])#   name of varible
        name=name_array[2]

        push!(method_Scope,name=>[type,kind,count_var])
    
        count_var+=1

        i=i+3
        help=true
        while help
            if occursin(",",list[i])
                i=i+1
                name_array= split(list[i])#   name of varible
                name=name_array[2]
                push!(method_Scope,name=>[type,kind,count_var])
                count_var+=1
                i=i+1
            else
                help=false
            end
        end 
      end
  
     i=i+1
     
     num_of_locals[func_name]=count_var# putting in the new number of locals into the key
     

     SubRoutineBody(i,filePath,list,method_Scope,num_of_locals,count_var,count_argument,func_name,type_of_method,className,class_Scope)#send to subroutineBody
  
  
    end
end
function ParameterList(i::Int64, filePath::String, list::Array{String,1},method_Scope::Dict{Any,Any},num_of_locals::Dict{Any,Any},count_var::Int64,count_argument::Int64,className::SubString{String},class_Scope::Dict{Any,Any})
  
    if i<length(list)#not at the end of the list
    if occursin("method",list[i-4])
      push!(method_Scope,"this"=>[className,"argument",count_argument])
      count_argument+=1
    end
    func_arr=split(list[i-2])
    func_method=split(list[i-4])
    func_Name=func_arr[2] # name of function
    type_of_method=func_method[2]
    while !occursin(")",list[i])
        type_array= split(list[i])#   type of 
        type=type_array[2]
        name_array= split(list[i+1])#   name of varible
        name=name_array[2]
        
        push!(method_Scope,name=>[type,"argument",count_argument])
        count_argument+=1
        i=i+2
        if occursin(",",list[i])
            i=i+1
        end
    end 
   
    i=i+1
    SubRoutineBody(i,filePath,list,method_Scope,num_of_locals,count_var,count_argument,func_Name,type_of_method,className,class_Scope)
   

 end
end




function Statement(i::Int64, filePath::String, list::Array{String,1},class_Scope::Dict{Any,Any},method_Scope::Dict{Any,Any},num_of_locals::Dict{Any,Any},className::SubString{String})
    if i<length(list)#not at the end of the list
       if occursin("let", list[i])
         LetStatement(i,filePath, list,class_Scope,method_Scope,num_of_locals,className)
      end
       if occursin("if", list[i])
          IfStatement(i,filePath,list,class_Scope,method_Scope,num_of_locals,className)
       end
       if occursin("while", list[i])
            WhileStatement(i,filePath, list,class_Scope,method_Scope,num_of_locals,className) 
       end
       if occursin("do", list[i])
         DoStatement(i,filePath, list,class_Scope,method_Scope,num_of_locals,className)
          
        end

       if occursin("return", list[i])
            
        ReturnStatement(i,filePath, list,class_Scope,method_Scope,num_of_locals,className)
            
       end
       
    end


end
function ExpressionList(i::Int64, filePath::String, list::Array,class_Scope::Dict{Any,Any},method_Scope::Dict{Any,Any},num_of_locals::Dict{Any,Any},call_name::String,call::String,type::String,num::Int64,Condition::String,className::SubString{String}) 
    if i<length(list)#not at the end of the list
    help=false
    num_of_paramaters=0
        if !occursin(")",list[i])
            num_of_paramaters+=1
              
            Expression(i,filePath,list,class_Scope,method_Scope,num_of_locals,className,className)
            if occursin("(",list[i])
                i=i+1 #(
                count=1
                while count!=0
                    if occursin("(",list[i])
                        count+=1
                    end
                    if occursin(")",list[i])
                        count-=1
                        if count==0
                            i=i-1
                        end
                    end
                    i=i+1
                end
                 
            end
            i=i+1  
            if split(list[i])[2] in operators
                while split(list[i])[2] in operators
                    i=i+1
                    if occursin("[",list[i+1])
                        i=i+2 #varName[
                        count=1
                        while count!=0
                            if occursin("[",list[i])
                                count+=1
                            end
                            if occursin("]",list[i])
                                count-=1
                                if count==0
                                    i=i-1
                                end
                            end
                            i=i+1
                        end
                        i+=1
                    elseif occursin("(",list[i])
                        i=i+1 #(
                        count=1
                        while count!=0
                            if occursin("(",list[i])
                                count+=1
                            end
                            if occursin(")",list[i])
                                count-=1
                                if count==0
                                    i=i-1
                                end
                            end
                            i=i+1
                        end
                        i+=1
                    elseif occursin("(",list[i+1])||occursin(".",list[i+1])
                        if occursin(".",list[i+1])  
                            i+2
                        else
                            i=i+1
                        end
                        count=1
                        while count!=0
                            if occursin("(",list[i])
                                count+=1
                            end
                            if occursin(")",list[i])
                                count-=1
                                if count==0
                                    i=i-1
                                end
                            end
                            i=i+1
                        end
                        i+=1
                
                    else
                        i=i+1
                    end
                
                end
            
            end
            while (occursin(",",list[i]))
                num_of_paramaters+=1
                i+=1
                Expression(i,filePath,list,class_Scope,method_Scope,num_of_locals,className,className)
                if occursin("(",list[i])
                    i=i+1 #(
                    count=1
                    while count!=0
                        if occursin("(",list[i])
                            count+=1
                        end
                        if occursin(")",list[i])
                            count-=1
                            if count==0
                                i=i-1
                            end
                        end
                        i=i+1
                    end
                     
                end   
                i=i+1
                if split(list[i])[2] in operators
                    while split(list[i])[2] in operators
                        i=i+1
                        if occursin("[",list[i+1])
                            i=i+2 #varName[
                            count=1
                            while count!=0
                                if occursin("[",list[i])
                                    count+=1
                                end
                                if occursin("]",list[i])
                                    count-=1
                                    if count==0
                                        i=i-1
                                    end
                                end
                                i=i+1
                            end
                            i+=1
                        elseif occursin("(",list[i])
                            i=i+1 #(
                            count=1
                            while count!=0
                                if occursin("(",list[i])
                                    count+=1
                                end
                                if occursin(")",list[i])
                                    count-=1
                                    if count==0
                                        i=i-1
                                    end
                                end
                                i=i+1
                            end
                            i+=1
                        elseif occursin("(",list[i+1])||occursin(".",list[i+1])
                            if occursin(".",list[i+1])  
                                i+2
                            else
                                i=i+1
                            end
                            count=1
                            while count!=0
                                if occursin("(",list[i])
                                    count+=1
                                end
                                if occursin(")",list[i])
                                    count-=1
                                    if count==0
                                        i=i-1
                                    end
                                end
                                i=i+1
                            end
                            i+=1
                    
                        else
                            i=i+1
                        end
                    
                    end
                
               end
              
            end
       
        end
        
        if call=="method"

            num_of_paramaters+=1
            result=string("call ",call_name," ",num_of_paramaters,"\n") 
        
        else
        result=string("call ",call_name," ",num_of_paramaters,"\n") 
            
        end
        open(filePath,"a")do f2
            write(f2,result)
        end
        if Condition=="do"
            result=string("pop temp 0","\n")
            open(filePath,"a")do f2
                write(f2,result)
            end
        end
        
    end
    

end

function Expression(i::Int64, filePath::String, list::Array, class_Scope::Dict{Any,Any},method_Scope::Dict{Any,Any},num_of_locals::Dict{Any,Any},className::SubString{String},word::SubString{String})
    if i<length(list)#not at the end of the list
        Term(i,filePath,list,class_Scope,method_Scope,num_of_locals,className,word)
        if occursin("[",list[i+1])
            i=i+2 #varName[
            count=1
            while count!=0
                if occursin("[",list[i])
                    count+=1
                end
                if occursin("]",list[i])
                    count-=1
                    if count==0
                        i=i-1
                    end
                end
                i=i+1
            end
            i+=1
        elseif occursin("(",list[i])
    
            i=i+1 #(
                count=1
                while count!=0
                    if occursin("(",list[i])
                     count+=1
                    end
                    if occursin(")",list[i])
                        count-=1
                        if count==0
                         i=i-1
                        end
                    end
                    i=i+1
                end
                i+=1
            
           elseif occursin("(",list[i+1])||occursin(".",list[i+1])
           if occursin(".",list[i+1])  
            i=i+3
           else
            i=i+1
           end
           i+=1
           count=1
           while count!=0
               if occursin("(",list[i])
                count+=1
               end
               if occursin(")",list[i])
                   count-=1
                   if count==0
                    i=i-1
                   end
               end
               i=i+1
           end
           i+=1
        else
           i=i+1
       end
        while split(list[i])[2] in operators
            operator=split(list[i])[2]
            i=i+1
            Term(i,filePath,list,class_Scope,method_Scope,num_of_locals,className,word)

            if operator=="+"
                result="add\n"
            elseif operator=="-"
                result="sub\n"
            elseif operator=="*"
                result="call Math.multiply 2\n"
            elseif operator=="/"
                result="call Math.divide 2\n"
            elseif operator=="&amp;"||operator=="&"
                result="and\n"
            elseif operator=="&quot;"||operator=="|"
                result="or\n"
            elseif operator=="&lt;"||operator=="<"
                result="lt\n"
            elseif operator=="&gt;"||operator==">"
                result="gt\n"
            elseif  operator=="="
                
                result="eq\n"
                
            end
            open(filePath,"a")do f2
                write(f2,result)
            end
            if occursin("[",list[i+1])
                i=i+2 #varName[
                count=1
                while count!=0
                    if occursin("[",list[i])
                        count+=1
                    end
                    if occursin("]",list[i])
                        count-=1
                        if count==0
                            i=i-1
                        end
                    end
                    i=i+1
                end
                i+=1
            elseif occursin("(",list[i])
                i=i+1 #(
                    count=1
                    while count!=0
                        if occursin("(",list[i])
                         count+=1
                        end
                        if occursin(")",list[i])
                            count-=1
                            if count==0
                             i=i-1
                            end
                        end
                        i=i+1
                    end
                    i+=1
                
               elseif occursin("(",list[i+1])||occursin(".",list[i+1])
               if occursin(".",list[i+1])  
                
                i=i+3
                
               
               else
                
                i=i+1
               
               end
               i+=1
               count=1
               while count!=0
                
                   if occursin("(",list[i])
                    count+=1
                   end
                   if occursin(")",list[i])
                       count-=1
                       if count==0
                        i=i-1
                       end
                   end
                   i=i+1
               end
               i+=1
            else
               i=i+1
           end

        end
   end
end

function Term(i::Int64, filePath::String, list::Array,class_Scope::Dict{Any,Any},method_Scope::Dict{Any,Any},num_of_locals::Dict{Any,Any},className::SubString{String},word::SubString{String})
    if i<length(list)#not at the end of the list
    if occursin("[",list[i+1])
       word=split(list[i])[2]
        i=i+2 #varName[
        Expression(i,filePath,list,class_Scope,method_Scope,num_of_locals,className,className)
        if haskey(method_Scope,word)
            kind=method_Scope[word][2]
            num=method_Scope[word][3]
            if kind=="var"
                type="local"
            else
                type="argument"
            end
            result=string("push ",type," ",num,"\n")
            open(filePath,"a")do f2
                write(f2,result)
            end
           
        end
        result="add\n"*"pop pointer 1\n"*"push that 0\n"
        open(filePath,"a")do f2
            write(f2,result)
        end
        count=1
        while count!=0
            if occursin("[",list[i])
             count+=1
            end
            if occursin("]",list[i])
                count-=1
                if count==0
                 i=i-1
                end
            end
            i=i+1
        end
        i+=1
    elseif occursin("[",list[i])
        word=split(list[i-1])[2]
         i=i+1 #varName[
         Expression(i,filePath,list,class_Scope,method_Scope,num_of_locals,className,className)
         if haskey(method_Scope,word)
             kind=method_Scope[word][2]
             num=method_Scope[word][3]
             if kind=="var"
                 type="local"
             else
                 type="argument"
             end
             result=string("push ",type," ",num,"\n","add\n")
             open(filePath,"a")do f2
                 write(f2,result)
             end
            
         end
        
         count=1
         while count!=0
             if occursin("[",list[i])
              count+=1
             end
             if occursin("]",list[i])
                 count-=1
                 if count==0
                  i=i-1
                 end
             end
             i=i+1
         end
         i+=1
    elseif occursin("(",list[i])
        
        i=i+1 #(
           
        Expression(i,filePath,list,class_Scope,method_Scope,num_of_locals,className,className)
        count=1
        while count!=0
            if occursin("(",list[i])
             count+=1
            end
            if occursin(")",list[i])
                count-=1
                if count==0
                 i=i-1
                end
            end
            i=i+1
        end
        i+=1
    elseif split(list[i])[2] in unaryOperators
        unaryOperator=split(list[i])[2]
        i=i+1
        
        
        Term(i,filePath,list,class_Scope,method_Scope,num_of_locals,className,word)
        if unaryOperator=="-"
            result="neg\n"
            
        else
            result="not\n"
        end
        open(filePath,"a")do f2
            write(f2,result)
        end
    elseif occursin("(",list[i+1])||occursin(".",list[i+1])
        if occursin(".",list[i+1])  
            class_arr=split(list[i])
            class=class_arr[2]
            i+=1
            dot_arr=split(list[i])
            dot=dot_arr[2]
            i+=1
            name_array=split(list[i])
            f_name=name_array[2]
            if haskey(class_Scope,class)
                call="method"
                kind=class_Scope[class][2]
                if kind=="field"
                    type="this"
                else
                    type="static"
                end
                num=class_Scope[class][3]
                class=class_Scope[class][1]
            elseif haskey(method_Scope,class)
                call="method"
                kind=method_Scope[class][2]
                if kind=="var"
                    type="local"
                else
                    type="argument"
                end
                num=method_Scope[class][3]
                class=method_Scope[class][1]
            else
                call="function"
                type="null"
                num=0
                
            end
        
            
            call_name=class*dot*f_name
        else
            name_array=split(list[i])
            f_name=name_array[2]
            dot="."
            call="method"
            type="pointer"
                num=0
            call_name=className*dot*f_name
        end
            i=i+2
            if call=="method"
                result=string("push ",type," ",num,"\n")
                open(filePath,"a")do f2
                write(f2,result)
                end
            end
            ExpressionList(i,filePath,list,class_Scope,method_Scope,num_of_locals,call_name,call,type,num,"let",className)
       count=1
       while count!=0
           if occursin("(",list[i])
            count+=1
           end
           if occursin(")",list[i])
               count-=1
               if count==0
                i=i-1
               end
           end
           i=i+1
       end
       i+=1
    else
        if occursin("false",list[i])||occursin("null",list[i])
            result="push constant 0\n"
            open(filePath,"a")do f2
                write(f2,result)
            end
        elseif occursin("true",list[i])
            result="push constant 0\n"*"not\n"
            open(filePath,"a")do f2
                write(f2,result)
            end
        elseif occursin("integerConstant",list[i])
            num=parse(Int64,split(list[i])[2])
            result=string("push constant ",num,"\n")
            open(filePath,"a")do f2
                write(f2,result)
            end
        elseif occursin("this",list[i])
            result="push pointer 0\n"
            open(filePath,"a")do f2
                write(f2,result)
            end
        elseif occursin("stringConstant",list[i])
            stringConstant=replace(list[i],"<stringConstant> "=>"")
            stringConstant= replace(stringConstant," </stringConstant>"=>"")
            
            arr=stringConstant=split(stringConstant,"")
            j=1
            result=string("push constant ",length(arr),"\n","call String.new 1\n","push constant ",Int(only(arr[j])),"\n")

            j+=1
            while j!=length(arr)
                result*=string("call String.appendChar 2\n","push constant ",Int(only(arr[j])),"\n")
                j+=1
            end
            result*=string("call String.appendChar 2\n","push constant ",Int(only(arr[j])),"\n","call String.appendChar 2\n")
            open(filePath,"a")do f2
                write(f2,result)
            end
            
        elseif haskey(class_Scope,split(list[i])[2])
            word=split(list[i])[2]
            kind=class_Scope[word][2]
            num=class_Scope[word][3]
            if kind=="field"
                type="this"
            else
                type="static"
            end
            result=string("push ",type," ",num,"\n")
            open(filePath,"a")do f2
                write(f2,result)
            end
           
        elseif haskey(method_Scope,split(list[i])[2])
            word=split(list[i])[2]
            kind=method_Scope[word][2]
            num=method_Scope[word][3]
            if kind=="var"
                type="local"
            else
                type="argument"
            end
            result=string("push ",type," ",num,"\n")
            open(filePath,"a")do f2
                write(f2,result)
            end
           
        end
        
        
        i+=1
    end

end
end


function WhileStatement(i::Int64, filePath::String, list::Array,class_Scope::Dict{Any,Any},method_Scope::Dict{Any,Any},num_of_locals::Dict{Any,Any},className::SubString{String})
    index=i
    if i<length(list)#not at the end of the list
        while !occursin("(",list[i])
            
            i=i+1
        end
     
        i=i+1
        result=string("label WHILE_EXP",index,"\n")
        open(filePath,"a")do f2
            write(f2,result)
        end

        Expression(i,filePath,list,class_Scope,method_Scope,num_of_locals,className,className)
       
        count=1
        while count!=0
            if occursin("(",list[i])
             count+=1
            end
            if occursin(")",list[i])
                count-=1
                if count==0
                 i=i-1
                end
            end
            i=i+1
        end
        i=i+2
        result=string("not\n","if-goto WHILE_END",index,"\n")
        open(filePath,"a")do f2
            write(f2,result)
        end
      
        Statement(i,filePath,list,class_Scope,method_Scope,num_of_locals,className)
        count=1
        while count!=0
            if occursin("{",list[i])
             count+=1
            end
            if occursin("}",list[i])
                count-=1
                if count==0
                i=i-1
                end
            end
            i=i+1
        end
        result=string("goto WHILE_EXP",index,"\n","label WHILE_END",index ,"\n")
        open(filePath,"a")do f2
            write(f2,result)
        end
       
        
        i=i+1
        
        
        Statement(i,filePath,list,class_Scope,method_Scope,num_of_locals,className)
        
        
    end
  
end
function IfStatement(i::Int64, filePath::String, list::Array,class_Scope::Dict{Any,Any},method_Scope::Dict{Any,Any},num_of_locals::Dict{Any,Any},className::SubString{String})
    index=i
    if i<length(list)#not at the end of the list
        while !occursin("(",list[i])
        
            i=i+1
        end
      
        i=i+1
        Expression(i,filePath,list,class_Scope,method_Scope,num_of_locals,className,className)
        count=1
        while count!=0
            if occursin("(",list[i])
             count+=1
            end
            if occursin(")",list[i])
                count-=1
                if count==0
                 i=i-1
                end
            end
            i=i+1
        end
        i=i+2
        result=string("if-goto IF_TRUE",index,"\n","goto IF_FALSE",index,"\n","label IF_TRUE",index,"\n")
        open(filePath,"a")do f2
            write(f2,result)
        end
        Statement(i,filePath,list,class_Scope,method_Scope,num_of_locals,className)#send to Statement
       count=1
        while count!=0
            if occursin("{",list[i])
             count+=1
            end
            if occursin("}",list[i])
                count-=1
                if count==0
                i=i-1
                end
            end
            i=i+1
        end
        result=string("goto IF_END",index,"\n","label IF_FALSE",index,"\n")
        open(filePath,"a")do f2
            write(f2,result)
        end
           
        i=i+1
        if occursin("else",list[i])
              
              i=i+2
              

            Statement(i,filePath,list,class_Scope,method_Scope,num_of_locals,className)#send to Statement
            count=1
            while count!=0
                if occursin("{",list[i])
                 count+=1
                end
                if occursin("}",list[i])
                    count-=1
                    if count==0
                    i=i-1
                    end
                end
                i=i+1
            end
            i=i+1
            
        end
          result=string("label IF_END",index,"\n")
          open(filePath,"a")do f2
            write(f2,result)
          end
          
          Statement(i,filePath,list,class_Scope,method_Scope,num_of_locals,className)
         
        
   end
   
end
function DoStatement(i::Int64, filePath::String, list::Array,class_Scope::Dict{Any,Any},method_Scope::Dict{Any,Any},num_of_locals::Dict{Any,Any},className::SubString{String})
    if i<length(list)#not at the end of the list   
        i+=1
        if occursin(".",list[i+1])
            class_arr=split(list[i])
            class=class_arr[2]
            i+=1
            dot_arr=split(list[i])
            dot=dot_arr[2]
            i+=1
            name_array=split(list[i])
            f_name=name_array[2]
            if haskey(class_Scope,class)
                call="method"
                kind=class_Scope[class][2]
                if kind=="field"
                    type="this"
                else
                    type="static"
                end
                num=class_Scope[class][3]
                class=class_Scope[class][1]
            elseif haskey(method_Scope,class)
                call="method"
                kind=method_Scope[class][2]
                if kind=="var"
                    type="local"
                else
                    type="argument"
                end
                num=method_Scope[class][3]
                class=method_Scope[class][1]
            else
                call="function"
                type="null"
                num=0
                
            end
        
            
            call_name=class*dot*f_name
        else
            name_array=split(list[i])
            f_name=name_array[2]
            dot="."
            call="method"
            type="pointer"
                num=0
            call_name=className*dot*f_name
        end
            i=i+2
            if call=="method"
                result=string("push ",type," ",num,"\n")
                open(filePath,"a")do f2
                    write(f2,result)
                end
           end
            
        ExpressionList(i,filePath,list,class_Scope,method_Scope,num_of_locals,call_name,call,type,num,"do",className)
        while !occursin(";",list[i])
            i=i+1
        end
        
        i=i+1
       
        Statement(i,filePath,list,class_Scope,method_Scope,num_of_locals,className)
       
    
    end
end

function LetStatement(i::Int64, filePath::String, list::Array,class_Scope::Dict{Any,Any},method_Scope::Dict{Any,Any},num_of_locals::Dict{Any,Any},className::SubString{String})
  if i<length(list)#not at the end of the list
     i=i+1 
     word=split(list[i])[2]
     i=i+1
     help=true
      if occursin("[",list[i]) 
        help=false
        Expression(i,filePath,list,class_Scope,method_Scope,num_of_locals,className,word)
        i+=1
        count=1
        while count!=0
            
            if occursin("[",list[i])
                count+=1
            end
            if occursin("]",list[i])
                count-=1
                if count==0
                    i=i-1
                end
            end
            i=i+1
        end
        i+=1
      end 
       
      i=i+1
        Expression(i,filePath,list,class_Scope,method_Scope,num_of_locals,className,word)
       
        while split(list[i])[2]!=";"
         i=i+1
        end
        i=i+1
        if haskey(class_Scope,word)
            kind=class_Scope[word][2]
            num=class_Scope[word][3]
            if kind=="field"
                type="this"
            else
                type="static"
            end
        else
            kind=method_Scope[word][2]
            num=method_Scope[word][3]
            if kind=="var"
                type="local"
            else
                type="argument"
            end

        end
        if help
         result=string("pop ",type," ",num,"\n")
        else
            result=string("pop temp 0","\n","pop pointer 1\n","push temp 0\n","pop that 0\n")
        end
        open(filePath,"a")do f2
            write(f2,result)
        end
        Statement(i,filePath,list,class_Scope,method_Scope,num_of_locals,className)#send to Statement
        
       
   end          
end
function ReturnStatement(i::Int64, filePath::String, list::Array,class_Scope::Dict{Any,Any},method_Scope::Dict{Any,Any},num_of_locals::Dict{Any,Any},className::SubString{String})
    if i<length(list)#not at the end of the list
        if occursin(";",list[i+1])#no expression just return;
          result=string("push constant 0","\n","return","\n")
          open(filePath,"a")do f2
             write(f2,result)
          end
            i=i+2
            Statement(i,filePath,list,class_Scope,method_Scope,num_of_locals,className)#return to Statement
        else #has expression  
        
            i=i+1
            Expression(i,filePath,list,class_Scope,method_Scope,num_of_locals,className,className)
            result=string("return","\n")
            open(filePath,"a")do f2
             write(f2,result)
            end
            while !occursin(";",list[i])
                i=i+1
            end
            i=i+1
            Statement(i,filePath,list,class_Scope,method_Scope,num_of_locals,className)#return to Statement

        end
    end
end
function GoOverXML(x::String,filePath::String,nameOffile::String)
    count_field =0
    count_static=0
    num_of_locals=Dict()
    class_Scope=Dict()
    f1=open(filePath*"\\"*x) #opens xml Tokens file
    name=filePath*"\\"*nameOffile
    f2=open(name,"w")#open vm file to write too
    list = readlines(f1)
    j=2
    array_name=split(list[j+1] )
    className=array_name[2] 
    j=j+3

    ProgramStructure(j, name, list,className,count_static,count_field,class_Scope,num_of_locals)
   
end


function main()#going over project 10
    filePath="C:\\Users\\Hp\\Downloads\\Exercises\\Exercises\\Targil5\\project 11"
    filelist = readdir(filePath) #makes a list of the file names
    for i in filelist
        if isdir(filePath*"\\"*i)
          VmWriter(filePath*"\\"*i)
        end
    end
end

VmWriter("C:\\Users\\Hp\\Downloads\\Exercises\\Exercises\\Targil3 - TziporaAndMimi/")
#main()


    
    


