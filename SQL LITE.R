library("RSQLite")


# Connect to the sqlite file
con = dbConnect (RSQLite::SQLite(), dbname = "~/Desktop/R Project/SQL Lite/funWithMYSQL/R-code-for-SQL-Integration-/Chinook_Sqlite.sqlite")


# get a list of all tables and view the tables
alltables = dbListTables(con)

# Turn all tables into Data Frames
 A <-  list()
  for (i in 1:length(alltables)) {
   A[[i]] <- dbGetQuery(con, paste0("SELECT * FROM ",  alltables[i], " LIMIT 5"))
    }

# Name A properly.  Use A as a way to preview top line items from large DBs.
names(A) <- alltables

# Calculate how much money was spent by each customer in the db? 

Total_Spent <- dbGetQuery(con, "SELECT Customer.LastName, Customer.FirstName AS Name,
				   SUM(Invoice.Total) AS Total  
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
				   
				   				   
# Which cities in the database are top five consumers of classical music?  

Classical_Lovers <- dbGetQuery(con, "SELECT Invoice.BillingCity, SUM(InvoiceLine.Quantity) AS Count
				   FROM Invoice 
				   JOIN InvoiceLine ON (Invoice.InvoiceId = InvoiceLine.InvoiceId)
				   JOIN Track ON (InvoiceLine.TrackId = Track.TrackId)
				   JOIN Genre ON (Track.GenreId = Genre.GenreId)
				   WHERE Genre.Name = 'Classical'
				   GROUP BY Invoice.BillingCity
        	       ORDER BY Count DESC
                   Limit 5")
                  
# Which artist was the most popular in each given state and how many singles did each sell? 

Popular_US  <- dbGetQuery(con, "SELECT Invoice.BillingState, SUM(InvoiceLine.Quantity) AS Sales, 
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


# get a list of all tables and view the tables
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
 					
 					 
 					

					
					  

				    




				  
					  




				



