-- automatically fetch parent post rlevel, increments and inserts into new post
CREATE TRIGGER update_rlevel
	AFTER INSERT ON post
	FOR EACH ROW
	EXECUTE PROCEDURE set_rlevel();

CREATE TRIGGER increase_num_rates
	AFTER INSERT ON rates
	FOR EACH ROW
	EXECUTE PROCEDURE inc_num_rates();

CREATE TRIGGER decrease_num_rates
	AFTER DELETE ON rates
	FOR EACH ROW
	EXECUTE PROCEDURE dec_num_rates();
