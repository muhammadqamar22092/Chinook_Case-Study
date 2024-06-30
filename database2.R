install.packages("DBI",dependencies = TRUE)
library(DBI)
install.packages("RSQLite",dependencies = TRUE)
library(RSQLite)

drv<-dbDriver("SQLite")
con<-dbConnect(drv,dbname= "chinooK.db")
#username and password
#Test Connectioon
dbListTables(con)
dbListFields(con, "customer")
#USE DBGET QUERY EVERY TIME WRITE SQL QUERY
#q1
A <- dbGetQuery(con,"SELECT CustomerId,Sum(Total) AS customer_total
                FROM Invoice
                Group by 1
                Having customer_total > 40")
B<-dbGetQuery(con,"Select Album.Title,Track.Name
              From Track
              Join Album
              On Track.AlbumId=Album.AlbumId
              Where Track.UnitPrice=1.99")

#Display the artist name, album title, length of the album in seconds, with only
#albums longer than 1000 seconds, ordered by length in descending order. 
C<-dbGetQuery(con,"Select Artist.Name,Album.Title,Sum(Milliseconds)/1000 AS length
              FROM Album
              Join Artist USING(ArtistId)
              Join Track USING(AlbumId)
              Group By AlbumId
              Having length > 1000 
              Order By length Desc")

#additional
ad<- dbGetQuery(con,"Select c.FirstName,c.LastName,il.UnitPrice,il.Quantity,t.Name
                FROM Customer c
                Join Invoice i
                On c.CustomerId = i.CustomerId
                Join InvoiceLine il
                On i.InvoiceId=il.InvoiceId
                Join Track t
                On il.TrackId=t.TrackId
                Order by 3,4")
library(sqldf)

ad2<-dbGetQuery(con, "
    SELECT 
        c.*
    FROM 
        Customer c
    JOIN 
        Invoice i ON c.CustomerId = i.CustomerId
    JOIN 
        InvoiceLine il ON i.InvoiceId = il.InvoiceId
    GROUP BY 
        c.CustomerId
    HAVING 
        SUM(il.UnitPrice * il.Quantity) > 10 
        AND COUNT(DISTINCT i.InvoiceId) >= 2;")

ad3<-dbGetQuery(con,"
    SELECT 
        c.FirstName, 
        c.LastName, 
        SUM(il.UnitPrice * il.Quantity) AS TotalSpent
    FROM 
        Customer c
    JOIN 
        Invoice i ON c.CustomerId = i.CustomerId
    JOIN 
        InvoiceLine il ON i.InvoiceId = il.InvoiceId
    GROUP BY 
        c.CustomerId, c.FirstName, c.LastName
    ORDER BY 
        TotalSpent DESC
    LIMIT 5;")
ad4<- dbGetQuery(con,"SELECT 
    a.Title AS AlbumTitle, 
    COUNT(t.TrackId) AS NumberOfTracks
FROM 
    Album a
JOIN 
    Track t ON a.AlbumId = t.AlbumId
GROUP BY 
    a.AlbumId, a.Title
ORDER BY 
    NumberOfTracks DESC;
")

ad5<-dbGetQuery(con,"SELECT 
    e.FirstName,
    e.LastName,
    e.Title,
    SUM(il.UnitPrice * il.Quantity) AS TotalSalesAmount
FROM 
    Employee e
JOIN 
    Customer c ON e.EmployeeId = c.SupportRepId
JOIN 
    Invoice i ON c.CustomerId = i.CustomerId
JOIN 
    InvoiceLine il ON i.InvoiceId = il.InvoiceId
GROUP BY 
    e.FirstName, e.Title
ORDER BY 
    TotalSalesAmount DESC;")

ad6<-dbGetQuery(con,"SELECT 
    g.Name AS GenreName,
    SUM(il.Quantity) AS TotalTracksSold
FROM 
    Genre g
JOIN 
    Track t ON g.GenreId = t.GenreId
JOIN 
    InvoiceLine il ON t.TrackId = il.TrackId
GROUP BY 
    g.GenreId, g.Name
ORDER BY 
    TotalTracksSold DESC
LIMIT 3;
")
ad7<-dbGetQuery(con,"SELECT 
    c.FirstName, 
    c.LastName, 
    AVG(i.Total) AS AveragePurchaseAmount
FROM 
    Customer c
JOIN 
    Invoice i ON c.CustomerId = i.CustomerId
GROUP BY 
    c.CustomerId, c.FirstName, c.LastName
ORDER BY 
    AveragePurchaseAmount DESC;
")
ad8 <-dbGetQuery(con,"SELECT 
    g.Name AS GenreName, 
    COUNT(t.TrackId) AS TotalTracks
FROM 
    Genre g
JOIN 
    Track t ON g.GenreId = t.GenreId
GROUP BY 
    g.GenreId, g.Name
ORDER BY 
    TotalTracks DESC;
")





ad9 <-dbGetQuery(con,"SELECT 
    strftime('%Y', i.InvoiceDate) AS Year, 
    SUM(i.Total) AS TotalSalesAmount
FROM 
    Invoice i
GROUP BY 
    strftime('%Y', i.InvoiceDate)
ORDER BY 
    Year ASC;
")



ad10 <-dbGetQuery(con,"SELECT 
    c.Country AS CountryName, 
    COUNT(c.CustomerId) AS TotalCustomers
FROM 
    Customer c
GROUP BY 
    c.Country
ORDER BY 
    TotalCustomers DESC
LIMIT 3;
")



ad11 <-dbGetQuery(con,"SELECT 
    e.FirstName, 
    e.LastName, 
    COUNT(c.CustomerId) AS NumberOfCustomers
FROM 
    Employee e
LEFT JOIN 
    Customer c ON e.EmployeeId = c.SupportRepId
GROUP BY 
    e.EmployeeId, e.FirstName, e.LastName
ORDER BY 
    NumberOfCustomers DESC;
")



ad12 <-dbGetQuery(con,"SELECT 
    g.Name AS GenreName, 
    AVG(r.Rating) AS AverageTrackRating
FROM 
    Genre g
JOIN 
    Track t ON g.GenreId = t.GenreId
JOIN 
    Rating r ON t.TrackId = r.TrackId
GROUP BY 
    g.GenreId, g.Name
ORDER BY 
    AverageTrackRating DESC;
")
dbDisconnect(con)
