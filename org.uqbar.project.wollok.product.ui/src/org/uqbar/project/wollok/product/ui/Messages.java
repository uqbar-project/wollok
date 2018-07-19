package org.uqbar.project.wollok.product.ui;

import java.util.Properties;

import org.eclipse.osgi.util.NLS;
import org.uqbar.project.wollok.utils.WNLS;

/**
 * Holds keys for all i18nized texts.
 * Check for messages.properties file
 * 
 * @author dodain
 */
public class Messages extends NLS {
	private static final String BUNDLE_NAME = WollokProductActivator.PLUGIN_ID + ".messages";

	public static String AUTO_BUILD_JOB_TITLE;

	static {
		// initialize resource bundle
		NLS.initializeMessages(BUNDLE_NAME, Messages.class);
	}
	
	public static Properties loadProperties() { return WNLS.load(BUNDLE_NAME, Messages.class); }

	private Messages() { }

}
