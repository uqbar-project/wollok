package org.uqbar.project.wollok.interpreter.stack

import java.io.Serializable
import org.eclipse.emf.common.util.URI

/**
 * Represents a source code segment.
 * It decouples the information from the EObject.
 * Like a DTO object this allows us to send this information to the remote debugger
 * without serializing the whole environment.
 * 
 * @author jfernandes
 */
class SourceCodeLocation implements Serializable {
	@Property String fileURI
	@Property int startLine
	@Property int endLine
	@Property int offset
	@Property int length
	@Property String contextDescription
	
	new(URI fileURI, int startLine, int endLine, int offset, int length) {
		this.fileURI = fileURI.toString
		this.startLine = startLine
		this.endLine = endLine
		this.offset = offset
		this.length = length
	}
	
	override toString() '''«fileURI»:«startLine» [«offset»->«offset + length»]'''
	
}