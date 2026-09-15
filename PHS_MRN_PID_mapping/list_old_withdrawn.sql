/****** Object:  StoredProcedure [dbo].[List_Old_Withdrawn]    Script Date: 7/9/2024 9:16:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ana Holzbach
-- Create date: 7 July 2024
-- Description:	Lists Unrequested (Old/Withdrawn) Patients 
--		        present in the datamart
-- =============================================
CREATE PROCEDURE [dbo].[List_Old_Withdrawn]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	OPEN SYMMETRIC KEY <<redacted>> DECRYPTION
	by certificate EncryptCertificate

	select mm.patient_num, CONVERT(varchar(100),DECRYPTBYKEY(mm.emrn)) as mrn from emrn_mapping mm
	where not exists (select * from eaou_mapping am 
		where CONVERT(varchar(100),DECRYPTBYKEY(am.emrn)) = CONVERT(varchar(100),DECRYPTBYKEY(mm.emrn)) 
		and am.MRN_FACILITY = mm.company_cd);

	CLOSE SYMMETRIC KEY <<redacted>>

END