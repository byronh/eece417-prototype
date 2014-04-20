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
    <link type="text/css" rel="stylesheet" href="/stylesheets/bootstrap.min.css"/>
    <script type="text/javascript" src="/javascripts/main.js"></script>        
    <script type="text/javascript"
     src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBskpEcwdyTf9uTqblPYNjdL-OFiLyXHbw&sensor=true">
    </script>    
    <script type="text/javascript"> 
	  
		function initialize() {
					
			var myLatlng = new google.maps.LatLng(49.266446,-123.245577);   
		   
			var mapOptions = {
			  center: myLatlng,
			  zoom: 12
			};
			
			map = new google.maps.Map(document.getElementById("map-canvas"),
			  mapOptions);		
						
			
	
			// Load the selected markers			
			loadMarkers();       
		}      
 	
		google.maps.event.addDomListener(window, 'load', initialize);
    </script>
    
  </head>
  <body class="container">
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
	<div class="row">
		<div class="col-md-12">
			<p>Hello, ${fn:escapeXml(user.nickname)}! (You can
				<a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">sign out</a>.)</p>
		</div>
	</div>
	
	<%
	    } else {
	%>
	<div class="row">
		<div class="col-md-12">
			<p class="text-warning">
				<a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in</a>
				to use the system.
			</p>
		</div>
	</div>
			
	<%
	    }
	%>
	<% if (user != null) {%>
	<div class="row">
		<div class="col-md-12"> 
			<h4>Click <a href="guestbook.jsp">here</a> to see your reservations.</h4>
		</div>
	</div>
	<div class="row">
		<div class="col-md-12">
			<p>Please click on a marker to reserve a spot.</p>
		</div>
	</div>
	<div class="row invisible">
		<div class="col-md-12">
			<form>
				<input type="hidden" name="userLatitude" id="userLatitude" />
			   	<input type="hidden" name="userLongitude" id="userLongitude" />
			</form>
		</div>
	</div>
	
	<div id="map-canvas"></div>
				
	
		        
	    
	    	
		<%} %>
  </body>
</html>