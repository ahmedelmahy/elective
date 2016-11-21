if (!require('gWidgets')) install.packages('gWidgets'); library('gWidgets')
if (!require('RGtk2Extras')) install.packages('RGtk2Extras'); library('RGtk2Extras')
options(show.error.locations = TRUE)
options(guiToolkit="RGtk2")

read_form<-function(){
  window <- gwindow("elective", visible=FALSE)
  paned <- gpanedgroup(cont = window)
  group <- ggroup(cont = paned, horizontal = FALSE)
  glabel("Google Form", cont=group, anchor=c(-1,0))
  form <- gfilebrowse(cont = group,quote=FALSE)
  glabel("Save to ...", cont=group, anchor=c(-1,0))
  saveto <- gfilebrowse('Select a Folder',type='selectdir',cont = group,quote = FALSE)
  addSpring(group)
  addSpace(group,20)
  next1 <- gbutton("Next", cont = group)
  addHandlerChanged(next1, handler = function(h,...) {
    formpath<-svalue(form)
    wdpath<-svalue(saveto)
    if (wdpath!='Select a Folder'){setwd(wdpath)}
    dat<-read.csv(formpath,encoding='UTF-8')
    dispose(window)
    read_marks_and_courses(dat)
  })
  visible(window) <- TRUE
}

read_marks_and_courses=function(dat){
  dff=data.frame(id='',marks='')
  marksfile<-dfedit(dff)
  marksfile$marks=as.numeric(as.character(marksfile$marks))
  marksfile$marks[is.na(marksfile$marks)]=0
  cat('\n\n the number of students per course. write a number or no if what you see is not a course name ')
  readline('press Enter')
  d<-dat
  curz<-vector();xideal<-vector();work<-vector()
  for (u in 1:length(d)){
    enter<-readline(paste(colnames(d)[u],' :'))
    if (!is.na(as.numeric(enter))){
      curz<-c(curz,colnames(d)[u])
      xideal<-c(xideal,enter);
      work<-c(work,0)
    }
  }
  names(xideal)<-curz;names(work)<-curz
  cat('Choose the question containing the IDs\n\n')  ##Identify the ID variable
  didylist<-colnames(d)[which(!(colnames(d) %in% curz))]
  idname<-select.list(didylist,title='Which one ?')
  colnames(dat)[colnames(dat)==idname]<-'ID'
  d<-dat[!rev(duplicated(rev(dat$ID))),]
  #enteredmore<-unique(dat$ID[rev(duplicated(rev(dat$ID)))])   #report 1 #added unique
  prevd<-read_prev(curz)
  d<-remove_prev(d,prevd)
  plot2<<-add_marks(d,marksfile$id,marksfile$marks,xideal,work,curz,didylist)
  #plot2<-job6(d,xideal,work,curz)
  return(plot2)
}

read_prev=function(curz){
  dffg=data.frame(id='',prev1='',prev2='',prev3='')
  prevd<-dfedit(dffg)
  trim <- function (x) gsub("^\\s+|\\s+$", "", x) #define the trim function
  clean<-function(x){
    gsub("[[:punct:]]", "", tolower(x))
  } 
  #prevd<-data.frame(id,a,b,c)
  prevd[,2]=clean(trim(as.character(prevd[,2])));prevd[,3]=clean(trim(as.character(prevd[,3])));prevd[,4]=clean(trim(as.character(prevd[,4])))
  #prevd=tolower(prevd[,2])
  collected=c(prevd[,2],prevd[,3],prevd[,4])
  #prevuni=tolower(collected)
  #prevuni=gsub("[[:punct:]]", "", prevuni)
  prevuni=(unique(collected))
  for (i in 1: length(curz)){
    cat(paste(curz[i],'\n'))
    right=select.list(sort(prevuni),multiple=T,graphics = T)
    if (length(right)>0){
      prevd[,2][which(prevd[,2] %in% right)]=curz[i]
      prevd[,3][which(prevd[,3] %in% right)]=curz[i]
      prevd[,4][which(prevd[,4] %in% right)]=curz[i]
      prevuni=prevuni[-which(prevuni %in% right)]
    }
  }
  prevd[,2][-which(prevd[,2] %in% curz)]=NA
  prevd[,3][-which(prevd[,3] %in% curz)]=NA
  prevd[,4][-which(prevd[,4] %in% curz)]=NA
  return(prevd)
}

remove_prev=function(d,prevd){
  d$ID=as.character(d$ID)
  prevd[,1]=as.character(prevd[,1])
  prevd[,2]=as.character(prevd[,2])
  prevd[,3]=as.character(prevd[,3])
  prevd[,4]=as.character(prevd[,4])
  
  for (k in which(d$ID %in% prevd$id)){
    d[d$ID==k,which(colnames(d[d$ID==k,]) %in% prevd$prev1[prevd$id==k])]=0
    d[d$ID==k,which(colnames(d[d$ID==k,]) %in% prevd$prev2[prevd$id==k])]=0
    d[d$ID==k,which(colnames(d[d$ID==k,]) %in% prevd$prev3[prevd$id==k])]=0
  }
  return(d)
}







add_marks=function(d,newid,newmarks,xideal,work,curz,didylist){
  #newid=as.character(marksfile$id);newmarks=as.character(marksfile$marks)
  notfound=d$ID[which(!(d$ID %in% newid))]
  if (length(notfound)>0){
    cat('\n The following students filled the form\n
        and their marks are not found enter the marks, 0 or no to exclude them\n
        ,(if you see <U+0645> it mean the letter meem)')
    readline(' press Enter')
    w=0
    for (q in 1:length(notfound)){
      qenter=readline(paste(notfound[q],' :'))
      if (!is.na(as.numeric(qenter))){
        newid[length(newid)+q-w]=as.character(notfound[q])
        newmarks[length(newmarks)+q-w]=qenter
      }
      if(is.na(as.numeric(qenter))){
        d<-d[-which(notfound[q]== d$ID),]
        w=w+1
      }
    }
  }
  
  d=check_outside(d,xideal,work,curz,newid,newmarks,didylist)
  d<-add_marks_to_form(d,newid,newmarks)
  
  d<-entry_mistake_checker(d,curz)
  plot2<-distribute_courses(d,work,xideal,curz)
  return(plot2)
}

check_outside=function(d,xideal,work,curz,newid,newmarks,didylist){
  cat('\n\n\nElective Outside\n')
  readline('press Enter')
  isthere= select.list(c('yes there is a question about elective outside','no'))
  if (isthere=='yes there is a question about elective outside'){
    called=select.list(didylist,title='Which one of these questions?')
    cat('\n\nWhich answer to exclude ?')
    here=select.list(levels(d[,called]),title='Which answer to exclude ?')
    outsideids=as.character(d$ID[d[,called]==here])
    #print(outsideids)
    colnames(d)[colnames(d)==called]='outside'
    #edit(d)
    d$outside=as.character(d$outside)
    d$outside[d$outside!=here]=rep(0,length(which(d$outside!=here)))
    d$outside[d$outside==here]=rep(1,length(which(d$outside==here)))
    d[d$outside==1,curz]=0
    
    curz[length(curz)+1]='outside'
    xideal[length(curz)]=1000;names(xideal)=curz
    work[length(curz)]=0;names(work)=curz
    #,curz]
    #d=d[d[,called]!=here,]
    #n=length(outsideids)
    #cat(' I now have', dim(d)[1],'students in
    #  the memory. As I removed ',n,' students who
    #  will take the elective abroad ')
  }
  
  request=newid[which(!newid %in% d$ID )]
  requested<-request_ids_to_add(request)
  d <-add_ids(d,requested,curz)
  return(d)
  }

add_ids=function(d,requested,curz){
  a=rep(length(curz),dim(d)[2]*length(requested))
  mat=matrix(a,nrow=length(requested))
  add_d<-as.data.frame(mat);colnames(add_d)=colnames(d)
  print(dim(add_d))
  add_d$ID=requested
  d[which(colnames(d)%in%curz)]=sapply(d[which(colnames(d)%in%curz)],as.numeric)
  d=rbind(d,add_d)
  print(dim(d))
  return(d)
  }


add_marks_to_form=function(d,newid,newmarks){
  d$markss=rep(0,dim(d)[1])
  for (lolo in 1: length(newid)){
     d$markss[which(d$ID == newid[lolo])] =newmarks[lolo]
  }
  d2<-d
  d<-d
  return(d)
}
#a=rep(0,length(curz))
#if (length(requested)>0){
  
#  data.frame(ID=requested,)
#  d2$ID=c(d2$ID,requested)
#}


#d$markss=rep(0,dim(d)[1])
#
#}


entry_mistake_checker=function(d,curz){
  #num=colnames(d)[which(colnames(d)%in% curz)]
  for (i in 1: length(curz)){
    mistake=which(is.na(as.numeric(as.character(d[,curz[i]]))))  #as.numeric(as.character(d[,curz[i]]))>length(curz)|
    d[,curz[i]][mistake]=0
    d[,curz[i]]=as.numeric(as.character(d[,curz[i]]))
  }

  #for (i in  num){
  #  p=sum(d[i,num])
  #  if (p==0){
  #    d=d[-i,]
  #  }
  d<-order_by_marks(d)
  return(d)
}

order_by_marks=function(d){
  d$markss=as.numeric(d$markss)
  d=d[order(as.numeric(d$markss),decreasing =T),]
  return(d)
}



request_ids_to_add=function(request){
  if (length(request)>0){
    cat('\nThe following students did not fill the form\n
        Are they with us? enter yes or no')
    readline(' press Enter')
    requested=vector()  
    u=0
    for (p in 1:length(request)){
      penter=readline(paste(request[p],' :'))
      if (penter=='yes'){
        u=u+1
        requested[u]=request[p]
      }
    }}
  return(requested)
  }

distribute_courses=function(d,work,xideal,curz){
  puma=(which(colnames(d)%in%curz))
  id=vector();mark=id;number=id;choice=id
  edit(d)
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
  plot2<-data.frame(id,mark,number,choice)
  return(plot2)
}

read_form()  

