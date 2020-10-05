package org.uqbar.project.wollok.ui.highlight

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ide.editor.syntaxcoloring.DefaultSemanticHighlightingCalculator
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor
import org.eclipse.xtext.nodemodel.ICompositeNode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.util.CancelIndicator
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WInitializer
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.WollokConstants.*
import static org.uqbar.project.wollok.ui.highlight.WollokHighlightingConfiguration.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * Customizes highlighting
 * 
 * @author jfernandes
 * @author fdodino     adding Class, Mixin & Object customization for dark mode
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
		WKO.highlightComponent(obj, node, acceptor)
	}

	def dispatch highlight(WClass clazz, ICompositeNode node, IHighlightedPositionAcceptor acceptor) {
		CLASS.highlightComponent(clazz, node, acceptor)
	}

	def highlightComponent(String componentName, WMethodContainer methodContainer, ICompositeNode node, IHighlightedPositionAcceptor acceptor) {
		val startKeyword = node.text.indexOf(componentName)
		addHighlight(startKeyword, componentName, methodContainer.name, node, acceptor, COMPONENT_STYLE_ID)
		if (methodContainer.parent !== null) {
			addHighlight(startKeyword, INHERITS, methodContainer.parent.name, node, acceptor, COMPONENT_STYLE_ID)
		}
		if (methodContainer.mixins !== null) {
			methodContainer.mixins.forEach [ addHighlight(startKeyword, MIXED_WITH, it.name, node, acceptor, COMPONENT_STYLE_ID)]
		}
		super.highlightElement(methodContainer, acceptor, cancelIndicator)		
	}

	def void addHighlight(int initialOffset, String keyword, String name, ICompositeNode node, IHighlightedPositionAcceptor acceptor, String style) {
		val startKeyword = node.text.indexOf(keyword)
		if (startKeyword == -1) return
		val start = node.text.indexOf(name, startKeyword)
		if (start == -1) return;
		val offset = node.offset + start - initialOffset
		acceptor.addPosition(offset, name.length, style)
	}

	def dispatch highlight(WMixin mixin, ICompositeNode node, IHighlightedPositionAcceptor acceptor) {
		val startKeyword = node.text.indexOf(MIXIN)
		addHighlight(startKeyword, MIXIN, mixin.name, node, acceptor, COMPONENT_STYLE_ID)
		super.highlightElement(mixin, acceptor, cancelIndicator)
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