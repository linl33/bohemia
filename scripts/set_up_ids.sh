#!/bin/sh
psql -c "CREATE DATABASE ids"
psql ids -c "CREATE TABLE workers(
    ID SERIAL,
    wid           CHAR(50) NOT NULL,
    first_name           CHAR(50),
    last_name           CHAR(50),
    location           CHAR(50)
)"
psql ids -c "CREATE TABLE households(
    ID SERIAL,
    wid           CHAR(50) NOT NULL,
    subid           CHAR(50),
    hhid           CHAR(50),
    lid           CHAR(50)
)"
