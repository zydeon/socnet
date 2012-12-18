import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.MultipartConfig;
import java.sql.*;
import dbconnect.Database;


public class DeletePostSv extends HttpServlet {
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	Integer id_post=Integer.parseInt(request.getParameter("id"));
	String src  = (String)request.getSession().getAttribute("user");
	
	Connection con = Database.getConnection();
	try{
	    Database.deletePost(con, id_post,src);
	    response.sendRedirect("chat");
	}
	catch(SQLException e){
		Database.putConnection(con);
	    response.sendRedirect("chat.jsp?msg="+e.getMessage());
	}    
    }	
}
