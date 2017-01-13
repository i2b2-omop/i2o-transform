-- Working code to import OMOP codes into PCORnet ontology
-- Only intended for developers
-- Jeff Klann, PhD

-- Add source code for condition (note: leaves out dxs that end up in measurement or observation
update d set omop_sourcecode=concept_id
from pcornet_diag d inner join concept as c
on concept_code=pcori_basecode
where 
--c.vocabulary_id in ('ICD9CM', 'ICD10CM') and  -- include all vocabs
--c.invalid_reason IS NULL and -- commented out to include deprecated
c.domain_id='Condition'

-- Fill in OMOP basecode for Condition
-- 9200 don't get converted that have a valid sourcecode...
update d set omop_basecode=c1.concept_id
from pcornet_diag d inner join concept c1 on c1.concept_id=d.OMOP_SOURCECODE
inner join   concept_relationship cr   ON  c1.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
inner join concept c2 ON c2.concept_id = cr.concept_id_2
and c2.standard_concept = 'S'
and c2.invalid_reason is null
and c2.domain_id='Condition'

-- Add source code for procedure (note: run with +1 and +0 in substring to catch basecode variations)
update p set omop_sourcecode=concept_id
from pcornet_proc p inner join concept as c
on concept_code=substring(pcori_basecode,charindex(':',pcori_basecode)+1,100)
where 
c.domain_id='Procedure'

-- Fill in OMOP basecode for Procedure
-- 9200 don't get converted that have a valid sourcecode...
update d set omop_basecode=c1.concept_id
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
(select omop_sourcecode from pcornet_diag where OMOP_BASECODE is  null and OMOP_SOURCECODE is not null)
