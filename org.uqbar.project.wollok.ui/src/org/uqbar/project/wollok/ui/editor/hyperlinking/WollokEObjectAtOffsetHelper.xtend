package org.uqbar.project.wollok.ui.editor.hyperlinking

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.resource.EObjectAtOffsetHelper
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import com.google.inject.Inject
import org.uqbar.project.wollok.interpreter.WollokClassFinder

/**
 * Extends the default xtext class
 * in order to include navigation for messages->methods.
 * At least for those that have been inferred by the
 * type system.
 * There are cases were using structural types were
 * you cannot have a reference to a particular method
 * 
 * // TODO:
 * (Actually in the future it should search all over types
 * to find compatible methods and suggest you a list of options)
 * 
 * @author jfernandes
 */
//REFACTOR: vuelve a evaluar todo el sistema de tipos del programa 2 veces!
//  una en findCrossReferenceNode()
//  y de nuevo en getCrossReferencedElement()
class WollokEObjectAtOffsetHelper extends EObjectAtOffsetHelper {
	@Inject
	WollokClassFinder classFinder

	override protected findCrossReferenceNode(INode node) {
		val semantic = node.semanticElement
		if (semantic instanceof WMemberFeatureCall && (semantic as WMemberFeatureCall).isResolvedToMethod || semantic instanceof WSuperInvocation)
			node
		else
			super.findCrossReferenceNode(node)
	}
	
	def boolean isResolvedToMethod(WMemberFeatureCall it) { resolveMethod(classFinder) != null }
	
	override getCrossReferencedElement(INode node) {
		val ref = node.semanticElement.resolveReference
		if (ref != null)
			ref
		else
			super.getCrossReferencedElement(node)
	}
	
	def dispatch resolveReference(WMemberFeatureCall it) { resolveMethod(classFinder) }
	def dispatch resolveReference(WSuperInvocation it) { superMethod }
	def dispatch resolveReference(EObject it) { null }
	
/*	

 *TODO: Hacer un extension point
	@Inject
  	protected WollokDslTypeSystem xsemanticsSystem

	def resolveMethod(WMemberFeatureCall call) {
		val env = xsemanticsSystem.emptyEnvironment()
		for (e : (call.eResource.contents.head).eContents) {
			xsemanticsSystem.inferTypes(env, e)
		}
		
		val receiverTypeResult = xsemanticsSystem.type(env, call.memberCallTarget)
		if (receiverTypeResult.failed)
			return null
		val receiverType = receiverTypeResult.first
		val messageTypeResult = xsemanticsSystem.messageType(env, call)
		
		if (!messageTypeResult.failed && receiverType.understandsMessage(messageTypeResult.first))
			if (receiverType instanceof ConcreteType)
				receiverType.lookupMethod(messageTypeResult.first)
			else
				null
		else
			null
		
	}

 */	
	
}