package br.com.morettotic.entity;

import java.io.Serializable;
import java.util.UUID;

import org.json.JSONException;
import org.json.JSONObject;

public class Profile implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public static final String C_ID = "id_user";
	public static final String C_EMAIL = "email";
	public static final String C_NAME = "name";
	public static final String C_BIRTH = "birthday";
	public static final String C_PAYPALL = "paypall_acc";
	public static final String C_CREDITS = "credits";
	public static final String C_NATURE = "nature";
	public static final String C_PROFICIENCY = "proficiency";
	public static final String C_AVATAR = "avatar";
	public static final String C_MESSAGE = "message";
	public static final String C_ROLE = "role";
	public static final String C_PASSWD = "passwd";
	public static final String MAIN_URL = "http://www.seenergia.com.br/babel_json_services/";//"http://www.nosnaldeia.com.br/babel_json_services/";
	public static final String AVATAR = "libs/avatars/resized_";
	public static final String C_SIP_SERVER = "serverName";
	public static final String C_SIP_USER = "user";
	public static final String C_SIP_PASS = "pass";
	public static final String C_ID_TRANSLATOR = "id_translator";
	public static final String C_TRANSLATOR = "translator_name";
	public static final String C_PASSWD_ERROR = "passWdError";
	public static final String BIRTH = "birthday";
	public static final String UPLOAD_CONFIG = "libs/upload.config.php";
	public static final String SIP_USER_TRANSLATOR = "sip_user_t";
	public static final String CALL_TOKEN = "call_token";
	public static final String C_TRANSLATOR_AVATAR = "translator_avatar";
	public static final String C_USER_AVATAR = "user_avatar";
	public static final String FINISH_CONF = "?action=FINISH_PROFILE&token=";
	

	private String json;

	private String error;
	private String id = "-1";
	private String email = "";
	private String name = "";
	private String birth = "";
	private String paypallAcc = "";
	private String proficiency = "PT";
	private String nature = "1";
	private String credits = "0";
	private String avatar;
	private String roleId = "1";
	private String passWd = "";
	private String sipUser;
	private String sipPass;
	private String sipServ;
	private boolean isAuthenticated = false;
	private String sipTranslatorU;
	private String callToken;
	private String userAvatar,translatorAvatar;
	
	
	private String translatorId,translatorName;
	
	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getBirth() {
		return birth;
	}

	public void setBirth(String birth) {
		this.birth = birth;
	}

	public String getPaypallAcc() {
		return paypallAcc;
	}

	public void setPaypallAcc(String paypallAcc) {
		this.paypallAcc = paypallAcc;
	}

	public String getJson() {
		try {
			int initPos = json.indexOf('{');
			int strSize = json.length();
			return json.substring(initPos, strSize);
		} catch (Exception e) {
			return "{'error':'" + e.getMessage() + "'}";
		}
	}

	public void setJson(String json) {
		this.json = json;
	}

	public String getProficiency() {
		return proficiency;
	}

	public void setProficiency(String proficiency) {
		this.proficiency = proficiency;
	}

	public String getNature() {
		return nature;
	}

	public void setNature(String nature) {
		this.nature = nature;
	}

	public String getCredits() {
		return credits;
	}

	public void setCredits(String credits) {
		this.credits = credits;
	}

	public String getAvatar() {
		return avatar;
	}

	public void setAvatar(String avatar) {
		this.avatar = avatar;
	}

	public String getRoleId() {
		return roleId;
	}

	public void setRoleId(String roleId) {
		this.roleId = roleId;
	}

	public String getSipUser() {
		return sipUser;
	}

	public void setSipUser(String sipUser) {
		this.sipUser = sipUser;
	}

	public String getSipPass() {
		return sipPass;
	}

	public void setSipPass(String sipPass) {
		this.sipPass = sipPass;
	}

	public String getSipServ() {
		return sipServ;
	}

	public void setSipServ(String sipServ) {
		this.sipServ = sipServ;
	}

	public String getPassWd() {
		return passWd;
	}

	public void setPassWd(String passWd) {
		this.passWd = passWd;
	}
	
	public JSONObject fromJson() throws JSONException{
		return new JSONObject(getJson());
	}

	public boolean isAuthenticated() {
		return isAuthenticated;
	}

	public void setAuthenticated(boolean isAuthenticated) {
		this.isAuthenticated = isAuthenticated;
	}

	public String getTranslatorId() {
		return translatorId;
	}

	public void setTranslatorId(String translatorId) {
		this.translatorId = translatorId;
	}

	public String getTranslatorName() {
		return translatorName;
	}

	public void setTranslatorName(String translatorName) {
		this.translatorName = translatorName;
	}

	public String getError() {
		return error;
	}

	public void setError(String error) {
		this.error = error;
	}

	public String getSipTranslatorU() {
		return sipTranslatorU;
	}

	public void setSipTranslatorU(String sipTranslatorU) {
		this.sipTranslatorU = sipTranslatorU;
	}

	public String getCallToken() {
		return callToken;
	}

	public void setCallToken(String callToken) {
		this.callToken = callToken;
	}

	public String getUserAvatar() {
		return userAvatar;
	}

	public void setUserAvatar(String userAvatar) {
		this.userAvatar = userAvatar;
	}

	public String getTranslatorAvatar() {
		return translatorAvatar;
	}

	public void setTranslatorAvatar(String translatorAvatar) {
		this.translatorAvatar = translatorAvatar;
	}

}
