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
