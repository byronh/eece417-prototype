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
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.Date" %>
<html>
	<head>
	<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
	<link type="text/css" rel="stylesheet" href="/stylesheets/bootstrap.min.css"/> 
	<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
	<style type="text/css">
		html { height: 100% }
		body { height: 100%; margin: 0; padding: 0 }
		#map-canvas { height: 400px; width: 500px }
	</style>
	<script type="text/javascript"
     src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBskpEcwdyTf9uTqblPYNjdL-OFiLyXHbw&sensor=true">
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
	<div class="container">
		<div class="row">
			<div class="col-md-12">
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
					<p>
						<a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in</a>
						to use the system.
					</p>
				<%
				    }
				%>
			</div>
		</div>
		<% if (user != null){ %>
		<div class="row">
			<div class="col-md-12">
				<h1>Listing your reservations</h1>
			</div>
		</div>
		<div class="row">
			<div class="col-md-12">
				<h2>Click <a href="testapp.jsp">here</a> to make a new reservation.</h2>
			</div>
		</div>
		<div class="row hidden">
			<div class="col-md-12">
				<form>
					<input type="hidden" name="userLatitude" id="userLatitude" />
				   	<input type="hidden" name="userLongitude" id="userLongitude" />
				    <input type="hidden" name="measureAccuracy" id="measureAccuracy" />
				</form>
			</div>
		</div>
		<%
		    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
		    Key parkingKey = KeyFactory.createKey("Parking", "Parking");
		    // Run an ancestor query to ensure we see the most up-to-date
		    // view of the reservations belonging to the selected Guestbook.
		    Date currentDate = new Date();
		    Query query = new Query("Reservation", parkingKey).addFilter("user", Query.FilterOperator.EQUAL, user).addFilter("reservationDate", Query.FilterOperator.GREATER_THAN_OR_EQUAL, currentDate).addSort("reservationDate", Query.SortDirection.ASCENDING);
		    List<Entity> reservations = datastore.prepare(query).asList(FetchOptions.Builder.withLimit(10));
		    if (reservations.isEmpty()) {
		        %>
		        <div class="row">
		        	<div class="col-md-12">
		        		<p class="text-warning">You have not done any reservation.</p>
	        		</div>
        		</div>
		        <%
		    } else {
		        %>
		        <div class="row">
		        	<div class="col-md-12">
				        <table class="table table-hover">
				        <thead>	
				        	<tr>
				        		<td>Date(m/d/y)</td>
				        		<td>Amount Of Hours reserved</td>
				        		<td>Parking</td>
				        		<td colspan="2" >Geolocation (Latitude/Longitude) </td>
				        		<td>Actions</td>
				        	</tr> 
				        </thead>
				        <tbody>
					        <%
					        for (Entity reservation : reservations) {
					            pageContext.setAttribute("amount_of_hours", reservation.getProperty("amountOfHours"));
					            pageContext.setAttribute("marker_id", reservation.getProperty("markerID"));
					            pageContext.setAttribute("user_latitude", reservation.getProperty("userLatitude"));
					            pageContext.setAttribute("user_longitude", reservation.getProperty("userLongitude"));
					            pageContext.setAttribute("measure_accuracy", reservation.getProperty("measureAccuracy"));
					            pageContext.setAttribute("reservation_date", reservation.getProperty("reservationDate")); %>
					            <tr>
					            	<td><fmt:formatDate value="${reservation_date}" pattern="MM/dd/yy HH:mm" /></td>
					            	<td>${fn:escapeXml(amount_of_hours) }</td>
					            	<td>Parking ${fn:escapeXml(marker_id)}</td>
					            	<td>${fn:escapeXml(user_latitude)}</td>
					            	<td>${fn:escapeXml(user_longitude)}</td>
					            	<td><a href='delete?reservationDate=${fn:escapeXml(reservation_date)}&latitude=${fn:escapeXml(user_latitude)}&longitude=${fn:escapeXml(user_longitude)}&amountOfHours=${fn:escapeXml(amount_of_hours) }&markerID=${fn:escapeXml(marker_id)}'>Remove reservation</a></td>
					            	<script>
							            markers.push(new google.maps.Marker({
							                position: new google.maps.LatLng(${fn:escapeXml(user_latitude)},${fn:escapeXml(user_longitude)}),
							                title: '${fn:escapeXml(reservation_user.nickname)}'
							            }));
					            	</script>
				            	</tr>
					            <% } %>
					            <%
					        } %>
					        </tbody>
					        </table>
				       </div>
			       </div>
			    <div class="row">
			    	<div class="col-md-12">
			    		<div id="map-canvas"></div>
			    	</div>
			    </div>
		    <% }
			%>
	</div>
  </body>
</html>