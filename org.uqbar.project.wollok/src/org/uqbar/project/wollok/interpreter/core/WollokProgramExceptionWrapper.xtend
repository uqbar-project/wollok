package org.uqbar.project.wollok.interpreter.core

import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.uqbar.project.wollok.sdk.WollokDSK
import org.uqbar.project.wollok.wollokDsl.WThrow

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

/**
 * Wraps a user exception (an exception thrown in the user code
 * written in Wollok lang) into a java exception so we can reuse
 * java exception mechanism. 
 * 
 * @author jfernandes
 */
class WollokProgramExceptionWrapper extends RuntimeException {
	WollokObject wollokException
	@Accessors URI URI
	@Accessors int lineNumber
	
	new(WollokObject exception) {
		wollokException = exception
	}
	
	new(WollokObject exception, WThrow origin) {
		this(exception)
		URI = EcoreUtil2.getURI(origin)
		lineNumber = lineNumber(origin)	
	}
	
	def node(WThrow it) { NodeModelUtils.findActualNodeFor(it) }
	def lineNumber(WThrow it) { node.textRegionWithLineInformation.lineNumber }
	
	def getWollokException() {
		wollokException
	}
	
	def boolean isMessageNotUnderstood() {
		wollokException.call("className").wollokToJava(String) != WollokDSK.MESSAGE_NOT_UNDERSTOOD_EXCEPTION
	}
	
	def getWollokStackTrace() {
		wollokException.call("getStackTraceAsString").wollokToJava(String) as String
	}
	
	def getWollokMessage() {
		wollokException.call("getMessage").wollokToJava(String) as String
	}
	
}