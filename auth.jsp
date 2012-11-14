<%
if ( session.getAttribute("user")==null )
{
%>
    <jsp:forward page="/login.jsp"></jsp:forward>
<%
} 
%>