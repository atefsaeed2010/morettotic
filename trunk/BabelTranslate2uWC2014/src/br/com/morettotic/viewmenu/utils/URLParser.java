package br.com.morettotic.viewmenu.utils;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.InetAddress;
import java.net.URL;
import java.net.URLEncoder;
import java.net.UnknownHostException;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;
import android.view.View;

public class URLParser {
	
	public static int TYPE_WIFI = 1;
	public static int TYPE_MOBILE = 2;
	public static int TYPE_NOT_CONNECTED = 0;
	static InputStream is = null;
	String ret = "trash";
	static String json = "";
	int serverResponseCode = 0;

	// constructor
	public URLParser() {
	}
	
	public static final void sendEmailIntent(String txt, Activity a){
		Intent intent = new Intent(Intent.ACTION_SEND);
		intent.setType("text/html");
		intent.putExtra(Intent.EXTRA_EMAIL, "malacma@gmail.com");
		intent.putExtra(Intent.EXTRA_SUBJECT, "ERRO");
		intent.putExtra(Intent.EXTRA_TEXT, "I'm email body.");

		a.startActivity(Intent.createChooser(intent, "Send Email"));
	}
	
	public int uploadFile(String caminhoImagem, String caminhoServidor,final View rootView) {
		String uploadFile = caminhoImagem;

		HttpURLConnection conn = null;
		DataOutputStream dos = null;
		String lineEnd = "\r\n";
		String twoHyphens = "--";
		String boundary = "*****";
		int bytesRead, bytesAvailable, bufferSize;
		byte[] buffer;
		int maxBufferSize = 1 * 1024 * 1024;
		File sourceFile = new File(caminhoImagem);

		if (!sourceFile.isFile()) {

			//dialog.dismiss();

			Log.e("uploadFile", "Source File not exist :" + uploadFile);

			new Thread(new Runnable() {
				public void run() {
					//messageText.setText("Source File not exist :" + uploadFile);
				}
			}).start();

			return 0;

		} else {
			try {

				// open a URL connection to the Servlet
				FileInputStream fileInputStream = new FileInputStream(
						sourceFile);
				URL url = new URL(caminhoServidor);

				// Open a HTTP connection to the URL
				conn = (HttpURLConnection) url.openConnection();
				conn.setDoInput(true);
				conn.setDoOutput(true);
				conn.setUseCaches(false);
				conn.setRequestMethod("POST");
				conn.setRequestProperty("Connection", "Keep-Alive");
				conn.setRequestProperty("ENCTYPE", "multipart/form-data");
				conn.setRequestProperty("Content-Type",
						"multipart/form-data;boundary=" + boundary);
				conn.setRequestProperty("uploaded_file", caminhoImagem);

				dos = new DataOutputStream(conn.getOutputStream());

				dos.writeBytes(twoHyphens + boundary + lineEnd);
				dos.writeBytes("Content-Disposition: form-data; name=\"uploaded_file\";filename=\""
						+ caminhoImagem + "\"" + lineEnd);

				dos.writeBytes(lineEnd);

				// create a buffer of maximum size
				bytesAvailable = fileInputStream.available();

				bufferSize = Math.min(bytesAvailable, maxBufferSize);
				buffer = new byte[bufferSize];

				// read file and write it into form...
				bytesRead = fileInputStream.read(buffer, 0, bufferSize);

				while (bytesRead > 0) {

					dos.write(buffer, 0, bufferSize);
					bytesAvailable = fileInputStream.available();
					bufferSize = Math.min(bytesAvailable, maxBufferSize);
					bytesRead = fileInputStream.read(buffer, 0, bufferSize);

				}

				// send multipart form data necesssary after file data...
				dos.writeBytes(lineEnd);
				dos.writeBytes(twoHyphens + boundary + twoHyphens + lineEnd);

				// Responses from the server (code and message)
				serverResponseCode = conn.getResponseCode();
				String serverResponseMessage = conn.getResponseMessage();

				Log.i("uploadFile", "HTTP Response is : "
						+ serverResponseMessage + ": " + serverResponseCode);

				if (serverResponseCode == 200) {

					/*new Thread(new Runnable() {
						public void run() {

							String msg = "File Upload Completed.";

							//messageText.setText(msg);
							Toast.makeText(rootView.getContext(),
									"File Upload Complete.", Toast.LENGTH_SHORT)
									.show();
						}
					}).start();*/
				}

				// close the streams //
				fileInputStream.close();
				dos.flush();
				dos.close();

			} catch (Exception e) {

				//dialog.dismiss();
				e.printStackTrace();

				/*new Thread(new Runnable() {
					public void run() {
						//messageText.setText("Got Exception : see logcat ");
						//Toast.makeText(rootView.getContext(),
								"Got Exception : see logcat ",
								Toast.LENGTH_SHORT).show();
					}
				}).start();*/
				Log.e("Upload file to server Exception",
						"Exception : " + e.getMessage(), e);
			}
			//dialog.dismiss();
			return serverResponseCode;

		}
	}

	public String getStringFromUrl(String url) throws Exception {
		// Making HTTP request
		try {
			// defaultHttpClient
			//String encodedUrl = URLEncoder.encode(url, "UTF-8");
			DefaultHttpClient httpClient = new DefaultHttpClient();
			HttpPost httpPost = new HttpPost(url);
			HttpResponse httpResponse = httpClient.execute(httpPost);
			HttpEntity httpEntity = httpResponse.getEntity();
			is = httpEntity.getContent();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} catch (ClientProtocolException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		try {
			BufferedReader reader = new BufferedReader(new InputStreamReader(
					is, "iso-8859-1"), 8);
			StringBuilder sb = new StringBuilder();
			String line = null;
			while ((line = reader.readLine()) != null) {
				sb.append(line + "n");
			}
			is.close();
			ret = sb.toString();
					
			int finishAt = ret.lastIndexOf("}");
			ret = ret.substring(0, ++finishAt);
					
			return ret.trim();
		} catch (Exception e) {
			return e.toString();
		}
	}

	public JSONObject jsonFromUrl() throws JSONException {
		return new JSONObject(ret);
	}
	

	public static int getConnectivityStatus(Context context) {
		ConnectivityManager cm = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);

		NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
		if (null != activeNetwork) {
			if (activeNetwork.getType() == ConnectivityManager.TYPE_WIFI)
				return TYPE_WIFI;

			if (activeNetwork.getType() == ConnectivityManager.TYPE_MOBILE)
				return TYPE_MOBILE;
		}
		return TYPE_NOT_CONNECTED;
	}

	public static String getConnectivityStatusString(Context context) {
		int conn = getConnectivityStatus(context);
		String status = null;
		if (conn == TYPE_WIFI) {
			status = "Wifi enabled";
		} else if (conn == TYPE_MOBILE) {
			status = "Mobile data enabled";
		} else if (conn == TYPE_NOT_CONNECTED) {
			status = "Not connected to Internet";
		}
		return status;
	}
	
	public static boolean isNetworkAvaliable(Context context){
		int ret = getConnectivityStatus(context);
		if(ret==TYPE_NOT_CONNECTED){
			return false;
		}else{
			return true;
		}
	}
}