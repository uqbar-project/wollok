package wollok.lang

import java.util.ArrayList
import java.util.Collection
import java.util.Set
import java.util.TreeSet
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper

import static org.uqbar.project.wollok.sdk.WollokDSK.*

import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*

/**
 * @author jfernandes
 */
class WSet extends WCollection<Set<WollokObject>> implements JavaWrapper<Set<WollokObject>> {
	new() {
		wrapped = new TreeSet<WollokObject>(new WollokObjectComparator)
	}
	
	def anyOne() { 
		if(wrapped.isEmpty) 
			throw new WollokRuntimeException(NLS.bind(Messages.WollokInterpreter_illegalOperationEmptyCollection, "anyOne"))
		else
			wrapped.head
	}
	
	override protected def verifyWollokElementsContained(Collection<WollokObject> set, Collection<WollokObject> set2) {
		set2.forall [ elem |
			set.exists[ it.wollokEquals(elem) ]
		]
	}

	/**
	 * @author: dodain
	 * 
	 * For performance reasons I had to use C-ish syntax, which resulted
	 * in a much better performance ratio
	 */
	def filter(WollokObject objClosure) {
		val closure = objClosure.asClosure
		val Collection<WollokObject> result = newArrayList
		for (var i = 0; i < wrapped.size; i++) {
			val element = wrapped.get(i)
			if ((closure.doApply(element).getNativeObject(BOOLEAN) as JavaWrapper<Boolean>).wrapped) {
				result.add(element)
			}
		}
		result.toSet
	}
	
	def max() {
		wrapped.last
	}
	
	/**
	 * @author: dodain
	 * 
	 * For performance reasons I had to use C-ish syntax, which resulted
	 * in a much better performance ratio
	 */
	override def Object fold(WollokObject acc, WollokObject proc) {
		val closure = proc.asClosure
		var seed = acc
		val Collection<WollokObject> array = new ArrayList(wrapped.toArray())
		for (var i = 0; i < array.size; i++) {
			seed = closure.doApply(seed, array.get(i))
		}
		seed
	}
	
}