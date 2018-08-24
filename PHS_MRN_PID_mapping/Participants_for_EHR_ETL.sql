-----------------------------------------------------------------------------------
-- Description: Joins 'Full Participants' from health pro against
--              with consented AOU participants in constrack that RAs have validated a picture id for
--              with list of AOU participants that have had there identity(Firstname, lastname, dob) validated (by Alex Hille)
-- Output: A mapping of constrack consented MRNs to AOU participant ids of those individuals that will have there EHRs transformed and delivered
-- Authored by: Kevin Embree
-- Authored on: August 21st, 2018
------------------------------------------------------------------------------------

select health_pro_data.pmi_id, validated_ids_1.mrn, validated_ids_1.facility 
from health_pro_data 
join (select si.study_id as participant_id, m.mrn, mf.name as facility from patient_consent pc 
    join mrn m on pc.mrn_fk = m.id 
    join mrn_facility mf on m.mrn_facility_fk = mf.id 
    join study_id si on m.patient_fk = si.patient_fk 
    join irb_protocol irb on si.irb_protocol_fk = irb.id and irb.protocol_number = '2017P000508' 
    join consent_form cf on pc.consent_form_fk = cf.id and cf.name like 'ALL OF US%' 
    join pt_consent_status pcs on pc.id = pcs.patient_consent_fk 
    join consent_status_single css on pcs.id = css.id 
    join question q on pcs.question_fk = q.id 
    join question_type qt on q.question_type_fk = qt.id and qt.type = 'Consent' 
    join choice c on css.choice_fk = c.id and c.text = 'Consented' 
    join pt_consent_status pcs2 on pc.id = pcs2.patient_consent_fk 
    join question q2 on pcs2.question_fk = q2.id 
    join question_tag qt2 on qt2.question_fk = q2.id 
    join tag t on qt2.tag_fk = t.id and t.code = 'VID' 
    join consent_status_single css2 on pcs2.id = css2.id 
    join choice c2 on css2.choice_fk = c2.id and c2.text = 'Yes') validated_ids_1 on validated_ids_1.participant_id = health_pro_data.pmi_id 
join aou_validated_id aou_vid on aou_vid.pmi_id = health_pro_data.pmi_id and aou_vid.id_validation_confirmation = 1 
where participant_status = 'Full Participant' and WITHDRAWAL_STATUS = 0;