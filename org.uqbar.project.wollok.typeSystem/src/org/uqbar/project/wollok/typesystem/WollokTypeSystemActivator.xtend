package org.uqbar.project.wollok.typesystem

import com.google.inject.Inject
import java.util.List
import org.eclipse.core.runtime.Platform
import org.eclipse.core.runtime.Plugin
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.osgi.framework.BundleContext
import org.uqbar.project.wollok.ui.internal.WollokDslActivator

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * 
 * 
 * @author jfernandes
 */
class WollokTypeSystemActivator extends Plugin {
	public static val BUNDLE_NAME = " org.uqbar.project.wollok.typeSystem"
	public static val TYPE_SYSTEM_IMPL_EXTENSION_POINT = "org.uqbar.project.wollok.typeSystem.implementation"
	
	public static val PREF_TYPE_SYSTEM_IMPL = "TYPE_SYSTEM_IMPL"
	public static val PREF_TYPE_SYSTEM_CHECKS_ENABLED = "TYPE_SYSTEM_CHECKS_ENABLED"
	
	private static WollokTypeSystemActivator plugin
	private BundleContext context  
	private List<TypeSystem> typeSystems
	@Inject IPreferenceStoreAccess preferenceStoreAccess
	
	def synchronized getTypeSystems() {
		if (typeSystems == null) {
			val configs = Platform.extensionRegistry.getConfigurationElementsFor(TYPE_SYSTEM_IMPL_EXTENSION_POINT)
			typeSystems = configs.map[it.createExecutableExtension("class") as TypeSystem]
		}
		return typeSystems	
	}
	
	def getTypeSystem(EObject context) {
		// TODO: some kind of cache ?
		var selectedTypeSystem = context.preferences.getString(PREF_TYPE_SYSTEM_IMPL)
		if (selectedTypeSystem == null)
			selectedTypeSystem = "XSemantics"
		getTypeSystem(selectedTypeSystem)
	}
	
	def getTypeSystem(String typeSystemName) {
		getTypeSystems().findFirst[name == typeSystemName]
	}
	
	def preferences(EObject obj) {
		preferenceStoreAccess.getContextPreferenceStore(obj.IFile.project)
	}
	
	override start(BundleContext context) {
		super.start(context)
		this.context = context
		injector.injectMembers(this)
		plugin = this
	}
	
	def getInjector() {
		WollokDslActivator.getInstance().getInjector(WollokDslActivator.ORG_UQBAR_PROJECT_WOLLOK_WOLLOKDSL);
	}
	
	override stop(BundleContext context) throws Exception {
		plugin = null
		super.stop(context)
	}

	static def getDefault() {
		plugin
	}
	
}