package org.uqbar.project.wollok.ui.contentassist

import org.eclipse.jface.text.contentassist.ICompletionProposal
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor

import static extension org.uqbar.project.wollok.utils.ProposalUtils.*

class ConstructorCallAcceptorDelegate extends ICompletionProposalAcceptor.Delegate {

	new(ICompletionProposalAcceptor acceptor) {
		super(acceptor)
	}
	 
	override accept(ICompletionProposal originalProposal) {
		super.accept(originalProposal?.enhance)
	}

	def dispatch ICompletionProposal enhance(ICompletionProposal proposal) {
		proposal
	}
	
	def dispatch ICompletionProposal enhance(ConfigurableCompletionProposal proposal) {
		if (proposal !== null && proposal.replacementString !== null) {
			proposal.replacementString = proposal.className + "()"
		}
		proposal
	}
	
	override canAcceptMoreProposals() {
		true
	}

}

