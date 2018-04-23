package org.uqbar.project.wollok.ui.wizard.abstractWizards

import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.ui.dialogs.ISelectionValidator
import org.eclipse.core.runtime.Path
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*
import org.uqbar.project.wollok.ui.Messages

class WollokElementValidator implements ISelectionValidator {
	
	override isValid(Object arg0) {
		val path = arg0 as Path
		val resource = ResourcesPlugin.workspace.root.findMember(path)
		if (resource.hidden) {
			return Messages.ELEMENT_VALIDATOR_SELECT_SOURCE_FOLDER
		}
		val container = resource.container
		if (container.isSourceFolder) null else Messages.ELEMENT_VALIDATOR_SELECT_SOURCE_FOLDER
	}
	
}