package org.uqbar.project.wollok

import org.eclipse.core.runtime.Plugin
import org.eclipse.emf.ecore.EObject
import org.osgi.framework.BundleContext
import org.uqbar.project.wollok.interpreter.WollokRuntimeException

/**
 * 
 */
class WollokActivator extends Plugin {
	public static val BUNDLE_NAME = "org.uqbar.project.wollok"
	public static val WOLLOK_LIB_BUNDLE_NAME = "org.uqbar.project.wollok.lib"
	static WollokActivator plugin;
	BundleContext context  
	
	override start(BundleContext context) {
		super.start(context)
		this.context = context
		plugin = this
	}
	
	override stop(BundleContext context) throws Exception {
		plugin = null
		super.stop(context)
	}

	static def getDefault() {
		plugin
	}
	
	def getWollokLib() {
		bundle.bundleContext.bundles.findFirst[b| b.symbolicName == WOLLOK_LIB_BUNDLE_NAME]
	}
	
	def loadWollokLibClass(String className, EObject context) {
		try {
			wollokLib.loadClass(className);
		} 
		catch (InstantiationException e) {
			throw new WollokRuntimeException("Error while creating native object class " + className, e);
		}
		catch (ClassNotFoundException e) {
			// not found in wollok-lib Search here
			Thread.currentThread.contextClassLoader.loadClass(className)
		}
		catch (IllegalAccessException e) {
			throw new WollokRuntimeException("Error while creating native object class " + className, e);
		}
	}
	
	def findResource(String bundleName, String fullName) {
		val bundle = context.bundles.findFirst[it.symbolicName == bundleName]
		bundle?.getResource(fullName).openStream
	}
	
	def findResource(String fullName) {
		val bundle = context.bundles.findFirst [ it.getResource("/" + fullName) !== null ]
		if(bundle === null)
			null
		else
			bundle.getResource(fullName).openStream
	}

}