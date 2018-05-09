-- Working code to import OMOP codes into PCORnet ontology
-- Only intended for developers
-- Jeff Klann, PhD
-- Presently only handles mappings of domainX to domainX. Some codes bifurcate and map a Condition to e.g., a Condition and an Observation
-- Additionally only handles the codes of the expected type in the source tree. For example, codes that OMOP labels as Procedure in pcornet_diag have no mapping
-- Works for condition, procedure, lab measurements, and vital measurements. Requires empty c_omopsourcecode columns in ontology tables (bigint) and manually
--   filled-in i_loinc in pcornet_vital 
-- Do this at the start 
update concept set invalid_reason=null where invalid_reason=''

-- Add source code for condition (note: leaves out dxs that end up in measurement or observation
-- Note: change PMI.. to your vocabulary db
update d set omop_sourcecode=concept_id
from pcornet_diag d inner join PMI..concept as c
on concept_code=substring(pcori_basecode,charindex(':',pcori_basecode)+1,200) -- jgk 1/15/18: old ontologies had ICD9: in pcori_basecode and it needs to be stripped
where 
--c.vocabulary_id in ('ICD9CM', 'ICD10CM') and  -- include all vocabs
--c.invalid_reason IS NULL and -- commented out to include deprecated
c.domain_id='Condition'

-- Fill in OMOP basecode for Condition
-- 27,0000 don't get converted that have a valid sourcecode...
--update d set omop_basecode=c2.concept_id
--from pcornet_diag d inner join concept c1 on c1.concept_id=d.OMOP_SOURCECODE
--inner join  concept_relationship cr   ON  c1.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
--inner join conceptc2 ON c2.concept_id =cr.concept_id_2
--and c2.standard_concept ='S'
--and c2.invalid_reason is null
--and c2.domain_id='Condition'

-- The New Way - create new table for OMOP basecode for Condition
-- Can handle multiple target SNOMED mappings this way
DROP TABLE i2o_mapping
GO
select distinct omop_sourcecode,c2.concept_id,c2.domain_id into i2o_mapping
from pcornet_diag d inner join concept c1 on c1.concept_id=d.OMOP_SOURCECODE
inner join  concept_relationship cr   ON  c1.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
inner join concept c2 ON c2.concept_id =cr.concept_id_2
and c2.standard_concept ='S'
and c2.invalid_reason is null
--and c1.concept_id in (select omop_sourcecode from temp_mds)
and c2.domain_id='Condition'
--and c1.domain_id!=c2.domain_id
GO

-- Add source code for procedure (note: run with +1 and +0 in substring to catch basecode variations)
-- jgk 01-15-18: Not necessary, numbering is 1-based and not found returns 0
update p set omop_sourcecode=concept_id
from pcornet_proc p inner join PMI..concept as c
on concept_code=substring(pcori_basecode,charindex(':',pcori_basecode)+1,100)
where 
c.domain_id='Procedure' 

-- Fill in OMOP basecode for Procedure
-- update d set omop_basecode=c1.concept_id
-- from pcornet_proc d inner join concept c1 on c1.concept_id=d.OMOP_SOURCECODE
-- inner join  concept_relationship cr   ON  c1.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
-- inner join concept c2 ON c2.concept_id =cr.concept_id_2
-- and c2.standard_concept ='S'
-- and c2.invalid_reason is null
-- and c2.domain_id='Procedure'

-- New way: Add to mapping table for Procedure
insert into i2o_mapping(omop_sourcecode,concept_id,domain_id)
select omop_sourcecode, c2.concept_id,c2.domain_id
from pcornet_proc d inner join concept c1 on c1.concept_id=d.OMOP_SOURCECODE
inner join  concept_relationship cr   ON  c1.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
inner join concept c2 ON c2.concept_id =cr.concept_id_2
and c2.standard_concept ='S'
and c2.invalid_reason is null
and c2.domain_id='Procedure'

-- Add source code for lab 
update p set omop_sourcecode=concept_id
from pcornet_lab p inner join concept as c
on concept_code=pcori_basecode
where 
c.domain_id='Measurement'

-- Note that labs don't have any bifurcation when going to standard codes - though only 8 of our labs are non-standard at present
insert into i2o_mapping(omop_sourcecode,concept_id,domain_id)
select omop_sourcecode, c2.concept_id,c2.domain_id
from pcornet_lab d inner join concept c1 on c1.concept_id=d.OMOP_SOURCECODE
inner join  concept_relationship cr   ON  c1.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
inner join concept c2 ON c2.concept_id =cr.concept_id_2
and c2.standard_concept ='S'
and c2.invalid_reason is null
and c2.domain_id='Measurement'

-- Create a units_cd conversion table
drop table i2o_unitsmap
GO
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
Go

-- Now, vitals! These all map to standard codes so we don't use the omop_mapping table
update p set omop_sourcecode=concept_id
from pcornet_vital p inner join concept as c
on concept_code=p.i_loinc
where 
c.domain_id='Measurement'

-- Add source code for drug expose
update p set omop_sourcecode=concept_id
from pcornet_med p inner join concept as c
on concept_code=pcori_cui
where 
c.domain_id='Drug'

-- New way: Add to mapping table for Drug
insert into i2o_mapping(omop_sourcecode,concept_id,domain_id)
select omop_sourcecode, c2.concept_id,c2.domain_id
from pcornet_med d inner join concept c1 on c1.concept_id=d.OMOP_SOURCECODE
inner join  concept_relationship cr   ON  c1.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
inner join concept c2 ON c2.concept_id =cr.concept_id_2
and c2.standard_concept ='S'
and c2.invalid_reason is null
and c2.domain_id='Drug'

-- Procedure dumps a lot into observation and measurement. Add a column with target table and then add source codes to procedures.
ALTER TABLE [dbo].[pcornet_proc]
	ADD [OMOP_TARGETTABLE] varchar(35) NULL
GO
update pcornet_proc set omop_targettable='PROCEDURE_OCCURRENCE' where omop_sourcecode is not null and OMOP_TARGETTABLE IS NULL
GO
update p set omop_sourcecode=concept_id,omop_targettable=domain_id
from pcornet_proc p inner join concept as c
on concept_code=substring(pcori_basecode,charindex(':',pcori_basecode)+1,100)
where 
vocabulary_id in ('CPT4','HCPCS') and c.domain_id!='Procedure'
GO

--- WORKSPACE -----
/*

-- Partners specific, find changes between old and newer ontology mapping
select c.c_fullname,c.c_name,c.pcori_basecode,o.PCORI_BASECODE from pcornet_master_vw c inner join pcori_mart_112016..pcornet_master_vw o on o.C_FULLNAME=c.c_fullname
 where (c.PCORI_BASECODE!=o.PCORI_BASECODE or ((c.pcori_basecode is null or c.pcori_basecode='') and o.pcori_basecode is not null))
 and o.pcori_basecode not like 'LP%' and c.c_fullname not like '\PCORI_MOD%' and o.PCORI_BASECODE!='@'
 
 update c set c.PCORI_BASECODE=o.PCORI_BASECODE 
from scilhs_lab c
inner join pcori_mart_112016..scilhs_lab o on o.C_FULLNAME=c.c_fullname
where c.PCORI_BASECODE!=o.PCORI_BASECODE  and o.pcori_basecode not like 'LP%' and c.c_fullname not like '\PCORI_MOD%' and o.PCORI_BASECODE!='@'


--- Loook for missing pocedure omop codes
select * from pcornet_proc where OMOP_SOURCECODE is  null and c_synonym_cd='N'--and 
select * from pcornet_proc where OMOP_TARGETTABLE!='PROCEDURE_OCCURRENCE'
select * from concept where vocabulary_id='CPT4' and concept_code in ('31505','44128','25248') 
select * from pcornet_proc where substring(pcori_basecode,charindex(':',pcori_basecode)+1,100)  in ('31505','44128','25248')


select * from i2o_mapping where domain_id='Drug'


select c.concept_name,c2.concept_name
from concept as c
inner join concept_relationship r on c.concept_id  =r.concept_id_1
inner join concept as c2 on r.concept_id_2=c2.concept_id
where c.vocabulary_id='UCUM' and 
           c.standard_concept='S' and 
           c.domain_id='Unit'
and c.concept_id!=r.concept_id_2

select * from concept_relationship where domain_id_2="Unit"


select distinct units_cd,concept_name,concept_id,standard_concept from i2b2fact f
 inner join concept c on f.units_cd=c.concept_name
 and c.domain_id='Unit'
where c2.vocabulary_id='UCUM' and 
      --c2.standard_concept='S' and 
      c2.domain_id='Unit'

select concept_id,concept_code,invalid_reason,domain_id,concept_name
from pcornet_proc d inner join concept as c
on concept_code=pcori_basecode
where 
--c.vocabulary_id in ('ICD9CM', 'ICD10CM') and 
omop_sourcecode is null and c.domain_id='Condition'

select pcori_basecode,substring(pcori_basecode,charindex(':',pcori_basecode)+1,100) from pcornet_proc

select * from concept_relationship cr inner join concept c on cr.concept_id_2=c.concept_id where c.standard_concept='S' and concept_id_1 in 
(select omop_sourcecode from pcornet_proc where OMOP_BASECODE is  null and OMOP_SOURCECODE is not null)

select pcori_basecode from
(select PCORI_BASECODE,count(*) c from
(select distinct pcori_basecode,c2.concept_id from PCORNET_diag d inner join concept c1 on c1.concept_id=d.OMOP_SOURCECODE
inner join  concept_relationship cr   ON  c1.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
inner join conceptc2 ON c2.concept_id =cr.concept_id_2) x group by PCORI_BASECODE) x where c>1

and c2.domain_id='Condition'
where omop_basecode is null and omop_sourcecode is not null

select distinct vocabulary_id,domain_id,invalid_reason from concept

select * from PCORNET_DIAG where omop_basecode is null

select * from pcornet_diag where m_applied_path!='@'

select  condition_type_concept_id, count(*) from condition_occurrence group by condition_type_concept_id


select * from pcornet_diag where omop_sourcecode=omop_basecode

select x.person_id,x.visit_occurrence_id,c.condition_source_concept_id,c.condition_concept_id,p.concept_name from
(select person_id,visit_occurrence_id,count(*) c from condition_occurrence group by person_id,visit_occurrence_id) x
inner join condition_occurrence c on c.visit_occurrence_id=x.visit_occurrence_id
inner join concept p on p.concept_id=c.condition_concept_id
where x.c>1 and p.domain_id='Condition' order by x.person_id,x.visit_occurrence_id,c.condition_source_concept_id

-- Distinct concept class mappings
select distinct c1.vocabulary_id,c1.standard_concept,cr.relationship_id,c2.vocabulary_id,c2.standard_concept
from pcornet_proc d inner join concept c1 on c1.concept_id=d.OMOP_SOURCECODE
inner join  concept_relationship cr   ON  c1.concept_id = cr.concept_id_1 --and (cr.relationship_id = 'Maps to' or cr.relationship_id = 'ICD9P - SNOMED eq')
inner join concept�c2 ON c2.concept_id =cr.concept_id_2
and c2.standard_concept ='S'
and c2.invalid_reason is null
and c2.domain_id='Procedure'
--and c2.concept_class_id!=c1.concept_class_id

select distinct concept_class_id from concept2 where concept_class_id not in (select concept_class_id from concept)

-- Concept relationship types
select distinct omop_sourcecode, relationship_id from pcornet_proc p 
inner join concept_relationship cr on cr.concept_id_1=omop_sourcecode where c_fullname like '%\09\%'
 
-- Sourecode types
select distinct omop_sourcecode, concept_class_id from pcornet_proc p 
inner join concept cr on cr.concept_id=omop_sourcecode where c_fullname like '%\09\%'


select *  from concept where  
--domain_id='Procedure'
--  concept_code like '___.%' 
concept_class_id like '4-dig%'

select distinct vocabulary_id from concept

select distinct c1.concept_class_id,relationship_id,c2.concept_class_id
from pcornet_proc d inner join concept c1 on c1.concept_id=d.OMOP_SOURCECODE
inner join  concept_relationship cr   ON  c1.concept_id = cr.concept_id_1
inner join concept�c2 ON c2.concept_id =cr.concept_id_2
where c_fullname like '%\09\%' 
*/