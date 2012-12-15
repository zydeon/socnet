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

-- CREATE OR REPLACE FUNCTION delete_pm()
-- RETURNS trigger AS $$
-- BEGIN
-- 	DELETE FROM message WHERE id_message = OLD.id_message;
-- 	RETURN OLD;
-- END;
-- $$
-- LANGUAGE plpgsql;