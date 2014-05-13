package br.com.morettotic.viewmenu.utils;

import android.app.Activity;
import android.content.Context;
import android.os.Vibrator;

public class Vibrator2u {
	private Vibrator v;
	private Activity a1;
	private int dot = 200;      
	private int dash = 500;     
	private int short_gap = 200;    
	private int medium_gap = 500;  
	
	private long[] callButton = {
		    0,  // Start immediately
		    dot
		};
	private long[] switchButtonON = {
		    0,  // Start immediately
		    short_gap, dash, medium_gap
		};
	private long[] switchButtonOFF = {
		    0,  // Start immediately
		    dash, short_gap, dash
		};
	private long[] error = {
		    0,  // Start immediately
		    dash,dash,dash
		};

	
	public void callButton(){
		v.vibrate(callButton, -1);
	}
	
	public void switchButtonON(){
		v.vibrate(switchButtonON, -1);
	}
	public void switchButtonOFF(){
		v.vibrate(switchButtonOFF, -1);
	}
	public void error(){
		v.vibrate(error, -1);
	}
	
	public Vibrator2u(Activity pa){
		this.a1 = pa;
		this.v = (Vibrator) this.a1.getSystemService(Context.VIBRATOR_SERVICE);
	}

}
