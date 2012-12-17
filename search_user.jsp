<jsp:include page="auth.jsp"></jsp:include>
<% java.sql.ResultSet searchedUsers = (java.sql.ResultSet) request.getAttribute("searched_users"); %>

<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
	<link rel="stylesheet" type="text/css" href="css/style.css"/>	
	<title>soc.net</title>
</head>
<body>

	<form action="searchUser" method="post">
		User login: <input type="text" name="user_login"> <br>
		Name: <input type="text" name="name"> <br>
		City: <input type="text" name="city_name"> <br>
		Country: <input type="text" name="country_name"> <br>
		Address: <input type="text" name="address"> <br>
		Age: <input type="text" name="age"> <br>
		Email: <input type="text" name="email"> <br>
		Gender: 
		M <input type="radio" name="gender" value="male">
		F <input type="radio" name="gender" value="female">

		<br>
		<input type="submit" value="Search">
	</form>

	<% if(searchedUsers!=null) { %>
		<% while(searchedUsers.next()) {%>
			<p><%= searchedUsers.getString("login") %></p>
		<% } %>
	<% } %>

</body>
</html>