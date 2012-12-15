import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.Date;
import dbconnect.Database;

public class SearchUserSv extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String user_login= request.getParameter("user_login");
		String name = request.getParameter("name");

		String country_name = request.getParameter("country_name");
		String city_name = request.getParameter("city_name");
		String address = request.getParameter("address");

		String age_ = request.getParameter("age");
		Integer age = null;
		if(!age_.equals(""))
			age = Integer.parseInt(age_);

		String email = request.getParameter("email");
		Boolean gender_male = null;
		if( request.getParameter("gender") != null )
			gender_male = request.getParameter("gender").equals("male");

		ResultSet searchedUsers = Database.searchUser(user_login, city_name, country_name, name, age, email, gender_male, address, true);
		request.setAttribute("searched_users", searchedUsers);

		RequestDispatcher dispatcher = request.getRequestDispatcher("search_user.jsp");
		dispatcher.forward(request, response);
	}
}
