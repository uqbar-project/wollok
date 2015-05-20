package org.uqbar.project.wollok.ui.launch;

import java.net.MalformedURLException;
import java.net.URL;

import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;
import org.uqbar.project.wollok.launch.WollokLauncherException;

/**
 * The activator class controls the plug-in life cycle
 */
public class Activator extends AbstractUIPlugin {
	public static final String LAUNCHER_PLUGIN_ID = "org.uqbar.project.wollok.launch";
	public static final String PLUGIN_ID = "org.uqbar.project.wollok.ui.launch";
	private static Activator plugin;
	
	public void start(BundleContext context) throws Exception {
		super.start(context);
		plugin = this;
	}

	public void stop(BundleContext context) throws Exception {
		plugin = null;
		super.stop(context);
	}

	public static Activator getDefault() {
		return plugin;
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
