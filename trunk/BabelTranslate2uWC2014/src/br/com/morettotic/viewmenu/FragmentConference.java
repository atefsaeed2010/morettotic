package br.com.morettotic.viewmenu;

import static br.com.morettotic.entity.Profile.FINISH_CONF;
import static br.com.morettotic.entity.Profile.MAIN_URL;
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
import android.webkit.WebView;
import android.widget.Button;
import android.widget.RatingBar;
import android.widget.RatingBar.OnRatingBarChangeListener;
import android.widget.TextView;
import br.com.morettotic.sip.CSIPService;
import br.com.morettotic.viewmenu.utils.URLParser;

import com.vizteck.navigationdrawer.R;

public class FragmentConference extends Fragment {
	private JSONObject json;
	private ProgressDialog dialog = null;
	private TextView translatorName, credits;
	private Button atender, desligar;
	private View rootView;
	private String avaliacao;

	// this Fragment will be called from MainActivity
	public FragmentConference() {
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {

		rootView = inflater.inflate(R.layout.conference_fragment, container,
				false);
		translatorName = (TextView) rootView.findViewById(R.id.textView1);

		translatorName.setText(MY_PROFILE.getTranslatorName());

		credits = (TextView) rootView.findViewById(R.id.textViewCredits);

		credits.setText("Credits: (" + MY_PROFILE.getCredits() + ") minutes");

		dialog = new ProgressDialog(rootView.getContext());
		WebView web = (WebView) rootView.findViewById(R.id.avatarIdWebView);
		// web.loadUrl("http://nosnaldeia.com.br/babel_json_services/libs/avatars/resized_IMG_20140322_180057.jpg");
		web.loadUrl(MAIN_URL + "?action=AVATAR_VIEW&id_user="
				+ MY_PROFILE.getTranslatorId());
		atender = (Button) rootView.findViewById(R.id.atender);
		desligar = (Button) rootView.findViewById(R.id.button2);
		CSIPService csipService = CSIPService.getInstance(getActivity(),
				MY_PROFILE);
		if (!csipService.isChamadaEmAndamento()) {
			CSIPService.getInstance(getActivity(), MY_PROFILE).ligar();
			atender.setVisibility(View.GONE);
		} else {
			atender.setVisibility(View.VISIBLE);
		}
		desligar.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				// Perform action on click
				dialog.setMessage("Finish...");
				dialog.show();
				new FinishConfAction().execute(MAIN_URL + FINISH_CONF
						+ MY_PROFILE.getCallToken());

			}
		});

		atender.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				CSIPService.getInstance(getActivity(), MY_PROFILE).atender();
				atender.setVisibility(View.GONE);
			}
		});

		RatingBar ratingBar1 = (RatingBar) rootView
				.findViewById(R.id.ratingBar1);
		ratingBar1.setOnRatingBarChangeListener(new OnRatingBarChangeListener() {
					public void onRatingChanged(RatingBar ratingBar,
							float rating, boolean fromUser) {
						avaliacao = String.valueOf(rating);
						// TODO - Enviar para o Servidor
					}
				});

		return rootView;
	}

	class FinishConfAction extends AsyncTask<String, Void, String> {

		protected String doInBackground(String... urls) {

			// Creating new JSON Parser
			URLParser jParser = new URLParser();

			// Getting JSON from URL
			String json1 = null;

			CSIPService.getInstance(getActivity(), MY_PROFILE).desligar();

			try {
				json1 = jParser.getStringFromUrl(urls[0]);

				MY_PROFILE.setJson(json1);

				json = new JSONObject(MY_PROFILE.getJson());

				// MY_PROFILE.setTranslatorId(json.getString(C_ID_TRANSLATOR));

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

			dialog.dismiss();
			MAINWINDOW.displayView(2);
			super.onPostExecute(result);
		}

	}
}
