package org.uqbar.project.wollok.ui.diagrams.classes.model.commands

import org.eclipse.gef.commands.Command
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AbstractMethodContainerEditPart

class HideComponentCommand extends Command {
	@Accessors AbstractMethodContainerEditPart component
	
	override execute() {
		// we do nothing, simply refresh view
	}
	
}
