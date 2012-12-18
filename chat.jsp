<%@ page import="dbconnect.Database" %>
<%
String msg = request.getParameter("msg");
if(msg!=null)
	out.println( "<span style='color:red'>*"+msg+"</span>" );
%>

<html>
<head>
    <script type="text/javascript">
    function outputPost(source, text, sentDate, replyLevel, owner, ID, filePath, id_chatroom){
	var rl = parseInt(replyLevel);
	var html =  "<div class=post_div id='"+ID+"' style='position:relative;left:"+(rl*50)+"'>" +
	    "FROM "+source+" <br>"+
	    "date:"+ sentDate +"<br>"+
	    "<p>"+text+"</p>"+
	    "<button onclick=\"newReply('"+ID+"','"+(rl+1)+"','"+id_chatroom+"')\">Reply</button>";

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
	html += "</div><br><br>";				
	document.write(html);
    }	
		function newReply(parent, replyLvl, id_chatroom){
			div = document.createElement('div');
			div.innerHTML = "<form action='newReply' method='post'>"+
			"<textarea name='text' rows='2' cols='30'>"+
			"</textarea>"+
			"<br>"+
			"<input type='hidden' name='id_chatroom' value='"+id_chatroom+"'>"+
			"<input type='hidden' name='parent' value='"+parent+"'>"+
			"<input type='hidden' name='replyLvl' value='"+replyLvl+"'>"+
			"<input type='submit' value='Submit'>"+
			"</form>";
			document.getElementById(parent).appendChild(div);
		}	
		function newPost(id_chatroom){
			var html = 	"<div>"+
			"<form action='newPost' method='post' enctype='multipart/form-data'>"+
			"<textarea name='text' rows='2' cols='30' placeholder='New post here'>"+
			"</textarea>"+
			"<br>"+
			"<input type='hidden' name='id_chatroom' value='"+id_chatroom+"'>"+
			"<input type='file' name='attach'>"+
			"<input type='submit' value='Submit'>"+
	  "</form>"+
			"</div>";

			document.write(html);
		}			
		</script>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<link rel="stylesheet" type="text/css" href="css/style.css"/>
		<title>soc.net</title>
	</head>
	<body style='text-align:left;'>
		<% String theme = (String) request.getAttribute("theme"); %>
		<% java.sql.ResultSet posts = (java.sql.ResultSet) request.getAttribute("posts"); %>
		<% String id_chatroom = (String) request.getAttribute("id_chatroom"); %>
		
		<h4><%=theme%></h4>
		<a href="rate?r=Y&id=<%=id_chatroom%>"><button>Y</button></a>
		<a href="rate?r=M&id=<%=id_chatroom%>"><button>M</button></a>
		<a href="rate?r=N&id=<%=id_chatroom%>"><button>N</button></a>
		<hr><br>
		<script type="text/javascript"> newPost("<%=id_chatroom%>"); </script>	

		<% if(posts!=null) { %>
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
					"<%=file_path%>",
					"<%=id_chatroom%>");
				</script>
				<% } %>			
		<% } %>			

	</body>
	</html> 
