import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.Date;
import dbconnect.Database;

public class PMSv extends HttpServlet{
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException,ServletException{
	String to = request.getParameter("to");
	String text = request.getParameter("text");
	String from = (String)request.getSession().getAttribute("user");
	Database.addPM(to,text,from);
    }
}














