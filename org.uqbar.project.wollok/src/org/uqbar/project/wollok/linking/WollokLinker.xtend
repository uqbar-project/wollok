package org.uqbar.project.wollok.linking

import com.google.common.collect.Multimap
import com.google.inject.Inject
import com.google.inject.Singleton
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.diagnostics.IDiagnosticProducer
import org.eclipse.xtext.linking.lazy.LazyLinker
import org.eclipse.xtext.linking.lazy.SyntheticLinkingSupport
import org.eclipse.xtext.nodemodel.INode
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WSuite
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * Customizes the xtext linker in order to set
 * the implicit relation between each class and Object superclass
 * 
 * @author npasserini
 */
@Singleton
class WollokLinker extends LazyLinker {
	@Inject
	var SyntheticLinkingSupport syntheticLinkingSupport
	
	override def installProxies(EObject obj, IDiagnosticProducer producer,
		Multimap<EStructuralFeature.Setting, INode> settingsToLink) {

		super.installProxies(obj, producer, settingsToLink)

		if (obj.shouldSetParent) {
			syntheticLinkingSupport.createAndSetProxy(obj, obj.parentRef, 'Object')
		}
	}
	
	
	def dispatch shouldSetParent(WClass it) { parent === null && name != 'Object' } // this should check the FQN name !
	def dispatch shouldSetParent(WMixin obj) { false }
	def dispatch shouldSetParent(WMethodContainer it) { parent === null }
	def dispatch shouldSetParent(WSuite it) { false } 
	def dispatch shouldSetParent(EObject obj) { false }

	def dispatch EReference getParentRef(WClass wClass) { WollokDslPackage.Literals.WCLASS__PARENT }
	def dispatch EReference getParentRef(WNamedObject wObject) { WollokDslPackage.Literals.WNAMED_OBJECT__PARENT }
	def dispatch EReference getParentRef(WObjectLiteral wObject) { WollokDslPackage.Literals.WOBJECT_LITERAL__PARENT }
	def dispatch EReference getParentRef(EObject wObject) { null }
}
