import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import dbconnect.Database;

public class Login extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String sql;
		PrintWriter out  = response.getWriter();

		String user      = request.getParameter("user");
		String pass      = request.getParameter("password");

		// ADICIONAR ISTO
		// escape(user);
		// escape(pass);

		if( Database.authUser(user, pass) ){
			request.getSession(true).setAttribute("user", user);
			response.sendRedirect("index.jsp");			
		}
		else{
			response.sendRedirect("login.jsp?msg=Wrong username or password");
		}	
	}	
}
