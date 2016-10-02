package org.uqbar.project.wollok.debugger.client.source

import org.eclipse.debug.core.sourcelookup.AbstractSourceLookupDirector
import org.uqbar.project.wollok.ui.launch.Activator

/**
 * Directs the configuration of source lookup objects.
 * The ones that searches for the current debug location source code
 * in order to present it to the user to see the corresponding code.
 * 
 * @author jfernandes
 */
class WollokSourceLookupDirector extends AbstractSourceLookupDirector {
	
	override initializeParticipants() {
		addParticipants(#[createParticipant])
	}
	
	def createParticipant() {
		new WollokSourceLookupParticipant => [
			Activator.^default.injector.injectMembers(it)
		]
	}
	
}