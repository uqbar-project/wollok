package org.uqbar.project.wollok.ui.debugger.client.source

import org.eclipse.debug.core.sourcelookup.AbstractSourceLookupDirector

/**
 * Directs the configuration of source lookup objects.
 * The ones that searches for the current debug location source code
 * in order to present it to the user to see the corresponding code.
 * 
 * @author jfernandes
 */
class WollokSourceLookupDirector extends AbstractSourceLookupDirector {
	
	override initializeParticipants() {
		addParticipants(#[new WollokSourceLookupParticipant])
	}
	
}