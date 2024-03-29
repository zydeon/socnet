import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.MultipartConfig;
import java.sql.*;
import dbconnect.Database;


public class DeletePMSv extends HttpServlet {
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	Integer id_pm=Integer.parseInt(request.getParameter("id"));
	String src  = (String)request.getSession().getAttribute("user");
	
	Connection con = Database.getConnection();
	try{
	    Database.deletePM(con, id_pm,src);
	    response.sendRedirect("pm?list=inbox");
	}
	catch(SQLException e){
		Database.putConnection(con);
	    response.sendRedirect("pm?list=inbox");
	}    
    }	
}
