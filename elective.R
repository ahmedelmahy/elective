if (!require('gWidgets')) install.packages('gWidgets'); library('gWidgets')
if (!require('gWidgetsRGtk2')) install.packages('gWidgetsRGtk2'); library('gWidgetsRGtk2')
if (!require('RGtk2Extras')) install.packages('RGtk2Extras'); library('RGtk2Extras')
if (!require('ReporteRs')) install.packages('ReporteRs'); library('ReporteRs')
if (!require('ggplot2')) install.packages('ggplot2'); library('ggplot2')
if (!require('gridExtra')) install.packages('gridExtra'); library('gridExtra')
if (!require('grid')) install.packages('grid'); library('grid')
options(show.error.locations = TRUE)
options(warn=-1)
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
  #dff=data.frame(id='',marks='')
  #marksfile<-dfedit(dff)
  markslink="https://docs.google.com/spreadsheets/d/1_P1IaWKQp5M478r46NQrao5v-vGeylYnB1cf9lQROrk/pub?output=csv"
  marksfile<-read.csv(markslink,encoding='UTF-8')
  colnames(marksfile)=c('id','names','marks')
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
  
  cat('Choose the question containing the names\n\n')  ##Identify the ID variable
  didylist2<-colnames(d)[which(!(colnames(d) %in% curz))]
  idid<-select.list(didylist2,title='Which one ?')
  colnames(dat)[colnames(dat)==idid]<-'originalname'
  
  d<-dat[!rev(duplicated(rev(dat$ID))),]
  #enteredmore<-unique(dat$ID[rev(duplicated(rev(dat$ID)))])   #report 1 #added unique
  #prevd<-read_prev(curz)
  #d<-remove_prev(d,prevd)
  plot2<<-add_marks(d,as.character(marksfile$id),marksfile$marks,marksfile$names,xideal,work,curz,didylist)
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







add_marks=function(d,newid,newmarks,newnames,xideal,work,curz,didylist){
  #newid=as.character(marksfile$id);newmarks=as.character(marksfile$marks)
  notfound=d$ID[which(!(d$ID %in% newid))]
  if (length(notfound)>0){
    cat('\n The following students filled the form\n
        and their marks are not found enter the marks, 0 to randommly distribute them, or no to exclude them\n
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
  
  plot2=check_outside(d,xideal,work,curz,newid,newmarks,newnames,didylist)
  #d<-add_marks_to_form(d,newid,newmarks)
  #plot2<-distribute_courses(d,work,xideal,curz)
  return(plot2)
}

check_outside=function(d,xideal,work,curz,newid,newmarks,newnames,didylist){
  cat('\n\n\nElective Outside\n')
  readline('press Enter')
  isthere= select.list(c('yes there is a question about elective outside','no'))
  if (isthere=='yes there is a question about elective outside'){
    called=select.list(didylist,title='Which one of these questions?')
    cat('\n\nWhich answer to keep ?')
    here=select.list(levels(d[,called]),title='Which answer to keep? choose NO')
    outsideids=as.character(d$ID[d[,called]!=here])
    #print(outsideids)
    colnames(d)[colnames(d)==called]='outside'
    #
    #d2=d
    #d=d2
    d$outside=as.character(d$outside)
    d$outside[d$outside!=here]=rep(1,length(which(d$outside!=here)))
    d$outside[d$outside==here]=rep(0,length(which(d$outside==here)))
    
    d[d$outside==1,curz]=0
      #as.data.frame(matrix(0,nrow=sum(d$outside==1),ncol=length(curz)))

    #c=curz x=xideal
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
  request=request[!is.na(request)]
  requested<-request_ids_to_add(request)
  
  d <-add_ids(d,requested,curz)
  d <-add_marks_to_form(d,newid,newmarks,newnames)  
  plot2=distribute_courses(d,work,xideal,curz)
  return(plot2)
  }

add_ids=function(d,requested,curz){
  a=rep(length(curz),dim(d)[2]*length(requested))
  mat=matrix(a,nrow=length(requested))
  
  add_d<-as.data.frame(mat);colnames(add_d)=colnames(d)
  print(dim(add_d))
  add_d$ID=requested
  if (length(add_d)<length(d)){
  add_d$outside=0  #probably use try
  }
  #d<-entry_mistake_checker(d,curz)
  d[which(colnames(d)%in%curz)]=sapply(d[which(colnames(d)%in%curz)],as.character)
  d[which(colnames(d)%in%curz)]=sapply(d[which(colnames(d)%in%curz)],as.numeric)
  d[is.na(d)]=length(curz)
  d=rbind(d,add_d)

  
  return(d)
  }


add_marks_to_form=function(d,newid,newmarks,newnames){
  d$markss=rep(0,dim(d)[1])
  d$namess=rep('name!',dim(d)[1])
  for (lolo in 1: length(newid)){
     d$markss[which(d$ID == newid[lolo])] =newmarks[lolo]
     d$namess[which(d$ID == newid[lolo])] =as.character(newnames[lolo])
     
  }
  #d2<-d
  #d<-d
  d<-order_by_marks(d)
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


#entry_mistake_checker=function(d,curz){
  #num=colnames(d)[which(colnames(d)%in% curz)]
  #for (i in 1: length(curz)){
    #mistake=which(is.na(as.numeric(as.character(d[,curz[i]]))))  #as.numeric(as.character(d[,curz[i]]))>length(curz)|
    #d[,curz[i]][mistake]=0
    #d[,curz[i]]=as.numeric(as.character(d[,curz[i]]))
  #}

  #for (i in  num){
  #  p=sum(d[i,num])
  #  if (p==0){
  #    d=d[-i,]
  #  }
  
#  return(d)
#}

order_by_marks=function(d){
  d$markss=as.numeric(d$markss)
  d=d[order(as.numeric(d$markss),decreasing =T),]
  
  return(d)
}



request_ids_to_add=function(request){
  if (length(request)>0){
    cat('\nThe following students did not fill the form\n
        Are they with us? select all students you want to include')
    readline(' press Enter')
    #requested=vector()  
    #u=0
    #re=c('1a',2,3)
    requested=select.list(request,multiple = TRUE,graphics=TRUE)
    #for (p in 1:length(request)){
     # penter=readline(paste(request[p],' :'))
      #if (penter=='yes'){
      #  u=u+1
      #  requested[u]=request[p]
      #}}
  }
  return(requested)
  }

distribute_courses=function(d,work,xideal,curz){
  if("outside" %in% colnames(d)){d$outside[d$outside>1]=0} #work around as some were 12
  puma=(which(colnames(d)%in% curz))
  id=vector();mark=id;number=id;choice=id;namess=id
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
          if (!is.na(d$namess[i])){namess[ii]=d$namess[i]}
          if (is.na(d$namess[i])){namess[ii]=paste('*',d$originalname[i])}
          
          #namees[ii]
          work[which(curz==ost)]=(work[which(curz==ost)])+1
          break
        }
      }
    }}
  plot2<-data.frame(id,namess,mark,number,choice)
  #----------------------------------------------
  ##
  plot1=rep(0,length(curz));names(plot1)=curz
  d2=d
  d2[,puma][d2[,puma]>length(puma)]=length(puma)
  d2[,puma][d2[,puma]==0]=length(puma)
  for (i in 1:dim(d2)[1]){
    #i=1
    s=sort(d2[i,][puma])
    for (j in 1: length(s) ){
      #j=5
      ost=names(s[j])
      plot1[which(curz==ost)]= plot1[which(curz==ost)]+length(s)-s[1,j] #+1-j
    }
  }
  pdf('A statistical report.pdf')
  #--------------
  plot(0:10, type = "n", xaxt="n", yaxt="n", bty="n", xlab = "", ylab = "")
  text(5, 8, "A statistical report") 
  text(5,6,"To include research questions")
  text(5, 5, "that aim to survey or test")
  text(5, 4, "a specific hypothesis for improving the")
  text(5, 3, "elective courses please contact me:")
  text(5, 2, "elmahy2005@gmail.com; 01016234359")
  #----
  barplot(sort(plot1,decreasing = F),col= terrain.colors(length(plot1),1),horiz = T,legend=T,
          yaxt='n', ann=FALSE, main='Graph1:\n Courses arranged by students preferences',
          sub='Courses with small bars are courses that students dislike and should be
        either improved or deleted',legend.text=T,args.legend=list(x='bottomright'))
  
  #----------------------
  hist(plot2$mark,breaks=dim(plot2)[1]/8,main='A histogram of the marks of the students involved',col='blue3',xlab='Marks')
  #------
  par(mar = c(13, 4, 4, 2) + 0.1,cex.axis=.9)
  boxplot(plot2$mark~plot2$choice,col='green',main='A boxplot that presents the relation between marks and choices',las=2)

  dev.off()
  ##
  #-------------------------------
  final_report_per_id(plot2)
  #plot2=read.csv("final_report_per_id.csv",encoding = 'UTF-8')
  final_report_per_course(plot2)
  Sys.setlocale("LC_ALL","English_United States.1252") #LC_CTYPE
  #options(encoding='native.enc')
  return(plot2)
}

final_report_per_id=function(plot2){
  plot2a=plot2[which(!is.na(as.numeric(as.character(plot2$id)))),]
  plot2b=plot2[which(is.na(as.numeric(as.character(plot2$id)))),]
  plot2a=plot2a[order(as.numeric(as.character(plot2a$id))),]
  plot3=rbind(plot2a,plot2b)
  Sys.setlocale("LC_ALL","arabic")
  #options(encoding='UTF-8')
  write.csv(plot3, file = "final_report_per_id.csv",row.names = F,fileEncoding='UTF-8')
}
final_report_per_course=function(plot2){
  dff=data.frame(as.character(plot2$id),as.character(plot2$namess),as.character(plot2$choice));colnames(dff)=c('id','name','choice')
  #dff=dff[order(as.character(dff$choice)),]
  curz=names(summary(plot2$choice))
  doc<-docx()
  doc2<-bsdoc()
  for (i in 1:length(curz)){
    dffid=dff$id[which(dff$choice==curz[i])]
    dffname=dff$name[which(dff$choice==curz[i])]
    cu=curz[i]
    fileConn<-file(paste(cu,"report.txt",collapse=''),encoding='UTF-8')
    txt4=paste('The elective course   ',
               cu,
               ' has the following students IDs: \n\n\n\n',
               paste(dffid,',',dffname, collapse='\n'))
    writeLines(txt4, fileConn)
    close(fileConn)
    
    
    
    
    
    options( "ReporteRs-fontsize" = 12,
             "ReporteRs-default-font" = "Arial",
             "ReporteRs-locale.language"='arabic',
             "ReporteRs-locale.region"='EG')
    ldoc=length(dffid)
    dfdoc=data.frame(index=1:ldoc,dffname,dffid)
    
    
    if(dim(dfdoc)[1]>15){
      png(paste(cu,"report.png",collapse=''),height=550, width=610)
    p<-tableGrob(dfdoc[1:round(dim(dfdoc)[1]/2),],cols=c("index","names","ID"),rows=NULL)
    p2<-tableGrob(dfdoc[(round(dim(dfdoc)[1]/2)+1):dim(dfdoc)[1],],cols=c("index","names","ID"),rows=NULL)
    grid.arrange(p,p2,top=textGrob(cu, gp=gpar(fontsize=20,fontface="bold"),just="top"),nrow=1)
    }
    if(dim(dfdoc)[1]<16){
      png(paste(cu,"report.png",collapse=''),height=480, width=300)
      p<-tableGrob(dfdoc,cols=c("index","names","ID"),rows=NULL)
      grid.arrange(p,top=textGrob(cu, gp=gpar(fontsize=20,fontface="bold"),just="top"))
    }
    
    
    dev.off()
    
    
    
    flex<-FlexTable(dfdoc,header.columns=F,body.par.props = parCenter(),
                    body.cell.props=cellProperties(text.direction = "tbrl"))
    flex2<-FlexTable(dfdoc,header.columns=F,body.par.props = parCenter(),
                    body.cell.props=cellProperties(text.direction = "tbrl"))
    flex<-setFlexTableWidths(flex,width=c(1,4,2))
    flex2<-setFlexTableWidths(flex2,width=c(1,4,2))
    flex=addHeaderRow(flex,c('index','name','id'),first=T,
                      par.properties=parCenter(),
                      cell.properties=cellProperties(border.left.style="none",
                                                     border.right.style="none",border.bottom.style="none"))
    flex2=addHeaderRow(flex2,c('index','name','id'),first=T,
                      par.properties=parCenter(),
                      cell.properties=cellProperties(border.left.style="none",
                                                     border.right.style="none",border.bottom.style="none"))
    
    doc <- addParagraph(doc, pot(paste(cu,'\n','number of the students is ',ldoc,'\n',collapse=''),textProperties(font.weight = "bold")),
                        par.properties= parProperties(text.align = "center"))
    
    doc2 <- addParagraph(doc2, pot(paste(cu,'\n','number of the students is ',ldoc,'\n',collapse=''),textProperties(font.weight = "bold")),
                        par.properties= parProperties(text.align = "center"))
    
    doc<-addFlexTable(doc,flex)
    doc2<-addFlexTable(doc2,flex2)
    doc <- addPageBreak(doc)
    #doc2 <- addPageBreak(doc2)
  }
  writeDoc(doc,file= "final report.docx")
  writeDoc(doc2,file= 'final report.html')
}

read_form()  

