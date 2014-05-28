/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package smartcities.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author lamm
 */
public class UrlParser {

    /**
     *
     * @param response
     * @param purl
     * @throws IOException
     */
    public static void printURL(HttpServletResponse response, String purl) throws IOException {
        try {
            URL url;
            url = new URL(purl);
            BufferedReader reader = new BufferedReader(new InputStreamReader(url.openStream()));
            String line;

            while ((line = reader.readLine()) != null) {
                // ...
                response.getWriter().println(line);
            }
            reader.close();

        } catch (MalformedURLException e) {
            // ...response.getWriter().println(line);
            response.getWriter().println(e.toString());
        } catch (IOException e) {
            // ...
            response.getWriter().println(e.toString());
        }

    }

    public static StringBuilder bufferURL(HttpServletResponse response, String purl) throws IOException {
        StringBuilder sb = new StringBuilder();

        try {
            URL url;
            url = new URL(purl);
            BufferedReader reader = new BufferedReader(new InputStreamReader(url.openStream()));
            String line;
           
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            reader.close();

        } catch (MalformedURLException e) {
            // ...response.getWriter().println(line);
            response.getWriter().println(e.toString());
        } catch (IOException e) {
            // ...
            response.getWriter().println(e.toString());
        }

        return sb;
    }
}
