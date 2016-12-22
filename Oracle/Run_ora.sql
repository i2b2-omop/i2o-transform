----------------------------------------------------------------------------------------------------------------------------------------
-- Run Program
-- Written by Matthew Joss: extracted various portions of the oracle transform script into this separate script.
----------------------------------------------------------------------------------------------------------------------------------------



BEGIN
PMN_DROPSQL('DROP TABLE i2b2patient_list');
END;
/

CREATE table i2b2patient_list as 
select * from
(
select DISTINCT f.PATIENT_NUM from I2B2FACT f 
inner join i2b2visit v on f.patient_num=v.patient_num
where f.START_DATE >= to_date('01-Jan-2010','dd-mon-rrrr') and v.START_DATE >= to_date('01-Jan-2010','dd-mon-rrrr')
) where ROWNUM<100000000
/

create or replace VIEW i2b2patient as select * from I2B2DEMODATA.PATIENT_DIMENSION where PATIENT_NUM in (select PATIENT_NUM from i2b2patient_list)
/

create or replace view i2b2visit as select * from I2B2DEMODATA.VISIT_DIMENSION where START_DATE >= to_date('01-Jan-2010','dd-mon-rrrr') and (END_DATE is NULL or END_DATE < CURRENT_DATE) and (START_DATE <CURRENT_DATE)
/




BEGIN          -- RUN PROGRAM 
pcornetclear;  -- Make sure to run this before re-populating any pmn tables.
pcornetloader; -- you may want to run sql statements one by one in the pcornetloader procedure :)
END;
/
