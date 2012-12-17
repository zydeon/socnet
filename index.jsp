<%@ page import="dbconnect.Database"%>
<jsp:include page="auth.jsp"></jsp:include>
<% java.sql.ResultSet chatrooms = (java.sql.ResultSet) request.getAttribute("searchedChats"); %>
<% if(chatrooms==null) { %>
<% 		chatrooms = Database.getChatrooms(); %> 
<% } %>
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
	<script type="text/javascript">
	function displayChatroom(){
		var chatroom_list = document.getElementById('chatroom_list'); 
		var cr = chatroom_list.options[chatroom_list.selectedIndex].value;
		document.getElementById('chatroom_frame').src = 'chat?id='+cr;
	}
	function showInputTheme(){
		document.getElementById('new_chatroom_theme').style.display='inline';
		document.getElementById('new_chatroom_theme').style.visibility='visible';     
		document.getElementById('new_chatroom_submit').style.display='inline';
		document.getElementById('new_chatroom_submit').style.visibility='visible';
	}
	</script>    
</head>

<body>
	<div class="main_div">
		<div class="title_div">
			<h1>soc.net</h1>
		</div>
		<hr>
		<a href="edit_profile.jsp"><button>Edit Profile</button></a>
		<a href="pm?list=inbox"><button>To PM's</button></a>
		<a href="logout"><button>Logout</button></a>
		<a href="manage_chatrooms.jsp"><button>Manage chatrooms</button></a>
		<a href="search_user.jsp"><button>Search user</button></a>

		<button onclick="showInputTheme()">Create chatroom</button>
		<form action="new_chatroom" method="post">
			<input type="text" name="new_chatroom_theme" id="new_chatroom_theme" placeholder="Theme" style="visibility:hidden">
			<input type="submit" id="new_chatroom_submit" value="Add" style="visibility:hidden">
		</form>

		<div style="background-color:#000000;float:left;">
			<select id="chatroom_list" size=30 onchange="displayChatroom()">
				<% while(chatrooms.next()){ %>
				<option value="<%= chatrooms.getInt("id_chatroom") %>" >    <%= chatrooms.getString("theme") %>   </option>
				<%}%>
			</select>
		</div>
		<div style="float:left;">
			<iframe width=500 height=1000 id="chatroom_frame" src="chat"></iframe>
		</div>

		<!-- SEARCH CHATS -->
		<div>
			<form action="searchChats" method="post">
				Theme: <input type="text" name="theme"> <br>
				Creator: <input type="text" name="creator"> <br>
				<input type="submit" value="Search">
			</form>
		</div>

	</div>
</body>
</html>
