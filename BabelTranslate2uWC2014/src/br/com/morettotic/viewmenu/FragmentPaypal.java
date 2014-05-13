package br.com.morettotic.viewmenu;

import android.app.AlertDialog;
import android.app.Fragment;
import android.content.DialogInterface;
import static br.com.morettotic.viewmenu.MainActivity.*;
import static br.com.morettotic.entity.Profile.*;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.Button;
import br.com.morettotic.sip.CSIPService;

import com.vizteck.navigationdrawer.R;

public class FragmentPaypal extends Fragment {
	// this Fragment will be called from MainActivity
	public FragmentPaypal() {
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		
		
		final View rootView = inflater.inflate(R.layout.paypal_fragment,
				container, false);
		AlertDialog.Builder builder1 = new AlertDialog.Builder(
				rootView.getContext());
		builder1.setMessage("Buy some coins to call a translator!");
		builder1.setCancelable(true);
		builder1.setNegativeButton("OK",
				new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int id) {
						
						dialog.cancel();
						
					}
				});

		AlertDialog alert11 = builder1.create();
		alert11.show();
		WebView web = (WebView) rootView.findViewById(R.id.paypallWebView);
		//web.e
		web.loadUrl(MAIN_URL + "paypall/?id="+MY_PROFILE.getId());
		
		return rootView;
	}
}
