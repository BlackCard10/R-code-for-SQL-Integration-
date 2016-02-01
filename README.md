# R-code-for-SQL-Integration-

## Synopsis
The purpose of this code is to demonstrate how SQL code can be written directly into R and sent to a server for seamless data querying, 
storage, and manipulation. 

## Code Example 
The following command, "dbGetQuery", can be used to send SQL code to an established SQL connection that will then return back
the data requested as a data frame.  The data frame can then be used for further statistical analysis, maniplation, visualization and more
once in R.  

  Total_Spent <- dbGetQuery(con, "SELECT Customer.LastName

## Motivation

The motivation for this was very simple: ease. I, like most people, hate to context switch.  Commonly analysts work in two or more
environments 1) a SQL manager that returns data 2) a visualization and presentation environment like R.  Once the data from SQL is returned
it gets transformed to a .csv or some intermediary format, loaded into R or another data visualization environment and then further study 
is completed.  I simply wanted to cut out the midde man as much as possible.

