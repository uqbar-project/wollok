package org.uqbar.project.wollok.typesystem;

import java.util.Properties;

import org.eclipse.osgi.util.NLS;
import org.uqbar.project.wollok.utils.WNLS;

public class Messages extends NLS {
	private static final String BUNDLE_NAME = "org.uqbar.project.wollok.typesystem.messages"; //$NON-NLS-1$

	// ****************************
	// ** Type system preference page
	// ****************************

	public static String WollokTypeSystem_INFO_DESCRIPTION;
	public static String WollokTypeSystem_WARN_DESCRIPTION;
	public static String WollokTypeSystem_ERROR_DESCRIPTION;

	
	static {
		// initialize resource bundle
		NLS.initializeMessages(BUNDLE_NAME, Messages.class);
	}
	
	public static Properties loadProperties() { return WNLS.load(BUNDLE_NAME, Messages.class); }

	private Messages() {
	}

}
