if (!require('gWidgets')) install.packages('gWidgets'); library('gWidgets')
if (!require('RGtk2Extras')) install.packages('RGtk2Extras'); library('RGtk2Extras')

options(guiToolkit="RGtk2")


read_form <-function(){
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
    formpath<<-svalue(form)
    wdpath<<-svalue(saveto)
    if (wdpath!='Select a Folder'){setwd(wdpath)}
    dat<<-read.csv(formpath,encoding='UTF-8')
    dispose(window)
    read_marks_and_courses(dat)
  })
  visible(window) <- TRUE
}
read_form()