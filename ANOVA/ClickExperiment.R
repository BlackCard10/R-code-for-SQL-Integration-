
library(DBI)
library(dplyr)
library(ggplot2)
library(car)



# Assume a test situation for the location of a button on a page where there are four
# distinct locations { 'top left', 'bottom left', 'top right', 'bottom right'}.  You randomly assign 
# users to a condition and collect the number of times he/she clicked the button over a one 
# week period.  Your goal is to find out if there is a meaningful difference between the 
# mean number of clicks for any given location of a button over one week period. 



# Connect to the sqlite file
con = dbConnect (RSQLite::SQLite(), dbname = "~/Desktop/R Project/SQL Lite/funWithMYSQL/R-code-for-SQL-Integration-/Chinook_Sqlite.sqlite")


# Create a new table in the database that will hold the result of the experiment
Create_ClickTable <- dbGetQuery(con, "CREATE TABLE Clicks ( 
						subject INTEGER PRIMARY KEY, 
						condition VARCAR(20),
						clicks INTEGER
						)" )
		
		
# Fill the table with the experimental data from the test 
dbGetQuery(con, "INSERT INTO Clicks ('condition', 'clicks')
					VALUES('top left', '12'), ('top right', '17'), ('bottom right', '14'),
					('bottom left', '15'), ('top left' ,'10'), ('top right', '19') , ('bottom right', '11'),
					('bottom left', '12'), ('top left', '11'), ('top right', '14') , ('bottom right', '13'), 
					('bottom left', '12'), ('top left', '11'), ('top right', '16'), ('bottom right', '10'), 
					('bottom left', '14') " ) 


# Connect to the sqlite file
con = dbConnect (RSQLite::SQLite(), dbname = "~/Desktop/R Project/SQL Lite/funWithMYSQL/R-code-for-SQL-Integration-/Chinook_Sqlite.sqlite")



# Pull all values from the DB from the experiment
ClicksDF <- dbGetQuery(con, "SELECT * FROM Clicks")



# View the format of the DF and change type condition to a factor
str(ClicksDF)
ClicksDF$condition <- as.factor(ClicksDF$condition)



# Calculate the mean number of clicks by condition
ConditionMean <- tapply(ClicksDF$clicks, ClicksDF$condition, mean)



# Plot the mean number of clicks by condition
Clicksplot <- ggplot(ClicksDF, aes(x = ClicksDF$condition, y = ClicksDF$clicks)) + 
  geom_boxplot(color = "Red") + labs(x = "Condition", y = "Clicks") + theme(panel.background = element_rect(fill = "darkgrey"))



# Check for homogeniety of variance across conditions
leveneTest(ClicksDF$clicks ~ ClicksDF$condition, center = mean, ClicksDF)



# Complete an ANOVA test to access if the mean differneces are significant
ClickAnova <- aov(ClicksDF$clicks ~ ClicksDF$condition, ClicksDF)

summary(ClickAnova)



# Calculate TukeyHSD as a posthoc test to correct for familywise error rate
TukeyClicks <- TukeyHSD(ClickAnova)



# Compute pairwise T test to find significant condition diffences in means 
pairwise.t.test(ClicksDF$clicks, ClicksDF$condition, p.adjust.method = "bonferroni")


























					
					
					
