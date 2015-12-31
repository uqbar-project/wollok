package org.uqbar.project.wollok.ui.editor.hyperlinking

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.resource.EObjectAtOffsetHelper
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.uqbar.project.wollok.wollokDsl.Import
import org.uqbar.project.wollok.scoping.WollokGlobalScopeProvider
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage
import org.eclipse.xtext.naming.QualifiedName

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
		val semantic = node.semanticElement
		if (isCrossReference(semantic))
			node
		else
			super.findCrossReferenceNode(node)
	}
	
	protected def dispatch isCrossReference(EObject it) { false }
	protected def dispatch isCrossReference(WMemberFeatureCall it) { isResolvedToMethod }
	protected def dispatch isCrossReference(WSuperInvocation it) { true }
	protected def dispatch isCrossReference(Import it) { !importedNamespace.endsWith(".*") }
	
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
	def dispatch resolveReference(Import it) { 
		// hack uses another grammar ereference
		val scope = scopeProvider.getScope(eResource, WollokDslPackage.Literals.WCLASS__PARENT)
		val fqn = QualifiedName.create(importedNamespace.split("\\."))
		val found = scope.getElements(fqn)
		if (found.empty)
			null
		else
			found.get(0).EObjectOrProxy			
	}
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