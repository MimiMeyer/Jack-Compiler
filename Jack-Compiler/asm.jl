
function HasVm(filePath::String,filelist::Array)
  
  hasVm::Bool=false
  count=0
  for i in filelist #going over the file names
    if occursin(".", i)#if contains dot
      arr::Array=split(i,".")#splliting by the dot
      if arr[2]=="vm" #checks if its a vm file
        hasVm=true#has a vm file
        count+=1#checks if there is more then one vm file
      end
    end
  end
  if count>1#if there is more then one file
    outPutFile = filePath*"\\"*basename(filePath)*".asm"
    BootStrap(outPutFile)#BootStrap
  end
  if (!hasVm)#if it does't have vm check sub file
    CheckSubFile(filePath,filelist)
  else
    for i in filelist #going over the file names
      if occursin(".", i)#if contains dot
        arr::Array=split(i,".")#splliting by the dot
        if arr[2]=="vm" #checks if its a vm file
          nameOffile=arr[1]
          outPutFile = filePath*"\\"*basename(filePath)*".asm"
          GoOverVm(outPutFile,filePath,i,nameOffile)#checks each line and translates accordingly 
          
          
        end
      end
    end
  end
    
 
end

function CheckSubFile(filePath::String,filelist::Array)#checks subfiles recursively
  for i in filelist #going over the file names
    result="\\"*i
    filePath=filePath*result
    if (isdir(filePath)) && "C:\\Users\\Hp\\Downloads\\Exercises\\Exercises\\Targil5\\project 11\\Square\\JackToVMdir"!=filePath #only if file path is directory and file path doesnt equal that
     fileList = readdir(filePath) #making a list for the file names
     HasVm(filePath,fileList)#check if file has vm files
     filePath = replace(filePath,result => "" )#removes results recursively
    else
      break
     
    end
  end   
  
end



function Add(outPutFile::String) #function add
  result=string("//start ADD","\n","@SP","\n","AM=M-1","\n","D=M","\n","A=A-1","\n","M=M+D","\n","//end ADD","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end
end
function PushConstant(x::SubString{String},outPutFile::String)#fuction for pushing in a a value 
  result=string("//start PushConstant ",x,"\n","@",x,"\n","D=A","\n","@SP","\n","A=M","\n","M=D","\n","@SP","\n","M=M+1","\n","//end PushConstant ",x,"\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end
end
function Equal(outPutFile::String,num::Int64)
  result=string("//start EQUAL","\n","@SP","\n","A=M-1","\n","D=M","\n","A=A-1","\n","D=D-M","\n","@IF_TRUE",num,"\n","D;JEQ","\n","D=0","\n","@IF_FALSE",num,"\n","0;JMP","\n","(IF_TRUE",num,") //label","\n","D=-1","\n","(IF_FALSE",num,")","\n","@SP","\n","A=M-1","\n","A=A-1","\n","M=D","\n","@SP","\n","M=M-1","\n","//end EQUAL","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end
end
function LessThan(outPutFile::String,num::Int64)
  result=string("//start LessThan","\n","@SP","\n","AM=M-1","\n","D=M","\n","A=A-1","\n","D=M-D","\n","@FALSE",num,"\n","D;JGE","\n","@SP","\n","A=M-1","\n","M=-1","\n","@CONTINUE",num,"\n","0;JMP","\n","(FALSE",num,")","\n","@SP","\n","A=M-1","\n","M=0","\n","(CONTINUE",num,")","\n","//end LessThan","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function GreaterThan(outPutFile::String,num::Int64)
  result=string("//start GreaterThan","\n","@SP","\n","AM=M-1","\n","D=M","\n","A=A-1","\n","D=M-D","\n","@FALSE",num,"\n","D;JLE","\n","@SP","\n","A=M-1","\n","M=-1","\n","@CONTINUE",num,"\n","0;JMP","\n","(FALSE",num,")","\n","@SP","\n","A=M-1","\n","M=0","\n","(CONTINUE",num,")","\n","//end GreaterThan","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function Subtraction(outPutFile::String)
  result=string("//start Subtraction","\n","@SP","\n","M=M-1","\n","@SP","\n","A=M","\n","D=M","\n","@SP","\n","M=M-1","\n","@SP","\n","A=M","\n","M=M-D","\n","@SP","\n","M=M+1","\n","//end Subtraction","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function Negative(outPutFile::String)
  result=string("//start Negative","\n","D=0","\n","@SP","\n","A=M-1","\n","M=D-M","\n","//end Negative","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function And(outPutFile::String)
  result=string("//start and","\n","@SP","\n","AM=M-1","\n","D=M","\n","A=A-1","\n","M=M&D","\n","//end and","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function Or(outPutFile::String)
  result=string("//start or","\n","@SP","\n","AM=M-1","\n","D=M","\n","A=A-1","\n","M=M|D","\n","//end or","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function PushStatic(num::SubString{String},outPutFile::String,name::SubString{String})
  result=string("//start PushStatic","\n","@Static",name,".",num,"\n","D=M","\n","@SP","\n","A=M","\n", "M=D","\n","@SP","\n","M=M+1","\n","//end PushStatic","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function PopStatic(num::SubString{String},outPutFile::String,name::SubString{String})
  result=string("//start PopStatic","\n","@SP","\n","M=M-1","\n","A=M","\n","D=M","\n","@Static",name,".",num,"\n","M=D","\n","//end popStatic","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function PopLocal(outPutFile::String,x::Int64)
  result=string("//start PopLocal","\n","@LCL","\n","D=M","\n","@",x,"\n","D=D+A","\n","@13","\n","M=D","\n","@SP","\n","AM=M-1","\n","D=M","\n","@13","\n","A=M","\n","M=D","\n","//end PopLocal","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function PushLocal(outPutFile::String,x::Int64)
  result=string("//start PushLocal","\n","@LCL","\n","D=M","\n","@",x,"\n","A=D+A","\n","D=M","\n","@SP","\n","A=M","\n","M=D","\n","@SP","\n","M=M+1","\n","//end PushLocal","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function PopArgument(outPutFile::String,num::Int64)
  result=string("//start PopArgument","\n","@ARG","\n","D=M","\n","@",num,"\n","D=D+A","\n","@13","\n","M=D","\n","@SP","\n","AM=M-1","\n","D=M","\n","@13","\n","A=M","\n","M=D","\n","//end PopArgument","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function PushArgument(outPutFile::String,num::Int64)
  result=string("//start PushArgument","\n","@ARG","\n","D=M","\n","@",num,"\n","A=D+A","\n","D=M","\n","@SP","\n","A=M","\n","M=D","\n","@SP","\n","M=M+1","\n","//end PushArgument","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function PopThis(outPutFile::String,num::Int64)
  result=string("//start PopThis","\n","@THIS","\n","D=M","\n","@",num,"\n","D=D+A","\n","@13","\n","M=D","\n","@SP","\n","AM=M-1","\n","D=M","\n","@13","\n","A=M","\n","M=D","\n","//end PopThis","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function PushThis(outPutFile::String,num::Int64)
  result=string("//start PushThis","\n","@THIS","\n","D=M","\n","@",num,"\n","A=D+A","\n","D=M","\n","@SP","\n","A=M","\n","M=D","\n","@SP","\n","M=M+1","\n","//end PushThis","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function PopThat(outPutFile::String,num::Int64)
result=string("//start PopThat","\n","@THAT","\n","D=M","\n","@",num,"\n","D=D+A","\n","@13","\n","M=D","\n","@SP","\n","AM=M-1","\n","D=M","\n","@13","\n","A=M","\n","M=D","\n","//end PopThat","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function PushThat(outPutFile::String,num::Int64)
 result=string("//start PushThat","\n","@THAT","\n","D=M","\n","@",num,"\n","A=D+A","\n","D=M","\n","@SP","\n","A=M","\n","M=D","\n","@SP","\n","M=M+1","\n","//end PushThat","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function PopTemp(outPutFile::String,num::Int64)
 result=string("//start PopTemp","\n","@5","\n","D=M","\n","@",num,"\n","D=D+A","\n","@13","\n","M=D","\n","@SP","\n","AM=M-1","\n","D=M","\n","@13","\n","A=M","\n","M=D","\n","//end PopTemp","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function PushTemp(outPutFile::String,num::Int64)
 result=string("//start PushTemp","\n","@5","\n","D=M","\n","@",num,"\n","A=D+A","\n","D=M","\n","@SP","\n","A=M","\n","M=D","\n","@SP","\n","M=M+1","\n","//end PushTemp","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function PopPointer0(outPutFile::String)
 result=string("//start PopPointer0","\n","@THIS","\n","D=A","\n","@13","\n","M=D","\n","@SP","\n","AM=M-1","\n","D=M","\n","@13","\n","A=M","\n","M=D","\n","//end PopPointer0","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function PopPointer1(outPutFile::String)
 result=string("//start PopPointer1","\n","@THAT","\n","D=A","\n","@13","\n","M=D","\n","@SP","\n","AM=M-1","\n","D=M","\n","@13","\n","A=M","\n","M=D","\n","//end PopPointer1","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function PushPointer0(outPutFile::String)
 result=string("//start PushPointer0","\n","@THIS","\n","D=M","\n","@SP","\n","A=M","\n","M=D","\n","@SP","\n","M=M+1","\n","//end PushPointer0","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function PushPointer1(outPutFile::String)
 result=string("//start PushPointer1","\n","@THAT","\n","D=M","\n","@SP","\n","A=M","\n","M=D","\n","@SP","\n","M=M+1","\n","//end PushPointer1","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end


function Func(outPutFile::String,k::SubString{String},func::SubString{String})
  result=string("//start func ",func,"\n","(",func,")","\n","@",k,"\n","D=A","\n","@",func,".End","\n","D;JEQ","\n","(",func,".Loop)","\n","@SP","\n","A=M","\n","M=0","\n","@SP","\n","M=M+1","\n","@",func,".Loop","\n","D=D-1;JNE","\n","(",func,".End)","\n","//end func ",func,"\n")
  open(outPutFile,"a")do f2
     write(f2,result)
   end 
end
function IfGoTo(outPutFile::String,label::SubString{String},fileName::SubString{String})
    result=string("//start IfGoTo","\n","@SP","\n","M=M-1","\n","A=M","\n","D=M","\n","@",fileName,".",label,"\n","D;JNE","\n","//end IfGoTo","\n")
    open(outPutFile,"a")do f2
        write(f2,result)
    end   
end
function GoTo(outPutFile::String,label::SubString{String},fileName::SubString{String})
    result=string("//start goto","\n","@",fileName,".",label,"\n","0; JMP","\n","//end goto","\n")
    open(outPutFile,"a")do f2
        write(f2,result)
    end 
end
function Label(outPutFile::String,label::SubString{String},fileName::SubString{String})
    result=string("//start Label","\n","(",fileName,".",label,")","\n","//end label","\n")
    open(outPutFile,"a")do f2
        write(f2,result)
    end   
end
function Return(outPutFile::String)
  result=string("//start return","\n","//FRAME=LCL","\n","@LCL","\n","D=M","\n","//RET(RAM[13])=(FRAME-5)","\n","@5","\n","A=D-A","\n","D=M","\n","@13","\n","M=D","\n","//ARG=POP()","\n","@SP","\n","M=M-1","\n","A=M","\n","D=M","\n","@ARG","\n","A=M","\n","M=D","\n"
  ,"//SP=ARG+1","\n","@ARG","\n","D=M","\n","@SP","\n","M=D+1","//THAT=(FRAME-1)","\n","\n","@LCL","\n","M=M-1","\n","A=M","\n","D=M","\n","@THAT","\n","M=D","\n","//THIS=(FRAME-2)","\n","@LCL","\n","M=M-1","\n","A=M","\n","D=M","\n","@THIS","\n","M=D","\n","//ARG=(FRAME-3)","\n","@LCL","\n","M=M-1","\n","A=M","\n","D=M","\n","@ARG","\n","M=D","\n"
 ,"//LCL=(FRAME-4)","\n","@LCL","\n","M=M-1","\n","A=M","\n","D=M","\n","@LCL","\n","M=D","\n","//GOTO RET (RAM[13])","\n","@13","\n","A=M","\n","0;JMP","\n","//end return","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function HelpCall(outPutFile::String,name::String)
  result=string("//push",name,"\n",name,"\n","D=M","\n","@SP","\n","A=M","\n","M=D","\n","@SP","\n","M=M+1","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end 
end
function Call(outPutFile::String,FileName::SubString{String},count::Int64,num::SubString{String})
 f1=outPutFile
 bool=true
 number=count
 line=string("@",FileName,".ReturnAddress",count)#label for return address 
 
 while bool#makes sure counter is accurate
   for i in eachline(f1)
     if i==line
       count+=1
       bool=false
      end
      line=string("@",FileName,".ReturnAddress",count)
   end
   if number==count#count was not used 
     bool=false
   end
 end
  result1=string("//start call","\n","//push return address","\n","@",FileName,".ReturnAddress",count,"\n","D=A","\n","@SP","\n","A=M","\n","M=D","\n","@SP","\n","M=M+1","\n")
  open(outPutFile,"a")do f2
   write(f2,result1)
  end
  HelpCall(outPutFile,"@LCL")#could of used push local
  HelpCall(outPutFile,"@ARG")
  HelpCall(outPutFile,"@THIS")
  HelpCall(outPutFile,"@THAT")

  result2=string("//ARG=SP-n-5","\n","@SP","\n","D=M","\n","@5","\n","D=D-A","\n","@",num,"\n","D=D-A","\n","@ARG","\n","M=D","\n","//LCL=SP","\n","@SP","\n","D=M","\n","@LCL","\n","M=D","\n","//GO TO ",FileName,"\n","@",FileName,"\n","0;JMP","\n","(",FileName,".ReturnAddress",count,")","\n","//end call","\n")
  open(outPutFile,"a")do f2
   write(f2,result2)
  end 
end

function Not(outPutFile::String)
  result=string("//start Not","\n","@SP","\n","AM=M-1","\n","M=!M","\n","@SP","\n","M=M+1","\n","//end not","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end

end
function BootStrap(outPutFile::String)
  result=string("//start BootStrap","\n","@256","\n","D=A","\n","@SP","\n","M=D","\n")
  open(outPutFile,"a")do f2
    write(f2,result)
  end
  FileName::SubString{String}="Sys.init"
  count=0
  x::SubString{String}="0"
  Call(outPutFile,FileName,count,x)#call sys.init 0
  result1=string("//end BootStrap","\n")
  open(outPutFile,"a")do f2
    write(f2,result1)
  end

end
function GoOverVm(outPutFile::String,filePath::String,i::String,name::SubString{String})
 f1=open(filePath*"\\"*i) #opens vm file
 f2=outPutFile #creates asm file with same name as vm file
 count=0
 countForCall=1#use for count
    for j in eachline(f1)#goes over each line in file
        if j!=""#not an empty line
            word::Array=split(j)#splits each line
            if word[1]=="not"
              Not(outPutFile)
            end
            if word[1]=="label"
                Label(outPutFile,word[2],name)
            end
            if word[1]=="function"
                Func(outPutFile,word[3],word[2])
            end
            if word[1]=="return"
              Return(outPutFile)
            end
            if word[1]=="call"
              Call(outPutFile,word[2],countForCall,word[3])
              countForCall+=1
              
            end
            if word[1]=="goto"
                GoTo(outPutFile,word[2],name)
            end
            if word[1]=="if-goto"
                IfGoTo(outPutFile,word[2],name)
            end
            if word[1]=="add"
                Add(outPutFile)
            end 
            if word[1]=="eq"
                Equal(outPutFile,count)
                count+=1
            end
            if word[1]=="lt"
                LessThan(outPutFile,count)
                count+=1
            end
            if word[1]=="gt"
                GreaterThan(outPutFile,count)
                count+=1
            end
            if word[1]=="sub"
                Subtraction(outPutFile)
            end
            if word[1]=="neg"
                Negative(outPutFile)
            end
            if word[1]=="and"
                And(outPutFile)
            end
            if word[1]=="or"
                Or(outPutFile)
            end
            if word[1]=="push"
                if word[2]=="constant"
                    PushConstant(word[3],outPutFile)
                end
                if word[2]=="static"
                    PushStatic(word[3],outPutFile,name)
                end
                if word[2]=="local"
                PushLocal(outPutFile,parse(Int64,word[3]))
                end
                if word[2]=="argument"
                    PushArgument(outPutFile,parse(Int64,word[3]))
                end
                if word[2]=="this"
                    PushThis(outPutFile,parse(Int64,word[3]))
                end
                if word[2]=="that"
                    PushThat(outPutFile,parse(Int64,word[3]))
                end
                if word[2]=="temp"
                    PushTemp(outPutFile,parse(Int64,word[3])+5)
                end
                if word[2]=="pointer"
                    if word[3]=="1"
                        PushPointer1(outPutFile)
                    end
                    if word[3]=="0"
                        PushPointer0(outPutFile)
                    end
                end
            end
            if word[1]=="pop"
                if word[2]=="static"
                    PopStatic(word[3],outPutFile,name)
                end
                if word[2]=="local"
                    PopLocal(outPutFile,parse(Int64,word[3]))
                end
                if word[2]=="argument"
                    PopArgument(outPutFile,parse(Int64,word[3]))
                end
                if word[2]=="this"
                    PopThis(outPutFile,parse(Int64,word[3]))
                end
                if word[2]=="that"
                    PopThat(outPutFile,parse(Int64,word[3]))
                end
                if word[2]=="temp"
                    PopTemp(outPutFile,parse(Int64,word[3])+5)
                end
                if word[2]=="pointer"
                    if word[3]=="1"
                        PopPointer1(outPutFile)
                    end
                    if word[3]=="0"
                        PopPointer0(outPutFile)
                    end
                end
            end
        end
        
    end
end


#main
filePath="C:\\Users\\Hp\\Downloads\\Exercises\\Exercises"
filelist = readdir(filePath) #making a list for the file names
HasVm(filePath,filelist)#checks if has vm


 



 
 
  
