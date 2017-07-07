package org.uqbar.project.wollok.errorHandling

import java.io.Serializable
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.WollokConstants

import static org.uqbar.project.wollok.WollokConstants.*

@Accessors
class StackTraceElementDTO implements Serializable {
	String contextDescription
	Integer lineNumber
	String fileName

	public static List<String> REPL_STACK_WORDS = #[WollokConstants.SYNTHETIC_FILE, WollokConstants.REPL_FILE]
		
	new(String contextDescription, String fileName, int lineNumber) {
		this.contextDescription = contextDescription
		this.fileName = fileName
		this.lineNumber = lineNumber
	}
	
	def toLink() {
		val result = new StringBuffer
		result.append("   ")
		result.append("at ") 
		if (contextDescription != null) {
			result.append(contextDescription)
			result.append(" ")
		}
		if (fileName != null && !fileName.isEmpty) {
			result.append("[<a href=\"" + fileName + STACKELEMENT_SEPARATOR + lineNumber + "\">" + fileName.location(lineNumber) + "</a>]\n")
		}
		result.toString
	}

	def location(String fileName, int line) {
		if (fileName.contains(PATH_SEPARATOR))
		 '''«fileName.substring(fileName.lastIndexOf(PATH_SEPARATOR))»:«line»'''
		else
			fileName
	}
	
	override toString() {
		contextDescription + " [" + fileName + ":" + lineNumber + "]"
	}
	
	def asStackTraceElement(){
		new StackTraceElement(contextDescription ?: "","", fileName, lineNumber)
	}
	
	def shouldBeFiltered() {
		if (fileName === null || fileName.trim.equals("")) return true;
		REPL_STACK_WORDS.map [ toLowerCase ].exists [ word |
			fileName?.toLowerCase.contains(word)
		]
	}
	
	
	def hasFileName() { fileName != null && !fileName.isEmpty }
	
}