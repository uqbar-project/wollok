package org.uqbar.project.wollok.typesystem.constraints.variables

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall

class ClassParameterTypeVariable implements ITypeVariable {
	@Accessors
	EObject owner
	
	@Accessors
	extension TypeVariablesRegistry registry

	String paramName

	new(EObject owner, String paramName) {
		this.owner = owner
		this.paramName = paramName
	}

	override beSubtypeOf(TypeVariable variable) {
		variable.owner.classTypeParameter.beSubtypeOf(variable)
	}

	override beSupertypeOf(TypeVariable variable) {
		variable.owner.classTypeParameter.beSupertypeOf(variable)
	}

	def classTypeParameter(EObject owner) {
		val messageSend = owner as WMemberFeatureCall
		val receiverTypeInfo = messageSend.memberCallTarget.tvar.typeInfo as GenericTypeInfo
		receiverTypeInfo.param(paramName)
	}

}
