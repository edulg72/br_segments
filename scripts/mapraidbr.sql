--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Name: vw_mp_refresh_table(); Type: FUNCTION; Schema: public; Owner: waze
--

CREATE FUNCTION vw_mp_refresh_table() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  drop table if exists vw_mp;
  create table vw_mp as
    select mp.id, mp.resolved_by, mp.resolved_on, mp.weight, st_x(mp.position) as longitude, st_y(mp.position) as latitude, mp.resolution, mp.city_id from mp;
end;
$$;


ALTER FUNCTION public.vw_mp_refresh_table() OWNER TO waze;

--
-- Name: vw_places_refresh_table(); Type: FUNCTION; Schema: public; Owner: waze
--

CREATE FUNCTION vw_places_refresh_table() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  drop table if exists vw_places;
  create table vw_places as
    select id, name, street_id, created_on, created_by, updated_on, updated_by, st_x(position) as longitude, st_y(position) as latitude, lock, approved, residential, category, ad_locked, city_id from places;
  create index idx_places_city_id on vw_places (city_id nulls last);
end;
$$;


ALTER FUNCTION public.vw_places_refresh_table() OWNER TO waze;

--
-- Name: vw_pu_refresh_table(); Type: FUNCTION; Schema: public; Owner: waze
--

CREATE FUNCTION vw_pu_refresh_table() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  drop table if exists vw_pu;
  create table vw_pu as
    select p.id as id,
           pu.created_by as created_by,
           pu.created_on as created_on,
           ST_X(pu.position) as longitude,
           ST_Y(pu.position) as latitude,
           pu.staff as staff,
           coalesce(p.name, '[No Name]'::character varying) as name,
           pu.city_id as city_id
    from places p, pu
    where p.id = pu.place_id;
end;
$$;


ALTER FUNCTION public.vw_pu_refresh_table() OWNER TO waze;

--
-- Name: vw_ur_refresh_table(); Type: FUNCTION; Schema: public; Owner: waze
--

CREATE FUNCTION vw_ur_refresh_table() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  drop table if exists vw_ur;
  create table vw_ur as
    select id, comments, last_comment, last_comment_on, last_comment_by, first_comment_on, resolved_by, resolved_on, created_on, st_x(position) as longitude, st_y(position) as latitude, resolution, city_id from ur;
    create index idx_ur_city_id on vw_ur (city_id nulls last);
end;
$$;


ALTER FUNCTION public.vw_ur_refresh_table() OWNER TO waze;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: areas_mapraid; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE areas_mapraid (
    id integer NOT NULL,
    name character varying(100),
    map_name character varying(50)
);


ALTER TABLE areas_mapraid OWNER TO waze;

--
-- Name: cities; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE cities (
    id integer NOT NULL,
    name character varying(50),
    isempty boolean,
    state_id integer
);


ALTER TABLE cities OWNER TO waze;

--
-- Name: cities_mapraid; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE cities_mapraid (
    gid integer NOT NULL,
    name character varying(49),
    geom geometry(MultiPolygon,4326),
    city_id integer,
    area_id integer
);


ALTER TABLE cities_mapraid OWNER TO waze;

--
-- Name: cities_mapraid_gid_seq; Type: SEQUENCE; Schema: public; Owner: waze
--

CREATE SEQUENCE cities_mapraid_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cities_mapraid_gid_seq OWNER TO waze;

--
-- Name: cities_mapraid_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: waze
--

ALTER SEQUENCE cities_mapraid_gid_seq OWNED BY cities_mapraid.gid;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE countries (
    id integer NOT NULL,
    name character varying(50)
);


ALTER TABLE countries OWNER TO waze;

--
-- Name: mp; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE mp (
    id character varying(20) NOT NULL,
    resolved_by integer,
    resolved_on timestamp without time zone,
    weight integer,
    "position" geometry(Point,4326),
    resolution integer,
    city_id integer
);


ALTER TABLE mp OWNER TO waze;

--
-- Name: places; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE places (
    id character varying(50) NOT NULL,
    name character varying(100),
    street_id integer,
    created_on timestamp without time zone,
    created_by integer,
    updated_on timestamp without time zone,
    updated_by integer,
    "position" geometry(Point,4326),
    lock integer,
    approved boolean,
    residential boolean,
    category character varying(40),
    ad_locked boolean,
    city_id character varying(7)
);


ALTER TABLE places OWNER TO waze;

--
-- Name: pu; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE pu (
    id character varying(60) NOT NULL,
    created_by integer,
    created_on timestamp without time zone,
    "position" geometry(Point,4326),
    staff boolean,
    city_id integer,
    place_id character varying(50)
);


ALTER TABLE pu OWNER TO waze;

--
-- Name: segments; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE segments (
    id integer NOT NULL,
    latitude real,
    longitude real,
    length integer,
    level smallint,
    last_edit_on timestamp without time zone,
    last_edit_by integer,
    lock smallint,
    connected boolean,
    street_id integer,
    roadtype smallint,
    dc_density smallint,
    fwdmaxspeed integer,
    revmaxspeed integer,
    fwddirection boolean,
    revdirection boolean,
    city_id integer
);


ALTER TABLE segments OWNER TO waze;

--
-- Name: states; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE states (
    id integer NOT NULL,
    name character varying(50),
    country_id integer,
    abbreviation character varying(2),
    updated_at timestamp without time zone
);


ALTER TABLE states OWNER TO waze;

--
-- Name: states_shapes; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE states_shapes (
    gid integer NOT NULL,
    cvegeo character varying(2),
    nombre character varying(31),
    pob1 integer,
    pob2 integer,
    pob2_r double precision,
    pob3 integer,
    pob3_r double precision,
    pob4 integer,
    pob4_r double precision,
    pob5 integer,
    pob5_r double precision,
    pob6 integer,
    pob6_r double precision,
    pob7 integer,
    pob7_r double precision,
    pob8 integer,
    pob8_r double precision,
    pob9 integer,
    pob9_r double precision,
    pob10 integer,
    pob10_r double precision,
    pob11 integer,
    pob11_r double precision,
    pob12 integer,
    pob12_r double precision,
    pob13 integer,
    pob13_r double precision,
    pob14 integer,
    pob14_r double precision,
    pob15 integer,
    pob15_r double precision,
    pob16 integer,
    pob16_r double precision,
    pob17 integer,
    pob17_r double precision,
    pob18 integer,
    pob18_r double precision,
    pob19 integer,
    pob19_r double precision,
    pob20 integer,
    pob20_r double precision,
    pob21 integer,
    pob21_r double precision,
    pob22 integer,
    pob22_r double precision,
    pob23 integer,
    pob23_r double precision,
    pob24 integer,
    pob24_r double precision,
    pob25 integer,
    pob25_r double precision,
    pob26_r double precision,
    pob27_r double precision,
    pob28_r double precision,
    pob29_r double precision,
    pob30_r double precision,
    pob31 integer,
    pob31_r double precision,
    pob32 integer,
    pob32_r double precision,
    pob33 integer,
    pob33_r double precision,
    pob34 integer,
    pob34_r double precision,
    pob35 integer,
    pob35_r double precision,
    pob36 integer,
    pob36_r double precision,
    pob37 integer,
    pob37_r double precision,
    pob38 integer,
    pob38_r double precision,
    pob39 integer,
    pob39_r double precision,
    pob40 integer,
    pob40_r double precision,
    pob41 integer,
    pob41_r double precision,
    pob42 integer,
    pob42_r double precision,
    pob43 integer,
    pob43_r double precision,
    pob44 integer,
    pob44_r double precision,
    pob45 integer,
    pob45_r double precision,
    pob46 integer,
    pob46_r double precision,
    pob47 integer,
    pob47_r double precision,
    pob48 integer,
    pob48_r double precision,
    pob49 integer,
    pob49_r double precision,
    pob50 integer,
    pob50_r double precision,
    pob51 integer,
    pob51_r double precision,
    pob52 integer,
    pob52_r double precision,
    pob53 integer,
    pob53_r double precision,
    pob54 integer,
    pob54_r double precision,
    pob55 integer,
    pob55_r double precision,
    pob56 integer,
    pob56_r double precision,
    pob57 integer,
    pob57_r double precision,
    pob58 integer,
    pob58_r double precision,
    pob59 integer,
    pob59_r double precision,
    pob60 integer,
    pob60_r double precision,
    pob61 integer,
    pob61_r double precision,
    pob62 integer,
    pob62_r double precision,
    pob63 integer,
    pob63_r double precision,
    pob64 integer,
    pob64_r double precision,
    pob65 integer,
    pob65_r double precision,
    pob66 integer,
    pob66_r double precision,
    pob67 integer,
    pob67_r double precision,
    pob68 integer,
    pob68_r double precision,
    pob69 integer,
    pob69_r double precision,
    pob70 integer,
    pob70_r double precision,
    pob71 integer,
    pob71_r double precision,
    pob72 integer,
    pob72_r double precision,
    pob73 integer,
    pob73_r double precision,
    pob74 integer,
    pob74_r double precision,
    pob75 integer,
    pob75_r double precision,
    pob76 integer,
    pob76_r double precision,
    pob77 integer,
    pob77_r double precision,
    pob78 integer,
    pob78_r double precision,
    pob79 integer,
    pob79_r double precision,
    pob80 integer,
    pob80_r double precision,
    pob81 integer,
    pob81_r double precision,
    __oid integer,
    geom geometry(MultiPolygon,4326)
);


ALTER TABLE states_shapes OWNER TO waze;

--
-- Name: states_shapes_gid_seq; Type: SEQUENCE; Schema: public; Owner: waze
--

CREATE SEQUENCE states_shapes_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE states_shapes_gid_seq OWNER TO waze;

--
-- Name: states_shapes_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: waze
--

ALTER SEQUENCE states_shapes_gid_seq OWNED BY states_shapes.gid;


--
-- Name: streets; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE streets (
    id integer NOT NULL,
    name character varying(100),
    isempty boolean,
    city_id integer
);


ALTER TABLE streets OWNER TO waze;

--
-- Name: updates; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE updates (
    updated_at timestamp with time zone,
    object character varying(20) NOT NULL
);


ALTER TABLE updates OWNER TO waze;

--
-- Name: ur; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE ur (
    id integer NOT NULL,
    comments integer,
    last_comment text,
    last_comment_on timestamp with time zone,
    last_comment_by integer,
    first_comment_on timestamp with time zone,
    resolved_by integer,
    resolved_on timestamp with time zone,
    created_on timestamp with time zone,
    "position" geometry(Point,4326),
    resolution integer,
    city_id integer
);


ALTER TABLE ur OWNER TO waze;

--
-- Name: users; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    username character varying(50),
    rank integer
);


ALTER TABLE users OWNER TO waze;

--
-- Name: vw_mp; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE vw_mp (
    id character varying(20),
    resolved_by integer,
    resolved_on timestamp without time zone,
    weight integer,
    longitude double precision,
    latitude double precision,
    resolution integer,
    city_id integer
);


ALTER TABLE vw_mp OWNER TO waze;

--
-- Name: vw_pu; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE vw_pu (
    id character varying(50),
    created_by integer,
    created_on timestamp without time zone,
    longitude double precision,
    latitude double precision,
    staff boolean,
    name character varying,
    city_id integer
);


ALTER TABLE vw_pu OWNER TO waze;

--
-- Name: vw_ur; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE vw_ur (
    id integer,
    comments integer,
    last_comment text,
    last_comment_on timestamp with time zone,
    last_comment_by integer,
    first_comment_on timestamp with time zone,
    resolved_by integer,
    resolved_on timestamp with time zone,
    created_on timestamp with time zone,
    longitude double precision,
    latitude double precision,
    resolution integer,
    city_id integer
);


ALTER TABLE vw_ur OWNER TO waze;

--
-- Name: gid; Type: DEFAULT; Schema: public; Owner: waze
--

ALTER TABLE ONLY cities_mapraid ALTER COLUMN gid SET DEFAULT nextval('cities_mapraid_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: public; Owner: waze
--

ALTER TABLE ONLY states_shapes ALTER COLUMN gid SET DEFAULT nextval('states_shapes_gid_seq'::regclass);


--
-- Name: areas_mapraid_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY areas_mapraid
    ADD CONSTRAINT areas_mapraid_pkey PRIMARY KEY (id);


--
-- Name: cities_mapraid_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY cities_mapraid
    ADD CONSTRAINT cities_mapraid_pkey PRIMARY KEY (gid);


--
-- Name: cities_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: mp_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY mp
    ADD CONSTRAINT mp_pkey PRIMARY KEY (id);


--
-- Name: pk_atualizacao; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT pk_atualizacao PRIMARY KEY (object);


--
-- Name: places_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY places
    ADD CONSTRAINT places_pkey PRIMARY KEY (id);


--
-- Name: pu_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY pu
    ADD CONSTRAINT pu_pkey PRIMARY KEY (id);


--
-- Name: segments_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY segments
    ADD CONSTRAINT segments_pkey PRIMARY KEY (id);


--
-- Name: states_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: states_shapes_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY states_shapes
    ADD CONSTRAINT states_shapes_pkey PRIMARY KEY (gid);


--
-- Name: streets_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY streets
    ADD CONSTRAINT streets_pkey PRIMARY KEY (id);


--
-- Name: ur_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY ur
    ADD CONSTRAINT ur_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_ur_city_id; Type: INDEX; Schema: public; Owner: waze; Tablespace: 
--

CREATE INDEX idx_ur_city_id ON vw_ur USING btree (city_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: waze
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM waze;
GRANT ALL ON SCHEMA public TO waze;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

