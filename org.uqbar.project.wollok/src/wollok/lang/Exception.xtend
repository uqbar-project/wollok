package wollok.lang

import java.io.File
import java.util.List
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.stack.SourceCodeLocation

import static org.uqbar.project.wollok.WollokConstants.*

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

/**
 * Wollok Exception native implementation.
 * 
 * @author jfernandes
 */
class Exception {
	public static String FILE = "file:"
	
	WollokObject exceptionObject
	List<SourceCodeLocation> stackTrace
	
	new(WollokObject object, WollokInterpreter interpreter) {
		exceptionObject = object
		stackTrace = interpreter
			.currentThread
			.stack
			.filter [ frame | frame.showableInStackTrace ]
			.map[f| f.currentLocation ]
			.clone
			.reverse
	}
	
	def initialize() {}
	
	def getStackTrace() {
		stackTrace.map[ 
			exceptionObject.call("createStackTraceElement", contextDescription.javaToWollok, location.toString.javaToWollok)
		].toList
	}

	def getFullStackTrace() {
		stackTrace.map[ 
			exceptionObject.call("createStackTraceElement", contextDescription.javaToWollok, fullLocation.toString.javaToWollok)
		].toList
	}
	
	def location(SourceCodeLocation l) {
		if (l.fileURI.contains(PATH_SEPARATOR))
		 '''«l.fileURI.substring(l.fileURI.lastIndexOf(PATH_SEPARATOR))»:«l.startLine»'''
		else
			l.fileURI
	}
	
	def fullLocation(SourceCodeLocation l) {
		var fileURI = l.fileURI
		if (fileURI.startsWith(FILE)) {
			var spaces = WINDOWS_FILE_PREFIX_SIZE
			if (File.separator.equalsIgnoreCase(PATH_SEPARATOR)) {
				// Hack to handle absolute paths for Linux / Mac
				spaces = DEFAULT_FILE_PREFIX_SIZE
			}
			fileURI = fileURI.substring(spaces) 
		}
		'''«fileURI»,«l.startLine»'''
	}
	
}