package org.uqbar.project.wollok.ui.quickfix

import com.google.inject.Inject
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.model.IXtextDocument
import org.eclipse.xtext.ui.editor.model.edit.IModificationContext
import org.eclipse.xtext.ui.editor.quickfix.DefaultQuickfixProvider
import org.eclipse.xtext.ui.editor.quickfix.Fix
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor
import org.eclipse.xtext.util.concurrent.IUnitOfWork
import org.eclipse.xtext.validation.Issue
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.ui.Messages
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference
import org.uqbar.project.wollok.wollokDsl.WollokDslFactory
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage

import static org.uqbar.project.wollok.WollokConstants.*
import static org.uqbar.project.wollok.validation.WollokDslValidator.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.ui.quickfix.QuickFixUtils.*

import static extension org.uqbar.project.wollok.utils.XTextExtensions.*
import org.uqbar.project.wollok.wollokDsl.WBlockExpression

/**
 * Custom quickfixes.
 * see http://www.eclipse.org/Xtext/documentation.html#quickfixes
 * 
 * @author jfernandes
 */
class WollokDslQuickfixProvider extends DefaultQuickfixProvider {
	val tabChar = "\t"
	val returnChar = System.lineSeparator
			
	@Inject
	WollokClassFinder classFinder

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
			val f = (e as WAssignment).feature.ref.eContainer
			if (f instanceof WVariableDeclaration) {
				val feature = f as WVariableDeclaration
				context.xtextDocument.replace(feature.before, feature.node.length,
					VAR + " " + feature.variable.name + " =" + feature.right.node.text)
			}
		]
	}

	@Fix(WollokDslValidator.METHOD_ON_WKO_DOESNT_EXIST)
	def createNonExistingMethod(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_createMethod_name, Messages.WollokDslQuickfixProvider_createMethod_description, null) [ e, context |
			val call = e as WMemberFeatureCall
			val callText = call.node.text
			
			val wko = call.resolveWKO(classFinder)
			
			val placeToAdd = wko.findPlaceToAddMethod
			
			context.getXtextDocument(wko.fileURI).replace(
				placeToAdd,
				0,
				System.lineSeparator + "\t" + METHOD + " " + call.feature +
					callText.substring(callText.indexOf('('), callText.lastIndexOf(')') + 1) +
					" {" + System.lineSeparator + "\t\t//TODO: " + Messages.WollokDslQuickfixProvider_createMethod_stub + System.lineSeparator + "\t}"
			)
		]
	}
	
	def int findPlaceToAddMethod(WMethodContainer it) {
		val lastMethod = members.lastOf(WMethodDeclaration)
		if (lastMethod != null)
			return lastMethod.after
		val lastConstructor = members.lastOf(WConstructor)
		if (lastConstructor != null)
			return lastConstructor.after
		val lastInstVar = members.lastOf(WVariableDeclaration)
		if (lastInstVar != null)
			return lastInstVar.after
		
		return it.node.offset + it.node.text.indexOf("{") + 1
	}
	
	def <T> T lastOf(EList<?> l, Class<T> type) { l.findLast[type.isInstance(it)] as T }

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
			
			val constructor = "\t" + '''method «method.name»(«method.parameters.map[name].join(",")»){
		//TODO: «Messages.WollokDslQuickfixProvider_createMethod_stub»
	}''' + System.lineSeparator 
			
			addConstructor(parent, constructor)
		]
	}
	
	@Fix(METHOD_DOESNT_OVERRIDE_ANYTHING)
	def removeOverrideKeyword(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Remove override keyword', 'Remove override keyword.', null) [ e, it |
			xtextDocument.deleteToken(e, OVERRIDE + " ")
		]
	}
	
	@Fix(WollokDslValidator.REQUIRED_SUPERCLASS_CONSTRUCTOR)
	def addConstructorsFromSuperclass(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Add constructors from superclass', 'Add same constructors as superclass.', null) [ e, it |
			val clazz = e as WClass
			val constructors = clazz.parent.constructors.map[ '''«tabChar»constructor(«parameters.map[name].join(',')») = super(«parameters.map[name].join(',')»)«returnChar»'''].join(System.lineSeparator)
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
		// TODO try to generalize and use findPlaceToAddMethod
		
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
	
	@Fix(VARIABLE_NEVER_ASSIGNED)
	def initializeNonAssignedVariable(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Initialize value', 'Initialize.', null) [ e, it |
			xtextDocument.append(e, " = value")
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
			var inlineResult = if (ifE.then.isReturnTrue) ifE.condition.sourceCode else ("!(" + ifE.condition.sourceCode + ")")
			if (ifE.then.hasReturnWithValue) {
				inlineResult = RETURN + " " + inlineResult
			}
			xtextDocument.replaceWith(e, inlineResult)
		]
	}
	
	@Fix(RETURN_FORGOTTEN)
	def prependReturn(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Prepend "return"', 'Adds a "return" keyword', null) [ e, it |
			val method = e as WMethodDeclaration
			val body = (method.expression as WBlockExpression)
			insertBefore(body.expressions.last, RETURN + " ")
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
			context.insertBefore(firstExpressionInContext, VAR + " " + newVarName)
		]

		// create instance var
		issueResolutionAcceptor.accept(issue, 'Create instance variable', 'Create new instance variable.', "variable.gif") [ e, context |
			val newVarName = xtextDocument.get(issue.offset, issue.length)
			val firstClassChild = (e as WExpression).method.declaringContext.eContents.head
			context.insertBefore(firstClassChild, VAR + " " + newVarName)
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
			context.xtextDocument.replace(container.after, 0, System.lineSeparator + CLASS + newClassName + " {" + System.lineSeparator + "}" + System.lineSeparator)
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
