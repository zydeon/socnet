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


-- CREATE OR REPLACE FUNCTION inc_num_rates()
-- RETURNS trigger AS $$
-- BEGIN
-- 	UPDATE chat_room c SET num_rates=(num_rates+1)
-- 	WHERE c.id_chatroom = NEW.id_chatroom;
-- 	RETURN NULL;
-- END;
-- $$
-- LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION dec_num_rates()
-- RETURNS trigger AS $$
-- BEGIN
-- 	UPDATE chat_room c SET num_rates=(num_rates-1)
-- 	WHERE c.id_chatroom = OLD.id_chatroom;
-- 	RETURN NULL;
-- END;
-- $$
-- LANGUAGE plpgsql;
