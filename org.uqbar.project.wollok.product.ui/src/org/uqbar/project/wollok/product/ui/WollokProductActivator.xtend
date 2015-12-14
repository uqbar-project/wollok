package org.uqbar.project.wollok.product.ui

import org.eclipse.ui.plugin.AbstractUIPlugin
import org.osgi.framework.BundleContext

/**
 * Activator for the wollok product.
 * It has the programmatic code to hack eclipse workbench
 * removing cluttering like wizards we don't want and preferences pages, menues, etc.
 * 
 * @author jfernandes
 */
class WollokProductActivator extends AbstractUIPlugin {
	public static val PLUGIN_ID = "org.uqbar.project.wollok.product.ui"; //$NON-NLS-1$
	static var WollokProductActivator plugin
	
	override start(BundleContext context) throws Exception {
		super.start(context)
		plugin = this
	}

	override void stop(BundleContext context) throws Exception {
		plugin = null
		super.stop(context)
	}
	
}