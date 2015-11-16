package wollok.lang

import java.io.File
import java.util.List
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.stack.SourceCodeLocation
import org.uqbar.project.wollok.wollokDsl.WClass

//import static org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

/**
 * Wollok Exception native implementation.
 * 
 * @author jfernandes
 */
class Exception {
	WollokObject exceptionObject
	List<SourceCodeLocation> stackTrace
	
	new(WollokObject object, WollokInterpreter interpreter) {
		exceptionObject = object
		stackTrace = interpreter.stack.map[f| f.currentLocation].clone
	}
	
	def getStackTrace() {
		stackTrace.reverse.map[ exceptionObject.call("createStackTraceElement", contextDescription, location)].toList //.javaToWollok
	}
	
	def location(SourceCodeLocation l) {
		if (l.fileURI.contains(File.separator))
		 '''«l.fileURI.substring(l.fileURI.lastIndexOf(File.separator))»:«l.startLine»'''
		else
			l.fileURI
	}
	
}