package br.com.morettotic.viewmenu.action;

import android.app.Activity;
import android.os.AsyncTask;
import br.com.morettotic.entity.Profile;
import br.com.morettotic.viewmenu.utils.URLParser;

public class DefaultAction extends AsyncTask<String, Void, String> { 

	private String myAction = "";
	private Activity myActivity;
	
	public DefaultAction(String myAction){
		this.myAction = myAction;
	}
	public DefaultAction(){
		
	}
	
	public void setStatusAction(String id,String status){
		myAction = Profile.MAIN_URL;
		myAction+= "?action=STATUS&id_user="+id;
		myAction+= "&online="+status;
	}
	
	public void execute(){
		execute("");
	}
	
	protected String doInBackground(String... urls) {
		// Creating new JSON Parser
		URLParser jParser = new URLParser();

		// Getting JSON from URL
		String json1 = null;
		try {
			json1 = jParser.getStringFromUrl(myAction);

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

		
		super.onPostExecute(result);
	}

	public Activity getMyActivity() {
		return myActivity;
	}

	public void setMyActivity(Activity myActivity) {
		this.myActivity = myActivity;
	}

}

