/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package smartcities.control;

import smartcities.util.UrlParser;
import com.google.appengine.labs.repackaged.org.json.JSONException;
import com.google.appengine.labs.repackaged.org.json.JSONObject;
import com.google.appengine.labs.repackaged.org.json.XML;
import java.io.IOException;
import java.io.PrintWriter;
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
public class WeatherService extends GenericService {

    private static final String WINFO1 = "http://api.openweathermap.org/data/2.5/weather?q=";//Palho%C3%A7a,BR
    private static final String WINFO3 = "http://api.openweathermap.org/data/2.5/find?q=Bigua%C3%A7u&type=like&mode=json";

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

        response.setContentType("application/json");

        String cidade = request.getParameter("city");
        String pais = request.getParameter("country");
        String lat = request.getParameter("lat");
        String lon = request.getParameter("lon");
        String cdAeroporto = request.getParameter("cdAeroporto");
        String previsao = request.getParameter("p");
        StringBuilder sb = null;
        JSONObject jsonObj;
        try {
            if (cidade != null && pais != null) {

                UrlParser.printURL(response, makeR1(cidade, pais));

            } else if (cidade != null) {

                UrlParser.printURL(response, makeR2(cidade));

            } else if (lat != null && lon != null && previsao != null) {
                String url = makeR5(lat, lon);
                //response.getWriter().printf(url);
                
                sb = UrlParser.bufferURL(response,url);

                jsonObj = XML.toJSONObject(sb.toString());
                response.getWriter().printf(jsonObj.toString());
                
                //UrlParser.printURL(response, url);

            } else if (lat != null && lon != null) {

                UrlParser.printURL(response, makeR3(lat, lon));

            } else if (cdAeroporto != null) {

                sb = UrlParser.bufferURL(response, makeR4(cdAeroporto));

                jsonObj = XML.toJSONObject(sb.toString());
                response.getWriter().printf(jsonObj.toString());

            }

        } catch (IOException ex) {
            Logger.getLogger(WeatherService.class.getName()).log(Level.SEVERE, null, ex);

        } catch (JSONException ex) {
            try {
                Logger.getLogger(UFService.class.getName()).log(Level.SEVERE, null, ex);
                response.getWriter().printf(sb.toString());
            } catch (IOException ex1) {
                Logger.getLogger(WeatherService.class.getName()).log(Level.SEVERE, null, ex1);
            }
        }

    }

    private static String makeR5(String lat, String lon) {
        String url = "http://servicos.cptec.inpe.br/XML/cidade/7dias/" + lat + "/" + lon + "/previsaoLatLon.xml";
        return url;
    }

    private static String makeR4(String cdAeroporto) {
        String url = "http://servicos.cptec.inpe.br/XML/estacao/" + cdAeroporto + "/condicoesAtuais.xml";
        return url;
    }

    private static String makeR2(String cit) {
        String url = "http://api.openweathermap.org/data/2.5/find?q=" + cit + "&type=accurate&mode=json";
        return url;
    }

    private static String makeR3(String lat, String lon) {
        String url = "http://api.openweathermap.org/data/2.5/weather?lat=" + lat + "&lon=" + lon;
        return url;
    }

    private static String makeR1(String cit, String cou) {
        String r = WINFO1 + cit + "," + cou;
        return r;
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

}
