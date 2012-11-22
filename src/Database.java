package dbconnect;		// needs package to be imported to JSP

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
	private static final int SALT_BYTES = 32;

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

	
	// MUDAR PARA SERVLETS (TIRAR SYNCHRONIZED) ????
	public static synchronized String generateHash(String password, String salt) throws java.security.NoSuchAlgorithmException {
		MessageDigest digest = MessageDigest.getInstance("SHA-256");
		digest.reset();
		// REVER ISTO
		digest.update(salt.getBytes());
		return bytesToHex( digest.digest(password.getBytes()) );
	}

	public static synchronized String generateSalt() throws java.io.UnsupportedEncodingException{
		byte[] salt = new byte[SALT_BYTES];
		(new SecureRandom()).nextBytes(salt);
		return bytesToHex(salt);
	}

	private static String bytesToHex(byte[] bytes){
		String res = "0x";
		for (byte b : bytes) {
			res += String.format("%02X", b);
		}
		return res;
	}

	public static boolean authUser(String user, String pass){
		try{
			Connection con = Database.getConnection();
			if( con != null ){
				Statement st = con.createStatement();
				ResultSet rs;

				String sql = "SELECT salt FROM \"user\" WHERE login='"+user+"';";
				rs = st.executeQuery(sql);
				if(rs.next()){
					String salt = rs.getString("salt");
					String hash = generateHash(pass, salt);

					sql = "SELECT count(*) FROM \"user\" WHERE login='"+user+"' AND pass='"+hash+"'";
					rs = st.executeQuery(sql);
					if( rs.next() && rs.getInt("count")>0 )
					return true;
				}
				Database.putConnection(con);
			}
		}
		catch(SQLException e){
			System.out.println(e);
		}
		catch(java.security.NoSuchAlgorithmException e){
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

	// public static boolean registerUser(String user, String pass, String name, String country, String city, String birthdate, String email, String address, boolean public_){
	// 	Connection con = Database.getConnection();
	// 	if(con != null){
	// 		try{
	// 			String sql = "SELECT login FROM \"user\" WHERE login='"+user+"'";
	// 			Statement st = con.createStatement();
	// 			ResultSet rs = st.executeQuery(sql);

	// 			if( rs.next() ){
	// 				response.sendRedirect("register.jsp?msg=User already exists");
	// 			}
	// 			else {
	// 				if( !country.equals("none") ) {

	// 					sql = "SELECT id_country FROM \"country\" WHERE name='"+country+"';";
	// 					rs = st.executeQuery(sql);
	// 					if (rs.next())
	// 						id_country = rs.getInt("id_country");

	// 					if( !city.equals("") ){

	// 						sql = "SELECT id_city, id_country FROM \"city\" WHERE name = '"+city+"';";
	// 						rs = st.executeQuery(sql);
	// 						// if alreay exists
	// 						if( rs.next() ){
	// 							id_city = rs.getInt("id_city");
	// 							id_country = rs.getInt("id_country");
	// 						}
	// 						else{
	// 							sql = "INSERT INTO city (name, id_country) VALUES ('"+city+"',"+id_country+")";
	// 							st.executeUpdate(sql);
	// 							sql = "SELECT id_city FROM city WHERE name='"+city+"';";
	// 							rs = st.executeQuery(sql);
	// 							if(rs.next())
	// 								id_city = rs.getInt("id_city");
	// 						}
	// 					}
	// 				}

	// 				// generate salt
	// 				String salt = Database.generateSalt();
	// 				String hash = Database.generateHash(pass, salt);

	// 				sql =  "INSERT INTO \"user\" (login, pass, name, id_city, id_country, birthdate, email, address, gender_male, public, salt) ";
	// 				sql += "VALUES ('"+user+"','"+hash+"','"+name+"',"+id_city+","+id_country+","+birthdate+",'"+email+"','"+address+"',"+gender_male+","+public_+",'"+salt+"');";

	// 				st.executeUpdate(sql);
	// 				out.println("\nRegister successful!");
	// 				out.flush();
	// 			}
				
	// 			Database.putConnection(con);
	// 		}
	// 		catch(SQLException e){
	// 			System.out.println(e);
	// 		}
	// 		catch(java.security.NoSuchAlgorithmException e){
	// 			System.out.println(e);
	// 		}
	// 	}
	// }

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


	public static String getCity(String id_city){
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
		catch( java.sql.SQLException e){
	    	System.out.println(e);
	    	return false;
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
}
