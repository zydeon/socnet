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

-- GENERATE_HASHpass_)
saltE OR REPLACE FUNCTION generate_hash(pass varchar, salt varchar) RETURNS varchar AS $$
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
