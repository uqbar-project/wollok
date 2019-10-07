package wollok.lang

import java.util.ArrayList
import java.util.Collection
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.core.WCallable
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

import static org.uqbar.project.wollok.sdk.WollokSDK.*

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*
import static extension org.uqbar.project.wollok.utils.WollokObjectUtils.*

/**
 * @author jfernandes
 */
class WCollection<T extends Collection<WollokObject>> {
	@Accessors var T wrapped
	protected extension WollokInterpreterAccess = new WollokInterpreterAccess
	
	def Object fold(WollokObject acc, WollokObject proc) {
		proc.checkNotNull("fold")
		val c = proc.asClosure
		val Collection<WollokObject> iterable = new ArrayList(wrapped.toArray())
		iterable.fold(acc) [i, e|
			c.doApply(i, e)
		]
	}

	/**
	 * @author: dodain
	 * 
	 * For performance reasons I had to use C-ish syntax, which resulted
	 * in a much better performance ratio. 
	 */
	def filter(WollokObject objClosure) {
		objClosure.checkNotNull("filter")
		val closure = objClosure.asClosure
		val wrappedAsList = wrapped.toArray
		val Collection<WollokObject> result = newArrayList
		for (var i = 0; i < wrapped.size; i++) {
			val element = wrappedAsList.get(i) as WollokObject
			if ((closure.doApply(element).getNativeObject(BOOLEAN) as JavaWrapper<Boolean>).wrapped) {
				result.add(element)
			}
		}
		result
	}
	
	/**
	 * @author dodain
	 * 
	 * Optimized implementation
	 */
	def contains(WollokObject obj) {
		for (var i = 0; i < wrapped.size; i++) {
			val element = wrapped.get(i)
			if (element.wollokEquals(obj)) return true
		}
		return false
	}
	
	def Object findOrElse(WollokObject _predicate, WollokObject _continuation) {
		_predicate.checkNotNull("findOrElse")
		_continuation.checkNotNull("findOrElse")
		val predicate = _predicate.asClosure
		val continuation = _continuation.asClosure

		for(Object element : wrapped) {
			if(predicate.doApply(element as WollokObject).wollokToJava(Boolean) as Boolean) {
				return element
			}
		}
		continuation.doApply()
	}

	def void add(WollokObject e) {
		wrapped.add(e)
	}
	
	def void remove(WollokObject e) { 
		// This is necessary because native #contains does not take into account Wollok object equality 
		wrapped.remove(wrapped.findFirst[it.wollokEquals(e)])
	}

	def size() { wrapped.size }
	
	def void clear() { wrapped.clear }
	
	def join() { join(",") }
	
	def join(String separator) {
		separator.checkNotNull("join")
		wrapped.map[ if (it instanceof WCallable) call("toString") else toString ].join(separator)
	}
	
	@NativeMessage("==")
	def wollokEqualsEquals(WollokObject other) { 
		wollokEquals(other)
	}
	
	@NativeMessage("equals")
	def wollokEquals(WollokObject other) {
		other.checkNotNull("equals")
		
		other.hasNativeType &&
		verifySizes(wrapped, other.getNativeCollection) &&
		verifyWollokElementsContained(wrapped, other.getNativeCollection) &&
		verifyWollokElementsContained(other.getNativeCollection, wrapped)
	}
	
	protected def hasNativeType(WollokObject it) {
		hasNativeType(this.class.name)
	}
	
	protected def Collection<WollokObject> getNativeCollection(WollokObject it) {
		getNativeObject(this.class).getWrapped()
	}
	
	protected def verifySizes(Collection<WollokObject> col, Collection<WollokObject> col2) {
		col.size.equals(col2.size)
	}
	
	protected def verifyWollokElementsContained(Collection<WollokObject> set, Collection<WollokObject> set2) { false } // Abstract method
}