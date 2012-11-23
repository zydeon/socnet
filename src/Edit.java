import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.Date;
import dbconnect.Database;

public class Edit extends HttpServlet {

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

	PrintWriter out = response.getWriter();

	String user = (String) request.getSession().getAttribute("user");
	String name = request.getParameter("name");
	String pass = request.getParameter("password");

	String country = request.getParameter("country"); //.toUpperCase();
	String city = request.getParameter("city"); //.toUpperCase();

	if (country.equals("none"))
		country=null;

	Integer id_city = null;

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
		
	Boolean public_ = request.getParameter("public") != null;

	if (!pass.equals(""))
		Database.updatePassword(user, pass);
	Database.updateProfile(user, public_, gender_male, birthdate, email, address, name, country);


	response.sendRedirect("index.jsp");

    }

}
