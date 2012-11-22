<%@ page import="dbconnect.Database"%>

<jsp:include page="auth.jsp"></jsp:include>

<% 
	String user = (String)session.getAttribute("user");
	java.sql.ResultSet userInfo = Database.getUserInfo(user);

	java.sql.ResultSet countries = Database.getCountries();
	String months[] = new String[] { "January","February","March","April","May","June","July","August","September","October","November","December" };

%>

<form action="edit" method="post" >
	User: <b> <%= user %> <b><p>
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
		%>
		</select>

		<input type="text" name="city" placeholder = "City" id="city" style="<%= (userInfo.getString("id_country").equals("") ? "visibility:hidden" : "") %>" value="<%= Database.getCity(userInfo.getString("id_city"))%>"> <br><br>
		<% 
		Integer year = 0;
		Integer month = 0;
		Integer day = 0;
		Boolean male = userInfo.getBoolean("gender_male");
		Boolean publicP = userInfo.getBoolean("public");
		if (!userInfo.getString("birthdate").equals("")){
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
		M <input type="radio" name="gender" value="male" <%= (male==true ? "checked" : "") %> >
		F <input type="radio" name="gender" value="female" <%= (male==false ? "checked" : "") %>><br><br>

		Public: <input type="checkbox" name="public" <%= (publicP ? "checked" : "") %>>
		<br><br>
	<% } %>
	<input type="submit" name="enter" value="Save">

	<br>
	<br>
	<br>

</form>

<script type="text/javascript">

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

</script>