package org.uqbar.project.wollok.ui.labeling

import org.eclipse.emf.ecore.EObject

interface WollokTypeSystemLabelExtension {
	def String resolvedType(EObject obj)
}