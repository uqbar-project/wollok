package org.uqbar.project.wollok.ui.diagrams.classes.parts

import org.eclipse.gef.Request
import org.eclipse.gef.RequestConstants
import org.eclipse.gef.editparts.AbstractGraphicalEditPart
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.ui.editor.IURIEditorOpener
import org.uqbar.project.wollok.ui.WollokActivator
import org.eclipse.emf.ecore.EObject

/**
 * Abstract base class for edit parts of different language elements.
 * Has some reusable behavior like double-click will open the element in the 
 * code editor.
 * 
 * @author jfernandes
 */
abstract class AbstractLanguageElementEditPart extends AbstractGraphicalEditPart {
	IURIEditorOpener opener
		
	new() {
		opener = WollokActivator.getInstance.opener
	}
	
	override performRequest(Request req) {
		if (req.type == RequestConstants.REQ_OPEN)
	         opener.open(EcoreUtil2.getURI(languageElement), true)
		else 
			super.performRequest(req)
	}
	
	def EObject getLanguageElement()
	
}