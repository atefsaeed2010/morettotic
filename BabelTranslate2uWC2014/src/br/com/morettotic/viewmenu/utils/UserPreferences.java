package br.com.morettotic.viewmenu.utils;

import static br.com.morettotic.viewmenu.MainActivity.MAINWINDOW;
import android.app.Activity;
import android.content.SharedPreferences;
import br.com.morettotic.entity.Profile;
import br.com.morettotic.viewmenu.MainActivity;

public class UserPreferences {
	private static final String PROFILE = "PROFILE";
	private static final String USER = Profile.C_EMAIL;
	private static final String PASS = Profile.C_PASSWD;
	private static final String FROM = Profile.C_NATURE;
	
	
	/**
	 * Salva as preferencias do usuario para facilitar o login
	 * 
	 * */
	public UserPreferences(Activity a, String pUser,String pPass, String pFrom){
		SharedPreferences settingsUser = a.getSharedPreferences(PROFILE, 0);
		      
		SharedPreferences.Editor editorUser = settingsUser.edit();
        
		editorUser.putString(USER, pUser);
		editorUser.putString(PASS, pPass);
		editorUser.putString(FROM, pFrom);
		
        //Confirma a gravação dos dados
		editorUser.commit();
	}
	
	public static final String getEmail(Activity a){
		SharedPreferences settings = a.getSharedPreferences(PROFILE, 0);
        return settings.getString(USER, "");
	}
	
	public static final String getPass(Activity a){
		SharedPreferences settings = a.getSharedPreferences(PROFILE, 0);
        return settings.getString(PASS, "");
	}
	
	public static final String getNature(Activity a){
		SharedPreferences settings = a.getSharedPreferences(PROFILE, 0);
        return settings.getString(FROM, "");
	}

	public static boolean hasProfile(MainActivity mAINWINDOW) {
		// TODO Auto-generated method stub
	
		return UserPreferences.getEmail(MAINWINDOW).equals("")?false:true;
	}
	public static void destroy(MainActivity a){
		SharedPreferences settingsUser = a.getSharedPreferences(PROFILE, 0);
	      
		SharedPreferences.Editor editorUser = settingsUser.edit();
        editorUser.clear();
		
        //Confirma a gravação dos dados
		editorUser.commit();
	}

}
