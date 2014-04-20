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
		 int hour = Integer.parseInt(req.getParameter("hour"));
		 int minute = Integer.parseInt(req.getParameter("minute"));
		 int day = Integer.parseInt(req.getParameter("day"));
		 int month = Integer.parseInt(req.getParameter("month"));
		 int year = Integer.parseInt(req.getParameter("year"));
		 int amountOfHours = Integer.parseInt(req.getParameter("amountOfHours"));
		 float longitude = Float.parseFloat(req.getParameter("longitude"));
		 Float latitude = Float.parseFloat(req.getParameter("latitude"));
		 Date givenDate = new Date(year, month, day, hour, minute);
		 Query query = new Query("Reservation", parkingKey).addFilter("user", Query.FilterOperator.EQUAL, user).
				 										addFilter("reservationDate", Query.FilterOperator.EQUAL, givenDate).
				 										addFilter("amountOfHours", Query.FilterOperator.EQUAL, amountOfHours).
				 										addFilter("userLongitude", Query.FilterOperator.EQUAL, longitude).
				 										addFilter("userLatitude", Query.FilterOperator.EQUAL, latitude);
		 List<Entity> reservations = datastore.prepare(query).asList(FetchOptions.Builder.withLimit(10));
		 if (!reservations.isEmpty()){
			 for (Entity reservation : reservations) {
			 
			 }
		 }
		 resp.sendRedirect("/guestbook.jsp");
	 }
}
