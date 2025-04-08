-- #### start restheart ###
-- 1. open a terminal
-- 2. G:
--3. cd G:\Development\restheart\restheart
--4.  java -jar restheart.jar -o conf-override.conf
--5. test connection.(in a new browser enter 'http://localhost:8081/ping')

-- Check Oracle ACL Security settings on REST host and port
-- Create an ACL to allow Oracle to call RESTHeart:
--- Permissions to invoke REST URLs for RestHeart

begin
  DBMS_NETWORK_ACL_ADMIN.append_host_ace (
      host       => 'localhost',
      lower_port => 8081,  
      upper_port => 8081,
      ace        => xs$ace_type(privilege_list => xs$name_list('http'),
                                principal_name => 'logtest',
                                principal_type => xs_acl.ptype_db));
  end;
/

-- WITH AUTH
-- metoda ataseaza token-ul la fiecare request.
--token-ul se creeaza pe baza username-ului si a parolei

CREATE OR REPLACE FUNCTION get_restheart_data_media(pURL VARCHAR2, pUserPass VARCHAR2) 
RETURN clob IS
  l_req   UTL_HTTP.req;
  l_resp  UTL_HTTP.resp;
  l_buffer clob; 
begin
  l_req  := UTL_HTTP.begin_request(pURL);
  UTL_HTTP.set_header(l_req, 'Authorization', 'Basic ' || 
    UTL_RAW.cast_to_varchar2(UTL_ENCODE.base64_encode(UTL_I18N.string_to_raw(pUserPass, 'AL32UTF8')))); 
  l_resp := UTL_HTTP.get_response(l_req);
  UTL_HTTP.READ_TEXT(l_resp, l_buffer);
  UTL_HTTP.end_response(l_resp);
  return l_buffer;
end;
/

--curl http://admin:secret@localhost:8081/SuperStoreDB/user_interactions
-- se adauga username si parola
SELECT get_restheart_data_media('http://localhost:8081/SuperStoreDB/user_interactions', 'admin:secret') from dual;


-- CREATE views mongodb
-- se prelucrează datele din MongoDB intr-un format relational
DROP VIEW view_user_interactions_mongodb

CREATE OR REPLACE VIEW view_user_interactions_mongodb AS
WITH json_data AS (
    SELECT get_restheart_data_media('http://localhost:8081/SuperStoreDB/user_interactions', 'admin:secret') AS doc
    FROM dual
)
SELECT 
    jt.user_interaction_id,
    jt.customer_id,
    jt.event_type,
    jt.page,
    TIMESTAMP '1970-01-01 00:00:00 UTC' + NUMTODSINTERVAL(jt.timestamp / 1000, 'SECOND') AS interaction_time
FROM 
    JSON_TABLE(
        (SELECT doc FROM json_data),
        '$[*]' COLUMNS (
            user_interaction_id VARCHAR2(50) PATH '$._id."$oid"',
            customer_id    NUMBER        PATH '$.customer_id',
            event_type     VARCHAR2(100) PATH '$.event_type',
            page           VARCHAR2(200) PATH '$.page',
            timestamp      NUMBER        PATH '$.timestamp."$date"'
        )
    ) jt;


SELECT * FROM view_user_interactions_mongodb;

--curl http://admin:secret@localhost:8081/SuperStoreDB/Feedback

SELECT get_restheart_data_media('http://localhost:8081/SuperStoreDB/feedback', 'admin:secret') from dual;

DROP VIEW view_feedback_mongodb

-- view_feedback_mongodb

CREATE OR REPLACE VIEW view_feedback_mongodb AS
WITH json_data AS (
    SELECT get_restheart_data_media('http://localhost:8081/SuperStoreDB/feedback', 'admin:secret') AS doc
    FROM dual
)
SELECT 
    jt.feedback_id,
    jt.customer_id,
    jt.order_id,
    jt.product_id,
    jt.rating,
    jt.feedback_comment,
    TIMESTAMP '1970-01-01 00:00:00 UTC' 
      + NUMTODSINTERVAL(jt.feedback_date / 1000, 'SECOND') AS feedback_time
FROM 
    JSON_TABLE(
        (SELECT doc FROM json_data),
        '$[*]' COLUMNS (
            feedback_id      VARCHAR2(50)   PATH '$._id."$oid"',
            customer_id      NUMBER         PATH '$.customer_id',
            order_id         NUMBER         PATH '$.order_id',
            product_id       NUMBER         PATH '$.product_id',
            rating           NUMBER         PATH '$.rating',
            feedback_comment VARCHAR2(4000) PATH '$.comment',
            feedback_date    NUMBER         PATH '$.feedback_date."$date"'
        )
    ) jt;

SELECT * FROM view_feedback_mongodb;

