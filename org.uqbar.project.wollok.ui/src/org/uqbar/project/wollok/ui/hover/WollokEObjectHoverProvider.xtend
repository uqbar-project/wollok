package org.uqbar.project.wollok.ui.hover

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ui.editor.hover.html.DefaultEObjectHoverProvider

import static extension org.uqbar.project.wollok.errorHandling.HumanReadableUtils.*

/**
 * Customizes default hover provider to avoid including the grammar rule's
 * exact name which would be tricky for the end user.
 * 
 * @author jfernandes
 */
class WollokEObjectHoverProvider extends DefaultEObjectHoverProvider {
	
	override getFirstLine(EObject o) {
		val label = getLabel(o)
		return o.modelTypeDescription + (if (label !== null) " <b>"+label+"</b>" else "")
	}
}