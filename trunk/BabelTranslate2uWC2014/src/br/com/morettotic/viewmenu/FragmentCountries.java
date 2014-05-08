package br.com.morettotic.viewmenu;

import static br.com.morettotic.entity.Profile.CALL_TOKEN;
import static br.com.morettotic.entity.Profile.C_CREDITS;
import static br.com.morettotic.entity.Profile.C_ID_TRANSLATOR;
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
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageButton;
import br.com.morettotic.sip.CSIPService;
import br.com.morettotic.viewmenu.httputil.URLParser;

import com.vizteck.navigationdrawer.R;

public class FragmentCountries extends Fragment {

	public enum Proficiency {
		PORTUGUESE(1), ENGLISH(2), GERMANY(3), FRENCH(4), JAPANESE(5), CHINESE(
				6);

		public Integer valor;

		Proficiency(Integer valor) {
			this.valor = valor;
		}
	}

	private boolean hasTranslatorOnline = false;
	private ProgressDialog dialog = null;
	private JSONObject json;
	private String url;
	private View rootView;
	private Proficiency proficiency = Proficiency.ENGLISH;

	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {

		rootView = inflater.inflate(R.layout.countries_fragment, container,
				false);
		dialog = new ProgressDialog(rootView.getContext());

		final ImageButton imageButtonBR = (ImageButton) rootView
				.findViewById(R.id.imageButtonBR);
		imageButtonBR.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				proficiency = Proficiency.PORTUGUESE;
			}
		});

		final ImageButton imageButtonEN = (ImageButton) rootView
				.findViewById(R.id.imageButtonEN);
		imageButtonEN.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				proficiency = Proficiency.ENGLISH;
			}
		});

		final ImageButton imageButtonGR = (ImageButton) rootView
				.findViewById(R.id.imageButtonGR);
		imageButtonGR.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				proficiency = Proficiency.GERMANY;
			}
		});

		final ImageButton imageButtonFR = (ImageButton) rootView
				.findViewById(R.id.imageButtonFR);
		imageButtonFR.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				proficiency = Proficiency.FRENCH;
			}
		});

		final ImageButton imageButtonJP = (ImageButton) rootView
				.findViewById(R.id.imageButtonJP);
		imageButtonJP.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				proficiency = Proficiency.JAPANESE;
			}
		});

		final ImageButton imageButtonCH = (ImageButton) rootView
				.findViewById(R.id.imageButtonCH);
		imageButtonCH.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				proficiency = Proficiency.CHINESE;
			}
		});

		final ImageButton imageButtonMR = (ImageButton) rootView
				.findViewById(R.id.imageButtonMR);
		imageButtonMR.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				proficiency = Proficiency.ENGLISH;
			}
		});

		final Button buttonCallTranslator = (Button) rootView
				.findViewById(R.id.buttonCallTranslator);
		buttonCallTranslator.setOnClickListener(new View.OnClickListener() {

			public void onClick(View v) {
				// Perform action on click
				// Conecta no servidor SIP

				dialog.setMessage("Searching for a translator!");
				dialog.show();

				url = MAIN_URL + "?action=CALL_PROFILE&nature="
						+ MY_PROFILE.getNature() + "&proficiency="
						+ proficiency.valor + "&id_user=" + MY_PROFILE.getId()
						+ "&id_service_type=3";

				new CallAction().execute(url);

			}
		});

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
				MY_PROFILE.setSipTranslatorU(json
						.getString(SIP_USER_TRANSLATOR));
				MY_PROFILE.setCallToken(json.getString(CALL_TOKEN));
				MY_PROFILE.setUserAvatar(json.getString(C_USER_AVATAR));
				MY_PROFILE.setTranslatorAvatar(json
						.getString(C_TRANSLATOR_AVATAR));
				MY_PROFILE.setCredits(json.getString(C_CREDITS));

				if (json.getString(C_ID_TRANSLATOR).equals("null")) {
					dialog.setMessage("Try again later...\nNo translator avaliable or online");
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
			CSIPService.setDestino(MY_PROFILE.getSipServ(),
					MY_PROFILE.getSipTranslatorU());
			if (hasTranslatorOnline) {
				MAINWINDOW.displayView(3);
			}
			dialog.dismiss();

			super.onPostExecute(result);
		}

	}
}
