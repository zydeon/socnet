CREATE OR REPLACE FUNCTION set_rlevel()
RETURNS trigger AS $$
BEGIN
	IF NEW.id_parent IS NOT NULL THEN
		UPDATE post SET rlevel=(
					SELECT rlevel+1 FROM post WHERE id_message = NEW.id_parent )
		WHERE id_message = NEW.id_message;
	END IF;
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

