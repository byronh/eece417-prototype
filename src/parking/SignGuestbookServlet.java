package parking;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

import java.io.IOException;
import java.util.Date;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class SignGuestbookServlet extends HttpServlet {
    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse resp)
                throws IOException {
        UserService userService = UserServiceFactory.getUserService();
        User user = userService.getCurrentUser();

        // We have one entity group per Guestbook with all reservations residing
        // in the same entity group as the Guestbook to which they belong.
        // This lets us run a transactional ancestor query to retrieve all
        // reservations for a given Guestbook.  However, the write rate to each
        // Guestbook should be limited to ~1/second.
        Key parkingKey = KeyFactory.createKey("Parking", "Parking");
        int markerID = Integer.parseInt(req.getParameter("markerID"));
        int day = Integer.parseInt(req.getParameter("day"));
        int month = Integer.parseInt(req.getParameter("month"));
        int year = Integer.parseInt(req.getParameter("year"));
        int hour = Integer.parseInt(req.getParameter("hour"));
        int minute = Integer.parseInt(req.getParameter("minute"));
        int amount = Integer.parseInt(req.getParameter("amount"));
        float userLatitude = Float.parseFloat(req.getParameter("userLatitude"));
        float userLongitude = Float.parseFloat(req.getParameter("userLongitude"));
        float measureAccuracy = Float.parseFloat(req.getParameter("measureAccuracy"));
        Date reservationDate = new Date(year, month, day, hour, minute);
        Date registerDate = new Date();
        Entity reservation = new Entity("Reservation", parkingKey);
        reservation.setProperty("user", user);
        reservation.setProperty("date", registerDate);
        reservation.setProperty("reservationDate", reservationDate);
        reservation.setProperty("amountOfHours", amount);
        reservation.setProperty("userLatitude", userLatitude);
        reservation.setProperty("userLongitude", userLongitude);
        reservation.setProperty("measureAccuracy", measureAccuracy);
        reservation.setProperty("markerID", markerID);
        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
        datastore.put(reservation);

        resp.sendRedirect("/guestbook.jsp");
    }
}