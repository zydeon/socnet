import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.Date;
import dbconnect.Database;

public class EditProfileSv extends HttpServlet {

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		PrintWriter out = response.getWriter();

		String user = (String) request.getSession().getAttribute("user");
		String name = request.getParameter("name");
		String pass = request.getParameter("password");

		Integer id_country = Integer.parseInt(request.getParameter("country")); //.toUpperCase();
		String city = request.getParameter("city"); //.toUpperCase();

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
			
		Boolean public_ = request.getParameter("public") != null;

		Database.updateProfile(user, pass, city, id_country, name, birthdate, email, gender_male, address, public_ );

		response.sendRedirect("");

    }

}
