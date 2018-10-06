package org.uqbar.project.wollok.typeSystem.ui.labeling

import java.util.List
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.MessageType
import org.uqbar.project.wollok.typesystem.WollokType
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
	
	// TODO: We should define this service public in the interface
	// MessageType should be exported in TypeSystem bundle in order to be visible
	// for external ones, like wollok.ui
	def allMessages(EObject o) {
		o.ifHasType [ resolvedType | resolvedType.allMessages.toList ]
	}
	
	override allMethods(EObject o) {
		o.allMessages.map [ method ].toList
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

	def List<MessageType> ifHasType(EObject o, (WollokType)=>List<MessageType> declarations) {
		if (!o.isTypeSystemEnabled) return newArrayList
		val resolvedType = o.doResolvedType
		if (resolvedType === null) return newArrayList
		declarations.apply(resolvedType)
	}
	
}