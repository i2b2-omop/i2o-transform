CREATE TABLE [dbo].[i2o_mapping]  ( 
	[omop_sourcecode]	bigint NULL,
	[concept_id]     	int NOT NULL,
	[domain_id]      	varchar(20) NOT NULL 
	)
ON [PRIMARY]
	WITH (DATA_COMPRESSION = NONE)
GO


CREATE TABLE [dbo].[i2o_unitsmap]  ( 
	[units_name]      	varchar(255) NOT NULL,
	[concept_id]      	int NOT NULL,
	[standard_concept]	varchar(1) NULL 
	)
ON [PRIMARY]
	WITH (DATA_COMPRESSION = NONE)
GO
