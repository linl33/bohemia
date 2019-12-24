#!/bin/sh
psql -c "CREATE DATABASE ids"
psql ids -c "CREATE TABLE IF NOT EXISTS workers(
    ID SERIAL,
    wid           CHAR(3) NOT NULL,
    first_name           VARCHAR(50),
    last_name           VARCHAR(50),
    location           VARCHAR(50)
)"
psql ids -c "CREATE TABLE IF NOT EXISTS households(
    ID SERIAL,
    wid           CHAR(3) NOT NULL,
    subid           CHAR(3),
    hhid           CHAR(7),
    lid           VARCHAR(50)
)"
