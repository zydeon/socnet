<%@ page import="dbconnect.Database"%>
<%@ page import="java.util.ArrayList" %>
<%
ArrayList<String> countries = Database.getCountries();
%>



<h1>soc.net</h1>

<form action="register" method="post"  onsubmit="return checkfields();">
<input type="text" name="user" id="user" placeholder="Username"> <br>
<input type="password" name="password" id="password" placeholder="Password"> <br>
<input type="password" name="cpassword" id="cpassword" placeholder="Confirm Password"> <br><br>
<input type="text" name="name" placeholder="Name"> <br>
<input type="text" name="email" placeholder="Email"> <br>
<input type="text" name="address" placeholder = "Adress"> <br>
<input type="text" name="city" placeholder = "City" id="city"> 

<select name="country" id="country">
<option selected="selected" value="">Country</option>
<%
	int i;
	for( i = 0; i < countries.size(); ++i ){
		out.println( "<option value='"+countries.get(i)+"'>"+countries.get(i)+"</option>" );
	}
			out.println("<br>");
%> 

</select>

<br>
<br>
Birthday: 
<select name="year" id="year" size="1">
<%
   int y;
   out.println("<option value='none' selected='selected'> Year</option>");
   for(y=1950;y<=2012;y++)
	       out.println("<option value='"+y+"'>"+y+"</option>");
%>
</select>
<select name="month" id="month" size="1">
<option value="none" selected="selected"> Month</option>
<option value="1">January</option>
<option value="2">February</option>
<option value="3">March</option>
<option value="4">April</option>
<option value="5">May</option>
<option value="6">June</option>
<option value="7">July</option>
<option value="8">August</option>
<option value="9">September</option>
<option value="10">October</option>
<option value="11">November</option>
<option value="12">December</option>
</select>

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

document.getElementById('year').onchange = setDay;
document.getElementById('month').onchange = setDay;

</script>
</form>




