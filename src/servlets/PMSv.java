import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.Date;
import dbconnect.Database;

public class PMSv extends HttpServlet{
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException,ServletException{
	String list = request.getParameter("list");
	System.out.println("LIST="+list);
	if(list != null){
	    try{
		java.sql.ResultSet pms = null;
		if( list.equals("inbox")){
		    pms = Database.getInbox((String)request.getSession().getAttribute("user"));
		}
		else if(list.equals("outbox")){
		    pms = Database.getOutbox((String)request.getSession().getAttribute("user"));
		}
		else if(list.equals("history")){
		    pms = Database.getHistory((String)request.getSession().getAttribute("user"),(String)request.getParameter("other"));
		}
		request.setAttribute("pms", pms);
			    
		RequestDispatcher dispatcher = request.getRequestDispatcher("pm.jsp");
		dispatcher.forward(request, response);
		
	    }
	    catch(SQLException e){
		System.out.println("INVALID PM LIST");	
	    }
	}
	else{
	    System.out.println("INVALID PM LIST");	
	}
    }
}
