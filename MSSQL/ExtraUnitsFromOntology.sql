--------------------------------------------------------------------------------------
-- Manually adding more unit mappings
--     Starting with a handlful of i2o_unit upserts
-- Authored by: Kevin Embree
-- Authored On: 2020-12-10
---------------------------------------------------------------------------------------
--Manually UPSERT unit mappings for most commonly used unit values in the PHS XML values
-- Run any time after OMOPBuildMapping has been run to add these mappings back in.
IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = 'mg/dl' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 8840,
		standard_concept = 'S'
    WHERE units_name = 'mg/dl';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( 'mg/dl', 8840, 'S' );

IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = '%')
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 8554,
		standard_concept = 'S'
    WHERE units_name = '%';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( '%', 8554, 'S' );

IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = 'mmol/l' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 8753,
		standard_concept = 'S'
    WHERE units_name = 'mmol/l';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( 'mmol/l', 8753, 'S' );

IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = 'g/dl' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 8950,
		standard_concept = 'S'
    WHERE units_name = 'g/dl';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( 'g/dl', 8950, 'S' );

IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = 'k/ul' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 8792,
		standard_concept = 'S'
    WHERE units_name = 'k/ul';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( 'k/ul', 8792, 'S' );

IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = 'u/l' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 8645,
		standard_concept = 'S'
    WHERE units_name = 'u/l';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( 'u/l', 8645, 'S' );

IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = 'th/cmm' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 8961,
		standard_concept = 'S'
    WHERE units_name = 'th/cmm';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( 'th/cmm', 8961, 'S' );

IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = 'fl' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 8583,
		standard_concept = 'S'
    WHERE units_name = 'fl';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( 'fl', 8583, 'S' );

IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = 'ml/min/1.73m2' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 9117,
		standard_concept = 'S'
    WHERE units_name = 'ml/min/1.73m2';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( 'ml/min/1.73m2', 9117, 'S' );

IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = 'gm/dl' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 8713,
		standard_concept = 'S'
    WHERE units_name = 'gm/dl';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( 'gm/dl', 8713, 'S' );

IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = 'th/cumm' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 8961,
		standard_concept = 'S'
    WHERE units_name = 'th/cumm';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( 'th/cumm', 8961, 'S' );

IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = 'pg/rbc' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 8704,
		standard_concept = 'S'
    WHERE units_name = 'pg/rbc';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( 'pg/rbc', 8704, 'S' );

IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = 'm/ul' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 8815,
		standard_concept = 'S'
    WHERE units_name = 'm/ul';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( 'm/ul', 8815, 'S' );
	--
IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = 'mil/cmm' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 8931,
		standard_concept = 'S'
    WHERE units_name = 'mil/cmm';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( 'mil/cmm', 8931, 'S' );

IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = 'sec' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 8555,
		standard_concept = 'S'
    WHERE units_name = 'sec';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( 'sec', 8555, 'S' );

IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = 'ng/ml' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 8842,
		standard_concept = 'S'
    WHERE units_name = 'ng/ml';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( 'ng/ml', 8842, 'S' );

IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = '/100 wc' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 9032,
		standard_concept = 'S'
    WHERE units_name = '/100 wc';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( '/100 wc', 9032, 'S' );
	
IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = 'pg' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 8564,
		standard_concept = 'S'
    WHERE units_name = 'pg';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( 'pg', 8564, 'S' );
		
IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = 'th/mm3' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 8961,
		standard_concept = 'S'
    WHERE units_name = 'th/mm3';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( 'th/mm3', 8961, 'S' );
	
IF EXISTS ( SELECT * FROM i2o_unitsmap u where u.units_name = '/100 wbcs' )
    UPDATE dbo.i2o_unitsmap
        SET concept_id = 9032,
		standard_concept = 'S'
    WHERE units_name = '/100 wbcs';
ELSE 
    INSERT dbo.i2o_unitsmap ( units_name, concept_id, standard_concept )
    VALUES ( '/100 wbcs', 9032, 'S' );