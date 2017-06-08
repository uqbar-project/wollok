package org.uqbar.project.wollok.ui.contentassist

import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.uqbar.project.wollok.ui.WollokActivator
import org.uqbar.project.wollok.wollokDsl.WMember
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.ui.Messages

@Accessors
class WollokProposalBuilder {
	boolean displayFullFqn = false
	String reference
	WMember member
	static String imagePath = 'icons/wollok-icon-method_16.png'
	ContentAssistContext context
	
	def getProposal() {
		this.validate()
		var WollokProposal result = new WollokProposal(reference, member, WollokActivator.getInstance.getImageDescriptor(imagePath).createImage,context)
		result.isCalledFromSelf = displayFullFqn
		result
	}
	
	def private validate() {
		if (reference ===null || member === null || context === null)
			throw new WollokRuntimeException(Messages.WollokProposal_cannot_instantiate)
	}
	
	
}