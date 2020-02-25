package wollok.lang

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper
import org.uqbar.project.wollok.interpreter.natives.DefaultNativeObjectFactory

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

/**
 * abstract base class to share some code between java wrappers
 * for native objects
 * 
 * @author jfernandes
 */
abstract class AbstractJavaWrapper<T> implements JavaWrapper<T> {
	protected WollokInterpreterAccess interpreterAccess = new WollokInterpreterAccess // re-use a singleton ?
	protected val WollokObject obj
	protected val WollokInterpreter interpreter
	
	@Accessors protected T wrapped
	
	new(WollokObject obj, WollokInterpreter interpreter) {
		this.obj = obj
		this.interpreter = interpreter
	}
	
	def newInstance(String className) {
		evaluator.newInstance(className)
	}
	
	def solve(String fieldName) {
		obj.resolve(fieldName).coerceToInteger.intValue
	}

	def solveOrAssign(String property, int value) {
		val solvedProperty = obj.resolve(property)
		if (solvedProperty === null) {
			obj.setReference(property, value.convertJavaToWollok)
			return value
		}
		solvedProperty.coerceToInteger
	}
	
	def getEvaluator() {
		interpreter.evaluator as WollokInterpreterEvaluator
	}
	
	def newInstanceWithWrapped(T wrapped) {
		val String transformedClassName = DefaultNativeObjectFactory.javaToWollokFQN(class.name)
		evaluator.newInstanceWithWrapped(transformedClassName, wrapped)
	}
	
}