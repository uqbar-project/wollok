package org.uqbar.project.wollok.ui.launch;

import java.net.MalformedURLException;
import java.net.URL;

import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;
import org.uqbar.project.wollok.launch.WollokLauncherException;
import org.uqbar.project.wollok.ui.tests.WollokTestResultView;
import org.uqbar.project.wollok.ui.tests.WollokTestsResultListener;

/**
 * The activator class controls the plug-in life cycle
 */
public class Activator extends AbstractUIPlugin {
	public static final String LAUNCHER_PLUGIN_ID = "org.uqbar.project.wollok.launch";
	public static final String PLUGIN_ID = "org.uqbar.project.wollok.ui.launch";
	private static Activator plugin;
	
	private WollokTestResultView wollokTestResultView;
	private WollokTestsResultListener wollokTestsResultListener;
	
	public WollokTestResultView getWollokTestResultView() {
		return wollokTestResultView;
	}

	public void setWollokTestResultView(WollokTestResultView wollokTestResultView) {
		this.wollokTestResultView = wollokTestResultView;
	}

	public void start(BundleContext context) throws Exception {
		super.start(context);
		plugin = this;
		wollokTestsResultListener = new WollokTestsResultListener();
	} 

	public void stop(BundleContext context) throws Exception {
		plugin = null;
		super.stop(context);
		wollokTestsResultListener.close();
	}

	public static Activator getDefault() {
		return plugin;
	}
	
	public WollokTestsResultListener getWollokTestsResultListener() {
		return wollokTestsResultListener;
	}
	
	public ImageDescriptor getImageDescriptor(String name) {
		try {
			URL u = new URL(getDescriptor().getInstallURL(), name);
			return ImageDescriptor.createFromURL(u);
		}
		catch (MalformedURLException e) {
			throw new WollokLauncherException("Error while loading image [" + name + "]", e);
		}
	}

}
