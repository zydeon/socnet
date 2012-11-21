
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

	public static String[] getCountries(){
		ArrayList<String> countries = new ArrayList<String>();
		try{
			Connection con = getConnection();
			if(con!=null){
				Statement st = con.createStatement();
				String query = "SELECT name FROM country;";
				ResultSet rs = st.executeQuery(query);
				while( rs.next() )
					countries.add( rs.getString("name") );
					
				putConnection(con);
			}
		}
		catch( java.sql.SQLException e){
			System.out.println(e);
		}

		return countries.toArray( new String[0] );
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
}