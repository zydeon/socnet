import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import dbconnect.Database;

public class Logout extends HttpServlet {

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
		request.getSession().invalidate();
		response.sendRedirect("index.jsp");
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);	
	}	
}
