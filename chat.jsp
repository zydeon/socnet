<%@ page import="dbconnect.Database"%>
<%
   String id_chatroom = request.getParameter("id");
   if(id_chatroom==null){
   %>
<- PLEASE SELECT A CHATROOM 
   <%
      }
      else{
      String theme = Database.getChatRoomTheme(id_chatroom);
      java.sql.ResultSet posts = Database.getPosts( id_chatroom );
      %>
   <h1><%= theme %></h1>
   <hr>
   <br>
   <br>

   <% while(posts.next()){ %>
   <div style="position:relative;left:<%= posts.getInt("rlevel")*50 %>px;">
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
      }
      %>
