-- automatically fetch parent post rlevel, increments and inserts into new post
CREATE TRIGGER update_rlevel
	AFTER INSERT ON post
	FOR EACH ROW
	EXECUTE PROCEDURE set_rlevel();
