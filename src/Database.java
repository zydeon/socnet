package dbconnect;      // needs package to be imported to JSP

import java.sql.*;
import java.util.ArrayList;
import java.security.MessageDigest;
import java.security.SecureRandom;

public class Database{

	private static final int MAX_CONNECTIONS=15;
	private static final String dbUrl = "jdbc:postgresql://localhost/socnet";
	private static final String dbUser = "socnet_user";
	private static final String dbPassword = "dbdb";
	private static boolean initialized = false;

	private static Pool connectionsPool;

	public static void init(){
		if(!initialized){
			connectionsPool = new Pool(MAX_CONNECTIONS);
			initialized = true;
			System.out.println("Database initialized!!! ");
			System.out.println("Pool size = "+connectionsPool.getSize());
		}
	}

	public static void destroy(){
		if(initialized)
		connectionsPool.destroy();
	}

	public static Connection createConnection(){
		Connection con = null;
		try{
			// DATABASE CONNECTION
			// Class.forName("com.mysql.jdbc.Driver").newInstance(); //not needed
			con = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

		}
		catch(SQLException e){
			System.out.println(e);
		}
		return con;
	}

	public static synchronized Connection getConnection( ){
		if( initialized ){
			try{
				return connectionsPool.getItem();
			}
			catch(java.lang.InterruptedException e){
				System.out.println(e);
			}
		}
		else
			System.out.println("Database not initialized!");
		return null;
	}

	public static synchronized void putConnection(Connection c){
		if(initialized)
			connectionsPool.putItem(c);
		else
			System.out.println("Database not initialized!");
	}

	public static boolean authUser(String user, String pass){
		try{
			Connection con = getConnection();
			if( con != null ){
				Statement st = con.createStatement();
				ResultSet rs;

				String sql = "SELECT salt,disabled FROM \"user\" WHERE login='"+user+"';";
				rs = st.executeQuery(sql);
				if(rs.next()){
					if (!rs.getBoolean("disabled")){
						String salt = rs.getString("salt");

						sql = "SELECT count(*) FROM \"user\" "
							+ "WHERE login='"+user+"' AND pwhash = crypt('"+pass+"','"+salt+"');";

						rs = st.executeQuery(sql);

						if( rs.next() && rs.getInt("count")>0){                                     
							putConnection(con);
							return true;
						}
					}
				}
				putConnection(con);
			}
		}
		catch(SQLException e){
			System.out.println(e);
		}
		return false;
	}

	public static boolean existsUser(String user){
		Connection con = Database.getConnection();
		if(con != null){
			try{
				String sql = "SELECT count(*) FROM \"user\" WHERE login='"+user+"'";
				Statement st = con.createStatement();
				ResultSet rs = st.executeQuery(sql);

				if( rs.next() && rs.getInt("count")>0 )
					return true;
				
				Database.putConnection(con);
			}
			catch(SQLException e){
				System.out.println(e);
			}
		}
		return false;
	}

	public static boolean existsCountry(String id_country){
		if(id_country == null)
			return false;

		Connection con = Database.getConnection();
		if(con != null){
			try{
				String sql = "SELECT count(*) FROM \"country\" WHERE id_country='"+id_country+"'";
				Statement st = con.createStatement();
				ResultSet rs = st.executeQuery(sql);

				if( rs.next() && rs.getInt("count")>0 )
					return true;
				
				Database.putConnection(con);
			}
			catch(SQLException e){
				System.out.println(e);
			}
		}
		return false;       
	}

	public static String getCityName(String id_city){
		ResultSet rs = null;
		String city_name = "";
		try{
			Connection con = getConnection();
			if(con!=null){
				Statement st = con.createStatement();
				String query = "SELECT name FROM city WHERE id_city="+id_city+";";
				rs = st.executeQuery(query);
				if(rs.next())
					city_name = rs.getString("name");

				putConnection(con);
			}
		}
		catch( java.sql.SQLException e){
			System.out.println(e);
		}
		return city_name;
	}


	public static Integer getCityID(String city_name){
		// return id_city of 'city_name'
		// if city_name does not exist adds it and returns the new id_city
		Integer id_city = null;
		try{
			Connection con = getConnection();
			if(con!=null){
				// CHECK IF CITY EXISTS
				String sql = "SELECT id_city FROM \"city\" WHERE name='"+city_name+"'";
				Statement st = con.createStatement();
				ResultSet rs = st.executeQuery(sql);

				if( rs.next() )
					return rs.getInt("id_city");
				
				// IF it does not exist
				sql = "SELECT nextval('city_id_seq') AS id_city;";
				rs = st.executeQuery(sql);
				
				if(rs.next())
					id_city = rs.getInt("id_city");

				sql = "INSERT INTO city "
					+ "VALUES ("+id_city+",'"+city_name+"');";
				st.executeUpdate(sql);      

				putConnection(con);
				
			}
		}
		catch( java.sql.SQLException e){
			System.out.println(e);
		}

		return id_city;
	}

	public static String generateSalt(){
		String salt = null;     
		try{
			Connection con = getConnection();
			if(con!=null){
				Statement st = con.createStatement();
				String sql = "SELECT gen_salt('md5') AS salt;";
				ResultSet rs = st.executeQuery(sql);
				if(rs.next())
					salt = rs.getString("salt");

				putConnection(con);
			}
		}
		catch(SQLException e){
			System.out.println(e);
		}

		return salt;
	}

	public static String generateHash(String pass, String salt){
		String hash = null;     
		try{
			Connection con = getConnection();
			if(con!=null){
				Statement st = con.createStatement();
				String sql = "SELECT crypt('"+pass+"','"+salt+"') AS hash;";
				ResultSet rs = st.executeQuery(sql);
				if(rs.next())
					hash = rs.getString("hash");

				putConnection(con);
			}
		}
		catch(SQLException e){
			System.out.println(e);
		}

		return hash;    
	}

	public static boolean registerUser(String user, String pass, String name, String id_country, String city_name,
									   String birthdate, String email, String address, boolean public_, Boolean gender_male){
		/*
			'gender_male' needs to be Boolean (capital B) to accept null values
		 */
		Integer id_city = null;
		try{
			Connection con = getConnection();
			if(con != null){
				Statement st = con.createStatement();
				ResultSet rs;
				String sql, salt, hash;
		
			
				if(id_country == null || existsCountry(id_country)){
					if( !city_name.equals("") )
						id_city = getCityID(city_name);
					// generate salt
					salt = generateSalt();
					hash = generateHash(pass, salt);

					sql = "INSERT INTO \"user\" (login, id_city, id_country, pwhash, name, birthdate, email, gender_male, address, public, salt, disabled) "
						+ "VALUES ('"+user+"',"+id_city+","+id_country+",'"+hash+"','"+name+"',"+birthdate+",'"+email+"',"+gender_male+",'"+address+"',"+public_+",'"+salt+"',false);";

					st.executeUpdate(sql);
					putConnection(con);
					return true;                    
				}
				putConnection(con);
			}
		}
		catch(SQLException e){
			System.out.println(e);
		}

		return false;
	}

	public static ResultSet getCountries(){
		ResultSet rs = null;
		try{
			Connection con = getConnection();
			if(con!=null){
				Statement st = con.createStatement();
				String query = "SELECT * FROM country;";
				rs = st.executeQuery(query);
				putConnection(con);
			}
		}
		catch( java.sql.SQLException e){
			System.out.println(e);
		}

		return rs;
	}

	public static ResultSet getChatrooms(){
		ResultSet rs = null;
		try{
			Connection con = getConnection();
			if(con!=null){
				Statement st = con.createStatement();
				String query = "SELECT theme, id_chatroom FROM chat_room;";
				rs = st.executeQuery(query);
				putConnection(con);
			}
		}
		catch( java.sql.SQLException e){
			System.out.println(e);
		}

		return rs;
	}

	public static ResultSet getPosts(String id_chatroom){
		ResultSet rs = null;
		try{
			Connection con = getConnection();
			if(con!=null){
				Statement st = con.createStatement();
				String query = "SELECT *"
				+ "FROM get_posts("+id_chatroom+", NULL);";

				rs = st.executeQuery(query);
				putConnection(con);
			}
		}
		catch( java.sql.SQLException e){
			System.out.println(e);
		}

		return rs;
	}

	public static String getChatRoomTheme(String id){
		String theme = "";
		try{
			Connection con = getConnection();
			if(con!=null){
				Statement st = con.createStatement();
				String query = "SELECT theme "
				+ "FROM chat_room "
				+ "WHERE id_chatroom="+id+";";

				ResultSet rs = st.executeQuery(query);
				if(rs.next())
				theme = rs.getString("theme");

				putConnection(con);
			}
		}
		catch( java.sql.SQLException e){
			System.out.println(e);
		}
		return theme;
	}


	public static ResultSet getUserInfo(String user){
		ResultSet rs = null;
		try{
			Connection con = getConnection();
			if(con!=null){
				Statement st = con.createStatement();
				String query = "SELECT * FROM \"user\" WHERE login='"+user+"'";

				rs = st.executeQuery(query);
			}       
		}catch( java.sql.SQLException e){
			System.out.println(e);
		}               
		return rs;
	}

	public static boolean addChatRoom(String theme, String creator){
		try{
			Connection con = getConnection();
			if(con!=null){
				Statement st = con.createStatement();
				String query = "INSERT INTO chat_room"
				+ "(creator, theme)"
				+ "VALUES ('"+creator+"', '"+theme+"');";

				st.executeUpdate(query);
				putConnection(con);
			}
		}
		catch( java.sql.SQLException e){
			System.out.println(e);
			return false;
		}
		return true;
	}

	public static boolean addPM(String to,String text,String from){
	//PM:       id_message | to | read 
	//Message:  id_message | from | id_attach | text | read_date | sent_date | image | msg_type
	try{
		Connection con = getConnection();
		if(con!=null){
		Statement st = con.createStatement();
		String query = 
			"BEGIN;"+
			"INSERT INTO message (to,type) VALUES ('"+to+"','B');"+
			"INSERT INTO pm (text,from) VALUES ('"+text+"','"+from+"');"+
			"COMMIT;";
		
		st.executeUpdate(query);
		putConnection(con);
		}
	}
	catch( java.sql.SQLException e){
		System.out.println(e);
		return false;
	}               
	return true;
	}


	public static void updateProfile(String user, boolean public_, boolean gender_male, String birthdate, String email, String address, String name, String country){
		ResultSet rs = null;
		try{
			Connection con = getConnection();
			if(con!=null){
				Statement st = con.createStatement();
				String query = "UPDATE \"user\" SET public="+public_+" , gender_male="+gender_male+" , birthdate="+birthdate+" , email='"+email+"' , address='"+address+"' , name='"+name+"' , id_country="+country+" WHERE login='"+user+"'";
				st.executeUpdate(query);
			}       
		}catch( java.sql.SQLException e){
			System.out.println(e);
		}               
	}

	public static void disableProfile(String user){
		ResultSet rs = null;
		try{
			Connection con = getConnection();
			if(con!=null){
				Statement st = con.createStatement();
				String query = "UPDATE \"user\" SET disabled=true WHERE login='"+user+"'";
				st.executeUpdate(query);
			}       
		}catch( java.sql.SQLException e){
			System.out.println(e);
		}               
	}

	public static void updatePassword(String user, String pass){
		ResultSet rs = null;

		try{
			String salt = generateSalt();
			String hash = generateHash(pass, salt);
			Connection con = getConnection();
			if(con!=null){
				Statement st = con.createStatement();
				String query = "UPDATE \"user\" SET pwhash='"+hash+"', salt='"+salt+"' WHERE login='"+user+"'";
				st.executeUpdate(query);
			}       
		}catch( java.sql.SQLException e){
			System.out.println(e);
		}
	}

}