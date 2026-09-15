/****** Object:  StoredProcedure [dbo].[purge_unrequested_patients_from_i2b2]    Script Date: 7/10/2024 12:19:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================
-- Author:		Kevin Embree
-- Description:	Removes from the datamart patients delivered by the RPDR that were requested for this quarter 

-- Modified:	Ana Holzbach
-- Date:		July 10, 2024
-- Description:	Using encrypted MRNs in emrn_mapping and eaou_mapping
-- ===============================================================================================================
ALTER PROCEDURE [dbo].[purge_unrequested_patients_from_i2b2] 
AS
BEGIN
	SET NOCOUNT ON;

	OPEN SYMMETRIC KEY <<redacted>> DECRYPTION
	by certificate EncryptCertificate

	update eaou_mapping set MRN_FACILITY = 'MEE' where MRN_FACILITY = 'MEEI';
	update eaou_mapping set MRN_FACILITY = 'NSM' where MRN_FACILITY = 'NSMC';

    -- delete observations
	delete from observation_fact
	where patient_num in (
	select mm.patient_num from emrn_mapping mm
where not exists (select * from eaou_mapping am where CONVERT(varchar(100),DECRYPTBYKEY(am.emrn)) = CONVERT(varchar(100),DECRYPTBYKEY(mm.emrn)) 
	and am.MRN_FACILITY = mm.company_cd));

	delete from observation_fact_notes
	where patient_num in (
	select mm.patient_num from emrn_mapping mm
where not exists (select * from eaou_mapping am where CONVERT(varchar(100),DECRYPTBYKEY(am.emrn)) = CONVERT(varchar(100),DECRYPTBYKEY(mm.emrn)) 
	and am.MRN_FACILITY = mm.company_cd));

	delete from visit_dimension
	where patient_num in (
	select mm.patient_num from emrn_mapping mm
where not exists (select * from eaou_mapping am where CONVERT(varchar(100),DECRYPTBYKEY(am.emrn)) = CONVERT(varchar(100),DECRYPTBYKEY(mm.emrn)) 
	and am.MRN_FACILITY = mm.company_cd));

	delete from patient_dimension
	where patient_num in (
	select mm.patient_num from emrn_mapping mm
where not exists (select * from eaou_mapping am where CONVERT(varchar(100),DECRYPTBYKEY(am.emrn)) = CONVERT(varchar(100),DECRYPTBYKEY(mm.emrn)) 
	and am.MRN_FACILITY = mm.company_cd));

CLOSE SYMMETRIC KEY <<redacted>>

END
