-- Instructions: 
-- 1) Alter the database names to match yours in the places indicated.
-- 2) The OMOPLoader.sql script must be run first also
-- 3) Make sure to have the PCORNet ontology loaded and mapped: https://github.com/ARCH-commons/arch-ontology
-- 4) For testing, change the 100000000 number to something small, like 10000
-- 5) Run this from the database with the OMOP transforms and tables.   
-- 
-- All data from all dates is transformed.
-- Jeff Klann, PhD, and Matthew Joss
--------------------------------------------------------------------------------------------------------------------------
use <insert your db name here>


-- Make 100000000 number smaller for testing
exec OMOPPrep 100000000
GO

exec OMOPclear
GO
exec OMOPloader
GO
exec omopReport
GO
select * from i2oReport;