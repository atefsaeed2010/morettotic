package br.com.morettotic.viewmenu;

import org.json.JSONException;
import org.json.JSONObject;

import static br.com.morettotic.viewmenu.MainActivity.*;
import static br.com.morettotic.entity.Profile.*;
import android.app.Fragment;
import android.app.ProgressDialog;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.media.AudioManager;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import br.com.morettotic.sip.CSIPService;
import br.com.morettotic.viewmenu.httputil.URLParser;

import com.csipsimple.api.ISipService;
import com.csipsimple.service.SipService;
import com.vizteck.navigationdrawer.R;

public class FragmentCountries extends Fragment {

	private boolean hasTranslatorOnline = false;
	private ProgressDialog dialog = null;
	private JSONObject json;
	private String url;
	private ISipService service;
	private AudioManager audioManager;
	private View rootView;
	
	
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {

		rootView = inflater.inflate(R.layout.countries_fragment,
				container, false);
		dialog = new ProgressDialog(rootView.getContext());
		final ImageButton button = (ImageButton) rootView
				.findViewById(R.id.imageButtonEN);

		
		
		// final Intent intent = new Intent(this, ConfActivity.class);
		button.setOnClickListener(new View.OnClickListener() {

			public void onClick(View v) {
				// Perform action on click
				// Conecta no servidor SIP

				dialog.setMessage("Searching for a translator!");
				dialog.show();

				url = MAIN_URL + "?action=CALL_PROFILE&nature="
						+ MY_PROFILE.getNature() + "&proficiency=2&id_user="
						+ MY_PROFILE.getId() + "&id_service_type=3";
				
				new CallAction().execute(url);

			}
		});
		// if(hasTranslatorOnline)

		return rootView;
	}

	class CallAction extends AsyncTask<String, Void, String> {

		protected String doInBackground(String... urls) {

			// Creating new JSON Parser
			URLParser jParser = new URLParser();

			// Getting JSON from URL
			String json1 = null;
			/**
			 * 
			 { id_translator: null, translator_name: null, sip_user_t: null,
			 * sip_pass_t: null, servername: null, start_t: 1396503270,
			 * call_token: "2a04abdbff0a481c081223600d6515ba", id_user: "-1",
			 * name: "Visitor", email: null, birthday: "11/11/2011",
			 * paypall_acc: "N-I", credits: "0", nature: "2", proficiency:
			 * "null", serverName: "ekiga.net", user: "trandutoringles", pass:
			 * "translate1", role: "translate1", message: "CONFERENCE" }
			 * 
			 * 
			 * */
			try {
				json1 = jParser.getStringFromUrl(urls[0]);
				
				MY_PROFILE.setJson(json1);
				
				json = new JSONObject(MY_PROFILE.getJson());
				
				MY_PROFILE.setTranslatorId(json.getString(C_ID_TRANSLATOR));
				MY_PROFILE.setTranslatorName(json.getString(C_TRANSLATOR));
				MY_PROFILE.setSipTranslatorU(json.getString(SIP_USER_TRANSLATOR));
				MY_PROFILE.setCallToken(json.getString(CALL_TOKEN));
				MY_PROFILE.setUserAvatar(json.getString(C_USER_AVATAR));
				MY_PROFILE.setTranslatorAvatar(json.getString(C_TRANSLATOR_AVATAR));
				MY_PROFILE.setCredits(json.getString(C_CREDITS));
				
				if (json.getString(C_ID_TRANSLATOR).equals("null")) {
					//dialog.setMessage("Try again later...\nNo translator avaliable or online");
				} else {
					hasTranslatorOnline = true;
				}

				// MY_PROFILE.set
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			// se tiver tradutor online.....

			return json1;
		}

		@Override
		protected void onPostExecute(String result) {
			// TODO Auto-generated method stub
			MY_PROFILE.setJson(result);
			CSIPService.setDestino(MY_PROFILE.getSipServ(), MY_PROFILE.getSipTranslatorU());
			if(hasTranslatorOnline){
				MAINWINDOW.displayView(3);
			}
			dialog.dismiss();
			
			super.onPostExecute(result);
		}

	}
}
