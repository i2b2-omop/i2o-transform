----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- OMOPLoader Script
-- Contributors: Jeff Klann, PhD; Matthew Joss; Aaron Abend; Arturo Torres
-- Version now managed by changelog. Last update 12/7/16@6pm
-- NOT NEARLY FINISHED! FOR DEVELOPERS ONLY!
-- MSSQL version
--
-- INSTRUCTIONS:
-- 1. Edit the "create synonym" statements, parameters, and the USE statement at the top of this script to point at your objects. 
--    This script will be run from an OMOP database you must have created.
-- 2. In the Second part of this preamble, there are two functions that need to be edited depending on the base units used at your site: unit_ht() and unit_wt(). 
--      Use the corresponding RETURN statement depending on which units your site uses: 
--      Inches (RETURN 1) versus Centimeters(RETURN 0.393701) and Pounds (RETURN 1) versus Kilograms(RETURN 2.20462). 
-- 3. USE your empty OMOP db and make sure it has privileges to read from the various locations that the synonyms point to.
-- 4. Run this script to set up the loader
-- 5. Use the included run_*.sql script to execute the procedure, or run manually via "exec OMOPLoader" (will transform all patients)

----------------------------------------------------------------------------------------------------------------------------------------
-- create synonyms to make the code portable - please edit these
----------------------------------------------------------------------------------------------------------------------------------------

-- Change to your pmn database
use PMI
go

-- drop any existing synonyms
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'i2b2fact') DROP SYNONYM i2b2fact
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'i2b2patient') DROP SYNONYM  i2b2patient
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'i2b2visit') DROP SYNONYM  i2b2visit
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_diag') DROP SYNONYM pcornet_diag
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_demo') DROP SYNONYM pcornet_demo
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_proc') DROP SYNONYM pcornet_proc
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_lab') DROP SYNONYM pcornet_lab
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_med') DROP SYNONYM pcornet_med
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_vital') DROP SYNONYM pcornet_vital
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pcornet_enc') DROP SYNONYM pcornet_enc
IF OBJECTPROPERTY (object_id('dbo.getDataMartID'), 'IsScalarFunction') = 1 DROP function getDataMartID
IF OBJECTPROPERTY (object_id('dbo.getDataMartName'), 'IsScalarFunction') = 1 DROP function getDataMartName
IF OBJECTPROPERTY (object_id('dbo.getDataMartPlatform'), 'IsScalarFunction') = 1 DROP function getDataMartPlatform
GO

-- You will almost certainly need to edit your database name
-- Synonyms for dimension tables
create synonym i2b2visit for PMI..visit_dimension
GO 
create synonym i2b2patient for  PMI..patient_dimension
GO
create synonym i2b2fact for  PMI..observation_fact    
GO
create synonym i2b2concept for  PMI..concept_dimension  
GO

-- You will almost certainly need to edit your database name
-- Synonyms for ontology dimensions and loyalty cohort summary
create synonym pcornet_med for PMI..pcornet_med
GO
create synonym pcornet_lab for PMI..pcornet_lab
GO
create synonym pcornet_diag for PMI..pcornet_diag
GO 
create synonym pcornet_demo for PMI..pcornet_demo 
GO
create synonym pcornet_proc for PMI..pcornet_proc
GO
create synonym pcornet_vital for PMI..pcornet_vital
GO
create synonym pcornet_enc for PMI..pcornet_enc_15
GO

-- Create the demographics codelist (no need to modify)
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[omop_codelist]') AND type in (N'U'))
DROP TABLE [dbo].[omop_codelist]
GO

create table omop_codelist (codetype varchar(20), code varchar(20))
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

CREATE FUNCTION unit_ht() RETURNS float(10) AS BEGIN 
    RETURN 1 -- Use this statement if your site stores HT data in units of Inches 
--    RETURN 0.393701 -- Use this statement if your site stores HT data in units of Centimeters 
END
GO

CREATE FUNCTION unit_wt() RETURNS float(10) AS BEGIN 
    RETURN 1 -- Use this statement if your site stores WT data in units of Pounds 
--    RETURN 2.20462 -- Use this statement if your site stores WT data in units of Kilograms  
END
GO


----------------------------------------------------------------------------------------------------------------------------------------
-- ALTER THE TABLES - note that all tables have changed since v5
----------------------------------------------------------------------------------------------------------------------------------------

-- Download SQL to create the tables from https://github.com/OHDSI/CommonDataModel

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




Alter Table condition_occurrence Drop Column condition_occurrence_id
Go

Alter Table condition_occurrence
Add condition_occurrence_id Int Identity(1, 1)
Go

Alter Table procedure_occurrence Drop Column procedure_occurrence_id
Go

Alter Table procedure_occurrence
Add procedure_occurrence_id Int Identity(1, 1)
Go

Alter Table measurement Drop Column measurement_id
Go

Alter Table measurement
Add measurement_id Int Identity(1, 1)
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
declare @val varchar(20)

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
declare @onecode varchar(20)
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
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'i2pReport') AND type in (N'U')) DROP TABLE i2pReport
GO
create table i2pReport (runid numeric, rundate smalldatetime, concept varchar(20), sourceval numeric, sourcedistinct numeric, destval numeric, destdistinct numeric)
go
insert into i2preport (runid) select 0

-- Run the popcodelist procedure we just created
EXEC pcornet_popcodelist
GO

--- Load the procedures

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- 1. Demographics 
----------------------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPdemographics') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPdemographics
go

create procedure OMOPdemographics as 

DECLARE @sqltext NVARCHAR(4000);
DECLARE @batchid numeric
declare getsql cursor local for 
--1 --  S,R,NH
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,time_of_birth,gender_concept_id,ethnicity_concept_id,race_concept_id) '+ --person(raw_sex,PATID, BIRTH_DATE, BIRTH_TIME,SEX, HISPANIC, RACE) 
	'	select p.sex_cd+'':'+sex.c_name+''',p.race_cd+'':'+race.c_name+''',p.race_cd+'':Unknown'',patient_num, '+
	'	year(birth_date), '+
    '	month(birth_date), '+
    '	day(birth_date), '+
	'	substring(convert(varchar,birth_date,20),12,5), '+
	''''+sex.omop_basecode+''','+
	'0,'+
	''''+race.omop_basecode+''''+
	' from i2b2patient p '+
	'	where lower(p.sex_cd) in ('+lower(sex.c_dimcode)+') '+
	'	and	lower(p.race_cd) in ('+lower(race.c_dimcode)+') '+
	'   and lower(isnull(p.race_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''HISPANIC'') '
	from pcornet_demo race, pcornet_demo sex
	where race.c_fullname like '\PCORI\DEMOGRAPHIC\RACE%'
	and race.c_visualattributes like 'L%'
	and sex.c_fullname like '\PCORI\DEMOGRAPHIC\SEX%'
	and sex.c_visualattributes like 'L%'
union -- A - S,R,H
select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,time_of_birth,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
	'	select p.sex_cd+'':'+sex.c_name+''',p.race_cd+'':'+race.c_name+''',p.race_cd+'':'+hisp.c_name+''',patient_num, '+ --'	select p.sex_cd+'':''+sex.c_name,p.race_cd+'':''+race.c_name,p.race_cd+'':''+hisp.c_name,patient_num, '+
	'	year(birth_date), '+
    '	month(birth_date), '+
    '	day(birth_date), '+
	'	substring(convert(varchar,birth_date,20),12,5), '+
	''''+sex.omop_basecode+''','+
	''''+hisp.omop_basecode+''','+
	''''+race.omop_basecode+''''+
	' from i2b2patient p '+
	'	where lower(p.sex_cd) in ('+lower(sex.c_dimcode)+') '+
	'	and	lower(p.race_cd) in ('+lower(race.c_dimcode)+') '+
	'	and	lower(isnull(p.race_cd,''xx'')) in (select lower(code) from omop_codelist where codetype=''RACE'') '+
	'   and lower(isnull(p.race_cd,''xx'')) in (select lower(code) from omop_codelist where codetype=''HISPANIC'') '
	from pcornet_demo race, pcornet_demo hisp, pcornet_demo sex
	where race.c_fullname like '\PCORI\DEMOGRAPHIC\RACE%'
	and race.c_visualattributes like 'L%'
	and hisp.c_fullname like '\PCORI\DEMOGRAPHIC\HISPANIC\Y%'
	and hisp.c_visualattributes like 'L%'
	and sex.c_fullname like '\PCORI\DEMOGRAPHIC\SEX%'
	and sex.c_visualattributes like 'L%'
union --2 S, nR, nH
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,time_of_birth,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
	'	select p.sex_cd+'':'+sex.c_name+''',p.race_cd+'':Unknown'',p.race_cd+'':Unknown'',patient_num, '+ --'	select p.sex_cd,p.race_cd,p.race_cd,patient_num, '+
	'	year(birth_date), '+
    '	month(birth_date), '+
    '	day(birth_date), '+
	'	substring(convert(varchar,birth_date,20),12,5), '+
	''''+sex.omop_basecode+''','+
	'0,'+
	'0'+
	' from i2b2patient p '+
	'	where lower(isnull(p.sex_cd,''xx'')) in ('+lower(sex.c_dimcode)+') '+
	'	and	lower(isnull(p.race_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''RACE'') '+
	'   and lower(isnull(p.race_cd,''ni'')) not in (select lower(code) from omop_codelist where codetype=''HISPANIC'') '
	from pcornet_demo sex
	where sex.c_fullname like '\PCORI\DEMOGRAPHIC\SEX%'
	and sex.c_visualattributes like 'L%'
union --3 -- nS,R, NH
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,time_of_birth,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
	'	select p.sex_cd,p.race_cd+'':'+race.c_name+''',p.race_cd+'':Unknown'',patient_num, '+
	'	year(birth_date), '+
    '	month(birth_date), '+
    '	day(birth_date), '+
	'	substring(convert(varchar,birth_date,20),12,5), '+
	'0,'+
	'0,'+
	''''+race.omop_basecode+''''+
	' from i2b2patient p '+
	'	where lower(isnull(p.sex_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''SEX'') '+
	'	and	lower(p.race_cd) in ('+lower(race.c_dimcode)+') '+
	'   and lower(isnull(p.race_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''HISPANIC'')'
	from pcornet_demo race
	where race.c_fullname like '\PCORI\DEMOGRAPHIC\RACE%'
	and race.c_visualattributes like 'L%'
union --B -- nS,R, H
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,time_of_birth,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
	'	select p.sex_cd,p.race_cd+'':'+race.c_name+''',p.race_cd+'':'+hisp.c_name+''',patient_num, '+
	'	year(birth_date), '+
    '	month(birth_date), '+
    '	day(birth_date), '+
	'	substring(convert(varchar,birth_date,20),12,5), '+
	'0,'+
	''''+hisp.omop_basecode+''','+
	''''+race.omop_basecode+''''+
	' from i2b2patient p '+
	'	where lower(isnull(p.sex_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''SEX'') '+
	'	and	lower(p.race_cd) in ('+lower(race.c_dimcode)+') '+
	'	and	lower(isnull(p.race_cd,''xx'')) in (select lower(code) from omop_codelist where codetype=''RACE'') '+
	'   and lower(isnull(p.race_cd,''xx'')) in (select lower(code) from omop_codelist where codetype=''HISPANIC'')'
	from pcornet_demo race,pcornet_demo hisp
	where race.c_fullname like '\PCORI\DEMOGRAPHIC\RACE%'
	and race.c_visualattributes like 'L%'
	and hisp.c_fullname like '\PCORI\DEMOGRAPHIC\HISPANIC\Y%'
	and hisp.c_visualattributes like 'L%'
union --4 -- S, NR, H
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,time_of_birth,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
	'	select p.sex_cd+'':'+sex.c_name+''',p.race_cd+'':Unknown'',p.race_cd+'':Hispanic'',patient_num, '+
	'	year(birth_date), '+
    '	month(birth_date), '+
    '	day(birth_date), '+
	'	substring(convert(varchar,birth_date,20),12,5), '+
	''''+sex.omop_basecode+''','+
	'38003563,'+
	'0'+
	' from i2b2patient p '+
	'	where lower(isnull(p.sex_cd,''NI'')) in ('+lower(sex.c_dimcode)+') '+
	'	and lower(isnull(p.race_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''RACE'') '+
	'	and lower(isnull(p.race_cd,''xx'')) in (select lower(code) from omop_codelist where codetype=''HISPANIC'') '
	from pcornet_demo sex
	where sex.c_fullname like '\PCORI\DEMOGRAPHIC\SEX%'
	and sex.c_visualattributes like 'L%'
union --5 -- NS, NR, H
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,time_of_birth,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
	'	select p.sex_cd,p.race_cd+'':Unknown'',p.race_cd+'':Hispanic'',patient_num, '+
	'	year(birth_date), '+
    '	month(birth_date), '+
    '	day(birth_date), '+
	'	substring(convert(varchar,birth_date,20),12,5), '+
	'0,'+
	'38003563,'+
	'0'+
	' from i2b2patient p '+
	'	where lower(isnull(p.sex_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''SEX'') '+
	'	and lower(isnull(p.race_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''RACE'') '+
	'	and lower(isnull(p.race_cd,''xx'')) in (select lower(code) from omop_codelist where codetype=''HISPANIC'')'
union --6 -- NS, NR, nH
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,time_of_birth,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
	'	select p.sex_cd,p.race_cd+'':Unknown'',p.race_cd+'':Unknown'',patient_num, '+
	'	year(birth_date), '+
    '	month(birth_date), '+
    '	day(birth_date), '+
	'	substring(convert(varchar,birth_date,20),12,5), '+
	'0,'+
	'0,'+
	'0'+
	' from i2b2patient p '+
	'	where lower(isnull(p.sex_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''SEX'') '+
	'	and lower(isnull(p.race_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''HISPANIC'') '+
	'   and lower(isnull(p.race_cd,''xx'')) not in (select lower(code) from omop_codelist where codetype=''RACE'') ' 

begin
exec pcornet_popcodelist

set @batchid = 0
OPEN getsql;
FETCH NEXT FROM getsql INTO @sqltext;

WHILE @@FETCH_STATUS = 0
BEGIN
	--print @sqltext
	exec sp_executesql @sqltext
	FETCH NEXT FROM getsql INTO @sqltext;
	
END

CLOSE getsql;
DEALLOCATE getsql;

end

go

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- 2. Encounter - v6 by Jeff Klann and Aaron Abend
-- TODO: This version does not translate codes in the visit_dimension columns, except inout_cd (enc_type)
-- Bugfix: Multiple DRGs in one encounter no longer causes error
----------------------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPencounter') AND type in (N'P', N'PC'))
DROP PROCEDURE OMOPencounter
GO

create procedure OMOPencounter as

DECLARE @sqltext NVARCHAR(4000);
begin

insert into visit_occurrence(person_id,visit_occurrence_id,visit_start_date,visit_start_time, 
		visit_end_date,visit_end_time,provider_id,  
		visit_concept_id ,care_site_id,visit_type_concept_id,visit_source_value) 
select distinct v.patient_num, v.encounter_num,  
	start_Date, 
	cast(start_Date as time), 
	(case when end_date is not null then end_date else start_date end) end_Date, 
	(case when end_date is not null then cast(end_Date as time) else cast(start_date as time) end),  
	'0', 
(case when omop_enctype is not null then omop_enctype else '0' end) enc_type, '0', '44818518',v.inout_cd  
from i2b2visit v inner join person d on v.patient_num=d.person_id
left outer join 
-- Encounter type. Note that this requires a full table scan on the ontology table, so it is not particularly efficient.
(select patient_num, encounter_num, inout_cd,omop_basecode omop_enctype from i2b2visit v
 inner join pcornet_enc e on c_dimcode like '%'''+inout_cd+'''%' and e.c_fullname like '\PCORI\ENCOUNTER\ENC_TYPE\%') enctype
  on enctype.patient_num=v.patient_num and enctype.encounter_num=v.encounter_num

end
go

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- 3. Diagnosis - v6.1 by Aaron Abend and Jeff Klann
--   new: removed factline cache
--        now ignores facts with a condition modifier
--        6.1. optimized for temp tables
-- + 3a. Condition, combined within this procedure.
----------------------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPdiagnosis') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPdiagnosis
go

create procedure OMOPdiagnosis as
declare @sqltext nvarchar(4000)
begin

-- Optimized to use temp tables, not views. Also removed the distinct for speed.
select  patient_num, encounter_num, factline.provider_id, concept_cd, start_date, dxsource.pcori_basecode dxsource, dxsource.c_fullname
 into #sourcefact
from i2b2fact factline
inner join visit_occurrence enc on enc.person_id = factline.patient_num and enc.visit_occurrence_id = factline.encounter_Num
inner join pcornet_diag dxsource on factline.modifier_cd =dxsource.c_basecode  
where dxsource.c_fullname like '\PCORI_MOD\CONDITION_OR_DX\%'

select  patient_num, encounter_num, factline.provider_id, concept_cd, start_date, dxsource.pcori_basecode pdxsource,dxsource.c_fullname 
into #pdxfact from i2b2fact factline 
inner join visit_occurrence enc on enc.person_id = factline.patient_num and enc.visit_occurrence_id = factline.encounter_Num 
inner join pcornet_diag dxsource on factline.modifier_cd =dxsource.c_basecode  
and dxsource.c_fullname like '\PCORI_MOD\PDX\%'

insert into condition_occurrence (person_id, visit_occurrence_id, condition_start_date, provider_id, condition_concept_id, condition_type_concept_id, condition_end_date, condition_source_value, condition_source_concept_id) --pmndiagnosis (patid,encounterid, X enc_type, admit_date, providerid, dx, dx_type, dx_source, pdx)
select distinct factline.patient_num, factline.encounter_num encounterid, enc.visit_start_date, enc.provider_id, --bug fix MJ 10/7/16
isnull(omap.concept_id, '0'), 
CASE WHEN (sf.c_fullname like '\PCORI_MOD\CONDITION_OR_DX\DX_SOURCE\%' or sf.c_fullname is null) THEN 
    CASE WHEN pf.pdxsource = 'P' THEN 44786627 WHEN pf.pdxsource= 'S' THEN 44786629 ELSE '0' END 
    ELSE 38000245 END, 
end_date, pcori_basecode, diag.omop_sourcecode
from i2b2fact factline
inner join visit_occurrence enc on enc.person_id = factline.patient_num and enc.visit_occurrence_id = factline.encounter_Num
 left outer join #sourcefact sf
on	factline.patient_num=sf.patient_num
and factline.encounter_num=sf.encounter_num
and factline.provider_id=sf.provider_id --bug fix MJ 10/7/16, JK 12/7/16
and factline.concept_cd=sf.concept_Cd
and factline.start_date=sf.start_Date --bug fix MJ 10/7/16, JK 12/7/16
left outer join #pdxfact pf
on	factline.patient_num=pf.patient_num
and factline.encounter_num=pf.encounter_num
and factline.provider_id=pf.provider_id --bug fix MJ 10/7/16, JK 12/7/16
and factline.concept_cd=pf.concept_cd
and factline.start_date=pf.start_Date --bug fix MJ 10/7/16, JK 12/7/16
inner join pcornet_diag diag on diag.c_basecode  = factline.concept_cd
inner join i2o_mapping omap on diag.omop_sourcecode=omap.omop_sourcecode and omap.domain_id='Condition'
-- Skip ICD-9 V codes in 10 ontology, ICD-9 E codes in 10 ontology, ICD-10 numeric codes in 10 ontology
-- Note: makes the assumption that ICD-9 Ecodes are not ICD-10 Ecodes; same with ICD-9 V codes. On inspection seems to be true.
where (diag.c_fullname not like '\PCORI\DIAGNOSIS\10\%' or
  ( not ( diag.pcori_basecode like '[V]%' and diag.c_fullname not like '\PCORI\DIAGNOSIS\10\([V]%\([V]%\([V]%' )
  and not ( diag.pcori_basecode like '[E]%' and diag.c_fullname not like '\PCORI\DIAGNOSIS\10\([E]%\([E]%\([E]%' ) 
  and not (diag.c_fullname like '\PCORI\DIAGNOSIS\10\%' and diag.pcori_basecode like '[0-9]%') )) 
--and (sf.c_fullname like '\PCORI_MOD\CONDITION_OR_DX\DX_SOURCE\%' or sf.c_fullname is null)

end
go

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- 4. Procedures - v6 by Aaron Abend and Jeff Klann
-- v6 - minor optimizations
-- 0.6.4 - NI in px_source, fixed encounter start vs. fact start
-- 0.6.5 - Somehow was referencing the wrong column name from encounter table for admit date
----------------------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPprocedure') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPprocedure
go

create procedure OMOPprocedure as

begin

---------------------------------------
-- Copied and tweaked from condition_ocurrence procedure 'OMOPDiagnosis'
---------------------------------------
-- Optimized to use temp tables, not views. Also removed the distinct for speed.
select  patient_num, encounter_num, factline.provider_id, concept_cd, start_date, pxsource.pcori_basecode dxsource, pxsource.c_fullname
 into #procedurefact
from i2b2fact factline
inner join visit_occurrence enc on enc.person_id = factline.patient_num and enc.visit_occurrence_id = factline.encounter_Num
inner join PCORNET_PROC pxsource on factline.concept_cd =pxsource.c_basecode  
where pxsource.c_fullname like '\PCORI\PROCEDURE\%'

---------------------- Old PCORI Columns----------------------------------------------------------
--				patid,			encounterid,	enc_type, admit_date, providerid, px, px_type, px_source,px_date) 
---------------------------------------------------------------------------------------------------
insert into procedure_occurrence( person_id,  procedure_concept_id, procedure_date, procedure_type_concept_id, modifier_concept_id, quantity, provider_id, visit_occurrence_id, procedure_source_value, procedure_source_concept_id, qualifier_source_value) 
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
select  distinct fact.patient_num, isnull(omap.concept_id, '0'), enc.visit_start_date, 0, 0, null, 0, fact.encounter_num, pproc.PCORI_BASECODE, pproc.OMOP_SOURCECODE, null
from i2b2fact fact
---------------------------------------------------------
-- For every procedure there must be a corresponding visit
-----------------------------------------------------------
 inner join visit_occurrence enc on enc.person_id = fact.patient_num and enc.visit_occurrence_id = fact.encounter_Num 
 inner join PCORNET_PROC pproc on pproc.c_basecode = fact.concept_cd
 inner join i2o_mapping omap on pproc.omop_sourcecode=omap.omop_sourcecode and omap.domain_id='Procedure'
-----------------------------------------------------------
-- look for observation facts that are procedures
-- Q: Which procedures are primary and which are secondary and which are unknown
---------- For the moment setting everything unknown
-----------------------------------------------------------
left outer join #procedurefact pf
	on fact.patient_num = pf.patient_num
	and fact.encounter_num = pf.encounter_num
	and fact.provider_id = pf.provider_id
	and fact.concept_cd = pf.concept_cd
	and fact.start_date = pf.START_DATE
where pf.c_fullname like '\PCORI\PROCEDURE\%'

end
go



----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- 5. Vitals - v6 by Jeff Klann
-- TODO: This version does not do unit conversions.
----------------------------------------------------------------------------------------------------------------------------------------
------------------------- Vitals Code ------------------------------------------------ 
-- Written by Jeff Klann, PhD
-- Borrows heavily from GPC's CDM_transform.sql by Dan Connolly and Nathan Graham, available at https://bitbucket.org/njgraham/pcori-annotated-data-dictionary/overview 
-- This transform must be run after demographics and encounters. It does not rely on the PCORI_basecode column except for tobacco and smoking status, so that does not need to be changed.
-- v6 now supports CDM v3 (smoking and tobacco transforms)
-- v0.6.4 now correctly merges modifiers
-- TODO: This does not do unit conversions.

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPvital') AND type in (N'P', N'PC'))
DROP PROCEDURE OMOPvital
GO

create procedure OMOPvital as
begin
-- jgk: I took out admit_date - it doesn't appear in the scheme. Now in SQLServer format - date, substring, name on inner select, no nested with. Added modifiers and now use only pathnames, not codes.
insert into measurement(person_id, visit_occurrence_id, measurement_date, measurement_time)--pmnVITAL(patid, encounterid, measure_date, measure_time,ht, wt, diastolic, systolic, original_bmi, bp_position,smoking,tobacco,tobacco_type)
select patid, encounterid, measure_date, measure_time,vital_source,ht, wt, diastolic, systolic, original_bmi, bp_position,smoking,tobacco,
case when tobacco in ('02','03','04') then -- no tobacco
    case when smoking in ('03','04') then '04' -- no smoking
        when smoking in ('01','02','07','08') then '01' -- smoking
        else 'NI' end -- (no tobacco, unknown smoking)
 when tobacco='01' then -- tobacco
    case when smoking in ('03','04') then '02' -- no smoking
        when smoking in ('01','02','07','08') then '03' -- smoking
        else 'OT' end -- (tobacco, unknown smoking)
  when tobacco in ('NI','OT','UN') and smoking in ('01','02','07','08') then '05'  -- (unknown tobacco w/ smoking) jgk bugfix 12/17/15
 else 'NI' end tobacco_type 
from
(select patid, encounterid, measure_date, measure_time, --isnull(max(vital_source),'HC') vital_source, -- jgk: not in the spec, so I took it out  admit_date,
max(ht) ht, max(wt) wt, max(diastolic) diastolic, max(systolic) systolic, 
max(original_bmi) original_bmi, isnull(max(bp_position),'NI') bp_position,
isnull(isnull(max(smoking),max(unk_tobacco)),'NI') smoking,
isnull(isnull(max(tobacco),max(unk_tobacco)),'NI') tobacco
from (
  select vit.patid, vit.encounterid, vit.measure_date, vit.measure_time 
    , case when vit.pcori_code like '\PCORI\VITAL\HT%' then vit.nval_num*(dbo.unit_ht()) else null end ht -- unit_ht() converts from centimeters to inches
    , case when vit.pcori_code like '\PCORI\VITAL\WT%' then vit.nval_num*(dbo.unit_wt()) else null end wt -- unit_wt() converts from kilograms to pounds
    , case when vit.pcori_code like '\PCORI\VITAL\BP\DIASTOLIC%' then vit.nval_num else null end diastolic
    , case when vit.pcori_code like '\PCORI\VITAL\BP\SYSTOLIC%' then vit.nval_num else null end systolic
    , case when vit.pcori_code like '\PCORI\VITAL\ORIGINAL_BMI%' then vit.nval_num else null end original_bmi
    , case when vit.pcori_code like '\PCORI_MOD\BP_POSITION\%' then substring(vit.pcori_code,len(vit.pcori_code)-2,2) else null end bp_position
    , case when vit.pcori_code like '\PCORI_MOD\VITAL_SOURCE\%' then substring(vit.pcori_code,len(vit.pcori_code)-2,2) else null end vital_source
    , case when vit.pcori_code like '\PCORI\VITAL\TOBACCO\02\%' then vit.pcori_basecode else null end tobacco
    , case when vit.pcori_code like '\PCORI\VITAL\TOBACCO\SMOKING\%' then vit.pcori_basecode else null end smoking
    , case when vit.pcori_code like '\PCORI\VITAL\TOBACCO\__\%' then vit.pcori_basecode else null end unk_tobacco
    , enc.admit_date
  from pmndemographic pd
  left join (
 -- Begin gather facts and modifier facts
      select patient_num patid, encounter_num encounterid, 
      	substring(convert(varchar,start_Date,20),1,10) measure_date, 
	substring(convert(varchar,start_Date,20),12,5) measure_time, 
      nval_num, pcori_basecode, pcori_code from
    (select obs.patient_num, obs.encounter_num, obs.start_Date, nval_num, pcori_basecode, codes.pcori_code
    from i2b2fact obs
    inner join (select c_basecode concept_cd, c_fullname pcori_code, pcori_basecode
      from (
        select '\PCORI\VITAL\BP\DIASTOLIC\' concept_path 
        union all
        select '\PCORI\VITAL\BP\SYSTOLIC\' concept_path 
        union all
        select '\PCORI\VITAL\HT\' concept_path
        union all
        select '\PCORI\VITAL\WT\' concept_path
        union all
        select '\PCORI\VITAL\ORIGINAL_BMI\' concept_path
        union all
        select '\PCORI\VITAL\TOBACCO\' concept_path
        ) bp, pcornet_vital pm
      where pm.c_fullname like bp.concept_path + '%'
      ) codes on (codes.concept_cd = obs.concept_cd) 
      UNION ALL
    select obs.patient_num, obs.encounter_num, obs.start_Date, nval_num, pcori_basecode, codes.pcori_code
    from i2b2fact obs
    inner join (select c_basecode concept_cd, c_fullname pcori_code, pcori_basecode
      from (
        select '\PCORI_MOD\BP_POSITION\' concept_path
        union all
        select '\PCORI_MOD\VITAL_SOURCE\' concept_path
        ) bp, pcornet_vital pm
      where pm.c_fullname like bp.concept_path + '%'
     ) codes on (codes.concept_cd = obs.modifier_cd)
     )fx
-- End gather facts and modifier facts
    ) vit on vit.patid = pd.patid    
  join pmnencounter enc on enc.encounterid = vit.encounterid
  ) x
where ht is not null 
  or wt is not null 
  or diastolic is not null 
  or systolic is not null 
  or original_bmi is not null
  or bp_position is not null
  or vital_source is not null
  or smoking is not null
  or tobacco is not null
group by patid, encounterid, measure_date, measure_time, admit_date) y

end 
go

----------------------------------------------------------------------------------------------------------------------------------------
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
      ,[measurement_time]--[RESULT_TIME]
      ,[value_as_concept_id]--[RESULT_QUAL]
      ,[value_as_number]--[RESULT_NUM]
      ,[unit_source_value]--[RESULT_UNIT]
      ,[value_source_value]--[RAW_RESULT]
      ,[unit_concept_id]
      ,[measurement_concept_id]
      ,[measurement_source_concept_id]
      ,[measurement_type_concept_id]
      ,[provider_id])

Select distinct m.patient_num, m.encounter_num, vital.i_loinc, 
Cast(m.start_date as DATE) meaure_date,   
CAST(CONVERT(char(5), M.start_date, 108) as TIME) measure_time,
'0', m.nval_num, m.units_cd, concat (tval_char, nval_num), u.concept_id, isnull(vital.omop_sourcecode, '0'), vital.omop_sourcecode,
'44818701', '0'
from i2b2fact m
inner join visit_occurrence enc on enc.person_id = m.patient_num and enc.visit_occurrence_id = m.encounter_Num
inner join pcornet_vital vital on vital.c_basecode  = m.concept_cd
left outer join i2o_unitsmap u on u.units_name=m.units_cd
where vital.c_fullname like '\PCORI\VITAL\%'
and vital.i_loinc is not null 

end
go
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- 6. Enrollment - v6 by Jeff Klann
----------------------------------------------------------------------------------------------------------------------------------------
------------------------- Enrollment Code ------------------------------------------------ 
-- Written by Jeff Klann, PhD
-- v6 Updated 9/30/15 - now supports loyalty cohort (be sure view at the top of the script is updated)
-- Bugfix 1/11/16 - BASIS should be called ENR_BASIS
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPenroll') AND type in (N'P', N'PC'))
DROP PROCEDURE OMOPenroll
GO

create procedure OMOPenroll as
begin

INSERT INTO [pmnENROLLMENT]([PATID], [ENR_START_DATE], [ENR_END_DATE], [CHART], [ENR_BASIS]) 
    select x.patient_num patid, case when l.patient_num is not null then l.period_start else enr_start end enr_start_date
    , case when l.patient_num is not null then l.period_end when enr_end_end>enr_end then enr_end_end else enr_end end enr_end_date 
    , 'Y' chart, case when l.patient_num is not null then 'A' else 'E' end enr_basis from 
    (select patient_num, min(start_date) enr_start,max(start_date) enr_end,max(end_date) enr_end_end from i2b2visit where patient_num in (select patid from pmndemographic) group by patient_num) x
    left outer join i2b2loyalty_patients l on l.patient_num=x.patient_num

end
go

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- 7. LAB_RESULT_CM - v6.1
----------------------------------------------------------------------------------------------------------------------------------------
------------------------- LAB_RESULT_CM------------------------------------------------ 
-- 8/14/2015 - first version
-- 9/24/15 - Removed factline cache and optimized
-- 12/9/15 - Optimized to use temp tables
-- Written by Jeff Klann, PhD and Arturo Torres

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPlabResultCM') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPlabResultCM;
GO
create procedure OMOPlabResultCM as
begin

-- Optimized to use temp tables; also, removed "distinct" - much faster and seems unnecessary - 12/9/15
select patient_num, encounter_num, m.provider_id, concept_cd, start_date, lsource.pcori_basecode  PRIORITY 
into #priority from i2b2fact M
inner join visit_occurrence enc on enc.person_id = m.patient_num and enc.visit_occurrence_id = m.encounter_Num
inner join pcornet_lab lsource on m.modifier_cd =lsource.c_basecode
where c_fullname LIKE '\PCORI_MOD\PRIORITY\%'
 
select  patient_num, encounter_num, m.provider_id, concept_cd, start_date, lsource.pcori_basecode  RESULT_LOC
into #location from i2b2fact M
inner join visit_occurrence enc on enc.person_id = m.patient_num and enc.visit_occurrence_id = m.encounter_Num
inner join pcornet_lab lsource on m.modifier_cd =lsource.c_basecode
where c_fullname LIKE '\PCORI_MOD\RESULT_LOC\%'

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
      ,[measurement_time]--[RESULT_TIME]
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
      ,[provider_id])

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
Cast(m.start_date as DATE) RESULT_DATE,   -- Bug fix MJ 10/06/16
CAST(CONVERT(char(5), M.start_date, 108) as TIME) RESULT_TIME,
CASE WHEN m.ValType_Cd='T' THEN CASE WHEN m.Tval_Char IS NOT NULL THEN 'OT' ELSE '0' END END RESULT_QUAL, -- TODO: Should be a standardized value
CASE WHEN m.ValType_Cd='N' THEN m.NVAL_NUM ELSE null END RESULT_NUM,
--CASE WHEN m.ValType_Cd='N' THEN (CASE isnull(nullif(m.TVal_Char,''),'NI') WHEN 'E' THEN 'EQ' WHEN 'NE' THEN 'OT' WHEN 'L' THEN 'LT' WHEN 'LE' THEN 'LE' WHEN 'G' THEN 'GT' WHEN 'GE' THEN 'GE' ELSE 'NI' END)  ELSE 'TX' END RESULT_MODIFIER,
isnull(m.Units_CD,'NI') RESULT_UNIT, -- TODO: Should be standardized units
nullif(norm.NORM_RANGE_LOW,'') NORM_RANGE_LOW,
--norm.NORM_MODIFIER_LOW,
nullif(norm.NORM_RANGE_HIGH,'') NORM_RANGE_HIGH,
--norm.NORM_MODIFIER_HIGH,
--CASE isnull(nullif(m.VALUEFLAG_CD,''),'NI') WHEN 'H' THEN 'AH' WHEN 'L' THEN 'AL' WHEN 'A' THEN 'AB' ELSE 'NI' END ABN_IND,
CASE WHEN m.ValType_Cd='T' THEN substring(m.TVal_Char,1,50) ELSE substring(cast(m.NVal_Num as varchar),1,50) END RAW_RESULT,
u.concept_id, omap.concept_id, ont_loinc.omop_sourcecode, '44818702', '0'


FROM i2b2fact M   --JK bug fix 10/7/16
inner join visit_occurrence enc on enc.person_id = m.patient_num and enc.visit_occurrence_id = m.encounter_Num -- Constraint to selected encounters
inner join pcornet_lab lab on lab.c_basecode  = M.concept_cd and lab.c_fullname like '\PCORI\LAB_RESULT_CM\%'
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

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- 8. HARVEST - v6
-- Populates with SCILHS defaults and parameters at top of script. Update for other networks.
-- 1/16/16 fixed typo
-- 5/17/16 fixed quotes around insert statement
----------------------------------------------------------------------------------------------------------------------------------------
-- BUGFIX 04/22/16: Needed leading zeros on numbers

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPharvest') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPharvest;
GO
create procedure OMOPharvest as
begin

INSERT INTO [dbo].[pmnharvest]([NETWORKID], [NETWORK_NAME], [DATAMARTID], [DATAMART_NAME], [DATAMART_PLATFORM], [CDM_VERSION], [DATAMART_CLAIMS], [DATAMART_EHR], [BIRTH_DATE_MGMT], [ENR_START_DATE_MGMT], [ENR_END_DATE_MGMT], [ADMIT_DATE_MGMT], [DISCHARGE_DATE_MGMT], [PX_DATE_MGMT], [RX_ORDER_DATE_MGMT], [RX_START_DATE_MGMT], [RX_END_DATE_MGMT], [DISPENSE_DATE_MGMT], [LAB_ORDER_DATE_MGMT], [SPECIMEN_DATE_MGMT], [RESULT_DATE_MGMT], [MEASURE_DATE_MGMT], [ONSET_DATE_MGMT], [REPORT_DATE_MGMT], [RESOLVE_DATE_MGMT], [PRO_DATE_MGMT], [REFRESH_DEMOGRAPHIC_DATE], [REFRESH_ENROLLMENT_DATE], [REFRESH_ENCOUNTER_DATE], [REFRESH_DIAGNOSIS_DATE], [REFRESH_PROCEDURES_DATE], [REFRESH_VITAL_DATE], [REFRESH_DISPENSING_DATE], [REFRESH_LAB_RESULT_CM_DATE], [REFRESH_CONDITION_DATE], [REFRESH_PRO_CM_DATE], [REFRESH_PRESCRIBING_DATE], [REFRESH_PCORNET_TRIAL_DATE], [REFRESH_DEATH_DATE], [REFRESH_DEATH_CAUSE_DATE]) 
	VALUES('SCILHS', 'SCILHS', dbo.getDataMartID(), dbo.getDataMartName(), dbo.getDataMartPlatform(), 3, '01', '02', '01','01','02','01','02','01','02','01','02','01','01','02','02','01','01','01','02','01',getdate(),getdate(),getdate(),getdate(),getdate(),getdate(),getdate(),getdate(),getdate(),null,getdate(),null,null,null)

end
GO

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- 9. Prescribing - by Aaron Abend and Jeff Klann, PhD with optimizations by Griffin Weber, MD, PhD
----------------------------------------------------------------------------------------------------------------------------------------
-- You must have run the meds_schemachange proc to create the PCORI_NDC and PCORI_CUI columns
-- TODO: The first encounter inner join seems to slow things down

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPprescribing') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPprescribing;
GO
create procedure OMOPprescribing as
begin

-- Griffin's optimization: use temp tables rather than left joining directly - 12/9/15
    select pcori_basecode,c_fullname,instance_num,start_date,provider_id,concept_cd,encounter_num,modifier_cd
		into #basis
		from i2b2fact basis
			inner join pmnENCOUNTER enc on enc.patid = basis.patient_num and enc.encounterid = basis.encounter_Num
		 join pcornet_med basiscode 
			on basis.modifier_cd = basiscode.c_basecode
			and basiscode.c_fullname like '\PCORI_MOD\RX_BASIS\%'

    select pcori_basecode,instance_num,start_date,provider_id,concept_cd,encounter_num,modifier_cd 
		into #freq
		from i2b2fact freq
			inner join pmnENCOUNTER enc on enc.patid = freq.patient_num and enc.encounterid = freq.encounter_Num
		 join pcornet_med freqcode 
			on freq.modifier_cd = freqcode.c_basecode
			and freqcode.c_fullname like '\PCORI_MOD\RX_FREQUENCY\%'

    select nval_num,instance_num,start_date,provider_id,concept_cd,encounter_num,modifier_cd
		into #quantity
		from i2b2fact quantity
			inner join pmnENCOUNTER enc on enc.patid = quantity.patient_num and enc.encounterid = quantity.encounter_Num
		 join pcornet_med quantitycode 
			on quantity.modifier_cd = quantitycode.c_basecode
			and quantitycode.c_fullname like '\PCORI_MOD\RX_QUANTITY\'

	select nval_num,instance_num,start_date,provider_id,concept_cd,encounter_num,modifier_cd 
		into #refills
		from i2b2fact refills
			inner join pmnENCOUNTER enc on enc.patid = refills.patient_num and enc.encounterid = refills.encounter_Num
		 join pcornet_med refillscode 
			on refills.modifier_cd = refillscode.c_basecode
			and refillscode.c_fullname like '\PCORI_MOD\RX_REFILLS\'

    select nval_num,instance_num,start_date,provider_id,concept_cd,encounter_num,modifier_cd 
		into #supply
		from i2b2fact supply
			inner join pmnENCOUNTER enc on enc.patid = supply.patient_num and enc.encounterid = supply.encounter_Num
		 join pcornet_med supplycode 
			on supply.modifier_cd = supplycode.c_basecode
			and supplycode.c_fullname like '\PCORI_MOD\RX_DAYS_SUPPLY\'

-- insert data with outer joins to ensure all records are included even if some data elements are missing
insert into pmnprescribing (
	PATID
    ,encounterid
    ,RX_PROVIDERID
	,RX_ORDER_DATE -- using start_date from i2b2
	,RX_ORDER_TIME  -- using time start_date from i2b2
	,RX_START_DATE
	,RX_END_DATE 
    ,RXNORM_CUI --using pcornet_med pcori_cui - new column!
    ,RX_QUANTITY ---- modifier nval_num
    ,RX_REFILLS  -- modifier nval_num
    ,RX_DAYS_SUPPLY -- modifier nval_num
    ,RX_FREQUENCY --modifier with basecode lookup
    ,RX_BASIS --modifier with basecode lookup
--    ,RAW_RX_MED_NAME, --not filling these right now
--    ,RAW_RX_FREQUENCY,
--    ,RAW_RXNORM_CUI
)
select distinct  m.patient_num, m.Encounter_Num,m.provider_id,  m.start_date order_date,  substring(convert(varchar,m.start_date,8),1,5), m.start_date start_date, m.end_date, mo.pcori_cui
    ,quantity.nval_num quantity, refills.nval_num refills, supply.nval_num supply, substring(freq.pcori_basecode,charindex(':',freq.pcori_basecode)+1,2) frequency, substring(basis.pcori_basecode,charindex(':',basis.pcori_basecode)+1,2) basis
 from i2b2fact m inner join pcornet_med mo on m.concept_cd = mo.c_basecode 
inner join pmnENCOUNTER enc on enc.encounterid = m.encounter_Num
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

where (basis.c_fullname is null or basis.c_fullname like '\PCORI_MOD\RX_BASIS\PR\%') -- jgk 11/2 bugfix: filter for PR, not DI

end
GO
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- 9a. Dispensing - by Aaron Abend and Jeff Klann, PhD 
----------------------------------------------------------------------------------------------------------------------------------------
-- You must have run the meds_schemachange proc to create the PCORI_NDC and PCORI_CUI columns

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPdispensing') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPdispensing;
GO
create procedure OMOPdispensing as
begin

-- Griffin's optimizations - 12/9/15
select nval_num,encounter_num,concept_cd 
    into #supply
    from i2b2fact supply
        inner join pmnENCOUNTER enc on enc.patid = supply.patient_num and enc.encounterid = supply.encounter_Num
      join pcornet_med supplycode 
        on supply.modifier_cd = supplycode.c_basecode
        and supplycode.c_fullname like '\PCORI_MOD\RX_DAYS_SUPPLY\'

select nval_num,encounter_num,concept_cd 
    into #amount
    from i2b2fact amount
     join pcornet_med amountcode
        on amount.modifier_cd = amountcode.c_basecode
        and amountcode.c_fullname like '\PCORI_MOD\RX_QUANTITY\'

-- insert data with outer joins to ensure all records are included even if some data elements are missing

insert into pmndispensing (
	PATID
    ,PRESCRIBINGID
	,DISPENSE_DATE -- using start_date from i2b2
    ,NDC --using pcornet_med pcori_ndc - new column!
    ,DISPENSE_SUP ---- modifier nval_num
    ,DISPENSE_AMT  -- modifier nval_num
--    ,RAW_NDC
)
select  m.patient_num, null,m.start_date, isnull(mo.pcori_ndc,'00000000000')
    ,max(supply.nval_num) sup, max(amount.nval_num) amt 
from i2b2fact m inner join pcornet_med mo
on m.concept_cd = mo.c_basecode
inner join pmnENCOUNTER enc on enc.encounterid = m.encounter_Num

    -- jgk bugfix 11/2 - we weren't filtering dispensing events
    inner join (select pcori_basecode,c_fullname,encounter_num,concept_cd from i2b2fact basis
        inner join pmnENCOUNTER enc on enc.patid = basis.patient_num and enc.encounterid = basis.encounter_Num
     join pcornet_med basiscode 
        on basis.modifier_cd = basiscode.c_basecode
        and basiscode.c_fullname='\PCORI_MOD\RX_BASIS\DI\') basis
    on m.encounter_num = basis.encounter_num
    and m.concept_cd = basis.concept_Cd 

    left join #supply supply
    on m.encounter_num = supply.encounter_num
    and m.concept_cd = supply.concept_Cd

    left join #amount amount
    on m.encounter_num = amount.encounter_num
    and m.concept_cd = amount.concept_Cd

group by m.encounter_num ,m.patient_num, m.start_date,  mo.pcori_ndc

end
GO
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- 10. Death - v1 by Jeff Klann, PhD
-- Simple transform only pulls death date from patient dimension, does not rely on an ontology
----------------------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPdeath') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPdeath
go


create procedure OMOPdeath as

begin
insert into pmndeath( 
				patid,			death_date, death_date_impute, death_source,death_match_confidence) 
select  distinct pat.patient_num, pat.death_date, case 
when vital_status_cd like 'X%' then 'B'
when vital_status_cd like 'M%' then 'D'
when vital_status_cd like 'Y%' then 'N'
else 'OT'	
end, 'NI','NI'
from i2b2patient pat
where (pat.death_date is not null or vital_status_cd like 'Z%') and pat.patient_num in (select patid from pmndemographic)

end
go

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- 10. clear Program - includes all tables
----------------------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPclear') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPclear
go

create procedure OMOPclear
as 
begin

DELETE FROM pmndispensing
DELETE FROM pmnprescribing
DELETE FROM pmnprocedure
DELETE FROM pmndiagnosis
DELETE FROM pmncondition
DELETE FROM pmnvital
DELETE FROM pmnenrollment
DELETE FROM pmnlabresults_cm
delete from pmndeath
DELETE FROM pmnencounter
DELETE FROM pmndemographic
DELETE FROM pmnharvest

end
go

----------------------------------------------------------------------------------------------------------------------------------------
-- 11. Load Program
----------------------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPloader') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPloader
go

create procedure OMOPloader
as
begin

exec OMOPclear
exec OMOPharvest
exec OMOPdemographics
exec OMOPencounter
exec OMOPdiagnosis
exec OMOPcondition
exec OMOPprocedure
exec OMOPvital
exec OMOPenroll
exec OMOPlabResultCM
exec OMOPprescribing
exec OMOPdispensing
exec OMOPdeath
exec OMOPreport

end
go

----------------------------------------------------------------------------------------------------------------------------------------
-- 12. Report Results - Version 5.1 by Aaron Abend and Jeff Klann
-- This version is useful to check against i2b2, but consider running the more detailed annotated data dictionary tool also.
----------------------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OMOPreport') AND type in (N'P', N'PC')) DROP PROCEDURE OMOPreport
go

CREATE PROCEDURE [dbo].[OMOPreport] 
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
declare @pmnenroll numeric
declare @pmnvital numeric
declare @pmnlabs numeric
declare @pmnprescribings numeric
declare @pmndispensings numeric
declare @pmncond numeric

declare @pmnencountersd numeric
declare @pmndxd numeric
declare @pmnprocsd numeric
declare @pmnfactsd numeric
declare @pmnenrolld numeric
declare @pmnvitald numeric
declare @pmnlabsd numeric
declare @pmnprescribingsd numeric
declare @pmndispensingsd numeric
declare @pmncondd numeric


declare @runid numeric
begin

select @i2b2Pats =count(*)  from i2b2patient
select @i2b2Encounters=count(*)   from i2b2visit i inner join pmndemographic d on i.patient_num=d.patid
--select @i2b2Facts=count(*)   from i2b2fact where concept_Cd like 'ICD9%'

-- Counts in PMN tables
select @pmnPats=count(*)   from pmndemographic
select @pmnencounters=count(*)   from pmnencounter e 
select @pmndx=count(*)   from pmndiagnosis
select @pmnprocs =count(*)  from pmnprocedure
select @pmncond=count(*) from pmncondition
select @pmnenroll =count(*)  from pmnenrollment
select @pmnvital =count(*)  from pmnvital
select @pmnlabs =count(*)  from pmnlabresults_cm
select @pmnprescribings =count(*)  from pmnprescribing
select @pmndispensings =count(*)  from pmndispensing

-- Distinct patients in PMN tables
select @pmnencountersd=count(distinct patid)  from pmnencounter e 
select @pmndxd=count(distinct patid)   from pmndiagnosis
select @pmnprocsd =count(distinct patid)  from pmnprocedure
select @pmncondd=count(distinct patid) from pmncondition
select @pmnenrolld =count(distinct patid)  from pmnenrollment
select @pmnvitald =count(distinct patid)  from pmnvital
select @pmnlabsd =count(distinct patid)  from pmnlabresults_cm
select @pmnprescribingsd =count(distinct patid)  from pmnprescribing
select @pmndispensingsd =count(distinct patid)  from pmndispensing

-- Distinct patients in i2b2 (unfinished)
select @i2b2pxd=count(distinct patient_num) from i2b2fact fact
 inner join	pcornet_proc pr on pr.c_basecode  = fact.concept_cd   
where pr.c_fullname like '\PCORI\PROCEDURE\%'

select  patient_num, encounter_num, provider_id, concept_cd, start_date, dxsource.pcori_basecode dxsource, dxsource.c_fullname
 into #sourcefact
from i2b2fact factline
inner join pcornet_diag dxsource on factline.modifier_cd =dxsource.c_basecode  
where dxsource.c_fullname like '\PCORI_MOD\CONDITION_OR_DX\%'

select @i2b2dxd=count(distinct factline.patient_num) from i2b2fact factline
 left outer join #sourcefact sf
on	factline.patient_num=sf.patient_num
and factline.encounter_num=sf.encounter_num
and factline.provider_id=sf.provider_id
and factline.concept_cd=sf.concept_Cd
and factline.start_date=sf.start_Date 
 inner join	pcornet_diag dx on dx.c_basecode  = factline.concept_cd   
where dx.c_fullname like '\PCORI\DIAGNOSIS\%' 
and (sf.c_fullname like '\PCORI_MOD\CONDITION_OR_DX\DX_SOURCE\%' or sf.c_fullname is null)

select @i2b2cond=count(distinct factline.patient_num) from i2b2fact factline
 left outer join #sourcefact sf
on	factline.patient_num=sf.patient_num
and factline.encounter_num=sf.encounter_num
and factline.provider_id=sf.provider_id
and factline.concept_cd=sf.concept_Cd
and factline.start_date=sf.start_Date 
 inner join	pcornet_diag dx on dx.c_basecode  = factline.concept_cd   
where dx.c_fullname like '\PCORI\DIAGNOSIS\%' 
and (sf.c_fullname like '\PCORI_MOD\CONDITION_OR_DX\CONDITION_SOURCE\%')


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

select @runid = max(runid) from i2pReport
set @runid = @runid + 1
insert into i2pReport select @runid, getdate(), 'Pats',			@i2b2pats, @i2b2pats,		@pmnpats,			null
insert into i2pReport select @runid, getdate(), 'Enrollment',	@i2b2pats, @i2b2pats,		@pmnenroll,			@pmnenrolld

insert into i2pReport select @runid, getdate(), 'Encounters',	@i2b2Encounters,null,@pmnEncounters,		@pmnEncountersd
insert into i2pReport select @runid, getdate(), 'DX',		null,@i2b2dxd,@pmndx,	@pmndxd
insert into i2pReport select @runid, getdate(), 'PX',		null,@i2b2pxd,@pmnprocs,	@pmnprocsd
insert into i2pReport select @runid, getdate(), 'Condition',		null,@i2b2cond,		@pmncond,	@pmncondd
insert into i2pReport select @runid, getdate(), 'Vital',		null,@i2b2vitald,		@pmnvital,	@pmnvitald
insert into i2pReport select @runid, getdate(), 'Labs',		null,null,		@pmnlabs,	@pmnlabsd
insert into i2pReport select @runid, getdate(), 'Prescribing',		null,null,	@pmnprescribings,	@pmnprescribingsd
insert into i2pReport select @runid, getdate(), 'Dispensing',		null,null,	@pmndispensings,	@pmndispensingsd

select concept 'Data Type',sourceval 'From i2b2',sourcedistinct 'Patients in i2b2' ,  destval 'In PopMedNet', destdistinct 'Patients in PopMedNet' from i2preport where runid=@runid

end
GO

