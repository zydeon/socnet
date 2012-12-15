import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.MultipartConfig;
import java.sql.*;
import dbconnect.Database;


@MultipartConfig()
public class NewPMSv extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String text = request.getParameter("text");
		String from  = (String)request.getSession().getAttribute("user");
		String to = request.getParameter("to");
		String time = request.getParameter("time");
		Part file = request.getPart("attach");
		String filePath = null;
		if( file.getSize() > 0 ){
			String fileName = getFilename(file);
			filePath = "attachments/"+fileName;
			String currentPath = request.getSession().getServletContext().getRealPath("/");
			file.write( currentPath + filePath );
		}
		if(time.equals(""))
		    time=null;
		Database.addPM(from,to,text,filePath,time);
		System.out.println(filePath);
		response.sendRedirect("pm?list=inbox");
	}	


	private static String getFilename(Part part) {
	    for (String cd : part.getHeader("content-disposition").split(";")) {
	        if (cd.trim().startsWith("filename")) {
	            String filename = cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
	            return filename.substring(filename.lastIndexOf('/') + 1).substring(filename.lastIndexOf('\\') + 1); // MSIE fix.
	        }
	    }
	    return null;
	}
}
