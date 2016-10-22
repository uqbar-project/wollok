package wollok.lang

import java.io.File
import java.util.List
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.emf.common.util.URI
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.ui.IWorkbenchWindow
import org.eclipse.ui.PlatformUI
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.stack.SourceCodeLocation

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

/**
 * Wollok Exception native implementation.
 * 
 * @author jfernandes
 */
class Exception {
	static String FILE = "file:"
	
	WollokObject exceptionObject
	List<SourceCodeLocation> stackTrace
	
	new(WollokObject object, WollokInterpreter interpreter) {
		exceptionObject = object
		stackTrace = interpreter.stack.map[f| f.currentLocation].clone
	}
	
	def getStackTrace() {
		stackTrace.reverse.map[ 
			exceptionObject.call("createStackTraceElement", contextDescription.javaToWollok, location.toString.javaToWollok)
		].toList
	}

	def getFullStackTrace() {
		stackTrace.reverse.map[ 
			exceptionObject.call("createStackTraceElement", contextDescription.javaToWollok, fullLocation.toString.javaToWollok)
		].toList
	}
	
	def location(SourceCodeLocation l) {
		if (l.fileURI.contains(File.separator))
		 '''«l.fileURI.substring(l.fileURI.lastIndexOf(File.separator))»:«l.startLine»'''
		else
			l.fileURI
	}
	
	def fullLocation(SourceCodeLocation l) {
		var fileURI = l.fileURI
		if (fileURI.startsWith(FILE)) {
			fileURI = fileURI.substring(5)
		}
		'''«fileURI»,«l.startLine»'''
	}
	
}