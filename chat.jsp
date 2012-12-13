<%@ page import="dbconnect.Database" %>

<html>
<head>
	<title></title>
	<script type="text/javascript">
		function outputPost(source, text, sentDate, replyLevel, owner, ID, filePath){
			var rl = parseInt(replyLevel);
			var html =  "<div id='"+ID+"' style='position:relative;left:"+(rl*50)+"px'>" +
							"FROM "+source+" <br>"+
							"date:"+ sentDate +"<br>"+
							"<p>"+text+"</p>"+
							"<button onclick=\"newReply('"+ID+"','"+(rl+1)+"')\">Reply</button>";

			if(filePath!="null"){
				html += "<a href=\""+filePath+"\">Anexo</a>"
			}	

			if(owner=="true"){
				//html += "<button onclick=\"editPost('"+ID+"')\"> Edit </button>" +
				html +=	"<form action='deletePost' method='post'>"+
							"<input type='hidden' name='id' value="+ID+"> "+
							"<input type='submit' value='Delete'>"+
						"</form>";
			}
			html += "</div><br>";				
			document.write(html);
		}	
		function newReply(parent, replyLvl){
			div = document.createElement('div');
			div.innerHTML = "<form action='newReply' method='post'>"+
								"<textarea name='text' rows='2' cols='30'>"+
								"</textarea>"+
								"<br>"+
								"<input type='hidden' name='parent' value='"+parent+"'>"+
								"<input type='hidden' name='replyLvl' value='"+replyLvl+"'>"+
								"<input type='submit' value='Submit'>"+
							"</form>";
			document.getElementById(parent).appendChild(div);
		}	
		function newPost(){
			var html = 	"<div>"+
			"<form action='newPost' method='post' enctype='multipart/form-data'>"+
			"<textarea name='text' rows='2' cols='30' placeholder='New post here'>"+
			"</textarea>"+
			"<br>"+
			"<input type='file' name='pic' accept='image/*'>"+
			"<input type='submit' value='Submit'>"+
			"</form>"+
			"</div>";

			document.write(html);
		}			
 </script>
</head>
<body>

	<% String id_chatroom = request.getParameter("id"); %>
	<% if(id_chatroom==null) { %>
		<p><- Select a chatroom </p>
	<%} else {%>
		<% String theme = Database.getChatRoomTheme(id_chatroom); %>
		<% java.sql.ResultSet posts = Database.getPosts( id_chatroom ); %>

		<h1><%=theme%></h1>

		<script type="text/javascript"> newPost(); </script>
		<% while( posts.next() ) { %>
			<% String from      = posts.getString("from"); %>
			<% String text      = posts.getString("text"); %>
			<% String sent_date = posts.getString("sent_date"); %>
			<% Integer rlevel   = posts.getInt("rlevel"); %>
			<% Integer id       = posts.getInt("id_message"); %>
			<% String file_path = posts.getString("file_path"); %>
			<% Boolean owner    = ((String)session.getAttribute("user")).equals(from); %>

			<script type="text/javascript"> outputPost("<%=from%>",
													   "<%=text%>",
													   "<%=sent_date%>",
													   "<%=rlevel%>",
													   "<%=owner%>",
													   "<%=id%>",
													   "<%=file_path%>");
			</script>
		<% } %>
	<% } %>

</body>
</html> 