package br.com.morettotic.sip;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.database.Cursor;
import android.net.Uri;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;
import br.com.morettotic.entity.Profile;
import br.com.morettotic.viewmenu.MainActivity;

import com.csipsimple.api.ISipService;
import com.csipsimple.api.SipCallSession;
import com.csipsimple.api.SipConfigManager;
import com.csipsimple.api.SipManager;
import com.csipsimple.api.SipProfile;
import com.csipsimple.api.SipProfileState;
import com.csipsimple.service.SipService;
import com.csipsimple.ui.incall.IOnCallActionTrigger;

/**
 * Ligação com o SipService, deve ser a ponte entre as duas app
 * 
 * @author george
 * 
 */
public class CSIPService {

	public enum DirecaoChamada {
		ENTRADA, SAIDA
	};

	private static final String THIS_FILE = "CSIPService";
	private static String usuario = "translator_pt_en";
	private static String servidorSIP = "ekiga.net";
	private static String senha = "translator_pt_en";
	private static String destino = "CS00016929@sps6.commcorp.com.br";
	private Long idConexaoSIP = SipProfile.INVALID_ID;
	private ISipService service;
	private boolean serviceCSIPConectado;
	private boolean usuarioSIPLogado;
	private Activity activity;
	private ServiceConnection connection;
	private static Profile myProfile;
	private static Object callMutex = new Object();
	private static SipCallSession[] callsInfo = null;
	private IOnCallActionTrigger onTriggerListener;
	private boolean chamadaEmAndamento;
	private DirecaoChamada direcaoChamada;

	private static CSIPService instance;

	public ServiceConnection getConnection() {
		return connection;
	}

	public static void setDestino(String sName, String uName) {
		destino = uName + "@" + sName;
		// destino = uName;
	}

	private BroadcastReceiver listenerChamada = new BroadcastReceiver() {

		@Override
		public void onReceive(Context context, Intent intent) {
			try {
				String action = intent.getAction();

				if (action.equals(SipManager.ACTION_SIP_CALL_CHANGED)) {
					Log.d(THIS_FILE, "onReceive ACTION_SIP_CALL_CHANGED");
					SipCallSession[] chamadas = service.getCalls();
					SipCallSession chamadaAtual = chamadas[chamadas.length - 1];
					if (chamadaAtual.getCallState() == SipCallSession.InvState.DISCONNECTED) {
						Log.d(THIS_FILE,
								"DISCONNECTED - estado tratado desligado");
						chamadaEmAndamento = false;
						((MainActivity) activity).displayView(2);
					} else if (chamadaAtual.getCallState() == SipCallSession.InvState.EARLY) {
						Log.d(THIS_FILE, "EARLY - estado tratado atendendo");
						if (!chamadaEmAndamento) {
							((MainActivity) activity).displayView(3);
							chamadaEmAndamento = true;
							direcaoChamada = DirecaoChamada.ENTRADA;
						}
					}
				} else {
					Log.d(THIS_FILE, "onReceive else");
				}
			} catch (RemoteException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	};

	public static CSIPService getInstance(Activity a, Profile p) {
		myProfile = p;
		usuario = myProfile.getSipUser();
		servidorSIP = myProfile.getSipServ();
		senha = myProfile.getSipPass();

		if (CSIPService.instance == null) {
			CSIPService.instance = new CSIPService(a);

		}
		//SipCallSession initialSession = a.getIntent().getParcelableExtra(
				//SipManager.EXTRA_CALL_INFO);

		/*synchronized (callMutex) {
			callsInfo = new SipCallSession[1];
			callsInfo[0] = initialSession;
		}*/

		((MainActivity) a).bindService(new Intent(a, SipService.class),instance);

		return CSIPService.instance;
		// return null;
	}

	private CSIPService(Activity a) {
		this.activity = a;
		connection = new ServiceConnection() {

			@Override
			public void onServiceConnected(ComponentName arg0, IBinder arg1) {
				service = ISipService.Stub.asInterface(arg1);
				Cursor cursor = activity.getContentResolver().query(
						SipProfile.ACCOUNT_URI,
						new String[] { SipProfile.FIELD_ID,
								SipProfile.FIELD_ACC_ID,
								SipProfile.FIELD_REG_URI }, null, null,
						SipProfile.FIELD_PRIORITY + " ASC");
				if (cursor != null) {
					try {
						if (cursor.moveToFirst()) {
							SipProfile foundProfile = new SipProfile(cursor);
							idConexaoSIP = foundProfile.id;
							SipProfileState sipProfileState = service
									.getSipProfileState(idConexaoSIP.intValue());
							if (sipProfileState != null) {
								usuarioSIPLogado = sipProfileState.isActive()
										&& sipProfileState.isValidForCall()
										&& sipProfileState.isAddedToStack();
							}
						}
					} catch (Exception e) {
						Log.e(THIS_FILE, "Problemas pegando conta existente", e);
					} finally {
						cursor.close();
					}

				}
				if (!usuarioSIPLogado) {
					idConexaoSIP = SipProfile.INVALID_ID;
					autenticaServidor();
				} else {
					serviceCSIPConectado = true;
				}
			}

			public void onServiceDisconnected(ComponentName arg0) {
				serviceCSIPConectado = false;
			}
		};
		this.activity.bindService(new Intent(this.activity, SipService.class),
				connection, Context.BIND_AUTO_CREATE);
	}

	private void autenticaServidor() {
		SipConfigManager.setPreferenceStringValue(this.activity,
				SipConfigManager.LOG_LEVEL, "3");
		SipConfigManager.setPreferenceBooleanValue(this.activity,
				SipConfigManager.USE_WIFI_IN, true);
		SipConfigManager.setPreferenceBooleanValue(this.activity,
				SipConfigManager.USE_WIFI_OUT, true);
		SipConfigManager.setPreferenceBooleanValue(this.activity,
				SipConfigManager.USE_3G_IN, true);
		SipConfigManager.setPreferenceBooleanValue(this.activity,
				SipConfigManager.USE_3G_OUT, true);
		SipConfigManager.setPreferenceBooleanValue(this.activity,
				SipConfigManager.USE_GPRS_IN, true);
		SipConfigManager.setPreferenceBooleanValue(this.activity,
				SipConfigManager.USE_GPRS_OUT, true);
		SipConfigManager.setPreferenceBooleanValue(this.activity,
				SipConfigManager.USE_EDGE_IN, true);
		SipConfigManager.setPreferenceBooleanValue(this.activity,
				SipConfigManager.USE_EDGE_OUT, true);
		SipConfigManager.setPreferenceBooleanValue(this.activity,
				SipConfigManager.INTEGRATE_WITH_DIALER, false);
		SipProfile sipProfile = new SipProfile();
		sipProfile.display_name = "LigacaoCSIP";
		sipProfile.id = idConexaoSIP;
		sipProfile.acc_id = "<sip:" + usuario + "@" + servidorSIP + ">";
		sipProfile.reg_uri = "sip:" + servidorSIP;
		sipProfile.realm = "*";
		sipProfile.username = usuario;
		sipProfile.data = senha;
		sipProfile.proxies = new String[] { "sip:" + servidorSIP };

		ContentValues contentValues = sipProfile.getDbContentValues();

		if (idConexaoSIP != SipProfile.INVALID_ID) {
			this.activity.getContentResolver().update(
					ContentUris.withAppendedId(SipProfile.ACCOUNT_ID_URI_BASE,
							idConexaoSIP), contentValues, null, null);
		} else {
			Uri savedUri = this.activity.getContentResolver().insert(
					SipProfile.ACCOUNT_URI, contentValues);
			if (savedUri != null) {
				idConexaoSIP = ContentUris.parseId(savedUri);
			}
		}
		Intent it = new Intent(SipManager.INTENT_SIP_SERVICE);
		it.putExtra(SipManager.EXTRA_OUTGOING_ACTIVITY, new ComponentName(
				this.activity, this.activity.getClass()));
		this.activity.startService(it);
		serviceCSIPConectado = true;
		this.activity.registerReceiver(listenerChamada, new IntentFilter(
				SipManager.ACTION_SIP_CALL_CHANGED));

	}

	public void ligar() {
		try {
			service.setSpeakerphoneOn(true);
			// service.
			service.makeCall(destino, idConexaoSIP.intValue());
			chamadaEmAndamento = true;
			direcaoChamada = DirecaoChamada.SAIDA;
		} catch (RemoteException e) {
			Log.e(THIS_FILE, "Erro ao ligar", e);
		}
	}

	public void ligar(String pdestino) {
		destino = pdestino;
		ligar();
	}

	public boolean desligar() {
		try {
			SipCallSession[] chamadas = this.service.getCalls();
			SipCallSession chamadaAtual = chamadas[chamadas.length - 1];
			chamadaEmAndamento = false;
			return service.hangup(chamadaAtual.getCallId(), 0) == SipManager.SUCCESS;
		} catch (RemoteException e) {
			Log.e(THIS_FILE, "Erro ao ligar", e);
		}
		return false;
	}

	public void atender() {
		try {
			SipCallSession[] chamadas = this.service.getCalls();
			SipCallSession chamadaAtual = chamadas[chamadas.length - 1];
			service.answer(chamadaAtual.getCallId(),
					SipCallSession.StatusCode.OK);
			chamadaEmAndamento = true;
		} catch (RemoteException e) {
			Log.e(THIS_FILE, "Erro ao ligar", e);
		}
	}

	public void atenderDesligar(SipCallSession chamadaAtual) {
		try {

			if (chamadaAtual.getCallState() == SipCallSession.InvState.CALLING) {
				Log.d(THIS_FILE, "CALLING - estado tratado desligando");
				chamadaEmAndamento = false;
				if (service.hangup(chamadaAtual.getCallId(), 0) == SipManager.SUCCESS) {
					Intent it = new Intent(this.activity.getBaseContext(),
							CSIPService.class);
					this.activity.startActivity(it);
				}
			} else if (chamadaAtual.getCallState() == SipCallSession.InvState.EARLY) {
				Log.d(THIS_FILE, "EARLY - estado tratado atendendo");
				chamadaEmAndamento = true;
				service.answer(chamadaAtual.getCallId(),
						SipCallSession.StatusCode.OK);
			} else if (chamadaAtual.getCallState() == SipCallSession.InvState.CONFIRMED) {
				Log.d(THIS_FILE, "CONFIRMED - estado tratado desligando");
				chamadaEmAndamento = false;
				if (service.hangup(chamadaAtual.getCallId(), 0) == SipManager.SUCCESS) {
					Intent it = new Intent(this.activity, CSIPService.class);
					this.activity.startActivity(it);
				}
			} else if (chamadaAtual.getCallState() == SipCallSession.InvState.DISCONNECTED) {
				Log.d(THIS_FILE,
						"DISCONNECTED - estado tratado voltando para o estado anterior");
				chamadaEmAndamento = false;
				Intent it = new Intent(this.activity.getBaseContext(),
						CSIPService.class);
				this.activity.startActivity(it);
			} else {
				if (chamadaAtual.getCallState() == SipCallSession.InvState.CONNECTING) {
					Log.d(THIS_FILE, "CONNECTING - estado sem tratamento");
				}
				if (chamadaAtual.getCallState() == SipCallSession.InvState.DISCONNECTED) {
					Log.d(THIS_FILE, "DISCONNECTED - estado sem tratamento");
				}
				if (chamadaAtual.getCallState() == SipCallSession.InvState.INCOMING) {
					Log.d(THIS_FILE, "INCOMING - estado sem tratamento");
				}
				if (chamadaAtual.getCallState() == SipCallSession.InvState.CALLING) {
					Log.d(THIS_FILE, "CALLING - estado sem tratamento");
				}
				if (chamadaAtual.getCallState() == SipCallSession.InvState.EARLY) {
					Log.d(THIS_FILE, "EARLY - estado sem tratamento");
				}
				if (chamadaAtual.getCallState() == SipCallSession.InvState.CONFIRMED) {
					Log.d(THIS_FILE, "CONFIRMED - estado sem tratamento");
				}
			}
		} catch (RemoteException e) {
			e.printStackTrace();
		}
	}

	public String getServidorSIP() {
		return servidorSIP;
	}

	public void setServidorSIP(String servidorSIP) {
		this.servidorSIP = servidorSIP;
	}

	public String getSenha() {
		return senha;
	}

	public void setSenha(String senha) {
		this.senha = senha;
	}

	public String getDestino() {
		return destino;
	}

	public void setDestino(String destino) {
		this.destino = destino;
	}

	public Long getIdConexaoSIP() {
		return idConexaoSIP;
	}

	public void setIdConexaoSIP(Long idConexaoSIP) {
		this.idConexaoSIP = idConexaoSIP;
	}

	public boolean isChamadaEmAndamento() {
		return chamadaEmAndamento;
	}

	public void setChamadaEmAndamento(boolean chamadaEmAndamento) {
		this.chamadaEmAndamento = chamadaEmAndamento;
	}

	public DirecaoChamada getDirecaoChamada() {
		return direcaoChamada;
	}

	public void setDirecaoChamada(DirecaoChamada direcaoChamada) {
		this.direcaoChamada = direcaoChamada;
	}

}
