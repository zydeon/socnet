<br>
<h3>NEW MESSAGE</h3>
<br>
<%
	String msg = request.getParameter("msg");
	if(msg!=null)
		out.println( "<span style='color:red'>*"+msg+"</span>" );
%>

<form action="pm" method="post">
  To:
  <input type="text" name="to">
  <br>
  <textarea name="text" rows="10" columns="100" style="resize:none;">
    
  </textarea>
  <br>
  <input type="submit" value="PM">;
</form>
