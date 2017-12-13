package org.uqbar.project.wollok.ui.contentassist

import org.eclipse.emf.ecore.EObject
import org.eclipse.jface.viewers.StyledString
import org.eclipse.jface.viewers.StyledString.Styler
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.Image
import org.eclipse.swt.graphics.TextStyle
import org.eclipse.swt.widgets.Display
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.ui.Messages
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WCollectionLiteral
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WMember
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNullLiteral
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

@Accessors
class WollokProposal {
	String referencePackage
	EObject model
	WMember member
	Image image
	int priority = 0
	ContentAssistContext context
	boolean isCalledFromSelf

	new(String reference, WMember m, Image image, int priority, ContentAssistContext context, EObject model) {
		this.referencePackage = reference
		this.member = m
		this.image = image
		this.context = context
		this.priority = priority
		this.model = model
	}

	def getMethodName() {
		member.asProposal
	}

	def getContainerName() {
		member.getMethodContainer.name
	}

	def getContainerPackage() {
		member.getMethodContainer.packageName
	}

	def getContainerFqn() {
		member.getMethodContainer.getNameWithPackage
	}

	def createProposalStyler() {
		val display = Display.getCurrent()
		new Styler() {

			override applyStyles(TextStyle textStyle) {
				textStyle.foreground = display.getSystemColor(SWT.COLOR_DARK_GRAY)
			}
		}
	}

	def getDisplayMessage() {
		if (member.eContainer.name.toLowerCase.equals(WollokConstants.ROOT_CLASS.toLowerCase) ||
			(isCalledFromSelf && member.declaringContext !== null && model.equals(member.declaringContext)))
			return new StyledString(methodName)

		val fromMessage = new StringBuilder => [
			append(" - ")
			if (member.isInMixin) {
				append(Messages.WollokProposal_from_mixin)
			} else if (member.wollokClass !== null) {
				append(Messages.WollokProposal_from_class)
			} else {
				append(Messages.WollokProposal_from_object)
			}
			append(" ")
			append(containerName)
			if (!containerFqn.equals(referencePackage)) {
				append(" (")
				append(containerPackage)
				append(")")
			}
		]
		(new StyledString(methodName)).append(fromMessage.toString, createProposalStyler)
	}

	def String origin() {
		if(member !== null && member.declaringContext !== null) member.declaringContext.name + "." else ""
	}

	def dispatch asProposal(WMemberFeatureCall call) {
		call.feature + "(" + call.memberCallArguments.map[asProposalParameter].join(",") + ")"
	}

	def dispatch asProposal(WMethodDeclaration it) {
		name + "(" + parameters.map[p|p.name].join(", ") + ")"
	}

	def dispatch asProposalParameter(WVariableReference r) { r.ref.name }

	def dispatch asProposalParameter(WClosure c) { '''[«c.parameters.map[":" + name].join(" ")»| ]''' }

	def dispatch asProposalParameter(WBooleanLiteral c) { "aBoolean" }

	def dispatch asProposalParameter(WNumberLiteral c) { "aNumber" }

	def dispatch asProposalParameter(WStringLiteral c) { "aString" }

	def dispatch asProposalParameter(WCollectionLiteral c) { "aCollection" }

	def dispatch asProposalParameter(WObjectLiteral c) { "anObject" }

	def dispatch asProposalParameter(WNullLiteral c) { WollokConstants.NULL } // mmm

	def dispatch asProposalParameter(WSelf c) { WollokConstants.SELF } // mmm

	def dispatch asProposalParameter(WExpression r) { "something" }
	
	def dispatch asProposalParameter(WVariable v) { v.name }
	
}
