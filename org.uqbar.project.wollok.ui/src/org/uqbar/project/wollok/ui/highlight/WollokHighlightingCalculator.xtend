package org.uqbar.project.wollok.ui.highlight

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ide.editor.syntaxcoloring.DefaultSemanticHighlightingCalculator
import org.eclipse.xtext.ide.editor.syntaxcoloring.HighlightingStyles
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor
import org.eclipse.xtext.nodemodel.ICompositeNode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.util.CancelIndicator
import org.uqbar.project.wollok.ui.contentassist.LanguageFeaturesHelper
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.ui.highlight.WollokHighlightingConfiguration.*
import org.uqbar.project.wollok.wollokDsl.Invariant

/**
 * Customizes highlighting
 * 
 * @author jfernandes
 */
class WollokHighlightingCalculator extends DefaultSemanticHighlightingCalculator {
	@Inject LanguageFeaturesHelper langFeatures
	
	override protected highlightElement(EObject object, IHighlightedPositionAcceptor acceptor, CancelIndicator cancel) {
		val node = NodeModelUtils.findActualNodeFor(object)
		highlight(object, node, acceptor, cancel)
	}
	
	// ** customizations (as multiple dispatch methods)
	
	def dispatch highlight(WVariableReference obj, ICompositeNode node, IHighlightedPositionAcceptor acceptor,  CancelIndicator cancel) {
		acceptor.addPosition(node.offset, node.length, styleFor(obj.ref))
		false
	}
	
	def dispatch highlight(WReferenciable obj, ICompositeNode node, IHighlightedPositionAcceptor acceptor,  CancelIndicator cancel) {
		acceptor.addPosition(node.offset, node.length, styleFor(obj))
		true
	}
	
	def styleFor(WReferenciable it) {
		if (isInstanceVar) 		INSTANCE_VAR_STYLE_ID 
		else if (isParameter) 	PARAMETER_STYLE_ID
		else 					LOCAL_VAR_STYLE_ID
	}
	
	def boolean isInstanceVar(WReferenciable obj) {
		obj.eContainer instanceof WVariableDeclaration && obj.eContainer.eContainer instanceof WMethodContainer
	}
	
	def isParameter(WReferenciable r) { r instanceof WParameter }

	// **********************************************
	// ** Enabling / Disabling language features
	// **********************************************
	
	// default: delegates to super
	def dispatch highlight(EObject obj, ICompositeNode node, IHighlightedPositionAcceptor acceptor, CancelIndicator cancel) {
		if (langFeatures.isDisabled(node.grammarElement, obj)) {
			highlightNode(acceptor, node, HighlightingStyles.DEFAULT_ID)
			true			
		}
		else { 
			super.highlightElement(obj, acceptor, cancel)
		}
	}
	
}