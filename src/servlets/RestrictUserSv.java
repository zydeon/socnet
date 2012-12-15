import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import dbconnect.Database;

public class RestrictUserSv extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		String user_login = request.getParameter("login");
		Boolean write = request.getParameter("write") != null;
		Boolean read = request.getParameter("read") != null;
		Integer id_chatroom = Integer.parseInt( request.getParameter("id_chatroom") );

		Boolean restriction = null;

		if(!read)
			restriction = true;
		else if( !write )
			restriction = false;

		Database.userRestrict(user_login, id_chatroom, restriction);
		response.sendRedirect("edit_chatroom.jsp?id="+id_chatroom);

	}	
}
