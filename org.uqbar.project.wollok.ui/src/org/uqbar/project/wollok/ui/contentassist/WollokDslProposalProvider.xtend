package org.uqbar.project.wollok.ui.contentassist

import org.eclipse.core.runtime.Platform
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.CrossReference
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.ui.Messages
import org.uqbar.project.wollok.ui.WollokActivator
import org.uqbar.project.wollok.ui.labeling.WollokTypeSystemLabelExtension
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WListLiteral
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WSetLiteral
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static extension org.uqbar.project.wollok.errorHandling.HumanReadableUtils.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 *
 * @author jfernandes
 * @author dodain
 * 
 * @see    https://www.eclipse.org/Xtext/documentation/310_eclipse_support.html#content-assist
 * 
 */
class WollokDslProposalProvider extends AbstractWollokDslProposalProvider {
	val extension BasicTypeResolver typeResolver = new BasicTypeResolver
	val extension WollokClassFinder classFinder = WollokClassFinder.getInstance
	
	WollokProposalBuilder builder
	
	// Type System
	WollokTypeSystemLabelExtension labelExtension = null
	boolean labelExtensionResolved = false

	def obtainLabelExtension() {
		if (!labelExtensionResolved) {
			labelExtension = resolveLabelExtension
			labelExtensionResolved = true
		}
		labelExtension
	}
	
	def synchronized getAllMethods(EObject obj) {
		if (!obj.isTypeSystemEnabled)
			return (obj as WMethodContainer).allUntypedMethods
		else {
		val tsLabelExtension = obtainLabelExtension
			if (tsLabelExtension !== null)
				tsLabelExtension.allMethods(obj)
			else
				newArrayList
		}
	}

	def boolean isTypeSystemEnabled(EObject obj) {
		obtainLabelExtension.isTypeSystemEnabled(obj)
	}

	def resolveLabelExtension() {
		val configPoints = Platform.getExtensionRegistry.getConfigurationElementsFor(
			"org.uqbar.project.wollok.ui.wollokTypeSystemLabelExtension")

		if (configPoints.empty)
			null
		else
			configPoints.get(0).createExecutableExtension("class") as WollokTypeSystemLabelExtension
	}
	
	
	override complete_WConstructorCall(EObject model, RuleCall ruleCall, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		if (model instanceof WConstructorCall) {
			val initializations = (model as WConstructorCall).createInitializersForNamedParametersInConstructor
			acceptor.accept(createCompletionProposal(initializations, Messages.WollokTemplateProposalProvider_WConstructorCallWithNamedParameter_name, WollokActivator.getInstance.getImageDescriptor('icons/assignment.png').createImage, context))
		}
		super.complete_WConstructorCall(model, ruleCall, context, acceptor)
	}
	
	override completeWMemberFeatureCall_Feature(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		val call = model as WMemberFeatureCall
		builder = new WollokProposalBuilder
		builder.context = context
		memberProposalsForTarget(call.memberCallTarget, assignment, acceptor)

		// still call super for global objects and other stuff
		super.completeWMemberFeatureCall_Feature(model, assignment, context, acceptor)
	}

	// default
	def dispatch void memberProposalsForTarget(WExpression expression, Assignment assignment, ICompletionProposalAcceptor acceptor) {
		if (expression instanceof WConstructorCall) {
			val constructorCall = expression as WConstructorCall
			constructorCall.classRef?.methodsAsProposals(acceptor)
			return
		}
		if (expression.isTypeSystemEnabled) {
			completeProposalsFor(expression, acceptor)
		}
	}

	// literals
	def dispatch void memberProposalsForTarget(WListLiteral expression, Assignment assignment, ICompletionProposalAcceptor acceptor) {
		(expression.listClass as WMethodContainer).methodsAsProposals(acceptor)
	}

	def dispatch void memberProposalsForTarget(WSetLiteral expression, Assignment assignment, ICompletionProposalAcceptor acceptor) {
		(expression.setClass as WMethodContainer).methodsAsProposals(acceptor)
	}

	def dispatch void memberProposalsForTarget(WBooleanLiteral expression, Assignment assignment, ICompletionProposalAcceptor acceptor) {
		(expression.booleanClass as WMethodContainer).methodsAsProposals(acceptor)
	}

	def dispatch void memberProposalsForTarget(WClosure expression, Assignment assignment, ICompletionProposalAcceptor acceptor) {
		(expression.closureClass as WMethodContainer).methodsAsProposals(acceptor)
	}
	
	def dispatch void memberProposalsForTarget(WStringLiteral expression, Assignment assignment, ICompletionProposalAcceptor acceptor) {
		(expression.stringClass as WMethodContainer).methodsAsProposals(acceptor)
	}
	
	def dispatch void memberProposalsForTarget(WNumberLiteral expression, Assignment assignment, ICompletionProposalAcceptor acceptor) {
		(expression.numberClass as WMethodContainer).methodsAsProposals(acceptor)
	}
	
	// to a variable
	def dispatch void memberProposalsForTarget(WVariableReference ref, Assignment assignment, ICompletionProposalAcceptor acceptor) {
		val referencedElement = ref.ref
		if (referencedElement.isTypeSystemEnabled)
			completeProposalsFor(referencedElement, acceptor)
		else
			memberProposalsForTarget(referencedElement, assignment, acceptor)
	}

	// any referenciable shows all messages that you already sent to it
	def dispatch void memberProposalsForTarget(WReferenciable ref, Assignment assignment, ICompletionProposalAcceptor acceptor) {
		if (ref.isTypeSystemEnabled)
			completeProposalsFor(ref, acceptor)
		else 
			ref.messageSentAsProposals(acceptor)
	}

	// for variables tries to resolve the type based on the initial value (for literal objects like strings, lists, etc)
	def dispatch void memberProposalsForTarget(WVariable ref, Assignment assignment, ICompletionProposalAcceptor acceptor) {
		if (ref.isTypeSystemEnabled) {
			completeProposalsFor(ref, acceptor)
			return
		}
		val WMethodContainer type = ref.resolveType
		if (type !== null) {
			type.methodsAsProposals(acceptor)
		}
		else {
			ref.messageSentAsProposals(acceptor)
		}
	}
	
	protected def void completeProposalsFor(EObject o, ICompletionProposalAcceptor acceptor) {
		val allMessages = o.allMethods
		allMessages.forEach [ method | 
			builder.model = method
			builder.reference = method.methodContainer.nameWithPackage
			addProposal(method, acceptor)
		]
	}

	// message to WKO's (shows the object's methods)
	def dispatch void memberProposalsForTarget(WNamedObject ref, Assignment assignment, ICompletionProposalAcceptor acceptor) {
		ref.methodsAsProposals(acceptor)
	}

	// messages to this
	def dispatch void memberProposalsForTarget(WSelf mySelf, Assignment assignment, ICompletionProposalAcceptor acceptor) {
		builder.displayFullFqn = true
		mySelf.declaringContext.methodsAsProposals(acceptor)
	}

	// *****************************
	// ** proposing methods and how they are completed
	// *****************************

	def messageSentAsProposals(WReferenciable ref, ICompletionProposalAcceptor acceptor) {
		builder.reference = ref.methodContainer.nameWithPackage
		ref.allMessageSent.filter[feature !== null].forEach[ addProposal( it, acceptor) ]
	}
	
	def methodsAsProposals(WMethodContainer ref, ICompletionProposalAcceptor acceptor) {
		builder.model = ref
		builder.reference = ref.nameWithPackage
		// @Dodain - kind of hack to retrieve getters and setters from properties 
		builder.accessorKind = Accessor.GETTER
		ref.allPropertiesGetters.forEach [ addProposal(it, acceptor) ]
		builder.accessorKind = Accessor.SETTER
		ref.allPropertiesSetters.forEach [ addProposal(it, acceptor) ]
		builder.accessorKind = Accessor.NONE
		println(ref.allMethods)
		ref.allMethods.forEach[ addProposal(it, acceptor) ]
	}

	def addProposal(EObject o, ICompletionProposalAcceptor acceptor) {
		builder.member = o
		builder.assignPriority
		acceptor.addProposal(builder.proposal)
	}

	// *****************************
	// ** generic extension methods
	// *****************************

	def addProposal(ICompletionProposalAcceptor acceptor, WollokProposal aProposal) {
		if (aProposal === null) return;
		val proposal = createCompletionProposal(aProposal.methodName, aProposal.displayMessage, aProposal.image, aProposal.priority, aProposal.prefix, aProposal.context)
		acceptor.accept(proposal)
		if (proposal instanceof ConfigurableCompletionProposal) {
			proposal.additionalProposalInfo = WollokActivator.getInstance.multilineProvider.getDocumentation(aProposal.member)
		}
	}
	
	// ****************************************
	// ** imports
	// ****************************************

	override completeImport_ImportedNamespace(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		val alreadyImported = model.file.importedDefinitions
		val content = model.file.allPossibleImports.filter [ element |
			val containerFqn = element.fqn
			val containerQn = QualifiedName.create(containerFqn.split("\\."))
			alreadyImported.forall [ deresolve(containerQn) === null ]  
		]
		// add other files content here

		content.forEach[
			acceptor.accept(createCompletionProposal(fqn, fqn, image, context))
		]
	}

	override completeWConstructorCall_ClassRef(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		lookupCrossReference((assignment.terminal as CrossReference), context, new ConstructorCallAcceptorDelegate(acceptor))
	}

}
