package org.uqbar.project.wollok.launch.tests

import java.io.File
import java.io.Serializable
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class StackTraceElementDTO implements Serializable {
	String contextDescription
	Integer lineNumber
	String fileName
	
	new(String contextDescription, String fileName, int lineNumber) {
		this.contextDescription = contextDescription
		this.fileName = fileName
		this.lineNumber = lineNumber
	}
	
	def toLink(URI testResource) {
		val result = new StringBuffer
		result.append("   ")
		result.append("at ") 
		if (contextDescription != null) {
			result.append(contextDescription)
			result.append(" ")
		}
		if (fileName != null && !fileName.isEmpty) {
			result.append("[<a href=\"" + fileName + ":" + lineNumber + "\">" + fileName.location(lineNumber) + "</a>]\n")
		}
		result.toString
	}

	def location(String fileName, int line) {
		if (fileName.contains(File.separator))
		 '''«fileName.substring(fileName.lastIndexOf(File.separator))»:«line»'''
		else
			fileName
	}
	
}