<%@ page import="dbconnect.Database"%>

-> <%= request.getParameter("id") %>

<%
	String id_chatroom = request.getParameter("id");
	java.sql.ResultSet posts = Database.getPosts( request.getParameter("id") ); 
%>

<br>
CONTENT FOR CHATROOM <br>
(<- ainda não dá para seleccionar a chatroom correcta ao lado, mas já mostra posts se os tiverem na BD) <br>
( http://localhost:8080/socnet/chat.jsp?id=X )
<br>
<br>
<br>



<%  while( posts.next() ){ %>
			<div style="position:relative;left:<%= posts.getInt("rlevel")*50 %>px">
				<div style="background-color:#0000FF;float:left;">
					IMAGEM
				</div >
				<div style="">
					FROM <%= posts.getString("from") %> <br>
					<%= posts.getString("read_date") %> <br>
					<p> <%= posts.getString("text") %>	</p>
					<a href="">Anexo</a>
					<button>Reply</button>
					<% if(posts.getString("from").equals(session.getAttribute("user")) ) { %>
						<button> Edit </button>
						<button> Delete </button>
					<% } %>
				</div>		
			</div>	
			<br>

<%		
	}

%>