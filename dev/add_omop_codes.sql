-- Working code to import OMOP codes into PCORnet ontology
-- Only intended for developers
-- Jeff Klann, PhD
-- Presently only handles mappings of domainX to domainX. Some codes bifurcate and map a Condition to e.g., a Condition and an Observation
-- Additionally only handles the codes of the expected type in the source tree. For example, codes that OMOP labels as Procedure in pcornet_diag have no mapping

-- Do this at the start 
update concept set invalid_reason=null where invalid_reason=''

-- Add source code for condition (note: leaves out dxs that end up in measurement or observation
update d set omop_sourcecode=concept_id
from pcornet_diag d inner join concept as c
on concept_code=pcori_basecode
where 
--c.vocabulary_id in ('ICD9CM', 'ICD10CM') and  -- include all vocabs
--c.invalid_reason IS NULL and -- commented out to include deprecated
c.domain_id='Condition'

-- Fill in OMOP basecode for Condition
-- 27,0000 don't get converted that have a valid sourcecode...
update d set omop_basecode=c2.concept_id
from pcornet_diag d inner join concept c1 on c1.concept_id=d.OMOP_SOURCECODE
inner join   concept_relationship cr   ON  c1.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
inner join concept c2 ON c2.concept_id = cr.concept_id_2
and c2.standard_concept = 'S'
and c2.invalid_reason is null
and c2.domain_id='Condition'

-- Alternately, create new table for OMOP basecode for Condition
-- Can handle multiple target SNOMED mappings this way

select distinct omop_sourcecode,c2.concept_id,c2.domain_id into i2o_mapping
from pcornet_diag d inner join concept c1 on c1.concept_id=d.OMOP_SOURCECODE
inner join   concept_relationship cr   ON  c1.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
inner join concept c2 ON c2.concept_id = cr.concept_id_2
and c2.standard_concept = 'S'
and c2.invalid_reason is null
--and c1.concept_id in (select omop_sourcecode from temp_mds)
and c2.domain_id='Condition'
--and c1.domain_id!=c2.domain_id

-- Add source code for procedure (note: run with +1 and +0 in substring to catch basecode variations)
update p set omop_sourcecode=concept_id
from pcornet_proc p inner join concept as c
on concept_code=substring(pcori_basecode,charindex(':',pcori_basecode)+1,100)
where 
c.domain_id='Procedure'

-- Fill in OMOP basecode for Procedure
update d set omop_basecode=c1.concept_id
from pcornet_proc d inner join concept c1 on c1.concept_id=d.OMOP_SOURCECODE
inner join   concept_relationship cr   ON  c1.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
inner join concept c2 ON c2.concept_id = cr.concept_id_2
and c2.standard_concept = 'S'
and c2.invalid_reason is null
and c2.domain_id='Procedure'

-- Add to mapping table for Procedure
insert into i2o_mapping(omop_sourcecode,concept_id,domain_id)
select omop_sourcecode, c2.concept_id,c2.domain_id
from pcornet_proc d inner join concept c1 on c1.concept_id=d.OMOP_SOURCECODE
inner join   concept_relationship cr   ON  c1.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
inner join concept c2 ON c2.concept_id = cr.concept_id_2
and c2.standard_concept = 'S'
and c2.invalid_reason is null
and c2.domain_id='Procedure'

--- WORKSPACE ------

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
inner join   concept_relationship cr   ON  c1.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
inner join concept c2 ON c2.concept_id = cr.concept_id_2) x group by PCORI_BASECODE) x where c>1

and c2.domain_id='Condition'
where omop_basecode is null and omop_sourcecode is not null

select distinct vocabulary_id,domain_id,invalid_reason from concept

select * from PCORNET_DIAG where omop_basecode is null

select * from pcornet_diag where m_applied_path!='@'

select  condition_type_concept_id, count(*) from condition_occurrence group by condition_type_concept_id


select * from pcornet_diag where omop_sourcecode=omop_basecode
