create procedure pmi_id_step1 as

begin
--------------------------------------------------------------
-- Step one add new columns to the 11 tables with person_id
-------------------------------------------------------------
alter table dbo.person add aou_id int null;
alter table dbo.visit_occurrence add aou_id int null;
alter table dbo.visit_detail add aou_id int null;
alter table dbo.condition_occurrence add aou_id int null;
alter table dbo.condition_era add aou_id int null;
alter table dbo.procedure_occurrence add aou_id int null;
alter table dbo.drug_exposure add aou_id int null;
alter table dbo.drug_era add aou_id int null;
alter table dbo.observation add aou_id int null;
alter table dbo.observation_period add aou_id int null;
alter table dbo.measurement add aou_id int null;
alter table dbo.device_exposure add aou_id int null;
alter table dbo.death add aou_id int null;
alter table dbo.specimen add aou_id int null;
alter table dbo.note add aou_id int null;

end
