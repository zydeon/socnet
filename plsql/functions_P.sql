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
		INSERT INTO message (id_message,"from",text,msg_type,attach_path)
		       VALUES(m_id,sender,content,'A',attach_);
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
		INSERT INTO message (id_message,"from",text,sent_date,msg_type,attach_path)
		       VALUES(m_id,sender,content,ts,'A',attach);
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
RETURNS TABLE (id_message_ numeric, "from" varchar, text varchar,"read" boolean,"to" varchar,file_path varchar,sent_date timestamp) AS $$
DECLARE
	ts timestamp;
BEGIN
	SELECT current_timestamp INTO ts;

	UPDATE pm SET "read"=true WHERE id_message IN (SELECT p.id_message FROM message m, pm p
	WHERE m.id_message = p.id_message AND 
	((m."from" LIKE user1 AND p.to LIKE user2) OR
	(m."from" LIKE user2 AND p.to LIKE user1)) AND
	m.sent_date < ts);

	RETURN QUERY SELECT m.id_message, m."from", m.text, p."read",p."to",m.attach_path,m.sent_date
	FROM message m, pm p
	WHERE m.id_message = p.id_message AND 
	((m."from" LIKE user1 AND p.to LIKE user2) OR (m."from" LIKE user2 AND p.to LIKE user1)) AND
	m.sent_date < ts
	ORDER BY m.sent_date DESC;
	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION 'system error';
	RETURN;
END;	
$$
LANGUAGE plpgsql;

--GET_INBOX()
CREATE OR REPLACE FUNCTION get_inbox(username varchar)
RETURNS TABLE (id_message_ numeric, "from" varchar, text varchar,"read" boolean,"to" varchar,file_path varchar,sent_date timestamp) AS $$
DECLARE
	ts timestamp;
BEGIN
	SELECT current_timestamp INTO ts;
	UPDATE pm SET "read"=true WHERE id_message IN (SELECT m.id_message FROM message m, pm p
	WHERE m.id_message = p.id_message AND p."to" LIKE username and m.sent_date < ts);
	
	RETURN QUERY SELECT m.id_message, m."from", m.text, p."read",p."to",m.attach_path,m.sent_date
	FROM message m, pm p
	WHERE m.id_message = p.id_message AND p."to" LIKE username AND m.sent_date < ts
	ORDER BY m.sent_date DESC;

	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION 'system error';
	RETURN;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_outbox("user" varchar)
RETURNS TABLE (id_message_ numeric, "from" varchar, text varchar,"read" boolean,"to" varchar,file_path varchar,sent_date timestamp) AS $$

DECLARE	
BEGIN			
	RETURN QUERY SELECT m.id_message, m."from", m.text, p."read",p."to",m.attach_path,m.sent_date
	FROM message m, pm p
	WHERE m.id_message = p.id_message AND 
	m."from" LIKE "user"
	ORDER BY m.sent_date DESC;

	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION 'system error';
	RETURN;
END;
$$
LANGUAGE plpgsql;

-- DELETE_PM()
CREATE OR REPLACE FUNCTION delete_pm(idpm integer,userlogin varchar)
RETURNS VOID AS $$
BEGIN
       DELETE FROM message WHERE "from" LIKE userlogin AND id_message IN (SELECT id_message FROM pm WHERE read=false AND id_message=idpm);
       EXCEPTION WHEN OTHERS THEN
               RAISE EXCEPTION 'system error';
END;
$$
LANGUAGE plpgsql;
