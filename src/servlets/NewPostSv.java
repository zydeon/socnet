import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.MultipartConfig;
import java.sql.*;
import dbconnect.Database;


@MultipartConfig()
public class NewPostSv extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String text = request.getParameter("text");
		String src  = (String)request.getSession().getAttribute("user");
		Integer id_chatroom = Integer.parseInt(request.getParameter("id_chatroom"));
		Part file = request.getPart("attach");
		String filePath = null;
		if( file.getSize() > 0 ){
			String fileName = getFilename(file);
			filePath = "attachments/"+fileName;
			String currentPath = request.getSession().getServletContext().getRealPath("/");
			file.write( currentPath + filePath );
		}

		Connection con = Database.getConnection();
		try{
			Database.addPost(con, id_chatroom, src, text, null, filePath, 0);
			response.sendRedirect("chat?id="+id_chatroom);
		}
		catch(SQLException e){
			try{
				con.rollback();
				con.setAutoCommit(true);
			}
			catch(SQLException e_){System.out.println("Rolling back: "+e_);}
			Database.putConnection(con);
			response.sendRedirect("chat.jsp?msg="+e.getMessage());
		}

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
