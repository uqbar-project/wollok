package org.uqbar.project.wollok.ui.diagrams;

import java.util.Properties;

import org.eclipse.osgi.util.NLS;
import org.uqbar.project.wollok.utils.WNLS;

public class Messages extends NLS {
	private static final String BUNDLE_NAME = "org.uqbar.project.wollok.ui.diagrams.messages"; //$NON-NLS-1$

	public static String StaticDiagram_Export_Description;
	public static String StaticDiagram_Show_Variables;
	public static String StaticDiagram_RememberShapePositions_Description;
	public static String StaticDiagram_CleanShapePositions_Description;
	public static String StaticDiagram_SaveConfiguration_Description;
	public static String StaticDiagram_LoadConfiguration_Description;
	public static String StaticDiagramOpenFile;
	
	static {
		// initialize resource bundle
		NLS.initializeMessages(BUNDLE_NAME, Messages.class);
	}
	
	public static Properties loadProperties() { return WNLS.load(BUNDLE_NAME, Messages.class); }

	private Messages() {
	}

}

