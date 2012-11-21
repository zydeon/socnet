--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: get_posts(numeric, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_posts(numeric, numeric) RETURNS TABLE(id_message numeric, "from" character varying, id_attach numeric, text character varying, read_date date, image character, id_parent integer, rlevel integer)
    LANGUAGE plpgsql
    AS $_$
DECLARE	r 	RECORD;
		B 	numeric := 1;
BEGIN
	IF $2 IS NULL THEN
		FOR r IN 
			SELECT m.id_message, m."from", m.id_attach, m.text, m.read_date, m.image, p.id_parent, p.rlevel
			FROM message m, post p
			WHERE m.id_message = p.id_message AND
				  p.id_chatroom = $1 AND
				  p.id_parent IS NULL
			ORDER BY read_date DESC

			LOOP
				id_message := r.id_message;
				"from" := r."from";
				id_attach := r.id_attach;
				text := r.text;
				read_date := r.read_date;
				image := r.image;
				id_parent := r.id_parent;
				rlevel := r.rlevel;
				RETURN NEXT;
				RETURN QUERY SELECT * FROM get_posts($1, r.id_message);
			END LOOP;			
	ELSE
		FOR r IN 
			SELECT m.id_message, m."from", m.id_attach, m.text, m.read_date, m.image, p.id_parent, p.rlevel
			FROM message m, post p
			WHERE m.id_message = p.id_message AND
				  p.id_chatroom = $1 AND
				  p.id_parent = $2
			ORDER BY read_date	DESC

			LOOP
				id_message := r.id_message;
				"from" := r."from";
				id_attach := r.id_attach;
				text := r.text;
				read_date := r.read_date;
				image := r.image;
				id_parent := r.id_parent;
				rlevel := r.rlevel;
				RETURN NEXT;
				RETURN QUERY SELECT * FROM get_posts($1, r.id_message);
			END LOOP;			
	END IF;
	RETURN;
END;
$_$;


--
-- Name: getlevel(numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION getlevel(numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
        DECLARE
                rec RECORD;
        BEGIN
                rec = (SELECT rlevel FROM post WHERE id_message = $1);
                RETURN rec.rlevel+1;
        END;
$_$;


--
-- Name: increment(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION increment() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
                RETURN 1;
        END;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: attach; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE attach (
    id_attach numeric(10,0) NOT NULL,
    id_message numeric(10,0) NOT NULL,
    attach character(64000) NOT NULL
);


--
-- Name: chat_room_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE chat_room_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chat_room_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('chat_room_id_seq', 5, true);


--
-- Name: chat_room; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE chat_room (
    id_chatroom numeric(10,0) DEFAULT nextval('chat_room_id_seq'::regclass) NOT NULL,
    creator character varying(24) NOT NULL,
    theme character varying(20) NOT NULL,
    closed boolean NOT NULL,
    num_rates numeric(3,0) NOT NULL
);


--
-- Name: city_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE city_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: city_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('city_id_seq', 9, true);


--
-- Name: city; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE city (
    id_city numeric(10,0) DEFAULT nextval('city_id_seq'::regclass) NOT NULL,
    id_country numeric(10,0) NOT NULL,
    name character varying(100) NOT NULL
);


--
-- Name: country_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE country_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: country_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('country_id_seq', 7, true);


--
-- Name: country; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE country (
    id_country numeric(10,0) DEFAULT nextval('country_id_seq'::regclass) NOT NULL,
    name character varying(100) NOT NULL
);


--
-- Name: message_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE message_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('message_id_seq', 5, true);


--
-- Name: message; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE message (
    id_message numeric(10,0) DEFAULT nextval('message_id_seq'::regclass) NOT NULL,
    "from" character varying(24) NOT NULL,
    id_attach numeric(10,0),
    text character varying(250000),
    read_date date,
    sent_date date NOT NULL,
    image character(254),
    msg_type character(1) NOT NULL
);


--
-- Name: pm; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pm (
    id_message numeric(10,0) NOT NULL,
    "to" character varying(24) NOT NULL,
    read boolean NOT NULL
);


--
-- Name: post; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE post (
    id_message numeric(10,0) NOT NULL,
    id_chatroom numeric(10,0) NOT NULL,
    id_parent numeric(10,0),
    rlevel integer DEFAULT increment() NOT NULL
);


--
-- Name: rates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rates (
    "user" character varying(24) NOT NULL,
    id_chatroom numeric(10,0) NOT NULL,
    rate character(1)
);


--
-- Name: restrictions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE restrictions (
    "user" character varying(24) NOT NULL,
    id_chatroom numeric(10,0) NOT NULL,
    read boolean
);


--
-- Name: user; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "user" (
    login character varying(24) NOT NULL,
    id_city numeric(10,0),
    id_country numeric(10,0),
    pass character varying(66) NOT NULL,
    name character varying(100),
    birthdate date,
    email character varying(32),
    gender_male boolean,
    address character varying(100),
    public boolean NOT NULL,
    salt character varying(66)
);


--
-- Data for Name: attach; Type: TABLE DATA; Schema: public; Owner: -
--

COPY attach (id_attach, id_message, attach) FROM stdin;
\.


--
-- Data for Name: chat_room; Type: TABLE DATA; Schema: public; Owner: -
--

COPY chat_room (id_chatroom, creator, theme, closed, num_rates) FROM stdin;
2	asd	asdasd	t	0
4	asd	Outra	f	200
5	asd	Mais uma	f	1
\.


--
-- Data for Name: city; Type: TABLE DATA; Schema: public; Owner: -
--

COPY city (id_city, id_country, name) FROM stdin;
3	2	COIMBRA
7	3	hjgj
8	3	Oi
9	2	OLECA
\.


--
-- Data for Name: country; Type: TABLE DATA; Schema: public; Owner: -
--

COPY country (id_country, name) FROM stdin;
2	PORTUGAL
3	ITALY
4	SPAIN
5	GERMANY
6	FRANCE
7	UK
\.


--
-- Data for Name: message; Type: TABLE DATA; Schema: public; Owner: -
--

COPY message (id_message, "from", id_attach, text, read_date, sent_date, image, msg_type) FROM stdin;
10	asd	\N	HELLOOOO	2001-01-01	2001-01-01	\N	A
1	OI	\N	HEY YO	2012-11-15	2012-11-15	\N	A
2	OLE	\N	ASDSAD	2012-12-15	2012-12-15	\N	A
3	Pedro	\N	MBASBDHJASDBVSJABD	2012-12-20	2012-12-20	\N	A
4	OLE	\N	REPLY DO ALEX	2012-12-21	2012-12-21	\N	A
5	Pedro	\N	\N	\N	2012-11-21	\N	A
\.


--
-- Data for Name: pm; Type: TABLE DATA; Schema: public; Owner: -
--

COPY pm (id_message, "to", read) FROM stdin;
\.


--
-- Data for Name: post; Type: TABLE DATA; Schema: public; Owner: -
--

COPY post (id_message, id_chatroom, id_parent, rlevel) FROM stdin;
10	2	\N	0
1	2	\N	0
2	2	1	1
3	2	2	2
4	2	1	1
5	2	1	1
\.


--
-- Data for Name: rates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY rates ("user", id_chatroom, rate) FROM stdin;
\.


--
-- Data for Name: restrictions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY restrictions ("user", id_chatroom, read) FROM stdin;
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "user" (login, id_city, id_country, pass, name, birthdate, email, gender_male, address, public, salt) FROM stdin;
asd	\N	\N	0x96DAF6C824A962C316F69E9C6D0D087379F61A72ED77A8BA7793433535E55A21		\N		\N		f	0xB7D14C3CC1685EF52C8B4A3B6BD50E47EB168C7C33F35FA3C28CE0EC5897A06F
Pedro	8	3	0x02C4FB5E7D0F176EF2F838382A99F78D823EDCAB8AFC4BDEF4F2992A68202C7D		\N		\N		f	0x2F7204006AADDE8863185CA007C1CDEFFFED44318696864B17A7D2BA52802220
dsa	\N	\N	0xB93214E226211D3B2086F398D6A0A900B984FF6DEAC1C607DF14CA7A8108F9BB		\N		\N		f	0x4469D19E97FC080257D19314FF1B0170C1A60D9CBE1048439FC2D58BC1E08141
OI	\N	\N	0xE5AA0077712E28E6DA9E702EC7C7CE38DF793F8B5B39A8F141CD32F95B7C8B95		\N		\N		f	0x974BC81CC824C907DA695BA0C29CC9CD5C8C5FFB34825BF5CF47D4E6B16CB242
OLE	9	2	0x92769B13A7914AC6E212DF5C52773774558CE79B6CA7AEFECC4CBF57D3DB0E7D		\N		\N		f	0xC7CAB8D19C52943CD7C11C9531973FD5AFBEE146BFCC3F66F75C425D4A70BA16
\.


--
-- Name: pk_attach; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attach
    ADD CONSTRAINT pk_attach PRIMARY KEY (id_attach);


--
-- Name: pk_chat_room; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY chat_room
    ADD CONSTRAINT pk_chat_room PRIMARY KEY (id_chatroom);


--
-- Name: pk_city; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY city
    ADD CONSTRAINT pk_city PRIMARY KEY (id_city);


--
-- Name: pk_country; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY country
    ADD CONSTRAINT pk_country PRIMARY KEY (id_country);


--
-- Name: pk_message; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY message
    ADD CONSTRAINT pk_message PRIMARY KEY (id_message);


--
-- Name: pk_pm; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pm
    ADD CONSTRAINT pk_pm PRIMARY KEY (id_message);


--
-- Name: pk_post; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY post
    ADD CONSTRAINT pk_post PRIMARY KEY (id_message);


--
-- Name: pk_rates; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rates
    ADD CONSTRAINT pk_rates PRIMARY KEY ("user", id_chatroom);


--
-- Name: pk_restrictions; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY restrictions
    ADD CONSTRAINT pk_restrictions PRIMARY KEY ("user", id_chatroom);


--
-- Name: pk_user; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "user"
    ADD CONSTRAINT pk_user PRIMARY KEY (login);


--
-- Name: are_in_fk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX are_in_fk ON post USING btree (id_chatroom);


--
-- Name: attach_pk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX attach_pk ON attach USING btree (id_attach);


--
-- Name: belongs___fk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX belongs___fk ON "user" USING btree (id_country);


--
-- Name: belongs__fk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX belongs__fk ON "user" USING btree (id_city);


--
-- Name: belongs_fk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX belongs_fk ON city USING btree (id_country);


--
-- Name: can_do_fk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX can_do_fk ON rates USING btree ("user");


--
-- Name: can_have_fk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX can_have_fk ON rates USING btree (id_chatroom);


--
-- Name: chat_room_pk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX chat_room_pk ON chat_room USING btree (id_chatroom);


--
-- Name: city_pk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX city_pk ON city USING btree (id_city);


--
-- Name: country_pk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX country_pk ON country USING btree (id_country);


--
-- Name: create_fk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX create_fk ON chat_room USING btree (creator);


--
-- Name: has_2_fk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX has_2_fk ON message USING btree (id_attach);


--
-- Name: has__fk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX has__fk ON attach USING btree (id_message);


--
-- Name: has_fk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX has_fk ON restrictions USING btree ("user");


--
-- Name: is_in_fk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX is_in_fk ON restrictions USING btree (id_chatroom);


--
-- Name: message_pk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX message_pk ON message USING btree (id_message);


--
-- Name: pm_pk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX pm_pk ON pm USING btree (id_message);


--
-- Name: post_pk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX post_pk ON post USING btree (id_message);


--
-- Name: rates_pk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX rates_pk ON rates USING btree ("user", id_chatroom);


--
-- Name: receives_fk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX receives_fk ON pm USING btree ("to");


--
-- Name: reply_fk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX reply_fk ON post USING btree (id_parent);


--
-- Name: restrictions_pk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX restrictions_pk ON restrictions USING btree ("user", id_chatroom);


--
-- Name: sends_fk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX sends_fk ON message USING btree ("from");


--
-- Name: user_pk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX user_pk ON "user" USING btree (login);


--
-- Name: fk_attach_has__message; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY attach
    ADD CONSTRAINT fk_attach_has__message FOREIGN KEY (id_message) REFERENCES message(id_message) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_chat_roo_create_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY chat_room
    ADD CONSTRAINT fk_chat_roo_create_user FOREIGN KEY (creator) REFERENCES "user"(login) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_city_belongs_country; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY city
    ADD CONSTRAINT fk_city_belongs_country FOREIGN KEY (id_country) REFERENCES country(id_country) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_message_has_2_attach; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY message
    ADD CONSTRAINT fk_message_has_2_attach FOREIGN KEY (id_attach) REFERENCES attach(id_attach) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_message_sends_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY message
    ADD CONSTRAINT fk_message_sends_user FOREIGN KEY ("from") REFERENCES "user"(login) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_pm_heranca2_message; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pm
    ADD CONSTRAINT fk_pm_heranca2_message FOREIGN KEY (id_message) REFERENCES message(id_message) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_pm_receives_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pm
    ADD CONSTRAINT fk_pm_receives_user FOREIGN KEY ("to") REFERENCES "user"(login) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_post_are_in_chat_roo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post
    ADD CONSTRAINT fk_post_are_in_chat_roo FOREIGN KEY (id_chatroom) REFERENCES chat_room(id_chatroom) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_post_heranca_message; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post
    ADD CONSTRAINT fk_post_heranca_message FOREIGN KEY (id_message) REFERENCES message(id_message) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_post_reply_post; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post
    ADD CONSTRAINT fk_post_reply_post FOREIGN KEY (id_parent) REFERENCES post(id_message) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_rates_can_do_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rates
    ADD CONSTRAINT fk_rates_can_do_user FOREIGN KEY ("user") REFERENCES "user"(login) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_rates_can_have_chat_roo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rates
    ADD CONSTRAINT fk_rates_can_have_chat_roo FOREIGN KEY (id_chatroom) REFERENCES chat_room(id_chatroom) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_restrict_has_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY restrictions
    ADD CONSTRAINT fk_restrict_has_user FOREIGN KEY ("user") REFERENCES "user"(login) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_restrict_is_in_chat_roo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY restrictions
    ADD CONSTRAINT fk_restrict_is_in_chat_roo FOREIGN KEY (id_chatroom) REFERENCES chat_room(id_chatroom) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_user_belongs___country; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "user"
    ADD CONSTRAINT fk_user_belongs___country FOREIGN KEY (id_country) REFERENCES country(id_country) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_user_belongs__city; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "user"
    ADD CONSTRAINT fk_user_belongs__city FOREIGN KEY (id_city) REFERENCES city(id_city) ON UPDATE RESTRICT ON DELETE RESTRICT;


CREATE USER socnet_user WITH PASSWORD 'dbdb';
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO socnet_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO socnet_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO socnet_user