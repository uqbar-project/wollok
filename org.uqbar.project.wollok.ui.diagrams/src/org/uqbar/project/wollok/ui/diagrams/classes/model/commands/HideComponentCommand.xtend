package org.uqbar.project.wollok.ui.diagrams.classes.model.commands

import org.eclipse.gef.commands.Command

/**
 * Dummy command that supports hiding a component from the static diagram
 *
 * @author dodain
 *  
 */
class HideComponentCommand extends Command {
	
	override execute() {
		// we do nothing, simply refresh view
	}
	
}
