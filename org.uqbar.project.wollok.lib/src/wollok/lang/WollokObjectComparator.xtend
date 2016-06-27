package wollok.lang

import java.util.Comparator
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.core.WollokObject

class WollokObjectComparator implements Comparator<WollokObject> {
	
	protected extension WollokInterpreterAccess = new WollokInterpreterAccess
	
	override compare(WollokObject o1, WollokObject o2) {
		if (o1.wollokEquals(o2)) {
			return 0
		}
		try {
			if (o1.wollokGreaterThan(o2)) {
				return 1
			} 
			return -1
		} catch (RuntimeException e) {
			return o1?.toString.compareTo(o2?.toString)
		}
	}
	
}