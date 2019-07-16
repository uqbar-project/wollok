package wollok.lang

import java.math.BigDecimal
import java.util.Collection
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.core.ToStringBuilder
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.sdk.WollokDSK

import static extension org.uqbar.project.wollok.errorHandling.HumanReadableUtils.*
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.WollokObjectUtils.*

/**
 * Wollok Object class. It's the native part
 * 
 * @author jfernandes
 */
class WObject {
	val WollokObject obj
	val WollokInterpreter interpreter

	new(WollokObject obj, WollokInterpreter interpreter) {
		this.obj = obj
		this.interpreter = interpreter
	}

	def identity() { System.identityHashCode(obj) }

	def kindName() { ToStringBuilder.objectDescription(obj.behavior) }

	def className() { (obj.kind).fqn }

	def generateDoesNotUnderstandMessage(String target, String methodName, BigDecimal _parametersSize) {
		val parametersSize = _parametersSize.coerceToInteger
		val fullMessage = methodName.fullMessage(parametersSize)
		val similarMethods = this.obj.allMethods.findMethodsByName(methodName)
		if (similarMethods.empty) {
			val caseSensitiveMethod = this.obj.allMethods.findMethodIgnoreCase(methodName, parametersSize)
			if (caseSensitiveMethod !== null) {
				return NLS.bind(Messages.WollokDslValidator_METHOD_DOESNT_EXIST_CASE_SENSITIVE,
					#[target, fullMessage, #[caseSensitiveMethod].convertToString])
			} else {
				return NLS.bind(Messages.WollokDslValidator_METHOD_DOESNT_EXIST, target, fullMessage)
			}
		} else {
			val similarDefinitions = similarMethods.map[messageName].join(', ')
			return NLS.bind(Messages.WollokDslValidator_METHOD_DOESNT_EXIST_BUT_SIMILAR_FOUND,
				#[target, fullMessage, similarDefinitions])
		}
	}

	def instanceVariables() {
		newList(obj.instanceVariables.keySet.map[variableMirror(it)].toList)
	}

	def instanceVariableFor(String name) {
		name.checkNotNull("instanceVariableFor")
		variableMirror(name)
	}

	def variableMirror(String name) {
		newInstance("wollok.mirror.InstanceVariableMirror", obj, name)
	}

	def resolve(String instVarName) {
		instVarName.checkNotNull("resolve")
		obj.resolve(instVarName)
	}

	def newInstance(String className, Object... arguments) {
		val wArgs = arguments.map[javaToWollok]
		(interpreter.evaluator as WollokInterpreterEvaluator).newInstance(className, wArgs)
	}

	def newList(Collection<WollokObject> elements) {
		val list = newInstance(WollokDSK.LIST)
		elements.forEach [
			list.call("add", it.javaToWollok)
		]
		list
	}

	def checkNotNull(WollokObject o, String operation) {
		if (o === null) {
			throw throwInvalidOperation(NLS.bind(Messages.WollokConversion_INVALID_OPERATION_NULL_PARAMETER, operation))
		}
	}

}
