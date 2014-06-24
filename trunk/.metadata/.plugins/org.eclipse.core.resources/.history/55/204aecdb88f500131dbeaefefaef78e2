package br.com.morettotic.viewmenu;

import static br.com.morettotic.entity.Profile.CALL_TOKEN;
import static br.com.morettotic.entity.Profile.C_CREDITS;
import static br.com.morettotic.entity.Profile.C_ID_TRANSLATOR;
import static br.com.morettotic.entity.Profile.C_SIP_SERVER_T;
import static br.com.morettotic.entity.Profile.C_TRANSLATOR;
import static br.com.morettotic.entity.Profile.C_TRANSLATOR_AVATAR;
import static br.com.morettotic.entity.Profile.C_USER_AVATAR;
import static br.com.morettotic.entity.Profile.MAIN_URL;
import static br.com.morettotic.entity.Profile.SIP_USER_TRANSLATOR;
import static br.com.morettotic.viewmenu.MainActivity.MAINWINDOW;
import static br.com.morettotic.viewmenu.MainActivity.MY_PROFILE;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Fragment;
import android.app.ProgressDialog;
import android.media.AudioManager;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.Spinner;
import br.com.morettotic.entity.ServiceType;
import br.com.morettotic.navdraw.R;
import br.com.morettotic.sip.CSIPService;
import br.com.morettotic.viewmenu.utils.URLParser;

import com.csipsimple.api.ISipService;

public class FragmentCountries extends Fragment {

	private boolean hasTranslatorOnline = false;
	private ProgressDialog dialog = null;
	private JSONObject json;
	private String url;
	private ISipService service;
	private AudioManager audioManager;
	private View rootView;
	private String spinnerTxt;
	private Spinner serviceType;
	
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {

		rootView = inflater.inflate(R.layout.countries_fragment,
				container, false);
		dialog = new ProgressDialog(rootView.getContext());
		final ImageButton button = (ImageButton) rootView
				.findViewById(R.id.imageButtonEN);

		serviceType = (Spinner) rootView.findViewById(R.id.spinner1);
		
		// final Intent intent = new Intent(this, ConfActivity.class);
		button.setOnClickListener(new View.OnClickListener() {

			public void onClick(View v) {
				// Perform action on click
				// Conecta no servidor SIP

				loadTranslator("2","English");

			}
		});
		
		
		final ImageButton button1CH = (ImageButton) rootView
				.findViewById(R.id.imageButtonCH);

		
		
		// final Intent intent = new Intent(this, ConfActivity.class);
		button1CH.setOnClickListener(new View.OnClickListener() {

			public void onClick(View v) {
				// Perform action on click
				// Conecta no servidor SIP


				loadTranslator("6","Chinese");

			}
		});
		
		final ImageButton button1ES = (ImageButton) rootView
				.findViewById(R.id.imageButtonES);

		
		
		// final Intent intent = new Intent(this, ConfActivity.class);
		button1ES.setOnClickListener(new View.OnClickListener() {

			public void onClick(View v) {
				// Perform action on click
				// Conecta no servidor SIP

				loadTranslator("8","Spanish");

			}
		});
		
		
		final ImageButton button1MR = (ImageButton) rootView
				.findViewById(R.id.imageButtonMR);

		
		
		// final Intent intent = new Intent(this, ConfActivity.class);
		button1MR.setOnClickListener(new View.OnClickListener() {

			public void onClick(View v) {
				// Perform action on click
				// Conecta no servidor SIP

				loadTranslator("7","Arabic");

			}
		});
		
		final ImageButton button1FR = (ImageButton) rootView
				.findViewById(R.id.imageButtonFR);

		
		
		// final Intent intent = new Intent(this, ConfActivity.class);
		button1FR.setOnClickListener(new View.OnClickListener() {

			public void onClick(View v) {
				// Perform action on click
				// Conecta no servidor SIP

				loadTranslator("4","French");

			}
		});
		
		final ImageButton button1BR = (ImageButton) rootView
				.findViewById(R.id.imageButtonBR);

		
		
		// final Intent intent = new Intent(this, ConfActivity.class);
		button1BR.setOnClickListener(new View.OnClickListener() {

			public void onClick(View v) {
				// Perform action on click
				// Conecta no servidor SIP

				loadTranslator("1","Portuguese");

			}
		});
		
		final ImageButton button1JP = (ImageButton) rootView
				.findViewById(R.id.imageButtonJP);

		
		
		// final Intent intent = new Intent(this, ConfActivity.class);
		button1JP.setOnClickListener(new View.OnClickListener() {

			public void onClick(View v) {
				// Perform action on click
				// Conecta no servidor SIP

				loadTranslator("5","Japanese");

			}
		});
		final ImageButton button1GR = (ImageButton) rootView
				.findViewById(R.id.imageButtonJP);

		
		
		// final Intent intent = new Intent(this, ConfActivity.class);
		button1GR.setOnClickListener(new View.OnClickListener() {

			public void onClick(View v) {
				// Perform action on click
				// Conecta no servidor SIP

				loadTranslator("3","Germany");

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
				MY_PROFILE.setSipTranslatorServer(json.getString(C_SIP_SERVER_T));
				
				if (json.getString(C_ID_TRANSLATOR).equals("null")) {
					//dialog.setMessage("Try again later...\nNo translator avaliable or online");
					//dialog.
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
			CSIPService.setDestino(MY_PROFILE.getSipTranslatorServer(), MY_PROFILE.getSipServ());
			if(hasTranslatorOnline){
				MAINWINDOW.displayView(3);
			}
			dialog.dismiss();
			
			super.onPostExecute(result);
		}

	}
	
	private void loadTranslator(String countryId,String countryName){
		
		new br.com.morettotic.viewmenu.utils.Vibrator2u(MainActivity.MAINWINDOW).callButton();

		spinnerTxt = serviceType.getSelectedItem().toString();
		
		dialog.setMessage("Searching for a translator ("+countryName+")!");
		dialog.show();
		
		ServiceType st = ServiceType.valueOf(spinnerTxt);
		
		MY_PROFILE.setCallToLanguage(countryId);
		
		url = MAIN_URL + "?action=CALL_PROFILE&nature="
				+ MY_PROFILE.getNature() + "&proficiency="+countryId
				+"&id_user="+ MY_PROFILE.getId() 
				+ "&id_service_type="+st.ordinal();
		
		new CallAction().execute(url);
	}
}
