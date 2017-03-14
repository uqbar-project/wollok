package wollok.lang

import java.util.Set
import java.util.TreeSet
import java.util.Collection
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.WollokRuntimeException

/**
 * @author jfernandes
 */
class WSet extends WCollection<Set<WollokObject>> {
	
	new() {
		wrapped = new TreeSet<WollokObject>(new WollokObjectComparator)
	}
	
	def anyOne() { 
		if(wrapped.isEmpty) 
			throw new WollokRuntimeException("Illegal operation 'anyOne' on empty collection")
		else
			wrapped.head
	}
	
	override protected def verifyWollokElementsContained(Collection set, Collection set2) {
		set2.forall [ elem |
			set.exists[ it.wollokEquals(elem) ]
		]
	}

}