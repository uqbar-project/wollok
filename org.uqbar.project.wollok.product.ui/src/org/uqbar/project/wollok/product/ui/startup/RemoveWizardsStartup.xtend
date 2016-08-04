package org.uqbar.project.wollok.product.ui.startup

import java.util.ArrayList
import java.util.List
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.internal.dialogs.WorkbenchWizardElement
import org.eclipse.ui.internal.wizards.AbstractExtensionWizardRegistry
import org.eclipse.ui.wizards.IWizardCategory
import org.eclipse.ui.wizards.IWizardDescriptor
import org.eclipse.ui.wizards.IWizardRegistry
import org.uqbar.project.wollok.ui.WollokUIStartup

/**
 * Programmatically hacks eclipse workbench to
 * remove unwanted wizards that will confuse users/students.
 * 
 * TODO: maybe we can have this configurable as a preference ?
 * 
 * @author jfernandes
 */
class RemoveWizardsStartup implements WollokUIStartup {
	
	override startup() { 
		PlatformUI.workbench.newWizardRegistry.removeWizards
		PlatformUI.workbench.exportWizardRegistry.removeWizards
		PlatformUI.workbench.importWizardRegistry.removeWizards
		
		// TODO: find a way to remove extensions
//		Platform.extensionRegistry.extensionPoints.map[p | p.extensions.toList ].flatten.forEach[
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
	        if (!wizard.id.includeWizards) {
	        	//println("Removing wizard " + wizard.id)
				val wizardElement = wizard as WorkbenchWizardElement
				registry.removeExtension(wizardElement.configurationElement.declaringExtension, #[wizardElement])
			}
		}
	}
	
	static val includeWizards = #[
		"org\\.eclipse\\.ui\\..*", 
		"org\\.uqbar\\.project\\.wollok\\..*",
		"org\\.eclipse\\.jdt\\.ui\\.wizards\\.NewPackageCreationWizard",
		"org\\.eclipse\\.jdt\\.ui\\.wizards\\.NewSourceFolderCreationWizard",
		"org\\.eclipse\\.team\\.svn\\...*"
	]
	def includeWizards(String id) {
		includeWizards.exists[id.matches(it)]
	}
	
	def List<IWizardDescriptor> getAllWizards(IWizardCategory[] categories) {
	  val results = new ArrayList<IWizardDescriptor>
	  for(wizardCategory : categories) {
	    results.addAll(wizardCategory.wizards)
	    results.addAll(getAllWizards(wizardCategory.categories))
	  }
	  results
	}
	
}