import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.Date;
import dbconnect.Database;

public class SearchChatsSv extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String theme = request.getParameter("theme");
		String creator = request.getParameter("creator");

		ResultSet searchedChats = Database.searchChatrooms(creator, theme);
		request.setAttribute("searchedChats", searchedChats);

		RequestDispatcher dispatcher = request.getRequestDispatcher("index.jsp");
		dispatcher.forward(request, response);
	}
}
