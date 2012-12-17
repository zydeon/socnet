import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.Date;
import dbconnect.Database;

public class ChatSv extends HttpServlet{
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException,ServletException{
		String id_chatroom = request.getParameter("id");
		System.out.println("ID="+id_chatroom);

		if(id_chatroom != null){
			try{
				String theme = Database.getChatroomTheme(id_chatroom);

				try{
					java.sql.ResultSet posts = Database.getPosts(id_chatroom);
					request.setAttribute("theme", theme);					System.out.println("THEME="+theme);
					request.setAttribute("posts", posts);					System.out.println("POSTS="+posts);
					request.setAttribute("id_chatroom", id_chatroom);		System.out.println("ID_CHAT="+id_chatroom);

					RequestDispatcher dispatcher = request.getRequestDispatcher("chat.jsp");
					dispatcher.forward(request, response);
				}
				catch(SQLException e){
					response.sendRedirect("chat.jsp?msg="+e.getMessage());
				}
			}
			catch(SQLException e){
				System.out.println("INVALIDE CHAT ROOM");	
			}
		}
		else{
			System.out.println("INVALIDE CHAT ROOM");	
		}
    }
}
