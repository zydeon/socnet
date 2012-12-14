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
LANGUAGE plpgsql;§

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


--AD_POST() TRANSACTION
CREATE OR REPLACE FUNCTION add_post(id_chatroom_ integer, sender varchar, content varchar, parent integer, attach_ varchar, rlevel_ integer)

RETURNS VOID AS
$$
DECLARE
	m_id integer;
	tmp boolean;
BEGIN
	SELECT user_exists(receiver) into tmp;
	IF tmp IS NOT NULL THEN
		SELECT nextval('message_id_seq') INTO m_id;	
		INSERT INTO message (id_message,"from",text,read_date,msg_type)
		       VALUES(m_id,sender,content,null,'b',attach);
		INSERT INTO post (id_message,id_parent,rlevel,id_chatroom,attach_)
		       VALUES(m_id,parent,rlevel_,chatroom);
	END IF;	     
EXCEPTION
	WHEN unique_violation THEN
		RAISE EXCEPTION 'Post failure';
	RETURN;
END;
$$
LANGUAGE plpgsql;
