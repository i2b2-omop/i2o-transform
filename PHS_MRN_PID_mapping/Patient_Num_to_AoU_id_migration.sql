------------------------------------------------------
-----------------------------------------------------
-- Description: This script replaces "patient_nums" in the 6 OMOP tables with the AoU Participants ID
--              This is done via a double mapping. From constrack using the aou_mapping script, generate a mapping from MRN to AoU ID
--              The RPDR fills in mrn_mapping with a mapping of MRN to i2b2 patient_num
--	            The OMOP transformation uses the i2b2 patient_num value as the patient_id used throughout the OMOP data schema
-- Author: Kevin Embree
-- Date Created: July 28th
-----------------------------------------------------
-----------------------------------------------------
--set the database name containing the transformed OMOP tables
use i2b2stub;

--------------------------------------------------------------
-- Step one add new columns to the 6 tables
-------------------------------------------------------------
--alter table dbo.person add aou_id int null;
--alter table dbo.visit_occurrence add aou_id int null;
--alter table dbo.condition_occurrence add aou_id int null;
--alter table dbo.procedure_occurrence add aou_id int null;
--alter table dbo.drug_exposure add aou_id int null;
--alter table dbo.measurement add aou_id int null;

----------------------------------------------------------
-- Step two loop through the mappings and fill in the new values into the new columns
-------------------------------------------------------------
--declare @aou_id as int;
--declare @patient_num as int;
--declare @ids as cursor
--set @ids = cursor for
--select am.pmi_id as aou_id, mm.patient_num from aou_mapping am
--join mrn_mapping mm on am.mrn = mm.mrn and am.mrn_facility = mm.company_cd;

--open @ids
--fetch next from @ids into @aou_id, @patient_num

--while @@FETCH_STATUS = 0
--begin 
--	update dbo.person set aou_id = @aou_id where person_id = @patient_num;
--	update dbo.visit_occurrence set aou_id = @aou_id where person_id = @patient_num;
--	update dbo.condition_occurrence set aou_id = @aou_id where person_id = @patient_num;
--	update dbo.procedure_occurrence set aou_id = @aou_id where person_id = @patient_num;
--	update dbo.drug_exposure set aou_id = @aou_id where person_id = @patient_num;
--	update dbo.measurement set aou_id = @aou_id where person_id = @patient_num;

--	fetch next from @ids into @aou_id, @patient_num
--end

--close @ids;
--deallocate @ids;

------------------------------------------------------------------
-- Step three check that every record has a new value before deleting the old column
-------------------------------------------------------------------
declare @record_cnt as int;

if (((select count(*) from person where aou_id is null) = 0) 
  and ((select count(*) from visit_occurrence where aou_id is null) = 0) 
  and ((select count(*) from condition_occurrence where aou_id is null) = 0)
  and ((select count(*) from procedure_occurrence where aou_id is null) = 0)
  and ((select count(*) from drug_exposure where aou_id is null) = 0)
  and ((select count(*) from measurement where aou_id is null) = 0))
begin
alter table dbo.person drop column person_id;
alter table dbo.visit_occurrence drop column person_id;
alter table dbo.condition_occurrence drop column person_id;
alter table dbo.procedure_occurrence drop column person_id;
alter table dbo.drug_exposure drop column person_id;
alter table dbo.measurement drop column person_id;
EXEC sp_rename 'dbo.person.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.visit_occurrence.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.condition_occurrence.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.procedure_occurrence.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.drug_exposure.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.measurement.aou_id', 'person_id', 'COLUMN';
end

set @record_cnt = (select count(*) from person where aou_id is null); 
if @record_cnt > 0
	print N'person table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from visit_occurrence where aou_id is null); 
if @record_cnt > 0
	print N'visit_occurrence table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from condition_occurrence where aou_id is null); 
if @record_cnt > 0
	print N'condition_occurrence table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from procedure_occurrence where aou_id is null); 
if @record_cnt > 0
	print N'procedure_occurrence table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from drug_exposure where aou_id is null); 
if @record_cnt > 0
	print N'drug_exposure table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from measurement where aou_id is null); 
if @record_cnt > 0
	print N'measurement table has ' + CAST(@record_cnt as varchar) + N' nulls present';




