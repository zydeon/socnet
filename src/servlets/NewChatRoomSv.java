import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.Date;
import dbconnect.Database;

public class NewChatRoomSv extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
    	System.out.println("TESTE");
		String theme = request.getParameter("new_chatroom_theme");
		Connection con = Database.getConnection();
		try{
			Database.addChatRoom(con, theme, (String) request.getSession().getAttribute("user")  );	
			response.sendRedirect("");
		}
		catch( java.sql.SQLException e){
			Database.putConnection(con);								
			response.sendRedirect("?msg="+e.getMessage());
		}
		
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	doGet(request, response);
    }
}
