package org.uqbar.project.wollok.ui.quickfix

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.model.IXtextDocument
import org.eclipse.xtext.ui.editor.quickfix.DefaultQuickfixProvider
import org.eclipse.xtext.ui.editor.quickfix.Fix
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor
import org.eclipse.xtext.util.concurrent.IUnitOfWork
import org.eclipse.xtext.validation.Issue
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage

import static org.uqbar.project.wollok.WollokDSLKeywords.*

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.ui.quickfix.QuickFixUtils.*
import org.uqbar.project.wollok.wollokDsl.WollokDslFactory

/**
 * Custom quickfixes.
 *
 * see http://www.eclipse.org/Xtext/documentation.html#quickfixes
 */
class WollokDslQuickfixProvider extends DefaultQuickfixProvider {

	@Fix(WollokDslValidator.CLASS_NAME_MUST_START_UPPERCASE)
	def capitalizeName(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Capitalize name', 'Capitalize the name.', null) [ context |
			context.xtextDocument => [
				val firstLetter = get(issue.offset, 1)
				replace(issue.offset, 1, firstLetter.toUpperCase)
			]
		]
	}

	@Fix(WollokDslValidator.REFERENCIABLE_NAME_MUST_START_LOWERCASE)
	def toLowerCaseReferenciableName(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Change to lowercase', 'Change to lowercase', null) [ context |
			context.xtextDocument => [
				val firstLetter = get(issue.offset, 1)
				replace(issue.offset, 1, firstLetter.toLowerCase)
			]
		]
	}

	@Fix(WollokDslValidator.CANNOT_ASSIGN_TO_VAL)
	def changeDeclarationToVar(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Change declaration to var', 'Change to var.', null) [ e, context |
			val feature = (e as WAssignment).feature
			if (feature instanceof WVariableDeclaration) {
				context.xtextDocument.replace(feature.before, feature.node.length,
					VAR + " " + feature.ref.name + " =" + feature.right.node.text)
			}
		]
	}

	@Fix(WollokDslValidator.METHOD_ON_THIS_DOESNT_EXIST)
	def createNonExistingMethod(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Create new method', 'Create method.', null) [ e, context |
			val call = e as WMemberFeatureCall
			val callText = call.node.text
			context.xtextDocument.replace(
				call.method.after,
				0,
				"\n" + "\t" + METHOD + " " + call.feature +
					callText.substring(callText.indexOf('('), callText.lastIndexOf(')') + 1) +
					" {\n\t\t//TODO: generated stub\n\t}"
			)
		]
	}

	@Fix(WollokDslValidator.METHOD_MUST_HAVE_OVERRIDE_KEYWORD)
	def changeDefToOverride(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Add "override" keyword', 'Add "override" keyword to method.', null) [ e, context |
			context.xtextDocument.replace(e.before, 0, OVERRIDE + ' ')
		]
	}
	
	@Fix(WollokDslValidator.ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS)
	def addCatchOrAlwaysToTry(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Add a "catch" statement', 'Add a "catch" statement".', null) [ e, context |
			context.insertAfter(e, 
				'''
				catch e : wollok.lang.Exception {
					// TODO: auto-generated stub
					throw e
				}'''
			)
		]

		acceptor.accept(issue, 'Add an "always" statement', 'Add an "always" statement".', null) [ e, context |
			context.insertAfter(e,
				'''
				then always {
					// TODO: auto-generated stub
				}'''
			)			
		]
	}

	// ************************************************
	// ** unresolved ref to "elements" quick fixes
	// ************************************************
	
	protected def quickFixForUnresolvedRefToVariable(IssueResolutionAcceptor issueResolutionAcceptor, Issue issue, IXtextDocument xtextDocument) {
		// create local var
		issueResolutionAcceptor.accept(issue, 'Create local variable', 'Create new local variable.', "variable.gif") [ e, context |
			val newVarName = xtextDocument.get(issue.offset, issue.length)
			val firstExpressionInContext = e.block.expressions.head
			context.insertBefore(firstExpressionInContext, "var " + newVarName)
		]

		// create instance var
		issueResolutionAcceptor.accept(issue, 'Create instance variable', 'Create new instance variable.', "variable.gif") [ e, context |
			val newVarName = xtextDocument.get(issue.offset, issue.length)
			val firstClassChild = (e as WExpression).method.declaringContext.eContents.head
			context.insertBefore(firstClassChild, "var " + newVarName)
		]
		
		// create parameter
		issueResolutionAcceptor.accept(issue, 'Add parameter to method', 'Add a new parameter.', "variable.gif") [ e, context |
			val newVarName = xtextDocument.get(issue.offset, issue.length)
			val method = (e as WExpression).method
			method.parameters += (WollokDslFactory.eINSTANCE.createWParameter => [ name = newVarName ])		
		]
	}
	
	protected def quickFixForUnresolvedRefToClass(IssueResolutionAcceptor issueResolutionAcceptor, Issue issue, IXtextDocument xtextDocument) {
		// create local var
		issueResolutionAcceptor.accept(issue, 'Create new class', 'Create a new class definition.', "class.png") [ e, context |
			val newClassName = xtextDocument.get(issue.offset, issue.length)
			val container = (e as WExpression).method.declaringContext
			context.xtextDocument.replace(container.after, 0, "\nclass " + newClassName + " {\n}\n")
		]
		
	}
	// *********************************************
	// ** Unresolved references code (should be generalized into something using reflection as xtext's declarative quickfixes)
		// **   this needs some overriding since xtext doesn't have an extension point or declarative way
	// **   to get in between (they already provide a quick fix to change the reference to some other similar variable name)
	// *********************************************
	
	override createLinkingIssueResolutions(Issue issue, IssueResolutionAcceptor issueResolutionAcceptor) {
		super.createLinkingIssueResolutions(issue, issueResolutionAcceptor)

		// adding "create for unresolved references"		
		val modificationContext = modificationContextFactory.createModificationContext(issue);
		val xtextDocument = modificationContext.getXtextDocument();
		if (xtextDocument == null)
			return;
		xtextDocument.readOnly(
			new IUnitOfWork.Void<XtextResource>() {
				override process(XtextResource state) throws Exception {
					val target = state.getEObject(issue.uriToProblem.fragment)
					val reference = getUnresolvedEReference(issue, target)
					if (reference == null)
						return;
					quickFixUnresolvedRef(target, reference, issueResolutionAcceptor, issue, xtextDocument)
				}
			})
	}

	protected def quickFixUnresolvedRef(EObject target, EReference reference,
		IssueResolutionAcceptor issueResolutionAcceptor, Issue issue, IXtextDocument xtextDocument) {
		if (target instanceof WVariableReference && reference.EType == WollokDslPackage.Literals.WREFERENCIABLE && reference.name == "ref") {
			quickFixForUnresolvedRefToVariable(issueResolutionAcceptor, issue, xtextDocument)
		}
		else if (reference.EType == WollokDslPackage.Literals.WCLASS) {
			quickFixForUnresolvedRefToClass(issueResolutionAcceptor, issue, xtextDocument)
		}
	}

}
