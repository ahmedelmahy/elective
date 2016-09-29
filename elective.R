#just used  cat try.R
##import csv file
options(warn=-1)  #to return it back use options(warn=0)
cat('Hi, This program is written using R to help assign every
student to his elective. R is used by scientists and medical
researchers all over the world. Join us ! 
This program comes with ABSOLUTELY NO WARRANTY and
written by Ahmed Elmahy in 2016; Email: ahmed.elmahy18@yahoo.com.
This program can be extended to produce tarteb eldof3a and to 
produce all word tables like el 8eyab that take clerks days to finish..etc\n\n\n
I assume you designed the elective Google form exactly
as I did and exported it as csv file from [file->download as]
    in the Responses page. Now you will choose it') #,fill=T)
readline('press Enter')
data=read.csv(file.choose(),encoding='UTF-8')
d=data[!rev(duplicated(rev(data$ID))),]
cat(paste('The form you entered contains', dim(data)[1],'entries and after removing
          dublicates -i.e people who entered more than once I chose their last entry- the 
          number of people is now', dim(d)[1]))

#edit(d)
cat('\n\n\nLogially, you should not wait student to write their marks.
They might cheat.
So I assume you have a file containing the last year [marks].
to make things easy,
you have to copy the students IDs and their corresponding marks.
copy all the ID of eldof3a, It does not matter. 
What does matter is that every ID line has a corresponding mark line
    Be careful!')
readline('Now you will paste the students ID of the current year, Press Enter: ')

samp=sample(1:100000,1)
file=paste(getwd(),'/newid',samp,'.txt',sep='')
fileConn<-file(file)
writeLines('',fileConn)
close(fileConn)
edit(NULL,file,title='Enter the marks every ID in a line; copy and paste from excel')
newid=as.numeric(readLines(file))



readline('And now paste their marks, Press Enter: ')
file2=paste(getwd(),'/newmarks',samp,'.txt',sep='')
fileConn2<-file(file2)
writeLines('',fileConn)
close(fileConn2)
edit(NULL,file2,title='Enter the marks every mark in a line; copy and paste from excel')
newmarks=as.numeric(readLines(file2))

df=data.frame(newid,newmarks)
df2<- df[rowSums(is.na(df))<ncol(df),]
newid=df2$newid
newmarks=df2$newmarks
edit(data.frame(newid,newmarks),title='Do you find every student ID beside his corresponding marks correctly ?')

cat('I do not trust you. So I will pick a random student ID
    and I will tell you his mark. you revise it and If it is
    wrong. you are not my friend \n')
soso=sample(newid,1)
cat(paste('The marks of the student with ID number', soso, ' are ', 
       newmarks[which(newid==soso)]))
readline('\nOnly continue if this is true, to continue Press Enter: ' )

notfound=d$ID[which(!(d$ID %in% newid))]
cat(paste('Awsome, now I revised students IDs in the form and found',length(notfound),
    'students whose ID isnot found in your entries. I will ask you to enter their
    marks manually as suggest by salma,'))
readline(' press Enter')

for (q in 1:length(notfound)){
  qenter=readline(paste(notfound[q],' :'))
  newid[length(newid)+q]=as.character(notfound[q])
  newmarks[length(newmarks)+q]=qenter
}

cat('Well done. Now I will ask you about the number of 
students needed for every course.
Just write the number 
Or write no if the question is not a course name ')
readline('press Enter')
curz=vector();xideal=vector();work=vector()
for (u in 1:length(d)){
  enter=readline(paste(colnames(d)[u],' :'))
  if (!is.na(as.numeric(enter))){
    curz=c(curz,colnames(d)[u])
    xideal=c(xideal,enter);
    work=c(work,0)
  }
}
cat('There is probably a question about spending elective outside egypt
    I will list to you the other questions. Hint: write 0 
    if this question doesnot exist')
didylist=colnames(d)[which(!(colnames(d) %in% curz))]
called=select.list(didylist,title='Which one of these questions?')
here=select.list(levels(d[,called]),title='And which answer to exclude mn el tawze3a?')

try((outsideids=d$ID[d[,called]==here]))
try((d=d[d[,called]!=here,]))
try(
cat(' I now have', dim(d)[1],'students in
    the memory. As I removed ',length(outsideids),' students who
     will take the elective abroad ')
 
)
 

cat('Now students who want to be together, You will enter their ids
    separated by a comma. Ids you enter will be arranged by their results and 
    I will simpy give all the IDs you enter the same mark and the 
    same choices as the smallest one , Becareful! and do not enter spaces at all ')  #what if they were at the end of a choice
readline('press Enter ')
cat('when you finish ekteb done')


d$markss=rep(0,dim(d)[1])
for (lolo in 1: length(newid)){
  d$markss[which(d$ID == newid[lolo])]  =newmarks[lolo]
}



while (TRUE){
  mary=readline('Enter a set of students IDs separated by a comma then Enter: ')
  if (mary=='done'){
    break
  }
  
  tsplit=strsplit(mary,',')[[1]]
  didyrows=which(d$ID %in% tsplit)
  newresults=mean(as.numeric(d$markss[didyrows][!is.na(as.numeric(d$markss[didyrows]))]))
  d$markss[didyrows]= newresults
  repeatedids=d$ID[didyrows]
  d[didyrows,]=d[rep(max(didyrows),length(didyrows)),]
  d$ID[didyrows]=repeatedids
}

cat('\n\n\n Now I sorted students based on their marks.')

d=d[order(d$markss,decreasing =T),]

readline('Press Enter')


#plot2=data.frame(id=character(dim(d)[1]),x=numeric(dim(d)[1]),
 #                choice=character(dim(d)[1]));colnames(plot2)=c('id','x','choice')



cat('Let us make sure I am right')
cat(paste('\nThe student with ID ', d$ID[1],' hwa el awal 3la eldof3a aw el round'))
readline('to continue Press Enter')


puma=(which(colnames(d)%in%curz))

for (i in 1:dim(d)[1]){
  s=sort(d[i,][puma])
  for (j in 1: length(s) ){
    ost=names(s[j])
    if (s[j]==0) {break}
    try(
      if (   work[which(curz==ost)]    < as.numeric(xideal [which(curz==ost)])   ){   
        print(paste(d$ID[i],ost))
        plot2[i]= c(d$ID[i],ost)
        work[which(curz==ost)]=(work[which(curz==ost)])+1
        break
      },silent=T)
    
    
  }
}

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


plot2