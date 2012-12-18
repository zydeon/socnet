import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.Date;
import dbconnect.Database;

public class DeleteInfoSv extends HttpServlet {

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
		String user_login = (String) request.getSession().getAttribute("user");

		Connection con = Database.getConnection();
		try{
			Database.deleteInfo(con, user_login);
			response.sendRedirect("");
		}
		catch(SQLException e){
			try{
				con.rollback();
				con.setAutoCommit(true);
			}
			catch(SQLException e_){System.out.println("Rolling back: "+e_);}
			Database.putConnection(con);			
			response.sendRedirect("edit_profile.jsp?msg="+e.getMessage());
		}
	}
}
