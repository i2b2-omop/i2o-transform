--------------
--DEATH: Written by Matthew Joss, Jeff Klann, and Vivian Gainer
--This procedure was written to be run at Partners Healthcare and to work with PHS codes. 
--This will likely not work as written for other sites. 
--Use the OMOPDeath proc that is currently in the OMOP transform.
--------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPDeath') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPDeath
go

create procedure OMOPDeath as
begin


select a.patient_num, patient_id_e, date_of_death_cd, date_of_death
into #rpdrmap
from [rpdr_19].[dbo].[dw_dim_patient] c join patient_mapping b
on c.patient_id_e = b.patient_ide
join patient_dimension a
on a.patient_num = b.patient_num
where a.vital_status_cd = 'Y'
and (patient_ide_source = 'EMP_R'and patient_ide_status = 'A')



insert into death( person_id,	death_date,  death_type_concept_id)
select  distinct pat.patient_num, pat.death_date, 
CASE WHEN dw.date_of_death_cd = 'E' THEN '38003569' WHEN dw.date_of_death_cd = 'X' THEN '242' END
from i2b2patient pat 
JOIN #rpdrmap dw
on pat.patient_num = dw.patient_num
where (pat.death_date is not null or vital_status_cd like 'Z%') and pat.patient_num in (select person_id from person)

end
go
