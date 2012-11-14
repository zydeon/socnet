
// import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
// import java.util.Date;
import dbconnect.Database;

public class DatabaseInitializer extends HttpServlet {

	public void init() throws ServletException{
		Database.init();
	}

	public void destroy(){
		Database.destroy();
	}

}
