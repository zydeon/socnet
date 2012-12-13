CREATE OR REPLACE FUNCTION get_posts(id_chat numeric, id_parent_ numeric)
RETURNS TABLE(id_message numeric, "from" varchar, text varchar, sent_date date, rlevel int, file_path varchar ) AS $$
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

-- ADD_CHATROOM()
CREATE OR REPLACE FUNCTION add_chatroom(creator_ varchar, theme_ varchar)
RETURNS VOID AS $$
BEGIN
	INSERT INTO chat_room (creator, theme) VALUES (creator_, theme_);
	EXCEPTION WHEN unique_violation THEN
		RAISE EXCEPTION 'Error: theme already exists';
	WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'Error: invalid creator login';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'Error: system error';

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