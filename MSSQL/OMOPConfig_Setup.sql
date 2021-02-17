----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- I2B2 to OMOP transformation setup script 
-- Description: This script sets up an OMOP datamart ready for filling from an I2B2 datamart
--              This script should only need to be run once on a fresh OMOP datamart database or whenever this script is updated
--              Note: This script does not contain any of the direct transformation logic
--              This script does the following ...
--                     1) Create a local i2o_transform_config table if it does not already exist and fills it with default values.
--							NOTE: Change the default values to instutiion specific values prior to running OMOPLoader script
--                     2) Create a local i2o_config_modifier table if it does not already existi and fills it with default values taht you may want to change
--							NOTE: Change the default values to instutiion specific values prior to running OMOPLoader script
--                     3) Create a local i2b2patient_list table that must exist before the OMOPLoader script can be run.
--                          NOTE: OMOPLoader script uses this table in creation of a view.
-- MSSQL version
-- Instructions: 1) Run this script in the database/schema of your OMOP tables
--               2) Review the table i2o_transform_config and update the default values to values appropriate for your environment
--				 3) Review the table i2o_config_modifier and update the default values to values appropriate for your environment
--
-- Contributors: Jeff Klann, PhD; Matthew Joss; Aaron Abend; Arturo Torres; Kevin Embree; Griffin Weber, MD, PhD
-----------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------
-- Set up of the local configuration table
-----------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'i2o_transform_config'))
	BEGIN
		CREATE TABLE i2o_transform_config ( 
			[key]       		varchar(100) NULL,
			[value]    			varchar(100) NULL
			)
	--------------------------------------------------------------------------------------------
	-- NOTE: All the values below are default values when the table is first created
	-- NOTE: Local instutions should not make changes here, but
	-- NOTE: Directly update the values in your local i2o_transform_config table once it's been made
	-- NOTE: This table will NOT be over-written if executed a subsequent time.
	--------------------------------------------------------------------------------------------
	--Set default database and schema of the I2B2 DataMart Tables
	INSERT INTO [i2o_transform_config]([key], [value])
	VALUES('i2b2mart.db.schema.', 'i2b2demodata.dbo.')

	--Set default database.schema of Transformation Ontologies
	INSERT INTO [i2o_transform_config]([key], [value])
	VALUES('ontology.demo.db.schema.table', 'i2b2demodata.dbo.pcornet_demo')
	INSERT INTO [i2o_transform_config]([key], [value])
	VALUES('ontology.diag.db.schema.table', 'i2b2demodata.dbo.pcornet_diag')
	INSERT INTO [i2o_transform_config]([key], [value])
	VALUES('ontology.enc.db.schema.table', 'i2b2demodata.dbo.pcornet_enc')
	INSERT INTO [i2o_transform_config]([key], [value])
	VALUES('ontology.enroll.db.schema.table', 'i2b2demodata.dbo.pcornet_enroll')
	INSERT INTO [i2o_transform_config]([key], [value])
	VALUES('ontology.lab.db.schema.table', 'i2b2demodata.dbo.pcornet_lab')
	INSERT INTO [i2o_transform_config]([key], [value])
	VALUES('ontology.med.db.schema.table', 'i2b2demodata.dbo.pcornet_med')
	INSERT INTO [i2o_transform_config]([key], [value])
	VALUES('ontology.proc.db.schema.table', 'i2b2demodata.dbo.pcornet_proc')
	INSERT INTO [i2o_transform_config]([key], [value])
	VALUES('ontology.vital.db.schema.table', 'i2b2demodata.dbo.pcornet_vital')

	--Set default database and schema of the OMOP DataMart tables
	--INSERT INTO [i2o_transform_config]([key], [value])
	--VALUES('omop.db.schema.', 'omopmart.dbo.')

	--Set height and weight variables to Imperial or Metric
	INSERT INTO [i2o_transform_config]([key], [value])
	VALUES('height.units', 'IMPERIAL')
	--INSERT INTO [i2o_transform_config]([key], [value])
	--VALUES('height.units', 'METRIC')
	INSERT INTO [i2o_transform_config]([key], [value])
	VALUES('weight.units', 'IMPERIAL')
	--INSERT INTO [i2o_transform_config]([key], [value])
	--VALUES('weight.units', 'METRIC')

	END;
GO

--------------------------------------------------------------------------------------------------------------
-- Setup of local modifier configuration table
--------------------------------------------------------------------------------------------------------------
-- Modifier config: you will need to configure this to point to the ontology table and path for your modifiers
-- Default configuration entered is for the PCORI ontology because these modifiers are standardized
	--------------------------------------------------------------------------------------------
	-- NOTE: All the values below are default values when the table is first created
	-- NOTE: Local institutions should not make changes here, but
	-- NOTE: Directly update the values in your local i2o_config_modifier table once it's been made
	-- NOTE: This table will NOT be over-written if executed a subsequent time.
	-- NOTE: Specify the full path to the table database.schema.table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'i2o_config_modifier'))
	BEGIN
		CREATE TABLE [i2o_config_modifier]  ( 
			[c_domain]       	varchar(25) NULL,
			[c_tablename]    	varchar(50) NULL,
			[c_path]         	varchar(400) NULL,
			[c_target_column]	varchar(50) NULL 
			)

			--Default Measurement modifiers for priority and location
			INSERT INTO [i2o_config_modifier]([c_domain], [c_tablename], [c_path], [c_target_column])
			VALUES('lab', 'i2b2demodata.dbo.pcornet_lab', '\PCORI_MOD\PRIORITY\', 'priority')
			INSERT INTO [i2o_config_modifier]([c_domain], [c_tablename], [c_path], [c_target_column])
			VALUES('lab', 'i2b2demodata.dbo.pcornet_lab', '\PCORI_MOD\RESULT_LOC\', 'result_loc')

			--Default drug_exposure modifiers for days supply, refills, quantity, frequency and basis
			INSERT INTO [i2o_config_modifier]([c_domain], [c_tablename], [c_path], [c_target_column])
			VALUES('rx', 'i2b2demodata.dbo.pcornet_med', '\PCORI_MOD\RX_DAYS_SUPPLY\', 'days_supply')
			INSERT INTO [i2o_config_modifier]([c_domain], [c_tablename], [c_path], [c_target_column])
			VALUES('rx', 'i2b2demodata.dbo.pcornet_med', '\PCORI_MOD\RX_REFILLS\', 'refills')
			INSERT INTO [i2o_config_modifier]([c_domain], [c_tablename], [c_path], [c_target_column])
			VALUES('rx', 'i2b2demodata.dbo.pcornet_med', '\PCORI_MOD\RX_QUANTITY\', 'quantity')
			INSERT INTO [i2o_config_modifier]([c_domain], [c_tablename], [c_path], [c_target_column])
			VALUES('rx', 'i2b2demodata.dbo.pcornet_med', '\PCORI_MOD\RX_FREQUENCY\', 'frequency')
			INSERT INTO [i2o_config_modifier]([c_domain], [c_tablename], [c_path], [c_target_column])
			VALUES('rx', 'i2b2demodata.dbo.pcornet_med', '\PCORI_MOD\RX_BASIS\', 'basis')
	END;
GO

---------------------------------------------------------------------------------------------
-- Set up i2b2patient_list table which allows for persistence of a explict list of patient_num values to be transformed
-- NOTE: This table must exist prior to creation of synonyms\views
---------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[i2b2patient_list]') AND type in (N'U'))
DROP TABLE [dbo].[i2b2patient_list]
GO
CREATE TABLE [dbo].[i2b2patient_list] ( 
	[patient_num]	int NOT NULL 
	)
GO