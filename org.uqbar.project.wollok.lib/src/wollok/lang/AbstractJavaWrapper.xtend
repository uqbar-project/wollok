package wollok.lang

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper
import org.uqbar.project.wollok.interpreter.natives.DefaultNativeObjectFactory

/**
 * abstract base class to share some code between java wrappers
 * for native objects
 * 
 * @author jfernandes
 */
class AbstractJavaWrapper<T> implements JavaWrapper<T> {
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
	
	def getEvaluator() {
		interpreter.evaluator as WollokInterpreterEvaluator
	}
	
	def newInstanceWithWrapped(T wrapped) {
		val String transformedClassName = DefaultNativeObjectFactory.javaToWollokFQN(class.name)
		evaluator.newInstanceWithWrapped(transformedClassName, wrapped)
	} 
}