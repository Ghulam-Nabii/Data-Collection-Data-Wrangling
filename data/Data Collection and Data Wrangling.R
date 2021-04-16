# set and get working directory



if(!file.exists("data")){
  dir.create("data")
}
setwd("./data")
getwd()

# Downloading Data File from Web

fileUrl <- "https://s3.amazonaws.com/bsp-ocsit-prod-east-appdata/datagov/wordpress/2019/09/opendatasites91819.csv"
download.file(fileUrl,destfile = "states.csv",method = "curl")
list.files("./data")

dateDownloaded <- date()
dateDownloaded

# structure of Data

str(OpenSites)

# Reading in csv file
OpenSites <- read.csv("states.csv")
OpenSites

# fread faster function

library(data.table)
fread("states.csv")

# Reading Excel Files


library("readxl")
readxl_example()

OpenSites <- read_excel("states.xlsx")

install.packages("rJava")


library("xlsx")
read.xlsx2("states.csv",sheetIndex = 1)


# Reading HTML Pages

library(rvest)
theurl <- "https://en.wikipedia.org/wiki/History_of_the_Portugal_national_football_team"

file <- read_html(theurl)

# Read table from webpage 

tables <- html_nodes(file,"table")
tables
table1 <- html_table(tables,fill = T)
table1

print(table1)

# Reading text from movie 

lego_movie <- read_html("http://www.imdb.com/title/tt1490017/")
rating <- lego_movie
ratiing <- html_nodes(rating,"strong span")
rating1 <- html_text(ratiing)
as.numeric(rating1)

# now cast of movie

cast <- lego_movie
cast1 <- html_nodes(cast,"#titleCast .primary_photo img")
cast2 <- html_attr(cast1,"alt")
cast2

# Poster of the movie

poster <- lego_movie
poster1 <- html_nodes(poster,".poster img")
poster2 <- html_attr(poster1,"src")
poster2

# Reading from Databases

# load RSQLITE library
library(RSQLite)

# load the mtcars as an R data frame put the row names as a column and print
# header
data("mtcars")
mtcars$car_names <- row.names(mtcars)
rownames(mtcars) <- c()
head(mtcars)

### creating databases and table

# create or connect to the database
connect <- dbConnect(RSQLite::SQLite(),"CarsDB.db")

# write the mtcars dataset into a tables names mtcars_data
dbWriteTable(connect,"cars_data",mtcars)

# list all the available tables in the database
dbListTables(connect)

# quick access functions
dbListFields(connect,"cars_data")
rdd<- dbReadTable(connect,"cars_data")
rdd

#### Executing SQL Queries

dbGetQuery(connect,"SELECT * FROM cars_data LIMIT 5")

dbGetQuery(connect,"SELECT car_names,hp,cyl FROM cars_data where cyl = 8")

dbGetQuery(connect,"SELECT car_names,hp,cyl FROM cars_data where car_names 
LIKE 'M%' AND cyl in (6,8)")

dbGetQuery(connect,"SELECT cyl,AVG(hp) AS 'average_hp',
           AVG(mpg) AS 'average_mpg' FROM cars_data
           GROUP by cyl
           ORDER by average_hp")

dbGetQuery(connect,"SELECT cyl,AVG(hp) as 'average_hp' FROM cars_data
           GROUP by cyl
           ORDER by average_hp")

### PARAMETERIZED QUERY

mpg <- 18
cyl <- 6
Result <- dbGetQuery(connect,"SELECT car_names,mpg,cyl FROM cars_data
                     WHERE mpg >= ? AND cyl >= ?", params = c(mpg,cyl))
Result


### Statements that do not return tabular Results

# visualise the data before deletion
dbGetQuery(connect,"SELECT * FROM cars_data LIMIT 10")

# Delete the column belonging to Mazda RX4
dbExecute(connect,"DELETE FROM cars_data where car_names ='Mazda RX4'")

# visualise the new table after deletion
dbGetQuery(connect,"SELECT * FROM cars_data LIMIT 10")

# Insert the data for Mazda RX4 
dbExecute(connect,"INSERT INTO cars_data VALUES (21.0,6,160.0,110,3.90,2.620,16.46,0,1,4,4,'Mazda RX4')")

# Mazda RX4 re introduced

dbGetQuery(connect,"SELECT * FROM cars_data")

# disconnect from database

dbDisconnect(connect)

#####################################
##########dbSendQuery################
#####################################

# you can fetch all results
res <- dbSendQuery(connect,"SELECT*FROM cars_data where cyl = 6")
res
dbFetch(res)

# clear the results
dbClearResult(res)

# chunk at a time 
res <- dbSendQuery(connect,"SELECT*FROM cars_data where cyl = 6")
while(!dbHasCompleted(res)){
  chunk <- dbFetch(res,n=5)
  print(nrow(chunk))
}

# clear the result
dbClearResult(res)

# Disconnect from Data Base
dbDisconnect(connect)


############################################
############## data.table ##################
############################################

library(data.table)
# data.frame
DF <- data.frame(x=rnorm(9),y=rep(c("a","b","c"),each = 3),z=rnorm(9))
DF
head(DF,3)
# data.table
DT <- data.table(x=rnorm(9),y=rep(c("a","b","c"),each = 3),z=rnorm(9))
DT
head(DT,3)

# See all data tables in memory
tables()

# calculating values for variables with expressions

DT[,list(mean(x),sum(z))]
DT[,table(y)]

# Adding new columns
DT[,w:=z^2]
DT

DT[,a:=x>0]
DT

# Merge data.table
DT1 <- data.table(x=c("a","a","b","dt1"),y=1:4)
DT2 <- data.table(x=c("a","b","dt2"),z=5:7)
setkey(DT1,x);setkey(DT2,x)
merge(DT1,DT2)
msleep <-read.csv("msleep_200908_125135.csv")
head(msleep_200908_125135)
