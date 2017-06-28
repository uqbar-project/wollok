package org.uqbar.project.wollok.ui.diagrams.classes.model.commands

import org.eclipse.gef.commands.Command
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AssociationConnectionEditPart

/**
 *
 * Delete Association Command allows to delete a connection
 * 
 * @author dodain
 *  
 */
class DeleteConnectionCommand extends Command {
	
	@Accessors AssociationConnectionEditPart connection
	
	override canExecute() {
		connection !== null
	}
	
	override execute() {
		connection.source = null
		connection.target = null
		connection.parent = null
	}
	
}