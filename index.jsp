<%@ page import="dbconnect.Database"%>
<%! String chatrooms[] = Database.getChatrooms(); %> 

<jsp:include page="auth.jsp"></jsp:include>

<h1>soc.net</h1>

<div style="background-color:#000000;float:left;">
	<select id="chatroom_list" size=30 onchange="displayChatroom()">
		<% int i;
		   for( i = 0; i < chatrooms.length; ++i ){ %>
			<option value="no <%=i%>" > <%=chatrooms[i]%> </option>
		<%}%>
	</select>
</div>

<div style="float:left;">
	<iframe id="chatroom_frame" src="chat.jsp?id=1">

	</iframe>
</div>

<script type="text/javascript">
	function displayChatroom(){
		var chatroom_list = document.getElementById('chatroom_list');
		var cr = chatroom_list.options[chatroom_list.selectedIndex].value;
		document.getElementById('chatroom_frame').src = 'chat.jsp?id='+cr;
	}
</script>