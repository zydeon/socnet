<%
	String msg = request.getParameter("msg");
	if(msg!=null)
		out.println( "<span style='color:red'>*"+msg+"</span>" );
%>

<form action="login" method="post" >
	User: <input type="text" name="user"> <br>
	Password: <input type="password" name="password"> <br>

	<input type="submit" name="enter" value="Login">

	<br>
	<br>
	<br>

	<a href="register.jsp">Sign Up !</a>

</form>