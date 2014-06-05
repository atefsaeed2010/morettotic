/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package smartcities.control;

import com.google.appengine.labs.repackaged.org.json.JSONException;
import com.google.appengine.labs.repackaged.org.json.JSONObject;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author lamm
 */
public class LoginService extends GenericService {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    public void processRequest(HttpServletRequest request, HttpServletResponse response) {

        super.processRequest(request, response);
        try {
            createBabelUser(request, response);
        } catch (IOException ex) {
            Logger.getLogger(LoginService.class.getName()).log(Level.SEVERE, null, ex);
        } catch (JSONException ex) {
            Logger.getLogger(LoginService.class.getName()).log(Level.SEVERE, null, ex);
        }

    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

    private void createBabelUser(HttpServletRequest request, HttpServletResponse response) throws IOException, JSONException {

        String pasString;
        pasString = "uni" + java.util.UUID.randomUUID().toString().substring(0, 5) + "xer";
        //@babel_json_services/?action=SAVE_PROFILE&id_user=1&email=dao2ne@gmail.com&name=Alejandro%20Martines&birthday=2010-01-01&paypall_acc=12223kkjj12&nature=1&proficiency=2&id_role=1&passwd=123123
        String url = "http://www.nosnaldeia.com.br/babel_json_services/?action=SAVE_PROFILE&"
                + "id_user=-1&email="
                + getUser().getEmail().toUpperCase()
                + "&name="
                + getUser().getNickname().toUpperCase()
                + "&birthday=2010-01-01&paypall_acc="
                + java.util.UUID.randomUUID().toString()
                + "&nature=1&proficiency=BR&id_role=1&passwd="
                + pasString;

        StringBuilder sb = UrlParser.bufferURL(response, url);

        String js = sb.toString();
        int t = js.length();
        js = js.substring(3, t);
        JSONObject json = new JSONObject(js);

        String idUser = json.getString("id_user");

        if (!idUser.equals("-1")) {
            //response.getWriter().print(url);
            response.getWriter().print("<h3>Welcome:" + getUser().getNickname().toUpperCase() + "</h3>");
            response.getWriter().print("<h5>Your password is:<i>" + pasString + "</i></h5>");
            response.getWriter().print("<h5>Download and login on app to set your language </h5>");
            response.getWriter().print("<h5>Thank you </h5>");

            response.getWriter().print("<h5><a href='http://www.nosnaldeia.com.br/babel_json_services/paypall/?id=" + idUser + "' target='_blank'>buy credits</a></h5>");

            //url = "http://www.nosnaldeia.com.br/babel_json_services/?login=" + getUser().getEmail().toUpperCase() + "&passwd=" + pasString;
            //sb = UrlParser.bufferURL(response, url);
        } else {
            response.getWriter().print("<h3>Welcome:" + getUser().getNickname().toUpperCase() + "</h3>");
            response.getWriter().print("<h4>Already registered</h4>");
        }
    }
}
