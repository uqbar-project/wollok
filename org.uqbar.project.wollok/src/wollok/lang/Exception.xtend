package wollok.lang

import java.io.File
import java.util.List
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.stack.SourceCodeLocation
import org.uqbar.project.wollok.wollokDsl.WClass

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
	
	def printStackTrace() {
		print(
'''Exception «(exceptionObject.kind as WClass).name»
	«FOR frame : stackTrace.reverse»
	at «frame.contextDescription» [«frame.location»]
«ENDFOR»''')
	}
	
	def location(SourceCodeLocation l) {
		if (l.fileURI.contains(File.separator))
		 '''«l.fileURI.substring(l.fileURI.lastIndexOf(File.separator))»:«l.startLine»'''
		else
			l.fileURI
	}
	
}