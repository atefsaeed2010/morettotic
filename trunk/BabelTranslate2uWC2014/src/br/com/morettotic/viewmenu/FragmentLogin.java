package br.com.morettotic.viewmenu;

import static br.com.morettotic.entity.Profile.BIRTH;
import static br.com.morettotic.entity.Profile.C_CREDITS;
import static br.com.morettotic.entity.Profile.C_EMAIL;
import static br.com.morettotic.entity.Profile.C_NAME;
import static br.com.morettotic.entity.Profile.C_NATURE;
import static br.com.morettotic.entity.Profile.C_PASSWD_ERROR;
import static br.com.morettotic.entity.Profile.C_PAYPALL;
import static br.com.morettotic.entity.Profile.C_PROFICIENCY;
import static br.com.morettotic.entity.Profile.C_ROLE;
import static br.com.morettotic.entity.Profile.C_SIP_PASS;
import static br.com.morettotic.entity.Profile.C_SIP_SERVER;
import static br.com.morettotic.entity.Profile.C_SIP_USER;
import static br.com.morettotic.entity.Profile.MAIN_URL;
import static br.com.morettotic.viewmenu.MainActivity.MAINWINDOW;
import static br.com.morettotic.viewmenu.MainActivity.MY_PROFILE;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Fragment;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import br.com.morettotic.entity.Profile;
import br.com.morettotic.sip.CSIPService;
import br.com.morettotic.viewmenu.httputil.URLParser;

import com.vizteck.navigationdrawer.R;

@SuppressLint("NewApi")
public class FragmentLogin extends Fragment {
	protected static final String FragmentProfile = null;
	private boolean hasErros = false;
	private ProgressDialog dialog = null;
	private String url;
	protected TextView passwd;
	AlertDialog.Builder builder2;
	// this Fragment will be called from MainActivity
	public FragmentLogin() {
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {

		final View rootView = inflater.inflate(R.layout.login_fragment,
				container, false);
		dialog = new ProgressDialog(rootView.getContext());
		
		
	
		
		
		
		final TextView email = (TextView) rootView.findViewById(R.id.email);
		final TextView passwd1 = (TextView) rootView
				.findViewById(R.id.password12);
		builder2 = new AlertDialog.Builder(rootView
				.getContext());
		if (MY_PROFILE.getEmail() != null) {
			email.setText(MY_PROFILE.getEmail());
			// passwd1.setText(MainActivity.MY_PROFILE.getPassWd());
		}
		if (MY_PROFILE.getPassWd() != null) {
			passwd1.setText(MY_PROFILE.getPassWd());
			// passwd1.setText(MainActivity.MY_PROFILE.getPassWd());
		}

		final CheckBox eula = (CheckBox) rootView
				.findViewById(R.id.checkBoxEula);
		// final Intent intent = new Intent(this, ConfActivity.class);
		eula.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				// Perform action on click
				AlertDialog.Builder builder1 = new AlertDialog.Builder(rootView
						.getContext());
				builder1.setMessage("EULA TEXT LOLOLO LOLOLO EULA TEXT LOLOLO LOLOLO EULA TEXT LOLOLO LOLOLO EULA TEXT LOLOLO LOLOLO EULA TEXT LOLOLO LOLOLO EULA TEXT LOLOLO LOLOLO EULA TEXT LOLOLO LOLOLO EULA TEXT LOLOLO LOLOLO EULA TEXT LOLOLO LOLOLO EULA TEXT LOLOLO LOLOLO EULA TEXT LOLOLO LOLOLO EULA TEXT LOLOLO LOLOLO .");
				builder1.setCancelable(true);
				builder1.setNegativeButton("OK",
						new DialogInterface.OnClickListener() {
							public void onClick(DialogInterface dialog, int id) {
								dialog.cancel();
							}
						});

				AlertDialog alert11 = builder1.create();
				alert11.show();
			}
		});

		final Button button = (Button) rootView
				.findViewById(R.id.sign_in_button);

		button.setOnClickListener(new View.OnClickListener() {

			public void onClick(View v) {
				try {
					hasErros = false;
					StringBuilder msg = new StringBuilder();
					RadioGroup g = (RadioGroup) getActivity().findViewById(
							R.id.radioGroupRole1);
					CheckBox eula = (CheckBox) getActivity().findViewById(
							R.id.checkBoxEula);

					// Returns an integer which represents the selected radio
					// button's ID
					int selected = g.getCheckedRadioButtonId();

					final String EMAIL_PATTERN = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
							+ "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";
					Pattern pattern;
					Matcher matcher;

					final TextView email = (TextView) rootView
							.findViewById(R.id.email);
					pattern = Pattern.compile(EMAIL_PATTERN);
					matcher = pattern.matcher(email.getText());

					// Gets a reference to our "selected" radio button
					AlertDialog.Builder builder1 = new AlertDialog.Builder(
							rootView.getContext());
					if (!matcher.matches()) {
						msg.append("Please fix your email!\n");
						hasErros = true;
					} else if (selected == -1) {
						msg.append("Please select yout country!\n");
						hasErros = true;
					} else if (!eula.isChecked()) {
						msg.append("Please read and agree with EULA!\n");
						hasErros = true;
					} else {

						RadioButton b = (RadioButton) getActivity()
								.findViewById(selected);

						builder1.setMessage("Loading profile!" + b.getText());

						passwd = (TextView) rootView
								.findViewById(R.id.password12);
						url = MAIN_URL + "?login=" + email.getText()
								+ "&passwd=" + passwd.getText()
								+ "&proficiency=" + b.getText();

						// inicia o email e a senha nature
						MY_PROFILE.setPassWd(passwd.getText().toString());
						MY_PROFILE.setPassWd(email.getText().toString());
						MY_PROFILE.setNature(b.getText().toString());

					}

					if (hasErros) {
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
					} else {
						dialog.setMessage("Loading...");
						dialog.show();
						new LoginAction().execute(url);
						builder1.setMessage("Loading profile!");

					}

				} catch (Exception ex) {
					ex.printStackTrace();
					// .setText(ex.getMessage());
				}

			}
		});
		return rootView;
	}

	class LoginAction extends AsyncTask<String, Void, String> {

		protected String doInBackground(String... urls) {
			// Creating new JSON Parser
			URLParser jParser = new URLParser();

			// Getting JSON from URL
			String json1 = null;
			try {
				json1 = jParser.getStringFromUrl(urls[0]);

			} catch (Exception e) {
				// TODO Auto-generated catch block
				return e.toString();
			}
			// JSONObject json2 = jParser.getJSONFromUrl(url2);

			return json1;
		}

		@Override
		protected void onPostExecute(String result) {
			// TODO Auto-generated method stub
			
			MY_PROFILE.setJson(result);

			try {
				JSONObject js = MY_PROFILE.fromJson();
				if (js.has("error")) {

					dialog.setMessage("Sorry. try again later.");

				} else {
					
					
					
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
					MY_PROFILE.setPassWd(passwd.getText().toString());
					MY_PROFILE.setError(null);
					//Email existe e senha não bate.......
					if(js.has(C_PASSWD_ERROR)){
						MY_PROFILE.setError(js.getString(C_PASSWD_ERROR));
					}
					MY_PROFILE.setAuthenticated(true);

					
				}

			} catch (Exception e) {
				dialog.setMessage("Sorry. try again later.(" + e.getMessage()
						+ ")");
			} finally {
				//Usuario e ou senha invalidos
				if(MY_PROFILE.getError()!=null){//usuario e ou senha nao batem....
					MY_PROFILE.setAuthenticated(false);//NAO LOGADO!
					builder2.setMessage(MY_PROFILE.getError());
					builder2.setCancelable(true);
					builder2.setNegativeButton("OK",
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog, int id) {
									dialog.cancel();
								}
							});

					AlertDialog alert11 = builder2.create();
					alert11.show();
				}else{
					//liga para o sipserver
					CSIPService.getInstance(getActivity(), MY_PROFILE);
					//Abre janela do perfil
					if(MY_PROFILE.getId().equals("-1")){
						MAINWINDOW.displayView(1);
					}else{
						MAINWINDOW.displayView(2);
					}
					
				}
				
			
				//Fecha loading
				dialog.dismiss();

			}
			super.onPostExecute(result);
		}

	}
}