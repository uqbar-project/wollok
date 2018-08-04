package org.uqbar.project.wollok.typesystem.preferences

import org.eclipse.core.resources.IProject
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.validation.CheckSeverity

interface WollokTypeSystemPreference {
	
	def boolean isTypeSystemEnabled(EObject file)
	def String getSelectedTypeSystem(EObject file)
	def boolean isTypeSystemEnabled(IProject file)
	def String getSelectedTypeSystem(IProject file)
	def CheckSeverity getTypeSystemSeverity()
	
}