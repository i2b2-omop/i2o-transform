# i2o-transform
### PCORnet Ontology to OMOP 
An i2b2-to-OMOP data transformation, developed for the [AllOfUs Research Program](https://www.nih.gov/research-training/allofus-research-program) and other projects. Derived from the [i2b2-to-PCORnet transform](https://github.com/ARCH-commons/i2p-transform) data transform. Note that this is dependent on the [ARCH ontology](https://github.com/ARCH-commons/arch-ontology).

Written by Jeffrey Klann, PhD; Matthew Joss; Kevin Embree

Derived from code by Jeffrey Klann, PhD; Matthew Joss; Aaron Abend; Arturo Torres

_Presently this is an alpha version!_

### Current status:
This transforms i2b2 data into OMOP according to the [AllOfUs OMOP CDM Table Requirements](https://sites.google.com/view/ehrupload/omop-tables). It currently runs on MSSQL _only_ and transforms the following tables in OMOP v5.2 format:

#### Fully supported in [current release](https://github.com/i2b2-omop/i2o-transform/releases/tag/0.1)
* person: populated from patient_dimension
* visit_occurrence: populated from visit_dimension
* condition_occurrence: populated from diagnosis data
* drug_exposure: poopulated from medication data
* procedure_occurrence: populated from procedure data
* measurement: populated with vital signs and labs (only tested on PCORI lab subset)

#### Supported in [repository code](https://github.com/i2b2-omop/i2o-transform/tree/0.1/MSSQL) (see more detail in the [CHANGELOG](https://github.com/i2b2-omop/i2o-transform/blob/master/CHANGELOG.md))
* measurement: populated with diagnosis, procedure, vital signs, and labs (testing presently on full LOINC ontology)
* observation: populated with diagnosis and procedure data
* drug_exposure: populated with medication and procedure data
* death: populated from patient_dimension directly (not tied to ontology)
* provider: populated from provider dimension

#### Still needed to support
* location: will be populated with location_cd?
* care_site: could be populated from location_cd?
* device_exposure: will be populated from procedure data
* _fact_relationship: cannot populate, no data_
* _specimen: cannot populate, no data_
* _notes: will be difficult to populate, will not be done by 8/18_

#### Additionally under development:
* Support for transforming unit codes into OMOP standard vocabulary
* Putting correct provider codes in all the clinical data tables (currently 0, unknown)

### Installation guide:
0. Verify that your i2b2 database is populated and mapped to the [ARCH ontology](https://github.com/ARCH-commons/arch-ontology), which must be separately installed.
1. Create a database for your OMOP tables and perform the next three major numbered steps on that database.
2. Download the [OMOP DDL](https://github.com/OHDSI/CommonDataModel/releases) to create the OMOP tables. This has been tested with OMOP 5.2.
3. Install the [OMOP vocabulary](http://athena.ohdsi.org/vocabulary/list). Be sure to download all needed vocabularies, which is usually ICD-10 plus the default set. (Note that OMOPBuildMapping, run automatically in step 5.5, is dependent on the vocabulary being loaded. If you perform these steps out of order, you might need to manually run OMOPBuildMapping on your database.)
4. Download and run the [MSSQL version](https://github.com/ARCH-commons/i2o-transform/tree/master/MSSQL) of the transform. (Oracle version not currently available.)
    1. Create a database for your OMOP tables and run the OMOP DDL there. Our transform requires that they be on the same server as your i2b2 instance - though you can move them later.
    2. Make sure the database user that will be running the scripts can also read from your i2b2 data and ontology databases. 
    3. *Config script. (TBD)* <-- once
    4. *PreparePCORnetOntology* <-- after any changes to ontology or omop concept table
    5. *LocalChangesToPointToLocalOntologies*
    6. From your new OMOP database, open the OMOPLoader.sql script.  Edit the preamble to match your local setup, according to the instructions in the file. This now includes the following:
        * synonym names 
        * the USE line 
        * Change 'LOINC:' in the lab results procedure to whatever term your local site uses. 
    7. This script will delete your existing OMOP tables. If you do not want this behavior, please back them up.
    8. Run the script.

5. From your i2b2 database: Download, install, and map your i2b2 data to v3.1 or later of the [ARCH Ontology](https://github.com/ARCH-commons/arch-ontology/blob/master/Documentation/INSTALL.md)

### Each time you want to transform your data:
1. From your OMOP database, execute the run script in the [MSSQL directory of our GitHub](https://github.com/ARCH-commons/i2o-transform/tree/master/MSSQL) to transform your data.

### Other components in this repository:
- *dev*: This contains the mapping code to generate the terminology mappings contained in our ontology and in the i2o-mapping table.
- *PHS_MRN_PID_mapping*: Partners-specific code for managing HealthPro participant ids.
- *Oracle*: Placeholder for Oracle version
