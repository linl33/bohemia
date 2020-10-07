-- TODO review non nullable fields, 
-- inspect full dataframe labels, 
-- whats with the repeat_id and repeat_counts?, 
-- what is the lgl type ideal to match in sql? currently using BOOLEAN.

-- CREATE DATABASE bohemia;
-- NOTE switch to the bohemia database before proceeding with the following queries execution.
-- psql command `\c bohemia`
-- on ubuntu: export PGPASSWORD='riscrazy'; psql -h 'localhost' -U 'bohemia_app' -d 'bohemia'

CREATE TABLE minicensus_main (
    instance_id   uuid, 
    any_deaths_past_year   VARCHAR(16),
    cook_main_water_source   VARCHAR(64),
    cook_time_to_water   VARCHAR(64),
    device_id   VARCHAR(64),
    end_time   TIMESTAMP,
    have_wid   VARCHAR(64),
    hh_sub_size   INT,
    hh_animals_distance_cattle_dry_season   VARCHAR(256),
    hh_animals_distance_cattle_dry_season_geo   VARCHAR(256),
    hh_animals_distance_cattle_rainy_season   VARCHAR(256),
    hh_animals_distance_cattle_rainy_season_geo   VARCHAR(256),
    hh_animals_distance_cattle_sleep   VARCHAR(256),
    hh_animals_dry_season_distance_pigs   VARCHAR(256),
    hh_animals_dry_season_geo_pigs   VARCHAR(256),
    hh_animals_dry_season_pigs   VARCHAR(256),
    hh_animals_rainy_season_distance_pigs   VARCHAR(256),
    hh_animals_rainy_season_geo_pigs   VARCHAR(256),
    hh_animals_rainy_season_pigs   VARCHAR(256),
    hh_animals_where_cattle_dry_season   VARCHAR(256),
    hh_animals_where_cattle_rainy_season   VARCHAR(256),
    hh_contact_info_number   VARCHAR(64),
    hh_contact_info_number_alternate   VARCHAR(64),
    hh_contact_info_number_can_call   VARCHAR(64),
    hh_country   VARCHAR(64),
    hh_district   VARCHAR(64),
    hh_geo_location   VARCHAR(256),
    hh_hamlet   VARCHAR(64),
    hh_hamlet_code   VARCHAR(3),
    hh_have_paint_house   VARCHAR(64),
    hh_have_paint_worker   VARCHAR(64),
    hh_head_dob   DATE,
    hh_head_gender   VARCHAR(8),
    hh_head_id   VARCHAR(11),
    hh_head_months_away   INT,
    hh_health_other   VARCHAR(256),
    hh_health_permission   VARCHAR(256),
    hh_health_who   VARCHAR(256),
    hh_health_who_other   VARCHAR(256),
    hh_id   VARCHAR(7), -- needs to be bigger
    hh_main_building_type   VARCHAR(256),
    hh_main_energy_source_for_lighting   VARCHAR(256),
    hh_main_wall_material   VARCHAR(256),
    hh_member_num   INT,
    hh_member_num_non_residents   INT,
    hh_member_num_residents   INT,
    hh_n_constructions   INT,
    hh_n_constructions_sleep   INT,
    hh_n_cows_greater_than_1_year   INT,
    hh_n_cows_less_than_1_year   INT,
    hh_n_pigs_greater_than_6_weeks   INT,
    hh_n_pigs_less_than_6_weeks   INT,
    hh_owns_cattle_or_pigs   VARCHAR(16),
    hh_photograph   VARCHAR(256),
    hh_possessions   VARCHAR(256),
    hh_region   VARCHAR(64),
    hh_size   INT,
    hh_village   VARCHAR(64),
    hh_ward   VARCHAR(64),
    how_many_deaths   INT,
    instanceName   VARCHAR(256),
    irs_past_12_months   VARCHAR(256),
    n_nets_in_hh   INT,
    respondent_id   VARCHAR(256),
    start_time   TIMESTAMP,
    todays_date   DATE,
    water_bodies   VARCHAR(256), 
    water_bodies_how_many   INT,
    wid   INT,
    wid_manual   VARCHAR(32),
    wid_qr   VARCHAR(32),
    PRIMARY KEY(instance_id)
);

CREATE TABLE minicensus_people (
    instance_id    uuid,
    first_name   VARCHAR(64),
    last_name   VARCHAR(64),
    pid   VARCHAR(11),
    --name_label   VARCHAR(128),
    num  INT,
    dob DATE,
    instance_id    uuid,
    dob   DATE,
    gender    VARCHAR(8),
    hh_member_adjustment  INT, 
    hh_member_number  INT,
    last_name     VARCHAR(256), -- the first name had multiple names stored, applying the same here 
    member_resident   VARCHAR(32),
    non_default_id    TEXT, 
    note_id   BOOLEAN, 
    permid    TEXT,
    repeat_household_members_enumeration_count    INT,
    trigger_non_default_id    TEXT,
    CONSTRAINT fk_minicensus_main FOREIGN KEY (instance_id) REFERENCES minicensus_main(instance_id) ON DELETE CASCADE
);

CREATE TABLE minicensus_repeat_death_info (
--   repeat_name <chr> - # table name 
--   repeated_id <dbl> - # used to associate data for a single row  
    instance_id    uuid,
    age_death     INT,  
    death_age     INT,                                           
    death_age_unit    VARCHAR(32),
    death_dob     DATE, 
    death_dob_known   VARCHAR(16), 
    death_dob_unknown     INT,
    death_dod     DATE, 
    death_dod_known   VARCHAR(16), 
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
    trigger_non_default_death_id   VARCHAR(16),
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
    hh_sub_relationship   VARCHAR(128),
    CONSTRAINT fk_minicensus_main FOREIGN KEY (instance_id) REFERENCES minicensus_main(instance_id) ON DELETE CASCADE
);

CREATE TABLE minicensus_repeat_mosquito_net (
--   repeat_name <chr> - # table name  
--   repeated_id <dbl> - # used to associate data for a single row
    instance_id    uuid,     
    net_obtain_when   TEXT,
    num   INT, 
    CONSTRAINT fk_minicensus_main FOREIGN KEY (instance_id) REFERENCES minicensus_main(instance_id) ON DELETE CASCADE
);

CREATE TABLE minicensus_repeat_water (
--   repeat_name <chr> - # table name 
--   repeated_id <dbl> - # used to associate data for a single row 
    instance_id    uuid,
    num  INT, 
    water_bodies_type  TEXT, 
    CONSTRAINT fk_minicensus_main FOREIGN KEY (instance_id) REFERENCES minicensus_main(instance_id) on delete CASCADE
);     

-- Enumerations

CREATE TABLE enumerations (
    instance_id   uuid, 
    agregado   VARCHAR(256),
    chefe_name   VARCHAR(128),
    construction_material   VARCHAR(256), 
    construction_type   VARCHAR(256),
    country   VARCHAR(32),
    device_id   VARCHAR(64),
    district   VARCHAR(32),
    end_time   TIMESTAMP,
    hamlet   VARCHAR(128),
    hamlet_code   VARCHAR(3),
    have_wid   VARCHAR(64),
    inquiry_date   Date,
    localizacao_agregado   VARCHAR(256),
    location_gps   VARCHAR(256),
    n_deaths_past_year   INT,
    n_residents   INT,
    n_total_constructions   INT,
    region   VARCHAR(64),
    start_time   TIMESTAMP,
    sub_name   VARCHAR(256),
    todays_date   DATE,
    village   VARCHAR(256),
    vizinho1   VARCHAR(256),
    vizinho2   VARCHAR(256),
    wall_material   VARCHAR(256),
    --wall_material_free   VARCHAR(256),
    ward   VARCHAR(256),
    wid   INT,
    wid_manual   VARCHAR(32),
    wid_qr   VARCHAR(32),
    PRIMARY KEY(instance_id)
);

-- Refusals


CREATE TABLE refusals (
    instance_id   uuid, 
    device_id   VARCHAR(64),
    end_time   TIMESTAMP,
    have_wid   VARCHAR(64),
    country   VARCHAR(32),
    hh_geo_location   VARCHAR(256),
    hamlet   VARCHAR(128),
    district   VARCHAR(64),
    region   VARCHAR(64),
    hamlet_code   VARCHAR(3),
    hh_id   VARCHAR(8),
    hh_id_manual   VARCHAR(8),
    hh_region   VARCHAR(32),
    village   VARCHAR(32),
    ward   VARCHAR(32),
    instancename   VARCHAR(64),
    reason_no_participate   TEXT,
    start_time   TIMESTAMP,
    todays_date   DATE,
    wid   INT,
    wid_manual   VARCHAR(32),
    wid_qr   VARCHAR(32),
    PRIMARY KEY(instance_id)
    );

-- Sessions

CREATE TABLE sessions (
    user_email  VARCHAR(256),
    start_time  TIMESTAMP NOT NULL,
    end_time    TIMESTAMP
);
  