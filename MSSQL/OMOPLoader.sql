----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- OMOPLoader Script for OMOP
-- Contributors: Jeff Klann, PhD; Matthew Joss; Aaron Abend; Arturo Torres; Kevin Embree; Griffin Weber, MD, PhD
-- Transforms i2b2 data mapped to the PCORnet ontology into OMOP format.
-- MSSQL version
--
-- FYI, now the diagnosis and procedure transforms write to four multiple target tables
--
-- INSTRUCTIONS:
-- 1. Make sure everything else is set up first! (e.g., concept tables, pcornet ontology, etc. - https://github.com/i2b2-omop/i2o-transform/blob/master/README.md)
-- 2. Run OMOPConfig_Setup.sql first if you have not already.
--          a) Review the default values set by OMOPConfig_setup.sql and update or modify them as needed for your environment.
-- 3. Run this script to set up the loader
--          a) Use your OMOP db and make sure it has privileges to read from the various locations that the synonyms point to.
-- 4. Use the included run_*.sql script to execute the procedure, or run manually via "exec OMOPLoader <number>" (will transform at most <number> patients)
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------
--Drop synonyms/views for i2b2 datamart
----------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID('i2b2patient')) DROP VIEW i2b2patient
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'i2b2concept') DROP SYNONYM i2b2concept
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'i2b2fact') DROP SYNONYM i2b2fact
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'i2b2visit') DROP SYNONYM  i2b2visit
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'i2b2provider') DROP SYNONYM i2b2provider


--Remove deprecated synonyms/views 
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'provider_dimension') DROP SYNONYM  provider_dimension
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'i2b2patient') DROP SYNONYM  i2b2patient

-------------------------------------------------------------------------------------------------------
-- Create synonyms/views for i2b2 datamart  based on values in i2o_transform_config table
-------------------------------------------------------------------------------------------------------
DECLARE @SQL nvarchar(4000)
DECLARE @SCHEMA nvarchar(100)

BEGIN TRY
	SET @SCHEMA = (SELECT tc.VALUE FROM i2o_transform_config tc where tc.[key] = 'i2b2mart.db.schema.')
END TRY
BEGIN CATCH
	RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
END CATCH
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID('i2b2patient'))
	BEGIN TRY
		SET @SQL = 'create view i2b2patient as select * from ' + @SCHEMA + N'patient_dimension where patient_num in (select patient_num from i2b2patient_list)'
		EXEC SP_EXECUTESQL @SQL
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
	END CATCH
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'i2b2concept')
	BEGIN TRY
		SET @SQL = 'create synonym i2b2concept for ' + @SCHEMA + 'concept_dimension'
		EXEC SP_EXECUTESQL @SQL
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
	END CATCH
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'i2b2fact')
	BEGIN TRY
		SET @SQL = 'create synonym i2b2fact for ' + @SCHEMA + 'observation_fact'
		EXEC SP_EXECUTESQL @SQL
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
	END CATCH
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'i2b2visit')
	BEGIN TRY
		SET @SQL = 'create synonym i2b2visit for ' + @SCHEMA + 'visit_dimension'
		EXEC SP_EXECUTESQL @SQL
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
	END CATCH
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'i2b2provider')
	BEGIN TRY
		SET @SQL = 'create synonym i2b2provider for ' + @SCHEMA + 'provider_dimension'
		EXEC SP_EXECUTESQL @SQL
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
	END CATCH
GO

----------------------------------------------------------------------------------------------------------
--Drop synonyms/views for i2b2 datamart
----------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_diag') DROP SYNONYM pcornet_diag
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_demo') DROP SYNONYM pcornet_demo
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_proc') DROP SYNONYM pcornet_proc
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_med') DROP SYNONYM pcornet_med
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_vital') DROP SYNONYM pcornet_vital
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_enc') DROP SYNONYM pcornet_enc
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_enroll') DROP SYNONYM pcornet_enroll
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'i2o_ontology_lab')) DROP VIEW i2o_ontology_lab
--IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'i2o_ontology_drug')) DROP VIEW i2o_ontology_drug

--Remove deprecated synonyms/views
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_lab') DROP SYNONYM pcornet_lab
GO

-------------------------------------------------------------------------------------------------------
-- Create synonyms/views for ontologies based on values in i2o_transform_config table
-------------------------------------------------------------------------------------------------------
DECLARE @SQL nvarchar(4000)
DECLARE @TABLE_NAME nvarchar(100)

IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_demo')
	BEGIN TRY
		SET @TABLE_NAME = (SELECT tc.VALUE FROM i2o_transform_config tc where tc.[key] = 'ontology.demo.db.schema.table')
		SET @SQL = 'create synonym pcornet_demo for ' + @TABLE_NAME 
		EXEC SP_EXECUTESQL @SQL
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
	END CATCH
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_diag')
	BEGIN TRY
		SET @TABLE_NAME = (SELECT tc.VALUE FROM i2o_transform_config tc where tc.[key] = 'ontology.diag.db.schema.table')
		SET @SQL = 'create synonym pcornet_diag for ' + @TABLE_NAME 
		EXEC SP_EXECUTESQL @SQL
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
	END CATCH
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_proc')
	BEGIN TRY
		SET @TABLE_NAME = (SELECT tc.VALUE FROM i2o_transform_config tc where tc.[key] = 'ontology.proc.db.schema.table')
		SET @SQL = 'create synonym pcornet_proc for ' + @TABLE_NAME 
		EXEC SP_EXECUTESQL @SQL
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
	END CATCH
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_med')
	BEGIN TRY
		SET @TABLE_NAME = (SELECT tc.VALUE FROM i2o_transform_config tc where tc.[key] = 'ontology.med.db.schema.table')
		---------------------------------------------------------------------------------------
		-- To be removed once all references to pcornet_med have been removed and replaced with i2o_ontology_drug
		---------------------------------------------------------------------------------------
		   SET @SQL = 'create synonym pcornet_med for ' + @TABLE_NAME 
		   EXEC SP_EXECUTESQL @SQL
		---------------------------------------------------------------------------------------
		SET @SQL = 'create view i2o_ontology_drug as (select * from ' + @TABLE_NAME + ')'
		EXEC SP_EXECUTESQL @SQL
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
	END CATCH
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_vital')
	BEGIN TRY
		SET @TABLE_NAME = (SELECT tc.VALUE FROM i2o_transform_config tc where tc.[key] = 'ontology.vital.db.schema.table')
		SET @SQL = 'create synonym pcornet_vital for ' + @TABLE_NAME 
		EXEC SP_EXECUTESQL @SQL
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
	END CATCH
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_enc')
	BEGIN TRY
		SET @TABLE_NAME = (SELECT tc.VALUE FROM i2o_transform_config tc where tc.[key] = 'ontology.enc.db.schema.table')
		SET @SQL = 'create synonym pcornet_enc for ' + @TABLE_NAME 
		EXEC SP_EXECUTESQL @SQL
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
	END CATCH
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_enroll')
	BEGIN TRY
		SET @TABLE_NAME = (SELECT tc.VALUE FROM i2o_transform_config tc where tc.[key] = 'ontology.enroll.db.schema.table')
		SET @SQL = 'create synonym pcornet_enroll for ' + @TABLE_NAME 
		EXEC SP_EXECUTESQL @SQL
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
	END CATCH
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'i2o_ontology_lab'))
	BEGIN TRY
		SET @TABLE_NAME = (SELECT tc.VALUE FROM i2o_transform_config tc where tc.[key] = 'ontology.lab.db.schema.table')
		SET @SQL = 'create view i2o_ontology_lab as (select * from  ' + @TABLE_NAME + ')'
		EXEC SP_EXECUTESQL @SQL
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
	END CATCH
GO

-- Create the demographics codelist (no need to modify)
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[omop_codelist]') AND type in (N'U'))
DROP TABLE [dbo].[omop_codelist]
GO

create table omop_codelist (codetype varchar(20), code varchar(50))
go



----------------------------------------------------------------------------------------------------------------------------------------
-- Unit Converter - By Matthew Joss
-- Here are two functions that need to be edited depending on the base units used at your site: unit_ht() and unit_wt(). 
-- Use the corresponding RETURN statement depending on which units your site uses: 
-- Inches (RETURN 1) versus Centimeters(RETURN 0.393701) and Pounds (RETURN 1) versus Kilograms(RETURN 2.20462).  
----------------------------------------------------------------------------------------------------------------------------------------
IF OBJECTPROPERTY (object_id('dbo.unit_ht'), 'IsScalarFunction') = 1 DROP function unit_ht

IF OBJECTPROPERTY (object_id('dbo.unit_wt'), 'IsScalarFunction') = 1 DROP function unit_wt
go

DECLARE @SQL nvarchar(4000)
DECLARE @UNIT_TYPE nvarchar(50)
SET @UNIT_TYPE = (SELECT tc.VALUE FROM i2o_transform_config tc WHERE tc.[key] = N'height.units');
IF @UNIT_TYPE = 'IMPERIAL'
	BEGIN TRY
		SET @SQL = 'CREATE FUNCTION unit_ht() RETURNS float(10) AS BEGIN RETURN 1 END'
		EXEC SP_EXECUTESQL @SQL
		-- Use this statement if your site stores HT data in units of Inches 
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
	END CATCH
IF @UNIT_TYPE = 'METRIC'
	BEGIN TRY
		SET @SQL = 'CREATE FUNCTION unit_ht() RETURNS float(10) AS BEGIN RETURN 0.393701 END'
		EXEC SP_EXECUTESQL @SQL
		-- Use this statement if your site stores HT data in units of Centimeters
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
	END CATCH
SET @UNIT_TYPE = (SELECT tc.VALUE FROM i2o_transform_config tc WHERE tc.[key] = 'weight.units');
IF @UNIT_TYPE = 'IMPERIAL'
	BEGIN TRY
		SET @SQL = 'CREATE FUNCTION unit_wt() RETURNS float(10) AS BEGIN RETURN 1 END'
		EXEC SP_EXECUTESQL @SQL
		-- Use this statement if your site stores WT data in units of Pounds
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
	END CATCH
IF @UNIT_TYPE = 'METRIC'
	BEGIN TRY
		SET @SQL = 'CREATE FUNCTION unit_wt() RETURNS float(10) AS BEGIN RETURN 2.20462 END'
		EXEC SP_EXECUTESQL @SQL
		-- Use this statement if your site stores WT data in units of Kilograms
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR: Failed to execute %s', 0, 1, @SQL) with NOWAIT;
	END CATCH 
GO

-----------------------------------------------------------------------------------------------------------------
-- Procedure to get a string part between two delimeters (i.e. a /)
-- E.g., replace(m.C_FULLNAME,dbo.stringpart(m.c_fullname,'\',m.C_HLEVEL)+'\','')
-- Jeff Klann, PhD 5/6/16
-----------------------------------------------------------------------------------------------------------------
drop function dbo.stringpart
GO
CREATE FUNCTION dbo.stringpart ( @stringToSplit VARCHAR(MAX),@delimiter char(1),@el int )
RETURNS varchar(max) 
AS
BEGIN

 DECLARE @name NVARCHAR(255)
 DECLARE @pos INT
 DECLARE @num INT

 SET @num=-2
 WHILE @num!=@el and CHARINDEX(@delimiter, @stringToSplit) > 0
 BEGIN
  SELECT @pos  = CHARINDEX(@delimiter, @stringToSplit)  
  SELECT @name = SUBSTRING(@stringToSplit, 1, @pos-1)

  SELECT @stringToSplit = SUBSTRING(@stringToSplit, @pos+1, LEN(@stringToSplit)-@pos)
  SET @num=@num+1
 END

 RETURN @name
END
GO

----------------------------------------------------------------------------------------------------------------------------------------
-- ALTER THE TABLES - 
----------------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[visit_provids]') AND type in (N'U'))
DROP TABLE [dbo].[visit_provids]
GO
CREATE TABLE [dbo].[visit_provids]  ( 
	[encounter_num]	int NULL,
	[provider_id]  	varchar(50) NULL 
	)
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PMN_LabNormal]') AND type in (N'U'))
DROP TABLE [dbo].[PMN_LabNormal]
GO
-- Lab Normal ranges table
CREATE TABLE [dbo].[PMN_LabNormal]  ( 
	[LAB_NAME]          	varchar(150) NULL,
	[NORM_RANGE_LOW]    	varchar(10) NULL,
	[NORM_MODIFIER_LOW] 	varchar(2) NULL,
	[NORM_RANGE_HIGH]   	varchar(10) NULL,
	[NORM_MODIFIER_HIGH]	varchar(2) NULL 
	)
GO
INSERT INTO [dbo].[PMN_LabNormal]([LAB_NAME], [NORM_RANGE_LOW], [NORM_MODIFIER_LOW], [NORM_RANGE_HIGH], [NORM_MODIFIER_HIGH])
  VALUES('LAB_NAME:LDL', '0', 'GE', '165', 'LE')
GO
INSERT INTO [dbo].[PMN_LabNormal]([LAB_NAME], [NORM_RANGE_LOW], [NORM_MODIFIER_LOW], [NORM_RANGE_HIGH], [NORM_MODIFIER_HIGH])
  VALUES('LAB_NAME:A1C', '', 'NI', '', 'NI')
GO
INSERT INTO [dbo].[PMN_LabNormal]([LAB_NAME], [NORM_RANGE_LOW], [NORM_MODIFIER_LOW], [NORM_RANGE_HIGH], [NORM_MODIFIER_HIGH])
  VALUES('LAB_NAME:CK', '50', 'GE', '236', 'LE')
GO
INSERT INTO [dbo].[PMN_LabNormal]([LAB_NAME], [NORM_RANGE_LOW], [NORM_MODIFIER_LOW], [NORM_RANGE_HIGH], [NORM_MODIFIER_HIGH])
  VALUES('LAB_NAME:CK_MB', '', 'NI', '', 'NI')
GO
INSERT INTO [dbo].[PMN_LabNormal]([LAB_NAME], [NORM_RANGE_LOW], [NORM_MODIFIER_LOW], [NORM_RANGE_HIGH], [NORM_MODIFIER_HIGH])
  VALUES('LAB_NAME:CK_MBI', '', 'NI', '', 'NI')
GO
INSERT INTO [dbo].[PMN_LabNormal]([LAB_NAME], [NORM_RANGE_LOW], [NORM_MODIFIER_LOW], [NORM_RANGE_HIGH], [NORM_MODIFIER_HIGH])
  VALUES('LAB_NAME:CREATININE', '0', 'GE', '1.6', 'LE')
GO
INSERT INTO [dbo].[PMN_LabNormal]([LAB_NAME], [NORM_RANGE_LOW], [NORM_MODIFIER_LOW], [NORM_RANGE_HIGH], [NORM_MODIFIER_HIGH])
  VALUES('LAB_NAME:CREATININE', '0', 'GE', '1.6', 'LE')
GO
INSERT INTO [dbo].[PMN_LabNormal]([LAB_NAME], [NORM_RANGE_LOW], [NORM_MODIFIER_LOW], [NORM_RANGE_HIGH], [NORM_MODIFIER_HIGH])
  VALUES('LAB_NAME:HGB', '12', 'GE', '17.5', 'LE')
GO
INSERT INTO [dbo].[PMN_LabNormal]([LAB_NAME], [NORM_RANGE_LOW], [NORM_MODIFIER_LOW], [NORM_RANGE_HIGH], [NORM_MODIFIER_HIGH])
  VALUES('LAB_NAME:INR', '0.8', 'GE', '1.3', 'LE')
GO
INSERT INTO [dbo].[PMN_LabNormal]([LAB_NAME], [NORM_RANGE_LOW], [NORM_MODIFIER_LOW], [NORM_RANGE_HIGH], [NORM_MODIFIER_HIGH])
  VALUES('LAB_NAME:TROP_I', '0', 'GE', '0.49', 'LE')
GO
INSERT INTO [dbo].[PMN_LabNormal]([LAB_NAME], [NORM_RANGE_LOW], [NORM_MODIFIER_LOW], [NORM_RANGE_HIGH], [NORM_MODIFIER_HIGH])
  VALUES('LAB_NAME:TROP_T_QL', '', 'NI', '', 'NI')
GO
INSERT INTO [dbo].[PMN_LabNormal]([LAB_NAME], [NORM_RANGE_LOW], [NORM_MODIFIER_LOW], [NORM_RANGE_HIGH], [NORM_MODIFIER_HIGH])
  VALUES('LAB_NAME:TROP_T_QN', '0', 'GE', '0.09', 'LE')
GO


IF  EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'xpk_condition_occurrence') 
	Alter table condition_occurrence DROP constraint xpk_condition_occurrence
Go
Alter Table condition_occurrence Drop Column condition_occurrence_id
Go

Alter Table condition_occurrence
Add condition_occurrence_id Int Identity(1, 1)
Go


IF  EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'xpk_procedure_occurrence') 
	Alter table procedure_occurrence DROP constraint xpk_procedure_occurrence
Go
Alter Table procedure_occurrence Drop Column procedure_occurrence_id
Go

Alter Table procedure_occurrence
Add procedure_occurrence_id Int Identity(1, 1)
Go

IF  EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'xpk_measurement') 
	Alter table measurement DROP constraint xpk_measurement
Go
Alter Table measurement Drop Column measurement_id
Go

Alter Table measurement
Add measurement_id Int Identity(1, 1)
Go

IF  EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'xpk_drug_exposure') 
	Alter table drug_exposure DROP constraint xpk_drug_exposure
Go
Alter Table drug_exposure Drop Column drug_exposure_id
Go

Alter Table drug_exposure
Add drug_exposure_id Int Identity(1, 1)
Go

IF  EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'xpk_observation_period') 
	Alter table observation_period DROP constraint xpk_observation_period
Go
Alter Table observation_period Drop Column observation_period_id
Go

Alter Table observation_period
Add observation_period_id Int Identity(1, 1)
Go

ALTER TABLE [dbo].[observation_period] ALTER COLUMN [observation_period_start_datetime] datetime NULL
GO

ALTER TABLE [dbo].[observation_period] ALTER COLUMN [observation_period_end_datetime] datetime NULL
GO


IF  EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'xpk_observation') 
	Alter table observation DROP constraint xpk_observation
Go
Alter Table observation Drop Column observation_id
Go

Alter Table observation
Add observation_id BigInt Identity(1, 1)
Go

-- todo: I should recreate these constraints or ask users to rerun the omop constraint script
alter table person drop constraint fpk_person_care_site
GO
alter table provider drop constraint fpk_provider_care_site
GO
Alter table care_site DROP constraint xpk_care_site
GO
Alter Table care_site Drop Column care_site_id
Go
Alter Table care_site
Add care_site_id Int Identity(1, 1)
Go

----------------------------------------------------------------------------------------------------------------------------------------
-- Prep-to-transform code
----------------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pcornet_parsecode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pcornet_parsecode]
GO

create procedure pcornet_parsecode (@codetype varchar(20), @codestring varchar(1000)) as

declare @tex varchar(2000)
declare @pos int
declare @readstate char(1) 
declare @nextchar char(1) 
declare @val varchar(50)

begin

set @val=''
set @readstate='F'
set @pos=0
set @tex = @codestring
while @pos<len(@tex)
begin
	set @pos = @pos +1
	set @nextchar=substring(@tex,@pos,1)
	if @nextchar=',' continue
	if @nextchar='''' 
	begin
		if @readstate='F' 
			begin
			set @readstate='T' 
			continue
			end
		else 
			begin
			insert into omop_codelist values (@codetype,@val)
			set @val=''
			set @readstate='F'  
			end
	end
	if @readstate='T'
	begin
		set @val= @val + @nextchar
	end		
end 
end
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pcornet_popcodelist]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pcornet_popcodelist]
GO
create procedure pcornet_popcodelist as

declare @codedata varchar(2000)
declare @onecode varchar(50)
declare @codetype varchar(20)

declare getcodesql cursor local for
select 'RACE',c_dimcode from pcornet_demo where c_fullname like '\PCORI\DEMOGRAPHIC\RACE%'
union
select 'SEX',c_dimcode from pcornet_demo where c_fullname like '\PCORI\DEMOGRAPHIC\SEX%'
union
select 'HISPANIC',c_dimcode from pcornet_demo where c_fullname like '\PCORI\DEMOGRAPHIC\HISPANIC\Y%'

begin
delete from omop_codelist;
open getcodesql ;
fetch next from getcodesql  into @codetype,@codedata;
while @@fetch_status=0
begin	
 
	exec pcornet_parsecode  @codetype,@codedata 
	fetch next from getcodesql  into @codetype,@codedata;
end

close getcodesql ;
deallocate getcodesql ;
end

go

-- create the reporting table - don't do this once you are running stuff and you want to track loads
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'i2oreport') AND type in (N'U')) DROP TABLE i2oreport
GO
create table i2oreport (runid numeric, rundate smalldatetime, concept varchar(20), sourceval numeric, sourcedistinct numeric, destval numeric, destdistinct numeric)
go
insert into i2oreport (runid) select 0

-- Run the popcodelist procedure we just created
EXEC pcornet_popcodelist
GO

--- Load the procedures

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- Demographics 
----------------------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPdemographics') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPdemographics
go

create procedure OMOPdemographics as 

DECLARE @sqltext NVARCHAR(4000);
DECLARE @batchid numeric
declare getsql cursor local for 
--1 --  S,R,NH
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,birth_datetime,gender_concept_id,ethnicity_concept_id,race_concept_id) '+ --person(raw_sex,PATID, BIRTH_DATE, BIRTH_TIME,SEX, HISPANIC, RACE) 
	'	select p.sex_cd+'':'+sex.c_name+''',substring(p.race_cd+'':'+race.c_name+''', 1, 50),substring(p.race_cd+'':Unknown'', 1, 50),patient_num, '+
	'	year(birth_date), '+
    '	month(birth_date), '+
    '	day(birth_date), '+
	'	birth_date, '+ --Bug fix MJ 5/10/17
	''''+sex.omop_basecode+''','+
	'0,'+
	''''+race.omop_basecode+''''+
	' from i2b2patient p '+
	'	where lower(p.sex_cd) in ('+lower(sex.c_dimcode)+') '+
	'	and	lower(p.race_cd) in ('+lower(race.c_dimcode)+') '+
	'   and lower(isnull(p.race_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''HISPANIC'') '+
	'   and patient_num not in (select person_id from person)' --bug fix MJ 3/19/18
    from pcornet_demo race, pcornet_demo sex
	where race.c_fullname like '\PCORI\DEMOGRAPHIC\RACE\%'
	and race.c_visualattributes like 'L%'
	and sex.c_fullname like '\PCORI\DEMOGRAPHIC\SEX\%'
	and sex.c_visualattributes like 'L%'
union -- A - S,R,H
select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,birth_datetime,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
	'	select p.sex_cd+'':'+sex.c_name+''',substring(p.race_cd+'':'+race.c_name+''', 1, 50), substring(p.race_cd+'':'+hisp.c_name+''', 1, 50),patient_num, '+ --'	select p.sex_cd+'':''+sex.c_name,p.race_cd+'':''+race.c_name,p.race_cd+'':''+hisp.c_name,patient_num, '+
	'	year(birth_date), '+
    '	month(birth_date), '+
    '	day(birth_date), '+
	'	birth_date, '+ --Bug fix MJ 5/10/17
	''''+sex.omop_basecode+''','+
	''''+hisp.omop_basecode+''','+
	''''+race.omop_basecode+''''+
	' from i2b2patient p '+
	'	where lower(p.sex_cd) in ('+lower(sex.c_dimcode)+') '+
	'	and	lower(p.race_cd) in ('+lower(race.c_dimcode)+') '+
	'	and	lower(isnull(p.race_cd,''xx'')) in (select lower(code) from omop_codelist where codetype=''RACE'') '+
	'   and lower(isnull(p.race_cd,''xx'')) in (select lower(code) from omop_codelist where codetype=''HISPANIC'') '+
	'   and patient_num not in (select person_id from person)' --bug fix MJ 3/19/18
    from pcornet_demo race, pcornet_demo hisp, pcornet_demo sex
	where race.c_fullname like '\PCORI\DEMOGRAPHIC\RACE\%'
	and race.c_visualattributes like 'L%'
	and hisp.c_fullname like '\PCORI\DEMOGRAPHIC\HISPANIC\Y%'
	and hisp.c_visualattributes like 'L%'
	and sex.c_fullname like '\PCORI\DEMOGRAPHIC\SEX\%'
	and sex.c_visualattributes like 'L%'
union --2 S, nR, nH
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,birth_datetime,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
	'	select p.sex_cd+'':'+sex.c_name+''',substring(p.race_cd+'':Unknown'', 1, 50), substring(p.race_cd+'':Unknown'', 1, 50),patient_num, '+ --'	select p.sex_cd,p.race_cd,p.race_cd,patient_num, '+
	'	year(birth_date), '+
    '	month(birth_date), '+
    '	day(birth_date), '+
	'	birth_date, '+ --Bug fix MJ 5/10/17
	''''+sex.omop_basecode+''','+
	'0,'+
	'0'+
	' from i2b2patient p '+
	'	where lower(isnull(p.sex_cd,''xx'')) in ('+lower(sex.c_dimcode)+') '+
	'	and	lower(isnull(p.race_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''RACE'') '+
	'   and lower(isnull(p.race_cd,''ni'')) not in (select lower(code) from omop_codelist where codetype=''HISPANIC'') '+
    '   and patient_num not in (select person_id from person)' --bug fix MJ 3/19/18
	from pcornet_demo sex
	where sex.c_fullname like '\PCORI\DEMOGRAPHIC\SEX\%'
	and sex.c_visualattributes like 'L%'
union --3 -- nS,R, NH
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,birth_datetime,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
	'	select p.sex_cd,substring(p.race_cd+'':'+race.c_name+''', 1, 50),substring(p.race_cd+'':Unknown'', 1, 50),patient_num, '+
	'	year(birth_date), '+
    '	month(birth_date), '+
    '	day(birth_date), '+
	'	birth_date, '+ --Bug fix MJ 5/10/17
	'0,'+
	'0,'+
	''''+race.omop_basecode+''''+
	' from i2b2patient p '+
	'	where lower(isnull(p.sex_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''SEX'') '+
	'	and	lower(p.race_cd) in ('+lower(race.c_dimcode)+') '+
	'   and lower(isnull(p.race_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''HISPANIC'')'+
	'   and patient_num not in (select person_id from person)' --bug fix MJ 3/19/18
    from pcornet_demo race
	where race.c_fullname like '\PCORI\DEMOGRAPHIC\RACE\%'
	and race.c_visualattributes like 'L%'
union --B -- nS,R, H
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,birth_datetime,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
	'	select p.sex_cd,substring(p.race_cd+'':'+race.c_name+''', 1, 50),substring(p.race_cd+'':'+hisp.c_name+''', 1, 50),patient_num, '+
	'	year(birth_date), '+
    '	month(birth_date), '+
    '	day(birth_date), '+
	'	birth_date, '+ --Bug fix MJ 5/10/17
	'0,'+
	''''+hisp.omop_basecode+''','+
	''''+race.omop_basecode+''''+
	' from i2b2patient p '+
	'	where lower(isnull(p.sex_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''SEX'') '+
	'	and	lower(p.race_cd) in ('+lower(race.c_dimcode)+') '+
	'	and	lower(isnull(p.race_cd,''xx'')) in (select lower(code) from omop_codelist where codetype=''RACE'') '+
	'   and lower(isnull(p.race_cd,''xx'')) in (select lower(code) from omop_codelist where codetype=''HISPANIC'')'+
    '   and patient_num not in (select person_id from person)'  --bug fix MJ 3/19/18
	from pcornet_demo race,pcornet_demo hisp
	where race.c_fullname like '\PCORI\DEMOGRAPHIC\RACE\%'
	and race.c_visualattributes like 'L%'
	and hisp.c_fullname like '\PCORI\DEMOGRAPHIC\HISPANIC\Y%'
	and hisp.c_visualattributes like 'L%'
union --4 -- S, NR, H
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,birth_datetime,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
	'	select p.sex_cd+'':'+sex.c_name+''',substring(p.race_cd+'':Unknown'', 1, 50),substring(p.race_cd+'':Hispanic'', 1, 50),patient_num, '+
	'	year(birth_date), '+
    '	month(birth_date), '+
    '	day(birth_date), '+
	'	birth_date, '+ --Bug fix MJ 5/10/17
	''''+sex.omop_basecode+''','+
	'38003563,'+
	'0'+
	' from i2b2patient p '+
	'	where lower(isnull(p.sex_cd,''NI'')) in ('+lower(sex.c_dimcode)+') '+
	'	and lower(isnull(p.race_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''RACE'') '+
	'	and lower(isnull(p.race_cd,''xx'')) in (select lower(code) from omop_codelist where codetype=''HISPANIC'') '+
	'   and patient_num not in (select person_id from person)'  --bug fix MJ 3/19/18
    from pcornet_demo sex
	where sex.c_fullname like '\PCORI\DEMOGRAPHIC\SEX\%'
	and sex.c_visualattributes like 'L%'
union --5 -- NS, NR, H
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,birth_datetime,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
	'	select p.sex_cd,substring(p.race_cd+'':Unknown'', 1, 50),substring(p.race_cd+'':Hispanic'', 1, 50),patient_num, '+
	'	year(birth_date), '+
    '	month(birth_date), '+
    '	day(birth_date), '+
	'	birth_date, '+ --Bug fix MJ 5/10/17
	'0,'+
	'38003563,'+
	'0'+
	' from i2b2patient p '+
	'	where lower(isnull(p.sex_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''SEX'') '+
	'	and lower(isnull(p.race_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''RACE'') '+
	'	and lower(isnull(p.race_cd,''xx'')) in (select lower(code) from omop_codelist where codetype=''HISPANIC'')' +
    '   and patient_num not in (select person_id from person)'  --bug fix MJ 3/19/18
union --6 -- NS, NR, nH
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,birth_datetime,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
	'	select p.sex_cd,substring(p.race_cd+'':Unknown'', 1, 50),substring(p.race_cd+'':Unknown'', 1, 50),patient_num, '+
	'	year(birth_date), '+
    '	month(birth_date), '+
    '	day(birth_date), '+
	'	birth_date, '+ --Bug fix MJ 5/10/17
	'0,'+
	'0,'+
	'0'+
    ' from i2b2patient p '+
	'	where lower(isnull(p.sex_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''SEX'') '+
	'	and lower(isnull(p.race_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''HISPANIC'') '+
	'   and lower(isnull(p.race_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''RACE'') ' +
    '   and patient_num not in (select person_id from person)'  --bug fix MJ 3/19/18
begin
exec pcornet_popcodelist

set @batchid = 0
OPEN getsql;
FETCH NEXT FROM getsql INTO @sqltext;

WHILE @@FETCH_STATUS = 0
BEGIN
	print @sqltext
	exec sp_executesql @sqltext
	FETCH NEXT FROM getsql INTO @sqltext;
	
END

CLOSE getsql;
DEALLOCATE getsql;

end

go

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- Build Mapping Transform -- Consolidated from other code written by Jeff Klann Ph. D.
-- This is run here and should be rerun whenever the OMOP concept dictionary is updated!
----------------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPBuildMapping') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPBuildMapping
go

create procedure OMOPBuildMapping as
begin

-- Create a units_cd conversion table
EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''i2o_unitsmap'') AND type in (N''U'')) DROP TABLE i2o_unitsmap')

select c1 units_name,isnull(concept2,concept1) concept_id,s2 standard_concept
 into i2o_unitsmap
from
(select distinct c.concept_name c1,c.concept_id concept1,c.standard_concept s1,c2.concept_name c2,c2.concept_id concept2,c2.standard_concept s2 from concept c 
left outer join concept_relationship r on c.concept_id  =r.concept_id_1
left outer join concept as c2 on r.concept_id_2=c2.concept_id
where c.domain_id='Unit' 
and (c2.vocabulary_id='UCUM' or c2.vocabulary_id is null) and 
      (c2.standard_concept='S' or c2.standard_concept is null) and 
      (c2.domain_id='Unit' or c2.domain_id is null)) x


-- **** DX MAPPING ***
-- ********************
EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''concept_map_dx_dx'') AND type in (N''U'')) DROP TABLE concept_map_dx_dx')
EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''concept_map_dx_obs'') AND type in (N''U'')) DROP TABLE concept_map_dx_obs')
EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''concept_map_dx_meas'') AND type in (N''U'')) DROP TABLE concept_map_dx_meas')
EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''concept_map_dx_proc'') AND type in (N''U'')) DROP TABLE concept_map_dx_proc')

-- 5/18 jgk - pull OMOP mappings from concept each time
-- Notes on mappings:
-- 1) There is a 1:1 mapping from ICD9/10 code to OMOP id, though this does not always map to Condition
-- 2) There is a mapping from OMOP id to SNOMED, but many times the source domain is Condition but the only entry in SNOMED is a different domain, like Observation
-- * Presently we retain rows when either the ICD9/10 id or the SNOMED id is in Condition, but we fill in id with 0 and populate source_id if mapped domain is not Condition
select c_basecode, substring(pcori_basecode,charindex(':',pcori_basecode)+1,200) pcori_basecode, c.concept_code, c.vocabulary_id, c.domain_id,c.concept_id, c2.concept_code mapped_code, c2.vocabulary_id mapped_vocabulary, c2.domain_id mapped_domain,c2.concept_id mapped_id into #concept_map
from pcornet_diag d inner join concept as c
on concept_code=substring(pcori_basecode,charindex(':',pcori_basecode)+1,200) -- old ontologies had ICD9: in pcori_basecode and it needs to be stripped
and vocabulary_id=case dbo.stringpart(c_fullname,'\',2) when '09' THEN 'ICD9CM' when '10' THEN 'ICD10CM' END
left join  concept_relationship cr  ON c.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
left join concept c2 ON c2.concept_id =cr.concept_id_2
and c2.standard_concept ='S'
and c2.invalid_reason is null
where c_synonym_cd='N'
and c.invalid_reason is NULL
and sourcesystem_cd not like '%(I9inI10)%'
-- Skip ICD-9 V codes in 10 ontology, ICD-9 E codes in 10 ontology, ICD-10 numeric codes in 10 ontology 
-- SOURCESYSTEM_CD should take care of this, but in case the site used the i2b2 mapping tool, it does not propagate sourcesystem_cd
-- Note: makes the assumption that ICD-9 Ecodes are not ICD-10 Ecodes; same with ICD-9 V codes. On inspection seems to be true.
and (c_fullname not like '\PCORI\DIAGNOSIS\10\%' or
  ( not ( pcori_basecode like '[V]%' and c_fullname not like '\PCORI\DIAGNOSIS\10\([V]%\([V]%\([V]%' )
  and not ( pcori_basecode like '[E]%' and c_fullname not like '\PCORI\DIAGNOSIS\10\([E]%\([E]%\([E]%' ) 
  and not (c_fullname like '\PCORI\DIAGNOSIS\10\%' and pcori_basecode like '[0-9]%') ))  

-- I would like an extra temporary table here that would remove null mappings when there exists a non-null mapping
-- The tricky part to remember is many single diagnoses map to multiple SNOMED codes
select * into concept_map_dx_dx from
(select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id from #concept_map 
  where domain_id='Condition' or mapped_domain='Condition' ) x
insert into concept_map_dx_dx(c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id)
select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id from #concept_map 
  where domain_id='Condition'and concept_id not in (select concept_id from concept_map_dx_dx)  
  
create index concept_map_dx_dx_idx on concept_map_dx_dx(c_basecode)

-- Next, update observation table ---
select * into concept_map_dx_obs from
(select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id from #concept_map 
  where domain_id='Observation' or mapped_domain='Observation' ) x
insert into concept_map_dx_obs(c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id)
select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id from #concept_map 
  where domain_id='Observation'  and concept_id not in (select concept_id from concept_map_dx_obs) 
create index concept_map_obs_idx on concept_map_dx_obs(c_basecode)

/*-- Next, update device table --- <-- not required by current projects
select * into #concept_map_dev from
(select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id from #concept_map 
  where domain_id='Device' or mapped_domain='Device' ) x
insert into #concept_map_dev(c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id)
select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id from #concept_map 
  where domain_id='Device'  and concept_id not in (select concept_id from #concept_map_dev) 
create index concept_map_dev_idx on #concept_map_dev(c_basecode)*/

-- Next, update measurement table ---
select * into concept_map_dx_meas from
(select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id from #concept_map 
  where domain_id='Measurement' or mapped_domain='Measurement' ) x
insert into concept_map_dx_meas(c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id)
select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id from #concept_map 
  where domain_id='Measurement'  and concept_id not in (select concept_id from concept_map_dx_meas) 
create index concept_map_mea_idx on concept_map_dx_meas(c_basecode)

-- Next, update procedure table ---
select * into concept_map_dx_proc from
(select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id from #concept_map 
  where domain_id='Procedure' or mapped_domain='Procedure' ) x
insert into concept_map_dx_proc(c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id)
select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id from #concept_map 
  where domain_id='Procedure'  and concept_id not in (select concept_id from concept_map_dx_proc) 
create index concept_map_proc_idx on concept_map_dx_proc(c_basecode)

-- **** PX MAPPING ***
-- ********************
EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''concept_map_px_px'') AND type in (N''U'')) DROP TABLE concept_map_px_px')
EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''concept_map_px_obs'') AND type in (N''U'')) DROP TABLE concept_map_px_obs')
EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''concept_map_px_meas'') AND type in (N''U'')) DROP TABLE concept_map_px_meas')
EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''concept_map_px_dx'') AND type in (N''U'')) DROP TABLE concept_map_px_dx')
EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''concept_map_px_rx'') AND type in (N''U'')) DROP TABLE concept_map_px_rx')
EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''i2o_mapping'') AND type in (N''U'')) DROP TABLE i2o_mapping')

-- Create on-the-fly vocab mappings
truncate table #concept_map
insert into #concept_map
select c_basecode, substring(pcori_basecode,charindex(':',pcori_basecode)+1,200) pcori_basecode, c.concept_code, c.vocabulary_id, c.domain_id,c.concept_id, c2.concept_code mapped_code, c2.vocabulary_id mapped_vocabulary, c2.domain_id mapped_domain,c2.concept_id mapped_id
from pcornet_proc p inner join concept as c
on concept_code=substring(pcori_basecode,charindex(':',pcori_basecode)+1,200) -- old ontologies had ICD9: in pcori_basecode and it needs to be stripped
and vocabulary_id=case dbo.stringpart(c_fullname,'\',2) when '09' THEN 'ICD9Proc' when '10' THEN 'ICD10PCS' WHEN 'CH' THEN 
 case dbo.stringpart(c_fullname,'\',3) when 'HC' THEN 'HCPCS' ELSE 'CPT4' END END
left join  concept_relationship cr  ON c.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
left join concept c2 ON c2.concept_id =cr.concept_id_2
and c2.standard_concept ='S'
and c2.invalid_reason is null
where c_synonym_cd='N'
-- still want old codes -- and c.invalid_reason is NULL

/* Interesting discovery: OMOP deletes mappings from concept_relationship for deleted CPT codes. CPT codes are deleted regularly. They still live in concept and self-mappings are legal for CPT and ICD in Procedure. So we create
 self-mappings to them rather than null mappings. This increases our total procedures to > last version. */
select * into concept_map_px_px from
(select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id from #concept_map 
  where (domain_id='Procedure' or mapped_domain='Procedure') and mapped_id is not null ) x
insert into concept_map_px_px(c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id)
select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id from #concept_map 
  where domain_id='Procedure'and concept_id not in (select concept_id from concept_map_px_px)  and mapped_id is not null 
insert into concept_map_px_px(c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id)
select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, concept_code mapped_code, vocabulary_id mapped_vocabulary, domain_id mapped_domain, concept_id mapped_id from #concept_map 
  where domain_id='Procedure' and vocabulary_id in ('CPT4','ICD10PCS','HCPCS') and concept_id not in (select concept_id from concept_map_px_px) 
create index concept_map_pxpx_idx on concept_map_px_px(c_basecode)

-- observation table ---
-- When mapped domain is not present, use unmapped code if it is CPT4, ICD-10, or HCPCS - these that do not have mappings are standard codes
select * into concept_map_px_obs from
(select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id from #concept_map 
  where mapped_domain='Observation' ) x
insert into concept_map_px_obs(c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id)
select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, concept_code mapped_code, vocabulary_id mapped_vocabulary, domain_id mapped_domain, concept_id mapped_id from #concept_map 
  where domain_id='Observation' and vocabulary_id in ('CPT4','ICD10PCS','HCPCS') and concept_id not in (select concept_id from concept_map_px_obs) 
create index concept_map_pxobs_idx on concept_map_px_obs(c_basecode)

-- Next, update measurement table ---
-- Millions of records (7k codes) get thrown into here - measurements like PTT that we have no value for
select * into concept_map_px_meas from
(select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id from #concept_map 
  where mapped_domain='Measurement' ) x
insert into concept_map_px_meas(c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id)
select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, concept_code mapped_code, vocabulary_id mapped_vocabulary, domain_id mapped_domain, concept_id mapped_id from #concept_map 
  where domain_id='Measurement' and vocabulary_id in ('CPT4','ICD10PCS','HCPCS') and concept_id not in (select concept_id from concept_map_px_meas) 
create index concept_map_pxmea_idx on concept_map_px_meas(c_basecode)

-- Next, update dx table ---
select * into concept_map_px_dx from
(select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id from #concept_map 
  where mapped_domain='Condition' ) x
insert into concept_map_px_dx(c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id)
select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, concept_code mapped_code, vocabulary_id mapped_vocabulary, domain_id mapped_domain, concept_id mapped_id from #concept_map 
  where domain_id='Condition' and vocabulary_id in ('CPT4','ICD10PCS','HCPCS') and concept_id not in (select concept_id from concept_map_px_dx) 
create index concept_map_pxmea_idx on concept_map_px_dx(c_basecode)

-- Next, update drug table
-- These are all (apparently) entries for vaccines
select * into concept_map_px_rx from
(select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id from #concept_map 
  where mapped_domain='Drug' ) x
insert into concept_map_px_rx(c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, mapped_code, mapped_vocabulary, mapped_domain, mapped_id)
select c_basecode, pcori_basecode, concept_code, vocabulary_id, domain_id,concept_id, concept_code mapped_code, vocabulary_id mapped_vocabulary, domain_id mapped_domain, concept_id mapped_id from #concept_map 
  where domain_id='Drug' and vocabulary_id in ('CPT4','ICD10PCS','HCPCS') and concept_id not in (select concept_id from concept_map_px_rx) 
create index concept_map_pxrx_idx on concept_map_px_rx(c_basecode)

EXEC('DROP TABLE #concept_map')

-- New 04-20, no now builds i2o-mapping on the fly, which was needed for labs and drug exposure

-- Add labs from the ontology
select distinct c1.concept_code source_code, c1.concept_id source_id, convert(int, c2.concept_id) concept_id,convert(varchar(20),c2.domain_id) domain_id -- convert is to allow nulls
into i2o_mapping
from i2o_ontology_lab d inner join concept c1 on (c1.concept_code=d.i_stdcode and d.i_stddomain='LOINC' and c1.domain_id='Measurement')
inner join  concept_relationship cr   ON  c1.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
inner join concept c2 ON c2.concept_id =cr.concept_id_2
and c2.standard_concept ='S'
and c2.invalid_reason is null
and c2.domain_id='Measurement';

-- Add drugs from the ontology
-- Note: left joins to support non-standard codes (no mapping) in i2o-2020.
insert into i2o_mapping(source_code, source_id,concept_id,domain_id)
select distinct c1.concept_code source_code, c1.concept_id source_id, c2.concept_id,isnull(c2.domain_id,c1.domain_id)
from i2o_ontology_drug d inner join concept c1 on (c1.concept_code=d.i_stdcode and (d.i_stddomain='RxNorm' or d.i_stddomain='NDC') and c1.domain_id='Drug')
left join  concept_relationship cr   ON  c1.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
left join concept c2 ON c2.concept_id =cr.concept_id_2
and c2.standard_concept ='S'
and c2.invalid_reason is null
and c2.domain_id='Drug';

-- Index it
CREATE NONCLUSTERED INDEX [i2omap_index]
	ON [dbo].[i2o_mapping]([source_code]);

end
go
exec OMOPBuildMapping

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- Care Site Transform -- Written by Matthew Joss, and Jeff Klann Ph. D.
--NEW 08-23-18!
----------------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPCare_site') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPCare_site
go

create procedure OMOPCare_site as
begin

insert into care_site(place_of_service_source_value, care_site_name)
select distinct location_cd, location_cd
from i2b2visit where location_cd is not null

end
go

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- Encounter - by Jeff Klann and Aaron Abend and Matthew Joss
----------------------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPencounter') AND type in (N'P', N'PC'))
DROP PROCEDURE OMOPencounter
GO

create procedure OMOPencounter as

DECLARE @sqltext NVARCHAR(4000);
begin

insert into visit_occurrence with(tablock) (person_id,visit_occurrence_id,visit_start_date,visit_start_datetime, 
		visit_end_date,visit_end_datetime,provider_id,  
		visit_concept_id ,care_site_id,visit_type_concept_id,visit_source_value) 
select distinct v.patient_num, v.encounter_num,  
	convert(date, start_Date) as visit_start_date, 
	start_Date as visit_start_datetime, 
	ISNULL(convert(date, end_date), ISNULL((select convert(date, max(f.start_date)) from i2b2fact f where f.encounter_num = v.encounter_num group by f.encounter_num), convert(date, start_date))) end_Date, 
	ISNULL(end_date, ISNULL((select max(f.start_date) from i2b2fact f where f.encounter_num = v.encounter_num group by f.encounter_num), start_date)) end_datetime,  
	provider.provider_id, --insert provider id instead of '0.'
(case when e.omop_basecode is not null then e.omop_basecode else '0' end) enc_type, care.care_site_id, '44818518' as visit_type_concept_id,v.inout_cd  
from i2b2visit v inner join person d on v.patient_num=d.person_id
inner join visit_provids t on t.encounter_num=v.encounter_num
left outer join  pcornet_enc e on c_dimcode like '%'''+inout_cd+'''%' and e.c_fullname like '\PCORI\ENCOUNTER\ENC_TYPE\%'
left outer join provider on t.provider_id = provider.provider_source_value 
left outer join care_site care on v.location_cd = care.place_of_service_source_value


end
go


----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- Observation Period  - Jeff Klann
-- Very simple adaptation of PCORNet Enrollment table
----------------------------------------------------------------------------------------------------------------------------------------
------------------------- Enrollment Code ------------------------------------------------ 
-- Written by Jeff Klann, PhD
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPObservationPeriod') AND type in (N'P', N'PC'))
DROP PROCEDURE OMOPObservationPeriod
GO

create procedure OMOPObservationPeriod as
begin

INSERT INTO [Observation_Period]([person_id], [observation_period_start_date], [observation_period_end_date], [period_type_concept_id] ) 
    select person_id
		, ISNULL(min_start, ISNULL(dob, SYSDATETIME())) observation_period_start_date
		, ISNULL(max_end, ISNULL(max_start, ISNULL(dob, SYSDATETIME()))) observation_period_end_date
		, CASE when min_start IS NULL then 44814725 else 44814724 end period_type_concept_id
	from (
		select p.person_id, min(v.start_date) min_start, max(v.start_date) max_start, max(end_date) max_end, min(p.birth_datetime) dob from person p
		left outer join i2b2visit v on p.person_id = v.patient_num
		group by p.person_id) person_dates

end
go
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- Diagnosis - by Jeff Klann and Matthew Joss and Aaron Abend
-- v2 5/18 - now builds concept map on the fly and inserts into all 4 target tables
-- 5/19 - now uses concept map built in consolidated proc omopbuildmapping
----------------------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPdiagnosis') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPdiagnosis
go

create procedure OMOPdiagnosis as
declare @sqltext nvarchar(4000)
begin

-- Optimized to use temp tables, not views. 
select  patient_num, encounter_num, factline.provider_id, concept_cd, start_date, dxsource.pcori_basecode dxsource, dxsource.c_fullname
into #sourcefact
from i2b2fact factline
--inner join visit_occurrence enc on enc.person_id = factline.patient_num and enc.visit_occurrence_id = factline.encounter_Num
inner join pcornet_diag dxsource on factline.modifier_cd =dxsource.c_basecode  
where dxsource.c_fullname like '\PCORI_MOD\CONDITION_OR_DX\%'

select  patient_num, encounter_num, factline.provider_id, concept_cd, start_date, dxsource.pcori_basecode pdxsource,dxsource.c_fullname 
into #pdxfact from i2b2fact factline 
--inner join visit_occurrence enc on enc.person_id = factline.patient_num and enc.visit_occurrence_id = factline.encounter_Num 
inner join pcornet_diag dxsource on factline.modifier_cd =dxsource.c_basecode  
and dxsource.c_fullname like '\PCORI_MOD\PDX\%'

insert into condition_occurrence with (tablock) (person_id, visit_occurrence_id, condition_start_date, provider_id, condition_concept_id, condition_type_concept_id, condition_end_date, condition_source_value, condition_source_concept_id, condition_start_datetime) --pmndiagnosis (patid,encounterid, X enc_type, admit_date, providerid, dx, dx_type, dx_source, pdx)
select distinct factline.patient_num, factline.encounter_num encounterid, convert(date,factline.start_date), enc.provider_id, 
case diag.mapped_domain when 'Condition' then diag.mapped_id else '0' END, -- insufficient, sometimes target domains are non-null and non-condition: isnull(diag.mapped_id, '0'), 
CASE WHEN (sf.c_fullname like '\PCORI_MOD\CONDITION_OR_DX\DX_SOURCE\%' or sf.c_fullname is null) THEN 
    CASE WHEN pf.pdxsource = 'P' THEN 44786627 WHEN pf.pdxsource= 'S' THEN 44786629 ELSE '0' END 
    ELSE 38000245 END, 
end_date, pcori_basecode, diag.concept_id, factline.start_date
from i2b2fact factline
inner join visit_occurrence enc on enc.person_id = factline.patient_num and enc.visit_occurrence_id = factline.encounter_Num
 left outer join #sourcefact sf
on	factline.patient_num=sf.patient_num
and factline.encounter_num=sf.encounter_num
and factline.provider_id=sf.provider_id 
and factline.concept_cd=sf.concept_Cd
and factline.start_date=sf.start_Date 
left outer join #pdxfact pf
on	factline.patient_num=pf.patient_num
and factline.encounter_num=pf.encounter_num
and factline.provider_id=pf.provider_id 
and factline.concept_cd=pf.concept_cd
and factline.start_date=pf.start_Date 
inner join concept_map_dx_dx diag on diag.c_basecode = factline.concept_cd and (diag.mapped_domain='Condition' or diag.domain_id='Condition')
-- Note: old I9inI10 exclusion logic now above in concept_map code

-- Next, update observation table ---
insert into observation with(tablock) (person_id,observation_concept_id,observation_date, observation_datetime, observation_type_concept_id,provider_id,observation_source_value,observation_source_concept_id,visit_occurrence_id)
select  distinct fact.patient_num, case diag.mapped_domain when 'Observation' then diag.mapped_id else '0' END, fact.start_date, fact.start_date, 38000280 -- observation recorded from EHR
  , 0, diag.PCORI_BASECODE, diag.concept_id, fact.encounter_num from i2b2fact fact 
inner join visit_occurrence enc on enc.person_id = fact.patient_num and enc.visit_occurrence_id = fact.encounter_Num -- encounters limit amount of output
inner join concept_map_dx_obs diag on diag.c_basecode = fact.concept_cd

-- Next, update measurement table ---
INSERT INTO [dbo].[measurement] with(tablock) ([person_id], [measurement_concept_id], [measurement_date], [measurement_datetime], [measurement_type_concept_id], [provider_id], [visit_occurrence_id], [measurement_source_value], [measurement_source_concept_id]) 
select  distinct fact.patient_num, case diag.mapped_domain when 'Measurement' then diag.mapped_id else '0' END, fact.start_date, fact.start_date, 45754907 -- derived value. Other option is 5001, test ordered through EHR 
  , 0, fact.encounter_num, diag.PCORI_BASECODE, diag.concept_id from i2b2fact fact
inner join visit_occurrence enc on enc.person_id = fact.patient_num and enc.visit_occurrence_id = fact.encounter_Num -- encounters limit amount of output
inner join concept_map_dx_meas diag on diag.c_basecode = fact.concept_cd

-- Next, update procedure table ---
insert into procedure_occurrence with(tablock)( person_id,  procedure_concept_id, procedure_date, procedure_type_concept_id, modifier_concept_id, quantity, provider_id, visit_occurrence_id, procedure_source_value, procedure_source_concept_id, qualifier_source_value, procedure_datetime) 
select  distinct fact.patient_num, case diag.mapped_domain when 'Procedure' then diag.mapped_id else '0' END, fact.start_date, 44786630 /*primary*/, 0, null, null, fact.encounter_num, diag.PCORI_BASECODE, diag.concept_id, null, fact.start_date
from i2b2fact fact inner join concept_map_dx_proc diag on diag.c_basecode = fact.concept_cd
inner join visit_occurrence enc on enc.person_id = fact.patient_num and enc.visit_occurrence_id = fact.encounter_Num -- encounters limit amount of output

end
go

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- Procedures - by Jeff Klann and Aaron Abend and Matthew Joss and Kevin Embree
-- NEW VERSION 5/18 now grabs mappings from the OMOP vocab tables on the fly!
-- 5/19 - now uses concept map built in consolidated proc omopbuildmapping
----------------------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPprocedure') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPprocedure
go

create procedure OMOPprocedure as

begin

---------------------------------------
-- Copied and tweaked from condition_ocurrence procedure 'OMOPDiagnosis'
---------------------------------------

---------------------- Old PCORI Columns----------------------------------------------------------
--				patid,			encounterid,	enc_type, admit_date, providerid, px, px_type, px_source,px_date) 
---------------------------------------------------------------------------------------------------
insert into procedure_occurrence( person_id,  procedure_concept_id, procedure_date, procedure_type_concept_id, modifier_concept_id, quantity, provider_id, visit_occurrence_id, procedure_source_value, procedure_source_concept_id, qualifier_source_value, procedure_datetime) 
---------------------- Old PCORI values ----------------------------------------------------------------
--enc.encounterid, fact.patient_num, 	enc.enc_type, enc.admit_date, 
--		enc.providerid, substring(pr.pcori_basecode,charindex(':',pr.pcori_basecode)+1,11) px, substring(pr.c_fullname,18,2) pxtype, 'NI' px_source,fact.start_date
--------------------------------------------------------------------------------------------------------------------------
-- procedure_occurance_id ----------> set to identity column (not shown here)----------------------> Done
-- person_id -----------------------> patient_num unique identifier for the patient in i2b2--------> Done
-- procedure_concept_id ------------> i2o_mapping concept_id---------------------------------------> Done
-- procedure_date ------------------> encounter visit_start_date ----------------------------------> Done
-- procedure_type_concept_id -------> 44786630 (primary), 44786631 (secondary), 0 (unknown), how do we know the difference??????
-- modifier_concept_id -------------> (Set to 0 for Data Sprint 2)
-- quantity ------------------------>  Quantity of procedures done in this visit????? Count of procedures per patient/visit??????
-- provider_id ---------------------> (Set to 0 for Data Sprint 2)
-- visit_occurence_id --------------> observation_fact.encounter_num i2b2 id for the encounter (visit)-> Done
-- procedure_source_value ----------> PCORI base code from ontology -------------------------------> Done
-- procuedure_source_concept_id ----> OMOP source code from ontology ------------------------------> Done
-- qualifier_source_value ----------> The source code for the qualifier as it appears in the source data. What is this?????????????
select  distinct fact.patient_num, isnull(prc.mapped_id, '0'), fact.start_date, 0, 0, null, provider.provider_id, fact.encounter_num, prc.PCORI_BASECODE, prc.concept_id, null, fact.start_date
from i2b2fact fact
---------------------------------------------------------
-- For every procedure there must be a corresponding visit - added this back bc otherwise not constrained to patientlist
-----------------------------------------------------------
 inner join visit_occurrence enc on enc.person_id = fact.patient_num and enc.visit_occurrence_id = fact.encounter_Num 
/* inner join PCORNET_PROC pproc on pproc.c_basecode = fact.concept_cd
 inner join i2o_mapping omap on pproc.omop_sourcecode=omap.omop_sourcecode and omap.domain_id='Procedure'*/
 inner join concept_map_px_px prc on prc.c_basecode = fact.concept_cd and (prc.mapped_domain='Procedure' or prc.domain_id='Procedure')
 left outer join provider on fact.provider_id = provider.provider_source_value --provider support added MJ 6/16/18
-----------------------------------------------------------
-- look for observation facts that are procedures
-- Q: Which procedures are primary and which are secondary and which are unknown
---------- For the moment setting everything unknown
-----------------------------------------------------------

--where c_fullname like '\PCORI\PROCEDURE\%' 
--and omop_targettable='PROCEDURE_OCCURRENCE' -- this column was added 3/27/18

end
go

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- Procedure Seconday - by Jeff Klann, adapted from procedure
-- Insert procedures into observation, measurement, drug, dx tables
-- Device not supported - not required by AllOfUs at the moment
-- 5/19 - now uses concept map built in consolidated proc omopbuildmapping
----------------------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPprocedure_secondary') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPprocedure_secondary
go

create procedure OMOPprocedure_secondary as

begin


-- Update observation table ---
-- When mapped domain is not present, use unmapped code if it is CPT4, ICD-10, or HCPCS - these that do not have mappings are standard codes
insert into observation with(tablock) (person_id,observation_concept_id,observation_date, observation_datetime, observation_type_concept_id,provider_id,observation_source_value,observation_source_concept_id,visit_occurrence_id)
select  distinct fact.patient_num, case prc.mapped_domain when 'Observation' then prc.mapped_id else '0' END, fact.start_date, fact.start_date, 38000280 -- observation recorded from EHR
  , provider.provider_id, prc.PCORI_BASECODE, prc.concept_id, fact.encounter_num from i2b2fact fact
 -- not tied to encounters-- inner join visit_occurrence enc on enc.person_id = fact.patient_num and enc.visit_occurrence_id = fact.encounter_Num 
inner join concept_map_px_obs prc on prc.c_basecode = fact.concept_cd
left outer join provider on fact.provider_id = provider.provider_source_value 

-- Next, update measurement table ---
-- Millions of records (7k codes) get thrown into here - measurements like PTT that we have no value for
INSERT INTO [dbo].[measurement] with(tablock) ([person_id], [measurement_concept_id], [measurement_date], [measurement_datetime], [measurement_type_concept_id], [provider_id], [visit_occurrence_id], [measurement_source_value], [measurement_source_concept_id]) 
select  distinct fact.patient_num, case prc.mapped_domain when 'Measurement' then prc.mapped_id else '0' END, fact.start_date, fact.start_date, 45754907 -- derived value. Other option is 5001, test ordered through EHR 
  , 0, fact.encounter_num, prc.PCORI_BASECODE, prc.concept_id from i2b2fact fact
inner join visit_occurrence enc on enc.person_id = fact.patient_num and enc.visit_occurrence_id = fact.encounter_Num -- encounters needed to reduce output
inner join concept_map_px_meas prc on prc.c_basecode = fact.concept_cd

-- Next, update dx table ---
insert into condition_occurrence with (tablock) (person_id, visit_occurrence_id, condition_start_date, provider_id, condition_concept_id, condition_type_concept_id, condition_end_date, condition_source_value, condition_source_concept_id, condition_start_datetime) --pmndiagnosis (patid,encounterid, X enc_type, admit_date, providerid, dx, dx_type, dx_source, pdx)
select distinct factline.patient_num, factline.encounter_num encounterid, enc.visit_start_date, enc.provider_id, 
case diag.mapped_domain when 'Condition' then diag.mapped_id else '0' END,  5086, -- Condition tested for by diagnostic procedure
end_date, pcori_basecode, diag.concept_id, factline.start_date
from i2b2fact factline
inner join visit_occurrence enc on enc.person_id = factline.patient_num and enc.visit_occurrence_id = factline.encounter_Num
inner join concept_map_px_dx diag on diag.c_basecode = factline.concept_cd 

-- Next, update drug table
-- These are all (apparently) entries for vaccines
insert into drug_exposure with (tablock) (person_id  , drug_concept_id, drug_exposure_start_date , drug_exposure_start_datetime, drug_exposure_end_date , drug_exposure_end_datetime  , drug_type_concept_id 
  , visit_occurrence_id , drug_source_value , drug_source_concept_id , dose_unit_source_value )
select distinct m.patient_num, rx.mapped_id, m.start_date, cast(m.start_Date as datetime), isnull(m.end_date,m.start_date), cast(isnull(m.end_date,m.start_date) as datetime),
 '43542358' -- Physician administered drug - these are all vaccines...
, m.Encounter_num, rx.concept_code, rx.concept_id, units_cd
 from i2b2fact m inner join concept_map_px_rx rx on rx.c_basecode = m.concept_cd 
inner join visit_occurrence enc on enc.person_id = m.patient_num and enc.visit_occurrence_id = m.encounter_Num -- encounters needed to reduce output

end
go

----------------------------------------------------------------------------------------------------------------------------------------
------------------------- Vitals ------------------------------------------------ 
-- Written by Jeff Klann, PhD, and Matthew Joss
----------------------------------------------------------------------------------------------------------------------------------------


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPvital') AND type in (N'P', N'PC'))
DROP PROCEDURE OMOPvital
GO

create procedure OMOPvital as
begin


INSERT INTO dbo.[measurement]
     ([person_id]--[PATID]
      ,[visit_occurrence_id]--[ENCOUNTERID]
      ,[measurement_source_value]--[LAB_LOINC]
      ,[measurement_date]--[RESULT_DATE]
      ,[measurement_datetime]--[RESULT_TIME]
      ,[value_as_concept_id]--[RESULT_QUAL]
      ,[value_as_number]--[RESULT_NUM]
      ,[unit_source_value]--[RESULT_UNIT]
      ,[value_source_value]--[RAW_RESULT]
      ,[unit_concept_id]
      ,[measurement_concept_id]
      ,[measurement_source_concept_id]
      ,[measurement_type_concept_id]
      ,[provider_id]
      ,[operator_concept_id])

Select distinct m.patient_num, m.encounter_num, substring(vital.i_loinc, 1, 50), 
convert(date, m.start_date) meaure_date,   
M.start_date measure_time,
'0', m.nval_num, substring(m.units_cd, 1, 50), substring(concat (tval_char, nval_num), 1, 50), 
isnull(u.concept_id, '0'), isnull(vital.omop_sourcecode, '0'), isnull(vital.omop_sourcecode, '0'),
'44818701', provider.provider_id, '0'
from i2b2fact m
inner join visit_occurrence enc on enc.person_id = m.patient_num and enc.visit_occurrence_id = m.encounter_Num
inner join pcornet_vital vital on vital.c_basecode  = m.concept_cd
left outer join i2o_unitsmap u on u.units_name=m.units_cd
left outer join provider on m.provider_id = provider.provider_source_value --provider support MJ 6/17/18
where vital.c_fullname like '\PCORI\VITAL\%'
and vital.i_loinc is not null 


end
go

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- LAB_RESULT_CM - Written by Jeff Klann, PhD and Arturo Torres, and Matthew Joss
-- DEPRECATED! (04/9/20)
----------------------------------------------------------------------------------------------------------------------------------------
/*
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPlabResultCM') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPlabResultCM;
GO
create procedure OMOPlabResultCM as
begin

-- Optimized to use temp tables; also, removed "distinct" - much faster and seems unnecessary - 12/9/15
select patient_num, encounter_num, m.provider_id, concept_cd, start_date, lsource.pcori_basecode  PRIORITY 
into #priority from i2b2fact M
--inner join visit_occurrence enc on enc.person_id = m.patient_num and enc.visit_occurrence_id = m.encounter_Num
inner join pcornet_lab lsource on m.modifier_cd =lsource.c_basecode
where c_fullname LIKE '\PCORI_MOD\PRIORITY\%'
 
select  patient_num, encounter_num, m.provider_id, concept_cd, start_date, lsource.pcori_basecode  RESULT_LOC
into #location from i2b2fact M
--inner join visit_occurrence enc on enc.person_id = m.patient_num and enc.visit_occurrence_id = m.encounter_Num
inner join pcornet_lab lsource on m.modifier_cd =lsource.c_basecode
where c_fullname LIKE '\PCORI_MOD\RESULT_LOC\%'

-- Optimization - build temp ont table - 8/13/18 jgk - new version that doesn't have duplicate entries
select * into #pcornet_lab2 from 
(select *, row_number() over (partition by c_basecode order by (case when parent_basecode like 'LAB_NAME:%' then 0 when parent_basecode like 'LOINC:%' then 1 else 2 end), pcori_specimen_source desc) k -- Griffin Weber's code to pick one row per basecode with preference for one with a lab_name in parent_basecode and with specimen source
from (select lab.pcori_basecode,lab.c_basecode,lab.pcori_specimen_source,ont_parent.c_basecode parent_basecode, NORM_RANGE_LOW, NORM_MODIFIER_LOW, NORM_RANGE_HIGH,NORM_MODIFIER_HIGH
from pcornet_lab lab -- the actual leaf entry (local basecode)
inner join pcornet_lab ont_loinc on lab.pcori_basecode=ont_loinc.pcori_basecode and ont_loinc.c_basecode like 'LOINC:%' -- the entry with a LOINC code (could be the same or the parent row, depending on the mapping)
left outer join (select c_fullname, c_basecode, norm.* from pcornet_lab ont_parent inner join pmn_labnormal norm on ont_parent.c_basecode=norm.LAB_NAME where c_fullname like '\PCORI\LAB_RESULT_CM\LAB_NAME\%' and c_basecode like 'LAB_NAME:%') ont_parent on ont_loinc.c_path=ont_parent.c_fullname -- labnormal table plus c_fullname corresponding to it
where lab.c_fullname like '\PCORI\LAB_RESULT_CM\%') x) x where k=1


INSERT INTO dbo.[measurement]
     ([person_id]--[PATID]
      ,[visit_occurrence_id]--[ENCOUNTERID]
      --,[]--[LAB_NAME]
      --,[]--[SPECIMEN_SOURCE]
      ,[measurement_source_value]--[LAB_LOINC]
      --,[]--[PRIORITY]
      --,[]--[RESULT_LOC]
      --,[]--[LAB_PX]
      --,[]--[LAB_PX_TYPE]
      ,[measurement_date]--[RESULT_DATE]
      ,[measurement_datetime]--[RESULT_TIME]
      ,[value_as_concept_id]--[RESULT_QUAL]
      ,[value_as_number]--[RESULT_NUM]
      --,[]--[RESULT_MODIFIER]
      ,[unit_source_value]--[RESULT_UNIT]
      ,[range_low]--[NORM_RANGE_LOW]
      --,[]--[NORM_MODIFIER_LOW]
      ,[range_high]--[NORM_RANGE_HIGH]
      --,[]--[NORM_MODIFIER_HIGH]
      --,[]--[ABN_IND],
      ,[value_source_value]--[RAW_RESULT]
      ,[unit_concept_id]
      ,[measurement_concept_id]
      ,[measurement_source_concept_id]
      ,[measurement_type_concept_id]
      ,[provider_id]
      ,[operator_concept_id])

--select max(len(raw_result)),max(len(specimen_time)),max(len(result_time)),max(len(result_unit))
--max(len(lab_name)),max(len(lab_loinc)),max(len(priority)), max(len(result_loc)), max(len(lab_px)),max(len(result_qual)),max(len(result_num)) 

SELECT DISTINCT  M.patient_num patid,
M.encounter_num encounterid,
--CASE WHEN ont_parent.C_BASECODE LIKE 'LAB_NAME%' then SUBSTRING (ont_parent.c_basecode,10, 10) ELSE 'NI' END LAB_NAME,
--CASE WHEN lab.pcori_specimen_source like '%or SR_PLS' THEN 'SR_PLS' WHEN lab.pcori_specimen_source is null then 'NI' ELSE lab.pcori_specimen_source END specimen_source, -- (Better way would be to fix the column in the ontology but this will work)
isnull(lab.pcori_basecode, 'NI') LAB_LOINC,
--isnull(p.PRIORITY,'NI') PRIORITY,
--isnull(l.RESULT_LOC,'NI') RESULT_LOC,
--isnull(lab.pcori_basecode, 'NI') LAB_PX,
--'LC'  LAB_PX_TYPE,
Cast(m.start_date as DATE) RESULT_DATE,   
cast(m.start_Date as datetime) RESULT_TIME,
isnull(CASE WHEN m.ValType_Cd='T' THEN CASE WHEN m.Tval_Char IS NOT NULL THEN 'OT' ELSE '0' END END, '0') RESULT_QUAL, -- TODO: Should be a standardized value
CASE WHEN m.ValType_Cd='N' THEN m.NVAL_NUM ELSE null END RESULT_NUM,
--CASE WHEN m.ValType_Cd='N' THEN (CASE isnull(nullif(m.TVal_Char,''),'NI') WHEN 'E' THEN 'EQ' WHEN 'NE' THEN 'OT' WHEN 'L' THEN 'LT' WHEN 'LE' THEN 'LE' WHEN 'G' THEN 'GT' WHEN 'GE' THEN 'GE' ELSE 'NI' END)  ELSE 'TX' END RESULT_MODIFIER,
isnull(m.Units_CD,'NI') RESULT_UNIT, -- TODO: Should be standardized units
nullif(lab.NORM_RANGE_LOW,'') NORM_RANGE_LOW,
--isnull(lab.NORM_MODIFIER_LOW, 'UN') NORM_MODIFIER_LOW,
nullif(lab.NORM_RANGE_HIGH,'') NORM_RANGE_HIGH,
--isnull(lab.NORM_MODIFIER_HIGH, 'UN') NORM_MODIFIER_HIGH,
--CASE isnull(nullif(m.VALUEFLAG_CD,''),'NI') WHEN 'H' THEN 'AH' WHEN 'L' THEN 'AL' WHEN 'A' THEN 'AB' ELSE 'NI' END ABN_IND,
CASE WHEN m.ValType_Cd='T' THEN substring(m.TVal_Char,1,50) ELSE substring(cast(m.NVal_Num as varchar),1,50) END RAW_RESULT,
isnull(u.concept_id, '0'), isnull(omap.concept_id, '0'), isnull(ont_loinc.omop_sourcecode, '0'), '44818702', '0', '0'


FROM i2b2fact M  
inner join visit_occurrence enc on enc.person_id = m.patient_num and enc.visit_occurrence_id = m.encounter_Num -- Constraint to selected encounters
--inner join pcornet_lab lab on lab.c_basecode  = M.concept_cd and lab.c_fullname like '\PCORI\LAB_RESULT_CM\%'
inner join #pcornet_lab2 lab on lab.c_basecode  = M.concept_cd
inner join pcornet_lab ont_loinc on lab.pcori_basecode=ont_loinc.pcori_basecode and ont_loinc.c_basecode like 'LOINC:%' --NOTE: You will need to change 'LOINC:' to our local term.
inner JOIN pcornet_lab ont_parent on ont_loinc.c_path=ont_parent.c_fullname
inner join i2o_mapping omap on ont_loinc.omop_sourcecode=omap.omop_sourcecode and omap.domain_id='Measurement'
left outer join pmn_labnormal norm on ont_parent.c_basecode=norm.LAB_NAME
left outer join i2o_unitsmap u on u.units_name=m.units_cd


LEFT OUTER JOIN
#priority p
ON  M.patient_num=p.patient_num
and M.encounter_num=p.encounter_num
and M.provider_id=p.provider_id
and M.concept_cd=p.concept_Cd
and M.start_date=p.start_Date
 
LEFT OUTER JOIN
#location l
ON  M.patient_num=l.patient_num
and M.encounter_num=l.encounter_num
and M.provider_id=l.provider_id
and M.concept_cd=l.concept_Cd
and M.start_date=l.start_Date
 
WHERE m.ValType_Cd in ('N') -- excluding non-numerical measurementss
--sand ont_parent.C_BASECODE LIKE 'LAB_NAME%' -- Exclude non-pcori labs
and m.MODIFIER_CD='@'

END
GO  
*/
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- Prescribing - by Aaron Abend and Jeff Klann PhD and Matthew Joss with optimizations by Griffin Weber, MD, PhD
-- Note that now a lot of deprecated codes have been removed entirely from the concept dictionary (pre-2007) and they get a 0 now
----------------------------------------------------------------------------------------------------------------------------------------
-- You must have run the meds_schemachange proc to create the PCORI_NDC and PCORI_CUI columns

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPdrug_exposure') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPdrug_exposure;
GO
create procedure OMOPdrug_exposure as
begin

-- Griffin's optimization: use temp tables rather than left joining directly - 12/9/15
    select pcori_basecode,c_fullname,instance_num,start_date,basis.provider_id,concept_cd,encounter_num,modifier_cd
		into #basis
		from i2b2fact basis
			--inner join visit_occurrence enc on enc.person_id = basis.patient_num and enc.visit_occurrence_id = basis.encounter_Num
		 join pcornet_med basiscode 
			on basis.modifier_cd = basiscode.c_basecode
			and basiscode.c_fullname like '\PCORI_MOD\RX_BASIS\%'

    select pcori_basecode,instance_num,start_date,freq.provider_id,concept_cd,encounter_num,modifier_cd 
		into #freq
		from i2b2fact freq
			--inner join visit_occurrence enc on enc.person_id = freq.patient_num and enc.visit_occurrence_id = freq.encounter_Num
		 join pcornet_med freqcode 
			on freq.modifier_cd = freqcode.c_basecode
			and freqcode.c_fullname like '\PCORI_MOD\RX_FREQUENCY\%'

    select nval_num,instance_num,start_date,quantity.provider_id,concept_cd,encounter_num,modifier_cd
		into #quantity
		from i2b2fact quantity
			--inner join visit_occurrence enc on enc.person_id = quantity.patient_num and enc.visit_occurrence_id = quantity.encounter_Num
		 join pcornet_med quantitycode 
			on quantity.modifier_cd = quantitycode.c_basecode
			and quantitycode.c_fullname like '\PCORI_MOD\RX_QUANTITY\'

	select nval_num,instance_num,start_date,refills.provider_id,concept_cd,encounter_num,modifier_cd 
		into #refills
		from i2b2fact refills
			--inner join visit_occurrence enc on enc.person_id = refills.patient_num and enc.visit_occurrence_id = refills.encounter_Num
		 join pcornet_med refillscode 
			on refills.modifier_cd = refillscode.c_basecode
			and refillscode.c_fullname like '\PCORI_MOD\RX_REFILLS\'

    select nval_num,instance_num,start_date,supply.provider_id,concept_cd,encounter_num,modifier_cd 
		into #supply
		from i2b2fact supply
			--inner join visit_occurrence enc on enc.person_id = supply.patient_num and enc.visit_occurrence_id = supply.encounter_Num
		 join pcornet_med supplycode 
			on supply.modifier_cd = supplycode.c_basecode
			and supplycode.c_fullname like '\PCORI_MOD\RX_DAYS_SUPPLY\'

-- insert data with outer joins to ensure all records are included even if some data elements are missing
insert into drug_exposure(
-- drug_exposure_id -------- --------> set to identity column (not shown here)----------------------> Done
person_id   -----------------------> patient_num unique identifier for the patient in i2b2--------> Done
, drug_concept_id -------------> i2o_mapping concept_id---------------------------------------> Done
, drug_exposure_start_date --------> i2b2fact visit_start_date ----------------------------------> Done
, drug_exposure_start_datetime -----> i2b2fact visit_start_date ---------------------------------> Done
, drug_exposure_end_date  -----------> i2b2fact end_end ------------------------------------> Done
, drug_exposure_end_datetime  ----------->  i2b2fact end_end --------------------------------> Done
, drug_type_concept_id -------> jgk 32918 added prescribed & dispensed... there are more variants ----> NOT DONE
, stop_reason ------------------> Reason the drug was stoppped varchar(20) ... Do we have this?---> NO
, refills   --------------------------> from ontology \PCORI_MOD\RX_REFILLS\ ----------------> Done
, quantity	--------------------------> from ontology \PCORI_MOD\RX_QUANTITY ----------------> Done
, days_supply	--------------------------> from ontology \PCORI_MOD\RX_DAYS_SUPPLY ----------> Done
, sig----------------------------> The directions "signetur" on the Drug prescription as recorded in the original prescription or dispensing record -- Passing the frequency---> Done
, route_concept_id ---------------> routes of administrating medication oral, intravenous, etc... Need a mapping ---------------------------> NOT DONE
-- NOT IN 5.2 -- , effective_drug_dose ------------> Numerical Value of Drug dose for this Drug_Exposure... Do we have this? --> No 
-- NOT IN 5.2 -- , dose_unit_concept_id -----------> UCUM Codes concpet c where c.vocabulary_id = 'UCUM and c.standard_concept='S' and c.domain_id='Unit'----> NOT DONE
, lot_number ----------------------> varchar... do we have this value?------------------------> No
, provider_id ---------------------> (Set to 0 for Data Sprint 2)-----------------------------> Done
, visit_occurrence_id -----------------> observation_fact.encounter_num i2b2 id for the encounter (visit)-> Done
, drug_source_value ----------> PCORI base code from ontology preffered vocabularies RxNorm, NDC, CVX, or the name, do we have this? ---> Use the base_code which NDC or RXNorm ---> Done
, drug_source_concept_id ----> OMOP source code from ontology  do we have this mapping?-------> NOT DONE
, route_source_value ----------> Varchar ....Do we have this?-------yes-----------------------> NOT DONE
, dose_unit_source_value ----------> Varchar .....Do we have this?--yes-----------------------> NOT DONE
)
select distinct m.patient_num, isnull(isnull(omap.concept_id,omap.source_id),0) , m.start_date, cast(m.start_Date as datetime), isnull(m.end_date,m.start_date), cast(isnull(m.end_date,m.start_date) as datetime),
 case 
   when basis.c_fullname is null or basis.c_fullname like '\PCORI_MOD\RX_BASIS\PR\%' then '38000177'
   when basis.c_fullname like '\PCORI_MOD\RX_BASIS\DI\%' then '38000175'
 end
, null
, refills.nval_num refills, quantity.nval_num quantity, supply.nval_num supply, substring(freq.pcori_basecode,charindex(':',freq.pcori_basecode)+1,2) frequency
, null, null
, provider.provider_id, m.Encounter_num, mo.C_BASECODE, null, null, units_cd
 from i2b2fact m
 inner join pcornet_med mo on m.concept_cd = mo.c_basecode 
 inner join visit_occurrence enc on enc.person_id = m.patient_num and enc.visit_occurrence_id = m.encounter_Num 
-- Note the only reason we need i2o_mapping is to figure which are standard codes, sourcecode already comes from RxCui
 left join i2o_mapping omap on mo.i_stdcode=omap.source_code and omap.domain_id='Drug'

-- TODO: This join adds several minutes to the load - must be debugged

    left join #basis basis
    on m.encounter_num = basis.encounter_num
    and m.concept_cd = basis.concept_Cd
    and m.start_date = basis.start_date
    and m.provider_id = basis.provider_id
    and m.instance_num = basis.instance_num

    left join #freq freq
    on m.encounter_num = freq.encounter_num
    and m.concept_cd = freq.concept_Cd
    and m.start_date = freq.start_date
    and m.provider_id = freq.provider_id
    and m.instance_num = freq.instance_num

    left join #quantity quantity 
    on m.encounter_num = quantity.encounter_num
    and m.concept_cd = quantity.concept_Cd
    and m.start_date = quantity.start_date
    and m.provider_id = quantity.provider_id
    and m.instance_num = quantity.instance_num

    left join #refills refills
    on m.encounter_num = refills.encounter_num
    and m.concept_cd = refills.concept_Cd
    and m.start_date = refills.start_date
    and m.provider_id = refills.provider_id
    and m.instance_num = refills.instance_num

    left join #supply supply
    on m.encounter_num = supply.encounter_num
    and m.concept_cd = supply.concept_Cd
    and m.start_date = supply.start_date
    and m.provider_id = supply.provider_id
    and m.instance_num = supply.instance_num
    
    left outer join provider on m.provider_id = provider.provider_source_value --provider support MJ 6/17/18

     where mo.i_stdcode is not null

end
GO

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- Era tables - contributed by Dr. George Hripcsak and the Columbia University Medical Center OMOP team
-- Adds derived information into drug_era and condition_era tables, must be run after drug_exposure and condition_occurrence are populate
-- NEW 01-15-18!
----------------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPera') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPera;
GO
create procedure OMOPera as
begin

with cteConditionTarget (CONDITION_OCCURRENCE_ID, PERSON_ID, CONDITION_CONCEPT_ID, CONDITION_TYPE_CONCEPT_ID, CONDITION_START_DATE, CONDITION_END_DATE) as
(
	select co.CONDITION_OCCURRENCE_ID, co.PERSON_ID, co.CONDITION_CONCEPT_ID, co.CONDITION_TYPE_CONCEPT_ID, co.CONDITION_START_DATE,
		COALESCE(co.CONDITION_END_DATE, DATEADD(day,1,CONDITION_START_DATE)) as CONDITION_END_DATE
	FROM dbo.CONDITION_OCCURRENCE co (nolock)
),
cteEndDates (PERSON_ID, CONDITION_CONCEPT_ID, END_DATE) as -- the magic
(
	select PERSON_ID, CONDITION_CONCEPT_ID, DATEADD(day,-30,EVENT_DATE) as END_DATE -- unpad the end date
	FROM
	(
		select PERSON_ID, CONDITION_CONCEPT_ID, EVENT_DATE, EVENT_TYPE,
		MAX(START_ORDINAL) OVER (PARTITION BY PERSON_ID, CONDITION_CONCEPT_ID ORDER BY EVENT_DATE, EVENT_TYPE ROWS UNBOUNDED PRECEDING) as START_ORDINAL, -- this pulls the current START down from the prior rows so that the NULLs from the END DATES will contain a value we can compare with
		ROW_NUMBER() OVER (PARTITION BY PERSON_ID, CONDITION_CONCEPT_ID ORDER BY EVENT_DATE, EVENT_TYPE) AS OVERALL_ORD -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
		from
		(
			-- select the start dates, assigning a row number to each
			Select PERSON_ID, CONDITION_CONCEPT_ID, CONDITION_START_DATE AS EVENT_DATE, -1 as EVENT_TYPE, ROW_NUMBER() OVER (PARTITION BY PERSON_ID, CONDITION_CONCEPT_ID ORDER BY CONDITION_START_DATE) as START_ORDINAL
			from cteConditionTarget

			UNION ALL

			-- pad the end dates by 30 to allow a grace period for overlapping ranges.
			select PERSON_ID, CONDITION_CONCEPT_ID, DATEADD(day,30,CONDITION_END_DATE), 1 as EVENT_TYPE, NULL
			FROM cteConditionTarget
		) RAWDATA
	) E
	WHERE (2 * E.START_ORDINAL) - E.OVERALL_ORD = 0
),
cteConditionEnds (PERSON_ID, CONDITION_CONCEPT_ID, CONDITION_TYPE_CONCEPT_ID, CONDITION_START_DATE, ERA_END_DATE) as
(
select
	c.PERSON_ID,
	c.CONDITION_CONCEPT_ID,
	c.CONDITION_TYPE_CONCEPT_ID,
	c.CONDITION_START_DATE,
	MIN(e.END_DATE) as ERA_END_DATE
FROM cteConditionTarget c
JOIN cteEndDates e  on c.PERSON_ID = e.PERSON_ID and c.CONDITION_CONCEPT_ID = e.CONDITION_CONCEPT_ID and e.END_DATE >= c.CONDITION_START_DATE
GROUP BY
	c.PERSON_ID,
	c.CONDITION_CONCEPT_ID,
	c.CONDITION_TYPE_CONCEPT_ID,
	c.CONDITION_START_DATE
)
-- Add INSERT statement here
INSERT INTO dbo.condition_era(
  condition_era_id,
  person_id,
  condition_concept_id,
  condition_era_start_date,
  condition_era_end_date,
  condition_occurrence_count)
select row_number() over (order by condition_concept_id), person_id, CONDITION_CONCEPT_ID, min(CONDITION_START_DATE) as CONDITION_ERA_START_DATE, ERA_END_DATE as CONDITION_ERA_END_DATE, COUNT(*) as CONDITION_OCCURRENCE_COUNT
from cteConditionEnds 
GROUP BY person_id, CONDITION_CONCEPT_ID, CONDITION_TYPE_CONCEPT_ID, ERA_END_DATE
order by person_id, CONDITION_CONCEPT_ID
;

with cteDrugTarget (DRUG_EXPOSURE_ID, PERSON_ID, DRUG_CONCEPT_ID, DRUG_TYPE_CONCEPT_ID, DRUG_EXPOSURE_START_DATE, DRUG_EXPOSURE_END_DATE, INGREDIENT_CONCEPT_ID) as
(
-- Normalize DRUG_EXPOSURE_END_DATE to either the existing drug exposure end date, or add days supply, or add 1 day to the start date
	select d.DRUG_EXPOSURE_ID, d. PERSON_ID, c.CONCEPT_ID, d.DRUG_TYPE_CONCEPT_ID, DRUG_EXPOSURE_START_DATE,
		COALESCE(DRUG_EXPOSURE_END_DATE, DATEADD(day,DAYS_SUPPLY,DRUG_EXPOSURE_START_DATE), DATEADD(day,1,DRUG_EXPOSURE_START_DATE)) as DRUG_EXPOSURE_END_DATE,
		c.CONCEPT_ID as INGREDIENT_CONCEPT_ID
	FROM dbo.DRUG_EXPOSURE d (nolock)
		join dbo.CONCEPT_ANCESTOR ca (nolock) on ca.DESCENDANT_CONCEPT_ID = d.DRUG_CONCEPT_ID
		join dbo.CONCEPT c (nolock) on ca.ANCESTOR_CONCEPT_ID = c.CONCEPT_ID
		where c.VOCABULARY_ID = 'RxNorm'
		and c.CONCEPT_CLASS_ID = 'Ingredient'
),
cteEndDates (PERSON_ID, INGREDIENT_CONCEPT_ID, END_DATE) as -- the magic
(
	select PERSON_ID, INGREDIENT_CONCEPT_ID, DATEADD(day,-30,EVENT_DATE) as END_DATE -- unpad the end date
	FROM
	(
		select PERSON_ID, INGREDIENT_CONCEPT_ID, EVENT_DATE, EVENT_TYPE,
		MAX(START_ORDINAL) OVER (PARTITION BY PERSON_ID, INGREDIENT_CONCEPT_ID ORDER BY EVENT_DATE, EVENT_TYPE ROWS UNBOUNDED PRECEDING) as START_ORDINAL, -- this pulls the current START down from the prior rows so that the NULLs from the END DATES will contain a value we can compare with
		ROW_NUMBER() OVER (PARTITION BY PERSON_ID, INGREDIENT_CONCEPT_ID ORDER BY EVENT_DATE, EVENT_TYPE) AS OVERALL_ORD -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
		from
		(
			-- select the start dates, assigning a row number to each
			Select PERSON_ID, INGREDIENT_CONCEPT_ID, DRUG_EXPOSURE_START_DATE AS EVENT_DATE, -1 as EVENT_TYPE, ROW_NUMBER() OVER (PARTITION BY PERSON_ID, DRUG_CONCEPT_ID ORDER BY DRUG_EXPOSURE_START_DATE) as START_ORDINAL
			from cteDrugTarget

			UNION ALL

			-- pad the end dates by 30 to allow a grace period for overlapping ranges.
			select PERSON_ID, INGREDIENT_CONCEPT_ID, DATEADD(day,30,DRUG_EXPOSURE_END_DATE), 1 as EVENT_TYPE, NULL
			FROM cteDrugTarget
		) RAWDATA
	) E
	WHERE (2 * E.START_ORDINAL) - E.OVERALL_ORD = 0
),
cteDrugExposureEnds (PERSON_ID, DRUG_CONCEPT_ID, DRUG_TYPE_CONCEPT_ID, DRUG_EXPOSURE_START_DATE, DRUG_ERA_END_DATE) as
(
select
	d.PERSON_ID,
	d.INGREDIENT_CONCEPT_ID,
	d.DRUG_TYPE_CONCEPT_ID,
	d.DRUG_EXPOSURE_START_DATE,
	MIN(e.END_DATE) as ERA_END_DATE
FROM cteDrugTarget d
JOIN cteEndDates e  on d.PERSON_ID = e.PERSON_ID and d.INGREDIENT_CONCEPT_ID = e.INGREDIENT_CONCEPT_ID and e.END_DATE >= d.DRUG_EXPOSURE_START_DATE
GROUP BY d.DRUG_EXPOSURE_ID,
	d.PERSON_ID,
	d.INGREDIENT_CONCEPT_ID,
	d.DRUG_TYPE_CONCEPT_ID,
	d.DRUG_EXPOSURE_START_DATE
)
-- Add INSERT statement here
INSERT INTO dbo.drug_era (
  drug_era_id,
  person_id,
  drug_concept_id,
  drug_era_start_date,
  drug_era_end_date,
  drug_exposure_count)
select row_number() over (order by drug_concept_id), person_id, drug_concept_id, min(DRUG_EXPOSURE_START_DATE) as DRUG_ERA_START_DATE, DRUG_ERA_END_DATE, COUNT(*) as DRUG_EXPOSURE_COUNT
from cteDrugExposureEnds
GROUP BY person_id, drug_concept_id, drug_type_concept_id, DRUG_ERA_END_DATE
order by person_id, drug_concept_id
;

end
GO



-------------------------------------------------------------------------------------------------------------------------
--DEATH
-------------------------------------------------------------------------------------------------------------------------



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPDeath') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPDeath
go

create procedure OMOPDeath as

begin
insert into death( person_id,	death_date,  death_type_concept_id)
select  distinct pat.patient_num, pat.death_date, '38003569'
from i2b2patient pat
where (pat.death_date is not null or vital_status_cd like 'Z%') and pat.patient_num in (select person_id from person)

end
go



----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- Provider Transform -- Written by Matthew Joss, and Jeff Klann Ph. D.
--NEW 06-12-18!
-- Bugfix 0619: Aggressively removes duplicate providers which caused duplicate visits
----------------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPProvider') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPProvider
go

create procedure OMOPProvider as
begin

insert into provider(provider_id, provider_name, provider_source_value)
select  distinct ROW_NUMBER() OVER (ORDER BY provider_id) New_ID, prov.name_char, prov.provider_id 
from (select provider_id, min(NAME_CHAR) name_char from i2b2provider group by provider_id) prov

end
go

----------------------------------------------------------------------------------------------------------------------------------------
-- i2o v2020 - revising to no longer require any particular ontology - to support rapidly updating codesets with more agility
-- Of course, OMOP and PCORI ontologies can be adapted to support this new method, for query interoperability. Scripts will be added to the repository.
-- By Jeff Klann, PhD 04/2020
----------------------------------------------------------------------------------------------------------------------------------------
-- This procedure extracts modifiers into temp tables based on the configuration in i2o_config_modifier
-- Now creates real tables called temp_mod_* - the calling procedure should drop them when done. (Global temp tables are across all dbs, and local temp tables only follow the inner scope, so were not feasible.)
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[build_modifiers]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[build_modifiers]
GO

create procedure [build_modifiers] (@domain varchar(20), @force_update int= 0) as
--------------------------------------------------------------------------------
--Description: For each entry in i2o_config_modifier table 
--               Generates a temp table for joining modifier fields to a query
--               Each temp table is indexed on person_id, encounter_num, provider_id, concept_cd, start_date, instance_num
-- Input parameters: @domain -- domain the temp table modifier is used for (must match value in i2o_config_modifier.c_domain
--                   @force_update -- Forces rebuilding of temp tables
-- Notes: Temp tables persist only during a connection
--        This procedure defaults to NOT overwriting a pre-existing temp table
--        If you need the temp tables rebuilt during a single connection set parameter @force_update = 1
---------------------------------------------------------------------------------
--Variables
declare @sqltext nvarchar (2000)
declare @tablename varchar(50)
declare @path varchar(400)
declare @target_column varchar(50)
declare @temp_tablename varchar(100)
declare @temp_tableidx varchar(100)

--Cursors
declare getconfigsql cursor local for
select c_tablename, c_path, c_target_column from i2o_config_modifier where c_domain=@domain

begin
	--Loop Cursor
    open getconfigsql;
    fetch next from getconfigsql into @tablename,@path,@target_column;
    while @@fetch_status=0
    begin

		--Set table temp name and idx name
		set @temp_tablename = 'temp_mod_' + @target_column;
		set @temp_tableidx = @temp_tablename + '_cidx';

		-- If force_update then drop existing temp table if it exists
		IF @force_update = 1 
			BEGIN
					IF OBJECT_ID(@temp_tablename) IS NOT NULL
						BEGIN TRY
							set @sqltext = 'DROP TABLE ' + @temp_tablename;
							exec sp_executesql @sqltext;
						END TRY
						BEGIN CATCH
							RAISERROR('ERROR: Failed to execute %s', 0, 1, @sqltext) with NOWAIT;
						END CATCH;
			END;

		-- If the temp table does not already exist create it and index it
		IF OBJECT_ID(@temp_tablename) IS NULL
			BEGIN TRY
				set @sqltext = 'select patient_num, encounter_num, m.provider_id, concept_cd, start_date, instance_num, o.i_stdcode  ' +@target_column+' ' +
					'into temp_mod_'+@target_column+' from i2b2fact M ' +
					' inner join '+@tablename+' o on m.modifier_cd =o.c_basecode ' +
					' where c_fullname LIKE '''+@path+ '%'''
				exec sp_executesql @sqltext
				set @sqltext = 'create clustered index ' + @temp_tableidx + ' on ' + @temp_tablename + '(patient_num, encounter_num, provider_id, concept_cd, start_date, instance_num)'
				exec sp_executesql @sqltext
				PRINT 'CREATED TEMPORARY TABLE ' + @TEMP_TABLENAME;
			END TRY
			BEGIN CATCH
				raiserror('Error: Failed to execute: %s',0, 1, @sqltext) with NOWAIT;
			END CATCH;

        fetch next from getconfigsql into @tablename,@path,@target_column;
    end
	--Close Loop
    close getconfigsql;
    deallocate getconfigsql;
end
GO

--exec build_modifiers lab
--select patient_num, encounter_num, m.provider_id, concept_cd, start_date, o.i_stdcode  priority into #priority from i2b2fact M  inner join pcornet_lab o on m.modifier_cd =o.c_basecode  where c_fullname LIKE '\PCORI_MOD\PRIORITY\%'

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPmeasurementLab') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPmeasurementLab;
GO
create procedure [OMOPmeasurementLab] as
--------------------------------------------------------------------
-- DESCRIPTION: Inserts observation_facts that have loinc codes into measurment table
-- Parameters: None
-- Notes: None
--------------------------------------------------------------------
DECLARE @START_TIME DATETIME;
DECLARE @END_TIME DATETIME;

begin

SET @START_TIME = GETDATE();
-- Build Modifiers
exec build_modifiers lab

INSERT INTO dbo.[measurement]
     ([person_id]
      ,[visit_occurrence_id]
      ,[measurement_source_value]
      ,[measurement_date]
      ,[measurement_datetime]
      ,[value_as_concept_id]
      ,[value_as_number]
      ,[unit_source_value]
      ,[range_low]
      ,[range_high]
      ,[value_source_value]
      ,[unit_concept_id]
      ,[measurement_concept_id]
      ,[measurement_source_concept_id]
      ,[measurement_type_concept_id]
      ,[provider_id]
      ,[operator_concept_id])

SELECT DISTINCT  M.patient_num person_id,
M.encounter_num visit_occurrence_id,
isnull(lab.i_stdcode, '') measurement_source_value,
Cast(m.start_date as DATE) measurement_date,   
cast(m.start_Date as datetime) measurement_datetime,
-- NOTE: Are these concept_ids the ones analysts want?
CASE isnull(m.VALUEFLAG_CD,'0') WHEN 'H' THEN '45876384' WHEN 'L' THEN '45881666' WHEN 'A' THEN '45878745' WHEN 'N' THEN '45884153' ELSE '0' END value_as_concept_id,
CASE WHEN m.ValType_Cd='N' THEN m.NVAL_NUM ELSE null END value_as_number,
isnull(m.Units_CD,'') unit_source_value, 

-- TODO: Need to get normal ranges working again
--nullif(lab.NORM_RANGE_LOW,'') range_low,
--nullif(lab.NORM_RANGE_HIGH,'') range_high,
null range_low, null range_high,

CASE WHEN m.ValType_Cd='T' THEN substring(m.TVal_Char,1,50) ELSE substring(cast(m.NVal_Num as varchar),1,50) END value_source_value,
isnull(u.concept_id, '0') unit_concept_id, 
isnull(omap.concept_id, '0') measurement_concept_id, 
isnull(omap.source_id, '0') measurement_source_concept_id, 
'44818702', provider.provider_id, '0'

FROM i2b2fact M  
inner join visit_occurrence enc on enc.person_id = m.patient_num and enc.visit_occurrence_id = m.encounter_Num -- Constraint to selected encounters
inner join (select distinct i_stdcode,c_basecode from i2o_ontology_lab where i_stddomain='LOINC') lab on lab.c_basecode  = M.concept_cd
inner join i2o_mapping omap on lab.i_stdcode=omap.source_code and omap.domain_id='Measurement'
--left outer join pmn_labnormal norm on ont_parent.c_basecode=norm.LAB_NAME
left outer join i2o_unitsmap u on u.units_name=m.units_cd
left outer join provider on m.provider_id = provider.provider_source_value --provider support


LEFT OUTER JOIN
temp_mod_priority p
ON  M.patient_num=p.patient_num
and M.encounter_num=p.encounter_num
and M.provider_id=p.provider_id
and M.concept_cd=p.concept_Cd
and M.start_date=p.start_Date
and M.instance_num = p.instance_num
 
LEFT OUTER JOIN
temp_mod_result_loc l
ON  M.patient_num=l.patient_num
and M.encounter_num=l.encounter_num
and M.provider_id=l.provider_id
and M.concept_cd=l.concept_Cd
and M.start_date=l.start_Date
and M.instance_num = l.instance_num
 
WHERE  m.MODIFIER_CD='@';

SET @END_TIME = GETDATE();
PRINT 'OMOPMEASUREMENT_LAB EXECUTION TIME: ' +  CAST(datediff(s, @start_time, @end_time) as nvarchar(50));


END
GO  

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- clear Program - includes all tables
----------------------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPclear') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPclear
go 

/* Useful code snippet - disable all FK constraints. Still does not allow truncate!
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"
exec sp_MSforeachtable @command1="print '?'", @command2="ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"
*/

create procedure OMOPclear
as 
begin

TRUNCATE TABLE death
TRUNCATE TABLE observation
TRUNCATE TABLE drug_era
TRUNCATE TABLE condition_era
TRUNCATE TABLE observation_period
TRUNCATE TABLE condition_occurrence
TRUNCATE TABLE drug_exposure
TRUNCATE TABLE measurement
TRUNCATE TABLE procedure_occurrence
DELETE FROM visit_occurrence -- Truncate cannot work with FPK constraints
DELETE FROM person -- Truncate cannot work with FPK constraints
DELETE FROM provider -- Truncate cannot work with FPK constraints
DELETE FROM location -- Truncate cannot work with FPK constraints
DELETE FROM care_site -- Truncate cannot work with FPK constraints

end
go

----------------------------------------------------------------------------------------------------------------------------------------
-- 11. Prep the patient list (formerly in run script)
-- Also, populate the visit_provids table. It's very slow so we don't want to do this every time we run the transform.
-- Note that this must be run every time i2b2 data is refreshed!
-- TODO, consider moving this
----------------------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPprep') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPprep
go

create procedure OMOPprep 
    @xnum INT=100000000 
as
begin
DECLARE @sql varchar(4000);

truncate table i2b2patient_list ;
truncate table visit_provids ;

SET @sql='insert into i2b2patient_list WITH (TABLOCK) (patient_num)
select distinct top '+cast(@xnum as varchar)+' f.patient_num from i2b2fact f
inner join i2b2visit v on f.patient_num=v.patient_num'
exec(@sql);

-- calculate providerID for every visit_dimension record
insert into visit_provids
SELECT enc.encounter_num, MAX(ofa.provider_id) AS ProviderID
FROM i2b2visit enc
     LEFT OUTER JOIN (select patient_num, encounter_num, provider_id from i2b2fact where provider_id!='@') ofa ON enc.encounter_num = ofa.encounter_num
      --^ bugfix 4/8/20 lots of encounters were not being included because they didn't have a provider
     JOIN i2b2patient_list d on enc.patient_num=d.patient_num -- this line is only to speed up the selection for smaller patient sets
GROUP BY enc.encounter_num

end
GO
 
----------------------------------------------------------------------------------------------------------------------------------------
-- 12. Load Program
-- If you pass a value >0 , OMOP prep is called to build the patient list
----------------------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPloader') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPloader
go

create procedure OMOPloader @xnum INT=0
as
begin

declare @FLAG varchar(30)

exec OMOPclear
set @FLAG=cast(getdate() as varchar(30))
RAISERROR('OMOPclear %s', 0, 1,@FLAG) WITH NOWAIT;
IF @xnum>0 BEGIN exec OMOPprep @xnum END;
set @FLAG=cast(getdate() as varchar(30))
RAISERROR('OMOPprep %s', 0, 1,@FLAG) WITH NOWAIT;
exec OMOPProvider --added for v4.0, needs to be run first.
set @FLAG=cast(getdate() as varchar(30))
RAISERROR('OMOPProvider %s', 0, 1,@FLAG) WITH NOWAIT;
exec OMOPdemographics
set @FLAG=cast(getdate() as varchar(30))
RAISERROR('OMOPdemographics %s', 0, 1,@FLAG) WITH NOWAIT;
exec OMOPcare_site
set @FLAG=cast(getdate() as varchar(30))
RAISERROR('OMOPcare_site %s', 0, 1,@FLAG) WITH NOWAIT;
exec OMOPencounter
set @FLAG=cast(getdate() as varchar(30))
RAISERROR('OMOPencounter %s', 0, 1,@FLAG) WITH NOWAIT;
exec OMOPobservationperiod
set @FLAG=cast(getdate() as varchar(30))
RAISERROR('OMOPobservationperiod %s', 0, 1,@FLAG) WITH NOWAIT;
exec OMOPdiagnosis
set @FLAG=cast(getdate() as varchar(30))
RAISERROR('OMOPdiagnosis %s', 0, 1,@FLAG) WITH NOWAIT;
exec OMOPdrug_exposure
set @FLAG=cast(getdate() as varchar(30))
RAISERROR('OMOPdrug_exposure %s', 0, 1,@FLAG) WITH NOWAIT;
exec OMOPvital
set @FLAG=cast(getdate() as varchar(30))
RAISERROR('OMOPvital %s', 0, 1,@FLAG) WITH NOWAIT;
exec OMOPmeasurementLab
set @FLAG=cast(getdate() as varchar(30))
RAISERROR('OMOPmeasurementLab %s', 0, 1,@FLAG) WITH NOWAIT;
exec OMOPprocedure
set @FLAG=cast(getdate() as varchar(30))
RAISERROR('OMOPprocedure %s', 0, 1,@FLAG) WITH NOWAIT;
exec OMOPprocedure_secondary -- Add procedures as specified by OMOP to all the non-procedure tables
set @FLAG=cast(getdate() as varchar(30))
RAISERROR('OMOPprocedure_secondary %s', 0, 1,@FLAG) WITH NOWAIT;
exec OMOPera
set @FLAG=cast(getdate() as varchar(30))
RAISERROR('OMOPera %s', 0, 1,@FLAG) WITH NOWAIT;
exec OMOPdeath
set @FLAG=cast(getdate() as varchar(30))
RAISERROR('OMOPdeath %s', 0, 1,@FLAG) WITH NOWAIT;
--exec OMOPreport

end
go



-------REPORT---------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'omopReport') AND type in (N'P', N'PC')) DROP PROCEDURE omopReport
go
CREATE PROCEDURE [dbo].[omopReport] 
as
declare @i2b2vitald numeric
declare @i2b2dxd numeric
declare @i2b2cond numeric
declare @i2b2pxd numeric
declare @i2b2encountersd numeric
declare @i2b2pats  numeric
declare @i2b2Encounters numeric
declare @i2b2facts numeric
declare @i2b2dxs numeric
declare @i2b2procs numeric
declare @i2b2lcs numeric
declare @pmnpats  numeric
declare @pmnencounters numeric
declare @pmndx numeric
declare @pmnprocs numeric
declare @pmnfacts numeric
declare @pmnobs numeric
declare @pmnvital numeric
declare @pmnlabs numeric
declare @pmnprescribings numeric
declare @pmncond numeric
declare @pmnencountersd numeric
declare @pmndxd numeric
declare @pmnprocsd numeric
declare @pmnfactsd numeric
declare @pmnenrolld numeric
declare @pmnvitald numeric
declare @pmnlabsd numeric
declare @pmnprescribingsd numeric
declare @pmnobsd numeric
declare @pmncondd numeric
declare @runid numeric
begin
select @i2b2Pats =count(*)  from i2b2patient
select @i2b2Encounters=count(*)   from i2b2visit i inner join person d on i.patient_num=d.person_id

-- Counts in OMOP tables
select @pmnPats=count(*)   from person
select @pmnencounters=count(*)   from visit_occurrence e 
select @pmndx=count(*)   from condition_occurrence
select @pmnprocs =count(*)  from procedure_occurrence
select @pmnvital =count(*)  from measurement  ---vitals are in measurement- Might need to change this to keep labs out
select @pmnlabs =count(*)  from measurement   ---labs are in measurement- Might need to change this to keep vitals out
select @pmnprescribings =count(*)  from drug_exposure
select @pmnobs =count(*)  from observation

-- Distinct patients in OMOP tables
select @pmnencountersd=count(distinct person_id)  from visit_occurrence e 
select @pmndxd=count(distinct person_id)   from condition_occurrence
select @pmnprocsd =count(distinct person_id)  from procedure_occurrence
select @pmnvitald =count(distinct person_id)  from measurement      ---vitals are in measurement right? Might need to change this to keep labs out
select @pmnlabsd =count(distinct person_id)  from measurement       ---labs are in measurement right? Might need to change this to keep vitals out
select @pmnprescribingsd =count(distinct person_id)  from drug_exposure
select @pmnobsd =count(distinct person_id)  from observation

-- Distinct patients in i2b2 (unfinished)
select @i2b2pxd=count(distinct patient_num) from i2b2fact fact
 inner join	pcornet_proc pr on pr.c_basecode  = fact.concept_cd   
where pr.c_fullname like '\PCORI\PROCEDURE\%'


select @i2b2dxd=count(distinct factline.patient_num) from i2b2fact factline
 inner join	pcornet_diag dx on dx.c_basecode  = factline.concept_cd   
where dx.c_fullname like '\PCORI\DIAGNOSIS\%' 

/* Would be nice to optionally allow local paths to count source data, such as:
\i2b2metadata\Diagnosis\ or \i2b2metadata\Diagnosis_ICD10\
\i2b2metadata\medications_rxnorm\
\i2b2metadata\LabTests\
\i2b2metadata\Procedures\
*/

-- Counts in i2b2
/*select @i2b2pxde=count(distinct patient_num) from i2b2fact fact
 inner join	pcornet_proc pr on pr.c_basecode  = fact.concept_cd   
 inner join pmnENCOUNTER enc on enc.patid = fact.patient_num and enc.encounterid = fact.encounter_Num
where pr.c_fullname like '\PCORI\PROCEDURE\%'*/
/*select @i2b2dxd=count(distinct patient_num) from i2b2fact fact
 inner join	pcornet_proc pr on pr.c_basecode  = fact.concept_cd   
where pr.c_fullname like '\PCORI\PROCEDURE\%'
select @i2b2vitald=count(distinct patient_num) from i2b2fact fact
 inner join	pcornet_proc pr on pr.c_basecode  = fact.concept_cd   
where pr.c_fullname like '\PCORI\PROCEDURE\%'
*/
select @i2b2encountersd=count(distinct patient_num) from i2b2visit 
select @runid = max(runid) from i2oreport
set @runid = @runid + 1
insert into i2oreport select @runid, getdate(), 'Pats',			@i2b2pats, @i2b2pats,		@pmnpats,			null
--insert into i2oreport select @runid, getdate(), 'Enrollment',	@i2b2pats, @i2b2pats,		@pmnenroll,			@pmnenrolld
insert into i2oreport select @runid, getdate(), 'Encounters',	@i2b2Encounters,null,@pmnEncounters,		@pmnEncountersd
insert into i2oreport select @runid, getdate(), 'DX',		null,@i2b2dxd,@pmndx,	@pmndxd
insert into i2oreport select @runid, getdate(), 'PX',		null,@i2b2pxd,@pmnprocs,	@pmnprocsd
--insert into i2oreport select @runid, getdate(), 'Condition',		null,@i2b2cond,		@pmncond,	@pmncondd
insert into i2oreport select @runid, getdate(), 'Vital',		null,@i2b2vitald,		@pmnvital,	@pmnvitald
insert into i2oreport select @runid, getdate(), 'Labs',		null,null,		@pmnlabs,	@pmnlabsd
insert into i2oreport select @runid, getdate(), 'Prescribing',		null,null,	@pmnprescribings,	@pmnprescribingsd
--insert into i2oreport select @runid, getdate(), 'Dispensing',		null,null,	@pmndispensings,	@pmndispensingsd
select concept 'Data Type',sourceval 'From i2b2',sourcedistinct 'Patients in i2b2' ,  destval 'In PopMedNet', destdistinct 'Patients in OMOP' from i2oreport where runid=@runid
end
GO
