-- Instructions: 
-- 1) Alter the database names to match yours in the places indicated.
-- 2) The loyalty cohort identification script must be run first. Note that the date windows in the loyalty cohort script are
--   presently hard-coded in both the loyalty cohort script and the PCORnetLoader script
-- 3) The PCORnetLoader_v6 script must be run first also
-- 4) Finally, be sure you have run the meds schemachange script on your medications ontology to create the additional columns.
-- 5) For testing, change the 100000000 number to something small, like 10000
-- 4) Run this from the database with the PopMedNet transforms and tables.   
--    Note that it could take a long time to run. (Should take ~30min per 10k patients, so about 1 day per 500k patients.)
--    NOTE (12-9-15) now the transform runs each procedure individually, to give the administrator finer-grained control. The old way still works too.
--    
-- Now 7/28/16 filters out patients with very low fact counts! (<5%)
-- All data from 1-1-2010 is transformed.
-- Jeff Klann, PhD


drop table i2b2patient_list
GO

-- Make 100000000 number smaller for testing
select distinct top 100000000 f.patient_num into i2b2patient_list from i2b2fact f
inner join i2b2visit v on f.patient_num=v.patient_num
 where f.start_date>='20100101' and v.start_date>='20100101'
GO
-- Change to match your database names
drop synonym i2b2patient;
GO
drop view i2b2patient;
GO
-- Change to match your database name
create view i2b2patient as select * from PCORI_Mart..patient_dimension where patient_num in (select patient_num from i2b2patient_list)
GO
drop synonym i2b2visit;
GO
drop view i2b2visit;
GO
-- Change to match your database name
create view i2b2visit as select * from PCORI_Mart..visit_dimension where start_date>='20100101' and (end_date is null or end_date<getdate());
GO

-- NEW! 7/28/16 Delete patients in the bottom 5% of fact count ("mini-loyalty") - these tend to have <5 facts and are not useful for research 
-- Count total PCORI facts per patient
-- Note: you will need to have added the synonym in the latest transform: "create synonym i2b2concept for PCORI_Mart..concept_dimension "
drop table #miniloyalty_patient_facts
GO
select 
    o.patient_num, count(*) num_facts
    into #miniloyalty_patient_facts
	from i2b2fact o 
    inner join i2b2patient_list p on p.patient_num=o.patient_num
	where concept_cd in (select concept_cd from i2b2concept where concept_path like '\P%') -- Change to '\PCORI%' if your paths are standard
    and o.start_date>='1/1/2010'
	group by o.patient_num
GO
alter table #miniloyalty_patient_facts add primary key (patient_num)
GO

-- Change "where k<6" to a different number to delete a different low fact %
delete from i2b2patient_list where patient_num in 
    (select patient_num from
        (select patient_num, k, sum(f) f from
            (select patient_num, ntile(100) over (partition by a, s order by f, patient_num) k,f
            from (
                select p.patient_num, floor(age_in_years_num/10) a, sex_cd s, isnull(f.num_facts,0) f
                from i2b2patient p
                    left join #miniloyalty_patient_facts f
                        on p.patient_num = f.patient_num
            ) t
          ) t group by PATIENT_NUM,k) t where k<6)

--exec pcornetloader;
--GO
-- Now run each procedure individually to ease commenting/uncommenting 
-- Also, deletes added for safety
exec pcornetclear
GO
delete from pmnharvest
GO
exec PCORNetHarvest
GO
delete from pmndemographic
GO
exec PCORNetDemographics
GO
delete from pmnENCOUNTER
GO
exec PCORNetEncounter
GO
delete from pmndiagnosis
GO
exec PCORNetDiagnosis
GO
delete from pmncondition
GO
exec PCORNetCondition
GO
delete from pmnprocedure
GO
exec PCORNetProcedure
GO
delete from pmnvital
GO
exec PCORNetVital
GO
delete from PMNenrollment
GO
exec PCORNetEnroll
GO
delete from pmnlabresults_cm
GO
exec PCORNetLabResultCM
GO
delete from pmnprescribing
GO
exec PCORNetPrescribing
GO
delete from pmndispensing
GO
exec PCORNetDispensing
GO
delete from pmnDeath
GO
exec PCORNetDeath
GO
exec pcornetreport
GO

select * from i2pReport;


