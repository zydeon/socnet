CREATE OR REPLACE FUNCTION get_posts(numeric, numeric)
RETURNS TABLE(id_message numeric, "from" varchar, id_attach numeric, text varchar, read_date date, image char, id_parent int, rlevel int ) AS $$
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
$$
LANGUAGE plpgsql;

-- GET_COUNTRIES()
CREATE OR REPLACE FUNCTION get_countries()
RETURNS SETOF country AS $$
BEGIN
	RETURN QUERY SELECT * FROM country;
END;
$$
LANGUAGE plpgsql;

-- GET_CHATROOMS()
CREATE OR REPLACE FUNCTION get_chatrooms()
RETURNS SETOF chat_room AS $$
BEGIN
	RETURN QUERY SELECT * FROM chat_room WHERE closed=false;
END;
$$
LANGUAGE plpgsql;

-- GET_CHATROOMS() BY USER
CREATE OR REPLACE FUNCTION get_chatrooms(login_ varchar)
RETURNS SETOF chat_room AS $$
BEGIN
	RETURN QUERY SELECT * FROM chat_room WHERE creator LIKE login_;
END;
$$
LANGUAGE plpgsql;

-- ADD_CHATROOM()
CREATE OR REPLACE FUNCTION add_chatroom(creator_ varchar, theme_ varchar)
RETURNS VOID AS $$
BEGIN
	INSERT INTO chat_room (creator, theme) VALUES (creator_, theme_);
	EXCEPTION WHEN unique_violation THEN
		RAISE EXCEPTION 'Error: theme already exists';
	WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'Error: invalid creator login';

END;
$$
LANGUAGE plpgsql;

-- UPDATE_CHATROOM()
CREATE OR REPLACE FUNCTION update_chatroom(id_chatroom_ integer, creator_ varchar, theme_ varchar, closed_ boolean)
RETURNS VOID AS $$
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
$$
LANGUAGE plpgsql;

-- USER_RESTRICTION()
CREATE OR REPLACE FUNCTION user_restriction(login_ varchar, id_chatroom_ integer, read_ boolean)
RETURNS VOID AS $$
DECLARE
	n integer := 0;
BEGIN
	SELECT count(*) INTO n from restrictions WHERE id_chatroom=id_chatroom_ AND "user"=login_;
	IF read_ IS NULL THEN
		IF (n > 0) THEN
			DELETE FROM restrictions WHERE id_chatroom=id_chatroom_ AND "user"=login_;
		END IF;
	ELSE
		IF n < 1 THEN
			INSERT INTO restrictions ("user",id_chatroom,read) VALUES (login_, id_chatroom_, read_);
		ELSE
			UPDATE restrictions SET read=read_;
		END IF;
	END IF;
		
	EXCEPTION WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'Error: invalid creator login or chatroom id';

END;
$$
LANGUAGE plpgsql;

-- SEARCH_CHATROOMS()
CREATE OR REPLACE FUNCTION search_chatrooms(creator_ varchar, theme_ varchar)
RETURNS SETOF chat_room AS $$
BEGIN
	RETURN QUERY SELECT * FROM chat_room WHERE upper(theme) LIKE '%' || upper(theme_) || '%'
											AND upper(creator) LIKE '%' || upper(creator_) || '%';
END;
$$
LANGUAGE plpgsql;


-- ADD_POST()
CREATE OR REPLACE FUNCTION add_post(id_chatroom_ integer, sender_login varchar, texto varchar, int parent string attach
RETURNS VOID AS $$
BEGIN
	-- CRIAR POST
END;
$$
LANGUAGE plpgsql;
