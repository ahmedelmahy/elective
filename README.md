# elective
This script is written in R to distribute students at Faculty of medicine, Alexandria university to their electives based of their choices with priority to students with higher grades.

# How to run it ?

* Download R on your computer for windows from [here](https://cran.r-project.org/bin/windows/base/R-3.3.1-win.exe) and install it (don't change any thing; just next,next...finish).

* Download the R script that I made. Right click on [here](https://raw.githubusercontent.com/ahmedelmahy/elective/master/elective.R) and choose save link as.

* Go to Start->all programs-> R.

* R will open, copy and paste the following:
```R
source(file.choose())
```
A dialog will open choose the R script that you downloaded whose name is 'elective.R' .


## Design the Google Form well.
Design a Google form that has a format like [this](https://docs.google.com/forms/d/e/1FAIpQLSdZWX7qiIEo-gFScxqoMNtq2hnE7jsE7dwIwrjn-adwGxhiuw/viewform), All courses names, A question about the ID and additional questions. After all students have filled the form, download the google form responses as .csv file

# How the program works ?
The program do these steps in order (to improve the program we will just add more steps).
1- A dialog will open to choose the csv file that you just downloaded.

2-the program will count the number of entries and remove dublicated entries (i.e students who filled the form more than one, only their last fill will stay) , the program will print a list of students who entered more than once to make things accurate.

3-
