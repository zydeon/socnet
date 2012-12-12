-- USER_EXISTS()
CREATE OR REPLACE FUNCTION user_exists(user_login varchar) RETURNS boolean AS $$
DECLARE
	res 	integer;
BEGIN
	SELECT COUNT(*) INTO res FROM "user" WHERE login LIKE user;
	IF res = 1 THEN
		RETURN true;
	END IF;
	RETURN false;
END;
$$
LANGUAGE plpgsql
RETURNS NULL ON NULL INPUT;

-- GENERATE_SALT()
CREATE OR REPLACE FUNCTION generate_salt() RETURNS varchar AS $$
DECLARE
	salt 	varchar;
BEGIN
	SELECT INTO salt gen_salt('md5');
	RETURN salt;
END;
$$
LANGUAGE plpgsql;

-- GENERATE_HASH()
CREATE OR REPLACE FUNCTION generate_hash(pass varchar, salt varchar) RETURNS varchar AS $$
DECLARE
	hash 	varchar;
BEGIN
	SELECT INTO hash crypt(pass, salt);
	RETURN hash;
END;
$$
LANGUAGE plpgsql;

-- AUTH_USER()
CREATE OR REPLACE FUNCTION auth_user(user_login varchar, pass varchar) RETURNS boolean AS $$
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
$$
LANGUAGE plpgsql
RETURNS NULL ON NULL INPUT;

-- GET_CITYID()
CREATE OR REPLACE FUNCTION get_cityid(city_name varchar) RETURNS integer AS $$
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
$$
LANGUAGE plpgsql
RETURNS NULL ON NULL INPUT;

-- REGISTER_USER()
CREATE OR REPLACE FUNCTION register_user(user_login varchar, pass_ varchar, name_ varchar, id_country_ integer, city_name_ varchar, birthdate_ date, email_ varchar, address_ varchar, public_ boolean, gender_male_ boolean)
RETURNS VOID AS
$$
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
$$
LANGUAGE plpgsql;

-- GET_USER_INFO()
CREATE OR REPLACE FUNCTION get_user_info(user_login varchar)
RETURNS TABLE(login varchar, id_city numeric, city_name varchar, id_country numeric, country_name varchar, name varchar, birthdate date, email varchar, gender_male boolean, address varchar, public boolean, disabled boolean) AS $$
DECLARE
	r RECORD;
BEGIN
	FOR r IN SELECT u.*, co.name country_name, ci.name city_name
		FROM "user" u, country co, city ci
		WHERE u.login LIKE user_login AND
			  u.id_city = ci.id_city AND
			  u.id_country = co.id_country
	LOOP
		login := r.login;
		id_city := r.id_city;
		city_name := r.city_name;
		id_country := r.id_country;
		country_name := r.country_name;
		name := r.name;
		birthdate := r.birthdate;
		email := r.email;
		gender_male := r.gender_male;
		address := r.address;
		public := r.public;
		disabled := r.disabled;
		RETURN NEXT;
	END LOOP;
	RETURN;
END;
$$
LANGUAGE plpgsql;

-- UPDATE_PASSWORD()
CREATE OR REPLACE FUNCTION update_password(login_ varchar,pass_ varchar)
RETURNS VOID AS
$$
DECLARE
	salt_ varchar;
	hash_ varchar;
BEGIN
	IF pass_ IS NOT NULL AND pass_ NOT LIKE '' THEN
		SELECT generate_salt() INTO salt_;
		SELECT generate_hash(pass_, salt_) INTO hash_;
		UPDATE "user" SET pwhash=hash_, salt=salt_ WHERE login LIKE login_;
	END IF;
END;
$$
LANGUAGE plpgsql;

-- UPDATE_PROFILE()
CREATE OR REPLACE FUNCTION update_profile(login_ varchar,pass_ varchar, city_name_ varchar, id_country_ integer, name_ varchar, birthdate_ date, email_ varchar, gender_male_ boolean, address_ varchar, public_ boolean)
RETURNS VOID AS
$$
DECLARE
	id_city_ integer := NULL;
	salt_ varchar;
	hash_ varchar;
BEGIN
	UPDATE "user" SET id_country=id_country_,
					  id_city=null,
					  name=name_,
					  email=email_,
					  gender_male=gender_male_,
					  address=address_,
					  public=public_
		WHERE login LIKE login_;

	IF city_name_ IS NOT NULL AND city_name_ NOT LIKE '' THEN
		SELECT get_cityid(city_name_) INTO id_city_;
		UPDATE "user" SET id_city=id_city_ WHERE login LIKE login_;
	END IF;

	IF pass_ IS NOT NULL AND pass_ NOT LIKE '' THEN
		PERFORM update_password(login_,pass_);
	END IF;
END;
$$
LANGUAGE plpgsql;

-- DISABLE_USER()
CREATE OR REPLACE FUNCTION disable_user(login_ varchar, disable boolean)
RETURNS VOID AS
$$
BEGIN
	UPDATE "user" SET disabled=disable WHERE login LIKE login_;
END;
$$
LANGUAGE plpgsql;