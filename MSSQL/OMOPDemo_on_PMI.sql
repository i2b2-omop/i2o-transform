USE [PMI]
GO

/****** Object:  StoredProcedure [dbo].[OMOPdemographics]    Script Date: 7/18/2017 10:47:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[OMOPdemographics] as 

DECLARE @sqltext NVARCHAR(4000);
DECLARE @batchid numeric
declare getsql cursor local for 
--1 --  S,R,NH
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,birth_datetime,gender_concept_id,ethnicity_concept_id,race_concept_id) '+ --person(raw_sex,PATID, BIRTH_DATE, BIRTH_TIME,SEX, HISPANIC, RACE) 
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
select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,birth_datetime,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
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
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,birth_datetime,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
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
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,birth_datetime,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
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
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,birth_datetime,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
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
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,birth_datetime,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
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
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,birth_datetime,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
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
	select 'insert into person(gender_source_value,race_source_value,ethnicity_source_value,person_id,year_of_birth,month_of_birth,day_of_birth,birth_datetime,gender_concept_id,ethnicity_concept_id,race_concept_id) '+
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
GO

