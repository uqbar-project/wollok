package org.uqbar.project.wollok.ui

import java.net.URL
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.swt.widgets.Display
import org.osgi.framework.BundleContext
import org.uqbar.project.wollok.ui.internal.WollokDslActivator

/**
 * Customized activator.
 * 
 * @author jfernandes
 */
class WollokActivator extends WollokDslActivator {
	//package name where the "messages.properties" is
	public static val BUNDLE_NAME = "org.uqbar.project.wollok.ui.messages" 

	def static WollokActivator getInstance() {
		return WollokDslActivator.getInstance as WollokActivator
	}
	
	override start(BundleContext context) throws Exception {
		super.start(context)
	}

	def static getStandardDisplay() {
		val display = Display.getCurrent
		if (display == null)
			return Display.getDefault
		return display;
	}
	
	def getImageDescriptor(String name) {
		val u = new URL(getDescriptor.getInstallURL(), name)
		return ImageDescriptor.createFromURL(u);
	}

}
