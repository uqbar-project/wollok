package org.uqbar.project.wollok.ui.utils

import java.io.PrintWriter
import java.io.StringWriter
import java.lang.reflect.InvocationTargetException
import java.lang.reflect.Method
import java.lang.reflect.Modifier
import java.util.Collection
import java.util.List
import java.util.Map
import java.util.Random
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions

import static org.uqbar.project.wollok.sdk.WollokDSK.*

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.errorHandling.WollokExceptionExtensions.*

/**
 * Utilities for xtend code
 * 
 * @author jfernandes
 * @author dodain (added i18n, null handling and better exception mechanism)
 * 
 */
class XTendUtilExtensions {

	def static stackTraceAsString(Throwable e) {
		val s = new StringWriter()
		e.printStackTrace(new PrintWriter(s))
		s.buffer.toString
	}

	def static bothNull(Object a, Object b) { a === null && b === null }

	def static noneAreNull(Object a, Object b) { a !== null && b !== null }

	// ***************************************
	// ** Collections
	// ***************************************
	def static <T> List<T> duplicates(List<T> original) {
		original.filter[e|original.filter[it == e].size > 1].toList
	}

	/** A "map" whose closure receives the index (position) besides the item */
	def static <E, T> Collection<T> map(Iterable<E> col, (Integer, E)=>T mapper) {
		val r = newArrayList
		col.fold(0)[i, e|r.add(mapper.apply(i, e)); i + 1]
		r
	}

	def static <E> E findFirstIfNone(Iterable<E> col, (E)=>Boolean predicate, ()=>E ifNone) {
		val f = col.findFirst(predicate)
		if(f !== null) f else ifNone.apply
	}

	def static <E, T> findFirstAndMap(Iterable<E> col, (E)=>Boolean predicate, (E)=>T ifFoundDo) {
		findFirstAndMap(col, predicate, ifFoundDo, [| ])
	}

	def static <E, T> void findFirstAndDo(Iterable<E> col, (E)=>Boolean predicate, (E)=>void ifFoundDo) {
		val f = col.findFirst(predicate)
		if (f !== null)
			ifFoundDo.apply(f)
	}

	def static <E, T> findFirstAndMap(Iterable<E> col, (E)=>Boolean predicate, (E)=>T ifFoundDo, ()=>T ifNotThen) {
		val f = col.findFirst(predicate)
		if (f !== null)
			ifFoundDo.apply(f)
		else
			ifNotThen.apply
	}

	def static <E> removeAllSuchAs(Collection<E> col, (E)=>Boolean predicate) {
		col.removeAll(col.filter(predicate))
	}

	def static <E> maxBy(Collection<E> col, (E)=>Comparable func) {
		col.collectComparing(func, [a, b|a > b])
	}

	def static <E> minBy(Collection<E> col, (E)=>Comparable func) {
		col.collectComparing(func, [a, b|a < b])
	}

	def static <E, K, V> Map<K, V> mapBy(Collection<E> col, (E)=>Pair<K, V> func) {
		newHashMap(col.map(func))
	}

	def static <A, B, O> Collection<O> zip(Iterable<A> colA, Iterable<B> colB, (A, B)=>O zipFunc) {
		colA.map[i, a|zipFunc.apply(a, colB.get(i))]
	}

	/** reused method between maxBy and minBy */
	def static <E> collectComparing(Collection<E> col, (E)=>Comparable func,
		(Comparable, Comparable)=>Boolean comparator) {
		var Comparable accVal = null
		var E accE = null
		for (e : col) {
			val thisVal = func.apply(e)
			if (accE === null || comparator.apply(thisVal, accVal)) {
				accVal = thisVal
				accE = e
			}
		}
		accE
	}

	// ***************************************
	// ** Wollok -> Native Java interaction
	// ***************************************
	def static invoke(Object target, String message, Object... args) {
		// native objects
		var matchingMethods = target.class.methods.filter[name == message && parameterTypes.size == args.size]
		if (matchingMethods.isEmpty)
			throw throwMessageNotUnderstood(target, message, args)
		if (matchingMethods.size > 1)
			throw throwInvalidOperation(NLS.bind(Messages.WollokConversion_MULTIPLE_MESSAGES_ERROR, target, message))

		// takes the first one and tries out :S Should do something like multiple-dispatching based on args. 
		matchingMethods.head.accesibleVersion.invokeConvertingArgs(target, args)
	}

	def static String createMessage(Object target, String message, Object... args) {
		val fullMessage = message + "(" + args.join(",") + ")"
		val wollokTarget = target.javaToWollok
		val targetName = '''«target» («target.class.simpleName»)'''
		val similarMethods = wollokTarget.findMethodsByName(message)
		if (similarMethods.empty) {
			val caseSensitiveMethod = wollokTarget.allMethods.findMethodIgnoreCase(message, args.size)
			if (caseSensitiveMethod !== null) {
				return NLS.bind(Messages.WollokDslValidator_METHOD_DOESNT_EXIST_CASE_SENSITIVE,
					#[target, fullMessage, #[caseSensitiveMethod].convertToString])
			} else {
				return NLS.bind(Messages.WollokDslValidator_METHOD_DOESNT_EXIST, targetName, fullMessage)
			}
		}
		val similarDefinitions = similarMethods.map[messageName].join(', ')
		NLS.bind(Messages.WollokDslValidator_METHOD_DOESNT_EXIST_BUT_SIMILAR_FOUND,
			#[targetName, fullMessage, similarDefinitions])
	}

	def static WollokObject invokeConvertingArgs(Method m, Object o, Object... args) {
		if ((!m.varArgs && m.parameterTypes.size != args.size) || (m.varArgs && args.length < m.parameterTypes.length -
			1)) {
				throw throwInvalidOperation(
					NLS.bind(Messages.WollokConversion_INVALID_ARGUMENTS_SIZE, m.name,
						m.parameterTypes.map[simpleName] + "(" + m.parameterTypes.length + ")")
				)
			}

			var Object[] result = null
			if (m.isVarArgs) {
				// TODO: contemplate vararg method with more than one arg
				result = newArrayOfSize(1)
				result.set(0, args)
			} else {
				val converted = newArrayList
				args.fold(0) [ i, a |
					val conv = a.wollokToJava(m.parameterTypes.get(i))
					converted.add(conv)
					i + 1
				]
				result = converted.toArray
			}

			try {
				val returnVal = m.invoke(o, result)
				javaToWollok(returnVal)
			} catch (InvocationTargetException e) {
				throw wrapNativeException(e, m, result)
			} catch (IllegalArgumentException e) {
				throw throwInvalidOperation(NLS.bind(Messages.WollokConversion_INVALID_OPERATION_PARAMETER, args.map [
					toString
				].join(", ")))
			}
		}

		def static wrapNativeException(InvocationTargetException e, Method m, Object[] params) {
			if (e.cause instanceof WollokProgramExceptionWrapper ||
				e.cause.class.name.equalsIgnoreCase(ASSERTION_EXCEPTION_FQN))
				e.cause
			else {
				new WollokProgramExceptionWrapper(e.cause.message.newWollokException)
			}
		}

		def static accesibleVersion(Method m) {
			var c = m.declaringClass
			var metodin = m
			while (metodin.cannotBeCalled() && c !== null) {
				c = c.superclass
				metodin = c.getMethod(m.name, m.parameterTypes)
			}
			metodin
		}

		def static getShortDescription(
			Method method) '''«method.declaringClass.simpleName».«method.name»(«method.parameterTypes.map[simpleName].join(', ')»)'''

		def static cannotBeCalled(Method m) {
			!m.isPublic || !m.declaringClass.isPublic
		}

		def static isPublic(Method m) { Modifier.isPublic(m.modifiers) }

		def static isPublic(Class<?> c) { Modifier.isPublic(c.modifiers) }

		def static randomBetween(int a, int b) {
			new Random().nextInt(b - a) + a
		}

		def static <T> T readPrivateField(Object o, String fieldName) {
			val field = o.class.declaredFields.findFirst[name == fieldName]
			field.accessible = true
			try
				field.get(o) as T
			finally
				field.accessible = false
		}

		def static toPhrase(String string) {
			(Character.toUpperCase(string.charAt(0)) + string.substring(1)).splitCamelCase
		}

		def static splitCamelCase(String s) {
			s.replaceAll(String.format("%s|%s|%s", "(?<=[A-Z])(?=[A-Z][a-z])", "(?<=[^A-Z])(?=[A-Z])",
				"(?<=[A-Za-z])(?=[^A-Za-z])"), " ")
		}

		def static int randonBetween(int Min, int Max) {
			Min + (Math.random() * ((Max - Min) + 1)).intValue
		}

	}
	