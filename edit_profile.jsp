<%@ page import="dbconnect.Database"%>

<jsp:include page="auth.jsp"></jsp:include>

<% 
	String user = (String)session.getAttribute("user");
	java.sql.ResultSet userInfo = Database.getUserInfo(user);

	java.sql.ResultSet countries = Database.getCountries();
	String months[] = new String[] { "January","February","March","April","May","June","July","August","September","October","November","December" };

%>


	User: <b> <%= user %> <b>  <form action="disable" method="post" >
		<input type="submit" name="Enter" value="Disable Account">
		<p>
	</form>
	<form action="deleteInfo" method="post" >
		<input type="submit" name="Enter" value="Delete All User Information">
		<p>
	</form>
	<form action="edit" method="post" >
	<!-- Password: <input type="password" name="password"> <br> -->
	<% if (userInfo.next()){ %>
		Name: <input type="text" name="user" id="user" placeholder="name" value="<%= userInfo.getString("name")%>"><br><br>
		Email: <input type="text" name="email" placeholder="Email" value="<%= userInfo.getString("email")%>"> <br><br>
		Address: <input type="text" name="address" placeholder = "Address" value="<%= userInfo.getString("address")%>"> <br><br>
		Country : <select name="country" id="country" onchange="toggleCity()" value="UK">
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

		<input type="text" name="city" placeholder = "City" id="city" style="<%= hidden %>" value="<%= Database.getCity(userInfo.getString("id_city"))%>"> <br><br>
		<% 
		Integer year = 0;
		Integer month = 0;
		Integer day = 0;
		String male = userInfo.getString("gender_male");
		if (male==null)
			male="nao especificado";
		System.out.println(male);

		Boolean publicP = userInfo.getBoolean("public");
		if (userInfo.getString("birthdate")!=null){
			String birthdate = userInfo.getString("birthdate");
			year = Integer.parseInt(birthdate.substring(0,4)); 
			month = Integer.parseInt(birthdate.substring(5,7));
			day = Integer.parseInt(birthdate.substring(8,10));

		}
		%>

		Birthday:
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
		New Password: <input type="password" name="password" id="password" placeholder="Password"> <br>
		Confirmation: <input type="password" name="cpassword" id="cpassword" placeholder="Confirm Password"> <br>

	<% } %>
	<input type="submit" name="enter" value="Save">

	<br>
	<br>
	<br>

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

    if( list_country.options[list_country.selectedIndex].value == 'none' ){
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