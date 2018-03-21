CREATE TABLE [dbo].[SCILHS_demo]  ( 
	[C_HLEVEL]          	int NOT NULL,
	[C_FULLNAME]        	varchar(900) NOT NULL,
	[C_NAME]            	varchar(2000) NOT NULL,
	[C_SYNONYM_CD]      	char(1) NOT NULL,
	[C_VISUALATTRIBUTES]	char(3) NOT NULL,
	[C_TOTALNUM]        	int NULL,
	[C_BASECODE]        	varchar(450) NULL,
	[C_METADATAXML]     	text NULL,
	[C_FACTTABLECOLUMN] 	varchar(50) NOT NULL,
	[C_TABLENAME]       	varchar(50) NOT NULL,
	[C_COLUMNNAME]      	varchar(50) NOT NULL,
	[C_COLUMNDATATYPE]  	varchar(50) NOT NULL,
	[C_OPERATOR]        	varchar(10) NOT NULL,
	[C_DIMCODE]         	varchar(900) NOT NULL,
	[C_COMMENT]         	text NULL,
	[C_TOOLTIP]         	varchar(1500) NULL,
	[M_APPLIED_PATH]    	varchar(700) NOT NULL,
	[UPDATE_DATE]       	datetime NULL,
	[DOWNLOAD_DATE]     	datetime NULL,
	[IMPORT_DATE]       	datetime NULL,
	[SOURCESYSTEM_CD]   	varchar(50) NULL,
	[VALUETYPE_CD]      	varchar(50) NULL,
	[M_EXCLUSION_CD]    	varchar(25) NULL,
	[C_PATH]            	varchar(700) NULL,
	[C_SYMBOL]          	varchar(50) NULL,
	[PCORI_BASECODE]    	varchar(450) NULL,
	[OMOP_BASECODE]     	varchar(450) NULL,
	[OMOP_SOURCECODE]   	bigint NULL,
	[i_flags]           	varchar(10) NULL 
	)
ON [PRIMARY]
	TEXTIMAGE_ON [PRIMARY]
	WITH (DATA_COMPRESSION = NONE)
GO
CREATE NONCLUSTERED INDEX [SCILHS_demo_hlevel_IDX]
	ON [dbo].[SCILHS_demo]([C_HLEVEL])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_demo_appliedpath__IDX]
	ON [dbo].[SCILHS_demo]([M_APPLIED_PATH])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_demo_synonym__IDX]
	ON [dbo].[SCILHS_demo]([C_SYNONYM_CD])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_demo_FULLNAME_IDX]
	ON [dbo].[SCILHS_demo]([C_FULLNAME])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_demo_exclusion__IDX]
	ON [dbo].[SCILHS_demo]([M_EXCLUSION_CD])
	ON [PRIMARY]
GO



CREATE TABLE [dbo].[SCILHS_diag]  ( 
	[C_HLEVEL]          	int NULL,
	[C_FULLNAME]        	varchar(700) NULL,
	[C_NAME]            	varchar(2000) NULL,
	[C_SYNONYM_CD]      	char(1) NULL,
	[C_VISUALATTRIBUTES]	char(3) NULL,
	[C_TOTALNUM]        	int NULL,
	[C_BASECODE]        	varchar(50) NULL,
	[C_METADATAXML]     	text NULL,
	[C_FACTTABLECOLUMN] 	varchar(50) NULL,
	[C_TABLENAME]       	varchar(50) NULL,
	[C_COLUMNNAME]      	varchar(50) NULL,
	[C_COLUMNDATATYPE]  	varchar(50) NULL,
	[C_OPERATOR]        	varchar(10) NULL,
	[C_DIMCODE]         	varchar(700) NULL,
	[C_COMMENT]         	text NULL,
	[C_TOOLTIP]         	varchar(900) NULL,
	[M_APPLIED_PATH]    	varchar(700) NULL,
	[UPDATE_DATE]       	datetime NULL,
	[DOWNLOAD_DATE]     	datetime NULL,
	[IMPORT_DATE]       	datetime NULL,
	[SOURCESYSTEM_CD]   	varchar(50) NULL,
	[VALUETYPE_CD]      	varchar(50) NULL,
	[M_EXCLUSION_CD]    	varchar(25) NULL,
	[C_PATH]            	varchar(700) NULL,
	[C_SYMBOL]          	varchar(50) NULL,
	[PCORI_BASECODE]    	varchar(50) NULL,
	[OMOP_SOURCECODE]   	bigint NULL,
	[i_flags]           	varchar(10) NULL 
	)
ON [PRIMARY]
	TEXTIMAGE_ON [PRIMARY]
	WITH (DATA_COMPRESSION = NONE)
GO
CREATE NONCLUSTERED INDEX [SCILHS_diag_synonym__IDX]
	ON [dbo].[SCILHS_diag]([C_SYNONYM_CD])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_diag_FULLNAME_IDX]
	ON [dbo].[SCILHS_diag]([C_FULLNAME])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_diag_appliedpath__IDX]
	ON [dbo].[SCILHS_diag]([M_APPLIED_PATH])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_diag_hlevel_IDX]
	ON [dbo].[SCILHS_diag]([C_HLEVEL])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_diag_exclusion__IDX]
	ON [dbo].[SCILHS_diag]([M_EXCLUSION_CD])
	ON [PRIMARY]
GO



CREATE TABLE [dbo].[SCILHS_enc]  ( 
	[C_HLEVEL]          	int NOT NULL,
	[C_FULLNAME]        	varchar(900) NOT NULL,
	[C_NAME]            	varchar(2000) NOT NULL,
	[C_SYNONYM_CD]      	char(1) NOT NULL,
	[C_VISUALATTRIBUTES]	char(3) NOT NULL,
	[C_TOTALNUM]        	int NULL,
	[C_BASECODE]        	varchar(450) NULL,
	[C_METADATAXML]     	text NULL,
	[C_FACTTABLECOLUMN] 	varchar(50) NOT NULL,
	[C_TABLENAME]       	varchar(50) NOT NULL,
	[C_COLUMNNAME]      	varchar(50) NOT NULL,
	[C_COLUMNDATATYPE]  	varchar(50) NOT NULL,
	[C_OPERATOR]        	varchar(10) NOT NULL,
	[C_DIMCODE]         	varchar(900) NOT NULL,
	[C_COMMENT]         	text NULL,
	[C_TOOLTIP]         	varchar(1500) NULL,
	[M_APPLIED_PATH]    	varchar(700) NOT NULL,
	[UPDATE_DATE]       	datetime NULL,
	[DOWNLOAD_DATE]     	datetime NULL,
	[IMPORT_DATE]       	datetime NULL,
	[SOURCESYSTEM_CD]   	varchar(50) NULL,
	[VALUETYPE_CD]      	varchar(50) NULL,
	[M_EXCLUSION_CD]    	varchar(25) NULL,
	[C_PATH]            	varchar(700) NULL,
	[C_SYMBOL]          	varchar(50) NULL,
	[PCORI_BASECODE]    	varchar(450) NULL,
	[C_TOOLTIP_LF]      	varchar(1500) NULL,
	[OMOP_BASECODE]     	varchar(450) NULL,
	[OMOP_SOURCECODE]   	bigint NULL,
	[i_flags]           	varchar(10) NULL 
	)
ON [PRIMARY]
	TEXTIMAGE_ON [PRIMARY]
	WITH (DATA_COMPRESSION = NONE)
GO
CREATE NONCLUSTERED INDEX [SCILHS_enc_exclusion__IDX]
	ON [dbo].[SCILHS_enc]([M_EXCLUSION_CD])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_enc_hlevel_IDX]
	ON [dbo].[SCILHS_enc]([C_HLEVEL])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_enc_appliedpath__IDX]
	ON [dbo].[SCILHS_enc]([M_APPLIED_PATH])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_enc_FULLNAME_IDX]
	ON [dbo].[SCILHS_enc]([C_FULLNAME])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_enc_synonym__IDX]
	ON [dbo].[SCILHS_enc]([C_SYNONYM_CD])
	ON [PRIMARY]
GO



CREATE TABLE [dbo].[SCILHS_enroll]  ( 
	[C_HLEVEL]          	int NOT NULL,
	[C_FULLNAME]        	varchar(900) NOT NULL,
	[C_NAME]            	varchar(2000) NOT NULL,
	[C_SYNONYM_CD]      	char(1) NOT NULL,
	[C_VISUALATTRIBUTES]	char(3) NOT NULL,
	[C_TOTALNUM]        	int NULL,
	[C_BASECODE]        	varchar(450) NULL,
	[C_METADATAXML]     	text NULL,
	[C_FACTTABLECOLUMN] 	varchar(50) NOT NULL,
	[C_TABLENAME]       	varchar(50) NOT NULL,
	[C_COLUMNNAME]      	varchar(50) NOT NULL,
	[C_COLUMNDATATYPE]  	varchar(50) NOT NULL,
	[C_OPERATOR]        	varchar(10) NOT NULL,
	[C_DIMCODE]         	varchar(900) NOT NULL,
	[C_COMMENT]         	text NULL,
	[C_TOOLTIP]         	varchar(1500) NULL,
	[M_APPLIED_PATH]    	varchar(700) NOT NULL,
	[UPDATE_DATE]       	datetime NULL,
	[DOWNLOAD_DATE]     	datetime NULL,
	[IMPORT_DATE]       	datetime NULL,
	[SOURCESYSTEM_CD]   	varchar(50) NULL,
	[VALUETYPE_CD]      	varchar(50) NULL,
	[M_EXCLUSION_CD]    	varchar(25) NULL,
	[C_PATH]            	varchar(700) NULL,
	[C_SYMBOL]          	varchar(50) NULL,
	[PCORI_BASECODE]    	varchar(450) NULL,
	[OMOP_SOURCECODE]   	bigint NULL,
	[i_flags]           	varchar(10) NULL 
	)
ON [PRIMARY]
	TEXTIMAGE_ON [PRIMARY]
	WITH (DATA_COMPRESSION = NONE)
GO
CREATE NONCLUSTERED INDEX [SCILHS_enroll_appliedpath__IDX]
	ON [dbo].[SCILHS_enroll]([M_APPLIED_PATH])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_enroll_FULLNAME_IDX]
	ON [dbo].[SCILHS_enroll]([C_FULLNAME])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_enroll_hlevel_IDX]
	ON [dbo].[SCILHS_enroll]([C_HLEVEL])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_enroll_synonym__IDX]
	ON [dbo].[SCILHS_enroll]([C_SYNONYM_CD])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_enroll_exclusion__IDX]
	ON [dbo].[SCILHS_enroll]([M_EXCLUSION_CD])
	ON [PRIMARY]
GO


CREATE TABLE [dbo].[SCILHS_lab]  ( 
	[C_HLEVEL]             	int NULL,
	[C_FULLNAME]           	varchar(700) NULL,
	[C_NAME]               	varchar(2000) NULL,
	[C_SYNONYM_CD]         	char(1) NULL,
	[C_VISUALATTRIBUTES]   	char(3) NULL,
	[C_TOTALNUM]           	int NULL,
	[C_BASECODE]           	varchar(50) NULL,
	[C_METADATAXML]        	text NULL,
	[C_FACTTABLECOLUMN]    	varchar(50) NULL,
	[C_TABLENAME]          	varchar(50) NULL,
	[C_COLUMNNAME]         	varchar(50) NULL,
	[C_COLUMNDATATYPE]     	varchar(50) NULL,
	[C_OPERATOR]           	varchar(10) NULL,
	[C_DIMCODE]            	varchar(700) NULL,
	[C_COMMENT]            	text NULL,
	[C_TOOLTIP]            	varchar(900) NULL,
	[M_APPLIED_PATH]       	varchar(700) NULL,
	[UPDATE_DATE]          	datetime NULL,
	[DOWNLOAD_DATE]        	datetime NULL,
	[IMPORT_DATE]          	datetime NULL,
	[SOURCESYSTEM_CD]      	varchar(50) NULL,
	[VALUETYPE_CD]         	varchar(50) NULL,
	[M_EXCLUSION_CD]       	varchar(25) NULL,
	[C_PATH]               	varchar(700) NULL,
	[C_SYMBOL]             	varchar(50) NULL,
	[PCORI_BASECODE]       	varchar(50) NULL,
	[PCORI_SPECIMEN_SOURCE]	varchar(50) NULL,
	[OMOP_SOURCECODE]      	bigint NULL,
	[i_flags]              	varchar(10) NULL 
	)
ON [PRIMARY]
	TEXTIMAGE_ON [PRIMARY]
	WITH (DATA_COMPRESSION = NONE)
GO
CREATE NONCLUSTERED INDEX [SCILHS_lab_exclusion__IDX]
	ON [dbo].[SCILHS_lab]([M_EXCLUSION_CD])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_lab_appliedpath__IDX]
	ON [dbo].[SCILHS_lab]([M_APPLIED_PATH])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_lab_hlevel_IDX]
	ON [dbo].[SCILHS_lab]([C_HLEVEL])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_lab_synonym__IDX]
	ON [dbo].[SCILHS_lab]([C_SYNONYM_CD])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_lab_FULLNAME_IDX]
	ON [dbo].[SCILHS_lab]([C_FULLNAME])
	ON [PRIMARY]
GO




CREATE TABLE [dbo].[SCILHS_med]  ( 
	[C_HLEVEL]          	int NULL,
	[C_FULLNAME]        	varchar(900) NULL,
	[C_NAME]            	varchar(2000) NULL,
	[C_SYNONYM_CD]      	char(1) NULL,
	[C_VISUALATTRIBUTES]	char(3) NULL,
	[C_TOTALNUM]        	int NULL,
	[C_BASECODE]        	varchar(450) NULL,
	[C_METADATAXML]     	text NULL,
	[C_FACTTABLECOLUMN] 	varchar(50) NULL,
	[C_TABLENAME]       	varchar(50) NULL,
	[C_COLUMNNAME]      	varchar(50) NULL,
	[C_COLUMNDATATYPE]  	varchar(50) NULL,
	[C_OPERATOR]        	varchar(10) NOT NULL,
	[C_DIMCODE]         	varchar(900) NOT NULL,
	[C_COMMENT]         	text NULL,
	[C_TOOLTIP]         	varchar(900) NULL,
	[M_APPLIED_PATH]    	varchar(700) NULL,
	[UPDATE_DATE]       	datetime NULL,
	[DOWNLOAD_DATE]     	datetime NULL,
	[IMPORT_DATE]       	datetime NULL,
	[SOURCESYSTEM_CD]   	varchar(50) NULL,
	[VALUETYPE_CD]      	varchar(50) NULL,
	[M_EXCLUSION_CD]    	varchar(25) NULL,
	[C_PATH]            	varchar(700) NULL,
	[C_SYMBOL]          	varchar(50) NULL,
	[PCORI_BASECODE]    	varchar(450) NULL,
	[PCORI_CUI]         	varchar(8) NULL,
	[PCORI_NDC]         	varchar(12) NULL,
	[OMOP_SOURCECODE]   	bigint NULL,
	[i_flags]           	varchar(10) NULL 
	)
ON [PRIMARY]
	TEXTIMAGE_ON [PRIMARY]
	WITH (DATA_COMPRESSION = NONE)
GO
CREATE NONCLUSTERED INDEX [SCILHS_med_FULLNAME_IDX]
	ON [dbo].[SCILHS_med]([C_FULLNAME])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_med_appliedpath__IDX]
	ON [dbo].[SCILHS_med]([M_APPLIED_PATH])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_med_hlevel_IDX]
	ON [dbo].[SCILHS_med]([C_HLEVEL])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_med_exclusion__IDX]
	ON [dbo].[SCILHS_med]([M_EXCLUSION_CD])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_med_synonym__IDX]
	ON [dbo].[SCILHS_med]([C_SYNONYM_CD])
	ON [PRIMARY]
GO





CREATE TABLE [dbo].[SCILHS_proc]  ( 
	[C_HLEVEL]          	int NULL,
	[C_FULLNAME]        	varchar(900) NULL,
	[C_NAME]            	varchar(2000) NULL,
	[C_SYNONYM_CD]      	char(1) NULL,
	[C_VISUALATTRIBUTES]	char(3) NULL,
	[C_TOTALNUM]        	int NULL,
	[C_BASECODE]        	varchar(450) NULL,
	[C_METADATAXML]     	text NULL,
	[C_FACTTABLECOLUMN] 	varchar(50) NULL,
	[C_TABLENAME]       	varchar(50) NULL,
	[C_COLUMNNAME]      	varchar(50) NULL,
	[C_COLUMNDATATYPE]  	varchar(50) NULL,
	[C_OPERATOR]        	varchar(10) NOT NULL,
	[C_DIMCODE]         	varchar(900) NOT NULL,
	[C_COMMENT]         	text NULL,
	[C_TOOLTIP]         	varchar(900) NULL,
	[M_APPLIED_PATH]    	varchar(700) NULL,
	[UPDATE_DATE]       	datetime NULL,
	[DOWNLOAD_DATE]     	datetime NULL,
	[IMPORT_DATE]       	datetime NULL,
	[SOURCESYSTEM_CD]   	varchar(50) NULL,
	[VALUETYPE_CD]      	varchar(50) NULL,
	[M_EXCLUSION_CD]    	varchar(25) NULL,
	[C_PATH]            	varchar(700) NULL,
	[C_SYMBOL]          	varchar(50) NULL,
	[PCORI_BASECODE]    	varchar(450) NULL,
	[OMOP_SOURCECODE]   	bigint NULL,
	[i_flags]           	varchar(10) NULL 
	)
ON [PRIMARY]
	TEXTIMAGE_ON [PRIMARY]
	WITH (DATA_COMPRESSION = NONE)
GO
CREATE NONCLUSTERED INDEX [SCILHS_proc_appliedpath__IDX]
	ON [dbo].[SCILHS_proc]([M_APPLIED_PATH])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_proc_hlevel_IDX]
	ON [dbo].[SCILHS_proc]([C_HLEVEL])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_proc_FULLNAME_IDX]
	ON [dbo].[SCILHS_proc]([C_FULLNAME])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_proc_exclusion__IDX]
	ON [dbo].[SCILHS_proc]([M_EXCLUSION_CD])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_proc_synonym__IDX]
	ON [dbo].[SCILHS_proc]([C_SYNONYM_CD])
	ON [PRIMARY]
GO



CREATE TABLE [dbo].[SCILHS_vital]  ( 
	[C_HLEVEL]          	int NOT NULL,
	[C_FULLNAME]        	varchar(900) NOT NULL,
	[C_NAME]            	varchar(2000) NOT NULL,
	[C_SYNONYM_CD]      	char(1) NOT NULL,
	[C_VISUALATTRIBUTES]	char(3) NOT NULL,
	[C_TOTALNUM]        	int NULL,
	[C_BASECODE]        	varchar(450) NULL,
	[C_METADATAXML]     	text NULL,
	[C_FACTTABLECOLUMN] 	varchar(50) NOT NULL,
	[C_TABLENAME]       	varchar(50) NOT NULL,
	[C_COLUMNNAME]      	varchar(50) NOT NULL,
	[C_COLUMNDATATYPE]  	varchar(50) NOT NULL,
	[C_OPERATOR]        	varchar(10) NOT NULL,
	[C_DIMCODE]         	varchar(900) NOT NULL,
	[C_COMMENT]         	text NULL,
	[C_TOOLTIP]         	varchar(1500) NULL,
	[M_APPLIED_PATH]    	varchar(700) NOT NULL,
	[UPDATE_DATE]       	datetime NULL,
	[DOWNLOAD_DATE]     	datetime NULL,
	[IMPORT_DATE]       	datetime NULL,
	[SOURCESYSTEM_CD]   	varchar(50) NULL,
	[VALUETYPE_CD]      	varchar(50) NULL,
	[M_EXCLUSION_CD]    	varchar(25) NULL,
	[C_PATH]            	varchar(700) NULL,
	[C_SYMBOL]          	varchar(50) NULL,
	[PCORI_BASECODE]    	varchar(450) NULL,
	[i_loinc]           	varchar(50) NULL,
	[OMOP_SOURCECODE]   	bigint NULL,
	[i_flags]           	varchar(10) NULL 
	)
ON [PRIMARY]
	TEXTIMAGE_ON [PRIMARY]
	WITH (DATA_COMPRESSION = NONE)
GO
CREATE NONCLUSTERED INDEX [SCILHS_vital_exclusion__IDX]
	ON [dbo].[SCILHS_vital]([M_EXCLUSION_CD])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_vital_synonym__IDX]
	ON [dbo].[SCILHS_vital]([C_SYNONYM_CD])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_vital_appliedpath__IDX]
	ON [dbo].[SCILHS_vital]([M_APPLIED_PATH])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_vital_FULLNAME_IDX]
	ON [dbo].[SCILHS_vital]([C_FULLNAME])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SCILHS_vital_hlevel_IDX]
	ON [dbo].[SCILHS_vital]([C_HLEVEL])
	ON [PRIMARY]
GO
