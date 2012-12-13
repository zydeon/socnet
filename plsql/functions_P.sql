--AD_PM()
CREATE OR REPLACE FUNCTION add_pm(sender varchar,receiver varchar,content varchar,attach_ varchar)

RETURNS BOOLEAN AS
$$
DECLARE
	a_id integer;
	m_id integer;
	tmp boolean;
BEGIN
	SELECT user_exists(receiver) into tmp;
	IF tmp IS NOT NULL THEN
		SELECT nextval('message_id_seq') INTO m_id;
		SELECT nextval('attach_id_seq') INTO a_id;
		IF attach IS NOT NULL AND attach NOT LIKE '' THEN
			   INSERT INTO attach (id_attach,id_message,attach)
	   		   VALUES (a_id,m_id,attach_);
		END IF ;
	
		INSERT INTO pm (id_message,"to",read)
		       VALUES(m_id,receiver,NULL);
		INSERT INTO messages (id_message,"from",id_attach,text,read_date,msg_type)
		       VALUES(m_id,sender,a_id,content,null,'b');
	END IF;	     
EXCEPTION
	WHEN unique_violation THEN
		RAISE EXCEPTION 'Pm failure';
END;
$$
LANGUAGE plpgsql;

--ADD DELAYED PM
CREATE OR REPLACE FUNCTION add_delayed_pm(sender varchar,receiver varchar,content varchar,attach_ varchar, t timestamp)

RETURNS BOOLEAN AS
$$
DECLARE
	a_id integer;
	m_id integer;
	tmp boolean;
BEGIN
	SELECT user_exists(receiver) into tmp;
	IF tmp IS NOT NULL THEN
		SELECT nextval('message_id_seq') INTO m_id;
		SELECT nextval('attach_id_seq') INTO a_id;
		SELECT current_timestamp INTO t;		
		IF attach IS NOT NULL AND attach NOT LIKE '' THEN
			   INSERT INTO attach (id_attach,id_message,attach)
	   		   VALUES (a_id,m_id,attach_);
		END IF ;
	

		INSERT INTO pm (id_message,"to",read)
		       VALUES(m_id,receiver,NULL);
		INSERT INTO messages (id_message,"from",id_attach,text,read_date,sent_date,msg_type)
		       VALUES(m_id,sender,a_id,content,null,t,null,'a');
	END IF;	     
EXCEPTION
	WHEN unique_violation THEN
		RAISE EXCEPTION 'Pm failure';

END;
$$
LANGUAGE plpgsql;

--GET_HISTORY()
CREATE OR REPLACE FUNCTION get_history(user1 varchar,user2 varchar)
RETURNS TABLE (id_message numeric, "from" varchar, id_attach numeric, text varchar, read_date date) AS $$
DECLARE
	r record;
BEGIN
	FOR r IN SELECT m.id_message, m."from", m.id_attach, m.text, m.read_date
	FROM message m, pm p
	WHERE m.id_message = p.id_message AND 
	((m."from" LIKE user1 AND p.to LIKE user2) OR
	(m."from" LIKE user2 AND p.to LIKE user1))
	LOOP
		--UPDATE MESSAGES AS READ
		RETURN NEXT;
	END LOOP;

END;
$$
LANGUAGE plpgsql;

--GET_ACTIVITY()

CREATE OR REPLACE FUNCTION get_activity("user" varchar) RETURNS TABLE (id_message numeric, "from" varchar, id_attach numeric, text varchar, read_date date) 
AS $$
DECLARE
	r record;
BEGIN
	FOR r IN SELECT m.id_message, m."from", m.id_attach, m.text, m.read_date
	FROM message m, pm p
	WHERE m.id_message = p.id_message AND 
	m."from" LIKE "user"
	LOOP
		-- UPDATE MESSAGES AS READ
		RETURN NEXT;
	END LOOP;

END;
$$
LANGUAGE plpgsql;


--REMOVE_MESSAGE()
CREATE OR REPLACE FUNCTION remove_message(id integer) RETURNS BOOLEAN AS $$
DECLARE
	read_ boolean;
BEGIN
	SELECT read  INTO read_ FROM message WHERE id_message=id;
	IF read_ IS false THEN
		DELETE FROM message WHERE id_message=id;
		DELETE FROM pm WHERE id_message = id;
	END IF;
	RETURN NOT read_;
END;
$$
LANGUAGE plpgsql;
