package br.com.morettotic.viewmenu;

import android.app.Fragment;
import static br.com.morettotic.viewmenu.MainActivity.*;
import static br.com.morettotic.entity.Profile.*;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import br.com.morettotic.navdraw.R;

public class FragmentPaypal extends Fragment {
	private View rootView;
	private WebView web;
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,Bundle savedInstanceState) {
		
		
		rootView = inflater.inflate(R.layout.paypal_fragment,container, false);
		/*AlertDialog.Builder builder1 = new AlertDialog.Builder(MAINWINDOW);
		builder1.setMessage("Buy coins!");
		builder1.setIcon(R.drawable.ic_payment);
		builder1.setCancelable(true);
		builder1.setNegativeButton("OK",
				new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int id) {
						
						dialog.cancel();
						
					}
				});

		//alert11 = builder1.create();
		builder1.show();*/
		
		web = (WebView) rootView.findViewById(R.id.paypallWebView);
		
		//web.setWebChromeClient(new InredisChromeClient(this));
		//web.setWebViewClient(new InredisWebViewClient(this));
		web.clearCache(true);
		web.clearHistory();
		web.getSettings().setJavaScriptEnabled(true);
		web.getSettings().setJavaScriptCanOpenWindowsAutomatically(true);
		web.loadUrl(MAIN_URL + "paypall/?id="+MY_PROFILE.getId());
		
		//Vibra pro amigo comprar moedas
		new br.com.morettotic.viewmenu.utils.Vibrator2u(MainActivity.MAINWINDOW).error();
		
		return rootView;
	}
}
