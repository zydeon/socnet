<%@ page import="dbconnect.Database"%>
<jsp:include page="auth.jsp"></jsp:include>
<%@ page import="java.util.ArrayList"%>

<% 
   ArrayList<String> usernames = Database.getUserNames();
   usernames.remove(session.getAttribute("username"));
   java.sql.ResultSet pms = Database.getInbox((String)session.getAttribute("username"));
   %>

<html>
  <head>	
    <link rel="stylesheet" type="text/css" href="css/style.css"/>
    <title></title>
    <script type="text/javascript">
      function outputPM(from,to,text,date,id,file_path){
	  var html = "<div class=post_div id='"+id+"'>"+
	      "FROM "+from+" - "+
	      "TO "+to+"<br>"+
	      "at "+date +"<br>"+
	      "<p> "+text+"</p><br>";
	      if(file_path!="null"){
		  html += "<a href=\""+filePath+"\">Anexo</a>"
	      }	
	  html+="</div><br><br>";
	  document.write(html);
      }
      
    </script>
  </head>
  <body>
    
    
    <h1>soc.net</h1>
    <div class="main_div">
      <h4>PM's</h4>
      <div id="sendPM" style="float:left;">
	Choose User:
	<form action="newPM" method="post">
	  <select name="dest" style="float:left">
	    <% for(String user : usernames) {%>
	    <option value="<%=user%>"><%=user%></option>
	    <% } %>
	  </select>
	  
	  <textarea name="text" placeholder="Write PM here"></textarea> <br>
	  <input type="submit" value="Send">
	</form>
      </div>

      <div id="showPMs" style="float:left;">
	<!-- remover esta linha (meter num style.css a parte digo eu) -->
	<% while(pms.next()) { %>
	<% String from      = pms.getString("from"); %>
	<% String to        = pms.getString("to"); %>
	<% String text      = pms.getString("text"); %>
	<% String sent_date = pms.getString("sent_date"); %>
	<% Integer id       = pms.getInt("id_message"); %>
	<% String file_path = pms.getString("file_path"); %>
	
	<script type="text/javascript"> outputPm(
	  "<%=from%>",
	  "<%=to%>",
	  "<%=text%>",
	  "<%=sent_date%>",
	  "<%=id%>",
	  "<%=file_path%>");
	</script>	
	<% } %>
      </div>
    </div>
  </body>
</html>
