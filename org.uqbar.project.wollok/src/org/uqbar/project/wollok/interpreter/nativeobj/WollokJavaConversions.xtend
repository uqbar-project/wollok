package org.uqbar.project.wollok.interpreter.nativeobj

import java.math.BigDecimal
import java.time.LocalDate
import java.util.Collection
import java.util.List
import java.util.Set
import org.eclipse.xtext.xbase.lib.Functions.Function1
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

import static org.uqbar.project.wollok.sdk.WollokDSK.*

/**
 * Holds common extensions for Wollok to Java and Java to Wollok conversions.
 * 
 * @author jfernandes
 */
class WollokJavaConversions {

	def static asInteger(WollokObject it) {
		((it as WollokObject).getNativeObject(INTEGER) as JavaWrapper<Integer>).wrapped
	}

	def static isWBoolean(Object it) { it instanceof WollokObject && (it as WollokObject).hasNativeType(BOOLEAN) }

	def static isTrue(Object it) {
		it instanceof WollokObject && ((it as WollokObject).getNativeObject(BOOLEAN) as JavaWrapper<Boolean>).wrapped
	}

	def static Object wollokToJava(Object o, Class<?> t) {
		if(o == null) return null
		if(t.isInstance(o)) return o
		if(t == Object) return o

		if (o.isNativeType(CLOSURE) && t == Function1)
			return [Object a|((o as WollokObject).getNativeObject(CLOSURE) as Function1).apply(a)]
		if (o.isNativeType(INTEGER) && (t == Integer || t == Integer.TYPE))
			return ((o as WollokObject).getNativeObject(INTEGER) as JavaWrapper<Integer>).wrapped
		if (o.isNativeType(DOUBLE) && (t == Double || t == Double.TYPE))
			return ((o as WollokObject).getNativeObject(DOUBLE) as JavaWrapper<BigDecimal>).wrapped
		if (o.isNativeType(STRING) && t == String)
			return ((o as WollokObject).getNativeObject(STRING) as JavaWrapper<String>).wrapped
		if (o.isNativeType(LIST) && (t == Collection || t == List))
			return ((o as WollokObject).getNativeObject(LIST) as JavaWrapper<List>).wrapped
		if (o.isNativeType(SET) && (t == Collection || t == Set))
			return ((o as WollokObject).getNativeObject(SET) as JavaWrapper<Set>).wrapped
		if (o.isNativeType(BOOLEAN) && (t == Boolean || t == Boolean.TYPE))
			return ((o as WollokObject).getNativeObject(BOOLEAN) as JavaWrapper<Boolean>).wrapped
		if (o.isNativeType(DATE)) {
			return (o as WollokObject).getNativeObject(DATE)
		}

//		if (t.array && t.componentType == Object) {
//			val a = newArrayOfSize(1)
//			a.set(0, o)
//			return a
//		}
		if (t == Collection || t == List)
			return #[o]

		// remove this ?
		if (t.
			primitive)
			return o

		throw new RuntimeException('''Cannot convert parameter "«o»" of type «o.class.name» to type "«t.simpleName»""''')
	}

	def static dispatch isNativeType(Object o, String type) { false }

	def static dispatch isNativeType(Void o, String type) { false }

	def static dispatch isNativeType(WollokObject o, String type) { o.hasNativeType(type) }

	def static WollokObject javaToWollok(Object o) {
		if(o == null) return null
		convertJavaToWollok(o)
	}

	def static dispatch WollokObject convertJavaToWollok(Integer o) { evaluator.getOrCreateNumber(o.toString) }

	def static dispatch WollokObject convertJavaToWollok(Double o) { evaluator.getOrCreateNumber(o.toString) }

	def static dispatch WollokObject convertJavaToWollok(BigDecimal o) { evaluator.getOrCreateNumber(o.toString) }

	// cache strings ?
	def static dispatch WollokObject convertJavaToWollok(String o) { evaluator.newInstanceWithWrapped(STRING, o) }

	def static dispatch WollokObject convertJavaToWollok(Boolean o) { evaluator.booleanValue(o) }

	def static dispatch WollokObject convertJavaToWollok(List o) { evaluator.newInstanceWithWrapped(LIST, o) }

	def static dispatch WollokObject convertJavaToWollok(Set o) { evaluator.newInstanceWithWrapped(SET, o) }

	def static dispatch WollokObject convertJavaToWollok(LocalDate o) { evaluator.newInstanceWithWrapped(DATE, o) }

	def static dispatch WollokObject convertJavaToWollok(WollokObject it) { it }

	def static dispatch WollokObject convertJavaToWollok(Object o) {
		throw new UnsupportedOperationException('''Unsupported convertion from java «o» («o.class.name») to wollok''')
	}

	def static newWollokExceptionAsJava(String message) {
		new WollokProgramExceptionWrapper(newWollokException(message))
	}

	def static newWollokException(String message) {
		evaluator.newInstance(EXCEPTION, message.javaToWollok)
	}

	def static newWollokException(String message, WollokObject cause) {
		evaluator.newInstance(EXCEPTION, message.javaToWollok, cause)
	}

	def static getEvaluator() { (WollokInterpreter.getInstance.evaluator as WollokInterpreterEvaluator) }

}
