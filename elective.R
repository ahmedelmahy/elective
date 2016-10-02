#data entry and removing dublicated rows.
#just used  cat try.R
##import csv file
options(warn=-1)  #to return it back use options(warn=0)
cat('Hi, This program is written using R to help assign every
student to his elective. R is used by scientists and medical
researchers all over the world. Join us ! 
This program comes with ABSOLUTELY NO WARRANTY and is
written by Ahmed Elmahy in 2016; Email: ahmed.elmahy18@yahoo.com.\n\n\n
I assume you designed the elective Google form exactly
as I did and downloaded it as csv file from
    
     the Responses page. Now you will choose it') #,fill=T)
readline('press Enter')
data=read.csv(file.choose(),encoding='UTF-8')

cat('Can you show me the folder where you want to save the results?\n ')
readline('press Enter')
mainDir=choose.dir()
subDir='temp'
dir.create(file.path(mainDir, subDir), showWarnings = FALSE)
setwd(file.path(mainDir, subDir))

#idenify the columns
cat('\n\nWell done. Now I will ask you about the number of 
students needed for every course.
Just write the number or write 0 if the course was deleted later
Or write no if the question is not a course name ')
readline('press Enter')
##courses numbers
d=data
curz=vector();xideal=vector();work=vector()
for (u in 1:length(d)){
  enter=readline(paste(colnames(d)[u],' :'))
  if (!is.na(as.numeric(enter))){
    curz=c(curz,colnames(d)[u])
    xideal=c(xideal,enter);
    work=c(work,0)
  }
}
names(xideal)=curz;names(work)=curz
##Identify the ID variable
cat('Can you show me the question that contains the IDs of the students ?\n\n')
didylist=colnames(d)[which(!(colnames(d) %in% curz))]
idname=select.list(didylist,title='Which one of these questions?')
colnames(data)[colnames(data)==idname]='ID'


##Make d and remove the dublicates
d=data[!rev(duplicated(rev(data$ID))),]
enteredmore=data$ID[rev(duplicated(rev(data$ID)))]   #report 1

cat(paste('The form you entered contains', dim(data)[1],'entries and after removing
          dublicates -i.e people who entered more than once I chose their last entry- the 
          number of people is now', dim(d)[1]))


#people to exlude from the elective
cat('\n\n\nThere is probably a question about spending elective outside egypt
    I will list to you the other questions.\n')
readline('press Enter')
isthere= select.list(c('yes there is a question about elective outside','no'))

#didylist=colnames(d)[which(!(colnames(d) %in% curz))]

if (isthere=='yes there is a question about elective outside'){
  called=select.list(didylist,title='Which one of these questions?')
  print(called)
  cat('\n\nWhich answer to exclude ?')
  here=select.list(levels(d[,called]),title='Which answer to exclude ?')
  print(here)
  outsideids=as.character(d$ID[d[,called]==here])
  print(outsideids)
  d=d[d[,called]!=here,]
  n=length(outsideids)
  cat(' I now have', dim(d)[1],'students in
      the memory. As I removed ',n,' students who
      will take the elective abroad ')
}



#entering marks and IDs
cat('\n\n\n.I assume you have a file containing the last year [marks].
to make things easy,
you have to copy the students IDs and their corresponding marks.
What does matter is that every ID line has a corresponding mark line
    Be careful!') #
readline('\n\nNow you will paste the students ID of the current year, Press Enter: ') #

##IDs
samp=sample(1:100000,1)
#

file=paste(getwd(),'/newid',samp,'.txt',sep='')
fileConn<-file(file)
writeLines('',fileConn)
close(fileConn)
edit(NULL,file,title='Enter the marks every ID in a line; copy and paste from excel')
newid=as.numeric(readLines(file))

##marks
readline('\nAnd now paste their marks, Press Enter: ')

file2=paste(getwd(),'/newmarks',samp,'.txt',sep='')
fileConn2<-file(file2)
writeLines('',fileConn2)
close(fileConn2)
edit(NULL,file2,title='Enter the marks every mark in a line; copy and paste from excel')
newmarks=readLines(file2)
newmarks=newmarks[newmarks!='']
newmarks[which((is.na(as.numeric(newmarks))))]='0'
newmarks=as.numeric(newmarks)

newid <- newid[!is.na(newid)]
newmarks=newmarks[!is.na(newmarks)]
###make sure
df=data.frame(newid,newmarks) #akeed mfeesh 7ad btkoon dragto fadya
#df2<- df[rowSums(is.na(df))<ncol(df),]

newid=df$newid      #previously were df2
newmarks=df$newmarks
edit(data.frame(newid,newmarks),title='Do you find every student ID beside his corresponding marks correctly ?')



###another check
cat('\nI will pick a random student ID
    and I will tell you his mark. you revise it and it should be right \n')
soso=sample(newid,1)
cat(paste('The marks of the student with ID number', soso, ' are ', 
       newmarks[which(newid==soso)]))
readline('\nOnly continue if this is true, to continue Press Enter: ' )

notfound=d$ID[which(!(d$ID %in% newid))]
cat(paste('\n\n\nAwesome, now I revised students IDs in the form\n and found',length(notfound),
    'students whose ID is not found in your entries.\n'))
    

if (length(notfound)>0){
  cat('\nI will ask you to enter their marks manually\n
      type 0 if his marks are not available
      type no if this id isnot included in this elective\n
      ,(if you see <U+0645> it mean the letter meem)')
  
  readline(' press Enter')
  for (q in 1:length(notfound)){
    qenter=readline(paste(notfound[q],' :'))
    if (!is.na(as.numeric(qenter))){
      newid[length(newid)+q]=as.character(notfound[q])
      newmarks[length(newmarks)+q]=qenter
    }
    if(is.na(as.numeric(qenter))){
      d=d[-which(notfound[q]== d$ID),]
        }
      }
    }
    
    



#together students
cat('Now students who want to be together, You will enter their ids\n
    separated by a comma. Ids you enter will be arranged\n by their results and 
    I will simpy give all the IDs you enter the mean mark\n and the 
    same choices as the latest one , \nBecareful! and do not enter spaces at all ')  #what if they were at the end of a choice
readline('press Enter to start ')
cat('\nwhen you finish ekteb done\n\n')

d$markss=rep(0,dim(d)[1])
for (lolo in 1: length(newid)){
  d$markss[which(d$ID == newid[lolo])]  =newmarks[lolo]
}



while (TRUE){
  mary=readline('Enter a couple separated by a comma then Enter: ')
  if (mary=='done'){
    break
  }
  
  tsplit=strsplit(mary,',')[[1]]
  didyrows=which(d$ID %in% tsplit)      #the program assumes both in the dataset otherwise 
  #the program can't find the other one!
  newresults=mean(as.numeric(d$markss[didyrows][!is.na(as.numeric(d$markss[didyrows]))]))
  d$markss[didyrows]= newresults
  repeatedids=d$ID[didyrows]
  d[didyrows,]=d[rep(max(didyrows),length(didyrows)),]
  d$ID[didyrows]=repeatedids
}



#now sorting

cat('\n\n\n Now I sorted students based on their marks.')




d=d[order(as.numeric(d$markss),decreasing =T),]
readline('Press Enter')
cat('Let us make sure I am right')
cat(paste('\nThe student with ID ', d$ID[1],' hwa el awal 3la eldof3a aw el round\n'))
readline('to continue Press Enter')


#plot2=data.frame(id=character(dim(d)[1]),x=numeric(dim(d)[1]),
 #                choice=character(dim(d)[1]));colnames(plot2)=c('id','x','choice')
num=which(colnames(d)%in% curz)
for (i in 1: length(curz)){
 
  mistake=which(as.numeric(as.character(d[,num[i]]))>length(curz)| is.na(as.numeric(as.character(d[,num[i]]))) )
  d[,num[i]][mistake]=0
  d[,num[i]]=as.numeric(as.character(d[,num[i]]))
}

for (i in  num){
  p=sum(d[i,num])
  if (p==0){
    d=d[-i,]
  }
  }

puma=(which(colnames(d)%in%curz))
id=vector();mark=id;number=id;choice=id

ii=0
for (i in 1:dim(d)[1]){
  s=sort(d[i,][puma])
  for (j in 1: length(s) ){
    ost=names(s[j])
    if (as.numeric(s[j])>0) {
      if (   work[which(curz==ost)]    < as.numeric(xideal [which(curz==ost)])   ){   
        ii=ii+1
        print(paste(d$ID[i],ost))
        
        id[ii]= as.character(d$ID[i])
        mark[ii]=d$markss[i]
        number[ii]=as.numeric(s[j])
        choice[ii]=ost
        work[which(curz==ost)]=(work[which(curz==ost)])+1
        break
      }
  }
}}

plot2=data.frame(id,mark,number,choice)

setwd(mainDir)
plot1=work;names(plot1)=curz

for (i in 1:dim(d)[1]){
    s=sort(d[i,][puma])
    for (j in 1: length(s) ){
      ost=names(s[j])
      
    plot1[which(curz==ost)]= plot1[which(curz==ost)]+length(s)+1-j
    
  }
}

barplot(sort(plot1,decreasing = F),col= terrain.colors(length(plot1),1),horiz = T,legend=T,
        yaxt='n', ann=FALSE, main='Graph1:\n Courses arranged by students preferences',
        sub='Courses with small bars are courses that students dislike and should be
        either improved or deleted',legend.text=T,args.legend=list(x='bottomright'))


#report1
txt1=paste ('the following IDs has filled the form more than once\n\n\n  ',paste(enteredmore,collapse=','))

fileConn<-file("report1.txt")
writeLines(txt1, fileConn)
close(fileConn)



#report2
zeromark=as.character(d$ID[d$markss==0])
txt2=paste('the following IDs were give zero marks and distributed randomly\n\n\n',
           paste(zeromark,collapse=','))

fileConn<-file("report2.txt")
writeLines(txt2, fileConn)
close(fileConn)



#report3

write.csv(plot2, file = "report3.csv")


#report4
dff=data.frame(as.character(plot2$id),as.character(plot2$choice));colnames(dff)=c('id','choice')

#dff=dff[order(as.character(dff$choice)),]

for (i in 1:length(curz)){
  dffid=dff$id[which(dff$choice==curz[i])]
  cu=curz[i]
  fileConn<-file(paste(cu,"report4.txt",collapse=''))
  txt4=paste('The elective course   ',
             cu,
             ' has the following students IDs: \n\n\n\n',
             paste(dffid, collapse=','))
  writeLines(txt4, fileConn)
  close(fileConn)
}


#report5

#didntfill=which(!(newid %in% c(as.character(d$ID),outsideids)))
didntfill=which(!(newid %in% as.character(d$ID)))
didntfill=didntfill[-which(didntfill %in% as.numeric(outsideids))]
txt3=paste('the following IDs did not fill the form\n\n\n',
           paste(didntfill,collapse=','))
fileConn<-file("report5.txt")
writeLines(txt3, fileConn)
close(fileConn)


#report6 free places
freeplaces=as.numeric(xideal)-as.numeric(work)
freedf=data.frame(curz,freeplaces)
write.csv(freedf, file = "report6.csv")



#report7 
plot2a=plot2[which(!is.na(as.numeric(as.character(plot2$id)))),]
plot2b=plot2[which(is.na(as.numeric(as.character(plot2$id)))),]
plot2a=plot2a[order(as.numeric(as.character(plot2a$id))),]
plot3=rbind(plot2a,plot2b)
write.csv(plot3, file = "report7.csv")


