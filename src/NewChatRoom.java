import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.Date;
import dbconnect.Database;

public class NewChatRoom extends HttpServlet {

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
		String theme = request.getParameter("new_chatroom_theme");
		Database.addChatRoom(theme, (String) request.getSession().getAttribute("user")  );
		response.sendRedirect("index.jsp");
	}

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	doGet(request, response);
	}
}
