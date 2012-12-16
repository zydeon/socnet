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


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET search_path = public, pg_catalog;

--
-- Name: add_chatroom(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION add_chatroom(creator_ character varying, theme_ character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO chat_room (creator, theme) VALUES (creator_, theme_);
	EXCEPTION WHEN unique_violation THEN
		RAISE EXCEPTION 'Error: theme already exists';
	WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'Error: invalid creator login';

END;
$$;


--
-- Name: auth_user(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION auth_user(user_login character varying, pass character varying) RETURNS boolean
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE
disabled_ boolean;
salt_ varchar;
res integer;
BEGIN
SELECT salt, disabled INTO salt_, disabled_ FROM "user" WHERE login LIKE user_login;
IF disabled_ = false THEN
SELECT COUNT(*) INTO res
FROM "user"
WHERE login LIKE user_login AND pwhash LIKE generate_hash(pass, salt_);

IF res = 1 THEN
RETURN true;
END IF;
END IF;

RETURN false;
END;
$$;


--
-- Name: generate_hash(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION generate_hash(pass character varying, salt character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
hash varchar;
BEGIN
SELECT INTO hash crypt(pass, salt);
RETURN hash;
END;
$$;


--
-- Name: generate_salt(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION generate_salt() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
salt varchar;
BEGIN
SELECT INTO salt gen_salt('md5');
RETURN salt;
END;
$$;


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

SELECT pg_catalog.setval('chat_room_id_seq', 13, true);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: chat_room; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE chat_room (
    id_chatroom numeric(10,0) DEFAULT nextval('chat_room_id_seq'::regclass) NOT NULL,
    creator character varying(24) NOT NULL,
    theme character varying(20) NOT NULL,
    closed boolean DEFAULT false NOT NULL,
    "ratesY" numeric(3,0) DEFAULT 0 NOT NULL,
    "ratesM" numeric(3,0) DEFAULT 0 NOT NULL,
    "ratesN" numeric(3,0) DEFAULT 0 NOT NULL
);


--
-- Name: get_chatrooms(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_chatrooms() RETURNS SETOF chat_room
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT * FROM chat_room WHERE closed=false;
END;
$$;


--
-- Name: get_cityid(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_cityid(city_name character varying) RETURNS integer
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE
id integer;
BEGIN
SELECT id_city INTO id
FROM city
WHERE name LIKE city_name;

-- not found, create
IF id IS NULL THEN 
SELECT nextval('city_id_seq') INTO id;
INSERT INTO city
VALUES (id, city_name);
END IF;

RETURN id;
END;
$$;


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
-- Name: get_countries(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_countries() RETURNS SETOF country
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT * FROM country;
END;
$$;


--
-- Name: get_posts(numeric, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_posts(id_chat numeric, id_parent_ numeric) RETURNS TABLE(id_message numeric, "from" character varying, text character varying, sent_date date, rlevel integer, file_path character varying)
    LANGUAGE plpgsql
    AS $_$
DECLARE	r 	RECORD;
BEGIN
	-- IF id_parent_ IS NULL THEN
		FOR r IN 
			SELECT m.id_message, m."from", m.text, m.sent_date, p.rlevel, m.attach_path
			FROM message m, post p
			WHERE m.id_message = p.id_message AND
				  p.id_chatroom = $1 AND
				  ((id_parent_ IS NULL AND p.id_parent IS NULL) OR
				  (id_parent_ IS NOT NULL AND p.id_parent = id_parent_))

			ORDER BY sent_date DESC

			LOOP
				id_message 	:= r.id_message;
				"from" 		:= r."from";
				text 		:= r.text;
				sent_date 	:= r.sent_date;
				rlevel 		:= r.rlevel;
				file_path   := r.attach_path;
				RETURN NEXT;
				RETURN QUERY SELECT * FROM get_posts(id_chat, r.id_message);
			END LOOP;			
	-- ELSE
	-- 	FOR r IN 
	-- 		SELECT m.id_message, m."from", m.id_attach, m.text, m.sent_date, m.image, p.id_parent, p.rlevel
	-- 		FROM message m, post p
	-- 		WHERE m.id_message = p.id_message AND
	-- 			  p.id_chatroom = $1 AND
	-- 			  p.id_parent = $2
	-- 		ORDER BY sent_date	DESC

	-- 		LOOP
	-- 			id_message := r.id_message;
	-- 			"from" := r."from";
	-- 			id_attach := r.id_attach;
	-- 			text := r.text;
	-- 			sent_date := r.sent_date;
	-- 			image := r.image;
	-- 			id_parent := r.id_parent;
	-- 			rlevel := r.rlevel;
	-- 			RETURN NEXT;
	-- 			RETURN QUERY SELECT * FROM get_posts($1, r.id_message);
	-- 		END LOOP;			
	-- END IF;
	RETURN;
END;
$_$;


--
-- Name: register_user(character varying, character varying, character varying, integer, character varying, date, character varying, character varying, boolean, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION register_user(user_login character varying, pass_ character varying, name_ character varying, id_country_ integer, city_name_ character varying, birthdate_ date, email_ character varying, address_ character varying, public_ boolean, gender_male_ boolean) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
id_city_ integer := NULL;
salt_ varchar;
hash_ varchar;
BEGIN
IF city_name_ IS NOT NULL AND city_name_ NOT LIKE '' THEN
SELECT get_cityid(city_name_) INTO id_city_;
END IF;

SELECT generate_salt() INTO salt_;
SELECT generate_hash(pass_, salt_) INTO hash_;

INSERT INTO "user"
(login, id_city, id_country, pwhash, name, birthdate, email, gender_male, address, public, salt, disabled)
VALUES
(user_login, id_city_, id_country_, hash_, name_, birthdate_, email_, gender_male_, address_, public_, salt_, false);

EXCEPTION
WHEN unique_violation THEN
RAISE EXCEPTION 'User already exists!';

END;
$$;


--
-- Name: set_rlevel(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION set_rlevel() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF NEW.id_parent IS NOT NULL THEN
		UPDATE post SET rlevel=(
					SELECT rlevel+1 FROM post WHERE id_message = NEW.id_parent )
		WHERE id_message = NEW.id_message;
	END IF;
	RETURN NEW;
END;
$$;


--
-- Name: teste(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION teste() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
var integer;
BEGIN
SELECT id_city INTO var FROM city WHERE id_city = 60;
EXCEPTION
WHEN no_data_found THEN
RAISE NOTICE 'OI';
END;
$$;


--
-- Name: update_chatroom(integer, character varying, character varying, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_chatroom(id_chatroom_ integer, creator_ character varying, theme_ character varying, closed_ boolean) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	n integer := 0;
BEGIN
	SELECT count(*) INTO n from chat_room WHERE id_chatroom=id_chatroom_ AND creator=creator_;
	IF n < 1 THEN
		RAISE EXCEPTION 'Error: this action can only be performed by the chatroom creator';
	END IF;
	UPDATE chat_room SET theme=theme_, closed=closed_ WHERE id_chatroom=id_chatroom_;
	EXCEPTION WHEN unique_violation THEN
		RAISE EXCEPTION 'Error: theme already exists';
	WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'Error: invalid creator login';

END;
$$;


--
-- Name: user_exists(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION user_exists(user_login character varying) RETURNS boolean
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE
res integer;
BEGIN
SELECT COUNT(*) INTO res FROM "user" WHERE login LIKE user_login;
IF res = 1 THEN
RETURN true;
END IF;
RETURN false;
END;
$$;


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

SELECT pg_catalog.setval('city_id_seq', 18, true);


--
-- Name: city; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE city (
    id_city numeric(10,0) DEFAULT nextval('city_id_seq'::regclass) NOT NULL,
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

SELECT pg_catalog.setval('message_id_seq', 11, true);


--
-- Name: message; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE message (
    id_message numeric(10,0) DEFAULT nextval('message_id_seq'::regclass) NOT NULL,
    "from" character varying(24) NOT NULL,
    text character varying(250000),
    read_date date,
    sent_date timestamp without time zone DEFAULT date_trunc('second'::text, now()) NOT NULL,
    msg_type character(1) NOT NULL,
    attach_path character varying(256)
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
    rlevel integer DEFAULT 1 NOT NULL
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
    pwhash character varying(34) NOT NULL,
    name character varying(100),
    birthdate date,
    email character varying(32),
    gender_male boolean,
    address character varying(100),
    public boolean NOT NULL,
    salt character varying(11) NOT NULL,
    disabled boolean NOT NULL
);


--
-- Data for Name: chat_room; Type: TABLE DATA; Schema: public; Owner: -
--

COPY chat_room (id_chatroom, creator, theme, closed, "ratesY", "ratesM", "ratesN") FROM stdin;
11	q	OI	f	0	0	0
12	e	HEY	f	0	0	0
13	q	a	f	0	0	0
\.


--
-- Data for Name: city; Type: TABLE DATA; Schema: public; Owner: -
--

COPY city (id_city, name) FROM stdin;
3	COIMBRA
7	hjgj
8	Oi
9	OLECA
10	London
69	YOO
15	ASD
16	
17	a
18	aasd
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

COPY message (id_message, "from", text, read_date, sent_date, msg_type, attach_path) FROM stdin;
10	a	UM	\N	2012-12-13 15:29:25	B	\N
11	a	DOIS	\N	2012-12-13 16:02:20	B	\N
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
10	11	\N	0
11	11	10	1
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

COPY "user" (login, id_city, id_country, pwhash, name, birthdate, email, gender_male, address, public, salt, disabled) FROM stdin;
q	17	3	$1$.NOQ0STv$MEI9.u2IdapzdWfCoZitM0	null	\N	q	t	q	f	$1$.NOQ0STv	f
w	\N	\N	$1$eLCgAA4K$RcZWFH10h1yDef5HAjwzV0		\N		t		f	$1$eLCgAA4K	f
e	\N	\N	$1$cN/R/azI$A0.rsy4XiJrDDpf0FsZfE0		\N		\N		f	$1$cN/R/azI	f
a	\N	\N	$1$Aq57apJs$1Bi8dTVNFys8MyMD0Dlf61		\N		\N		f	$1$Aq57apJs	f
s	\N	\N	$1$WEaolxFn$2mEzDrvpl.jC.6TcTxhUx1		\N		\N		f	$1$WEaolxFn	f
\.


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
-- Name: belongs___fk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX belongs___fk ON "user" USING btree (id_country);


--
-- Name: belongs__fk; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX belongs__fk ON "user" USING btree (id_city);


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
-- Name: update_rlevel; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rlevel AFTER INSERT ON post FOR EACH ROW EXECUTE PROCEDURE set_rlevel();


--
-- Name: fk_chat_roo_create_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY chat_room
    ADD CONSTRAINT fk_chat_roo_create_user FOREIGN KEY (creator) REFERENCES "user"(login) ON UPDATE RESTRICT ON DELETE RESTRICT;


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


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

DROP ROLE IF EXISTS socnet_user;
DROP USER IF EXISTS socnet_user;
CREATE USER socnet_user WITH PASSWORD 'dbdb';
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO socnet_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO socnet_user;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO socnet_user;
