-- Modify the PCORnet ontology to be compatible with the new version of the OMOP transform, i2o 2020
-- Run this from your i2b2 database that has the mapped PCORnet ontology!
-- Jeff Klann PhD, April 2020

-- Set up the extra columns i_stdcode, i_stddomain for labs
ALTER TABLE [dbo].[pcornet_lab]
	ADD [i_stdcode] varchar(50) NULL, 
	[i_stddomain] varchar(25) NULL
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
