package org.uqbar.project.wollok.ui.hover

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ui.editor.hover.html.DefaultEObjectHoverProvider
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

/**
 * Customizes default hover provider to avoid including the grammar rule's
 * exact name which would be tricky for the end user.
 * 
 * @author jfernandes
 */
//TODO: i18n !!
class WollokEObjectHoverProvider extends DefaultEObjectHoverProvider {
	
	override getFirstLine(EObject o) {
		val label = getLabel(o)
		return o.modelTypeDescription + (if (label != null) " <b>"+label+"</b>" else "")
	}
	
	// default: removes the "W" prefix and uses the class name
	def dispatch modelTypeDescription(EObject it) { if (eClass.name.startsWith("W")) eClass.name.substring(1) }
	def dispatch modelTypeDescription(WNamedObject it) { "Object" }
	def dispatch modelTypeDescription(WObjectLiteral it) { "Object" }
	def dispatch modelTypeDescription(WMethodDeclaration it) { "Method" }
	def dispatch modelTypeDescription(WVariableDeclaration it) { if (writeable) "Variable" else "Value" }
	
}