<%@ page import="dbconnect.Database"%>
<jsp:include page="auth.jsp"></jsp:include>
<%@ page import="java.util.ArrayList"%>

<% 
   ArrayList<String> usernames = Database.getUserNames();
   usernames.remove(session.getAttribute("username"));
   java.sql.ResultSet pms = (java.sql.ResultSet)request.getAttribute("pms");
   %>
<html>
  <head>	
    <link rel="stylesheet" type="text/css" href="css/style.css"/>
    <title></title>
    <script type="text/javascript">
      function outputPM(from,to,text,date,id,file_path){
      var html = "<div class=post_div id='"+id+"'>"+
	    "FROM "+from+" "+
	    "TO "+to+"<br>"+
	    "at "+date +"<br>"+
	    "<p> "+text+"</p><br>";
	if(file_path!="null"){
	    html += "<a href='"+file_path+"'>Anexo</a>"
	}	
	html+="</div><br><br>";
	document.write(html);
    }    
    function hist_func(){
    window.location=("/socnet/pm?list=history&other="+document.getElementById("hist_link").value);
    }
    </script>
  </head>
  <body>
        
    <h1>soc.net</h1>
    <div class="main_div">
      <h4>PM's</h4>
	<hr><br>
      <div>
	<a href="pm?list=inbox"><button>Inbox</button></a>
	<a href="pm?list=outbox"><button>Outbox</button></a>
	<button onclick="hist_func()">History</button>
	<input type="text" id="hist_link">
      </div>
      <hr><br>
      <div id="sendPM" class="reg_div" style="float:left;">
	Choose User:
	<form action="newPM" method="post" enctype="multipart/form-data">
	  <select name="to" style="float:left">
	    <% for(String user : usernames) {%>
	    <option value="<%=user%>"><%=user%></option>
	    <% } %>
	  </select>
	  <br><br>
	  <textarea name="text" placeholder="Write PM here"></textarea> <br>
	  <input type="file" name="attach"><br>
	  Send At:<br>
	  <input type="text" name="time">
	  <input type="submit" value="Send">
	</form>
      </div>
      <div id="showPMs" style="float:left;">
	<% while(pms.next()) { %>
	<% String from      = pms.getString("from"); %>
	<% String to        = pms.getString("to"); %>
	<% String text      = pms.getString("text"); %>
	<% String sent_date = pms.getString("sent_date"); %>
	<% Integer id       = pms.getInt("id_message_"); %>
	<% String file_path = pms.getString("file_path"); %>
	<script type="text/javascript"> outputPM("<%=from%>","<%=to%>","<%=text%>", "<%=sent_date%>","<%=id%>","<%=file_path%>");
	</script>	
	<% } %>
      </div>
    </div>
  </body>
</html>
