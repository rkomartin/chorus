DROP DATABASE IF EXISTS "gpdb_test_database";
CREATE DATABASE "gpdb_test_database" OWNER gpadmin;

\connect "gpdb_test_database"

  CREATE SCHEMA gpdb_test_schema;
    SET search_path TO 'gpdb_test_schema';

    CREATE TABLE base_table1
      (id integer, column1 integer, column2 integer, category text, time_value timestamp )
      DISTRIBUTED BY (id);
    COMMENT ON TABLE base_table1 IS 'comment on base_table1';
    INSERT INTO base_table1 VALUES ( 0,0,0, 'apple', '2012-03-01 00:00:02' );
    INSERT INTO base_table1 VALUES ( 1,1,1, 'apple', '2012-03-02 00:00:02' );
    INSERT INTO base_table1 VALUES ( 2,0,2, 'orange' , '2012-04-01 00:00:02');
    INSERT INTO base_table1 VALUES ( 3,1,3, 'orange' , '2012-03-05 00:00:02');
    INSERT INTO base_table1 VALUES ( 4,1,4, 'orange' , '2012-03-04 00:02:02');
    INSERT INTO base_table1 VALUES ( 5,0,5, 'papaya' , '2012-05-01 00:02:02');
    INSERT INTO base_table1 VALUES ( 6,1,6, 'papaya' , '2012-04-08 00:10:02');
    INSERT INTO base_table1 VALUES ( 7,1,7, 'papaya' , '2012-05-11 00:10:02');
    INSERT INTO base_table1 VALUES ( 8,1,8, 'papaya' , '2012-04-09 00:00:02');
    ANALYZE base_table1;

    CREATE VIEW view1 AS
      SELECT * FROM base_table1;
    COMMENT ON VIEW view1 IS 'comment on view1';

    CREATE EXTERNAL WEB TABLE external_web_table1
      (name text, date date, amount float4, category text, description text)
      LOCATION ('http://intranet.company.com/expenses/sales/file.csv')
      FORMAT 'CSV'
      ( HEADER );
    COMMENT ON TABLE external_web_table1 IS '';
    ANALYZE external_web_table1;

    CREATE TABLE master_table1
      ( id integer, some_int integer )
      DISTRIBUTED BY (id)
      PARTITION BY RANGE(some_int)
      ( START (1::integer) END (8::integer) EVERY (1::integer));
    COMMENT ON TABLE master_table1 IS 'comment on master_table1';
    ANALYZE master_table1;

    CREATE UNIQUE INDEX index1 ON base_table1 ( id );

    CREATE TYPE complex AS (
        r       double precision,
        i       double precision
    );
    CREATE TABLE pg_all_types (
        t_composite complex,
        t_decimal numeric,
        t_array integer[],
        t_bigint bigint,
        t_bigserial bigint NOT NULL,
        t_bit bit(5),
        t_varbit bit varying(10),
        t_bool boolean,
        t_box pg_catalog.box,
        t_bytea pg_catalog.bytea,
        t_varchar character varying(10),
        t_char character(10),
        t_cidr pg_catalog.cidr,
        t_circle pg_catalog.circle,
        t_date pg_catalog.date,
        t_double double precision,
        t_inet pg_catalog.inet,
        t_integer integer,
        t_interval interval,
        t_lseg pg_catalog.lseg,
        t_macaddr pg_catalog.macaddr,
        t_money pg_catalog.money,
        t_numeric numeric(5,5),
        t_path pg_catalog.path,
        t_point pg_catalog.point,
        t_polygon pg_catalog.polygon,
        t_real real,
        t_smallint smallint,
        t_serial integer NOT NULL,
        t_text pg_catalog.text,
        t_time_without_time_zone time without time zone,
        t_time_with_time_zone time with time zone,
        t_timestamp_without_time_zone timestamp without time zone,
        t_timestamp_with_time_zone timestamp with time zone
    );
    CREATE SEQUENCE pg_all_types_t_bigserial_seq
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE pg_all_types_t_bigserial_seq OWNED BY pg_all_types.t_bigserial;
    SELECT pg_catalog.setval('pg_all_types_t_bigserial_seq', 1, false);
    CREATE SEQUENCE pg_all_types_t_serial_seq
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE pg_all_types_t_serial_seq OWNED BY pg_all_types.t_serial;
    SELECT pg_catalog.setval('pg_all_types_t_serial_seq', 1, false);
    ALTER TABLE pg_all_types ALTER COLUMN t_bigserial SET DEFAULT nextval('pg_all_types_t_bigserial_seq'::regclass);
    ALTER TABLE pg_all_types ALTER COLUMN t_serial SET DEFAULT nextval('pg_all_types_t_serial_seq'::regclass);
    INSERT INTO pg_all_types VALUES
        (
            '(1,2)',
            1.2,
            '{1,2,3}',
            1,
            1,
            B'10101',
            B'101',
            true,
            '(2,2),(1,1)',
            'xDEADBEEF',
            'var char',
            'char      ',
            '192.168.100.128/25',
            '<(1,2),3>',
            '2011-01-01',
            10.01,
            '192.168.100.128',
            10,
            '3 days 04:05:06',
            '[(1,1),(2,2)]',
            '08:00:2b:01:02:03',
            '$1,000.00',
            0.02000,
            '[(1,1),(2,2),(3,3)]',
            '(0,0)',
            '((10,10),(20,20),(30,30))',
            1.1,
            1,
            2,
            'text',
            '04:05:06',
            '01:02:03-08',
            '1999-01-08 04:05:06',
            '1999-01-08 04:05:06-08'
         );

  \dtvs gpdb_test_schema.*


  CREATE SCHEMA gpdb_test_schema2;
    SET search_path TO 'gpdb_test_schema2';

    CREATE TABLE other_base_table
      (id integer)
      DISTRIBUTED BY (id);
    COMMENT ON TABLE other_base_table IS '';
    ANALYZE other_base_table;

  \dtvs gpdb_test_schema2.*

DROP DATABASE IF EXISTS "gpdb_test_database_without_public_schema";
CREATE DATABASE "gpdb_test_database_without_public_schema" OWNER gpadmin;

\connect "gpdb_test_database_without_public_schema"

  DROP SCHEMA public;

  CREATE SCHEMA gpdb_test_schema_in_db_without_public_schema;
    SET search_path TO 'gpdb_test_schema_in_db_without_public_schema';

    CREATE TABLE base_table1
      (id integer, column1 integer, column2 integer)
      DISTRIBUTED BY (id);
    INSERT INTO base_table1 VALUES ( 0,0,0 );

  \dtvs gpdb_test_schema_in_db_without_public_schema.*