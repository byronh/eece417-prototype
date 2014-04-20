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

        // We have one entity group per Guestbook with all Greetings residing
        // in the same entity group as the Guestbook to which they belong.
        // This lets us run a transactional ancestor query to retrieve all
        // Greetings for a given Guestbook.  However, the write rate to each
        // Guestbook should be limited to ~1/second.
        String guestbookName = req.getParameter("guestbookName");
        Key guestbookKey = KeyFactory.createKey("Parking", "Parking");
        int markerID = Integer.parseInt(req.getParameter("markerID"));
        int day = Integer.parseInt(req.getParameter("day"));
        int month = Integer.parseInt(req.getParameter("month"));
        int year = Integer.parseInt(req.getParameter("year"));
        int amount = Integer.parseInt(req.getParameter("amount"));
        float userLatitude = Float.parseFloat(req.getParameter("userLatitude"));
        float userLongitude = Float.parseFloat(req.getParameter("userLongitude"));
        float measureAccuracy = Float.parseFloat(req.getParameter("measureAccuracy"));
        Date reservationDate = new Date(year, month, day);
        Date registerDate = new Date();
        Entity greeting = new Entity("Greeting", guestbookKey);
        greeting.setProperty("user", user);
        greeting.setProperty("date", registerDate);
        greeting.setProperty("reservationDate", reservationDate);
        greeting.setProperty("amountOfHours", amount);
        greeting.setProperty("userLatitude", userLatitude);
        greeting.setProperty("userLongitude", userLongitude);
        greeting.setProperty("measureAccuracy", measureAccuracy);
        greeting.setProperty("markerID", markerID);
        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
        datastore.put(greeting);

        resp.sendRedirect("/guestbook.jsp");
    }
}