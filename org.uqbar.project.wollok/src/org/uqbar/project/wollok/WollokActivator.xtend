package org.uqbar.project.wollok

import org.eclipse.core.runtime.Plugin
import org.eclipse.emf.ecore.EObject
import org.osgi.framework.BundleContext
import org.uqbar.project.wollok.interpreter.WollokRuntimeException

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.eclipse.core.internal.resources.Project

/**
 * 
 */
class WollokActivator extends Plugin {
	public static val BUNDLE_NAME = "org.uqbar.project.wollok"
	public static val WOLLOK_LIB_BUNDLE_NAME = "org.uqbar.project.wollok.lib"
	private static WollokActivator plugin; 

	override start(BundleContext context) {
		super.start(context)
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
//			throw new WollokRuntimeException("Error while creating native object class " + className, e);
		}
		catch (IllegalAccessException e) {
			throw new WollokRuntimeException("Error while creating native object class " + className, e);
		}
	}
	

}