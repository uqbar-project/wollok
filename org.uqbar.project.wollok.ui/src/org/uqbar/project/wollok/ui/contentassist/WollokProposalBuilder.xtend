package org.uqbar.project.wollok.ui.contentassist

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.ui.Messages
import org.uqbar.project.wollok.ui.WollokActivator
import org.uqbar.project.wollok.wollokDsl.WMember
import org.uqbar.project.wollok.wollokDsl.WMethodContainer

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

@Accessors
class WollokProposalBuilder {
	boolean displayFullFqn = false
	String reference
	WMember member
	EObject model
	int priority
	List<WMethodContainer> classHierarchy = newArrayList
	static String imagePath = 'icons/wollok-icon-method_16.png'
	ContentAssistContext context
	
	def getProposal() {
		this.validate()
		var WollokProposal result = new WollokProposal(reference, member, WollokActivator.getInstance.getImageDescriptor(imagePath).createImage, priority, context, model)
		result.isCalledFromSelf = displayFullFqn
		result
	}
	
	def private validate() {
		if (reference === null || member === null || context === null)
			throw new WollokRuntimeException(Messages.WollokProposal_cannot_instantiate)
	}
	
	def void assignPriority() {
		validate()
		if (model === null || member.declaringContext === null) return;
		classHierarchy = model.declaringContext.linearizeHierarchy.reverse 
		priority = (classHierarchy.indexOf(member.declaringContext) + 1) * 10 
	}
	
}