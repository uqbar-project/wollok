package org.uqbar.project.wollok.typesystem.preferences

import org.eclipse.emf.ecore.EObject

interface WollokTypeSystemPreference {
	def boolean isTypeSystemEnabled(EObject file)
	def String getSelectedTypeSystem(EObject file)
}