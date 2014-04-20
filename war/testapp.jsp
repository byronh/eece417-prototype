<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreService" %>
<%@ page import="com.google.appengine.api.datastore.Query" %>
<%@ page import="com.google.appengine.api.datastore.Entity" %>
<%@ page import="com.google.appengine.api.datastore.FetchOptions" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no" /> 
    <meta charset="utf-8">       
    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
    <script type="text/javascript" src="/javascripts/main.js"></script>        
    <script type="text/javascript"
     src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBskpEcwdyTf9uTqblPYNjdL-OFiLyXHbw&sensor=true">
    </script>    
    <script type="text/javascript"> 
	  
		function initialize() {
					
			var myLatlng = new google.maps.LatLng(37.33152141760375,-122.04732071026367);   
		   
			var mapOptions = {
			  center: myLatlng,
			  zoom: 12
			};
			
			map = new google.maps.Map(document.getElementById("map-canvas"),
			  mapOptions);		
						
			var gstBkNm = guestbookNameString; //"default";
			
			 
					
			// Load the selected markers			
			loadMarkers();       
		}      
 	
		google.maps.event.addDomListener(window, 'load', initialize);
    </script>
    
  </head>
  <body>
<%
    String guestbookName = request.getParameter("guestbookName");
    if (guestbookName == null) {
        guestbookName = "default";
    }
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();
    if (user != null) {
      pageContext.setAttribute("user", user);
%>
<p>Hello, ${fn:escapeXml(user.nickname)}! (You can
<a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">sign out</a>.)</p>
<%
    } else {
%>
<p>
	<a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in</a>
	to use the system.
</p>
<%
    }
%>
<% if (user != null) {%>
<h4>Click <a href="guestbook.jsp">here</a> to see your reservations.</h4>
<p>Please click on a marker to reserve a spot.</p>


<!-- Original -->
<div id=oldMsgList>
<%
    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
    Key guestbookKey = KeyFactory.createKey("Guestbook", guestbookName);
    
    // Run an ancestor query to ensure we see the most up-to-date
    // view of the Greetings belonging to the selected Guestbook.
    
    Query query = new Query("Greeting", guestbookKey).addSort("date", Query.SortDirection.DESCENDING);
    List<Entity> greetings = datastore.prepare(query).asList(FetchOptions.Builder.withLimit(10));
    
    if (greetings.isEmpty()) {
        %>
        <p>Guestbook '${fn:escapeXml(guestbookName)}' has no messages.</p>
        <%
    } else {
        %>
        <p>Messages in Guestbook '${fn:escapeXml(guestbookName)}'.</p>
        <%
        for (Entity greeting : greetings) {
            pageContext.setAttribute("greeting_content",
                                     greeting.getProperty("content"));
            if (greeting.getProperty("user") == null) {
                %>
                <p>An anonymous person wrote:</p>
                <%
            } else {
                pageContext.setAttribute("greeting_user",
                                         greeting.getProperty("user"));
                %>
                <p><b>${fn:escapeXml(greeting_user.nickname)}</b> wrote:</p>
                <%
            }
            %>
            <blockquote>${fn:escapeXml(greeting_content)}</blockquote>
            <%
        }
    }
%>

    <form action="/sign_in" method="post">
      <div><textarea name="content" rows="3" cols="60"></textarea></div>
      <div><input type="submit" value="Post Greeting" /></div>
      <input type="hidden" name="guestbookName" value="${fn:escapeXml(guestbookName)}"/>
    </form>
    
</div> 
<!-- Original -->
	        
    <div id="map-canvas"></div>
    
	<br/>

	<%} %>
  </body>
</html>