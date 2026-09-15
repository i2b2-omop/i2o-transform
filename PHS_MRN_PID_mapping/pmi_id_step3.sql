create procedure pmi_id_step3 as

begin
------------------------------------------------------------------
-- Step three check that every record has a new value before deleting the old column
-------------------------------------------------------------------
declare @record_cnt as int;

if (((select count(*) from person where aou_id is null) = 0) 
  and ((select count(*) from visit_occurrence where aou_id is null) = 0) 
  and ((select count(*) from visit_detail where aou_id is null) = 0) 
  and ((select count(*) from condition_occurrence where aou_id is null) = 0)
  and ((select count(*) from condition_era where aou_id is null) = 0)
  and ((select count(*) from procedure_occurrence where aou_id is null) = 0)
  and ((select count(*) from drug_exposure where aou_id is null) = 0)
  and ((select count(*) from drug_era where aou_id is null) = 0)
  and ((select count(*) from measurement where aou_id is null) = 0)
  and ((select count(*) from observation where aou_id is null) = 0)
  and ((select count(*) from observation_period where aou_id is null) =0)
  and ((select count(*) from device_exposure where aou_id is null) = 0)
  and ((select count(*) from death where aou_id is null) = 0)
  and ((select count(*) from specimen where aou_id is null) = 0)
  and ((select count(*) from note where aou_id is null) = 0)
  )
begin

IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.person') AND NAME = N'xpk_person')
 ALTER TABLE AllOfUs_Mart.dbo.person DROP CONSTRAINT xpk_person;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.person') AND NAME = N'idx_person_id')
 DROP INDEX idx_person_id ON AllOfUs_Mart.dbo.person;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.visit_occurrence') AND NAME = N'idx_visit_person_id') 
DROP INDEX idx_visit_person_id ON AllOfUs_Mart.dbo.visit_occurrence;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.visit_detail') AND NAME = N'idx_visit_detail_person_id') 
DROP INDEX idx_visit_detail_person_id ON AllOfUs_Mart.dbo.visit_detail;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.condition_occurrence') AND NAME = N'idx_condition_person_id') 
DROP INDEX idx_condition_person_id ON AllOfUs_Mart.dbo.condition_occurrence;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.condition_era') AND NAME = N'idx_condition_era_person_id') 
DROP INDEX idx_condition_era_person_id ON AllOfUs_Mart.dbo.condition_era;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.procedure_occurrence') AND NAME = N'idx_procedure_person_id') 
DROP INDEX idx_procedure_person_id ON AllOfUs_Mart.dbo.procedure_occurrence;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.drug_exposure') AND NAME = N'idx_drug_person_id') 
DROP INDEX idx_drug_person_id ON AllOfUs_Mart.dbo.drug_exposure;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.drug_era') AND NAME = N'idx_drug_era_person_id') 
DROP INDEX idx_drug_era_person_id ON AllOfUs_Mart.dbo.drug_era;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.measurement') AND NAME = N'idx_measurement_person_id') 
DROP INDEX idx_measurement_person_id ON AllOfUs_Mart.dbo.measurement;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.observation') AND NAME = N'idx_observation_person_id') 
DROP INDEX idx_observation_person_id ON AllOfUs_Mart.dbo.observation;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.observation_period') AND NAME = N'idx_observation_period_id') 
DROP INDEX idx_observation_period_id ON AllOfUs_Mart.dbo.observation_period;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.device_exposure') AND NAME = N'idx_device_person_id') 
DROP INDEX idx_device_person_id ON AllOfUs_Mart.dbo.device_exposure;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.death') AND NAME = N'xpk_death')
 ALTER TABLE AllOfUs_Mart.dbo.death DROP CONSTRAINT xpk_death;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.death') AND NAME = N'idx_death_person_id') 
DROP INDEX idx_death_person_id ON AllOfUs_Mart.dbo.death;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.specimen') AND NAME = N'idx_specimen_person_id') 
DROP INDEX idx_specimen_person_id ON AllOfUs_Mart.dbo.specimen;
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = object_id(N'AllOfUs_Mart.dbo.note') AND NAME = N'idx_note_person_id') 
DROP INDEX idx_note_person_id ON AllOfUs_Mart.dbo.note;


alter table dbo.person drop column person_id;
alter table dbo.visit_occurrence drop column person_id;
alter table dbo.visit_detail drop column person_id;
alter table dbo.condition_occurrence drop column person_id;
alter table dbo.condition_era drop column person_id;
alter table dbo.procedure_occurrence drop column person_id;
alter table dbo.drug_exposure drop column person_id;
alter table dbo.drug_era drop column person_id;
alter table dbo.measurement drop column person_id;
alter table dbo.observation drop column person_id;
alter table dbo.observation_period drop column person_id;
alter table dbo.device_exposure drop column person_id;
alter table dbo.death drop column person_id;
alter table dbo.specimen drop column person_id;
alter table dbo.note drop column person_id;
EXEC sp_rename 'dbo.person.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.visit_occurrence.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.visit_detail.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.condition_occurrence.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.condition_era.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.procedure_occurrence.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.drug_exposure.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.drug_era.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.measurement.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.observation.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.observation_period.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.device_exposure.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.death.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.specimen.aou_id', 'person_id', 'COLUMN';
EXEC sp_rename 'dbo.note.aou_id', 'person_id', 'COLUMN';

CREATE INDEX idx_person_id ON AllOfUs_Mart.dbo.person(person_id);
CREATE INDEX idx_visit_person_id ON AllOfUs_Mart.dbo.visit_occurrence(person_id);
CREATE INDEX idx_visit_detail_person_id ON AllOfUs_Mart.dbo.visit_detail(person_id);
CREATE INDEX idx_condition_person_id ON AllOfUs_Mart.dbo.condition_occurrence(person_id);
CREATE INDEX idx_condition_era_person_id ON AllOfUs_Mart.dbo.condition_era(person_id);
CREATE INDEX idx_procedure_person_id ON AllOfUs_Mart.dbo.procedure_occurrence(person_id);
CREATE INDEX idx_drug_person_id ON AllOfUs_Mart.dbo.drug_exposure(person_id);
CREATE INDEX idx_drug_era_person_id ON AllOfUs_Mart.dbo.drug_era(person_id);
CREATE INDEX idx_measurement_person_id ON AllOfUs_Mart.dbo.measurement(person_id);
CREATE INDEX idx_observation_person_id ON AllOfUs_Mart.dbo.observation(person_id);
CREATE INDEX idx_observation_period_id ON AllOfUs_Mart.dbo.observation_period(person_id);
CREATE INDEX idx_device_person_id ON AllOfUs_Mart.dbo.device_exposure(person_id);
CREATE INDEX idx_death_person_id ON AllOfUs_Mart.dbo.death(person_id);
CREATE INDEX idx_specimen_person_id ON AllOfUs_Mart.dbo.specimen(person_id);
CREATE INDEX idx_note_person_id ON AllOfUs_Mart.dbo.note(person_id);

end
else 
begin
set @record_cnt = (select count(*) from person where aou_id is null); 
if @record_cnt > 0
	print N'person table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from visit_occurrence where aou_id is null); 
if @record_cnt > 0
	print N'visit_occurrence table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from visit_detail where aou_id is null); 
if @record_cnt > 0
	print N'visit_detail table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from condition_occurrence where aou_id is null); 
if @record_cnt > 0
	print N'condition_occurrence table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from condition_era where aou_id is null); 
if @record_cnt > 0
	print N'condition_era table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from procedure_occurrence where aou_id is null); 
if @record_cnt > 0
	print N'procedure_occurrence table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from drug_exposure where aou_id is null); 
if @record_cnt > 0
	print N'drug_exposure table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from drug_era where aou_id is null); 
if @record_cnt > 0
	print N'drug_era table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from measurement where aou_id is null); 
if @record_cnt > 0
	print N'measurement table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from observation where aou_id is null); 
if @record_cnt > 0
	print N'observation table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from observation_period where aou_id is null); 
if @record_cnt > 0
	print N'observation_period table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from device_exposure where aou_id is null); 
if @record_cnt > 0
	print N'device_exposure table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from death where aou_id is null); 
if @record_cnt > 0
	print N'death table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from specimen where aou_id is null); 
if @record_cnt > 0
	print N'specimen table has ' + CAST(@record_cnt as varchar) + N' nulls present';
set @record_cnt = (select count(*) from note where aou_id is null); 
if @record_cnt > 0
	print N'note table has ' + CAST(@record_cnt as varchar) + N' nulls present';
	end
end
