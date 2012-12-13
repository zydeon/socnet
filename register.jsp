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

	</div>
</div>
</body>
<script type="text/javascript">

function checkfields(){ 
	if(document.getElementById('user').value=='' || document.getElementById('user').value==null){
		alert("Invalid Username");
		document.getElementById('user').focus();
		return false; 
	}
	
	if(document.getElementById('password').value=='' || document.getElementById('password').value==null){
		alert("Invalid Password");
		document.getElementById('password').focus();
		return false; 
	}
	
	if(document.getElementById('password').value != document.getElementById('cpassword').value) { 
		alert("Your Passwords do not match.");
		document.getElementById('password').focus();
		return false; 
	}obj.option[obj.selectedIndex]
	
}

function daysInMonth(month,year) {
	var dd = new Date(year, month, 0);
	return dd.getDate();
}

function setDayDrop(dyear, dmonth, dday) {
	var year = dyear.options[dyear.selectedIndex].value;
	var month = dmonth.options[dmonth.selectedIndex].value;
	var day = dday.options[dday.selectedIndex].value;
	var days = (year == ' ' || month == ' ') ? 31 : daysInMonth(month,year);
	dday.options.length = 0;
	dday.options[dday.options.length] = new Option('Day',' ');
	for (var i = 1; i <= days; i++)
		dday.options[dday.options.length] = new Option(i,i);
}

function setDay() {
	var year = document.getElementById('year');
	var month = document.getElementById('month');
	var day = document.getElementById('day');
	setDayDrop(year,month,day);
}

function toggleCity(){
	var list_country = document.getElementById('country');

	console.log(list_country);

	if(list_country.options[list_country.selectedIndex].value=='none'){
		document.getElementById('city').style.display='inline';
		document.getElementById('city').style.visibility='hidden';
	}
	else{
		document.getElementById('city').style.display='inline';
		document.getElementById('city').style.visibility='visible';			
	}
}

document.getElementById('year').onchange = setDay;
document.getElementById('month').onchange = setDay;

</script>
