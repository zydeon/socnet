<%@ page import="dbconnect.Database"%>
<jsp:include page="auth.jsp"></jsp:include>
<% 
String user = (String)session.getAttribute("user");
java.sql.ResultSet userInfo = Database.getUserInfo(user);

java.sql.ResultSet countries = Database.getCountries();
String months[] = new String[] { "January","February","March","April","May","June","July","August","September","October","November","December" };
%>

<% 
String msg = request.getParameter("msg");
if(msg!=null)
	out.println( "<span style='color:red'>*"+msg+"</span>" );
%>

<html>
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
			<h4>Edit Profile:</h4><h4><%= user %></h4>
			<% if (userInfo.next()){ %>
			
			<% if( userInfo.getBoolean("disabled") ) { %>
				<a href="enable"><button>Enable Account</button></a>
				<% } else { %>
				<a href="disable"><button>Disable Account</button></a>
				<% } %>

				<a href="deleteInfo"><button>Delete All User Information</button></a>
				<br><br>
				<form action="edit" method="post" >	
Name:<br> <input type="text" name="user" id="user" placeholder="name" value="<%= ((userInfo.getString("name"))==null ? "" : userInfo.getString("name"))%>"><br>
Email:<br> <input type="text" name="email" placeholder="Email" value="<%= ((userInfo.getString("email"))==null ? "" : userInfo.getString("email"))%>"> <br>
Address:<br> <input type="text" name="address" placeholder = "Address" value="<%= ((userInfo.getString("address"))==null ? "" : userInfo.getString("address"))%>"> <br>
					Country :<br>
					<select name="country" id="country" onchange="toggleCity()" value="UK">
						<option value="none">Country</option>
						<%
						while(countries.next()){
							out.println("<option "+(countries.getString("id_country").equals(userInfo.getString("id_country"))?"selected ":"")
							+"value='"+countries.getString("id_country")+"'>"+countries.getString("name")+"</option>" );
						}
						String hidden = "";
						if (userInfo.getString("id_country")==null)
							hidden="visibility:hidden";
						%>
					</select>

					<input type="text" name="city" placeholder = "City" id="city" style="<%= hidden %>" value="<%= userInfo.getString("city_name") %>"> <br><br>
					<% 
						Integer year = 0;
						Integer month = 0;
						Integer day = 0;
						String male = userInfo.getString("gender_male");
						if (male==null)
						male="nao especificado";

						Boolean publicP = userInfo.getBoolean("public");
						if (userInfo.getString("birthdate")!=null){
							String birthdate = userInfo.getString("birthdate");
							year = Integer.parseInt(birthdate.substring(0,4)); 
							month = Integer.parseInt(birthdate.substring(5,7));
							day = Integer.parseInt(birthdate.substring(8,10));
						}
					%>

					Birthday:<br>
					<!-- YEAR -->
					<select name="year" id="year" size="1">
						<option value="1">Year</option>
						<%
							int y;
							for(y=1950;y<=2012;y++)
								out.println("<option "+(year==y?"selected":"")+" value='"+y+"'>"+y+"</option>");
						%>
					</select>
					<!-- MONTH -->
					<select name="month" id="month" size="1">
						<option value="none"> Month</option>
						<%
							int m;
							for( m = 0; m < 12; ++m )
								out.println("<option "+((month-1)==m?"selected":"")+" value='"+(m+1)+"''>"+months[m]+"</option>");
						%>
					</select>
					<!-- DAY -->
					<select name="day" id="day" size="1">
						<%
							int d;
							out.println("<option value='none'> Day</option>");
							for(d=1;d<=31;d++)
								out.println("<option "+(day==d?"selected":"")+" value='"+d+"'>"+d+"</option>");
						%>
					</select>
					<br>
					<br>
					Gender: 
					M <input type="radio" name="gender" value="male" <%= (male.equals("t") ? "checked" : "") %> >
					F <input type="radio" name="gender" value="female" <%= (male.equals("f") ? "checked" : "") %>><br><br>

					Public: <input type="checkbox" name="public" <%= (publicP ? "checked" : "") %>>
					<br><br>
					New Password: <br><input type="password" name="password" id="password" placeholder="Password"> <br>
					Confirmation: <br><input type="password" name="cpassword" id="cpassword" placeholder="Confirm Password"> <br>


					<br>
					<input type="submit" name="enter" value="Save">


					<script type="text/javascript">
						document.getElementById('year').onchange = setDay;
						document.getElementById('month').onchange = setDay;		
					</script>
				<%}%>


</form>
</div>
</body>
</html>
