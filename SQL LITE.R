library(DBI)
library(RSQLite)
library(leaflet)
library(dplyr)


# Connect to the sqlite file
con = dbConnect (RSQLite::SQLite(), dbname = "~/Desktop/R Project/SQL Lite/funWithMYSQL/R-code-for-SQL-Integration-/Chinook_Sqlite.sqlite")


# Get a list of all tables and view the tables
alltables = dbListTables(con)


# Turn all tables into Data Frames containing the first five rows of every table.  Include names of tables. s
 A <-  list()
  for (i in 1:length(alltables)) {
   A[[i]] <- dbGetQuery(con, paste0("SELECT * FROM ",  alltables[i], " LIMIT 5"))
    }


# Name A properly.  Use A as a way to preview top line items from large DBs.
names(A) <- alltables


# Calculate how much money was spent by each customer in the db

Total_Spent <- dbGetQuery(con, "SELECT Customer.CustomerId, Customer.LastName, Customer.FirstName AS Name, SUM(Invoice.Total) AS Total  
				   FROM Customer 
				   INNER JOIN Invoice ON (Customer.CustomerId = Invoice.CustomerId)
				   GROUP BY Customer.CustomerId")


# What media artist was the most popular artist in the db (by purchase $$)?

Popular_Artist <- dbGetQuery(con, "SELECT MAX(Total), Artist FROM (
				   SELECT SUM(Invoice.Total) AS Total, Artist.name As Artist
				   FROM Invoice 
				   JOIN InvoiceLine ON (Invoice.InvoiceId = InvoiceLine.InvoiceId)
				   JOIN Track ON (InvoiceLine.TrackId = Track.TrackId)
				   JOIN Album ON (Track.AlbumId = Album.ArtistId)
				   Join Artist ON (Album.ArtistId = Artist.ArtistId)
				   GROUP BY Artist.ArtistId
				   ORDER BY Total )") 


# What song was the most popular in the db (by purchase $$)

Popular_Song <- dbGetQuery(con, "SELECT MAX(Total), Track, Artist  FROM (
				   SELECT SUM(Invoice.Total) AS Total, Track.Name AS Track, Artist.name AS Artist
				   FROM Invoice 
				   JOIN InvoiceLine ON (Invoice.InvoiceId = InvoiceLine.InvoiceId)
				   JOIN Track ON (InvoiceLine.TrackId = Track.TrackId)
				   JOIN Album ON (Track.AlbumId = Album.ArtistId)
				   JOIN Artist ON (Album.ArtistId = Artist.ArtistId)
				   GROUP BY Track.TrackId, Artist.ArtistId )")
				   
				   				   
# Which cities in the database are top consumers of classical music?  

Classical_Lovers <- dbGetQuery(con, "SELECT Invoice.BillingCity, SUM(InvoiceLine.Quantity) AS Count
				   FROM Invoice 
				   JOIN InvoiceLine ON (Invoice.InvoiceId = InvoiceLine.InvoiceId)
				   JOIN Track ON (InvoiceLine.TrackId = Track.TrackId)
				   JOIN Genre ON (Track.GenreId = Genre.GenreId)
				   WHERE Genre.Name = 'Classical'
				   GROUP BY Invoice.BillingCity
				   ORDER BY Count DESC
				   Limit 50")
		
		
# Change the name of San Jose de... to "San Jose""
Classical_Lovers[11,1] <- "San Jose"


# Plot Classical_Lover
Classical_Plot <- ggplot(Classical_Lovers, aes(x = BillingCity, y = Count)) + geom_bar(stat = "Identity", fill = "Blue", alpha = .8)
                
                  
# Add a theme to Classical Lover
Classical_Plot + theme(axis.text = element_text(size = 7), panel.background = element_rect(fill = "White"))

                                    
                  
# Which artist was the most popular in each given state and how many singles did each sell? 

Popular_US  <- dbGetQuery(con, "SELECT Invoice.BillingState, SUM(InvoiceLine.Quantity) AS Sales 
				   FROM InvoiceLine 
				   JOIN Invoice ON (InvoiceLine.InvoiceId = Invoice.InvoiceId)
				   WHERE Invoice.BillingCountry = 'USA'
				   GROUP BY Invoice.BillingState ")
	
				   
# Update the customer table.  Update the telephone number for the Customer "Leone Kohler". 
# Insert a new record into the the Customers table.  

Update1 <- dbGetQuery(con, "UPDATE Customer SET Company = 'Bavarian Motor Works' WHERE CustomerId = 2 ") 

Update2 <- dbGetQuery(con, "INSERT INTO Customer('FirstName', 'LastName', 'Company', 
					'Address', 'City', 'State', 'Country', 'Email')
					VALUES('John', 'Hamilton', 'DataCompany INC', '1212 Bay Area St.', 
					'San Francisco', 'CA', 'USA', 'John.Hamilton@Dataco.com') ")
           
	Update1
	Update2
                    
# Reconnect to the sqlite file to pull changes to DB
con = dbConnect (RSQLite::SQLite(), dbname = "~/Desktop/R Project/SQL Lite/funWithMYSQL/Chinook_Sqlite.sqlite")


# Get a list of all tables and view the tables
alltables = dbListTables(con)


# Turn all tables into Data Frames
A <-  list()
for (i in 1:length(alltables)) {
  A[[i]] <- dbGetQuery(con, paste0("SELECT * FROM ",  alltables[i], " LIMIT 5"))
}

# Name A properly.  Use A as a way to preview top line items from large DBs.
names(A) <- alltables             


# What is the total amount spent on music by country?  Who spends the most?
Exp_PerCountry <- dbGetQuery(con, "SELECT SUM(Invoice.Total) AS TotalExpenditure, Invoice.BillingCountry
 					FROM Invoice
 					GROUP BY BillingCountry
 					ORDER BY TotalExpenditure DESC")
 					

# Create a subset of the dataset that contains only the valiues from the USA

Address_USA <- dbGetQuery(con, "SELECT InvoiceId, CustomerId, BillingAddress, BillingCity, BillingState, BillingCountry, BillingPostalCode
					FROM Invoice
					WHERE BillingCountry = 'USA'")
	
					
# I used a third party Geocoding services from the University of Texas, to access the long
# lat of the fields using the address fields from the Address_USA dataset. The following is going to use this data.  
Geocodes <- read.csv("~/Desktop/R Project/SQL Lite/funWithMYSQL/R-code-for-SQL-Integration-/TestAddress.csv") 



# Data Manipulation to preserve only the relavant data rows we're after. 
Geocodes <- Geocodes[1:91,]	 
	 
	 
# Add the data from the geocode to the Address USA db	
Address_USA <- Address_USA %>% 
			     mutate(Latitude = as.numeric(Geocodes$Latitude), Longitude = as.numeric(Geocodes$Longitude)) 	


# Create just a subset of long/lat work with the maps data
Address_USAGeo <- Address_USA %>% select(Longitude, Latitude)


# Project the entire dataset on to the map with clustered markers 		     
m <- leaflet(Address_USAGeo) %>% addTiles() %>% addMarkers(	
		  clusterOptions = markerClusterOptions()
      )
	m 	  

# Build a dataframe of the customer Id, billing zipcode and a binary factor of whether a given
# purchase is for rock music.  
Rock_Mailer <- dbGetQuery(con, "SELECT Customer.CustomerId, Invoice.BillingPostalCode, 
					CASE 
						WHEN Genre.Name LIKE '%Rock%' THEN 1 
						ELSE 0
							END AS Rock_Me
					FROM Customer 
					JOIN Invoice ON (Customer.CustomerId = Invoice.CustomerId)
					JOIN InvoiceLine ON (Invoice.InvoiceId = InvoiceLine.InvoiceId)
					JOIN Track ON (Track.TrackId = InvoiceLine.TrackId)
					JOIN Genre ON (Track.GenreId = Genre.GenreId) 
					GROUP BY Invoice.BillingPostalCode ") 								

# Only use complete cases of Rock_Mailer
Rock_Mailer <- Rock_Mailer[complete.cases(Rock_Mailer),]



# Count the number of songs in the database that contain "rock" grouped by postal code.  
Rock_Count <- dbGetQuery(con, "SELECT Invoice.BillingPostalCode, COUNT(*) As Quantity
					FROM Customer 
					JOIN Invoice ON (Customer.CustomerId = Invoice.CustomerId)
					JOIN InvoiceLine ON (Invoice.InvoiceId = InvoiceLine.InvoiceId)
					JOIN Track ON (Track.TrackId = InvoiceLine.TrackId)
					JOIN Genre ON (Track.GenreId = Genre.GenreId) 
					WHERE Genre.Name LIKE '%Rock%' 
					GROUP BY Invoice.BillingPostalCode
					Order by Quantity DESC
					Limit 10 ") 		

# Query the database for a count of the number of times a song was sold grouped by duration of track
Longer_Better <- dbGetQuery(con, "SELECT COUNT(InvoiceLine.TrackId) AS Sales, Track.Milliseconds
					FROM InvoiceLine
					JOIN Track ON (InvoiceLine.TrackId = Track.TrackId)
					GROUP BY InvoiceLine.TrackID ")		
					
					
# Fit a logistic model to prdict sales using the length of a song
Test.glm <- glm(as.factor(Sales) ~ Milliseconds, family = "binomial", data = Longer_Better)


# View the results of the logistic model Test.glm
summary(Test.glm)


# Query the database for the dates of sales of songs by "Aerosmith" 
Aerosmith_dates <- dbGetQuery(con, "SELECT Invoice.InvoiceDate, InvoiceLine.UnitPrice
                      FROM Invoice JOIN InvoiceLine ON (InvoiceLine.InvoiceId = Invoice.InvoiceId)
                      JOIN Track ON (InvoiceLine.TrackId = Track.TrackId)
                      JOIN Album ON (Album.AlbumId = Track.AlbumId)
                      JOIN Artist ON (Artist.ArtistId = Album.ArtistId) 
                      WHERE Artist.Name = 'Aerosmith' ")

# Change format of the column to a date item 
Aerosmith_dates$InvoiceDate <- as.POSIXct(Aerosmith_dates$InvoiceDate)


# Create a new column for the Year, Month and Quarter for the Aerosmith Data
Aerosmith_datesSplit <- Aerosmith_dates %>% 
                        mutate(Year = as.integer(format(Aerosmith_dates$InvoiceDate, '%Y')), Month = as.integer(format(Aerosmith_dates$InvoiceDate, '%m')))


# Catagorize the Months by Financial Quarter
Aerosmith_datesSplit$Quarter <- 0

# Classify Month to Quarters
  for (i in 1:length(Aerosmith_datesSplit$Month)) {
    if (Aerosmith_datesSplit$Month[i] < 4) {
      Aerosmith_datesSplit$Quarter[i] = 1
    }
    else if (Aerosmith_datesSplit$Month[i] >= 4 & Aerosmith_datesSplit$Month[i] < 7) {
      Aerosmith_datesSplit$Quarter[i] = 2
    }
    else if (Aerosmith_datesSplit$Month[i] >= 7 & Aerosmith_datesSplit$Month[i] < 10) {
      Aerosmith_datesSplit$Quarter[i] = 3
    } 
    else { 
      Aerosmith_datesSplit$Quarter[i] = 4 
    } 
  }
  
  
# Return all of the invoices which were generated in the last 30 days for customer number 5. 

Last_Thirty <- dbGetQuery(con, "SELECT * 
				    FROM Invoice
				    WHERE DATE_SUB(CURDATE(), INTERVAL 30 DAY) >= Invoice.InvoiceDate  
				    AND Invoice.CustomerId = 5 ")
				



						
			
				
				 



				  
					  




				



