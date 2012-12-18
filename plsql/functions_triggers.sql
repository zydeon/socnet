-- SET_RLEVEL()
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


--INC_RATE()
CREATE OR REPLACE FUNCTION inc_rate()
RETURNS trigger AS
$$
BEGIN
       -- AQUI
       IF upper(NEW.rate) LIKE 'Y' THEN
               UPDATE chat_room SET "ratesY"=("ratesY"+1) WHERE id_chatroom=NEW.id_chatroom;
       ELSE IF upper(NEW.rate) LIKE 'M' THEN
               UPDATE chat_room SET "ratesM"=("ratesM"+1) WHERE id_chatroom=NEW.id_chatroom;
       ELSE IF upper(NEW.rate) LIKE 'N' THEN
               UPDATE chat_room SET "ratesN"=("ratesN"+1) WHERE id_chatroom=NEW.id_chatroom;
       END IF;
       END IF;
       END IF;
       RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dec_rate()
RETURNS trigger AS
$$
BEGIN
       IF upper(OLD.rate) = 'Y' THEN
               UPDATE chat_room SET "ratesY"=("ratesY"-1) WHERE id_chatroom=OLD.id_chatroom;
       ELSE IF upper(OLD.rate) = 'M' THEN
               UPDATE chat_room SET "ratesM"=("ratesM"-1) WHERE id_chatroom=OLD.id_chatroom;
       ELSE IF upper(OLD.rate) = 'N' THEN
               UPDATE chat_room SET "ratesN"=("ratesN"-1) WHERE id_chatroom=OLD.id_chatroom;

       END IF;
       END IF;
       END IF;               

       IF upper(NEW.rate) = 'Y' THEN
               UPDATE chat_room SET "ratesY"=("ratesY"+1) WHERE id_chatroom=NEW.id_chatroom;
       ELSE IF upper(NEW.rate) = 'M' THEN
               UPDATE chat_room SET "ratesM"=("ratesM"+1) WHERE id_chatroom=NEW.id_chatroom;
       ELSE IF upper(NEW.rate) = 'N' THEN
               UPDATE chat_room SET "ratesN"=("ratesN"+1) WHERE id_chatroom=NEW.id_chatroom;

       END IF;
       END IF;
       END IF;

      RETURN NEW;
END;
$$
LANGUAGE plpgsql;