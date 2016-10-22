package org.uqbar.project.wollok.launch.tests

import java.io.Serializable
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
}