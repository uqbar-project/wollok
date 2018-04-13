package org.uqbar.project.wollok.product.ui.startup

import java.util.ArrayList
import java.util.List
import org.eclipse.core.runtime.dynamichelpers.IExtensionChangeHandler
import org.eclipse.jface.action.GroupMarker
import org.eclipse.jface.action.IContributionItem
import org.eclipse.jface.action.MenuManager
import org.eclipse.jface.action.Separator
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.internal.ActionSetContributionItem
import org.eclipse.ui.internal.Workbench
import org.eclipse.ui.internal.WorkbenchWindow
import org.eclipse.ui.internal.dialogs.WorkbenchWizardElement
import org.eclipse.ui.internal.ide.actions.BuildSetMenu
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
		println("Wollok startup!")
		PlatformUI.workbench.newWizardRegistry.removeWizards
		PlatformUI.workbench.exportWizardRegistry.removeWizards
		PlatformUI.workbench.importWizardRegistry.removeWizards
		removeUnwantedPerspectives
		
		val window = Workbench.getInstance().getActiveWorkbenchWindow() as WorkbenchWindow
		window.addPerspectiveListener(new WollokPerspectiveListener)

	// TODO: find a way to remove extensions
//		Platform.extensionRegistry.extensionPoints.map[p | p.extensions.toList ].flatten.forEach[
//			println('''Extension  «extensionPointUniqueIdentifier» :: «it.simpleIdentifier» | «label»''')
//			Platform.extensionRegistry.remove
//		]
	}

	def ignoredPerspectives() {
		#[
		"org.eclipse.jdt.ui.JavaPerspective", "org.eclipse.jdt.ui.JavaHierarchyPerspective",
		"org.eclipse.mylyn.tasks.ui.perspectives.planning", "org.eclipse.pde.ui.PDEPerspective",
		"org.eclipse.debug.ui.DebugPerspective"
		].map [ toLowerCase ]	
	}
	
	def removeUnwantedPerspectives() {
        val perspectiveRegistry = PlatformUI.getWorkbench().getPerspectiveRegistry()
        val perspectiveDescriptors = perspectiveRegistry.getPerspectives()
        val unwantedPerspectives = perspectiveDescriptors.filter [ perspectiveDescriptor |
        	ignoredPerspectives.contains(perspectiveDescriptor.id.toLowerCase)
        ]
        val extChgHandler = perspectiveRegistry as IExtensionChangeHandler
        extChgHandler.removeExtension(null, unwantedPerspectives)
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
		"org\\.eclipse\\.egit\\..*"
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

}
