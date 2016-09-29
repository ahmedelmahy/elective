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
The program do these steps in order (to improve the program we will just add more steps). the program will ask you in a user friendly way.

1- A dialog will open to choose the csv file that you just downloaded.

2- the program will ask you to enter the number of students needed for every course (Enter 0 if the course was deleted later).

3-the program will ask you to tell him which question contains the IDs of the students.

4-the program will ask you if there is a question of peope to be excluded e.g. those who will take it outside Egypt and the answer to be excluded i.e. 'yes'.

5-the program will count the number of entries and remove dublicated entries (i.e students who filled the form more than one, only their last fill will stay) , the program will report later a list of students who entered more than once to make things accurate.

## Now Enter the marks
You need to have an Excel file containing the results of the students

6-the program will ask you to enter IDs of the students , open the Excel file and copy the IDs of all students whom this elective is for.  then paste it -every ID in a line.

7-the program will ask you to enter IDs of the students whom ID you have just copied, go back to the excel file copy their results. then paste it -every mark in a line corresponding the lines of the IDs (the program will not continue except that marks correspond to the IDs- Don't worry about students whose marks are empty or raseb the program also will not recognize them and the will be left down and distributed randomly -If you intend to manually give them a results this easy but you will suffer summing their results).

8-

