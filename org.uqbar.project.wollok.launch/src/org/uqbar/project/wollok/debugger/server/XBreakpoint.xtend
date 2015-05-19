package org.uqbar.project.wollok.debugger.server

import org.eclipse.emf.ecore.EObject

import static extension org.uqbar.project.wollok.utils.XTextExtensions.*

/**
 * Server (interpreter) representation of a breakpoint
 * 
 * @author jfernandes
 */
class XBreakpoint {
	@Property String fileURI
	@Property int lineNumber
	
	new(String fileURI, int lineNumber) {
		this.fileURI = fileURI
		this.lineNumber = lineNumber
	}
	
	def hits(EObject object) {
		object.fileURI.toString == fileURI && object.lineNumber == lineNumber
	}
	
}