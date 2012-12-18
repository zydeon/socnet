import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.Date;
import dbconnect.Database;

public class rateSv extends HttpServlet{
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException,ServletException{
	String rate = request.getParameter("r");		
	Integer id_chatroom = Integer.parseInt(request.getParameter("id"));
	if(rate != null){
		Connection con = Database.getConnection();
	    try{
			Database.addRate(con, (String)request.getSession().getAttribute("user"),id_chatroom,rate);
			response.sendRedirect("chat?id="+id_chatroom);
			//return;
	    }
	    catch(SQLException e){
			try{
				con.rollback();
				con.setAutoCommit(true);
			}
			catch(SQLException e_){System.out.println("Rolling back: "+e_);}
			Database.putConnection(con);
			response.sendRedirect("chat?id="+id_chatroom+"&msg="+e.getMessage());
	    }
	}
	else{
	    	System.out.println("INVALID PM LIST");	
	}
    }
}
