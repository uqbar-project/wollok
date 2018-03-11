package org.uqbar.project.wollok.typesystem.preferences

import org.eclipse.core.resources.IProject

interface WollokTypeSystemPreference {
	def boolean isTypeSystemEnabled(IProject project)
	def String getSelectedTypeSystem(IProject project)
}