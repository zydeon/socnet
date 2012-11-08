<%@ page import="dbconnect.Database"%>
<%@ page import="java.util.ArrayList" %>
<%
ArrayList<String> countries = Database.getCountries();
%>



<h1>soc.net</h1>

<form action="register" method="post" >
<input type="text" name="user" placeholder="Username"> <br>
<input type="password" name="password" placeholder="Password"> <br>
<!-- Confirm password: <input type="password" name="password"> <br> -->
<input type="text" name="name" placeholder="Name"> <br>
<!-- Birthday: <input type="text" name="name"> <br> -->
Birthday:
<select name="year" id="year" size="1">
<script language="JavaScript">
function writeYears(){
	var text="";
	text+="<option value=\" \" selected=\"selected\"> Year</option>";
	for(var i=1950;i<=2012;i++)
	text+="<option value=\""+i+"\">"+i+"</option>";
	document.write(text);
}
writeYears();
</script>
</select>
<select name="month" id="month" size="1">
<option value=" " selected="selected"> Month</option>
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
<script language="JavaScript">
function writeDays(){
	var text="";
	text+="<option value=\" \" selected=\"selected\"> Day</option>";
	for(var i=1;i<=31;i++)
	text+="<option value=\""+i+"\">"+i+"</option>";
	document.write(text);
}
writeDays();
</script>
</select>
<br>
<input type="text" name="email" placeholder="Email"> <br>
<input type="text" name="address" placeholder = "Adress"> <br>


Gender:
M <input type="radio" name="gender" value="male">
F <input type="radio" name="gender" value="female">   <br>
Public: <input type="checkbox" name="public">

<select name="country">
<option selected="selected">Country</option>
<%
	int i;
	for( i = 0; i < countries.size(); ++i ){
		out.println( "<option value='"+countries.get(i)+"'>"+countries.get(i)+"</option>" );
	}
%>
</select>


<br>
<br>
<br>
<input type="submit" name="register" value="Register">

<script type="text/javascript">
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
	dday.options[dday.options.length] = new Option(' ',' ');
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




