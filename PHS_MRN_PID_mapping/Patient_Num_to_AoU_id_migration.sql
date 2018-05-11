------------------------------------------------------
-----------------------------------------------------
-- Description: This script creates 3 seperate stored procedures which if run in sequence will replace "patient_nums" in the 6 OMOP tables with the AoU Participants ID
--              This is done via a double mapping. From constrack using the aou_mapping script, generate a mapping from MRN to AoU ID
--              The RPDR fills in mrn_mapping with a mapping of MRN to i2b2 patient_num
--	            The OMOP transformation uses the i2b2 patient_num value as the patient_id used throughout the OMOP data schema
--     NOTE: To install the stored procedures in a fresh database you have to uncomment each procedure 1 at a time
--           and execute each stored procedure before moving on to install the next.
--           Since table columns are being modified and subsequent procedures will not compile/install untill the previous one has been executed.
-- Author: Kevin Embree
-- Date Created: July 28th
-- Updated 2018-04-20: Added logic to drop and add back indexes on person_id columns
-- Updated 2018-05-02: Changed the script form being one run by itself to creating 3 procedures to be run manually
-----------------------------------------------------
-----------------------------------------------------
--set the database name containing the transformed OMOP tables
use AllOfUs_Mart;


--IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pmi_id_step1]') AND type in (N'P', N'PC'))
--DROP PROCEDURE [dbo].[pmi_id_step1]
--GO

--create procedure pmi_id_step1 as

--begin

----------------------------------------------------------------
---- Step one add new columns to the 6 tables
---------------------------------------------------------------
--alter table dbo.person add aou_id int null;
--alter table dbo.visit_occurrence add aou_id int null;
--alter table dbo.condition_occurrence add aou_id int null;
--alter table dbo.procedure_occurrence add aou_id int null;
--alter table dbo.drug_exposure add aou_id int null;
--alter table dbo.measurement add aou_id int null;

--end
--go





--IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pmi_id_step2]') AND type in (N'P', N'PC'))
--DROP PROCEDURE [dbo].[pmi_id_step2]
--GO

--create procedure pmi_id_step2 as

--begin

------------------------------------------------------------
---- Step two loop through the mappings and fill in the new values into the new columns
---------------------------------------------------------------
--declare @aou_id as int;
--declare @pmi_id as varchar;
--declare @patient_num as int;
--declare @ids as cursor
--set @ids = cursor for
--select cast(substring(am.PMI_ID, 2, 10) as int) as aou_id, am.pmi_id, mm.patient_num from dbo.aou_mapping am
--join mrn_mapping mm on am.mrn = mm.mrn and substring(am.MRN_FACILITY,1,3) = mm.company_cd;

--open @ids
--fetch next from @ids into @aou_id, @pmi_id, @patient_num

--while @@FETCH_STATUS = 0
--begin 
--	update dbo.person set aou_id = @aou_id where person_id = @patient_num;
--	update dbo.person set person_source_value = @pmi_id where person_id = @patient_num;
--	update dbo.visit_occurrence set aou_id = @aou_id where person_id = @patient_num;
--	update dbo.condition_occurrence set aou_id = @aou_id where person_id = @patient_num;
--	update dbo.procedure_occurrence set aou_id = @aou_id where person_id = @patient_num;
--	update dbo.drug_exposure set aou_id = @aou_id where person_id = @patient_num;
--	update dbo.measurement set aou_id = @aou_id where person_id = @patient_num;

--	fetch next from @ids into @aou_id, @pmi_id, @patient_num
--end

--close @ids;
--deallocate @ids;

--end
--go


--IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pmi_id_step3]') AND type in (N'P', N'PC'))
--DROP PROCEDURE [dbo].[pmi_id_step3]
--GO

--create procedure pmi_id_step3 as

--begin

--------------------------------------------------------------------
---- Step three check that every record has a new value before deleting the old column and then renaming the new column to the old name
---------------------------------------------------------------------
--declare @record_cnt as int;

--if (((select count(*) from person where aou_id is null) = 0) 
--  and ((select count(*) from visit_occurrence where aou_id is null) = 0) 
--  and ((select count(*) from condition_occurrence where aou_id is null) = 0)
--  and ((select count(*) from procedure_occurrence where aou_id is null) = 0)
--  and ((select count(*) from drug_exposure where aou_id is null) = 0)
--  and ((select count(*) from measurement where aou_id is null) = 0))
--begin
----drop indexes
--DROP INDEX idx_person_id ON person;
--DROP INDEX idx_visit_person_id ON visit_occurrence;
--DROP INDEX idx_procedure_person_id ON procedure_occurrence;
--DROP INDEX idx_drug_person_id ON drug_exposure;
--DROP INDEX idx_condition_person_id ON condition_occurrence;
--DROP INDEX idx_measurement_person_id ON measurement;
----drop columns
--alter table dbo.person drop column person_id;
--alter table dbo.visit_occurrence drop column person_id;
--alter table dbo.condition_occurrence drop column person_id;
--alter table dbo.procedure_occurrence drop column person_id;
--alter table dbo.drug_exposure drop column person_id;
--alter table dbo.measurement drop column person_id;
----rename columns
--EXEC sp_rename 'dbo.person.aou_id', 'person_id', 'COLUMN';
--EXEC sp_rename 'dbo.visit_occurrence.aou_id', 'person_id', 'COLUMN';
--EXEC sp_rename 'dbo.condition_occurrence.aou_id', 'person_id', 'COLUMN';
--EXEC sp_rename 'dbo.procedure_occurrence.aou_id', 'person_id', 'COLUMN';
--EXEC sp_rename 'dbo.drug_exposure.aou_id', 'person_id', 'COLUMN';
--EXEC sp_rename 'dbo.measurement.aou_id', 'person_id', 'COLUMN';
----recreate indexes
--CREATE UNIQUE CLUSTERED INDEX idx_person_id ON person (person_id ASC);
--CREATE CLUSTERED INDEX idx_visit_person_id ON visit_occurrence (person_id ASC);
--CREATE CLUSTERED INDEX idx_procedure_person_id ON procedure_occurrence (person_id ASC);
--CREATE CLUSTERED INDEX idx_drug_person_id ON drug_exposure (person_id ASC);
--CREATE CLUSTERED INDEX idx_condition_person_id ON condition_occurrence (person_id ASC);
--CREATE CLUSTERED INDEX idx_measurement_person_id ON measurement (person_id ASC);
--end
---- Else if there are nulls present print out how many for each table
--else
--begin
--set @record_cnt = (select count(*) from person where aou_id is null); 
--if @record_cnt > 0
--	print N'person table has ' + CAST(@record_cnt as varchar) + N' nulls present';
--set @record_cnt = (select count(*) from visit_occurrence where aou_id is null); 
--if @record_cnt > 0
--	print N'visit_occurrence table has ' + CAST(@record_cnt as varchar) + N' nulls present';
--set @record_cnt = (select count(*) from condition_occurrence where aou_id is null); 
--if @record_cnt > 0
--	print N'condition_occurrence table has ' + CAST(@record_cnt as varchar) + N' nulls present';
--set @record_cnt = (select count(*) from procedure_occurrence where aou_id is null); 
--if @record_cnt > 0
--	print N'procedure_occurrence table has ' + CAST(@record_cnt as varchar) + N' nulls present';
--set @record_cnt = (select count(*) from drug_exposure where aou_id is null); 
--if @record_cnt > 0
--	print N'drug_exposure table has ' + CAST(@record_cnt as varchar) + N' nulls present';
--set @record_cnt = (select count(*) from measurement where aou_id is null); 
--if @record_cnt > 0
--	print N'measurement table has ' + CAST(@record_cnt as varchar) + N' nulls present';
--end

--end
--go





