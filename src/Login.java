import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import dbconnect.Database;

public class Login extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String sql;
		PrintWriter out  = response.getWriter();

		String user      = request.getParameter("user");
		String pass      = request.getParameter("password");

		// ADICIONAR ISTO
		// escape(user);
		// escape(pass);

		try{
			Connection con = Database.getConnection();

			if( con != null ){
				Statement st = con.createStatement();
				ResultSet rs;

				sql = "SELECT salt FROM \"user\" WHERE login='"+user+"';";
				rs = st.executeQuery(sql);
				if(rs.next()){
					String salt = rs.getString("salt");
					String hash = Database.generateHash(pass, salt);

					sql = "SELECT count(*) FROM \"user\" WHERE login='"+user+"' AND pass='"+hash+"'";
					rs = st.executeQuery(sql);
					if( rs.next() ){
						request.getSession(true).setAttribute("user", user);
						response.sendRedirect("index.jsp");
					}
					else
						response.sendRedirect("login.jsp?msg=Wrong username or password");
				}	
				else
					response.sendRedirect("login.jsp?msg=Wrong username or password");

				Database.putConnection(con);
			}		
		}
		catch(SQLException e){
			System.out.println(e);
		}
		catch(java.security.NoSuchAlgorithmException e){
			System.out.println(e);
		}

		try{
			response.sendRedirect("login.jsp?msg=Problems with connection or database!");
		}
		catch(java.lang.IllegalStateException e){}		
	}	
}
