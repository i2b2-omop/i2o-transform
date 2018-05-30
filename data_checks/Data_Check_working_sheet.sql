select * from observation_fact;


select * from drug_exposure;

select * from ;

select * from observation_fact where location_cd = 'LMA510';

select * from person;

select * from visit_occurrence;
select visit_type_concept_id, count(*) from visit_occurrence group by visit_type_concept_id;

select visit_source_value, count(*) from visit_occurrence group by visit_source_value;
-- Vist_type_concept_id doesn't change with the source value of 'O', 'I', '@'
-- Only one value is ever used 44818518 that doesn't make sense

select * from condition_occurrence;
select condition_concept_id, count(*) from condition_occurrence group by condition_concept_id;
select count(*) from condition_occurrence;
-- almost 600K of the conditions 881K are converted to nothing


select * from procedure_occurrence;
select count(*), procedure_concept_id from procedure_occurrence group by procedure_concept_id order by count(*);
select count(*), procedure_concept_id from procedure_occurrence group by procedure_concept_id order by procedure_concept_id;

select * from drug_exposure;
--415438
select drug_concept_id, count(*) from drug_exposure group by drug_concept_id order by count(*);
--21174
select * from drug_exposure where drug_exposure_start_datetime > drug_exposure_end_datetime;
--count 75947
select count(*), dose_unit_source_value from drug_exposure group by dose_unit_source_value order by count(*);
-- 
select * from measurement;
--985955
-- measurement_datetime is wrong it is has date as 1900-01-01
select count(*), measurement_concept_id from measurement group by measurement_concept_id order by count(*); 
-- Unknown = 158927
-- Why do a bunch of the source values have E prefix? Those are not being converted. 16% not converted

--insert into drug_strength (drug_concept_id, ingredient_concept_id, amount_value, amount_unit_concept_id, numerator_value, numerator_unit_concept_id, denominator_value, denominator_unit_concept_id, box_size, valid_start_date, valid_end_date, invalid_reason)
--select drug_concept_id, ingredient_concept_id, amount_value, amount_unit_concept_id, numerator_value, numerator_unit_concept_id, denominator_value, denominator_unit_concept_id, box_size, convert(date, valid_start_date), convert(date, valid_end_date), invalid_reason from drug_strength_varchar;

--insert into concept (concept_id, concept_name, domain_id, vocabulary_id, concept_class_id, standard_concept, concept_code, valid_start_date, valid_end_date, invalid_reason)
--select concept_id, concept_name, domain_id, vocabulary_id, concept_class_id, standard_concept, concept_code, convert(date, valid_start_date), convert(date, valid_end_date), invalid_reason from concept_varchar4;

--insert into concept_relationship (concept_id_1, concept_id_2, relationship_id, valid_start_date, valid_end_date, invalid_reason)
--select concept_id_1, concept_id_2, relationship_id, convert(date, valid_start_date), convert(date, valid_end_date), invalid_reason from concept_relationship_varchar;


 select * from  condition_occurrence where condition_concept_id = 0;
 --ICD9:
  select * from  condition_occurrence where condition_concept_id = 0 and condition_source_value like 'ICD9:%';
  select substring(condition_source_value, 6, 10) from  condition_occurrence where condition_concept_id = 0 and condition_source_value like 'ICD9:%';
  select count(*) from  condition_occurrence where condition_concept_id = 0 and condition_source_value like 'ICD9%';
  --538549
 select * from concept c where concept_code = 'V76.12';

 select count(*), domain_id from concept c group by domain_id;

 select c.concept_id from concept c 
 join condition_occurrence co on c.concept_code = substring(co.condition_source_value, 6, 20) and co.condition_source_value like 'ICD9%';
 --712265

  select c.* from concept c 
 join condition_occurrence co on c.concept_code = substring(co.condition_source_value, 6, 20) and co.condition_source_value like 'ICD9%'
 where c.domain_id like 'Condition%';
 --498789


 select * from pcornet_diag as diag where (diag.c_fullname not like '\PCORI\DIAGNOSIS\10\%' or
  ( not ( diag.pcori_basecode like '[V]%' and diag.c_fullname not like '\PCORI\DIAGNOSIS\10\([V]%\([V]%\([V]%' )
  and not ( diag.pcori_basecode like '[E]%' and diag.c_fullname not like '\PCORI\DIAGNOSIS\10\([E]%\([E]%\([E]%' ) 
  and not (diag.c_fullname like '\PCORI\DIAGNOSIS\10\%' and diag.pcori_basecode like '[0-9]%') )) ;


   select * from pcornet_diag as diag where (diag.c_fullname not like '\PCORI\DIAGNOSIS\10\%' or
  ( not ( diag.pcori_basecode like '[V]%' and diag.c_fullname not like '\PCORI\DIAGNOSIS\10\([V]%\([V]%\([V]%' )
  and not ( diag.pcori_basecode like '[E]%' and diag.c_fullname not like '\PCORI\DIAGNOSIS\10\([E]%\([E]%\([E]%' ) 
  and not (diag.c_fullname like '\PCORI\DIAGNOSIS\10\%' and diag.pcori_basecode like '[0-9]%') ))
  and diag.OMOP_SOURCECODE =0 ;



 select * from concept;

  select count(*), vocabulary_id from concept group by vocabulary_id;

  select * from concept c
  join concept_relationship cr on cr.concept_id_1 = c.concept_id and cr.relationship_id like '%SNOMED%'
   where c.vocabulary_id like 'ICD9%';
  --23329  ---103958

    select * from concept c 
 join condition_occurrence co on c.concept_code = substring(co.condition_source_value, 6, 20) and co.condition_source_value like 'ICD9%'
  join concept_relationship cr on cr.concept_id_1 = c.concept_id and cr.relationship_id = 'Maps to'
  join concept jc on jc.concept_id = cr.concept_id_2 and jc.standard_concept = 'S'
   where c.vocabulary_id like 'ICD9%' and c.domain_id like 'Condition%';

   select distinct omop_sourcecode,c2.concept_id,c2.domain_id 
from pcornet_diag d inner join concept c1 on c1.concept_id=d.OMOP_SOURCECODE
inner join  concept_relationship cr   ON  c1.concept_id = cr.concept_id_1 and cr.relationship_id = 'Maps to'
inner join concept c2 ON c2.concept_id =cr.concept_id_2
and c2.standard_concept ='S'
and c2.invalid_reason is null
--and c1.concept_id in (select omop_sourcecode from temp_mds)
and c2.domain_id='Condition'
-- zero records

select * from observation_fact fact
join pcornet_diag pd on fact.concept_cd = pd.c_basecode and pd.c_path not like '\PCORI\DIAGNOSIS\10%';
--540346



