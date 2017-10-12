--------------------------------------------------------
--  DDL for Table HEALTH_PRO_DATA
--------------------------------------------------------

  CREATE TABLE "CONSTRACK"."HEALTH_PRO_DATA" 
   (	"PMI_ID" VARCHAR2(26 BYTE), 
	"BIOBANK_ID" VARCHAR2(26 BYTE), 
	"LAST_NAME" VARCHAR2(26 BYTE), 
	"FIRST_NAME" VARCHAR2(26 BYTE), 
	"DATE_OF_BIRTH" DATE, 
	"LANGUAGE" VARCHAR2(26 BYTE), 
	"GENERAL_CONSENT_STATUS" NUMBER(3,0), 
	"GENERAL_CONSENT_DATE" DATE, 
	"EHR_CONSENT_STATUS" NUMBER(3,0), 
	"EHR_CONSENT_DATE" DATE, 
	"CABOR_CONSENT_STATUS" NUMBER(3,0), 
	"CABOR_CONSENT_DATE" DATE, 
	"WITHDRAWAL_STATUS" NUMBER(3,0), 
	"WITHDRAWAL_DATE" DATE, 
	"STREET_ADDRESS" VARCHAR2(400 BYTE), 
	"CITY" VARCHAR2(80 BYTE), 
	"STATE" VARCHAR2(26 BYTE), 
	"ZIP" VARCHAR2(26 BYTE), 
	"EMAIL" VARCHAR2(400 BYTE), 
	"PHONE" VARCHAR2(12 BYTE), 
	"SEX" VARCHAR2(26 BYTE), 
	"GENDER_IDENTITY" VARCHAR2(26 BYTE), 
	"RACE_ETHNICITY" VARCHAR2(400 BYTE), 
	"EDUCATION" VARCHAR2(400 BYTE), 
	"REQUIRED_PPI_SURVEY_COMPLETE" NUMBER(3,0), 
	"COMPLETED_SURVEYS" NUMBER(3,0), 
	"BASICS_PPI_SURVEY_COMPLETE" NUMBER(3,0), 
	"BASIC_PPI_SURVEY_COMP_DATE" DATE, 
	"HEALTH_PPI_SURVEY_COMPLETE" NUMBER(3,0), 
	"HEALTH_PPI_SURVEY_COMP_DATE" DATE, 
	"LIFESTYLE_PPI_SURVEY_COMPLETE" NUMBER(3,0), 
	"LIFESTYLE_PPI_SURVEY_COMP_DATE" DATE, 
	"HIST_PPI_SURVEY_COMPLETE" NUMBER(3,0), 
	"HIST_PPI_SURVERY_COMP_DATE" DATE, 
	"MEDS_PPI_SURVEY_COMPLETE" NUMBER(3,0), 
	"MEDS_PPI_SURVEY_COMP_DATE" DATE, 
	"FAMILY_PPI_SURVEY_COMPLETE" NUMBER(3,0), 
	"FAMILY_PPI_SURVERY_COMP_DATE" DATE, 
	"ACCESS_PPI_SURVEY_COMPLETE" NUMBER(3,0), 
	"ACCESS_PPI_SURVEY_COMP_DATE" DATE, 
	"PHYSICAL_MEASURMENTS_STATUS" NUMBER(3,0), 
	"PHYSICAL_MEASURE_COMP_DATE" DATE, 
	"SAMPLES_FOR_DNA_RECIEVED" NUMBER(3,0), 
	"BIOSPECIMENS" NUMBER(3,0), 
	"SST_COLLECTED" NUMBER(3,0), 
	"SST_COLLECTION_DATE" DATE, 
	"PST_COLLECTED" NUMBER(3,0), 
	"PST_COLLECTION_DATE" DATE, 
	"NA_HEP_COLLECTED" NUMBER(3,0), 
	"NA_HEP_COLLECTION_DATE" DATE, 
	"EDTA_4_COLLECTED" NUMBER(3,0), 
	"EDTA_4_COLLECTION_DATE" DATE, 
	"EDTA_10_1_EDTA_COLLECTED" NUMBER(3,0), 
	"EDTA_10_1_COLLECTION_DATE" DATE, 
	"EDTA_10_2_COLLECTED" NUMBER(3,0), 
	"EDTA_10_2_COLLECTION_DATE" DATE, 
	"URINE_COLLECTED" NUMBER(3,0), 
	"URINE_COLLECTION_DATE" DATE, 
	"SALIVA_COLLECTED" NUMBER(3,0), 
	"SALIVA_COLLECTION_DATE" DATE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "CTRACK_DATA" ;
--------------------------------------------------------
--  DDL for Index HEALTH_PRO_DATA_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "CONSTRACK"."HEALTH_PRO_DATA_PK" ON "CONSTRACK"."HEALTH_PRO_DATA" ("PMI_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "CTRACK_DATA" ;
--------------------------------------------------------
--  DDL for Index HEALTH_PRO_DATA_BIOBANK_ID
--------------------------------------------------------

  CREATE UNIQUE INDEX "CONSTRACK"."HEALTH_PRO_DATA_BIOBANK_ID" ON "CONSTRACK"."HEALTH_PRO_DATA" ("BIOBANK_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "CTRACK_DATA" ;
--------------------------------------------------------
--  Constraints for Table HEALTH_PRO_DATA
--------------------------------------------------------

  ALTER TABLE "CONSTRACK"."HEALTH_PRO_DATA" ADD CONSTRAINT "HEALTH_PRO_DATA_BIOBANK_ID" UNIQUE ("BIOBANK_ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "CTRACK_DATA"  ENABLE;
  ALTER TABLE "CONSTRACK"."HEALTH_PRO_DATA" ADD CONSTRAINT "HEALTH_PRO_DATA_PK" PRIMARY KEY ("PMI_ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "CTRACK_DATA"  ENABLE;