-- CSV
--creare tabel pentru importul datelor din CSV și popularea cu datele necesare
drop table analytics;

CREATE TABLE analytics (
    campaign_id VARCHAR2(10),
    campaign_name VARCHAR2(255),
    start_date VARCHAR2(255),
    end_date VARCHAR2(255),
    clicks NUMBER,
    impressions NUMBER,
    conversion_rate NUMBER(5,2),
    survey_score NUMBER(5,2),
    survey_comments VARCHAR2(4000)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY ext_file_ds
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        FIELDS TERMINATED BY ',' 
    )
    LOCATION ('1.analytics_data.csv')
)
REJECT LIMIT UNLIMITED;

select * from analytics


