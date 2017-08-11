package org.uqbar.project.wollok.serializer

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.nodemodel.ICompositeNode
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.linking.WollokLinker
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WNamedObject

/**
 * This syntactic sequencer is aware of synthetic links and ignores them during serialization
 */
class WollokDslSyntacticSequencerWithSyntheticLinking extends WollokDslSyntacticSequencer {
	override void acceptAssignedCrossRefDatatype(RuleCall datatypeRC, String token, EObject value, int index,
		ICompositeNode node) {

		if (!isSynthetic(node, token, value)) {
			super.acceptAssignedCrossRefDatatype(datatypeRC, token, value, index, node)
		}			
	}

	/**
	 * A Cross reference is synthetic if it is not written in code but injected automatically by the linker
	 * @see WollokLinker
	 */	
	def isSynthetic(ICompositeNode node, String token, EObject value) {
		node === null && (token == WollokConstants.ROOT_CLASS || token == WollokConstants.FQN_ROOT_CLASS) && (value instanceof WClass || value instanceof WNamedObject)
	}
}
