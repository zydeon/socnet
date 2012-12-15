import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import dbconnect.Database;

public class EditChatSv extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String theme      = request.getParameter("theme");
		Boolean closed = request.getParameter("closed") != null;
		Integer id_chatroom = Integer.parseInt( request.getParameter("id_chatroom") );
		String creator = (String) request.getSession().getAttribute("user");

		try{
			Database.editChatroom(id_chatroom, creator, theme, closed);
			response.sendRedirect("manage_chatrooms.jsp");
		}
		catch(SQLException e){
			response.sendRedirect("edit_chatroom.jsp?msg="+e.getMessage()+"&id="+id_chatroom);
		}

	}	
}
