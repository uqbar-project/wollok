package org.uqbar.project.wollok.interpreter.natives

import java.util.Map
import org.uqbar.project.wollok.WollokActivator
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WNamedObject

import static org.uqbar.project.wollok.sdk.WollokDSK.*

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import com.google.inject.Singleton

/**
 * Default implement
 * 
 * @author jfernandes
 */
@Singleton
class DefaultNativeObjectFactory implements NativeObjectFactory {
	// static public as a temporary "cut the refactor" method
	public static val Map<String, String> transformations = #{
		OBJECT -> "wollok.lang.WObject",
		COLLECTION -> "wollok.lang.WCollection",
		LIST -> "wollok.lang.WList",
		SET -> "wollok.lang.WSet",
		DICTIONARY -> "wollok.lang.WDictionary",
		NUMBER -> "wollok.lang.WNumber",
		STRING -> "wollok.lang.WString",
		BOOLEAN -> "wollok.lang.WBoolean",
		DATE -> "wollok.lang.WDate"
	}
	
	override createNativeObject(WClass it, WollokObject obj, WollokInterpreter interpreter) {
		createNativeObject(fqn, obj, interpreter)
	}
	
	override createNativeObject(WNamedObject it, WollokObject obj, WollokInterpreter interpreter) {
		var className = fqn
		var classNameParts = className.split("\\.")
		val lastPosition = classNameParts.length - 1
		classNameParts.set(lastPosition, classNameParts.get(lastPosition).toFirstUpper)
		
		className = classNameParts.join(".")
		val classFQN = className + "Object"
		
		createNativeObject(classFQN, obj, interpreter)
	}
	
	def createNativeObject(String classFQN, WollokObject obj, WollokInterpreter interpreter) {
		val javaClass = resolveNativeClass(classFQN, obj, interpreter)
		
		tryInstantiate(
			[|javaClass.getConstructor(WollokObject, WollokInterpreter).newInstance(obj, interpreter)],
			[|javaClass.getConstructor(WollokObject).newInstance(obj)],
			[|javaClass.newInstance]
		)
	}
	
	def resolveNativeClass(String originalFqn, WollokObject obj, WollokInterpreter interpreter) {
		val fqn = DefaultNativeObjectFactory.wollokToJavaFQN(originalFqn)
		val bundle = WollokActivator.getDefault
		if (bundle !== null)
			try
				bundle.loadWollokLibClass(fqn, obj.behavior)
			catch (ClassNotFoundException e)
				interpreter.classLoader.loadClass(fqn)
		else
			interpreter.classLoader.loadClass(fqn)
	}
	
	def static wollokToJavaFQN(String fqn) {
		val transformed = transformations.get(fqn)
		if (transformed !== null)
			transformed
		else
			fqn
	}
	
	def static javaToWollokFQN(String fqn) {
		val entry = transformations.entrySet.findFirst[e | e.value == fqn]
		if (entry !== null)
			entry.key
		else
			fqn
	}
	
	def static tryInstantiate(()=>Object... closures) {
		var Exception lastException = null
		for (c : closures) {
			try
				return c.apply
			catch (NoSuchMethodException e) {
				lastException = e
			}
			catch (InstantiationException e) {
				lastException = e
			}
		}
		throw new WollokRuntimeException("Error while instantiating native class. No valid constructor: (), or (WollokObject) or (WollokObject, WollokInterpreter)", lastException)
	}
	
}