package org.uqbar.project.wollok.errorHandling

import java.io.Serializable
import org.eclipse.xtend.lib.annotations.Accessors

import static org.uqbar.project.wollok.WollokConstants.*

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
	
	def toLink() {
		val result = new StringBuffer
		result.append("   ")
		result.append("at ") 
		if (contextDescription !== null) {
			result.append(contextDescription)
			result.append(" ")
		}
		if (fileName !== null && !fileName.isEmpty) {
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
	
	def hasFileName() { fileName !== null && !fileName.isEmpty }
	
	def safeCompare(String string, String string2) {
		(string === null && string2 === null) || (string !== null && string.equals(string2))
	}
	
	override equals(Object obj) {
		if (obj === null) return false;
		try {
			val st = obj as StackTraceElementDTO
			return safeCompare(fileName, st.fileName) && safeCompare(contextDescription, st.contextDescription) && lineNumber.intValue == st.lineNumber.intValue
		} catch (ClassCastException e) {
			return false
		}
	}

	override hashCode() {
		((fileName ?: "") + (contextDescription ?: "") + lineNumber.toString).hashCode
 	}
 	
 	def getContextForStackTrace() {
 		val result = new StringBuffer => [
			append("   ")
			append("at")
			append(" ")
			if (contextDescription !== null) {
				append(contextDescription)
				append(" ")
			}
		]
		result.toString
 	}
 	
 	def getLinkForStackTrace() {
 		val result = new StringBuffer => [
			if (hasFileName) {
				append("(" + fileName + ":" + lineNumber + ")")
			}
 		]
		result.toString 			
 	}
	
	def getElementForStackTrace() {
		contextForStackTrace + linkForStackTrace
	}
}