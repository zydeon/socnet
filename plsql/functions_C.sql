CREATE OR REPLACE FUNCTION get_posts(id_chat numeric, id_parent_ numeric, userlogin varchar)
RETURNS TABLE(id_message numeric, "from" varchar, text varchar, sent_date date, rlevel int, file_path varchar ) AS $$
DECLARE	r 	RECORD;
	n integer:=0;
	msg text:='system error';
BEGIN
	SELECT count(*) INTO n FROM chat_room WHERE id_chatroom=id_chat AND closed=true;
	IF n < 1 THEN
		n:=0;
		SELECT count(*) INTO n FROM restrictions WHERE "user" LIKE userlogin AND id_chatroom=id_chat AND read=false;
		IF n < 1 THEN
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
		ELSE
			msg:='user cant read from this chatroom';
			RAISE EXCEPTION '';
		END IF;
	ELSE
		msg:='This chatroom is closed';
		RAISE EXCEPTION '';
	END IF;
	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION '%',msg;
END;
$$
LANGUAGE plpgsql;

-- GET_COUNTRIES()
CREATE OR REPLACE FUNCTION get_countries()
RETURNS SETOF country AS $$
BEGIN
	RETURN QUERY SELECT * FROM country;
	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION 'system error';
END;
$$
LANGUAGE plpgsql;

-- GET_CHATROOMS()
CREATE OR REPLACE FUNCTION get_chatrooms()
RETURNS SETOF chat_room AS $$
BEGIN
	RETURN QUERY SELECT * FROM chat_room WHERE closed=false;
	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION 'system error';
END;
$$
LANGUAGE plpgsql;

-- GET_CHATROOMS() BY USER
CREATE OR REPLACE FUNCTION get_chatrooms(login_ varchar)
RETURNS SETOF chat_room AS $$
BEGIN
	RETURN QUERY SELECT * FROM chat_room WHERE creator LIKE login_;
	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION 'system error';
END;
$$
LANGUAGE plpgsql;

-- ADD_CHATROOM()
CREATE OR REPLACE FUNCTION add_chatroom(creator_ varchar, theme_ varchar)
RETURNS VOID AS $$
DECLARE
	n integer := 0;
	msg text:='system error';
BEGIN
	SELECT count(*) INTO n FROM chat_room WHERE creator=creator_ AND upper(theme) LIKE upper(theme_);
	IF n < 1 THEN
		INSERT INTO chat_room (creator, theme) VALUES (creator_, theme_);
	ELSE
		msg:='theme already exists';
		RAISE EXCEPTION '';
	END IF;
	EXCEPTION WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'invalid creator login';
	WHEN OTHERS THEN
		RAISE EXCEPTION '%',msg;

END;
$$
LANGUAGE plpgsql;

-- UPDATE_CHATROOM()
CREATE OR REPLACE FUNCTION update_chatroom(id_chatroom_ integer, creator_ varchar, theme_ varchar, closed_ boolean)
RETURNS VOID AS $$
DECLARE
	n integer := 0;
	msg text:='system error';
BEGIN
	SELECT count(*) INTO n FROM chat_room WHERE id_chatroom=id_chatroom_ AND creator=creator_;
	IF n < 1 THEN
		RAISE EXCEPTION 'this action can only be performed by the chatroom creator';
	END IF;
	IF theme_ IS NOT NULL THEN
		SELECT count(*) INTO n FROM chat_room WHERE creator=creator_ AND upper(theme) LIKE upper(theme_);
		IF n < 1 THEN
			UPDATE chat_room SET theme=theme_ WHERE id_chatroom=id_chatroom_;
		ELSE
			msg:='theme already exists';
			RAISE EXCEPTION '';
		END IF;
	END IF;

	IF closed_ IS NOT NULL THEN
		UPDATE chat_room SET closed=closed_ WHERE id_chatroom=id_chatroom_;
	END IF;

	EXCEPTION WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'invalid creator login';
	WHEN OTHERS THEN
		RAISE EXCEPTION '%',msg;

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
			UPDATE restrictions SET read=read_ WHERE id_chatroom=id_chatroom_ AND "user"=login_;
		END IF;
	END IF;
		
	EXCEPTION WHEN foreign_key_violation THEN
		RAISE EXCEPTION 'invalid creator login or chatroom id';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'system error';

END;
$$
LANGUAGE plpgsql;

-- SEARCH_CHATROOMS()
CREATE OR REPLACE FUNCTION search_chatrooms(creator_ varchar, theme_ varchar)
RETURNS SETOF chat_room AS $$
BEGIN
	RETURN QUERY SELECT * FROM chat_room WHERE upper(theme) LIKE '%' || upper(theme_) || '%'
											AND upper(creator) LIKE '%' || upper(creator_) || '%';
	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION 'system error';
END;
$$
LANGUAGE plpgsql;


--ADD_POST() TRANSACTION
CREATE OR REPLACE FUNCTION add_post(id_chatroom_ integer, sender varchar, content varchar, parent integer, attach_ varchar, rlevel_ integer)
RETURNS VOID AS
$$
DECLARE
	m_id integer;
	n integer:=0;
	msg text:='system error';
BEGIN
	SELECT count(*) INTO n FROM restrictions WHERE "user" LIKE sender AND id_chatroom=id_chatroom_;
	IF n < 1 THEN
		SELECT nextval('message_id_seq') INTO m_id;	
		INSERT INTO message (id_message,"from",text,msg_type,attach_path)
		       VALUES(m_id,sender,content,'b',attach_);
		INSERT INTO post (id_message,id_parent,rlevel,id_chatroom)
		       VALUES(m_id,parent,rlevel_,id_chatroom_);
	ELSE
		msg:='This User cant write a post on this chatroom';
		RAISE EXCEPTION '';
	END IF;
	EXCEPTION WHEN unique_violation THEN
		RAISE EXCEPTION 'Post failure';
	WHEN OTHERS THEN
		RAISE EXCEPTION '%',msg;
END;
$$
LANGUAGE plpgsql;

--CAN_RATE()
CREATE OR REPLACE FUNCTION can_rate(username varchar, chatroom_id numeric)

RETURNS boolean AS
$$
DECLARE
	tmp integer:=0;
BEGIN
	SELECT count(*) INTO tmp FROM message m, post p WHERE id_chatroom=chatroom_id AND m.id_message=p.id_message;
	IF tmp > 0 THEN
		RETURN true;
	END IF;
	RETURN false;
	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION 'system error';
END;
$$
LANGUAGE plpgsql;


--INC_RATE()
CREATE OR REPLACE FUNCTION inc_rate(chatroom_id numeric, rate_ char)
RETURNS VOID AS
$$
BEGIN
	IF upper(rate_) = 'Y' THEN
		UPDATE chatroom SET ratesY=(ratesY+1) WHERE id_chatroom=chatroom_id;
	ELSE IF upper(rate_) = 'M' THEN
			UPDATE chatroom SET ratesM=(ratesM+1) WHERE id_chatroom=chatroom_id;
	ELSE IF upper(rate_) = 'N' THEN
				UPDATE chatroom SET ratesN=(ratesN+1) WHERE id_chatroom=chatroom_id;
	ELSE
		RAISE EXCEPTION 'Invalid rate!';
	END IF;
	END IF;
	END IF;
	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION 'system error';
END;
$$
LANGUAGE plpgsql;

--DEC_RATE()
CREATE OR REPLACE FUNCTION dec_rate(chatroom_id numeric, rate_ char)
RETURNS VOID AS
$$
BEGIN
	IF upper(rate_) = 'Y' THEN
		UPDATE chatroom SET ratesY=(ratesY-1) WHERE id_chatroom=chatroom_id;
	ELSE IF upper(rate_) = 'M' THEN
		UPDATE chatroom SET ratesM=(ratesM-1) WHERE id_chatroom=chatroom_id;
	ELSE IF upper(rate_) = 'N' THEN
		UPDATE chatroom SET ratesN=(ratesN-1) WHERE id_chatroom=chatroom_id;
	ELSE
		RAISE EXCEPTION 'Invalid rate!';
	END IF;
	END IF;
	END IF;
	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION 'system error';
END;
$$
LANGUAGE plpgsql;

--RATE_CHATROOM()
CREATE OR REPLACE FUNCTION rate_chatroom(username varchar, chatroom_id numeric, rate_ char)

RETURNS VOID AS
$$
DECLARE
	can boolean:=false;
	tmp integer:=0;
	r char;
	msg text:='system error';
BEGIN
	IF rate_ IS NULL THEN
		SELECT count(*) INTO tmp FROM rates m WHERE id_chatroom=chatroom_id AND "user" LIKE username;
		IF tmp > 0 THEN
			SELECT rate INTO r FROM rates WHERE id_chatroom=chatroom_id AND "user" LIKE username;
			DELETE FROM rates WHERE id_chatroom=chatroom_id AND "user" LIKE username;
			PERFORM dec_rate(chatroom_id,r);
		END IF;
	ELSE
		SELECT can_rate(username, chatroom_id) INTO can;
		IF can = true THEN
			PERFORM inc_rate(chatroom_id, rate_);
			SELECT count(*) INTO tmp FROM rates m WHERE id_chatroom=chatroom_id AND "user" LIKE username;
			IF tmp > 0 THEN
				SELECT rate INTO r FROM rates WHERE id_chatroom=chatroom_id AND "user" LIKE username;
				UPDATE rates SET rate=upper(rate_) WHERE id_chatroom=chatroom_id AND "user" LIKE username;
				PERFORM dec_rate(chatroom_id,r);
			ELSE
				INSERT INTO rates ("user",id_chatroom,rate) VALUES (username, chatroom_id, upper(rate_));
			END IF;
		ELSE
			msg:='Only users with post in the chatroom can rate';
			RAISE EXCEPTION '';
		END IF;
	END IF;
	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION '%',msg;
END;
$$
LANGUAGE plpgsql;

-- GET_CHATROOM_THEME()
CREATE OR REPLACE FUNCTION get_chatroom_theme(id integer)
RETURNS varchar AS
$$
DECLARE theme_ varchar;
	msg text:='system error';
BEGIN
	SELECT theme INTO theme_ FROM chat_room WHERE id_chatroom = id;
	IF theme_ IS NOT NULL THEN
		RETURN theme_;
	ELSE
		msg:='Invalid chatroom';
		RAISE EXCEPTION '';
	END IF;
	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION '%',msg;
END;
$$
LANGUAGE plpgsql;

