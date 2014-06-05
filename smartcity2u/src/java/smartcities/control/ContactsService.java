/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package smartcities.control;

import com.google.appengine.repackaged.com.google.protobuf.ServiceException;
import com.google.gdata.data.Link;
import com.google.gdata.data.contacts.ContactEntry;
import com.google.gdata.data.extensions.ContactFeed;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URL;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import teaching.view.SQLContatcs;

/**
 *
 * @author lamm
 */
public class ContactsService extends GenericRequest {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    public void processRequest(HttpServletRequest request, HttpServletResponse response) {
        try {
            //     super.getUserService().
            super.processRequest(request, response);
            String user = super.getUser().getEmail();
            String pass = request.getParameter("passwd");
            
            SQLContatcs sqlc = new SQLContatcs();
            sqlc.autenticar(user, pass);
            sqlc.listarContatosDetalhado(response);
        } catch (IOException ex) {
            Logger.getLogger(ContactsService.class.getName()).log(Level.SEVERE, null, ex);
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

    
   private static void printContact(ContactEntry contact) {
    System.err.println("Id: " + contact.getId()); 
    if (contact.getTitle() != null) {
      System.err.println("Contact name: " + contact.getTitle().getPlainText());
    } else {
      System.err.println("Contact has no name");
      
    }
    System.err.println("Last updated: " + contact.getUpdated().toUiString());
    if (contact.hasDeleted()) {
      System.err.println("Deleted:");
    }

   // ElementHelper.printContact(System.err, contact);
    
    Link photoLink = contact.getLink(
        "http://schemas.google.com/contacts/2008/rel#photo", "image/*");
    System.err.println("Photo link: " + photoLink.getHref());
    String photoEtag = photoLink.getEtag();
    System.err.println("  Photo ETag: "
        + (photoEtag != null ? photoEtag : "(No contact photo uploaded)"));
    System.err.println("Self link: " + contact.getSelfLink().getHref());
    System.err.println("Edit link: " + contact.getEditLink().getHref());
    System.err.println("ETag: " + contact.getEtag());
    System.err.println("-------------------------------------------\n");
  }
 
 
/* This method will add a contact to that particular Google account */
    
}
