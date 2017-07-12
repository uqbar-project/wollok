package org.uqbar.project.wollok.typesystem

import java.util.List
import org.apache.log4j.Logger
import org.eclipse.core.runtime.Platform
import org.eclipse.core.runtime.Plugin
import org.eclipse.emf.ecore.EObject
import org.osgi.framework.BundleContext
import org.uqbar.project.wollok.typesystem.preferences.DefaultWollokTypeSystemPreferences
import org.uqbar.project.wollok.typesystem.preferences.WollokTypeSystemPreference

/**
 * 
 * 
 * @author jfernandes
 */
class WollokTypeSystemActivator extends Plugin {
	public static val BUNDLE_NAME = " org.uqbar.project.wollok.typeSystem"
	public static val TYPE_SYSTEM_IMPL_EXTENSION_POINT = "org.uqbar.project.wollok.typeSystem.implementation"
	public static val TYPE_SYSTEM_PREFERENCES_EXTENSION_POINTS = "org.uqbar.project.wollok.typesystem.preferences"

	val Logger log = Logger.getLogger(this.class)

	private static WollokTypeSystemActivator plugin
	private BundleContext context
	private List<TypeSystem> typeSystems
	WollokTypeSystemPreference typeSystemPreferences;

	def synchronized getTypeSystems() {
		if (typeSystems === null) {
			val configs = Platform.extensionRegistry.getConfigurationElementsFor(TYPE_SYSTEM_IMPL_EXTENSION_POINT)
			typeSystems = configs.map[it.createExecutableExtension("class") as TypeSystem]
		}
		return typeSystems
	}

	def synchronized WollokTypeSystemPreference getTypeSystemPreferences() {
		if (typeSystemPreferences === null) {
			val configs = Platform.extensionRegistry.getConfigurationElementsFor(TYPE_SYSTEM_PREFERENCES_EXTENSION_POINTS)

			if (configs.size > 0) {
				typeSystemPreferences = configs.get(0).createExecutableExtension("class") as WollokTypeSystemPreference
			} else {
				typeSystemPreferences = new DefaultWollokTypeSystemPreferences()
			}
			
			log.debug("Using system preferences:" + typeSystemPreferences.class.name)
		}

		typeSystemPreferences
	}

	def getTypeSystem(EObject context) {
		var selectedTypeSystem = this.getTypeSystemPreferences().getSelectedTypeSystem(context)
		getTypeSystem(selectedTypeSystem)
	}

	def getTypeSystem(String typeSystemName) {
		getTypeSystems().findFirst[name == typeSystemName]
	}

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

	def isTypeSystemEnabled(EObject file) {
		getTypeSystemPreferences().isTypeSystemEnabled(file)
	}

}
