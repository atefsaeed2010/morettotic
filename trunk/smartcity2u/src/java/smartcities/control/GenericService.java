/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package smartcities.control;

import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import java.io.IOException;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.jdo.PersistenceManager;
import javax.servlet.http.*;
import smartcities.control.entitys.ProfileLog;

/**
 *
 * @author lamm
 */
public abstract class GenericService extends HttpServlet {

    public static final String IP = "ip";
    private UserService userService;
    private User user;

    public void processRequest(HttpServletRequest r1, HttpServletResponse r2) {
        try {
            userService = UserServiceFactory.getUserService();
            user = userService.getCurrentUser();
            if (user == null) {
                r2.sendRedirect(getUserService().createLoginURL(r1.getRequestURI()));
            }
        } catch (IOException ex) {
            Logger.getLogger(GenericService.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            //Log
            logAction(user, r1);
        }
    }

    public UserService getUserService() {
        return userService;
    }

    public void setUserService(UserService userService) {
        this.userService = userService;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    private void logAction(User user, HttpServletRequest request) {
        if (request.getSession(true).getAttribute("user") != null) {
            return;
        }
        String ipAddress = request.getHeader("X-FORWARDED-FOR");
        if (ipAddress == null) {
            ipAddress = request.getRemoteAddr();
        }

        ProfileLog pl = new ProfileLog(user, ipAddress, new Date());
        PersistenceManager pm = PMF.get().getPersistenceManager();
        try {

            pm.makePersistent(pl);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {

            request.getSession(true).setAttribute("user", user);

            ipAddress = null;
            pl = null;
            pm.close();
            pm = null;

        }

    }

    public String getIp(HttpServletRequest request) {
        String ipAddress = request.getHeader("X-FORWARDED-FOR");
        if (ipAddress == null) {
            ipAddress = request.getRemoteAddr();
        }
        return ipAddress;
    }

}
