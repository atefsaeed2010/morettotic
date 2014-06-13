package br.com.morettotic.viewmenu;

import static br.com.morettotic.entity.Profile.FINISH_CONF;
import static br.com.morettotic.entity.Profile.MAIN_URL;
import static br.com.morettotic.viewmenu.MainActivity.MAINWINDOW;
import static br.com.morettotic.viewmenu.MainActivity.MY_PROFILE;

import java.util.*;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Fragment;
import android.app.ProgressDialog;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.SystemClock;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.Chronometer;
import android.widget.ImageView;
import android.widget.RatingBar;
import android.widget.RatingBar.OnRatingBarChangeListener;
import android.widget.TextView;
import android.widget.Chronometer.OnChronometerTickListener;
import br.com.morettotic.navdraw.*;
import br.com.morettotic.sip.CSIPService;
import br.com.morettotic.viewmenu.utils.URLParser;
import br.com.morettotic.navdraw.R;

public class FragmentConference extends Fragment {
	private ProgressDialog dialog = null;
	private TextView translatorName, credits,textViewTime;
	private Button atender, desligar;
	private View rootView;
	private RatingBar ratingBar1;
	private WebView web;
	private ImageView from,to;
	private long startTime, countUp;
	private Chronometer stopWatch;
	

	// this Fragment will be called from MainActivity
	public FragmentConference() {
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {

		rootView = inflater.inflate(R.layout.conference_fragment, container,
				false);
		translatorName = (TextView) rootView.findViewById(R.id.textView1);
		
		from = (ImageView) rootView.findViewById(R.id.imageViewFrom);
		to = (ImageView) rootView.findViewById(R.id.imageViewTo);
		//to.set
		//Change flags 
		setBackgroundStyle(from, MY_PROFILE.getNature().charAt(0));
		setBackgroundStyle(to,MY_PROFILE.getCallToLanguage().charAt(0) );
		
		translatorName.setText(MY_PROFILE.getTranslatorName());

		credits = (TextView) rootView.findViewById(R.id.textViewCredits);
		stopWatch = (Chronometer) rootView.findViewById(R.id.chronometer1);
        startTime = SystemClock.elapsedRealtime();

        textViewTime= (TextView) rootView.findViewById(R.id.textViewTime);
        stopWatch.setOnChronometerTickListener(new OnChronometerTickListener(){
            @Override
            public void onChronometerTick(Chronometer arg0) {
                countUp = (SystemClock.elapsedRealtime() - arg0.getBase()) / 1000;
                String asText = (countUp / 60) + ":" + (countUp % 60); 
                textViewTime.setText(asText);
            }
        });
        
		
		
		credits.setText("Credits: (" + MY_PROFILE.getCredits() + ") minutes");

		dialog = new ProgressDialog(rootView.getContext());
		
		ratingBar1 = (RatingBar) rootView.findViewById(R.id.ratingBar1);
		
		web = (WebView) rootView.findViewById(R.id.avatarIdWebView);
		// web.loadUrl("http://nosnaldeia.com.br/babel_json_services/libs/avatars/resized_IMG_20140322_180057.jpg");
		web.loadUrl(MAIN_URL + "?action=AVATAR_VIEW&id_user="+ MY_PROFILE.getTranslatorId());
		
		atender = (Button) rootView.findViewById(R.id.atender);
		desligar = (Button) rootView.findViewById(R.id.button2);
		
		CSIPService csipService = CSIPService.getInstance(getActivity(),MY_PROFILE);
		
		if (!csipService.isChamadaEmAndamento()) {
			if (MY_PROFILE.getSipTranslatorU() == null || MY_PROFILE.getSipTranslatorU().equals("null")) {
				MAINWINDOW.displayView(2);
			}else{
				CSIPService.getInstance(getActivity(), MY_PROFILE).ligar();
				atender.setVisibility(View.GONE);
				stopWatch.start();
			}
		} else {
			ratingBar1.setVisibility(View.GONE);//Tradutor nao visualiza  a barra de votacao
			web.loadUrl(MAIN_URL + "?action=AVATAR_VIEW&id_user="+ MY_PROFILE.getId());
			atender.setVisibility(View.VISIBLE);
		}
		
		desligar.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				// Perform action on click
				dialog.setMessage("Finish...");
				dialog.show();
				new FinishConfAction().execute(MAIN_URL + FINISH_CONF+ MY_PROFILE.getCallToken());

			}
		});

		atender.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				CSIPService.getInstance(getActivity(), MY_PROFILE).atender();
				atender.setVisibility(View.GONE);
				stopWatch.start();
			}
		});

		ratingBar1.setVisibility(View.VISIBLE);//Exibe
		ratingBar1.setOnRatingBarChangeListener(new OnRatingBarChangeListener() {
					public void onRatingChanged(RatingBar ratingBar,
							float rating, boolean fromUser) {
						String.valueOf(rating);
						//
						new RateAction().execute(MAIN_URL + 
								"?action=EVALUATION&id_user="+MY_PROFILE.getId()+
								"&id_trans="+MY_PROFILE.getTranslatorId()+
								"&rate="+rating);
						ratingBar1.setVisibility(View.GONE);//votou some
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

				new JSONObject(MY_PROFILE.getJson());

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
			CSIPService.setDestino(MY_PROFILE.getSipServ(),MY_PROFILE.getSipTranslatorU());

			dialog.dismiss();
			MAINWINDOW.displayView(2);
			super.onPostExecute(result);
		}

	}
	class RateAction extends AsyncTask<String, Void, String> {

		protected String doInBackground(String... urls) {

			// Creating new JSON Parser
			URLParser jParser = new URLParser();

			// Getting JSON from URL
			String json1 = null;

			try {
				json1 = jParser.getStringFromUrl(urls[0]);
				
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			return json1;
		}

		@Override
		protected void onPostExecute(String result) {
			// TODO Auto-generated method stub
			dialog.dismiss();
			super.onPostExecute(result);
		}

	}
	
	private void setBackgroundStyle(ImageView imageV, char from){
		switch(from){
		case '1':
			imageV.setBackgroundResource(R.drawable.br_b);
			break;
		case '2':
			imageV.setBackgroundResource(R.drawable.uk_b);
			break;
		case '3':
			imageV.setBackgroundResource(R.drawable.gr_b);
			break;
		case '4':
			imageV.setBackgroundResource(R.drawable.fr_b);
			break;
		case '5':
			imageV.setBackgroundResource(R.drawable.jp_b);
			break;
		case '6':
			imageV.setBackgroundResource(R.drawable.ch_b);
			break;
		case '7':
			imageV.setBackgroundResource(R.drawable.mr_b);
			break;
		case '8':
			imageV.setBackgroundResource(R.drawable.es_b);
			break;
	
		}
			
		
		//imageV.setBackgroundResource(R.drawable.ic_brasil);
	}
}
