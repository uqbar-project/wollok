package org.uqbar.project.wollok.ui.highlight

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ide.editor.syntaxcoloring.DefaultSemanticHighlightingCalculator
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor
import org.eclipse.xtext.nodemodel.ICompositeNode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.util.CancelIndicator
import org.uqbar.project.wollok.wollokDsl.WInitializer
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.ui.highlight.WollokHighlightingConfiguration.*

/**
 * Customizes highlighting
 * 
 * @author jfernandes
 */
class WollokHighlightingCalculator extends DefaultSemanticHighlightingCalculator {
	
	def cancelIndicator() {
		[ | false ] as CancelIndicator
	}
	
	override protected highlightElement(EObject object, IHighlightedPositionAcceptor acceptor, CancelIndicator cancelIndicator) {
		val node = NodeModelUtils.findActualNodeFor(object)
		highlight(object, node, acceptor)
	}
	
	// default: delegates to super
	def dispatch highlight(EObject obj, ICompositeNode node, IHighlightedPositionAcceptor acceptor) {
		super.highlightElement(obj, acceptor, cancelIndicator)
	}
	
	// ** customizations (as multiple dispatch methods)
	def dispatch highlight(WNamedObject obj, ICompositeNode node, IHighlightedPositionAcceptor acceptor) {
		super.highlightElement(obj, acceptor, cancelIndicator)
	}	
	
	def dispatch highlight(WVariableReference obj, ICompositeNode node, IHighlightedPositionAcceptor acceptor) {
		acceptor.addPosition(node.offset, node.length, styleFor(obj.ref))
		false
	}
	
	def dispatch highlight(WReferenciable obj, ICompositeNode node, IHighlightedPositionAcceptor acceptor) {
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
	
	def dispatch isParameter(EObject o) { false }
	def dispatch isParameter(WParameter p) { true }
	def dispatch isParameter(WVariable v) { 
		v.eContainer instanceof WInitializer
	}
}