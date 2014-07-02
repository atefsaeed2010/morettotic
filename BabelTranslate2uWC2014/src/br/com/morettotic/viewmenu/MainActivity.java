package br.com.morettotic.viewmenu;

import java.util.ArrayList;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Fragment;
import android.app.FragmentManager;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Configuration;
import android.content.res.TypedArray;
import android.os.Bundle;
import android.support.v4.app.ActionBarDrawerToggle;
import android.support.v4.widget.DrawerLayout;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import br.com.morettotic.entity.Profile;
import br.com.morettotic.navdraw.R;
import br.com.morettotic.sip.CSIPService;
import br.com.morettotic.viewmenu.action.DefaultAction;
import br.com.morettotic.viewmenu.adapter.NavDrawerListAdapter;
import br.com.morettotic.viewmenu.model.NavDrawerItem;

@SuppressLint("NewApi")
public class MainActivity extends Activity {
	public static Profile MY_PROFILE = new Profile();
	private DrawerLayout mDrawerLayout;
	private ListView mDrawerList;
	private ActionBarDrawerToggle mDrawerToggle;
	public static MainActivity MAINWINDOW;
	// NavigationDrawer title "Nasdaq" in this example
	private CharSequence mDrawerTitle;
	private String locale;
	// App title "Navigation Drawer" in this example
	private CharSequence mTitle;
	private Fragment fragment = null;
	// slider menu items details
	private String[] navMenuTitles;
	private TypedArray navMenuIcons;

	private ArrayList<NavDrawerItem> navDrawerItems;
	private NavDrawerListAdapter adapter;

	// Open a fragment
	public void openFragment(int posView) {
		displayView(posView);
	}

	public void bindService(Intent i, CSIPService c) {
		bindService(i, c.getConnection(), Context.BIND_AUTO_CREATE);
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		MAINWINDOW = this;

		// No network avaliable

		// bindService(new Intent(this, SipService.class), connection,
		// Context.BIND_AUTO_CREATE);

		locale = this.getResources().getConfiguration().locale.getDisplayName();
		System.out.println(locale);
		mTitle = mDrawerTitle = getTitle();

		// getting items of slider from array Navigation Drawer
		navMenuTitles = getResources().getStringArray(R.array.nav_drawer_items);

		// getting Navigation drawer icons from res icon_home
		navMenuIcons = getResources()
				.obtainTypedArray(R.array.nav_drawer_icons);

		mDrawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
		mDrawerList = (ListView) findViewById(R.id.list_slidermenu);

		navDrawerItems = new ArrayList<NavDrawerItem>();

		// list item in slider at 1 Login
		navDrawerItems.add(new NavDrawerItem("Login", R.drawable.ic_login));
		// list item in slider at 2 Profile
		navDrawerItems.add(new NavDrawerItem("Profile", R.drawable.ic_profile));

		// list item in slider at 3 Conference
		navDrawerItems.add(new NavDrawerItem("Translate",
				R.drawable.ic_translatetou));
		// list item in slider at 3 Conference
		navDrawerItems.add(new NavDrawerItem("Conference",
				R.drawable.ic_conference));

		//navDrawerItems.add(new NavDrawerItem("Configurations",
		//		R.drawable.ic_config));
		//navDrawerItems.
		navDrawerItems.add(new NavDrawerItem("Coins",
				R.drawable.ic_payment));

		navDrawerItems.add(new NavDrawerItem("Exit", R.drawable.ic_exit));

		// Recycle array
		navMenuIcons.recycle();

		mDrawerList.setOnItemClickListener(new SlideMenuClickListener());

		// setting list adapter for Navigation Drawer
		adapter = new NavDrawerListAdapter(getApplicationContext(),
				navDrawerItems);
		mDrawerList.setAdapter(adapter);

		// Enable action bar icon_luncher as toggle Home Button
		getActionBar().setDisplayHomeAsUpEnabled(true);
		getActionBar().setHomeButtonEnabled(true);

		mDrawerToggle = new ActionBarDrawerToggle(this, mDrawerLayout,
				R.drawable.ic_drawer, R.string.app_name, R.string.app_name) {

			public void onDrawerClosed(View view) {
				getActionBar().setTitle(mTitle);
				invalidateOptionsMenu(); // Setting, Refresh and Rate App
			}

			public void onDrawerOpened(View drawerView) {
				getActionBar().setTitle(mDrawerTitle);
				invalidateOptionsMenu();
			}
		};
		mDrawerLayout.setDrawerListener(mDrawerToggle);

		if (savedInstanceState == null) {
			displayView(0);
		}

	}

	/**
	 * Slider menu item click listener
	 * */
	private class SlideMenuClickListener implements
			ListView.OnItemClickListener {
		@Override
		public void onItemClick(AdapterView<?> parent, View view, int position,
				long id) {
			// display view for selected item
			displayView(position);
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// title/icon
		if (mDrawerToggle.onOptionsItemSelected(item)) {
			return true;
		}
		// Handle action bar actions click
		switch (item.getItemId()) {
		case R.id.action_rate:
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}

	// called when invalidateOptionsMenu() invoke

	@Override
	public boolean onPrepareOptionsMenu(Menu menu) {
		// if Navigation drawer is opened, hide the action items
		boolean drawerOpen = mDrawerLayout.isDrawerOpen(mDrawerList);
		menu.findItem(R.id.action_rate).setVisible(!drawerOpen);
		return super.onPrepareOptionsMenu(menu);
	}

	public void displayView(int position) {
		try {
			// update the main content with called Fragment
			switch (position) {
			case 0:
				fragment = new FragmentLogin();
				break;
			case 1:
				fragment = new FragmentProfile();
				break;
			case 2:
				double credits = Float.parseFloat(MY_PROFILE.getCredits());
				// Nao possui creditos meu amigo vai comprar (é usuario)!!!!!!
				if (credits < 1&&MY_PROFILE.getRoleId().equals("1")) {
					displayView(4);
				} else {
					fragment = new FragmentCountries();
				}
				break;
			// nunca passa aqui se nao tiver acesso a tela de chamadas e tiver
			// comprado creditos!
			case 3:// Se nao tiver destinatario nao pode abrir tela de chamada!
				if (MY_PROFILE.getRoleId().equals("1")
						&& (MY_PROFILE.getSipTranslatorU() == null || MY_PROFILE
								.getSipTranslatorU().equals("null"))) {
					displayView(2);
				} else {
					fragment = new FragmentConference();
				}
				break;
			/*case 4:
				fragment = new FragmentUpload();
				break;*/
			case 4:
				fragment = new FragmentPaypal();
				break;
			case 5:
				destroy();
				break;
			default:
				break;
			}
			// Se o perfil nao tiver informacoes abre o login sempre!!!!!!
			if ((MY_PROFILE.getEmail().equals("") && MY_PROFILE.getPassWd()
					.equals("")) || !MY_PROFILE.isAuthenticated()) {
				fragment = new FragmentLogin();
			}
			if (fragment != null) {
				FragmentManager fragmentManager = getFragmentManager();
				fragmentManager.beginTransaction()
						.replace(R.id.frame_container, fragment).commit();
				mDrawerList.setItemChecked(position, true);
				mDrawerList.setSelection(position);
				setTitle(navMenuTitles[position]);
				mDrawerLayout.closeDrawer(mDrawerList);
			} else {

				Log.e("this is mainActivity", "Error in else case");
			}
		} catch (Exception e) {
			AlertDialog.Builder builder1 = new AlertDialog.Builder(
					this.getApplicationContext());
			builder1.setMessage("Please try again later!" + e.toString());
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
	}

	private void destroy() {
		AlertDialog.Builder adb = new AlertDialog.Builder(this);

		adb.setTitle("Exit?");
		//adb.setIcon(R.drawable.ic_exit);

		adb.setPositiveButton("OK", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {

				CSIPService.destroy();
				DefaultAction da = new DefaultAction();
				da.setStatusAction(MY_PROFILE.getId(), "EXIT");
				da.execute();

				try {
					Thread.sleep(5000);
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					// e.printStackTrace();
				}
				MY_PROFILE = null;
				// MAINWINDOW.finish();
				System.exit(0);
			}
		});

		adb.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				displayView(2);
			}
		});
		adb.show();

	}

	@Override
	public void setTitle(CharSequence title) {
		mTitle = title;
		getActionBar().setTitle(mTitle);
	}

	@Override
	protected void onPostCreate(Bundle savedInstanceState) {
		super.onPostCreate(savedInstanceState);
		mDrawerToggle.syncState();
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
		mDrawerToggle.onConfigurationChanged(newConfig);
	}

}
