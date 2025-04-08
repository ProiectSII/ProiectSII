--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
DROP USER logtest CASCADE;

CREATE USER logtest IDENTIFIED BY 1234
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON USERS;

grant connect, resource to logtest; --drepturi user
grant CREATE VIEW to logtest; -- drept creare views

----
grant CREATE ANY DIRECTORY to logtest; -- drepturi de creare local directory pt a citi fisiere dintr-o cale specifica
GRANT READ ON DIRECTORY ext_file_ds TO logtest;
grant execute on utl_http to logtest; -- drepturi pentru citire url-uri
grant execute on dbms_lob to logtest; -- drepturi de stocare structuri mari de date

-- APEX suplimentary permissions
grant CREATE DIMENSION, CREATE JOB, CREATE MATERIALIZED VIEW, CREATE SYNONYM to logtest;

-- permisiuni pentru apelare endpoint rest port 3000 pentru PostgreRest
begin
  DBMS_NETWORK_ACL_ADMIN.append_host_ace (
      host       => 'localhost',
      lower_port => 3000,  
      upper_port => 3000,
      ace        => xs$ace_type(privilege_list => xs$name_list('http'),
                                principal_name => 'logtest',
                                principal_type => xs_acl.ptype_db));
  end;
/

--Vizualizare informatii grant user
SELECT host,
       lower_port,
       upper_port,
       ace_order,
       TO_CHAR(start_date, 'DD-MON-YYYY') AS start_date,
       TO_CHAR(end_date, 'DD-MON-YYYY') AS end_date,
       grant_type,
       inverted_principal,
       principal,
       principal_type,
       privilege
FROM   dba_host_aces
ORDER BY host, ace_order;

--------------------------------------------------------------------------------
--- Permissions to invoke REST URLs for RestHeart
---
begin
  dbms_network_acl_admin.append_host_ace (
      host       => '*',
      lower_port => 8081,
      upper_port => 8081,
      ace        => xs$ace_type(privilege_list => xs$name_list('http'),
                                principal_name => 'logtest',
                                principal_type => xs_acl.ptype_db));
  end;
/
COMMIT;
--------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- PREPARE PATH TO FILES
-- Creare directory virtual și importare fișier CSV

drop directory ext_file_ds;
 
create or replace directory ext_file_ds as 'G:\1.ProiectIIS\superstore-dataset';
grant all on directory ext_file_ds to public;

select *
  from all_directories;
 
SELECT *
FROM ALL_TAB_PRIVS
WHERE TABLE_NAME = 'EXT_FILE_DS';

SELECT * 
FROM DBA_DIRECTORIES 
WHERE DIRECTORY_NAME = 'EXT_FILE_DS';


-------------------------------------------------------------------------------
--POSTGREREST creare rol
create role web_anon nologin;
grant usage on schema public to web_anon;

grant select on public.customers to web_anon;
grant select on public.products to web_anon;
grant select on public.orders to web_anon;
grant select on public.order_items to web_anon;

-- best practice, created role dedicated to connection of the db
create role authenticator noinherit login password 'mysecretpassword';
grant web_anon to authenticator;


-- configurari de pornit serverul
-- G:
-- cd \Development\PostgREST
-- postgrest postgres.conf

-- Server postgres pornit.