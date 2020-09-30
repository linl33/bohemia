-- TODO review non nullable fields, 
-- inspect full dataframe labels, 
-- whats with the repeat_id and repeat_counts?, 
-- what is the lgl type ideal to match in sql? currently using BOOLEAN.

CREATE DATABASE bohemia;
CREATE USER bohemia_app WITH LOGIN PASSWORD 'riscrazy';
-- NOTE switch to the bohemia database before proceeding with the following queries execution.

CREATE TABLE minicensus_main (
    instance_id  uuid,
    household_data  jsonb NOT NULL,
    PRIMARY KEY(instance_id)
);

CREATE TABLE minicensus_repeat_death_info (
--   repeat_name <chr> - # table name 
--   repeated_id <dbl> - # used to associate data for a single row  
    instance_id    uuid,
    age_death     INT,  
    death_adjustment  INT,
    death_age     INT,                                           
    death_age_unit    VARCHAR(8),
    death_dob     DATE, 
    death_dob_known   BOOLEAN, 
    death_dob_unknown     INT,
    death_dod     DATE, 
    death_dod_known   BOOLEAN, 
    death_gender  VARCHAR(8), 
    death_id  TEXT,
    death_location    VARCHAR(128), 
    death_location_location   VARCHAR(128), 
    death_name    VARCHAR(256),
    death_number  INT, 
    death_number_size     VARCHAR(64), 
    death_surname     VARCHAR(64),
    non_default_death_id  TEXT, 
    note_death_id     TEXT,
    repeat_death_info_count   INT, 
    trigger_non_default_death_id  BOOLEAN,
    CONSTRAINT fk_minicensus_main FOREIGN KEY (instance_id) REFERENCES minicensus_main(instance_id) ON DELETE CASCADE
);

CREATE TABLE minicensus_repeat_hh_sub (
--   repeat_name <chr> - # table name
--   repeated_id <dbl> - # used to associate data for a single row 
    instance_id    uuid,
    hh_sub_count  INT,
    hh_sub_dob    DATE,
    hh_sub_gender     VARCHAR(8),
    hh_sub_id     INT,
    hh_sub_relationship   VARCHAR(64),
    hh_sub_relationship_other     VARCHAR(64),
    note_hh_head_is_sub   BOOLEAN,
    CONSTRAINT fk_minicensus_main FOREIGN KEY (instance_id) REFERENCES minicensus_main(instance_id) ON DELETE CASCADE
);

CREATE TABLE minicensus_repeat_household_members_enumeration (
--   repeat_name <chr> - # table name
--   repeated_id <dbl> - # used to associate data for a single row 
    instance_id    uuid,
    dob   DATE,
    first_name    VARCHAR(256),
    gender    VARCHAR(8),
    hh_member_adjus  INT, -- TODO fix label
    hh_member_number  INT,
    hh_member_number_size     VARCHAR(8), 
    last_name     VARCHAR(256), -- the first name had multiple names stored, applying the same here 
    member_resident   VARCHAR(8),
    non_default_id    TEXT, 
    note_id   BOOLEAN, 
    permid    TEXT,
    repeat_household_members_enumeration_count    INT,
    trigger_non_default_id    TEXT,
    CONSTRAINT fk_minicensus_main FOREIGN KEY (instance_id) REFERENCES minicensus_main(instance_id) ON DELETE CASCADE
);

CREATE TABLE minicensus_repeat_mosquito_net (
--   repeat_name <chr> - # table name  
--   repeated_id <dbl> - # used to associate data for a single row
    instance_id    uuid,     
    net_obtain_when   DATE,
    repeat_mosquito   INT, -- TODO fix label
    CONSTRAINT fk_minicensus_main FOREIGN KEY (instance_id) REFERENCES minicensus_main(instance_id) ON DELETE CASCADE
);

CREATE TABLE minicensus_repeat_water (
--   repeat_name <chr> - # table name 
--   repeated_id <dbl> - # used to associate data for a single row 
    instance_id    uuid,
    repeat_water_co  INT, -- TODO fix label
    water_bodies_ty  VARCHAR(64), -- TODO fix label
    CONSTRAINT fk_minicensus_main FOREIGN KEY (instance_id) REFERENCES minicensus_main(instance_id) on delete CASCADE
);                                    
