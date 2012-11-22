<%@ page import="dbconnect.Database"%>

<jsp:include page="auth.jsp"></jsp:include>

<% java.sql.ResultSet chatrooms = Database.getChatrooms(); %> 
<h1>soc.net</h1>

<form action="logout" method="get"> <button>Logout</button>  </form>
<hr>
<form>
	<button formaction="edit_profile.jsp" formmethod="get">To Profile</button>
	<button formaction="" formmethod="get">To PM's</button>
</form>
<button onclick="showInputTheme()">Create chatroom</button>
<form action="">
	<input type="text" id="new_chatroom_theme" placeholder="Theme">
	<input type="submit" >
</form>

<div style="background-color:#000000;float:left;">
  <select id="chatroom_list" size=30 onchange="displayChatroom()">
    <% while(chatrooms.next()){ %>
    <option value="<%= chatrooms.getInt("id_chatroom") %>" >    <%= chatrooms.getString("theme") %>   </option>
    <%}%>
  </select>
</div>

<div style="float:left;">
  <iframe width=1000 height=1000 id="chatroom_frame" src="chat.jsp?id=1" />
  
</iframe>
</div>

<script type="text/javascript">
	function displayChatroom(){
		var chatroom_list = document.getElementById('chatroom_list'); 
		var cr = chatroom_list.options[chatroom_list.selectedIndex].value;
		document.getElementById('chatroom_frame').src = 'chat.jsp?id='+cr;
	}
	function showInputTheme(){
		document.getElementById('city').style.display='inline';
		document.getElementById('city').style.visibility='visible';			
	}
</script>
