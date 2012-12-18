-- automatically fetch parent post rlevel, increments and inserts into new post
DROP TRIGGER IF EXISTS update_rlevel on post;
CREATE TRIGGER update_rlevel
	AFTER INSERT ON post
	FOR EACH ROW
	EXECUTE PROCEDURE set_rlevel();

DROP TRIGGER IF EXISTS inc_rate on rates;
CREATE TRIGGER inc_rate
	AFTER INSERT ON rates
	FOR EACH ROW
	EXECUTE PROCEDURE inc_rate();


DROP TRIGGER IF EXISTS dec_rate on rates;
CREATE TRIGGER dec_rate
	AFTER UPDATE ON rates
	FOR EACH ROW
	EXECUTE PROCEDURE dec_rate();
