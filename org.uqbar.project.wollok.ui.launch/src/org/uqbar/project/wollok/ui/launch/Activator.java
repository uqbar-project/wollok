package org.uqbar.project.wollok.ui.launch;

import java.net.MalformedURLException;
import java.net.URL;

import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;
import org.uqbar.project.wollok.launch.WollokLauncherException;
import org.uqbar.project.wollok.ui.internal.WollokDslActivator;
import org.uqbar.project.wollok.ui.tests.WollokTestsResultsListener;
import org.uqbar.project.wollok.ui.tests.model.WollokTestResults;

import com.google.inject.Injector;

/**
 * The activator class controls the plug-in life cycle
 */
public class Activator extends AbstractUIPlugin {
	public static final String LAUNCHER_PLUGIN_ID = "org.uqbar.project.wollok.launch";
	public static final String PLUGIN_ID = "org.uqbar.project.wollok.ui.launch";
	private static Activator plugin;

	private WollokTestsResultsListener wollokTestsResultListener;

	public void start(BundleContext context) throws Exception {
		super.start(context);
		plugin = this;
		wollokTestsResultListener = getInjector().getInstance(WollokTestsResultsListener.class);
	}

	public void stop(BundleContext context) throws Exception {
		plugin = null;
		super.stop(context);
		wollokTestsResultListener.close();
	}

	public ImageDescriptor getImageDescriptor(String name) {
		try {
			URL u = new URL(getDescriptor().getInstallURL(), name);
			return ImageDescriptor.createFromURL(u);
		} catch (MalformedURLException e) {
			throw new WollokLauncherException("Error while loading image ["
					+ name + "]", e);
		}
	}

	public static Activator getDefault() {
		return plugin;
	}

	public WollokTestsResultsListener getWollokTestsResultListener() {
		return wollokTestsResultListener;
	}

	public Integer getWollokTestViewListeningPort() {
		return this.getWollokTestsResultListener().getListeningPort();
	}

	public Injector getInjector(){
		return WollokDslActivator.getInstance().getInjector(WollokDslActivator.ORG_UQBAR_PROJECT_WOLLOK_WOLLOKDSL);
	}
}
