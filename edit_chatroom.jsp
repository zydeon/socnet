<%@ page import="dbconnect.Database"%>
<jsp:include page="auth.jsp"></jsp:include>
<% String id = (String) request.getParameter("id"); %>
<% 
   String msg = request.getParameter("msg");
   if(msg!=null)
   out.println( "<span style='color:red'>*"+msg+"</span>" );
%>


<html>
<head>
	<title>soc.net</title>
</head>
<body>


	<% if(id==null) { %>
		Selecionar chatroom
	<% } else { %>
		<% java.sql.ResultSet info = (java.sql.ResultSet) Database.getChatroomInfo(id); %>
		<% java.sql.ResultSet usersPermissions = (java.sql.ResultSet) Database.getUserPermissions(id); %>


		<div>

			<% if(info.next()) { %>

				<form action="editChat" method="post">
					New theme: <input type="text" name="theme" value="<%=info.getString("theme")%>"><br>				
					Closed : <input type="checkbox" name="closed" <%= (info.getBoolean("closed") ? "checked" : "") %>> <br>
					<input type="hidden" name="id_chatroom" value="<%=id%>"> 
					<input type="submit" value="Edit">
				</form>	

			<% } %>	
		</div>


		<div>
			<p>Manage permissions</p>
			<table>
				<tr> <td>Name</td><td>Write</td><td>Read</td> <td>Submit</td></tr>

				<% while(usersPermissions.next()) {%>
					<tr>													
						<form action="restrictUser" method="post">
							<input type="hidden" name="login" value="<%=usersPermissions.getString("user_login")%>">
							<input type="hidden" name="id_chatroom" value="<%=id%>">
							<td> <%=usersPermissions.getString("user_login")%> </td>
							<td> <input type="checkbox" name="write" <%=(usersPermissions.getBoolean("write")?"checked":"")%> > </td>
							<td> <input type="checkbox" name="read" <%=(usersPermissions.getBoolean("read")?"checked":"")%> > </td>
							<td> <input type="submit" value="Submit"> </td>
						</form>
					</tr>
				<% } %>

			</table>
		</div>

	<% } %>
	

</body>
</html>