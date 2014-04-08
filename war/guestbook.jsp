<!DOCTYPE html>
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

<html>
	<head>
	<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
	<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
	<style type="text/css">
		html { height: 100% }
		body { height: 100%; margin: 0; padding: 0 }
		#map-canvas { height: 400px; width: 500px }
	</style>
	<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBskpEcwdyTf9uTqblPYNjdL-OFiLyXHbw&sensor=true">
	</script>
	<script type="text/javascript">
	var map;
	var markers = [];

	function initialize() {
	  var mapOptions = {
	    zoom: 15
	  };
	  map = new google.maps.Map(document.getElementById('map-canvas'),
	      mapOptions);
	  addMarkers(map);
	  // Try HTML5 geolocation
	  if(navigator.geolocation) {
	    navigator.geolocation.getCurrentPosition(function(position) {
	      var pos = new google.maps.LatLng(position.coords.latitude,
	                                       position.coords.longitude);
		  document.getElementById("userLatitude").value = position.coords.latitude;
		  document.getElementById("userLongitude").value = position.coords.longitude;
		  document.getElementById("measureAccuracy").value = position.coords.accuracy;
	      var infowindow = new google.maps.InfoWindow({
	        map: map,
	        position: pos,
	        content: 'You are here.'
	      });

	      map.setCenter(pos);
	    }, function() {
	      handleNoGeolocation(true);
	    });
	  } else {
	    // Browser doesn't support Geolocation
	    handleNoGeolocation(false);
	  }
	}

	function handleNoGeolocation(errorFlag) {
	  if (errorFlag) {
	    var content = 'Error: The Geolocation service failed.';
	  } else {
	    var content = 'Error: Your browser doesn\'t support geolocation.';
	  }

	  var options = {
	    map: map,
	    position: new google.maps.LatLng(60, 105),
	    content: content
	  };

	  var infowindow = new google.maps.InfoWindow(options);
	  map.setCenter(options.position);
	}
	google.maps.event.addDomListener(window, 'load', initialize);
	
	function addMarkers(map){
		for(i = 0; i< markers.length; i++){
			markers[i].setMap(map);
		}	
	}
	</script>
	   	
 	</head>

  <body>

<%
    String guestbookName = request.getParameter("guestbookName");
    if (guestbookName == null) {
        guestbookName = "default";
    }
    pageContext.setAttribute("guestbookName", guestbookName);
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
<p>Hello!
<a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in</a>
to include your name with greetings you post.</p>
<%
    }
%>

    <form action="/sign" method="post">
   		<fieldset>
   		<legend>Send us a message:</legend>
	      <div><textarea name="content" rows="3" cols="60"></textarea></div>
	      <div><input type="submit" value="Post Greeting" /></div>
	      <div><input type="hidden" name="userLatitude" id="userLatitude" /></div>
	      <div><input type="hidden" name="userLongitude" id="userLongitude" /></div>
	      <div><input type="hidden" name="measureAccuracy" id="measureAccuracy" /></div>
	      <input type="hidden" name="guestbookName" value="${fn:escapeXml(guestbookName)}"/>
      	</fieldset>
    </form>
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
            pageContext.setAttribute("greeting_content", greeting.getProperty("content"));
            pageContext.setAttribute("user_latitude", greeting.getProperty("userLatitude"));
            pageContext.setAttribute("user_longitude", greeting.getProperty("userLongitude"));
            pageContext.setAttribute("measure_accuracy", greeting.getProperty("measureAccuracy"));
            pageContext.setAttribute("greeting_user", greeting.getProperty("user"));
            if (greeting.getProperty("user") == null) {
                %>
                <p>An anonymous person wrote:</p>
                <%
            } else {
                %>
                <p><b>${fn:escapeXml(greeting_user.nickname)}</b> wrote:</p>
                <%
            }
            %>
            <blockquote>${fn:escapeXml(greeting_content)}</blockquote>
            
            <% if (greeting.getProperty("userLatitude") != null && 
            		greeting.getProperty("userLongitude") != null){ %>
            	<p> Message sent at latitude: ${fn:escapeXml(user_latitude)}, 
	            Latitude: ${fn:escapeXml(user_longitude)}.
	            Measure accuracy: ${fn:escapeXml(measure_accuracy)} meters.	
	            </p>
            	<script>
		            markers.push(new google.maps.Marker({
		                position: new google.maps.LatLng(${fn:escapeXml(user_latitude)},${fn:escapeXml(user_longitude)}),
		                title: '${fn:escapeXml(greeting_user.nickname)}'
		            }));
            	</script>
            <% } %>
            <%
        }
    }
%>

	<div id="map-canvas"></div>
  </body>
</html>