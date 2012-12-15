<%@ page import="dbconnect.Database"%>

<%
java.sql.ResultSet countries = Database.getCountries();
String months[] = new String[] { "January","February","March","April","May","June","July","August","September","October","November","December" } ;
%>
<%
String msg = request.getParameter("msg");
if(msg!=null)
	out.println( "<span style='color:red'>*"+msg+"</span>" );
%>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
	<link rel="stylesheet" type="text/css" href="css/style.css"/>
	<script type="text/javascript" src="user_data.js"></script>
	<title>soc.net</title>  
</head>

<body>
	<br>
	<div class="main_div">
		<h1>soc.net</h1>
		<div class="reg_div">
			<h4>Registration</h4>
			<form action="register" method="post"  onsubmit="return checkfields();">
				Username:<br>
				<input type="text" name="user" id="user"> <br>
				Password:<br>
				<input type="password" name="password" id="password"> <br>
				Confirm Password:<br>
				<input type="password" name="cpassword" id="cpassword">
				<br><br><br>
				Name:<br>
				<input type="text" name="name"> <br>
				E-mail:<br>
				<input type="text" name="email"> <br>
				Adress:<br>
				<input type="text" name="address"> <br>

				<br>
				Country:<br>
				<select name="country" id="country" onchange="toggleCity()">
					<option selected value='none'>Country</option>
					<% while(countries.next()){ %>
					<option value="<%=countries.getString("id_country")%>"> <%=countries.getString("name")%> </option>
					<%}%>
				</select><br>
				<input type="text" name="city" id="city" style="visibility:hidden">
				<br>
				<br>
				Birthday: <br>
				<!-- YEAR -->
				<select name="year" id="year" size="1">
					<option value="1" selected="selected">Year</option>
					<%
					int y;
					for(y=1950;y<=2012;y++)
						out.println("<option value='"+y+"'>"+y+"</option>");
					%>
				</select>
				<!-- MONTH -->
				<select name="month" id="month" size="1">
					<option value="none" selected="selected"> Month</option>
					<%
					int m;
					for( m = 0; m < 12; ++m )
						out.println("<option value='"+(m+1)+"''>"+months[m]+"</option>");
					%>
				</select>
				<!-- DAY -->
				<select name="day" id="day" size="1">
					<%
					int d;
					out.println("<option value='none' selected='selected'> Day</option>");
					for(d=1;d<=31;d++)
						out.println("<option value='"+d+"'>"+d+"</option>");
					%>

				</select>
				<br><br>
				Gender: 
				M <input type="radio" name="gender" value="male">
				F <input type="radio" name="gender" value="female">   <br>
				<br>

				Public: <input type="checkbox" name="public">
				<br>
				<br>
				<br>
				<input type="submit" name="register" value="Register">
			</form>

			<script type="text/javascript">
			document.getElementById('year').onchange = setDay;
			document.getElementById('month').onchange = setDay;		
			</script>

		</div>
	</div>
</body>