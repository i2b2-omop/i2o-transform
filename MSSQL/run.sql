-- Instructions: 
-- 1) Alter the database names to match yours in the places indicated.
-- 2) The OMOPLoader.sql script must be run first also
-- 3) Make sure to have the PCORNet ontology loaded and mapped: https://github.com/SCILHS/scilhs-ontology
-- 4) For testing, change the 100000000 number to something small, like 10000
-- 5) Run this from the database with the OMOP transforms and tables.   
-- 
-- All data from 1-1-2010 is transformed.
-- Jeff Klann, PhD, and Matthew Joss
--------------------------------------------------------------------------------------------------------------------------
use i2b2stub
drop table i2b2patient_list
GO

-- Make 100000000 number smaller for testing
select distinct top 100000000 f.patient_num into i2b2patient_list from i2b2fact f
--inner join i2b2visit v on f.patient_num=v.patient_num
-- where f.start_date>='20100101' and v.start_date>='20100101'
GO
-- Change to match your database names
drop synonym i2b2patient;
GO
drop view i2b2patient;
GO
-- Change to match your database name
create view i2b2patient as select * from i2b2demodata..patient_dimension where patient_num in (select patient_num from i2b2patient_list)
GO
drop synonym i2b2visit;
GO
drop view i2b2visit;
GO
-- Change to match your database name
create view i2b2visit as select * from i2b2demodata..visit_dimension where (end_date is null or end_date<getdate());
GO




--exec pcornetloader;
--GO
exec OMOPclear
GO
delete from person
GO
exec OMOPdemographics
GO
delete from visit_occurrence
GO
exec OMOPencounter
GO
delete from OMOPobservationperiod
GO
exec OMOPobservationperiod
GO
delete from condition_occurrence
GO
exec OMOPdiagnosis
GO
delete from procedure_occurrence
GO
exec OMOPprocedure
GO
delete from measurement
GO
exec omopVital
GO
exec omopLabResultCM
GO
delete from drug_exposure
GO
exec OMOPdrug_exposure
GO
delete from drug_era
GO
delete from condition_era
GO
exec OMOPera
GO

select * from i2pReport;
