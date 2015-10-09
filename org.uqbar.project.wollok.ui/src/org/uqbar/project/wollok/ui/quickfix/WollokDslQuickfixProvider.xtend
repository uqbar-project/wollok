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
import org.uqbar.project.wollok.ui.Messages
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference
import org.uqbar.project.wollok.wollokDsl.WollokDslFactory
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage

import static org.uqbar.project.wollok.WollokDSLKeywords.*
import static org.uqbar.project.wollok.validation.WollokDslValidator.*

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.ui.quickfix.QuickFixUtils.*
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.WollokDSLKeywords
import org.eclipse.xtext.ui.editor.model.edit.IModificationContext

/**
 * Custom quickfixes.
 *
 * see http://www.eclipse.org/Xtext/documentation.html#quickfixes
 */
class WollokDslQuickfixProvider extends DefaultQuickfixProvider {

	@Fix(WollokDslValidator.CLASS_NAME_MUST_START_UPPERCASE)
	def capitalizeName(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_capitalize_name, Messages.WollokDslQuickfixProvider_capitalize_description, null) [ 
			xtextDocument => [
				val firstLetter = get(issue.offset, 1)
				replace(issue.offset, 1, firstLetter.toUpperCase)
			]
		]
	}

	@Fix(WollokDslValidator.REFERENCIABLE_NAME_MUST_START_LOWERCASE)
	def toLowerCaseReferenciableName(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_lowercase_name, Messages.WollokDslQuickfixProvider_lowercase_description, null) [ 
			xtextDocument => [
				val firstLetter = get(issue.offset, 1)
				replace(issue.offset, 1, firstLetter.toLowerCase)
			]
		]
	}

	@Fix(WollokDslValidator.CANNOT_ASSIGN_TO_VAL)
	def changeDeclarationToVar(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_changeToVar_name, Messages.WollokDslQuickfixProvider_changeToVar_description, null) [ e, context |
			val feature = (e as WAssignment).feature
			if (feature instanceof WVariableDeclaration) {
				context.xtextDocument.replace(feature.before, feature.node.length,
					VAR + " " + feature.ref.name + " =" + feature.right.node.text)
			}
		]
	}

	@Fix(WollokDslValidator.METHOD_ON_THIS_DOESNT_EXIST)
	def createNonExistingMethod(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_createMethod_name, Messages.WollokDslQuickfixProvider_createMethod_description, null) [ e, context |
			val call = e as WMemberFeatureCall
			val callText = call.node.text
			context.xtextDocument.replace(
				call.method.after,
				0,
				"\n" + "\t" + METHOD + " " + call.feature +
					callText.substring(callText.indexOf('('), callText.lastIndexOf(')') + 1) +
					" {\n\t\t//TODO: " + Messages.WollokDslQuickfixProvider_createMethod_stub + "\n\t}"
			)
		]
	}

	@Fix(WollokDslValidator.METHOD_MUST_HAVE_OVERRIDE_KEYWORD)
	def changeDefToOverride(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Add "override" keyword', 'Add "override" keyword to method.', null) [ e, it |
			xtextDocument.prepend(e, OVERRIDE + ' ')
		]
	}
	
	@Fix(METHOD_DOESNT_OVERRIDE_ANYTHING)
	def addMethodToSuperClass(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Create method in superclass', 'Add new method in superclass.', null) [ e, it |
			val method = e as WMethodDeclaration
			val parent = method.wollokClass.parent
			
			val constructor = '''method «method.name»(«method.parameters.map[name].join(",")») { 
				//TODO: «Messages.WollokDslQuickfixProvider_createMethod_stub»
			}'''
			
			addConstructor(parent, constructor)
		]
	}
	
	@Fix(METHOD_DOESNT_OVERRIDE_ANYTHING)
	def removeOverrideKeyword(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Remove override keyword', 'Remove override keyword.', null) [ e, it |
			xtextDocument.deleteToken(e, WollokDSLKeywords.OVERRIDE)
		]
	}
	
	@Fix(WollokDslValidator.REQUIRED_SUPERCLASS_CONSTRUCTOR)
	def addConstructorsFromSuperclass(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Add constructors from superclass', 'Add same constructors as superclass.', null) [ e, it |
			val clazz = e as WClass
			
			val constructors = clazz.parent.constructors.map[ '''\tnew(«parameters.map[name].join(',')») = super(«parameters.map[name].join(',')»)'''].join('\n')
			addConstructor(clazz, constructors)
		]
	}
	
	@Fix(CONSTRUCTOR_IN_SUPER_DOESNT_EXIST)
	def createConstructorInSuperClass(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Create constructor in superclass', 'Add new constructor in superclass.', null) [ e, it |
			val delegatingConstructor = (e as WConstructor).delegatingConstructorCall
			val parent = e.wollokClass.parent
			
			val constructor = '''new(«(1..delegatingConstructor.arguments.size).map["param" + it].join(",")») { 
				//TODO: «Messages.WollokDslQuickfixProvider_createMethod_stub»
			}'''
			
			addConstructor(parent, constructor)
		]
	}
	
	protected def addConstructor(IModificationContext it, WClass parent, String constructor) {
		val lastConstructor = parent.members.findLast[it instanceof WConstructor]
			if (lastConstructor != null)
				insertAfter(lastConstructor, constructor)
			else {
				val lastVar = parent.members.findLast[it instanceof WVariableDeclaration]
				if (lastVar != null)
					insertAfter(lastVar, constructor)
				else {
					val firstMethod = parent.members.findFirst[it instanceof WMethodDeclaration]
					if (firstMethod != null)
						insertBefore(firstMethod, constructor)
					else {
						xtextDocument.replace(parent.after - 1, 0, constructor)
					}
				}
			}
	} 
	
	@Fix(WollokDslValidator.WARNING_UNUSED_VARIABLE)
	def removeUnusedVariable(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Remove variable', 'Remove unused variable.', null) [ e, it |
			xtextDocument.delete(e)
		]
	}
	
	@Fix(DUPLICATED_CONSTRUCTOR)
	def deleteDuplicatedConstructor(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Remove constructor', 'Remove duplicated constructor.', null) [ e, it |
			xtextDocument.delete(e)
		]
	}
	
	
	@Fix(NATIVE_METHOD_CANNOT_OVERRIDES)
	def removeOverrideFromNativeMethod(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Remove override keyword', 'Remove override keyword.', null) [ e, it |
			xtextDocument.deleteToken(e, OVERRIDE)
		]
	}
	
	@Fix(DUPLICATED_METHOD)
	def removeDuplicatedMethod(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Remove method', 'Remove duplicated method.', null) [ e, it |
			xtextDocument.delete(e)
		]
	}
	
	@Fix(MUST_CALL_SUPER)
	def addCallToSuperInConstructor(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Add call to super', 'Add call to super.', null) [ e, it |
			val const = e as WConstructor
			val call = " = super()" // this could be more involved here and useful for the user :P
			val paramCloseOffset = const.node.text.indexOf(")")
			xtextDocument.replace(e.before + paramCloseOffset - 1, 0, call)
		]
	}
	
	@Fix(WollokDslValidator.ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS)
	def addCatchOrAlwaysToTry(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Add a "catch" statement', 'Add a "catch" statement".', null) [ e, context |
			context.insertAfter(e, 
				'''
				catch e : wollok.lang.Exception {
					// TODO: «Messages.WollokDslQuickfixProvider_createMethod_stub»
					throw e
				}'''
			)
		]

		acceptor.accept(issue, 'Add an "always" statement', 'Add an "always" statement".', null) [ e, context |
			context.insertAfter(e,
				'''
				then always {
					//TODO: «Messages.WollokDslQuickfixProvider_createMethod_stub»
				}'''
			)			
		]
	}
	
	@Fix(BAD_USAGE_OF_IF_AS_BOOLEAN_EXPRESSION) 
	def wrongUsageOfIfForBooleanExpressions(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Replace if with the condition', 'Removes the if and just leaves the condition.', null) [ e, it |
			val ifE = e as WIfExpression
			xtextDocument.replaceWith(e, ifE.condition)
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
		val xtextDocument = modificationContext.xtextDocument
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
