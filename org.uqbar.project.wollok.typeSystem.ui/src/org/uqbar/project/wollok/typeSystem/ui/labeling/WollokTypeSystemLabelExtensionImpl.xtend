package org.uqbar.project.wollok.typeSystem.ui.labeling

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.WollokTypeSystemActivator
import org.uqbar.project.wollok.ui.labeling.WollokTypeSystemLabelExtension
import org.apache.log4j.Logger

class WollokTypeSystemLabelExtensionImpl implements WollokTypeSystemLabelExtension {

	val Logger log = Logger.getLogger(this.class)

	override resolvedType(EObject o) {
		// if disabled
		if (!WollokTypeSystemActivator.^default.isTypeSystemEnabled(o))
			return null

		this.doResolvedType(o) ?: 
		"Any"
	}

	def doResolvedType(EObject o) {
		try {
			val typeSystem = WollokTypeSystemActivator.^default.getTypeSystem(o)
			return typeSystem.type(o)?.toString
		} catch (Exception e) {
			log.error("Error in type system !! " + e.message, e)
			return null
		}
	}

}