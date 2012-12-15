import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.Date;
import dbconnect.Database;

public class DisableInfoSv extends HttpServlet {

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
		String user_login = (String) request.getSession().getAttribute("user");

		Database.deleteInfo(user_login);
		response.sendRedirect("");
	}
}
