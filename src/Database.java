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
		Statement st = con.createStatement();
		ResultSet rs = st.executeQuery(sql);

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

    public static boolean existsUser(String user){
	Connection con = Database.getConnection();
	Boolean res = false;
	if(con != null){
	    try{
		String sql = "SELECT user_exists('"+user+"') AS exists;";
		Statement st = con.createStatement();
		ResultSet rs = st.executeQuery(sql);

		if( rs.next() )
		    res = rs.getBoolean("exists");
				
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
	String sql = "SELECT get_all_users()";
	Statement st = con.createStatement();
	ResultSet rs = st.executeQuery(sql);
	ArrayList<String> names = new ArrayList<String>();
	if(con != null){
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
    
    public static boolean registerUser(String user, String pass, String name, String id_country, String city_name,
				       String birthdate, String email, String address, boolean public_, Boolean gender_male){
	Integer id_city = null;
	Connection con = getConnection();
	if(con != null){
	    try{
		String sql = "SELECT register_user('"+user+"', '"+pass+"', '"+name+"', "+id_country+", '"+city_name+"', "+birthdate+", '"+email+"', '"+address+"', "+public_+", "+gender_male+");";
		Statement st = con.createStatement();
		ResultSet rs = st.executeQuery(sql);
				
		Database.putConnection(con);
		return true;
	    }
	    catch(SQLException e){
		System.out.println(e);
	    }
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

    public static ResultSet getInbox(String username) throws SQLException{
	ResultSet rs = null;

	try{
	    Connection con = getConnection();
	    if(con!=null){
		Statement st = con.createStatement();
		String query = "SELECT ";
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
