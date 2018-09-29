package org.uqbar.project.wollok.typeSystem.ui.labeling

import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.WollokTypeSystemActivator
import org.uqbar.project.wollok.ui.labeling.WollokTypeSystemLabelExtension

class WollokTypeSystemLabelExtensionImpl implements WollokTypeSystemLabelExtension {

	val Logger log = Logger.getLogger(this.class)

	override resolvedType(EObject o) {
		// if disabled
		if (!o.isTypeSystemEnabled)
			return null

		o.doResolvedType?.toString ?: "Any"
	}
	
	override allMessages(EObject o) {
		if (!o.isTypeSystemEnabled)
			return newArrayList
			
		o.doResolvedType.allMessages.map [ messageType | messageType.method ].toList
	}

	override isTypeSystemEnabled(EObject o) {
		WollokTypeSystemActivator.^default.isTypeSystemEnabled(o)
	}
	
	def doResolvedType(EObject o) {
		try {
			val typeSystem = WollokTypeSystemActivator.^default.getTypeSystem(o)
			return typeSystem.type(o)
		} catch (Exception e) {
			log.error("Error in type system !! " + e.message, e)
			return null
		}
	}

}