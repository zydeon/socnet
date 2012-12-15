--ADD_PM()
CREATE OR REPLACE FUNCTION add_pm(sender varchar,receiver varchar,content varchar,attach_ varchar)

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
		       VALUES(m_id,sender,content,null,'A');
		INSERT INTO pm (id_message,"to",read)
		       VALUES(m_id,receiver,false);
	END IF;	     
EXCEPTION
	WHEN unique_violation THEN
		RAISE EXCEPTION 'Pm failure';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'system error';
END;
$$
LANGUAGE plpgsql;

--ADD DELAYED PM
CREATE OR REPLACE FUNCTION add_delayed_pm(sender varchar,receiver varchar,content varchar,attach_ varchar, ts timestamp)

RETURNS VOID AS
$$
DECLARE
	m_id integer;
	tmp boolean;
BEGIN
	SELECT user_exists(receiver) into tmp;
	IF tmp IS NOT NULL THEN
		SELECT nextval('message_id_seq') INTO m_id;	
		INSERT INTO message (id_message,"from",text,read_date,sent_date,msg_type)
		       VALUES(m_id,sender,content,null,ts,'A');
		INSERT INTO pm (id_message,"to",read)
		       VALUES(m_id,receiver,false);
	END IF;	     
EXCEPTION
	WHEN unique_violation THEN
		RAISE EXCEPTION 'Delayed Pm Failure';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'system error';
	RETURN;
END;
$$
LANGUAGE plpgsql;

--GET_HISTORY()
CREATE OR REPLACE FUNCTION get_history(user1 varchar,user2 varchar)
RETURNS TABLE (id_message_ numeric, "from" varchar, text varchar, "read" boolean) AS $$
DECLARE
	ts timestamp;
BEGIN
	SELECT current_timestamp INTO ts;

	UPDATE pm SET "read"=true WHERE id_message IN (SELECT p.id_message FROM message m, pm p
	WHERE m.id_message = p.id_message AND 
	((m."from" LIKE user1 AND p.to LIKE user2) OR
	(m."from" LIKE user2 AND p.to LIKE user1)) AND
	m.sent_date < ts);

	RETURN QUERY SELECT m.id_message, m."from", m.text, p."read"
	FROM message m, pm p
	WHERE m.id_message = p.id_message AND 
	((m."from" LIKE user1 AND p.to LIKE user2) OR (m."from" LIKE user2 AND p.to LIKE user1)) AND
	m.sent_date < ts;
	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION 'system error';
	RETURN;
END;	
$$
LANGUAGE plpgsql;

--GET_INBOX()
CREATE OR REPLACE FUNCTION get_inbox(username varchar)
RETURNS TABLE (id_message_ numeric, "from" varchar, text varchar,"read" boolean) AS $$
DECLARE
	ts timestamp;
BEGIN
	SELECT current_timestamp INTO ts;
	UPDATE pm SET "read"=true WHERE id_message IN (SELECT m.id_message FROM message m, pm p
	WHERE m.id_message = p.id_message AND p."to" LIKE username and m.sent_date < ts);
	
	RETURN QUERY SELECT m.id_message, m."from", m.text, p."read"
	FROM message m, pm p
	WHERE m.id_message = p.id_message AND p."to" LIKE username AND m.sent_date < ts;

	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION 'system error';
	RETURN;
END;
$$
LANGUAGE plpgsql;

--GET_ACTIVITY()

CREATE OR REPLACE FUNCTION get_activity("user" varchar)
RETURNS TABLE (id_message_ numeric, "from" varchar, text varchar, "read" boolean) 
AS $$
DECLARE	
BEGIN			
	RETURN QUERY SELECT m.id_message, m."from", m.text, p."read"
	FROM message m, pm p
	WHERE m.id_message = p.id_message AND 
	m."from" LIKE "user";

	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION 'system error';
	RETURN;
END;
$$
LANGUAGE plpgsql;


--REMOVE_MESSAGE()
CREATE OR REPLACE FUNCTION remove_message(id integer) RETURNS BOOLEAN AS $$
DECLARE
	read_ boolean;
BEGIN
	SELECT read INTO read_ FROM pm WHERE id_message=id;
	IF read_ IS false THEN
		DELETE FROM pm WHERE id_message = id;
		DELETE FROM message WHERE id_message=id;
	END IF;
	RETURN NOT read_;
	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION 'system error';
END;
$$
LANGUAGE plpgsql;
