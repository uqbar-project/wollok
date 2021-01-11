package org.uqbar.project.wollok.errorHandling

import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.XTextExtensions.*

/**
 * @author jfernandes
 */
class HumanReadableUtils {
	// ************************************************************************
	// ** Model Type
	// ************************************************************************
	
	// default: removes the "W" prefix and uses the class name
	def static dispatch modelTypeDescription(WNamedObject it) { "Object" }
	def static dispatch modelTypeDescription(WObjectLiteral it) { "Object" }
	def static dispatch modelTypeDescription(WMethodDeclaration it) { "Method" }
	def static dispatch modelTypeDescription(WVariableDeclaration it) { if (writeable) "Variable" else "Constant" }
	def static dispatch modelTypeDescription(EObject it) { eClass.modelTypeName }
	
	def static modelTypeName(EClass it) {
		if (name.equals("WReferenciable")) return ""
		if (name.startsWith("W")) name.substring(1) else name
	}
	
	
	// ************************************************************************
	// ** Printing
	// ************************************************************************
	
	def static fullMessage(String methodName, int argumentsSize) {
		var args = ""
		val argsSize = argumentsSize
		if (argsSize > 0) {
			args = (1..argsSize).map [ "param" + it ].join(', ')
		}
		methodName + "(" + args + ")"
	}
	
	def static dispatch fullMessage(EObject o) { throw new RuntimeException("Element " + o + " is not a sent message")}
	def static dispatch fullMessage(WFeatureCall call) {
		'''«call.feature»(«call.memberCallArguments.map[sourceCode].join(', ')»)'''
	}
	def static dispatch fullMessage(WBinaryOperation op) {
		'''«op.feature»(«op.rightOperand.sourceCode»)'''
	}
	
	def static uninitializedNamedParameters(WConstructorCall it) {
		var uninitializedAttributes = classRef.allVariableDeclarations.filter [ right === null ].toList
		uninitializedAttributes.addAll(mixins.flatMap [ allVariableDeclarations ].filter [ right === null ])
//		Checking against initialize methods also, currently disregarded
//		val attributesInitializedInMethod = classRef.initializeMethods.flatMap [ method | method.assignments ].map [ feature ]
//		uninitializedAttributes = uninitializedAttributes.filter [ attributesInitializedInMethod.contains(it) ]
		val namedArguments = initializers.map [ initializer.name ]
		uninitializedAttributes.filter [ arg | !namedArguments.contains(arg.variable.name) ]
	}
	
	def static createInitializersForNamedParametersInConstructor(WConstructorCall it) {
		uninitializedNamedParameters.map 
			[ variable.name + " = value" ].join(", ")
	}
	
	def static List<WAssignment> assignments(WMethodDeclaration m) {
		if (!(m.expression instanceof WBlockExpression)) {
			return newArrayList
		}
		(m.expression as WBlockExpression).expressions.filter(WAssignment).toList
	}

	// ************************************************************************
	// ** Errors
	// ************************************************************************
	def static methodNotFoundMessage(WMethodContainer container, String methodName, Object... parameters) {
		val fullMessage = methodName + "(" + parameters.join(",") + ")"
		val similarMethods = container.findMethodsByName(methodName)
		if (similarMethods.empty) {
			val caseSensitiveMethod = container.allUntypedMethods.findMethodIgnoreCase(methodName, parameters.size)
			if (caseSensitiveMethod !== null) {
				(NLS.bind(Messages.WollokDslValidator_METHOD_DOESNT_EXIST_CASE_SENSITIVE,
					#[container.name, fullMessage, #[caseSensitiveMethod].convertToString]))
			} else {
				methodNotFoundMessage(container.name, fullMessage)
			}
		} else {
			val similarDefinitions = similarMethods.map[messageName].join(', ')
			(NLS.bind(Messages.WollokDslValidator_METHOD_DOESNT_EXIST_BUT_SIMILAR_FOUND,
					#[container.name, fullMessage, similarDefinitions]))
		}
	}
	
	def static methodNotFoundMessage(String type, String message) {
		NLS.bind(Messages.WollokDslValidator_METHOD_DOESNT_EXIST, type, message)
	}
	
	def static classNameWhenInvalid(WConstructorCall call) {
		val expr = call.sourceCode.trim
		val data = expr.split(" ")
		if (data.size < 1) return expr
		val classNameWithParameters = data.get(1)
		var indexParentheses = classNameWithParameters.indexOf("(")
		if (indexParentheses == -1) {
			return classNameWithParameters 
		}
		classNameWithParameters.substring(0, indexParentheses)
	}

}
