package org.uqbar.project.wollok.typesystem.constraints.variables

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.WollokType

interface ITypeVariable {
	def EObject getOwner()

	def void beSubtypeOf(ITypeVariable variable)

	def void beSupertypeOf(ITypeVariable variable)

	/**
	 * Creates a copy of this type variable, replacing parameters in the context of the received variable.
	 */
	def TypeVariable instanceFor(TypeVariable variable)

	def WollokType getType()
}
