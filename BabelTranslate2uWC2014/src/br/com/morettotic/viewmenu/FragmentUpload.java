package br.com.morettotic.viewmenu;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

import br.com.morettotic.entity.Profile;
import br.com.morettotic.viewmenu.httputil.URLParser;

import com.vizteck.navigationdrawer.R;

import android.app.Fragment;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import static br.com.morettotic.viewmenu.MainActivity.*;
import static br.com.morettotic.entity.Profile.*;

public class FragmentUpload extends Fragment {
	TextView messageText;
	Button uploadButton;
	Button escolherImagem;

	ProgressDialog dialog = null;
	private static final int SELECT_PICTURE = 1;
	private ImageView imageView;
	String uploadFile = "";
	WebView web;

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {

		final View rootView = inflater.inflate(R.layout.upload_fragment,
				container, false);
		super.onCreate(savedInstanceState);

		dialog = new ProgressDialog(rootView.getContext());

		escolherImagem = (Button) rootView.findViewById(R.id.escolherImagem);
		uploadButton = (Button) rootView.findViewById(R.id.btUpload1);
		messageText = (TextView) rootView.findViewById(R.id.messageText);

		messageText.setText("Uploading file path: " + uploadFile);

		web = (WebView) rootView.findViewById(R.id.webView1);
				
		//?action=AVATAR_VIEW&id_user=1
		
		if (!(MY_PROFILE.getId().equals("")
				&& MY_PROFILE.getId().equals("-1"))) {
			//carrega a imagem do perfil
			web.loadUrl(MAIN_URL + "?action=AVATAR_VIEW&id_user="+MY_PROFILE.getId());
			messageText.setText("");
		}else{
			//carrega a default
			web.loadUrl(MAIN_URL + "libs/avatars/resized_IMG-1381441477-V.jpg");
			messageText.setText("Please upload your avatar!");
		}
		
		
		
		/************* Php script path ****************/
		final String upLoadServerUri = MAIN_URL + UPLOAD_CONFIG;

		escolherImagem.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent intent = new Intent();
				intent.setType("image/*");
				intent.setAction(Intent.ACTION_GET_CONTENT);
				startActivityForResult(
						Intent.createChooser(intent, "Pic your avatar"),
						SELECT_PICTURE);

			}
		});

		uploadButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {

				/*
				 * dialog = ProgressDialog.show(rootView.getContext(), "",
				 * "Uploading imagem...", true);
				 */

				dialog.setMessage("Uploading Avatar..");
				dialog.show();
				new Thread(new Runnable() {
					public void run() {

						// messageText.setText("uploading iniciado.....");
						String a1[] = uploadFile.split("/");
						System.out.print(a1);

						new URLParser().uploadFile(uploadFile, upLoadServerUri,
								rootView);
						
						String image =  a1[a1.length - 1];
						
						web.loadUrl(Profile.MAIN_URL + Profile.AVATAR + image);
						
						if (!(MY_PROFILE.getId().equals("")
								&& MY_PROFILE.getId().equals("-1"))) {
							// Ação para gravar a imagem no perfil.
							// web.loadUrl(
							// Profile.MAIN_URL+"libs/avatars/resized_"+a1[a1.length-1]);
							String url = MAIN_URL+"?action=AVATAR&id_user="+MY_PROFILE.getId()+"&image_path=resized_"+image;
							
							MY_PROFILE.setAvatar("resized_"+image);
							
							web.loadUrl(url);
							
						}

						

						dialog.dismiss();
					}
				}).start();
			}
		});
		return rootView;
	}

	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (resultCode == this.getActivity().RESULT_OK) {
			if (requestCode == SELECT_PICTURE) {
				Uri selectedImageUri = data.getData();
				Log.d("onActivityResult selectedImageUri: ",
						selectedImageUri.getPath());
				uploadFile = getPath(selectedImageUri);
				Log.d("onActivityResult uploadFile: ", uploadFile);
			}
		}
	}

	/**
	 * Retorna URL Fisica da imagem
	 */
	public String getPath(Uri uri) {
		if (uri == null) {
			return null;
		}
		String[] projection = { MediaStore.Images.Media.DATA };
		Cursor cursor = this.getActivity().getContentResolver()
				.query(uri, projection, null, null, null);
		if (cursor != null) {
			int column_index = cursor
					.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
			cursor.moveToFirst();
			return cursor.getString(column_index);
		}
		return uri.getPath();
	}

	/**
	 * Faz o upload da imagem para
	 * 
	 * @param caminhoImagem
	 * @param caminhoServidor
	 * @return
	 */

	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		this.getActivity().getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

	private Drawable ImageOperations(Context ctx, String url,
			String saveFilename) {
		try {
			InputStream is = (InputStream) this.fetch(url);
			Drawable d = Drawable.createFromStream(is, "src");
			return d;
		} catch (MalformedURLException e) {
			return null;
		} catch (IOException e) {
			return null;
		}
	}

	public Object fetch(String address) throws MalformedURLException,
			IOException {
		URL url = new URL(address);
		Object content = url.getContent();
		return content;
	}
}
