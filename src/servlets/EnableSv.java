import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.Date;
import dbconnect.Database;

public class EnableSv extends HttpServlet {

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
		HttpSession session = request.getSession();
		String user_login = (String) session.getAttribute("user");

		Database.toggleUser(user_login, false);
		response.sendRedirect("");
	}
}
