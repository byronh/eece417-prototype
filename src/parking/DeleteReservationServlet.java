package parking;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.FetchOptions;


import java.io.IOException;
import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class DeleteReservationServlet extends HttpServlet{
	 @Override
	 public void doGet(HttpServletRequest req, HttpServletResponse resp)
	                throws IOException {
		 UserService userService = UserServiceFactory.getUserService();
		 User user = userService.getCurrentUser();
		 DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
		 Key parkingKey = KeyFactory.createKey("Parking", "Parking");
		 Date givenDate = new Date(req.getParameter("reservationDate"));
		 int amountOfHours = Integer.parseInt(req.getParameter("amountOfHours"));
		 int markerID = Integer.parseInt(req.getParameter("markerID"));
		 float longitude = Float.parseFloat(req.getParameter("longitude"));
		 Float latitude = Float.parseFloat(req.getParameter("latitude"));
		 Query query = new Query("Reservation", parkingKey).addFilter("user", Query.FilterOperator.EQUAL, user).
				 										addFilter("markerID",Query.FilterOperator.EQUAL, markerID).
				 										addFilter("reservationDate", Query.FilterOperator.EQUAL, givenDate).
				 										addFilter("amountOfHours", Query.FilterOperator.EQUAL, amountOfHours).
				 										addFilter("userLongitude", Query.FilterOperator.EQUAL, longitude).
				 										addFilter("userLatitude", Query.FilterOperator.EQUAL, latitude);
		 List<Entity> reservations = datastore.prepare(query).asList(FetchOptions.Builder.withLimit(10));
		 if (!reservations.isEmpty()){
			 for (Entity reservation : reservations) {
			 Key key = KeyFactory.createKey("Reservation", reservation.toString());
			 datastore.delete(key);
			 }
		 }
		 resp.sendRedirect("/guestbook.jsp");
	 }
}
