------------------------------------------------------
-----------------------------------------------------
-- Description: This script replaces "patient_nums" in the 10 OMOP tables with the AoU Participants ID
--              This is done via a double mapping. From constrack using the aou_mapping script, generate a mapping from MRN to AoU ID
--              The RPDR fills in mrn_mapping with a mapping of MRN to i2b2 patient_num
--	            The OMOP transformation uses the i2b2 patient_num value as the patient_id used throughout the OMOP data schema
-- Author: Kevin Embree
-- Date Created: July 28th
-- Updated on August 22nd 2018 to add 4 more tables
-- Also encapsulated the code into 3 stored procedures
-- Unfortunately to load the second and third procedures the first one must be executed so that the 'aou_id' columns exist and don't throw compile errors
---------------------------------------------------------
-- So to load...
-- 1) Comment out 2 and 3 (uncomment 1)
-- 2) Execute create procedure for 1
-- 3) Execute stored procedure 1
-- 4) Uncomment 2 and 3
-- 5) Then you can execute procedures 2 and 3
-----------------------------------------------------
-----------------------------------------------------
--set the database name containing the transformed OMOP tables
use AllOfUs_Mart;
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

drop procedure pmi_id_step1
go

create procedure pmi_id_step1 as

begin
--------------------------------------------------------------
-- Step one add new columns to the 10 tables with person_id
-------------------------------------------------------------
alter table dbo.person add aou_id int null;
alter table dbo.visit_occurrence add aou_id int null;
alter table dbo.condition_occurrence add aou_id int null;
alter table dbo.procedure_occurrence add aou_id int null;
alter table dbo.drug_exposure add aou_id int null;
alter table dbo.observation add aou_id int null;
alter table dbo.measurement add aou_id int null;
alter table dbo.device_exposure add aou_id int null;
alter table dbo.death add aou_id int null;
alter table dbo.specimen add aou_id int null;

end
go



drop procedure pmi_id_step2
go

create procedure pmi_id_step2 as

begin
----------------------------------------------------------
-- Step two loop through the mappings and fill in the new values into the new columns
-------------------------------------------------------------
declare @aou_id as int;
declare @pmi_id as varchar;
declare @patient_num as int;
declare @ids as cursor
set @ids = cursor for
select cast(substring(am.PMI_ID, 2, 10) as int) as aou_id, am.pmi_id, mm.patient_num from dbo.aou_mapping am
join mrn_mapping mm on am.mrn = mm.mrn and substring(am.MRN_FACILITY,1,3) = mm.company_cd;

open @ids
fetch next from @ids into @aou_id, @pmi_id, @patient_num

while @@FETCH_STATUS = 0
begin 
	update dbo.person set aou_id = @aou_id where person_id = @patient_num;
	update dbo.visit_occurrence set aou_id = @aou_id where person_id = @patient_num;
	update dbo.condition_occurrence set aou_id = @aou_id where person_id = @patient_num;
	update dbo.procedure_occurrence set aou_id = @aou_id where person_id = @patient_num;
	update dbo.drug_exposure set aou_id = @aou_id where person_id = @patient_num;
	update dbo.measurement set aou_id = @aou_id where person_id = @patient_num;
	update dbo.observation set aou_id = @aou_id where person_id = @patient_num;
	update dbo.device_exposure set aou_id = @aou_id where person_id = @patient_num;
	update dbo.death set aou_id = @aou_id where person_id = @patient_num;
	update dbo.specimen set aou_id = @aou_id where person_id = @patient_num;

	fetch next from @ids into @aou_id, @pmi_id, @patient_num
end

close @ids;
deallocate @ids;
end
go

drop procedure pmi_id_step3
go

create procedure pmi_id_step3 as

begin
------------------------------------------------------------------
-- Step three check that every record has a new value before deleting the old column
-------------------------------------------------------------------
declare @record_cnt as int;

if (((select count(*) from person where aou_id is null) = 0) 
  and ((select count(*) from visit_occurrence where aou_id is null) = 0) 
  and ((select count(*) from condition_occurrence where aou_id is null) = 0)
  and ((select count(*) from procedure_occurrence where aou_id is null) = 0)
  and ((select count(*) from drug_exposure where aou_id is null) = 0)
  and ((select count(*) from measurement where aou_id is null) = 0)
  and ((select count(*) from observation where aou_id is null) = 0)
  and ((select count(*) from device_exposure where aou_id is null) = 0)
  and ((select count(*) from death where aou_id is null) = 0)
  and ((select count(*) from specimen where aou_id is null) = 0))
begin

IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.person') AND NAME = N'idx_person_id')
 DROP INDEX idx_person_id ON AllOfUs_Mart.dbo.person;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.visit_occurrence') AND NAME = N'idx_visit_person_id') 
DROP INDEX idx_visit_person_id ON AllOfUs_Mart.dbo.visit_occurrence;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.condition_occurrence') AND NAME = N'idx_condition_person_id') 
DROP INDEX idx_condition_person_id ON AllOfUs_Mart.dbo.condition_occurrence;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.procedure_occurrence') AND NAME = N'idx_procedure_person_id') 
DROP INDEX idx_procedure_person_id ON AllOfUs_Mart.dbo.procedure_occurrence;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.drug_exposure') AND NAME = N'idx_drug_person_id') 
DROP INDEX idx_drug_person_id ON AllOfUs_Mart.dbo.drug_exposure;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.measurement') AND NAME = N'idx_measurement_person_id') 
DROP INDEX idx_measurement_person_id ON AllOfUs_Mart.dbo.measurement;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.observation') AND NAME = N'idx_observation_person_id') 
DROP INDEX idx_observation_person_id ON AllOfUs_Mart.dbo.observation;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.device_exposure') AND NAME = N'idx_device_person_id') 
DROP INDEX idx_device_person_id ON AllOfUs_Mart.dbo.device_exposure;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.death') AND NAME = N'idx_death_person_id') 
DROP INDEX idx_death_person_id ON AllOfUs_Mart.dbo.death;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.specimen') AND NAME = N'idx_specimen_person_id') 
DROP INDEX idx_specimen_person_id ON AllOfUs_Mart.dbo.specimen;



alter table dbo.person drop column person_id;
alter table dbo.visit_occurrence drop column person_id;
alter table dbo.condition_occurrence drop column person_id;
alter table dbo.procedure_occurrence drop column person_id;
alter table dbo.drug_exposure drop column person_id;
alter table dbo.measurement drop column person_id;
alter table dbo.observation drop column person_id;
alter table dbo.device_exposure drop column person_id;
alter table dbo.death drop column person_id;
alter table dbo.specimen drop column person_id;
EXEC sp_rename 'dbo.person.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.visit_occurrence.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.condition_occurrence.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.procedure_occurrence.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.drug_exposure.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.measurement.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.observation.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.device_exposure.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.death.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.specimen.aou_id', 'person_id', 'COLUMN';

CREATE INDEX idx_person_id ON AllOfUs_Mart.dbo.person(person_id);
CREATE INDEX idx_visit_person_id ON AllOfUs_Mart.dbo.visit_occurrence(person_id);
CREATE INDEX idx_condition_person_id ON AllOfUs_Mart.dbo.condition_occurrence(person_id);
CREATE INDEX idx_procedure_person_id ON AllOfUs_Mart.dbo.procedure_occurrence(person_id);
CREATE INDEX idx_drug_person_id ON AllOfUs_Mart.dbo.drug_exposure(person_id);
CREATE INDEX idx_measurement_person_id ON AllOfUs_Mart.dbo.measurement(person_id);
CREATE INDEX idx_observation_person_id ON AllOfUs_Mart.dbo.observation(person_id);
CREATE INDEX idx_device_person_id ON AllOfUs_Mart.dbo.device_exposure(person_id);
CREATE INDEX idx_death_person_id ON AllOfUs_Mart.dbo.death(person_id);
CREATE INDEX idx_specimen_person_id ON AllOfUs_Mart.dbo.specimen(person_id);

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
set @record_cnt = (select count(*) from observation where aou_id is null); 
if @record_cnt > 0
	print N'observation table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from device_exposure where aou_id is null); 
if @record_cnt > 0
	print N'device_exposure table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from death where aou_id is null); 
if @record_cnt > 0
	print N'death table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from specimen where aou_id is null); 
if @record_cnt > 0
	print N'specimen table has ' + CAST(@record_cnt as varchar) + N' nulls present';

end
go



