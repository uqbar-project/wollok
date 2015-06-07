package org.uqbar.project.wollok.lib;

import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

/**
 * The activator class controls the plug-in life cycle
 */
public class WollokLibActivator extends AbstractUIPlugin {
	// The plug-in ID: beware if you change it because wollok core project also has this iD
	public static final String PLUGIN_ID = "org.uqbar.project.wollok.lib"; //$NON-NLS-1$
	private static WollokLibActivator plugin;

	public WollokLibActivator() {
	}

	public void start(BundleContext context) throws Exception {
		super.start(context);
		plugin = this;
	}

	public void stop(BundleContext context) throws Exception {
		plugin = null;
		super.stop(context);
	}

	public static WollokLibActivator getDefault() {
		return plugin;
	}
	
}
