package dbconnect;	// needs package to be imported to JSP

import java.sql.*;
import java.util.ArrayList;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.text.SimpleDateFormat;

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

	public static ArrayList<String> getUserNames(){
		Connection con = Database.getConnection();
		ArrayList<String> names = new ArrayList<String>();
		if(con != null){
			try{
			PreparedStatement st = con.prepareStatement("SELECT * FROM get_user_names()");
			ResultSet rs = st.executeQuery();
				while(rs.next())
					names.add(rs.getString(1));
				
				Database.putConnection(con);
			}catch(SQLException e){
				System.out.println(e);
			}
		}
		return names;
	}
	
	public static void registerUser(Connection con, String user, String pass, String name, String id_country, String city_name,
		String birthdate, String email, String address, boolean public_, Boolean gender_male) throws SQLException{
		Integer id_city = null;
		if(con != null){
			con.setAutoCommit(false);
			String sql = "SELECT register_user('"+user+"', '"+pass+"', '"+name+"', "+id_country+", '"+city_name+"', "+birthdate+", '"+email+"', '"+address+"', "+public_+", "+gender_male+");";
			Statement st = con.createStatement();
			ResultSet rs = st.executeQuery(sql);
			con.commit();
			con.setAutoCommit(true);
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

	public static ResultSet getChatroomInfo(String id_chatroom){
		ResultSet rs = null;
		try{
			Connection con = getConnection();
			if(con!=null){
				PreparedStatement st = con.prepareStatement("SELECT * FROM get_chatroom_info(?);");
				st.setInt(1, Integer.parseInt(id_chatroom));

				rs = st.executeQuery();
				putConnection(con);
			}
		}
		catch( java.sql.SQLException e){
			System.out.println(e);
		}

		return rs;
	}	

	public static ResultSet getUserPermissions(String id_chatroom){
		ResultSet rs = null;
		try{
			Connection con = getConnection();
			if(con!=null){
				PreparedStatement st = con.prepareStatement("SELECT * FROM get_users_permissions(?);");
				st.setInt(1, Integer.parseInt(id_chatroom));

				rs = st.executeQuery();
				putConnection(con);
			}
		}
		catch( java.sql.SQLException e){
			System.out.println(e);
		}

		return rs;
	}
	public static ResultSet getOutbox(String username){
		ResultSet rs = null;

		try{
			Connection con = getConnection();
			if(con!=null){
				PreparedStatement st = con.prepareStatement("SELECT * FROM get_outbox(?);");
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

	public static ResultSet getHistory(String user1, String user2){
		ResultSet rs = null;

		try{
			Connection con = getConnection();
			if(con!=null){
				con.setAutoCommit(false);
				PreparedStatement st = con.prepareStatement("SELECT * FROM get_history(?,?);");
				st.setString(1, user1);
				st.setString(2, user2);
				
				rs = st.executeQuery();
				con.commit();
				con.setAutoCommit(true);
				putConnection(con);
			}
		}
		catch( java.sql.SQLException e){
			System.out.println(e);
		}
		
		return rs;
	}

	public static void userRestrict(String login, Integer id_chatroom, Boolean read){
		try{
			Connection con = getConnection();
			if(con!=null){
				PreparedStatement st = con.prepareStatement("SELECT user_restriction(?,?,?);");
				st.setString(1, login);
				if(id_chatroom != null) st.setInt(2, id_chatroom);
				else 			 		st.setNull(2, java.sql.Types.INTEGER);
				if(read != null) st.setBoolean(3, read);
				else 			 st.setNull(3, java.sql.Types.BOOLEAN);

				st.executeQuery();
				putConnection(con);
			}
		}
		catch( java.sql.SQLException e){
			System.out.println(e);
		}
	}			

	public static ResultSet getUserChatrooms(String user_login){
		ResultSet rs = null;
		try{
			Connection con = getConnection();
			if(con!=null){
				PreparedStatement st = con.prepareStatement("SELECT * FROM get_chatrooms(?);");
				st.setString(1, user_login);
				rs = st.executeQuery();
				putConnection(con);
			}
		}
		catch(java.sql.SQLException e){
			System.out.println(e);
		}

		return rs;
	}

	public static void editChatroom(Connection con, Integer id_chatroom, String creator, String theme, Boolean closed) throws SQLException{
		//Connection con = getConnection();
		if(con!=null){
			con.setAutoCommit(false);
			PreparedStatement st = con.prepareStatement("SELECT update_chatroom(?,?,?,?);");
			if(id_chatroom != null) st.setInt(1, id_chatroom);
			else st.setNull(1, java.sql.Types.INTEGER);
			st.setString(2, creator);
			st.setString(3, theme);
			if(closed != null) st.setBoolean(4, closed);
			else 			st.setNull(4, java.sql.Types.BOOLEAN);

			st.execute();
			con.commit();
			con.setAutoCommit(true);
			putConnection(con);
		}
	}

	public static ResultSet getInbox(String username){
		ResultSet rs = null;
		Connection con = null;
		try{
			con = getConnection();
			if(con!=null){
				con.setAutoCommit(false);
				PreparedStatement st = con.prepareStatement("SELECT * FROM get_inbox(?);");
				st.setString(1, username);
				rs = st.executeQuery();
				con.commit();
				con.setAutoCommit(true);
				putConnection(con);
			}
		}
		catch( java.sql.SQLException e){
			System.out.println(e);
			try{
				con.rollback();
				con.setAutoCommit(true);
			}
			catch(SQLException e_){System.out.println("Rolling back: "+e_);}
			putConnection(con);
		}

		return rs;
	}

	public static ResultSet getPosts(Connection con, String id_chatroom, String userlogin) throws SQLException{
		ResultSet rs = null;
		if(con!=null){
			PreparedStatement st = con.prepareStatement("SELECT * FROM get_posts(?,NULL,?)");
			st.setInt(1, Integer.parseInt(id_chatroom) );
			st.setString(2, userlogin );
			rs = st.executeQuery();
		}

		putConnection(con);
		return rs;
	}

	public static String getChatroomTheme(Connection con, String id) throws SQLException{
		String theme = "";
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
				putConnection(con);
			}       
		}catch( java.sql.SQLException e){
			System.out.println(e);
		}               
		return rs;
	}

	public static void addChatRoom(Connection con, String theme, String creator) throws SQLException{
		if(con!=null){
			PreparedStatement st = con.prepareStatement("SELECT add_chatroom(?,?)");
			st.setString(1, creator);
			st.setString(2, theme);
			st.execute();
			putConnection(con);
		}
	}

	public static boolean addPM(String from, String to,String text,String attach, String time){

		System.out.println("FROM "+from+ " TO "+to+" TEXT "+text+" PATH "+attach+" TIME "+time);
		Connection con = null;
		try{
			con = getConnection();
			if(con!=null){
				con.setAutoCommit(false);
				PreparedStatement st= null;
				if(time == null)
					st = con.prepareStatement("SELECT add_pm(?,?,?,?);");
				else 
					st = con.prepareStatement("SELECT add_delayed_pm(?,?,?,?,?);");
				
				st.setString(1, from);
				st.setString(2, to);
				st.setString(3, text);
				st.setString(4, attach);

				if(time != null){
					SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
					try{
						java.util.Date parsedDate = dateFormat.parse(time);
						java.sql.Timestamp timestamp = new java.sql.Timestamp(parsedDate.getTime());
						st.setTimestamp(5, timestamp);
					}catch(java.text.ParseException e){
						System.out.println(e);
					}
					
				}
				
				st.execute();
				con.commit();
				con.setAutoCommit(true);
				putConnection(con);
			}
		}catch( java.sql.SQLException e){
			System.out.println(e);
			try{
				con.rollback();
				con.setAutoCommit(true);
			}
			catch(SQLException e_){System.out.println("Rolling back: "+e_);}
			putConnection(con);
		}		
		return true;
	}
	
	
	public static void updateProfile(String user, String pass, String city_name, Integer id_country, String name, String birthdate, String email, Boolean gender_male, String address, Boolean public_){
		Connection con = null;
		try{
			con = getConnection();
			if(con!=null){
				con.setAutoCommit(false);
				PreparedStatement st = con.prepareStatement("SELECT update_profile(?,?,?,?,?,"+birthdate+",?,?,?,?)");
				st.setString(1, user);
				st.setString(2, pass);
				st.setString(3, city_name);
				if(id_country != null) st.setInt(4, id_country);
				else 			st.setNull(4, java.sql.Types.INTEGER);

				st.setString(5, name);
				//st.setString(6, birthdate);
				st.setString(6, email);

				if(gender_male != null) st.setBoolean(7, gender_male);
				else 			st.setNull(7, java.sql.Types.BOOLEAN);

				st.setString(8, address);

				if(public_ != null) st.setBoolean(9, public_);
				else 			st.setNull(9, java.sql.Types.BOOLEAN);				

				st.execute();
				con.commit();
				con.setAutoCommit(true);
				putConnection(con);
			}       
		}catch( java.sql.SQLException e){
			System.out.println(e);
			try{
				con.rollback();
				con.setAutoCommit(true);
			}
			catch(SQLException e_){System.out.println("Rolling back: "+e_);}
			putConnection(con);			
		}               
	}

	public static void toggleUser(String user, Boolean disabled){
		try{
			Connection con = getConnection();
			if(con!=null){
				PreparedStatement st = con.prepareStatement("SELECT disable_user(?,?);");
				st.setString(1, user);
				st.setBoolean(2, disabled);
				st.executeUpdate();
				putConnection(con);
			}
		}catch( java.sql.SQLException e){
			System.out.println(e);
		}
	}

	public static ResultSet searchUser(String user, String city_name, String country_name , String name , Integer age, String email , Boolean gender_male , String address, Boolean public_){
		System.out.println("user="+user);
		System.out.println("city_name="+city_name);
		System.out.println("country_name="+country_name);
		System.out.println("name="+name);
		System.out.println("age="+age);
		System.out.println("email="+email);
		System.out.println("gender_male="+gender_male);
		System.out.println("address="+address);
		System.out.println("public_="+public_);

		ResultSet rs = null;
		try{
			Connection con = getConnection();
			if(con!=null){
				PreparedStatement st = con.prepareStatement("SELECT * FROM search_user(?,?,?,?,?,?,?,?,?);");
				st.setString(1, user);
				st.setString(2, city_name);
				st.setString(3, country_name);
				st.setString(4, name);
				if(age != null) st.setInt(5, age);
				else 			st.setNull(5, java.sql.Types.INTEGER);
				st.setString(6, email);

				if(gender_male != null) st.setBoolean(7, gender_male);
				else 					st.setNull(7, java.sql.Types.BOOLEAN);

				st.setString(8, address);

				if(public_ != null) st.setBoolean(9, public_);
				else 			st.setNull(9, java.sql.Types.BOOLEAN);				

				rs = st.executeQuery();
				putConnection(con);
			}
		}catch( java.sql.SQLException e){
			System.out.println(e);
		}		
		return rs;
	}

	public static void addPost(Connection con, Integer id_chatroom, String source, String text, Integer parent, String filePath, Integer rlevel) throws SQLException{
		if(con!=null){
			con.setAutoCommit(false);
			PreparedStatement st = con.prepareStatement("SELECT add_post(?,?,?,?,?,?);");
			if(id_chatroom != null) st.setInt(1, id_chatroom);
			else 					st.setNull(1, java.sql.Types.INTEGER);				

			st.setString(2, source);
			st.setString(3, text);

			if(parent != null) st.setInt(4, parent);
			else 			   st.setNull(4, java.sql.Types.INTEGER);								

			st.setString(5, filePath);

			if(rlevel != null) st.setInt(6, rlevel);
			else 			   st.setNull(6, java.sql.Types.INTEGER);				

			st.execute();
			con.commit();
			con.setAutoCommit(true);
			putConnection(con);
		}	
	}
	public static void deletePost(Connection con, int id,String from) throws SQLException{
		if(con!=null){
			PreparedStatement st = con.prepareStatement("SELECT delete_post(?,?);");
			st.setInt(1, id);
			st.setString(2, from);				

			st.execute();
			putConnection(con);
		}	
	}

	public static void deletePM(Connection con, int id,String from) throws SQLException{
		if(con!=null){
			PreparedStatement st = con.prepareStatement("SELECT delete_pm(?,?);");
			st.setInt(1, id);
			st.setString(2, from);				

			st.execute();
			putConnection(con);
		}	
	}

	public static ResultSet searchChatrooms(String creator, String theme){
		ResultSet rs = null;
		try{
			Connection con = getConnection();
			if(con!=null){
				PreparedStatement st = con.prepareStatement("SELECT * FROM search_chatrooms(?,?);");
				st.setString(1, creator);
				st.setString(2, theme);				

				rs = st.executeQuery();
				putConnection(con);
			}
		}catch( java.sql.SQLException e){
			System.out.println(e);
		}		
		return rs;
	}	

	public static void deleteInfo(Connection con, String user)throws SQLException{
		if(con!=null){
			con.setAutoCommit(false);
			PreparedStatement st = con.prepareStatement("SELECT delete_activity(?);");
			st.setString(1, user);
			st.execute();
			con.commit();
			con.setAutoCommit(true);
			putConnection(con);
		}
	}

	public static void addRate(Connection con, String user, int chatroom,String rate) throws SQLException{
		System.out.println(user + chatroom + rate);
		if(con!=null){
			con.setAutoCommit(false);
			PreparedStatement st = con.prepareStatement("SELECT * FROM rate_chatroom(?,?,?);");
			st.setString(1, user);
			st.setInt(2, chatroom);			     
			st.setString(3,rate);

			st.execute();
			con.commit();
			con.setAutoCommit(true);
			putConnection(con);
		}	
	}	

}
