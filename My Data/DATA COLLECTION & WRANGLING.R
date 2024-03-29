############################################################
############## DATA COLLECTION & WRANGLING #################
############################################################


# getting and setting working directory
if (!file.exists("My Data")) {
  dir.create("My Data")
}
setwd("./My Data")
getwd()

# downloading data file
fileurl <- "https://opendata.arcgis.com/datasets/7055dbb02f0c4f14ab7ea3eb5ebfda
42_0.csv?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D"

download.file(fileurl,destfile = "mycameras.csv")
list.files("./My Data")

date_downloaded <- date()
date_downloaded

# Reading text and csv files

# read.table
cdata <- read.table("mycameras.csv",header = TRUE,sep = ",")
cdata
head(cdata)

# read.csv
cameraData <- read.csv("mycameras.csv")
cameraData
head(cameraData)

# fread function from data.table library
library(data.table)
Cdata_fread <- fread("mycameras.csv")
Cdata_fread
head(Cdata_fread)

# Reading Excel Files 

library("xlsx")

cameraData <- read.xlsx("mycameras.xlsx",sheetIndex = 1,header = T)
cameraData
head(cameraData)

# reading specific rows and columns in excel
colIndex <- 2:3
rowIndex <- 1:4
cameraData_subset <- read.xlsx("mycameras.xlsx",sheetIndex = 1,
                               colIndex = colIndex,rowIndex = rowIndex)
cameraData_subset

# Reading Excel Files 2nd way
library("readxl")
readxl_example()

xlsx_example <- readxl_example("datasets.xls")
ex<- read_excel(xlsx_example)
ex
cd <- read_excel("mycameras.xlsx")
cd
head(cd)
excel_sheets(xlsx_example)
read_excel(xlsx_example,sheet = "quakes")
read_excel(xlsx_example,sheet =  4)
read_excel(xlsx_example,n_max = 3)
read_excel(xlsx_example,range = )

# write excel files 
library(writexl)
write_xlsx(cameraData,"mycamera.xlsx")

# openxlsx: Read, Write and Edit xlsx Files

library(openxlsx)

write.xlsx(cameraData,"mycamera.xlsx",asTable = T)





# Reading webpages 

# read html webpage
library(rvest)
theurl <- "https://en.wikipedia.org/wiki/Argentina_national_football_team"
file <- read_html(theurl)

# Read table from html webpage
tables <- html_nodes(file,"table")
table1 <- html_table(tables[1:4],fill = TRUE)
table1
print(table1)


### Reading From SQLITE

# loading RSQLite library
library(RSQLite)
data(mtcars)
mtcars$car_names <- row.names(mtcars)
row.names(mtcars) <- c()
head(mtcars)

# create or connect to database 
setwd("./My Data")
connect <- dbConnect(RSQLite :: SQLite(),"carsDB.db")

# write a table 
dbWriteTable(connect,"cars_data",mtcars)

# list all available data tables in database
dbListTables(connect)

# quick access functions 
dbListFields(connect,"cars_data")
dbReadTable(connect,"cars_data")


# exceuting SQL queries

dbGetQuery(connect,"SELECT * FROM cars_data LIMIT 10")

dbGetQuery(connect,"SELECT car_names,hp,cyl FROM cars_data
           where car_names LIKE 'M%' AND cyl in (6,8) ")

dbGetQuery(connect,"SELECT cyl,AVG(hp) AS 'average_hp',AVG(mpg) AS 'average_mpg'
           FROM cars_data
           GROUP by cyl
           ")

# Parameterized Queries

mpg <- 18
cyl <- 6

Result <- dbGetQuery(connect,"SELECT car_names,mpg,cyl FROM cars_data WHERE
                     mpg >= ? AND cyl >= ?", para = c(mpg,cyl))
Result

# statements that do not return tabular results

dbGetQuery(connect,"SELECT * FROM cars_data LIMIT 10")
dbExecute(connect, "DELETE FROM cars_data WHERE car_names = 'Mazda RX4'")
dbGetQuery(connect,"SELECT * FROM cars_data LIMIT 10")
dbExecute(connect, "INSERT INTO cars_data VALUES 
(21.0,6,160.0,110,3.90,2.620,16.46,0,1,4,4,'Mazda RX4')")
dbGetQuery(connect, "SELECT * FROM cars_data")

dbDisconnect(connect)

# dbSendQuery function

res <- dbSendQuery(connect,"SELECT * FROM cars_data where cyl = 8")
res
dbFetch(res)
dbClearResult(res)

# chunk at a time
res <- dbSendQuery(connect,"SELECT * FROM cars_data where cyl = 8") 
while (!dbHasCompleted(res)) {
  chunk <- dbFetch(res,n=5)
  print(nrow(chunk))
}
dbClearResult(res)
dbDisconnect(connect)

# MySQL Database
library(RMySQL)
?dbConnect
ucscDb <- dbConnect(MySQL(),user = "genome",host = "genome-mysql.cse.ucsc.edu")
result <- dbGetQuery(ucscDb,"show databases;")
result
dbDisconnect(ucscDb)

# connecting to a database
hg19 <- dbConnect(MySQL(),user="genome",db="hg19",host="genome-mysql.cse.ucsc.edu")
hg19
allTables <- dbListTables(hg19)
length(allTables)
allTables[1:5]


####################################################
############## USING DATA.TABLE ####################
####################################################

library(data.table)
DF = data.frame(x=rnorm(9),y=rep(c("a","b","c"),each=3),z=rnorm(9))
DF
head(DF,3)

DT = data.table(x=rnorm(9),y=rep(c("a","b","c"),each=3),z=rnorm(9))
DT
head(DT,3)
table(DT)

DT[,list(mean(x),sum(z))]
DT[,table(y)]

# adding new columns in data table
DT[,w:=z^2]
DT
DT[,a:=x>0]
DT

# merge data.table
DT1 <- data.table(x=c("a","a","b","dt1"),y=1:4)
DT2 <- data.table(x=c("a","b","dt2"),z=5:7)
setkey(DT1,x);setkey(DT2,x)
merge(DT1,DT2)
fsort(DT)

### Sub Setting and Sorting
set.seed(12345)
x <- data.frame("var1"=sample(1:5),"var2"=sample(6:10),"var3"=sample(11:15))
x
x <- x[sample(1:5),];x$var2[c(1,3)] <- NA
x
x[,1,drop=F]
x[,"var1"]
x[1:2,2,drop=F]
x[(x$var1 <= 3 & x$var3 >11),]
x[(x$var1 <= 3 | x$var3 >15),]

# sorting the values
sort(x$var1)
sort(x$var2)
sort(x$var3)

sort(x$var1,decreasing = T)
sort(x$var2,na.last = T)

# ordering in data frame 
x[order(x$var1,x$var2,x$var3),]
x[,]

DT[order(-DT$y,DT$z),]

# more in subsetting and sorting
set.seed(12345)
x <- data.frame("var1"=sample(1:5),"var2"=sample(6:10),"var3"=sample(11:15))
x
x[sample(1:5),];x$var2[c(1,3)]=NA
x
x[,1]
x[,"var2"]
x[1:3,"var3"]
x[(x$var1 <=3 & x$var3 > 11),]
sort(x$var1)
sort(x$var2,decreasing = T,na.last = T)

# sorting and ordering Data Frame in R 
title <- c('Data Smart','Orientalism','False Impressions','The Age of Wrath','Making Software')
author <- c('Foreman, John','Said, Edward','Archer, Jeffery','Eraly, Abraham','Oram, Andy')
height <- c('235','197','177','238','235')
year <- c('2010','2011','2012','1999','1998')
bookDF <-  data.frame(title, author, height, year)
bookDF
sorted_BookDF <- bookDF[order(bookDF[,1],decreasing = T),]
sorted_BookDF

## ordering or arranging by dplyr function
ordered_BookDF <- arrange(bookDF,desc(year))
ordered_BookDF

id <- c('S1002','S1003','S1005','S1008','S1011','S1015')
age <- c(58, 67,64, 34, 30, 37)
gender <- c('female','male','male','male','male','male')
height <- c(61, 67, 68, 71, 69, 59)
weight <- c(256, 119, 183, 190, 191, 170)
# Create a data frame
subjectDfrm <-  data.frame(id, age, gender, weight)
subjectDfrm
sortedSubjectDfrm <- arrange(subjectDfrm,age,weight,gender)
sortedSubjectDfrm
subjectDfrm %>% arrange(age,weight,gender) %>% head


# DEALING WITH MISSING VALUES

# Testing for missing values
x <- c(1:4,NA,5:7,NA)
x
is.na(x)
x[!is.na(x)]

# data frame with missing data 
df <- data.frame(col1 = c(1:3,NA),col2 = c("this",NA,"is","text"),
                 col3=c(T,F,T,T),col4=c(2.5,4.2,NA,NA),stringsAsFactors = FALSE)
is.na(df)
is.na(df$col4)
which(is.na(x))
which(is.na(df))

sum(is.na(df))
sum(is.na(x))
colSums(is.na(df))

## Record/Impute Missing values
x <- c(1:4,NA,6:7,NA)
x
x[is.na(x)] <- mean(x,na.rm = T)
x
round(x,2)
# with data frame
df <- data.frame(col1=c(1:3,99),col2=c(2.5,4.2,99,3.2))
df[df==99] <- NA
df

df <- data.frame(col1=c(1:3,NA),col2=c("this",NA,"is","text"),col3=c(T,F,T,T),
                 col4=c(2.5,4.2,3.2,NA),stringsAsFactors = F)
df$col4[is.na(df$col4)] <- mean(df$col4,na.rm=T)
df

## Excluding Missing Valuesssss
x <- c(1:4,NA,6:7,NA)
x
mean(x,na.rm = T)

df <- data.frame(col1=c(1:3,NA),col2=c("this",NA,"is","text"),col3=c(T,F,T,T),
                 col4=c(2.5,4.2,3.2,NA),stringsAsFactors = F)
complete.cases(df)
df[complete.cases(df),]
df[!complete.cases(df),]
na.omit(df)

### Dealing with missing values in Dataset airquality
datasets::airquality
x <- airquality
x
x$Ozone[is.na(x$Ozone)] <- mean(x$Ozone,na.rm = T)
x$Solar.R[is.na(x$Solar.R)] <- mean(x$Solar.R,na.rm = T)
x$Wind[is.na(x$Wind)] <- mean(x$Wind,na.rm = T)
x$Month[is.na(x$Month)] <- mean(x$Month,na.rm = T)
x$Temp[is.na(x$Temp)] <- mean(x$Temp,na.rm = T)
x$Day[is.na(x$Day)] <- mean(x$Day,na.rm = T)
x
round(x,2)

x$Ozone[is.na(x$Ozone)] <- median(x$Ozone,na.rm = T)
x$Solar.R[is.na(x$Solar.R)] <- median(x$Solar.R,na.rm = T)
x$Wind[is.na(x$Wind)] <- median(x$Wind,na.rm = T)
x$Month[is.na(x$Month)] <- median(x$Month,na.rm = T)
x$Temp[is.na(x$Temp)] <- median(x$Temp,na.rm = T)
x$Day[is.na(x$Day)] <- median(x$Day,na.rm = T)
x
round(x,2)


complete.cases(x)
x[!complete.cases(x),]
na.omit(x)

#######################################
######### SPLIT & APPLY ###############
#######################################

head(InsectSprays)
View(InsectSprays)

tapply(InsectSprays$count,InsectSprays$spray,sum)

spins <- split(InsectSprays$count,InsectSprays$spray)
spins
?split
?gl

sprcount <- lapply(spins,sum)
sprcount
unlist(sprcount)
sapply(spins,sum)


############################################
########## MERGE/JOIN DATAFRAME ############
############################################

# cbind in r

activity <- data.frame(opid=c("op01","op02","op03","op04","op05","op06","op07"),
                       units=c(23,43,21,32,13,12,32))
names <- data.frame(operator=c("Larry","Curly","Moe","Jack","Jill","Kim","Perry"))
logical <- data.frame(logic=c(T,F,T,T,T,T,T))
blended <- cbind(activity,names)
blended
# rbind in r
rblended <- rbind(blended,blended)
rblended

df1 <- data.frame(LETTERS,dfindex=1:26)
df2 <- data.frame(letters,dfindex=c(1:10,15,20,22:35))

# inner join
merge(df1,df2)

# outer join
merge(df1,df2,all = TRUE)

# different column names
names(df1) <- c("alpha","lotsaNumbers")

merge(df1,df2,by.x = "lotsaNumbers",by.y = "dfindex")


###############################################
########### TIDYVERSE LIBRARY #################
###############################################

msleep <- read.csv("msleep.csv")
msleep

head(msleep)
library(dplyr)
sleeptime <- select(msleep,genus,sleep_total)
head(sleeptime)
filter(msleep,order=='carnivora')

groups <- group_by(msleep,genus)
groups
levels(groups$genus)

mtcars_n <- mtcars
head(mtcars_n)
mtcars_n <- mutate(mtcars,mpg_cyl = mpg*cyl)
mtcars_n
?summarise

# Mutate in R along with ifelse and grepl
library(dplyr)
head(mutate(mtcars,disp_1 = disp/61.0237),3)
x <- 10
ifelse(x>9,"x is greater than 9","x is not greater than 9")

section <- c("MATH111","MATH111","ENG111")
grade <- c(78,93,56)
student <-c("Ghulam Nabi","Airaf","Zain")
gradebook <- data.frame(section,grade,student)
mutate(gradebook,Pass.Fail=ifelse(grade >60,"Pass","Fail"))
mutate(gradebook,letter=ifelse(grade %in% 60:69,"D",
                               ifelse(grade %in% 70:79,"C",
                                      ifelse(grade %in% 80:89,"B",
                                             ifelse(grade %in% 90:99,"A","F")))))
grepl("MATH",gradebook$section)
mutate(gradebook,department = 
         ifelse(grepl("MATH",section),"Math Department",
                                     ifelse(grepl("ENG",section),"English Department","Other")))


### pipeline function %>%
head(mtcars)
mtcars %>% group_by(cyl) %>% summarise(mean=mean(disp),n=n())

sub_m <- mtcars %>% select(mpg,cyl,disp,hp,gear,carb) %>% mutate(dispxhp=disp*hp)
names(sub_m)
table(sub_m$disp)

sub_m <- mtcars %>% select(mpg,cyl,disp,hp,gear,carb) %>% filter(carb %in% c(4,2,1))
table(sub_m$carb)

## practical examples of dplyr
sample_n(msleep,3) # selects randow rows 

sample_frac(msleep,0.1) # selecting Random Fraction of Rows

distinct(msleep) # Remove Duplicate Rows based on all the variables (Complete Row)

distinct(msleep,genus,.keep_all = T) # Remove Duplicate Rows based on a variable

distinct(msleep,genus,vore,.keep_all = T) # Remove Duplicates Rows based on multiple variables

# select ()
select(msleep,genus,vore:conservation)
select(msleep,c(genus,vore,conservation))
select(msleep,-genus,-vore)
select(msleep,-c(genus,vore))
select(msleep,starts_with("s")) #Selecting or Dropping Variables starts with 'Y'
select(msleep,-starts_with("s"))
select(msleep,contains("s")) # Selecting Variables contain 's' in their names
select(msleep,genus,vore,everything()) # Reorder Variables

# rename() function
rename(msleep,genuss=genus)

# filter() function
filter(msleep,vore == "herbi")
filter(msleep,vore %in% c("herbi","omni"))

# summarise() function
msleep
summarise(msleep,mean_sleeptotal= mean(sleep_total),
          median_sleeprem= median(sleep_rem,na.rm = T))
summarise_at(msleep,vars(sleep_total,sleep_rem),list(~mean(.),~median(.),~n()))
summarise_at(msleep,vars(sleep_total,sleep_rem),list(~n(),~median(.,na.rm = T),
                                                     ~sum(is.na(.)),~mean(.,na.rm =T)))
t <- msleep %>% group_by(vore) %>% summarise_at(vars(sleep_total,sleep_rem),
                                                funs(n(),mean(.,na.rm=T)))

t
### join() function

df1 = data.frame(ID = c(1, 2, 3, 4, 5),
                 w = c('a', 'b', 'c', 'd', 'e'),
                 x = c(1, 1, 0, 0, 1),
                 y=rnorm(5),
                 z=letters[1:5])
df2 = data.frame(ID = c(1, 7, 3, 6, 8),
                 a = c('z', 'b', 'k', 'd', 'l'),
                 b = c(1, 2, 3, 0, 4),
                 c =rnorm(5),
                 d =letters[2:6])
df3 <- inner_join(df1,df2,by="ID")
df3
left_join(df1,df2,by="ID")
right_join(df1,df2,by="ID")

# applying intersect
mtcars$model <- rownames(mtcars)
first <- mtcars[1:20,]
second <- mtcars[10:32,]
intersect(first,second)
mtcars
setdiff(first,second)

# applying union
x=data.frame(ID = 1:6, ID1= 1:6)
y=data.frame(ID = 1:6,  ID1 = 1:6)
union(x,y)
union_all(x,y)
?setdiff

# tidyr library
library(tidyr)

# separate function
df <- data.frame(x=c("a:1","b:2","c:3","d:4"))
df
df %>% separate(x,c("Key","Value"),":") %>% str

# spread function
data <- data.frame(variable1= rep(LETTERS[1:3],each=3),
                   variable2=rep(paste0("factor",c(1,2,3)),3),num=1:9)
data
spread(data,variable2,num)

# gather function
head(iris)
mini_iris <- iris %>% group_by(Species) %>% slice(1)
mini_iris
mini_iris %>% gather(key="flower_att",value = "measurement",-Species)

# unite function
merged <- unite(mtcars,"vs_am",c("vs","am"))
merged



