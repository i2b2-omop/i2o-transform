# i2o-transform
### PCORnet Ontology to OMOP 
An i2b2-to-OMOP data transformation, developed for the [AllOfUs Research Program](https://www.nih.gov/research-training/allofus-research-program) and other projects. Derived from the [i2b2-to-PCORnet transform](https://github.com/ARCH-commons/i2p-transform) data transform. Note that this is presently still dependent on the [ARCH ontology](https://github.com/ARCH-commons/arch-ontology).

Written by Jeffrey Klann, PhD; Matthew Joss; Kevin Embree

Derived from code by Jeffrey Klann, PhD; Matthew Joss; Aaron Abend; Arturo Torres

_Presently this is an alpha version!_

### Current status:
This transforms i2b2 data into OMOP according to the [AllOfUs OMOP CDM Table Requirements](https://sites.google.com/view/ehrupload/omop-tables). It currently runs on MSSQL _only_ and transforms the following tables in OMOP v5.2 format:

#### Fully supported, but relies on the mapped [ARCH ontology](https://github.com/ARCH-commons/arch-ontology):
* person: populated from patient_dimension
* visit_occurrence: populated from visit_dimension
* condition_occurrence: populated from diagnosis data
* procedure_occurrence: populated from procedure data 
* measurement: populated with diagnosis, procedure, vital signs, and labs 
* observation: populated with diagnosis and procedure data
* drug_exposure: populated with medication and procedure data
* death: populated from patient_dimension directly (not tied to ontology)
* provider: populated from provider dimension

#### Transforms from any ontology:
* Labs, into the measurement table (requires a mapping to LOINC codes)

#### Unsupported at present
* location: will be populated with location_cd?
* care_site: could be populated from location_cd?
* device_exposure: will be populated from procedure data
* _fact_relationship: cannot populate, no data_
* _specimen: cannot populate, no data_
* _notes: will be difficult to populate, will not be done by 8/18_
* Support for transforming unit codes into OMOP standard vocabulary
* Putting correct provider codes in all the clinical data tables (currently 0, unknown)

(see more detail in the [CHANGELOG](https://github.com/i2b2-omop/i2o-transform/blob/master/CHANGELOG.md))

### Installation guide:

#### i2b2 side
1. From your i2b2 database: Download, install, and map your i2b2 data to v3.1 or later of the [ARCH Ontology](https://github.com/ARCH-commons/arch-ontology/blob/master/Documentation/INSTALL.md)
    1. You must run [PreparePCORnetOntology](https://github.com/i2b2-omop/i2o-transform/blob/covid_dev/MSSQL/preparePCORnetOntology.sql) one time to add the custom columns required to the ontology. You will need to run this again if you change your i2b2 ontology.
    2. If you have an alternate lab ontology, also load this ontology in your i2b2 database, with an extra column i_stdcode for LOINC codes and i_stddomain with the entry 'LOINC' for every row that should be transformed. (The ARCH ontology can serve as an example, if you've run the previous step.)

#### OMOP side
1. Create a target database for your OMOP tables and perform the next three major numbered steps on that database. Our transform requires that they be on the same server (but not the same database) as your i2b2 instance - though you can move them later.
2. Download and run the [OMOP DDL](https://github.com/OHDSI/CommonDataModel/releases) to create the OMOP tables. This has been tested with OMOP 5.2.
   1. When running the constraints, it is recommended to only run the primary key constraints and not the foreign key and other constraints. Although they provide useful data checks, they can cause ETL problems.
4. Install the [OMOP vocabulary](http://athena.ohdsi.org/vocabulary/list). Be sure to download all needed vocabularies, which is usually ICD-10-PCS plus the set that is checked off my default when download is clicked. (Note that OMOPBuildMapping, run automatically in step 5.5, is dependent on the vocabulary being loaded. If you perform these steps out of order, you might need to manually run OMOPBuildMapping on your database.)
5. Download and run the [MSSQL version](https://github.com/ARCH-commons/i2o-transform/tree/master/MSSQL) of the transform. (Oracle version not currently available.) Run all the following steps from the OMOP target database, not the i2b2 source database.
    1. Make sure the database user that will be running the scripts can also read from your i2b2 data and ontology databases. 
    3. Run [`OMOPConfig_Setup.sql`](https://github.com/i2b2-omop/i2o-transform/blob/covid_dev/MSSQL/OMOPConfig_Setup.sql). Edit any configuration parameters in i2o_transform_config afterward. If using ARCH ontologies, only these changes should be needed:
        * DB and schema for i2b2
        * Names (including db and schema) of ARCH ontologies
    6. From your new OMOP database, run the OMOPLoader.sql script to load the stored procedures.
        * *Note 2023:* It appears qualifier_source_value has been removed from omop. References to these will need to be removed from the transform.
        * *Note:* OMOPLoader.sql runs the procedure OMOPBuildMapping. If any of your mapping tables change (i2b2 ontologies or OMOP concept tables), you will need to rerun this stored procedure.
        * *Note:* Likewise, if your demographics mapping changes, you will need to rerun the stored procedure pcornet_popcodelist.
    8. Run the run.sql script to transform your data. 

### Each time you want to transform your data:
1. From your OMOP database, execute the run script in the [MSSQL directory of our GitHub](https://github.com/ARCH-commons/i2o-transform/tree/master/MSSQL) to transform your data. You can skip the OMOPPrep line if your i2b2 data has not changed since the last run.

### Other components in this repository:
- *dev*: This contains the mapping code to generate the terminology mappings contained in our ontology and in the i2o-mapping table.
- *PHS_MRN_PID_mapping*: Partners-specific code for managing HealthPro participant ids.
- *Oracle*: Placeholder for Oracle version
