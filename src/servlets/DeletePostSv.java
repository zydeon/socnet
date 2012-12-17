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
	
	try{
	    Database.deletePost(id_post,src);
	    response.sendRedirect("chat");
	}
	catch(SQLException e){
	    response.sendRedirect("chat.jsp?msg="+e.getMessage());
	}    
    }	
}
