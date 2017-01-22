if (!require('ReporteRs')) install.packages('ReporteRs'); library('ReporteRs')
library('gWidgets')
options( "ReporteRs-fontsize" = 12,
         "ReporteRs-default-font" = "Arial")#,
 #        "ReporteRs-locale.language"='ar')
#,
 #        "ReporteRs-locale.region"='EG')

a=c(1,2,3,4,
    paste('اول تاني تالت رابع')
          )
rcs=data.frame(a,b=c(1:5),c=c(1:5))
flex<-FlexTable(rcs,header.columns=F,
                body.par.props=parCenter())#,
               # body.cell.props=cellProperties(text.direction = "tbrl"))#,body.cell.props=cellProperties(border.left.style
                                            #                              ="none",border.right.style="none"))
flex
flex<-setFlexTableWidths(flex,width=c(3,2,1))
flex=addHeaderRow(flex,c('hh','','n'),first=T,
                  par.properties=parCenter(),
                  cell.properties=cellProperties(border.left.style="none",
                                                 border.right.style="none",border.bottom.style="none"))
flex
doc<-bsdoc()
#doc <- addTitle( doc, "The big title")#, level = 1 )
doc <- addParagraph(doc, pot('The big title', textProperties(font.weight = "bold")),par.properties= parProperties(text.align = "center",padding.bottom = 3,  padding.top = 3,padding.left = 1, padding.right = 1))

doc<-addFlexTable(doc,flex )

#,                  ,par.properties=parCenter())


#saveto=choose.dir(getwd(), "save to")
#writeDoc(doc,file= paste(saveto,'\\test.docx',collapse='',sep=''))
writeDoc(doc,file= 'testtkkkkk.html')
writeDoc(doc,file= 'testtkkkkk.docx')
