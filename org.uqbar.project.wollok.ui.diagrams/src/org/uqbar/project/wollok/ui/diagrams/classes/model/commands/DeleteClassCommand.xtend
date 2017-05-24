package org.uqbar.project.wollok.ui.diagrams.classes.model.commands

import org.eclipse.gef.commands.Command
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.classes.model.AbstractModel
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AbstractMethodContainerEditPart

@Accessors
class DeleteClassCommand extends Command {
	AbstractMethodContainerEditPart source
	
	override execute() {
		source.castedModel.configuration.deleteClass(source.castedModel as AbstractModel)
	}
	
}
