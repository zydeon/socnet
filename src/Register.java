import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.Date;
import dbconnect.Database;

public class Register extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		PrintWriter out = response.getWriter();

		String user      = request.getParameter("user");
		String pass      = request.getParameter("password");
		String name = request.getParameter("name");
		String country = request.getParameter("country");
		String city = request.getParameter("country").toUpperCase();


		int id_city = 1;
		int id_country = 1;
		String birthdate = "2012-11-4"; //new Date();
		String email = request.getParameter("email");
		String address = request.getParameter("address");
		boolean gender_male;
		gender_male = request.getParameter("gender_male").equals("male");
		boolean public_ = request.getParameter("public") != null;

		Connection con = Database.getConnection();
		if(con != null){
			try{
				String sql = "SELECT login FROM \"user\" WHERE login='"+user+"'";
				Statement st = con.createStatement();
				ResultSet rs = st.executeQuery(sql);
				if( rs.next() )
					out.println("Username already exists (redirect to register.html)!");
				else{



					sql = "SELECT id_city, id_country FROM \"city\" WHERE name = '"+city+"';";
					rs = st.executeQuery(sql);
					// if alreay exists
					if( rs.next() ){
						id_city = rs.getInt("id_city");
						id_country = rs.getInt("id_country");
					}
					else{
						// get id_country
						sql = "SELECT id_country FROM \"country\" WHERE name = '"+country+"';";
						rs = st.executeQuery(sql);
						if( rs.next() )
							id_country = rs.getInt("id_country");
			
						sql = "INSERT INTO city (name, id_country) VALUES ('"+city+"',"+id_country+")";
						st.executeUpdate(sql);
					}

					// generate salt
					String salt = Database.generateSalt();						
					String hash = Database.generateHash(pass, salt);

					System.out.println(salt);
					System.out.println(hash);

					sql =  "INSERT INTO \"user\" (login, pass, name, id_city, id_country, birthdate, email, address, gender_male, public, salt) ";
					sql += "VALUES ('"+user+"','"+hash+"','"+name+"',"+id_city+","+id_country+",'"+birthdate+"','"+email+"','"+address+"',"+gender_male+","+public_+",'"+salt+"');";

					out.println(sql);
					st.executeUpdate(sql);
					out.println("\nRegister successful! (redirect to index.html)");						
					
				}

				Database.putConnection(con);
			}
			catch(SQLException e){
				System.out.println(e);
			}
			catch(java.security.NoSuchAlgorithmException e){
				System.out.println(e);
			}
		}
		else
			System.out.println("Error connecting to database");
	}	

	// public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	// 	PrintWriter out = response.getWriter();
	// 	Connection con;
	// 	Statement st;
	// 	ResultSet rs = null;
	// 	String country;

	// 	try{
	// 		con = Database.getConnection();
	// 		st = con.createStatement();
	// 		String sql = "SELECT name FROM country;";
	// 		rs = st.executeQuery(sql);

	// 		out.println("<h1>soc.net</h1>");
	// 		out.println("<form action=\"register\" method=\"post\" >");
	// 		out.println("User: <input type=\"text\" name=\"user\"> <br>");
	// 		out.println("Password: <input type=\"password\" name=\"password\"> <br>");
	// 		out.println("Name: <input type=\"text\" name=\"name\"> <br>");
	// 		out.println("<!-- Birthday: <input type=\"text\" name=\"name\"> <br> -->");
	// 		out.println("Email: <input type=\"text\" name=\"email\"> <br>");
	// 		out.println("Address: <input type=\"text\" name=\"address\"> <br>");
	// 		out.println("Gender: M <input type=\"radio\" name=\"gender_male\">");
	// 		out.println("		F <input type=\"radio\" name=\"gender_female\">   <br>");
	// 		out.println("Public: Yes <input type=\"checkbox\" name=\"public\">");

	// 		// COUNTRIES
	// 		out.println("<select>");
	// 		while( rs.next() ){
	// 			country = rs.getString("name");
	// 			out.println( "<option value='"+country+"'>"+country+"</option>" );
	// 		}
	// 		out.println("</select>");		

	// 		out.println("<br>");
	// 		out.println("<br>");
	// 		out.println("<br>");
	// 		out.println("<input type=\"submit\" name=\"register\" value=\"Register\">");
	// 		out.println("</form>");
	// 	}
	// 	catch( java.sql.SQLException e){
	// 		System.out.println(e);
	// 	}
	// }

}
