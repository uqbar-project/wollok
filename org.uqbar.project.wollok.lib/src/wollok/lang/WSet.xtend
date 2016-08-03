package wollok.lang

import java.util.Set
import java.util.TreeSet
import java.util.Collection
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * @author jfernandes
 */
class WSet extends WCollection<Set<WollokObject>> {
	
	new() {
		wrapped = new TreeSet<WollokObject>(new WollokObjectComparator)
	}
	
	def anyOne() { wrapped.head }
	
	override protected def verifyWollokElementsContained(Collection set, Collection set2) {
		set.forall [ elem |
			wrapped.exists[ it.wollokEquals(elem) ]
		]
	}
}