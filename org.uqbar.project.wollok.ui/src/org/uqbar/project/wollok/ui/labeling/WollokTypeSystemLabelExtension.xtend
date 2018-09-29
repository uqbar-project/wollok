package org.uqbar.project.wollok.ui.labeling

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

interface WollokTypeSystemLabelExtension {
	def String resolvedType(EObject obj)
	def List<WMethodDeclaration> allMessages(EObject obj)
	def boolean isTypeSystemEnabled(EObject obj)
}