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

	String country = request.getParameter("country"); //.toUpperCase();
	String city = request.getParameter("city"); //.toUpperCase();

	Integer id_city = null;
	Integer id_country = null;

	String day = request.getParameter("day");
	String month = request.getParameter("month");
	String year = request.getParameter("year");

	String birthdate = null;
	if( !day.equals("none") && !month.equals("none") && !year.equals("none") )
	    birthdate = "'"+year+"-"+month+"-"+day+"'";


	String email = request.getParameter("email");
	String address = request.getParameter("address");
	Boolean gender_male = null;
	if( request.getParameter("gender") != null )
	    gender_male = request.getParameter("gender").equals("male");
		
	boolean public_ = request.getParameter("public") != null;


	// if( Database.existsUser(user) ){
	// 	if(  )
	// }
	// else
	// 	response.sendRedirect("register.jsp?msg=User already exists");


	// Database.registerUser(user, pass, name, country, city, birthdate, email, address, public_);


	Connection con = Database.getConnection();
	if(con != null){
	    try{
		String sql = "SELECT login FROM \"user\" WHERE login='"+user+"'";
		Statement st = con.createStatement();
		ResultSet rs = st.executeQuery(sql);

		if( rs.next() ){
		    response.sendRedirect("register.jsp?msg=User already exists");
		}
		else {
		    if( !country.equals("none") ) {

			sql = "SELECT id_country FROM \"country\" WHERE name='"+country+"';";
			rs = st.executeQuery(sql);
			if (rs.next()) 
			    id_country = rs.getInt("id_country");

			if( !city.equals("") ){

			    sql = "SELECT id_city FROM \"city\" WHERE name = '"+city+"';";
			    rs = st.executeQuery(sql);
			    // if alreay exists
			    if( rs.next() ){
					id_city = rs.getInt("id_city");
			    }else{				
					sql = "INSERT INTO city (name) VALUES ('"+city+"')";
					st.executeUpdate(sql);
					sql = "SELECT id_city FROM city WHERE name='"+city+"';";
					rs = st.executeQuery(sql);
					if(rs.next())
					    id_city = rs.getInt("id_city");
			    }
			}
		    }

		    // generate salt
		    String salt = Database.generateSalt();						
		    String hash = Database.generateHash(pass, salt);

		    sql =  "INSERT INTO \"user\" (login, pass, name, id_city, id_country, birthdate, email, address, gender_male, public, salt, disabled) ";
		    sql += "VALUES ('"+user+"','"+hash+"','"+name+"',"+id_city+","+id_country+","+birthdate+",'"+email+"','"+address+"',"+gender_male+","+public_+",'"+salt+"',false);";

		    st.executeUpdate(sql);
		    out.println("\nRegister successful!");
		    out.flush();
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

	try{
	    response.sendRedirect("register.jsp?msg=Problems with connection or database!");
	}
	catch(java.lang.IllegalStateException e){}

    }

}
