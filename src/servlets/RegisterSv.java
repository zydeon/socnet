import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.Date;
import dbconnect.Database;

public class RegisterSv extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		PrintWriter out = response.getWriter();

		String user      = request.getParameter("user");
		String pass      = request.getParameter("password");
		String name = request.getParameter("name");

		String id_country = request.getParameter("country"); //.toUpperCase();
		String city_name = request.getParameter("city"); //.toUpperCase();

		if (id_country.equals("none"))
			id_country=null;		

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

		try{
			Database.registerUser(user, pass, name, id_country, city_name, birthdate, email, address, public_, gender_male);
			System.out.println("registo deu");
			request.getSession(true).setAttribute("user", user);
			response.sendRedirect("");			
		}
		catch(SQLException e){
			response.sendRedirect("register.jsp?msg="+e.getMessage());
		}
	}
}
