package org.uqbar.project.wollok.typesystem.constraints

import java.util.regex.Pattern
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.wollokDsl.WollokDslFactory

class WollokModelPrintForDebug {
	static def debugInfo(EObject obj) {
		val base = obj.toString
		val prefix = (WollokDslFactory.package.name + ".impl.").replace(".", "\\.")
		val pattern = Pattern.compile(prefix + "W?(\\w*)Impl@(?:[0-9a-f]+)(.*)")
		val matcher = pattern.matcher(base)

		if (matcher.matches) 
			matcher.group(1) + matcher.group(2)
			else base
	}
}