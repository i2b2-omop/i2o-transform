--------------------------------------------------------------------------------------------------------
-- Description: Prep the local PCORnet ontology for use in the OMOP transformation
--				Run this from your i2b2 database that has the mapped PCORnet ontology!
-- Authored By: Jeff Klann PhD, April 2020
-- Updated on: 2020-12-07 by Kevin Embree 
--              To include i_unit column to maintain compatibility with PHS specific logic
--------------------------------------------------------------------------------------------------------

-- Set up the extra columns i_stdcode, i_stddomain, i_unit for labs
ALTER TABLE [dbo].[pcornet_lab]
	ADD [i_stdcode] varchar(50) NULL, 
	[i_stddomain] varchar(25) NULL,
	[i_unit] varchar(25) NULL
GO
CREATE NONCLUSTERED INDEX [pcornetlab_stdcode]
	ON [dbo].[pcornet_lab]([i_stdcode])
GO
update m set i_stdcode=pcori_basecode from pcornet_lab m
GO
update m set i_stddomain='LOINC',i_stdcode=pcori_basecode from pcornet_lab m where pcori_basecode like '%-%'
GO

-- Set up the extra columns i_stdcode, i_stddomain for drugs
ALTER TABLE [dbo].[pcornet_med]
	ADD [i_stdcode] varchar(50) NULL, 
	[i_stddomain] varchar(25) NULL
GO
CREATE NONCLUSTERED INDEX [pcornetmed_stdcode]
	ON [dbo].[pcornet_med]([i_stdcode])
GO
update m set i_stdcode=pcori_basecode from pcornet_med m
GO
update m set i_stddomain='RxNorm',i_stdcode=pcori_cui from pcornet_med m where PCORI_CUI is not null
GO
update m set i_stddomain='NDC',i_stdcode=pcori_ndc from pcornet_med m where PCORI_NDC is not null
GO
