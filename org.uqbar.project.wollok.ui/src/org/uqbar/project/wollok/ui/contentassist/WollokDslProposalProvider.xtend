package org.uqbar.project.wollok.ui.contentassist

import org.eclipse.emf.ecore.EObject
import org.eclipse.swt.graphics.Image
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WCollectionLiteral
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WNullLiteral
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WThis
import org.uqbar.project.wollok.wollokDsl.WVariableReference

/**
 * 
 * @author jfernandes
 */
class WollokDslProposalProvider extends AbstractWollokDslProposalProvider {
	//@Inject
  	//protected WollokDslTypeSystem system
	
	override completeWMemberFeatureCall_Feature(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		val call = model as WMemberFeatureCall
		memberProposalsForTarget(call.memberCallTarget, assignment, context, acceptor)
	}

	def dispatch void memberProposalsForTarget(WVariableReference reference, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
// WITHOUT - XSEMANTICS
// TODO: Hacer un extension point
//		reference.ref.type.allMessages.forEach[m| if (m != null) acceptor.addProposal(context, m.asProposal, WollokActivator.getInstance.getImageDescriptor('icons/wollok-icon-method_16.png').createImage)]
//			reference.ref.messagesSentTo.forEach[m| acceptor.addProposal(context, m.asProposalText, m.image)]
	}
/* 
	def asProposal(MessageType message) {
		message.name + "(" + message?.parameterTypes.map[p| p.asParamName ].join(", ") + ")" 
	}
	
	def dispatch String asParamName(WollokType type) { type.name }
	def dispatch String asParamName(StructuralType type) { "anObj" }
	def dispatch String asParamName(ObjectLiteralWollokType type) { "anObj" }
	
	def type(WReferenciable r) {
		val env = system.emptyEnvironment()
		val e = r.eResource.contents.filter(WFile).head.body
		system.inferTypes(env, e)
		system.queryTypeFor(env, r).first
	}
*/	
	// default hace super
	def dispatch void memberProposalsForTarget(WExpression expression, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		super.completeWMemberFeatureCall_Feature(expression, assignment, context, acceptor)
	}
		
	// *****************************
	// ** proposing methods and how they are completed
	// *****************************
	
	def asProposalText(WMemberFeatureCall call) {
		call.feature + "(" + call.memberCallArguments.map[asProposalParameter].join(",") + ")"
	}
	
	def dispatch asProposalParameter(WVariableReference r) {  r.ref.name }
	def dispatch asProposalParameter(WClosure c) { '''[«c.parameters.map[":" + name].join(" ")»| ]''' }
	def dispatch asProposalParameter(WBooleanLiteral c) { "aBoolean" }
	def dispatch asProposalParameter(WNumberLiteral c) { "aNumber" }
	def dispatch asProposalParameter(WStringLiteral c) { "aString" }
	def dispatch asProposalParameter(WCollectionLiteral c) { "aCollection" }
	def dispatch asProposalParameter(WObjectLiteral c) { "anObject" }
	def dispatch asProposalParameter(WNullLiteral c) { "null" } //mmm
	def dispatch asProposalParameter(WThis c) { "this" } //mmm
	def dispatch asProposalParameter(WExpression r) { "something" }

	// *****************************
	// ** generic extension methods
	// *****************************	
	
	def createProposal(ContentAssistContext context, String methodName, Image image) {
		createCompletionProposal(methodName, methodName, image, context)
	}
	
	def addProposal(ICompletionProposalAcceptor acceptor, ContentAssistContext context, String feature, Image image) {
		if (feature != null) 
			acceptor.accept(context.createProposal(feature, image))
	}

}
