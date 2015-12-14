package org.uqbar.project.wollok

import org.eclipse.emf.ecore.EClass

/**
 * @author jfernandes
 */
class WollokModelUtils {
	
	def static humanReadableModelTypeName(EClass it) { if (name.startsWith("W")) name.substring(1) else name }
	
}