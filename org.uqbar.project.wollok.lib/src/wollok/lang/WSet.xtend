package wollok.lang

import java.util.Set
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

/**
 * @author jfernandes
 */
class WSet extends WCollection<Set> {
	
	new() {
		wrapped = newHashSet
	}
	
	def anyOne() { wrapped.head }

	@NativeMessage("equals")
	override wollokEquals(WollokObject other) {
		if (!other.hasNativeType(this.class.name)) {
			return false
		}
		if (!verifyWollokElementsContained(wrapped, other.getNativeObject(this.class).wrapped)) {
			return false
		}
		verifyWollokElementsContained(other.getNativeObject(this.class).wrapped, wrapped)
	}
	
	private def verifyWollokElementsContained(Set<WollokObject> set, Set<WollokObject> set2) {
		set.forall [ elem |
			wrapped.exists[ it.wollokEquals(elem) ]
		]
	}
	
}