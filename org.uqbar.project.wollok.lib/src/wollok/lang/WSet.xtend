package wollok.lang

import java.util.Set
import java.util.TreeSet
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

/**
 * @author jfernandes
 */
class WSet extends WCollection<Set> {
	
	new() {
		wrapped = new TreeSet<WollokObject>(new WollokObjectComparator)
	}
	
	def anyOne() { wrapped.head }

	@NativeMessage("equals")
	override wollokEquals(WollokObject other) {
		other.hasNativeType(this.class.name) &&
		verifySizes(wrapped, other.asSet) &&
		verifyWollokElementsContained(wrapped, other.asSet) &&
		verifyWollokElementsContained(other.asSet, wrapped)
	}
	
	private def asSet(WollokObject it) {
		getNativeObject(this.class).wrapped
	}
	
	private def verifySizes(Set<WollokObject> set, Set<WollokObject> set2) {
		set.size.equals(set2.size)
	}
	
	private def verifyWollokElementsContained(Set<WollokObject> set, Set<WollokObject> set2) {
		set.forall [ elem |
			wrapped.exists[ it.wollokEquals(elem) ]
		]
	}
	
}