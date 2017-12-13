# i2o-transform
### PCORnet Ontology to OMOP 
An experimental fork of the i2b2-to-PCORNET transform that targets OMOP, for the [Precision Medicine Initiative](https://www.nih.gov/research-training/allofus-research-program).

Written by Jeffrey Klann, PhD; Matthew Joss; Kevin Embree
Derived from code by Jeffrey Klann, PhD; Matthew Joss; Aaron Abend; Arturo Torres

### To set this up:
1. Create a database for your OMOP tables and perform the next three major numbered steps on that database.
2. Download the [OMOP DDL](https://github.com/OHDSI/CommonDataModel) to create the OMOP tables.
3. Download and import the [i2o-mapping table](https://github.com/ARCH-commons/i2o-transform/blob/master/data/i2o_mapping.txt), which contains a subset of the OMOP concept dictionary needed by the transform script.
3. Download and run the [MSSQL version](https://github.com/ARCH-commons/i2o-transform/tree/master/MSSQL) of the transform. (Oracle version not currently available.)
    1. Create a database for your OMOP tables. Our transform requires that they be on the same server as your i2b2 instance - though you can move them later.
    2. Make sure the database user that will be running the scripts can also read from your i2b2 data and ontology databases. 
    3. From your new OMOP database, open the OMOPLoader.sql script.  Edit the preamble to match your local setup, according to the instructions in the file. This now includes the following:
        * synonym names 
        * the USE line 
        * Change 'LOINC:' in the lab results procedure to whatever term your local site uses. 
    4. This script will delete your existing OMOP tables. If you do not want this behavior, please back them up.
    5. Run the script.

4. From your i2b2 database: Download, install, and map your i2b2 data to v3.1 or later of the [ARCH Ontology](https://github.com/ARCH-commons/arch-ontology/blob/master/Documentation/INSTALL.md)

### Each time you want to transform your data:
1. From your OMOP database, execute the run script in the [MSSQL directory of our GitHub](https://github.com/ARCH-commons/i2o-transform/tree/master/MSSQL) to transform your data.

### Other components in this repository:
- *dev*: This contains the mapping code to generate the terminology mappings contained in our ontology and in the i2o-mapping table.
- *PHS_MRN_PID_mapping*: Partners-specific code for managing HealthPro participant ids.
- *Oracle*: Placeholder for Oracle version
