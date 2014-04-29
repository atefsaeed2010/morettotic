package br.com.morettotic.viewmenu;

import java.net.URLEncoder;

import org.json.JSONException;
import org.json.JSONObject;
//http://www.nosnaldeia.com.br/babel_json_services/?action=SAVE_PROFILE&id_user=1&email=malacma@gmail.com&passwd=Password&name=MORETTO LAMM&birthday=2010-01-01&paypall_acc=12223kkjj12&nature=4&proficiency=PT&id_role=1
import android.annotation.TargetApi;
import android.app.AlertDialog;
import android.app.DialogFragment;
import android.app.Fragment;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnFocusChangeListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RadioGroup.OnCheckedChangeListener;
import android.widget.TextView;
import br.com.morettotic.entity.Profile;
import br.com.morettotic.viewmenu.httputil.URLParser;

import com.vizteck.navigationdrawer.R;
import static br.com.morettotic.viewmenu.MainActivity.*;
import static br.com.morettotic.entity.Profile.*;

/**
 * http://www.nosnaldeia.com.br/babel_json_services/?action=SAVE_PROFILE&id_user
 * =69&email=super@mail.com&passwd=123456&name=USUARIO%20SUPER%201&birthday=2010
 * -01-01&paypall_acc=AAAS&nature=3&proficiency=FR&id_role=1&passwd=123456
 * 
 * */
public class FragmentProfile extends Fragment {
	// this Fragment will be called from MainActivity
	private String url;
	private ProgressDialog dialog = null;
	private JSONObject js;

	public FragmentProfile() {
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {

		final View rootView = inflater.inflate(R.layout.profile_fragment,
				container, false);

		dialog = new ProgressDialog(rootView.getContext());
		// Evento para esconder ou exibir os dados do tradutor (lingua de
		// proficiencia)
		RadioGroup roles = (RadioGroup) rootView
				.findViewById(R.id.radioGroupRole1);
		roles.setOnCheckedChangeListener(new OnCheckedChangeListener() {

			public void onCheckedChanged(RadioGroup group, int checkedId) {
				switch (checkedId) {
				case R.id.radioButtonUser:
					// 'Incident' checked
					showHideButtons(View.GONE, rootView);
					System.out.println(R.id.radioButtonUser);
					break;
				case R.id.radioButtonTranslator:
					showHideButtons(View.VISIBLE, rootView);
					System.out.println(R.id.radioButtonTranslator);
					break;
				}
			}
		});

		final TextView birthDay = (TextView) rootView
				.findViewById(R.id.birthday);
		final TextView name = (TextView) rootView.findViewById(R.id.name);
		final TextView paypall = (TextView) rootView
				.findViewById(R.id.paypallacc);
		final RadioButton radioUser = (RadioButton) rootView
				.findViewById(R.id.radioButtonUser);
		final RadioButton radioTranslator = (RadioButton) rootView
				.findViewById(R.id.radioButtonTranslator);
		final RadioGroup gFlags = (RadioGroup) rootView
				.findViewById(R.id.radioGroupFlags);
		final TextView pass1 = (TextView) rootView
				.findViewById(R.id.password11);
		final TextView pass2 = (TextView) rootView
				.findViewById(R.id.password12);

		//
		// birthDay.setText(MainActivity.MY_PROFILE.getJson());

		name.setText(MY_PROFILE.getName());
		birthDay.setText(MY_PROFILE.getBirth());
		paypall.setText(MY_PROFILE.getPaypallAcc());

		// Replica o passwd na tela de perfil
		pass1.setText(MY_PROFILE.getPassWd());
		pass2.setText(MY_PROFILE.getPassWd());
		// Seleciona o RADIOBUTTON do papel
		if (MY_PROFILE.getRoleId().equals("1")) {
			radioUser.setChecked(true);
			radioTranslator.setChecked(false);
		} else {
			radioUser.setChecked(false);
			radioTranslator.setChecked(true);
		}

		birthDay.setOnFocusChangeListener(new OnFocusChangeListener() {
			public void onFocusChange(View v, boolean hasFocus) {
				if (hasFocus) {
					// Exibe o dialogo de datas
					showTimePickerDialog(v);
				} else {
					birthDay.setText(DatePickerFragment.BIRTHDAY);
				}

			}
		});
		final Button buttonAvatar = (Button) rootView
				.findViewById(R.id.ButtonAvatar);
		// final Intent intent = new Intent(this, ConfActivity.class);
		buttonAvatar.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				MAINWINDOW.displayView(4);
			}
		});

		final Button button = (Button) rootView.findViewById(R.id.buttonFinish);
		// final Intent intent = new Intent(this, ConfActivity.class);
		button.setOnClickListener(new View.OnClickListener() {

			boolean hasErros = false;

			public void onClick(View v) {
				hasErros = false;
				TextView passw1 = (TextView) rootView
						.findViewById(R.id.password11);
				TextView passw2 = (TextView) rootView
						.findViewById(R.id.password12);
				RadioGroup gFlags = (RadioGroup) rootView
						.findViewById(R.id.radioGroupFlags);
				RadioGroup gRoles = (RadioGroup) rootView
						.findViewById(R.id.radioGroupRole1);
				TextView name = (TextView) rootView.findViewById(R.id.name);
				TextView birth = (TextView) rootView
						.findViewById(R.id.birthday);
				TextView pay = (TextView) rootView
						.findViewById(R.id.paypallacc);
				StringBuilder msg = new StringBuilder();
				String roleId = "1";
				RadioButton b1 = null, b2 = null;

				int selected = gFlags.getCheckedRadioButtonId();
				int selected2 = gRoles.getCheckedRadioButtonId();

				if (!passw1.getText().toString()
						.equals(passw2.getText().toString())) {
					msg.append("Password must match!\n");
					hasErros = true;
				}
				if (selected2 == -1) {
					msg.append("Please select your role!\n");
					hasErros = true;
				} else {
					b2 = (RadioButton) getActivity().findViewById(selected2);
					roleId = b2.getText().equals("USER") ? "1" : "2";
					MY_PROFILE.setRoleId(roleId);
				}
				if (selected == -1 && roleId.equals("2")) {
					msg.append("Please select your proficiency language!\n");
					hasErros = true;
				} else {
					b1 = (RadioButton) getActivity().findViewById(selected);
				}

				try {
					url = MAIN_URL
							+ "?action=SAVE_PROFILE"
							+ "&id_user="
							+ MY_PROFILE.getId()
							+ "&email="
							+ MY_PROFILE.getEmail()
							+ "&passwd="
							+ passw1.getText().toString()
							+ "&name="
							+ URLEncoder.encode(name.getText().toString()
									.toUpperCase(), "UTF-8")
							+ "&birthday="
							+ URLEncoder.encode(birth.getText().toString(),"UTF-8") 
							+ "&paypall_acc="+java.util.UUID.randomUUID().toString()
							+ "&nature=" + MY_PROFILE.getNature();
					if (b1 == null) {
						url += "&proficiency=PT";
						url += "&id_role=1";
					} else {
						url += "&proficiency=" + b1.getText().toString();
						url += "&id_role=2";
					}
				} catch (Exception e) {
					e.printStackTrace();
				}
				//

				// msg.append(url);
				// Perform action on click
				AlertDialog.Builder builder1 = new AlertDialog.Builder(rootView
						.getContext());

				builder1.setMessage(msg.toString());
				if (!hasErros) {
					dialog.setMessage("Loading...");
					dialog.show();
					new ProfileAction().execute(url);
				} else {
					builder1.setMessage(msg.toString());
					builder1.setCancelable(true);
					builder1.setNegativeButton("OK",
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int id) {
									dialog.cancel();
								}
							});

					AlertDialog alert11 = builder1.create();
					alert11.show();
				}

			}
		});

		return rootView;
	}

	private void showHideButtons(int isVisible, View root) {

		RadioGroup radio1 = (RadioGroup) root
				.findViewById(R.id.radioGroupFlags);
		radio1.setVisibility(isVisible);
		TextView title = (TextView) root.findViewById(R.id.textViewProfile);
		title.setVisibility(isVisible);
		final TextView paypall = (TextView) root
				.findViewById(R.id.paypallacc);
		paypall.setVisibility(View.GONE);
			

	}

	@TargetApi(Build.VERSION_CODES.HONEYCOMB)
	public void showTimePickerDialog(View v) {
		DialogFragment newFragment = (DialogFragment) new DatePickerFragment();
		newFragment.show(this.getFragmentManager(), "timePicker");
	}

	class ProfileAction extends AsyncTask<String, Void, String> {

		protected String doInBackground(String... urls) {

			// Creating new JSON Parser
			URLParser jParser = new URLParser();

			// Getting JSON from URL
			String json1 = null;
			try {
				json1 = jParser.getStringFromUrl(urls[0]);

			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				return e.toString();
			}

			return json1;
		}

		@Override
		// {"id_user":"131","name":"VISITOR","email":"hshd@jsjd.com","birthday":"2014-12-03","paypall_acc":"N-IHHHH",
		// "credits":"0","nature":"3","proficiency":"1","serverName":"ekiga.net","user":"trandutoringles","pass":"translate1","role":"1","message":"Updated"}
		protected void onPostExecute(String result) {
			// TODO Auto-generated method stub
			MY_PROFILE.setJson(result);
			try {
				js = new JSONObject(MY_PROFILE.getJson());
				MY_PROFILE.setId(js.getString(Profile.C_ID));
				MY_PROFILE.setProficiency(js.getString(C_PROFICIENCY));
				MY_PROFILE.setNature(js.getString(C_NATURE));
				MY_PROFILE.setCredits(js.getString(C_CREDITS));
				MY_PROFILE.setEmail(js.getString(C_EMAIL));
				MY_PROFILE.setName(js.getString(C_NAME));
				MY_PROFILE.setBirth(js.getString(BIRTH));
				MY_PROFILE.setPaypallAcc(js.getString(C_PAYPALL));
				MY_PROFILE.setCredits(js.getString(C_CREDITS));
				MY_PROFILE.setSipServ(js.getString(C_SIP_SERVER));
				MY_PROFILE.setSipUser(js.getString(C_SIP_USER));
				MY_PROFILE.setSipPass(js.getString(C_SIP_PASS));
				MY_PROFILE.setRoleId(js.getString(C_ROLE));
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			dialog.dismiss();
			// MainActivity.MAINWINDOW.displayView(2);
			super.onPostExecute(result);
		}

	}
	
	
	
	
}