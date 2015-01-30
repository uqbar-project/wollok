package org.uqbar.project.wollok.utils

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.util.ITextRegionWithLineInformation
import org.uqbar.project.wollok.interpreter.stack.SourceCodeLocation

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import org.uqbar.project.wollok.wollokDsl.WExpression

/**
 * Extension methods and utilities for xtext
 * 
 * @author jfernandes
 */
class XTextExtensions {
	// Esto deberia estar en las extensiones de debugging creo.
	public static val String LINE_NUMBER_SEPARATOR = "|"
	
	def static toSourceCodeLocation(EObject o) { 
		o.astNode.textRegionWithLineInformation.toSourceCodeLocation(o.fileURI) => [ contextDescription = o.contextDescription ]
	}
	def static dispatch String contextDescription(EObject o) { null }
	def static dispatch String contextDescription(WExpression e) { 
		val m = e.method
		if (m != null)
			m.declaringContext.contextName + "." + m.name + "(" + m.parameters.map[name].join(",") + ")"
		else 
			null
	}
	
	def static toSourceCodeLocation(ITextRegionWithLineInformation t, URI file) {
		new SourceCodeLocation(file, t.lineNumber, t.endLineNumber, t.offset, t.length)
	}
	
	def static astNode(EObject o) { NodeModelUtils.findActualNodeFor(o) }
	def static fileURI(EObject o) { o.eResource.URI }
	def static lineNumber(EObject o) { o.astNode.startLine }
	def static sourceCode(EObject o) { o.astNode.text }
	def static shortSouceCode(EObject o) { o.sourceCode.trim.replaceAll('\n', ' ') }
	
	def static objectURI(EObject o) { (o.eResource as XtextResource).getURIFragment(o) }
	
	def static allSiblingsBefore(EObject o) {
		val beforeNodes = newArrayList
		for(c : o.eContainer.eContents) {
			if (c != o)
				beforeNodes.add(c)
			else
				return beforeNodes
		}
	}
	
}