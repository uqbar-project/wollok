package org.uqbar.project.wollok.typesystem.preferences

import org.eclipse.core.resources.IProject
import org.eclipse.emf.ecore.EObject

interface WollokTypeSystemPreference {
	
	val String CONSTRAINTS_BASED = "Constraints-based"
	
	def boolean isTypeSystemEnabled(EObject file)
	def String getSelectedTypeSystem(EObject file)
	def boolean isTypeSystemEnabled(IProject file)
	def String getSelectedTypeSystem(IProject file)
	
	
}