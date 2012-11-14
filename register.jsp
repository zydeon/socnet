<%@ page import="dbconnect.Database"%>
<%@ page import="java.util.ArrayList" %>
<%
	String countries[] = Database.getCountries();
	String months[] = new String[] { "January","February","March","April","May","June","July","August","September","October","November","December" } ;
%>



<h1>soc.net</h1>
<h2>Registration</h2>

<%
	String msg = request.getParameter("msg");
	if(msg!=null)
		out.println( "<span style='color:red'>*"+msg+"</span>" );
%>

<form action="register" method="post"  onsubmit="return checkfields();">
	<input type="text" name="user" id="user" placeholder="Username"> <br>
	<input type="password" name="password" id="password" placeholder="Password"> <br>
	<input type="password" name="cpassword" id="cpassword" placeholder="Confirm Password">
	<br><br>
	<input type="text" name="name" placeholder="Name"> <br>
	<input type="text" name="email" placeholder="Email"> <br>
	<input type="text" name="address" placeholder = "Adress"> <br>

	<select name="country" onchange="hiddenCity()">
		<option selected value="none">Country</option>
		<%
			int i;
			for( i = 0; i < countries.length; ++i )
				out.println( "<option value='"+countries[i]+"'>"+countries[i]+"</option>" );
		%> 
	</select>

	<input type="text" name="city" placeholder = "City" id="city" style="visibility:hidden"> 	

	<br>
	<br>
	Birthday: 
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
		}

		if((document.getElementById('city').value != ''  && document.getElementById('city').value != null) && 
			(document.getElementById('country').value=='' || document.getElementById('country').value == null)){
		alert("You may not choose a city without choosing a country");
		document.getElementById('country').focus();
		return false;
		}
		
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

	function hiddenCity(){
		document.getElementById('city').style.display='inline';
		document.getElementById('city').style.visibility='visible';
	}

	document.getElementById('year').onchange = setDay;
	document.getElementById('month').onchange = setDay;

</script>





