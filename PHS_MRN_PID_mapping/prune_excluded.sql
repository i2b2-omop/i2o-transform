/****** Object:  StoredProcedure [dbo].[prune_excluded]    Script Date: 7/10/2024 12:39:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ana Holzbach
-- Create date: September 7th 2022
-- Description:	Removes participants who are deactivated and who have rescinded EHR consent, according to HealthPro data
--              Based on prune_deactivated by K. Embree

-- Modified:	Ana Holzbach
-- Date:		July 10, 2024
-- Description: Using encrypted MRNs in emrn_mapping and eaou_mapping
-- =============================================
ALTER PROCEDURE [dbo].[prune_excluded] 
	
AS
BEGIN
	SET NOCOUNT ON;

	OPEN SYMMETRIC KEY <<redacted>> DECRYPTION
	by certificate EncryptCertificate

	DECLARE @patient_num int
	,@pmi_id nvarchar
	,@ehr_consent_status tinyint
	,@ehr_consent_date date
	,@deactivated tinyint
	,@date_of_deactivation date

	DECLARE exclusions CURSOR READ_ONLY
      FOR  SELECT mm.patient_num, am.pmi_id, e.ehr_consent_status, e.deactivated, e.date_of_deactivation FROM excluded e
			join eaou_mapping am on e.pmi_id = am.pmi_id
			join emrn_mapping mm on am.MRN_FACILITY = mm.company_cd and CONVERT(varchar(100),DECRYPTBYKEY(am.emrn)) = CONVERT(varchar(100),DECRYPTBYKEY(mm.emrn));
 
      --OPEN CURSOR
      OPEN exclusions
 
      --FETCH excluded participant
      FETCH NEXT FROM exclusions INTO @patient_num, @pmi_id, @ehr_consent_status, @deactivated, @date_of_deactivation
 
      --LOOP UNTIL RECORDS ARE AVAILABLE.
      WHILE @@FETCH_STATUS = 0
      BEGIN
			BEGIN TRANSACTION
				delete from observation_fact_notes where patient_num = @patient_num and @deactivated = 1 and start_date > @date_of_deactivation;
				delete from observation_fact where patient_num = @patient_num and @deactivated = 1 and start_date > @date_of_deactivation;
				delete from visit_dimension where patient_num = @patient_num and @deactivated = 1 and start_date > @date_of_deactivation;

				delete from observation_fact_notes where patient_num = @patient_num and @ehr_consent_status = 0;
				delete from observation_fact where patient_num = @patient_num and @ehr_consent_status = 0;
				delete from visit_dimension where patient_num = @patient_num and @ehr_consent_status = 0;
			COMMIT

			PRINT N'Pruned patient_num: ' + CAST(@patient_num as nvarchar) + ' pmi_id: ' + @pmi_id;

			FETCH NEXT FROM exclusions INTO @patient_num, @pmi_id, @ehr_consent_status, @deactivated, @date_of_deactivation
		END

		CLOSE SYMMETRIC KEY <<redacted>>
END
