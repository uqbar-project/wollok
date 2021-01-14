package org.uqbar.project.wollok.product.ui.startup

import java.util.ArrayList
import java.util.List
import org.eclipse.core.runtime.dynamichelpers.IExtensionChangeHandler
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.internal.Workbench
import org.eclipse.ui.internal.WorkbenchWindow
import org.eclipse.ui.internal.dialogs.WorkbenchWizardElement
import org.eclipse.ui.internal.wizards.AbstractExtensionWizardRegistry
import org.eclipse.ui.wizards.IWizardCategory
import org.eclipse.ui.wizards.IWizardDescriptor
import org.eclipse.ui.wizards.IWizardRegistry
import org.uqbar.project.wollok.ui.WollokUIStartup
import org.eclipse.core.runtime.Platform
import org.uqbar.project.wollok.ui.preferences.WollokAdvancedProgrammingConfigurationBlock
import org.eclipse.core.runtime.preferences.IScopeContext
import org.eclipse.core.runtime.preferences.BundleDefaultsScope
import org.uqbar.project.wollok.ui.preferences.WollokAdvancedProgrammingConfigurationBlock
import org.eclipse.core.runtime.preferences.ConfigurationScope

/**
 * Programmatically hacks eclipse workbench to
 * remove unwanted wizards that will confuse users/students.
 * 
 * TODO: maybe we can have this configurable as a preference ?
 * 
 * @author jfernandes
 */
class RemoveWizardsStartup implements WollokUIStartup {

    static String PREFERENCE_STORE_NAME = "org.uqbar.project.wollok.WollokDsl"
	override startup() {
		
		val advanced = Platform.getPreferencesService().getBoolean(PREFERENCE_STORE_NAME, WollokAdvancedProgrammingConfigurationBlock.ACTIVATE_ADVANCED_PROGRAMMING, false, #[BundleDefaultsScope.INSTANCE] as IScopeContext[])
		
		if(! advanced) {
			removeAdvacedFeatures
		}
		
	}
	
	def removeAdvacedFeatures() {	
		PlatformUI.workbench.newWizardRegistry.removeWizards
		PlatformUI.workbench.exportWizardRegistry.removeWizards
		PlatformUI.workbench.importWizardRegistry.removeWizards
		removeUnwantedPerspectives

		val window = Workbench.instance.activeWorkbenchWindow as WorkbenchWindow
		if (window !== null)
			window.addPerspectiveListener(new WollokPerspectiveListener)

		// TODO: find a way to remove extensions
//		Platform.extensionRegistry.extension
//			println('''Extension  «extensionPointUniqueIdentifier» :: «it.simpleIdentifier» | «label»''')
//			Platform.extensionRegistry.remove
//		]
	}

	// reusable code
	def removeWizards(IWizardRegistry it) {
		(it as AbstractExtensionWizardRegistry).removeWizards
	}

	def removeWizards(AbstractExtensionWizardRegistry registry) {
		val categories = registry.rootCategory.categories
		for (wizard : categories.allWizards) {
			if (!wizard.id.includeWizards || wizard.id.excludeWizards) {
				val wizardElement = wizard as WorkbenchWizardElement
				//Platform.getLog(getClass()).info("removing " + wizardElement.id)
				registry.removeExtension(wizardElement.configurationElement.declaringExtension, #[wizardElement])
			}
		}
	}

	static val includeWizards = #[
		"org\\.eclipse\\.ui\\..*",
		"org\\.uqbar\\.project\\.wollok\\..*",
		"org\\.eclipse\\.jdt\\.ui\\.wizards\\.NewPackageCreationWizard",
		"org\\.eclipse\\.jdt\\.ui\\.wizards\\.NewSourceFolderCreationWizard",
		"org\\.eclipse\\.team\\.svn\\...*",
		"org\\.eclipse\\.egit\\..*",
//		"org\\.eclipse\\.xtend\\.ide\\.wizards\\.NewXtend.*",
//		"org\\.eclipse\\.jdt\\.ui\\.wizards\\.New.*",
		"org\\.uqbar\\...*"
		
	]

	def includeWizards(String id) {
		includeWizards.exists[id.matches(it)]
	}

	static val excludeWizards = #[
		"org.eclipse.ui.wizards.new.project"
	]

	def excludeWizards(String id) {
		excludeWizards.contains(id)
	}

	def List<IWizardDescriptor> getAllWizards(IWizardCategory[] categories) {
		val results = new ArrayList<IWizardDescriptor>
		for (wizardCategory : categories) {
			results.addAll(wizardCategory.wizards)
			results.addAll(getAllWizards(wizardCategory.categories))
		}
		results
	}

	def ignoredPerspectives() {
		#[
			"org.eclipse.jdt.ui.JavaPerspective",
			"org.eclipse.jdt.ui.JavaHierarchyPerspective",
			"org.eclipse.mylyn.tasks.ui.perspectives.planning",
			"org.eclipse.pde.ui.PDEPerspective",
			"org.eclipse.debug.ui.DebugPerspective",
			"org.eclipse.jdt.ui.JavaBrowsingPerspective"
		].map[toLowerCase]
	}

	def void removeUnwantedPerspectives() {
		val perspectiveRegistry = PlatformUI.getWorkbench().perspectiveRegistry
		val perspectiveDescriptors = perspectiveRegistry.perspectives
		val unwantedPerspectives = perspectiveDescriptors.filter [ perspectiveDescriptor |
			ignoredPerspectives.contains(perspectiveDescriptor.id.toLowerCase)
		]
		val extChgHandler = perspectiveRegistry as IExtensionChangeHandler
		extChgHandler.removeExtension(null, unwantedPerspectives)
	}

}
