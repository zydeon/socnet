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


		try{
			Connection con = Database.getConnection();

			if( con != null ){
				Statement st = con.createStatement();
				ResultSet rs;

				sql = "SELECT salt FROM \"User\" WHERE login='"+user+"';";
				rs = st.executeQuery(sql);
				if(rs.next()){
					String salt = rs.getString("salt");
					String hash = Database.generateHash(pass, salt);

					sql = "SELECT login FROM \"User\" WHERE login='"+user+"' AND pass='"+hash+"'";
					rs = st.executeQuery(sql);
					if( rs.next() )
						out.println("Login successful !");
					else
						out.println("Wrong username or password!");
				}	
				else
					out.println("Wrong username or password!");

				Database.putConnection(con);
			}
			else
				System.out.println("Error connecting to database");			
		}
		catch(SQLException e){
			System.out.println(e);
		}
		catch(java.security.NoSuchAlgorithmException e){
			System.out.println(e);
		}
	}	
}
