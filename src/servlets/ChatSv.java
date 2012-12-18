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
			Connection con = Database.getConnection();
			Connection con2 = Database.getConnection();
			try{
				String theme = Database.getChatroomTheme(con2, id_chatroom);

				try{
					java.sql.ResultSet posts = Database.getPosts(con, id_chatroom, (String)request.getSession().getAttribute("user"));
					request.setAttribute("theme", theme);					System.out.println("THEME="+theme);
					request.setAttribute("posts", posts);					System.out.println("POSTS="+posts);
					request.setAttribute("id_chatroom", id_chatroom);		System.out.println("ID_CHAT="+id_chatroom);

					String dest = "chat.jsp";
					String msg = request.getParameter("msg");
					if(msg!=null){
						dest += "?msg="+msg;
					}

					RequestDispatcher dispatcher = request.getRequestDispatcher(dest);
					dispatcher.forward(request, response);
				}
				catch(SQLException e){
					Database.putConnection(con);					
					response.sendRedirect("chat.jsp?msg="+e.getMessage());
				}
			}
			catch(SQLException e){
				Database.putConnection(con2);									
				response.sendRedirect("chat.jsp?msg="+e.getMessage());
			}
		}
		else{
			System.out.println("INVALIDE CHAT ROOM");	
		}
    }
}
