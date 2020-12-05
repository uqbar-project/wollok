package org.uqbar.project.wollok.ui.quickfix

import com.google.inject.Inject
import java.util.List
import org.eclipse.core.resources.IResource
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.model.IXtextDocument
import org.eclipse.xtext.ui.editor.model.edit.IModificationContext
import org.eclipse.xtext.ui.editor.quickfix.DefaultQuickfixProvider
import org.eclipse.xtext.ui.editor.quickfix.Fix
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor
import org.eclipse.xtext.util.concurrent.IUnitOfWork
import org.eclipse.xtext.validation.Issue
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.ui.Messages
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference
import org.uqbar.project.wollok.wollokDsl.WollokDslFactory
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage
import org.uqbar.project.wollok.scoping.WollokGlobalScopeProvider
import org.eclipse.osgi.util.NLS

import static org.uqbar.project.wollok.WollokConstants.*
import static org.uqbar.project.wollok.validation.WollokDslValidator.*

import static extension java.lang.Math.*
import static extension org.uqbar.project.wollok.errorHandling.HumanReadableUtils.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.ui.quickfix.QuickFixUtils.*
import static extension org.uqbar.project.wollok.utils.XTextExtensions.*
import static extension org.uqbar.project.wollok.utils.StringUtils.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * Custom quickfixes.
 * see https://eclipse.org/Xtext/documentation/310_eclipse_support.html#quick-fixes
 * 
 * @author jfernandes
 * @author tesonep
 * @author dodain
 */
class WollokDslQuickfixProvider extends DefaultQuickfixProvider {

	@Inject
	WollokClassFinder classFinder
	
	@Inject
	WollokGlobalScopeProvider scopeProvider

	/** 
	 * ***********************************************************************
	 * 					     Capitalization & Lowercase
	 * ***********************************************************************
	 */
	@Fix(WollokDslValidator.CLASS_NAME_MUST_START_UPPERCASE)
	def capitalizeName(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_capitalize_name,
			Messages.WollokDslQuickfixProvider_capitalize_description, null) [ e, it |
			val firstLetter = xtextDocument.get(issue.offset, 1)
			applyRefactor(e, it.xtextDocument, issue, firstLetter.toUpperCase)
		]
	}
	
	@Fix(WollokDslValidator.PARAMETER_NAME_MUST_START_LOWERCASE)
	def toLowerCaseParameterName(Issue issue, IssueResolutionAcceptor acceptor) {
		toLowerCaseReferenciableName(issue, acceptor)
	}

	@Fix(WollokDslValidator.OBJECT_NAME_MUST_START_LOWERCASE)
	def toLowerCaseObjectName(Issue issue, IssueResolutionAcceptor acceptor) {
		toLowerCaseReferenciableName(issue, acceptor)
	}

	@Fix(WollokDslValidator.VARIABLE_NAME_MUST_START_LOWERCASE)
	def toLowerCaseVariableName(Issue issue, IssueResolutionAcceptor acceptor) {
		toLowerCaseReferenciableName(issue, acceptor)
	}

	@Fix(WollokDslValidator.REFERENCIABLE_NAME_MUST_START_LOWERCASE)
	def toLowerCaseReferenciableName(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_lowercase_name,
			Messages.WollokDslQuickfixProvider_lowercase_description, null) [ e, it |
			val firstLetter = xtextDocument.get(issue.offset, 1)
			applyRefactor(e, it.xtextDocument, issue, firstLetter.toLowerCase)
		]
	}

	/** 
	 * ***********************************************************************
	 * 							Constructors
	 * ***********************************************************************
	 */
	@Fix(WollokDslValidator.REQUIRED_SUPERCLASS_CONSTRUCTOR)
	def addConstructorsFromSuperclass(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_add_constructors_superclass_name,
			Messages.WollokDslQuickFixProvider_add_constructors_superclass_description, null) [ e, it |
			val _object = e as WNamedObject
			val firstConstructor = _object.parent.constructors.map['''(«parameters.map[name].join(',')») '''].head
			xtextDocument.replace(issue.offset + issue.length, 0, firstConstructor)
		]
	}

	@Fix(WRONG_NUMBER_ARGUMENTS_CONSTRUCTOR_CALL)
	def createConstructorInClass(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_create_constructor_class_name,
			Messages.WollokDslQuickFixProvider_create_constructor_class_description, null) [ e, it |
			val call = e as WConstructorCall
			val clazz = call.classRef
			val constructor = call.defaultStubConstructor.toString 
			clazz.insertConstructor(constructor, it)
		]
	}

	@Fix(WRONG_NUMBER_ARGUMENTS_CONSTRUCTOR_CALL)
	def adjustConstructorCall(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_adjust_constructor_call_name,
			Messages.WollokDslQuickFixProvider_adjust_constructor_call_description, null) [ e, it |
			val call = e as WConstructorCall
			val clazz = call.classRef
			val numberOfParameters = call.arguments.size
			val constructors = clazz.constructors.sortBy [ a | (a.parameters.size - numberOfParameters).abs ]
			var paramsSize = 0
			var WConstructor constructor = null
			if (!constructors.isEmpty) {
				constructor = constructors.head
				paramsSize = constructor.parameters.size
			}
			val diffSize = numberOfParameters - paramsSize
			var List<String> newParams = newArrayList
			val List<String> paramsConstructor = if (constructor === null) newArrayList else constructor.parameters.map [ name ]
			if (diffSize < 0) {
				newParams = (call.arguments.map [ node.text.trim ]
					+ ((1..diffSize.abs).map [ paramsConstructor.get(it + numberOfParameters - 1) ])).toList
			} else {
				newParams =	call.arguments.subList(0, paramsSize)
					.map [ node.text.trim ].toList
			}
			val newConstructorCall = INSTANTIATION + " " + clazz.name + "(" +
				newParams.join(", ") + ")"
			xtextDocument.replaceWith(call, newConstructorCall)
		]
	}

	@Fix(CONSTRUCTOR_IN_SUPER_DOESNT_EXIST)
	def createConstructorInSuperClass(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_create_constructor_superclass_name,
			Messages.WollokDslQuickFixProvider_create_constructor_superclass_description, null) [ e, it |
			val delegatingConstructor = (e as WConstructor).delegatingConstructorCall
			val parent = e.wollokClass.parent

			val constructor = '''
				«tabChar»constructor(«(1..delegatingConstructor.arguments.size).map["param" + it].join(",")»){
				«tabChar»«tabChar»//TODO: «Messages.WollokDslQuickfixProvider_createMethod_stub»
				«tabChar»}'''

			parent.insertConstructor(constructor, it)
		]
	}

	@Fix(DUPLICATED_CONSTRUCTOR)
	def deleteDuplicatedConstructor(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_remove_constructor_name,
			Messages.WollokDslQuickFixProvider_remove_constructor_description, null) [ e, it |
			xtextDocument.delete(e)
		]
	}

	@Fix(WollokDslValidator.PROPERTY_ONLY_ALLOWED_IN_CERTAIN_METHOD_CONTAINERS)
	def deleteBadPropertyDefinition(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_remove_property_definition_name,
			Messages.WollokDslQuickFixProvider_remove_property_definition_description, null) [ e, it |
			xtextDocument.deleteToken(e, WollokConstants.PROPERTY)
		]
	}

	@Fix(UNNECESARY_OVERRIDE)
	def deleteUnnecesaryOverride(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_remove_method_name,
			Messages.WollokDslQuickFixProvider_remove_method_description, null) [ e, it |
			xtextDocument.delete(e)
		]
	}

	@Fix(ASSIGNMENT_INSIDE_IF)
	def replaceAssignmentWithComparison(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_replace_assignment_with_comparison_name,
			Messages.WollokDslQuickFixProvider_replace_assignment_with_comparison_description, null) [ e, it |
			val ^if = e as WIfExpression
			val assignment = ^if.condition as WAssignment
			val comparison = assignment.feature.node.text.trim + " == " + assignment.value.node.text.trim
			xtextDocument.replaceWith(assignment, comparison)
		]
	}

	@Fix(MUST_CALL_SUPER)
	def addCallToSuperInConstructor(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_add_call_super_name,
			Messages.WollokDslQuickFixProvider_add_call_super_description, null) [ e, it |
			val const = e as WConstructor
			val call = " = super()" // this could be more involved here and useful for the user :P
			val paramCloseOffset = const.node.text.indexOf(")")
			xtextDocument.replace(e.before + paramCloseOffset - 1, 0, call)
		]
	}

	@Fix(WollokDslValidator.ATTRIBUTE_NOT_FOUND_IN_NAMED_PARAMETER_CONSTRUCTOR)
	def deleteUnexistentAttributeInConstructorCall(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_remove_attribute_initialization_name,
			Messages.WollokDslQuickFixProvider_remove_attribute_initialization_description, null) [ e, it |
			val additional = if (e.hasEffectiveNextSibling) e.effectiveNextSibling.offset - e.node.endOffset else 0
			val before = if (!e.hasEffectiveNextSibling && e.hasEffectivePreviousSibling) e.node.offset - e.effectivePreviousSibling.endOffset else 0
			xtextDocument.replace(e.before - before, e.node.length + additional + before, "")
		]
	}

	@Fix(WollokDslValidator.MISSING_ASSIGNMENTS_IN_NAMED_PARAMETER_CONSTRUCTOR)
	def addMissingAttributesInConstructorCall(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_add_missing_initializations_name,
			Messages.WollokDslQuickFixProvider_add_missing_initializations_description, null) [ e, it |
			val call = e as WConstructorCall
			val preffix = if (call.hasNamedParameters) ", " else ""  
			val initializations = preffix + call.createInitializersForNamedParametersInConstructor
			xtextDocument.replace(e.node.endOffset - 1, 0, initializations)
		]
	}

	/** 
	 * ***********************************************************************
	 * 							Getters
	 * ***********************************************************************
	 */
	@Fix(WollokDslValidator.GETTER_METHOD_SHOULD_RETURN_VALUE)
	def addReturnVariable(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_return_variable_name,
			Messages.WollokDslQuickfixProvider_return_variable_description, null) [ e, context |
			val method = e as WMethodDeclaration
			if (!method.expressionReturns) {
				val body = method.expression as WBlockExpression
				if (body.expressions.empty) {
					context.xtextDocument.replaceWith(body,
						"{" + System.lineSeparator + "\t\t" + RETURN + " " + method.name + System.lineSeparator + "\t}")
				} else
					context.insertAfter(body.expressions.last, RETURN + " " + method.name)
			}
		]
	}

	@Fix(GETTER_METHOD_SHOULD_RETURN_VALUE)
	def prependReturnForGetter(Issue issue, IssueResolutionAcceptor acceptor) {
		prependReturn(issue, acceptor)
	}

	@Fix(RETURN_FORGOTTEN)
	def prependReturn(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_return_last_expression_name,
			Messages.WollokDslQuickfixProvider_return_last_expression_description, null) [ e, it |
			val method = e as WMethodDeclaration
			val body = (method.expression as WBlockExpression)
			if (!body.expressions.empty)
				insertJustBefore(body.expressions.last, RETURN + " ")
		]
	}

	@Fix(CANT_USE_RETURN_EXPRESSION_IN_ARGUMENT)
	def removeReturnKeyword(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_remove_return_keyword_name,
			Messages.WollokDslQuickFixProvider_remove_return_keyword_description, null) [ e, it |
			xtextDocument.deleteToken(e, RETURN + blankSpace)
		]
	}
	/** 
	 * ***********************************************************************
	 * 							Unexistent methods
	 * ***********************************************************************
	 */
	@Fix(WollokDslValidator.METHOD_ON_WKO_DOESNT_EXIST_SEVERAL_ARGS)
	def createNonExistingMethodWKO(Issue issue, IssueResolutionAcceptor acceptor) {
		createNonExistingMethodOnWKO(issue, acceptor)
	}

	@Fix(WollokDslValidator.PROPERTY_NOT_WRITABLE_ON_WKO)
	def createNonExistingMethodWKOOneArg(Issue issue, IssueResolutionAcceptor acceptor) {
		createNonExistingMethodOnWKO(issue, acceptor)
	}
	
	@Fix(WollokDslValidator.METHOD_ON_WKO_DOESNT_EXIST)
	def createNonExistingMethodOnWKO(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_createMethod_name,
			Messages.WollokDslQuickfixProvider_createMethod_description, null) [ e, context |
			val call = e as WMemberFeatureCall
			val container = call.resolveWKO(classFinder)
			createMethodInContainer(context, call, container)
		]
	}

	@Fix(WollokDslValidator.PROPERTY_NOT_WRITABLE_ON_WKO)
	def addWritablePropertyOnWKO(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_convertPropertyVar_name,
			Messages.WollokDslQuickfixProvider_convertPropertyVar_description, null) [ e, context |
			val call = e as WMemberFeatureCall
			val container = call.resolveWKO(classFinder)
			if (container.hasVariable(call.feature)) {
				upgradeToPropertyInContainer(context, call, container, true)
			} else {
				createPropertyInContainer(context, call, container)
			}			
		]
	}
	
	@Fix(WollokDslValidator.METHOD_ON_WKO_DOESNT_EXIST)
	def createPropertyOnWKO(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_createProperty_name,
			Messages.WollokDslQuickfixProvider_createProperty_description, null) [ e, context |
			val call = e as WMemberFeatureCall
			val container = call.resolveWKO(classFinder)
			if (container.hasVariable(call.feature)) {
				upgradeToPropertyInContainer(context, call, container)
			} else {
				createPropertyInContainer(context, call, container)
			}
		]
	}

	@Fix(WollokDslValidator.METHOD_ON_THIS_DOESNT_EXIST_SEVERAL_ARGS)
	def createNonExistingMethodSelf(Issue issue, IssueResolutionAcceptor acceptor) {
		createNonExistingMethodOnSelf(issue, acceptor)
	}
	
	@Fix(WollokDslValidator.PROPERTY_NOT_WRITABLE_ON_THIS)
	def createNonExistingMethodSelfOneArg(Issue issue, IssueResolutionAcceptor acceptor) {
		createNonExistingMethodOnSelf(issue, acceptor)
	}
	
	@Fix(WollokDslValidator.METHOD_ON_THIS_DOESNT_EXIST)
	def createNonExistingMethodOnSelf(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_createMethod_name,
			Messages.WollokDslQuickfixProvider_createMethod_description, null) [ e, context |
			val call = e as WMemberFeatureCall
			val container = call.method.eContainer as WMethodContainer
			createMethodInContainer(context, call, container)
		]
	}

	@Fix(WollokDslValidator.PROPERTY_NOT_WRITABLE_ON_THIS)
	def addWritablePropertyOnSelf(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_convertPropertyVar_name,
			Messages.WollokDslQuickfixProvider_convertPropertyVar_description, null) [ e, context |
			val call = e as WMemberFeatureCall
			val container = call.method.eContainer as WMethodContainer
			upgradeToPropertyInContainer(context, call, container, true)
		]
	}
	
	@Fix(WollokDslValidator.METHOD_ON_THIS_DOESNT_EXIST)
	def createPropertyOnSelf(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_createProperty_name,
			Messages.WollokDslQuickfixProvider_createProperty_description, null) [ e, context |
			val call = e as WMemberFeatureCall
			val container = call.method.eContainer as WMethodContainer
			if (container.hasVariable(call.feature)) {
				upgradeToPropertyInContainer(context, call, container)
			} else {
				createPropertyInContainer(context, call, container)
			}
		]
	}
	
	/** 
	 * ***********************************************************************
	 * 						  	Common Quick Fix tests
	 * ***********************************************************************
	 */

	@Fix(WollokDslValidator.CANNOT_ASSIGN_TO_VAL)
	def changeDeclarationToVar(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_changeToVar_name,
			Messages.WollokDslQuickfixProvider_changeToVar_description, null) [ e, context |
			val feature = (e as WAssignment).feature.ref.eContainer
			if (feature instanceof WVariableDeclaration) {
				val valueOrNothing = if (feature.right === null) "" else " =" + feature.right.node.text
				context.xtextDocument.replace(feature.before, feature.node.length,
					VAR + " " + feature.variable.name + valueOrNothing)
			}
		]
	}

	@Fix(BAD_USAGE_OF_IF_AS_BOOLEAN_EXPRESSION)
	def wrongUsageOfIfForBooleanExpressions(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_replace_if_condition_name,
			Messages.WollokDslQuickFixProvider_replace_if_condition_description, null) [ e, it |
			val ifE = e as WIfExpression
			var inlineResult = if (ifE.then.isReturnTrue)
					ifE.condition.sourceCode
				else
					("!(" + ifE.condition.sourceCode + ")")
			if (ifE.then.hasReturnWithValue) {
				inlineResult = RETURN + " " + inlineResult
			}
			val counterpart = ifE.nextExpression
			if (counterpart !== null && counterpart.returnsABoolean) {
				xtextDocument.delete(counterpart)
			}
			xtextDocument.replaceWith(e, inlineResult)
		]
	}

	@Fix(INITIALIZATION_VALUE_NEVER_USED)
	def removeInitialization(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_remove_initialization_name,
			Messages.WollokDslQuickFixProvider_remove_initialization_description, null) [ e, it |
			val varDef = e as WVariableDeclaration
			val code = (if (varDef.isWriteable) VAR else CONST) + " " + varDef.variable.name			
			xtextDocument.replaceWith(e, code)
		]
	}
	
	@Fix(WollokDslValidator.GLOBAL_VARIABLE_NOT_ALLOWED)
	@Fix(WollokDslValidator.WARNING_VARIABLE_SHOULD_BE_CONST)
	def changeDeclarationToConst(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_changeToConst_name,
			Messages.WollokDslQuickfixProvider_changeToConst_description, null) [ e, context |
			if (e instanceof WVariableDeclaration) {
				val varDef = e as WVariableDeclaration
				val value = " =" + varDef.right.node.text
				context.xtextDocument.replace(varDef.before, varDef.node.length,
					CONST + " " + varDef.variable.name + value)
			}
		]
	}
	
	@Fix(DONT_USE_WKONAME_WITHIN_IT)
	def replaceWkoNameWithSelf(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_replace_wkoname_with_self_name,
			Messages.WollokDslQuickFixProvider_replace_wkoname_with_self_description, null) [ e, it |
			xtextDocument.replaceWith(e, SELF)
		]
	}

	/** 
	 * ***********************************************************************
	 * 						  	Overriding methods
	 * ***********************************************************************
	 */

	@Fix(WollokDslValidator.METHOD_MUST_HAVE_OVERRIDE_KEYWORD)
	def changeDefToOverride(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_add_override_name,
			Messages.WollokDslQuickfixProvider_add_override_description, null) [ e, it |
			xtextDocument.prepend(e, OVERRIDE + ' ')
		]
	}

	@Fix(CANT_OVERRIDE_FROM_BASE_CLASS)
	def removeOverrideKeywordFromBaseClass(Issue issue, IssueResolutionAcceptor acceptor) {
		removeOverrideKeyword(issue, acceptor)
	}

	@Fix(METHOD_DOESNT_OVERRIDE_ANYTHING)
	def addMethodToSuperClass(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickfixProvider_create_method_superclass_name,
			Messages.WollokDslQuickfixProvider_create_method_superclass_description, null) [ e, it |
			val method = e as WMethodDeclaration
			val parent = (method.eContainer as WMethodContainer).parent as WMethodContainer
			parent.insertMethod(defaultStubMethod(parent, method), it)
		]
	}

	@Fix(METHOD_DOESNT_OVERRIDE_ANYTHING)
	def removeOverrideKeyword(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_remove_override_keyword_name,
			Messages.WollokDslQuickFixProvider_remove_override_keyword_description, null) [ e, it |
			xtextDocument.deleteToken(e, OVERRIDE + blankSpace)
		]
	}

	@Fix(NATIVE_METHOD_CANNOT_OVERRIDES)
	def removeOverrideFromNativeMethod(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_remove_override_keyword_name,
			Messages.WollokDslQuickFixProvider_remove_override_keyword_description, null) [ e, it |
			xtextDocument.deleteToken(e, OVERRIDE)
		]
	}

	/** 
	 * ***********************************************************************
	 * 							Unused or duplicated abstractions
	 * ***********************************************************************
	 */
	@Fix(WollokDslValidator.WARNING_UNUSED_VARIABLE)
	def removeUnusedVariable(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_remove_unused_variable_name,
			Messages.WollokDslQuickFixProvider_remove_unused_variable_description, null) [ e, it |
			xtextDocument.delete(e)
		]
	}

	@Fix(WollokDslValidator.WARNING_UNUSED_PARAMETER)
	def removeUnusedParameter(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_remove_unused_parameter_name,
			Messages.WollokDslQuickFixProvider_remove_unused_parameter_description, null) [ e, it |
			xtextDocument.delete(e)
		]
	}
	
	@Fix(DUPLICATED_METHOD)
	def removeDuplicatedMethod(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_remove_method_name,
			Messages.WollokDslQuickFixProvider_remove_method_description, null) [ e, it |
			xtextDocument.delete(e)
		]
	}

	@Fix(VARIABLE_NEVER_ASSIGNED)
	def initializeNonAssignedVariable(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_initialize_value_name,
			Messages.WollokDslQuickFixProvider_initialize_value_description, null) [ e, it |
			xtextDocument.append(e, " = value")
		]
	}

	/** 
	 * ***********************************************************************
	 * 							Try / catch block
	 * ***********************************************************************
	 */
	@Fix(WollokDslValidator.ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS)
	def addCatchOrAlwaysToTry(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_add_catch_name,
			Messages.WollokDslQuickFixProvider_add_catch_description, null) [ e, context |
			context.insertAfter(
				e,
				'''
				catch e : wollok.lang.Exception {
					// TODO: «Messages.WollokDslQuickfixProvider_createMethod_stub»
					throw e
				}'''
			)
		]

		acceptor.accept(issue, Messages.WollokDslQuickFixProvider_add_always_name,
			Messages.WollokDslQuickFixProvider_add_always_name, null) [ e, context |
			context.insertAfter(
				e,
				'''
				then always {
					//TODO: «Messages.WollokDslQuickfixProvider_createMethod_stub»
				}'''
			)
		]
	}

	// ************************************************
	// ** unresolved ref to "elements" quick fixes
	// ************************************************
	protected def quickFixForUnresolvedRefToVariable(IssueResolutionAcceptor issueResolutionAcceptor, Issue issue,
		IXtextDocument xtextDocument, EObject target) {
		val targetContext = target.declaringContext
		val hasMethodContainer = targetContext !== null
		val hasParameters = target.declaringMethod !== null && target.declaringMethod.parameters !== null
		val canCreateLocalVariable = target.canCreateLocalVariable
		
		// add import
		addImport(issueResolutionAcceptor, issue, target, xtextDocument, "wollok-icon-object_16.png")

		// create new local wko
		issueResolutionAcceptor.accept(issue, Messages.WollokDslQuickFixProvider_create_new_local_wko_name,
			Messages.WollokDslQuickFixProvider_create_new_local_wko_description, "wollok-icon-object_16.png") [ e, context |
			val newObjectName = xtextDocument.get(issue.offset, issue.length)
			val container = e.container
			context.xtextDocument.replace(container.before, 0,
				newObjectName.generateNewWKOCode)				
				
		]

		// create new external wko
		issueResolutionAcceptor.accept(issue, Messages.WollokDslQuickFixProvider_create_new_external_wko_name,
			Messages.WollokDslQuickFixProvider_create_new_external_wko_description, "wollok-icon-object_16.png") [ e, context |
			val newObjectName = xtextDocument.get(issue.offset, issue.length)
			val resource = xtextDocument.getAdapter(typeof(IResource))
			new AddNewElementQuickFixDialog(newObjectName, true, resource, context, e)
		]

		// create local var
		if (canCreateLocalVariable) {
			issueResolutionAcceptor.accept(issue, Messages.WollokDslQuickFixProvider_create_local_variable_name,
				Messages.WollokDslQuickFixProvider_create_local_variable_description, 'variable' + themeSuffix + '.png') [ e, context |
				val newVarName = xtextDocument.get(issue.offset, issue.length)
				val firstExpressionInContext = e.firstExpressionInContext
				context.insertBefore(firstExpressionInContext, VAR + " " + newVarName)
			]
		}

		// create instance var
		if (hasMethodContainer) {
			issueResolutionAcceptor.accept(issue, Messages.WollokDslQuickFixProvider_create_instance_variable_name,
				Messages.WollokDslQuickFixProvider_create_instance_variable_description, 'variable' + themeSuffix + '.png') [ e, context |
				val newVarName = xtextDocument.get(issue.offset, issue.length)
				e.declaringContext.insertVariable(newVarName, context)
			]
		}

		// create parameter
		if (hasParameters) {
			issueResolutionAcceptor.accept(issue, Messages.WollokDslQuickFixProvider_add_parameter_method_name,
				Messages.WollokDslQuickFixProvider_add_parameter_method_description, 'variable' + themeSuffix + '.png') [ e, context |
				val newVarName = xtextDocument.get(issue.offset, issue.length)
				val method = (e as WExpression).method
				method.parameters += (WollokDslFactory.eINSTANCE.createWParameter => [name = newVarName])
			]
		}
	}

	protected def quickFixForUnresolvedRefToClass(IssueResolutionAcceptor issueResolutionAcceptor, Issue issue,
		IXtextDocument xtextDocument, EObject target) {
			
		// add import
		addImport(issueResolutionAcceptor, issue, target, xtextDocument, "wollok-icon-class_16.png")
			
		// create inner class
		issueResolutionAcceptor.accept(issue, Messages.WollokDslQuickFixProvider_create_new_class_name,
			Messages.WollokDslQuickFixProvider_create_new_class_description, "wollok-icon-class_16.png") [ e, context |
			val newClassName = xtextDocument.get(issue.offset, issue.length)
			val container = e.container
			context.xtextDocument.replace(container.before, 0,
				CLASS + blankSpace + newClassName + " {" + System.lineSeparator + System.lineSeparator + "}" + System.lineSeparator + System.lineSeparator)
		]
		
		// create new external class
		issueResolutionAcceptor.accept(issue, Messages.WollokDslQuickFixProvider_create_new_external_class_name,
			Messages.WollokDslQuickFixProvider_create_new_external_class_description, "wollok-icon-class_16.png") [ e, context |
			val newClassName = xtextDocument.get(issue.offset, issue.length)
			val resource = xtextDocument.getAdapter(typeof(IResource))
			new AddNewElementQuickFixDialog(newClassName, false, resource, context, e)
		]

	}
	
	protected def addImport(IssueResolutionAcceptor issueResolutionAcceptor, Issue issue, EObject target,
		IXtextDocument xtextDocument, String icon) {
		val scope = scopeProvider.getScope(target.eResource, WollokDslPackage.Literals.WPACKAGE__ELEMENTS)
		val objectName = xtextDocument.get(issue.offset, issue.length)

		scope.matchingImports(objectName).forEach [ importName |
			val nameWithWildcard = importName.getPackage + ".*"
			issueResolutionAcceptor.accept(issue,
				NLS.bind(Messages.WollokDslQuickFixProvider_add_import_name, nameWithWildcard),
				NLS.bind(Messages.WollokDslQuickFixProvider_add_import_description, nameWithWildcard),
				"file_wlk.png", [ e, context |
					xtextDocument.insertWildcardImport(e, nameWithWildcard)
				], 1)
			issueResolutionAcceptor.accept(issue,
				NLS.bind(Messages.WollokDslQuickFixProvider_add_import_name, importName),
				NLS.bind(Messages.WollokDslQuickFixProvider_add_import_description, importName), icon, [ e, context |
					xtextDocument.insertImport(e, importName.generateNewImportCode)
				], 1)
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
		val modificationContext = modificationContextFactory.createModificationContext(issue)
		val xtextDocument = modificationContext.xtextDocument
		if (xtextDocument === null)
			return;
		xtextDocument.readOnly(new IUnitOfWork.Void<XtextResource>() {
			override process(XtextResource state) throws Exception {
				val target = state.getEObject(issue.uriToProblem.fragment)
				val reference = getUnresolvedEReference(issue, target)
				if (reference === null)
					return;
				quickFixUnresolvedRef(target, reference, issueResolutionAcceptor, issue, xtextDocument)
			}
		})
	}

	protected def quickFixUnresolvedRef(EObject target, EReference reference,
		IssueResolutionAcceptor issueResolutionAcceptor, Issue issue, IXtextDocument xtextDocument) {
		if (target instanceof WVariableReference && reference.EType == WollokDslPackage.Literals.WREFERENCIABLE &&
			reference.name == "ref") {
			if (target.declaringArgumentList === null) {
				quickFixForUnresolvedRefToVariable(issueResolutionAcceptor, issue, xtextDocument, target)
			} else {
				// TODO: quickFixForUnresolvedRefToNamedParameter
			}
		} else if (reference.EType == WollokDslPackage.Literals.WCLASS) {
			quickFixForUnresolvedRefToClass(issueResolutionAcceptor, issue, xtextDocument, target)
		}
	}

	/**
	 * **************************************************************************************
	 *                         Internal common methods
	 * **************************************************************************************
	 */
	def defaultStubMethod(WMemberFeatureCall call, int numberOfTabsMargin) {
		val margin = numberOfTabsMargin.output(tabChar)
		margin + METHOD + " " + call.feature + "(" +
					call.parameterNames + ")"
					+ " {" +
					System.lineSeparator + margin + tabChar + "//TODO: " + Messages.WollokDslQuickfixProvider_createMethod_stub +
					System.lineSeparator + margin + "}"
	}

	def defaultStubMethod(WMethodContainer mc, WMethodDeclaration method) {
		val margin = mc.adjustMargin
		'''
		«margin»«METHOD» «method.name»(«method.parameters.map[name].join(",")») {
		«margin»	//TODO: «Messages.WollokDslQuickfixProvider_createMethod_stub»
		«margin»}''' + System.lineSeparator
	}

	def defaultStubConstructor(WConstructorCall call) {
		call.arguments.size.defaultStubConstructor
	}

	def defaultStubConstructor(int paramsSize) {
		var args = ""
		val margin = 1.output(tabChar)
		if (paramsSize >= 1) {
			args = (1..paramsSize).map [ i | "param" + i ].join(", ")
		}
		'''
		«margin»«CONSTRUCTOR»(«args») {
		«margin»	//TODO: «Messages.WollokDslQuickfixProvider_createMethod_stub»
		«margin»}'''	
	}
	
	def adjustMargin(WMethodContainer mc) {
		if (mc.behaviors.empty) tabChar else ""
	}

	def defaultStubProperty(WMemberFeatureCall call, int numberOfTabsMargin, boolean constant) {
		val margin = numberOfTabsMargin.output(tabChar)
		margin + (if (constant) CONST else VAR) + " " + PROPERTY + " " + call.feature + " = initialValue" + System.lineSeparator
	}

	def resolveXtextDocumentFor(Issue issue) {
		modificationContextFactory.createModificationContext(issue).xtextDocument
	}

	def getContainerContext(IModificationContext it, WMethodContainer parent) {
		new IModificationContext() {

			override getXtextDocument() {
				it.getXtextDocument(parent.fileURI)
			}

			override getXtextDocument(URI uri) {
				it.getXtextDocument(uri)
			}

		}
	}

	def <T> T lastOf(List<?> l, Class<T> type) { l.findLast[type.isInstance(it)] as T }

	def lowerCaseName(String name) {
		name.substring(0, 1).toLowerCase + name.substring(1, name.length)
	}

	def upperCaseName(String name) {
		name.substring(0, 1).toUpperCase + name.substring(1, name.length)
	}

	/**
	 * author dodain
	 * 
	 * Originally, only changed eObject name, but not its references
	 * 
	 * Then, I found we could fire a refactor rename like in UI mode
	 * val rename = renameSupportFactory.create(xtextDocument.renameElementContext(e), e.name.lowerCaseName)
	 * rename.startDirectRefactoring
	 * 	def renameElementContext(IXtextDocument xtextDocument, EObject e) {
	 * 		xtextDocument.modify(new IUnitOfWork<IRenameElementContext, XtextResource>() {
	 * 			override def IRenameElementContext exec(XtextResource state) {
	 * 				renameContextFactory.createRenameElementContext(e, EditorUtils.activeXtextEditor, null, state)
	 * 			}
	 * 		})
	 * 	}
	 * 
	 * but I could not test it.
	 * 
	 * So, finally I implemented my own refactor thing, knowing that name is correct and I don't have
	 * to reconcile xtext document. So I search the main document for nodes named like eObject, 
	 * filtering only certain definitions (eg: if you rename a variable Energia from energia,
	 * method declarations and calls remain the same.
	 * 
	 * @See https://www.eclipse.org/forums/index.php/t/485483/ 	 
	 */
	protected def void applyRefactor(EObject eObject, IXtextDocument xtextDocument, Issue issue, String newText) {
		val rootNode = eObject.node.rootNode
		xtextDocument.replace(issue.offset.intValue, 1, newText)
		for (INode node : rootNode.leafNodes) {
			if (eObject.applyRenameTo(node)) {
				xtextDocument => [
					replace(node.offset, 1, newText)
				]
			}
		}
		
		/** Extending to related files of project
		 * @See https://kthoms.wordpress.com/2011/07/12/xtend-generating-from-multiple-input-models/
		 */
		// TODO: import static extension WEclipseUtils
		// eObject.getFile.refreshProject but also do a full refresh of this rename in whole project
	}

	/**
	 * Common method for wko, objects, mixins and classes to create a non-existent method based on a call
	 */
	def createMethodInContainer(IModificationContext context, WMemberFeatureCall call, WMethodContainer container) {
		val methodLocation = container.placeToAddMethod
		val xtextDocument = context.getXtextDocument(container.fileURI)
		val code = defaultStubMethod(call, xtextDocument.computeMarginFor(methodLocation.placeToAdd, container))
		container.insertMethod(code, context)
	}

	def createPropertyInContainer(IModificationContext context, WMemberFeatureCall call, WMethodContainer container) {
		val xtextDocument = context.getXtextDocument(container.fileURI)
		val code = defaultStubProperty(call, xtextDocument.computeMarginFor(container.placeToAddVariable.placeToAdd, container), call.memberCallArguments.isEmpty)
		container.insertProperty(code, context)
	}

	def upgradeToPropertyInContainer(IModificationContext context, WMemberFeatureCall call, WMethodContainer container) {
		val variable = container.getOwnVariableDeclaration(call.feature)
		upgradeToPropertyInContainer(context, call, container, variable.writeable)
	}

	def upgradeToPropertyInContainer(IModificationContext context, WMemberFeatureCall call, WMethodContainer container, boolean isVariable) {
		val xtextDocument = context.getXtextDocument(container.fileURI)
		val variable = container.getOwnVariableDeclaration(call.feature)
		val varOrConst = if (isVariable) VAR else CONST
		val propertyDef = if (variable.property) PROPERTY + " " else "" 
		val previousVarOrConst = if (variable.writeable) VAR else CONST
		xtextDocument.replace(variable.before, previousVarOrConst.length + propertyDef.length, varOrConst + " " + PROPERTY) 
	}
}
