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
		Connection con = Database.getConnection();
		Boolean res = false;
		if(con != null){
			try{
				String sql = "SELECT auth_user('"+user+"','"+pass+"') AS success";
				PreparedStatement st = con.prepareStatement( "SELECT auth_user(?,?) AS success" );
				st.setString(1, user);
				st.setString(2, pass);
				ResultSet rs = st.executeQuery();

				if( rs.next() )
					res = rs.getBoolean("success");
				
				Database.putConnection(con);
			}
			catch(SQLException e){
				System.out.println(e);
			}
		}
		return res;
	}

	// public static boolean existsUser(String user){
	// 	Connection con = Database.getConnection();
	// 	Boolean res = false;
	// 	if(con != null){
	// 		try{
	// 			String sql = "SELECT user_exists('"+user+"') AS exists;";
	// 			Statement st = con.createStatement();
	// 			ResultSet rs = st.executeQuery(sql);

	// 			if( rs.next() )
	// 				res = rs.getBoolean("exists");
				
	// 			Database.putConnection(con);
	// 		}
	// 		catch(SQLException e){
	// 			System.out.println(e);
	// 		}
	// 	}
	// 	return res;
	// }

    public static ArrayList<String> getUserNames() throws SQLException{
		Connection con = Database.getConnection();
		ArrayList<String> names = new ArrayList<String>();
		if(con != null){
			PreparedStatement st = con.prepareStatement("SELECT get_all_users()");
			ResultSet rs = st.executeQuery();
		    try{
				while(rs.next())
				    names.add(rs.getString(1));
				
				Database.putConnection(con);
		    }catch(SQLException e){
				System.out.println(e);
	    	}
		}
		return names;
    }
    
	public static void registerUser(String user, String pass, String name, String id_country, String city_name,
									   String birthdate, String email, String address, boolean public_, Boolean gender_male) throws SQLException{
		Integer id_city = null;
		Connection con = getConnection();
		if(con != null){
			String sql = "SELECT register_user('"+user+"', '"+pass+"', '"+name+"', "+id_country+", '"+city_name+"', "+birthdate+", '"+email+"', '"+address+"', "+public_+", "+gender_male+");";
			Statement st = con.createStatement();
			ResultSet rs = st.executeQuery(sql);
			
			Database.putConnection(con);
		}
	}

	public static ResultSet getCountries(){
		ResultSet rs = null;
		try{
			Connection con = getConnection();
			if(con!=null){
				PreparedStatement st = con.prepareStatement("SELECT * FROM get_countries()");
				rs = st.executeQuery();
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
				PreparedStatement st = con.prepareStatement("SELECT * FROM get_chatrooms();");
				rs = st.executeQuery();
				putConnection(con);
			}
		}
		catch( java.sql.SQLException e){
			System.out.println(e);
		}

		return rs;
	}

    public static ResultSet getInbox(String username) throws SQLException{
		ResultSet rs = null;

		try{
		    Connection con = getConnection();
		    if(con!=null){
				PreparedStatement st = con.prepareStatement("SELECT * FROM get_inbox(?);");
				st.setString(1, username);
				rs = st.executeQuery();
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
				PreparedStatement st = con.prepareStatement("SELECT * FROM get_posts(?,NULL)");
				st.setInt(1, Integer.parseInt(id_chatroom) );
				rs = st.executeQuery();
				putConnection(con);
			}
		}
		catch( java.sql.SQLException e){
			System.out.println(e);
		}

		return rs;
	}

	public static String getChatroomTheme(String id) throws SQLException{
		String theme = "";
		Connection con = getConnection();
		if(con!=null){
			PreparedStatement st = con.prepareStatement("SELECT theme FROM get_chatroom_theme(?) AS theme");
			st.setInt(1, Integer.parseInt(id));
			ResultSet rs = st.executeQuery();
			if(rs.next())
				theme = rs.getString("theme");

			putConnection(con);
		}
		return theme;
	}


	public static ResultSet getUserInfo(String user){
		ResultSet rs = null;
		try{
			Connection con = getConnection();
			if(con!=null){
				PreparedStatement st = con.prepareStatement("SELECT * FROM get_user_info(?)");
				st.setString(1, user);

				rs = st.executeQuery();
			}       
		}catch( java.sql.SQLException e){
			System.out.println(e);
		}               
		return rs;
	}

	public static void addChatRoom(String theme, String creator) throws SQLException{
		Connection con = getConnection();
		if(con!=null){
			PreparedStatement st = con.prepareStatement("SELECT add_chatroom(?,?)");
			st.setString(1, creator);
			st.setString(2, theme);
			st.execute();
			putConnection(con);
		}
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


	public static void updateProfile(String user, String pass, String city_name, Integer id_country, String name, String birthdate, String email, Boolean gender_male, String address, Boolean public_){
		try{
			Connection con = getConnection();
			if(con!=null){
				PreparedStatement st = con.prepareStatement("SELECT update_profile(?,?,?,?,?,?,?,?,?,?)");
				st.setString(1, user);
				st.setString(2, pass);
				st.setString(3, city_name);
				st.setInt(4, id_country);
				st.setString(5, name);
				st.setObject(6, birthdate);
				st.setString(7, email);
				st.setBoolean(8, gender_male);
				st.setString(9, address);
				st.setBoolean(10, public_);

				st.executeUpdate();
			}       
		}catch( java.sql.SQLException e){
			System.out.println(e);
		}               
	}

	public static void toggleUser(String user, Boolean disabled){
		ResultSet rs = null;
		try{
			Connection con = getConnection();
			if(con!=null){
				PreparedStatement st = con.prepareStatement("SELECT disable_user(?,?);");
				st.setString(1, user);
				st.setBoolean(2, disabled);
				st.executeUpdate();
			}
		}catch( java.sql.SQLException e){
			System.out.println(e);
		}
	}
	public static void deleteInfo(String user){
		// ResultSet rs = null;
		// try{
		// 	Connection con = getConnection();
		// 	if(con!=null){
		// 		PreparedStatement st = con.prepareStatement("SELECT _user(?,?);");
		// 		st.setString(1, user);
		// 		st.setBoolean(2, disabled);
		// 		st.executeUpdate();
		// 	}
		// }catch( java.sql.SQLException e){
		// 	System.out.println(e);
		// }
	}	

	public static void updatePassword(String user, String pass){
		// ResultSet rs = null;

		// try{
		// 	String salt = generateSalt();
		// 	String hash = generateHash(pass, salt);
		// 	Connection con = getConnection();
		// 	if(con!=null){
		// 		Statement st = con.createStatement();
		// 		String query = "UPDATE \"user\" SET pwhash='"+hash+"', salt='"+salt+"' WHERE login='"+user+"'";
		// 		st.executeUpdate(query);
		// 	}       
		// }catch( java.sql.SQLException e){
		// 	System.out.println(e);
		// }
	}

}
