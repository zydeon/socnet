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



<%
	while( posts.next() ){ %>
		<div style="background-color:#0000FF;float:left">
			IMAGEM
		</div >

		<div style="float:left">
			FROM <%= posts.getString("from") %> <br>
			READ_DATE <%= posts.getString("read_date") %> <br>
			<p>
				TEXTO TEXTO TEXTO TEXTO TEXTO TEXTO
			</p>
			<br>
			<a href="">Anexo</a>
			<button>Reply</button>
		</div>

<%		
	}

%>