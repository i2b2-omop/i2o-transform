- Create_Health_Pro_Data_Table.sql will create a table for storing a health pro 'work queue'
- Health_Pro_data.ctl is a SQLLDR control file for importing health pro a 'work queue' into the Health_Pro_Data table
- HealthProView.sql defines a table that joins Health Pro data to AoU consents tracked in Constrack
- AOU_Matching.sql is a PL/SQL script that checks the data for issues and generates a Mapping between MRNs and AoU participant ids for use in the EHR ETL at PHS

