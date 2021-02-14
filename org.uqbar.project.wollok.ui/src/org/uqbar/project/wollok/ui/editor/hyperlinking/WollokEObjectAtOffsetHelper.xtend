package org.uqbar.project.wollok.ui.editor.hyperlinking

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.resource.EObjectAtOffsetHelper
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.scoping.WollokGlobalScopeProvider
import org.uqbar.project.wollok.wollokDsl.Import
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

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
	@Inject
	WollokGlobalScopeProvider scopeProvider

	override protected findCrossReferenceNode(INode node) {
		val semantic = node?.semanticElement
		if (semantic !== null && semantic.isCrossReference(node)) {
			node
		} else {
			super.findCrossReferenceNode(node)
		}
	}
	
	protected def dispatch isCrossReference(EObject it, INode node) { false }
	protected def dispatch isCrossReference(WConstructorCall it, INode node) { false }
	protected def dispatch isCrossReference(WMemberFeatureCall it, INode node) { isResolvedToMethod }
	protected def dispatch isCrossReference(WSuperInvocation it, INode node) { !isInMixin }
	protected def dispatch isCrossReference(Import it, INode node) { node.text != "*" }
	
	def boolean isResolvedToMethod(WMemberFeatureCall it) { resolveMethod(classFinder) !== null }
	
	override getCrossReferencedElement(INode node) {
		try {
			val ref = node.semanticElement.resolveReference(node)
			if (ref !== null)
				ref
			else
				super.getCrossReferencedElement(node)
		}
		catch (UnresolvableCrossReference e) {
			null
		}
	}
	
	def dispatch EObject resolveReference(EObject it, INode node) { null }
	def dispatch EObject resolveReference(WConstructorCall it, INode node) { null }
	def dispatch EObject resolveReference(WMemberFeatureCall it, INode node) { resolveMethod(classFinder) }
	def dispatch EObject resolveReference(WSuperInvocation it, INode node) { superMethod }
	def dispatch EObject resolveReference(Import it, INode node) {
		val found = it.getScope(scopeProvider).getElements(upTo(node.text).toFQN)
		if (found.empty)
			throw new UnresolvableCrossReference
		else
			found.get(0).EObjectOrProxy			
	}

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