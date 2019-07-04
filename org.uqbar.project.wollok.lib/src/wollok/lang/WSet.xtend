package wollok.lang

import java.util.Collection
import java.util.HashMap
import java.util.Map
import java.util.Set
import java.util.TreeSet
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * @author jfernandes
 */
class WSet extends WCollection<Set<WollokObject>> {
	Map<WollokObject, String> stringRepresentation = new HashMap
	
	new() {
		wrapped = new TreeSet<WollokObject>(new WollokObjectComparator(stringRepresentation))
	}
	
	override add(WollokObject obj) {
		stringRepresentation.put(obj, obj.toString)
		super.add(obj)
	}
	
	def anyOne() { 
		if(wrapped.isEmpty) 
			throw new WollokRuntimeException(NLS.bind(Messages.WollokInterpreter_illegalOperationEmptyCollection, "anyOne"))
		else
			wrapped.head
	}
	
	override protected def verifyWollokElementsContained(Collection set, Collection set2) {
		set2.forall [ elem |
			set.exists[ it.wollokEquals(elem) ]
		]
	}
	
}