package org.uqbar.project.wollok.launch.repl;

import org.eclipse.osgi.util.NLS;

/**
 * i18n keys for the REPL
 * 
 * @author jfernandes
 */
public class Messages extends NLS {
	private static final String BUNDLE_NAME = "org.uqbar.project.wollok.launch.repl.messages"; //$NON-NLS-1$
	
	public static String Sarasa_0;
	public static String REPL_WELCOME;

	static {
		// initialize resource bundle
		NLS.initializeMessages(BUNDLE_NAME, Messages.class);
	}

	private Messages() {
	}
}
