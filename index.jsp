<%@ page import="dbconnect.Database"%>
<%! java.sql.ResultSet chatrooms = Database.getChatrooms(); %> 

<jsp:include page="auth.jsp"></jsp:include>

<h1>soc.net</h1>

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
</script>
