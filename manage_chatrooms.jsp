<%@ page import="dbconnect.Database"%>
<jsp:include page="auth.jsp"></jsp:include>
<% String user_login = (String) session.getAttribute("user"); %>
<% java.sql.ResultSet chatrooms = Database.getUserChatrooms(user_login); %>

<html>
<head>
	<title>soc.net</title>
	<script type="text/javascript">
		function editChatroom(){
			var chatroom_list = document.getElementById('chatroom_list'); 
			var cr = chatroom_list.options[chatroom_list.selectedIndex].value;
			document.getElementById('chatroom_frame').src = 'edit_chatroom.jsp?id='+cr;
		}
	</script>	
</head>
<body>

	<div class="main_div">
		<div class="title_div">
			<h1>Edit chatrooms</h1>
		</div>

		<div style="background-color:#000000;float:left;">
			<select id="chatroom_list" size=30 onchange="editChatroom()">
				<% while(chatrooms.next()){ %>
				<option value="<%= chatrooms.getInt("id_chatroom") %>" >    <%= chatrooms.getString("theme") %>   </option>
				<%}%>
			</select>
		</div>
		<div style="float:left;">
			<iframe width=500 height=600 id="chatroom_frame" src="edit_chatroom.jsp"></iframe>
		</div>

	</div>


</body>
</html>