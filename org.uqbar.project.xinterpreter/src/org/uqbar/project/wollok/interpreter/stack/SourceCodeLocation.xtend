package org.uqbar.project.wollok.interpreter.stack

import java.io.Serializable
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * Represents a source code segment.
 * It decouples the information from the EObject.
 * Like a DTO object this allows us to send this information to the remote debugger
 * without serializing the whole environment.
 * 
 * @author jfernandes
 */
@Accessors
class SourceCodeLocation implements Serializable {
	var String fileURI
	var int startLine
	var int endLine
	var int offset
	var int length
	var String contextDescription
	
	new(URI fileURI, int startLine, int endLine, int offset, int length) {
		this.fileURI = fileURI.toString
		this.startLine = startLine
		this.endLine = endLine
		this.offset = offset
		this.length = length
	}
	
	override String toString() '''«fileURI»:«startLine» [«offset»->«offset + length»]'''
	
}