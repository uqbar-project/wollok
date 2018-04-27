package org.uqbar.project.wollok.errorHandling

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.uqbar.project.wollok.wollokDsl.WFeatureCall
import static extension org.uqbar.project.wollok.utils.XTextExtensions.*
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.wollokDsl.WClass
import java.util.Map
import java.util.HashMap
import org.uqbar.project.wollok.wollokDsl.WInitializer

/**
 * @author jfernandes
 */
class HumanReadableUtils {
	// ************************************************************************
	// ** Model Type
	// ************************************************************************
	
	// default: removes the "W" prefix and uses the class name
	def static dispatch modelTypeDescription(EObject it) { eClass.modelTypeName }
	def static dispatch modelTypeDescription(WNamedObject it) { "Object" }
	def static dispatch modelTypeDescription(WObjectLiteral it) { "Object" }
	def static dispatch modelTypeDescription(WMethodDeclaration it) { "Method" }
	def static dispatch modelTypeDescription(WVariableDeclaration it) { if (writeable) "Variable" else "Constant" }
	
	def static modelTypeName(EClass it) { if(name.startsWith("W")) name.substring(1) else name }
	
	
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
	
	def static fullMessage(WFeatureCall call) {
		'''«call.feature»(«call.memberCallArguments.map[sourceCode].join(', ')»)'''
	}
	
	def static prettyPrint(WConstructorCall c) {
		c.classRef.prettyPrintConstructors
	}

	def static prettyPrintConstructors(WClass c) {
		val newPrevExpression = WollokConstants.INSTANTIATION + " " + c.declaringContext.name + "("
		val newPostExpression = ")"
		val constructors = (c.declaringContext as WClass).allConstructors
		if (constructors.isEmpty) {
			newPrevExpression + newPostExpression
		} else {
			constructors.map[newPrevExpression + parameters.map[name].join(", ") + newPostExpression].join(" or ")
		}
	}

	def static Map<String, EObject> namedArguments(WConstructorCall c) {
		c.initializers.fold(new HashMap, [ total, i | 
			val namedParameter = i as WInitializer
			total.put(namedParameter.initializer.name, namedParameter)
			total
		])
	} 

	def static uninitializedNamedParameters(WConstructorCall it) {
		val uninitializedAttributes = classRef.allVariableDeclarations.filter [ right === null ]
		val namedArguments = namedArguments.keySet
		uninitializedAttributes.filter [ arg | !namedArguments.contains(arg.variable.name) ]
	}
	
	def static createInitializersForNamedParametersInConstructor(WConstructorCall it) {
		uninitializedNamedParameters.map 
			[ variable.name + " = value" ].join(", ")
	}
	
	// ************************************************************************
	// ** Errors
	// ************************************************************************
	def static methodNotFoundMessage(WMethodContainer container, String methodName, Object... parameters) {
		val fullMessage = methodName + "(" + parameters.join(",") + ")"
		val similarMethods = container.findMethodsByName(methodName)
		if (similarMethods.empty) {
			val caseSensitiveMethod = container.allMethods.findMethodIgnoreCase(methodName, parameters.size)
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
}
