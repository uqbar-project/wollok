package org.uqbar.project.xtext.utils

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.util.ITextRegionWithLineInformation
import org.uqbar.project.wollok.interpreter.stack.SourceCodeLocation
import org.uqbar.project.wollok.interpreter.stack.SourceCodeLocator

/**
 * Extension methods and utilities for xtext source code
 * 
 * @author jfernandes
 */
class SourceCodeExtensions {
	def static toSourceCodeLocation(EObject o, extension SourceCodeLocator sl) { 
		o.astNode.textRegionWithLineInformation.toSourceCodeLocation(o.fileURI) => [ contextDescription = o.contextDescription ]
	}
	
	def static toSourceCodeLocation(ITextRegionWithLineInformation t, URI file) {
		new SourceCodeLocation(file, t.lineNumber, t.endLineNumber, t.offset, t.length)
	}
	
	def static astNode(EObject o) { NodeModelUtils.findActualNodeFor(o) }
	def static fileURI(EObject o) { o.eResource.URI }
	def static sourceCode(EObject o) { o.astNode.text }
}