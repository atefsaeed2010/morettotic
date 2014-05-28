package smartcities.control;

import smartcities.util.UrlParser;
import com.google.appengine.labs.repackaged.org.json.JSONException;
import com.google.appengine.labs.repackaged.org.json.JSONObject;
import com.google.appengine.labs.repackaged.org.json.XML;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.http.*;

public class UFService extends GenericService {

    private static final String UF_BR = "http://hidroweb.ana.gov.br/fcthservices/mma.asmx/Estado";

    /**
     *
     * @param req
     * @param resp
     * @throws IOException
     */
    @Override
    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        processRequest(req, resp);
        resp.setContentType("application/json");
        StringBuilder sb = UrlParser.bufferURL(resp, UF_BR);

        JSONObject jsonObj;
        try {
            jsonObj = XML.toJSONObject(sb.toString());
            resp.getWriter().printf(jsonObj.toString());
        } catch (JSONException ex) {
            Logger.getLogger(UFService.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

}
