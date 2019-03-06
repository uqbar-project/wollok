package org.uqbar.project.wollok.adapter.mumuki

import org.uqbar.project.wollok.wollokDsl.WProgram

/**
 * This adapter is enabled when running a mumuki program and disables the "void" expression validation.
 * This is a hack and should be removed when we provide a better way of integration with external REPLs 
 * or query runners.
 */
class MumukiAdapter {	
	boolean enabled = false
	
	def programStarted(WProgram it) {
		if (name == "mumuki") enabled = true	
	}
	
	def boolean ignoreVoidValidation() { enabled }
}
