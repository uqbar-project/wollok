package org.uqbar.project.wollok.typesystem.constraints

import java.util.regex.Pattern
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference
import org.uqbar.project.wollok.wollokDsl.WollokDslFactory

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

class WollokModelPrintForDebug {
	static def dispatch String debugInfo(Void obj) {
		// TODO A variable without an owner is a synthetic var.
		// Synthetic variables should have their own way of specifying something that allows us to identify where came this variable from.
		// Also this might not be the best place for this kind of logic, specific to synthetic variables.
		"synthetic"
	}

	static def dispatch String debugInfo(EObject obj) {
		val base = obj.toString
		val prefix = (WollokDslFactory.package.name + ".impl.").replace(".", "\\.")
		val pattern = Pattern.compile(prefix + "W?(\\w*)Impl@(?:[0-9a-f]+)(.*)")
		val matcher = pattern.matcher(base)

		if (matcher.matches)
			matcher.group(1) + matcher.group(2)
		else
			base
	}

	static def dispatch String debugInfo(WClass it)
		'''class «name»'''

	static def dispatch String debugInfo(WVariableReference it)
		'''«ref.name»'''

	static def dispatch String debugInfo(WVariableDeclaration it) 
		'''«if (writeable) "var" else "const"» «variable.debugInfo»'''

	static def dispatch String debugInfo(WBinaryOperation it) 
		'''«leftOperand.debugInfo» «feature» «rightOperand.debugInfo»'''

	static def dispatch String debugInfo(WMethodDeclaration it) 
		'''method «eContainer.name».«name»(«parameters.join(', ')[name]») {«System.identityHashCode(it)»}'''

	static def dispatch String debugInfo(WParameter it)
		'''param «name»'''

	static def dispatch String debugInfo(WMemberFeatureCall it)
		'''«memberCallTarget.debugInfo».«feature».(«memberCallArguments.join(', ')[debugInfo]»)'''

	static def dispatch String debugInfo(WVariable it)
		'''&«name»'''

	static def dispatch String debugInfo(WNumberLiteral it)
		'''«value»'''

	static def dispatch String debugInfo(WStringLiteral it)
		'''"«value»"'''

	static def dispatch String debugInfo(WAssignment it)
		'''«feature.debugInfo» = «value.debugInfo»'''

	static def dispatch String debugInfo(WBlockExpression it)
		'''body of «eContainer.debugInfoInContext»'''

	// ************************************************************************
	// ** Debug info with context
	// ************************************************************************

	static def dispatch String debugInfoInContext(TypeVariable tvar) {
		tvar.owner.debugInfoInContext
	}

	static def dispatch String debugInfoInContext(Void obj) {
		"synthetic"
	}

	static def dispatch String debugInfoInContext(EObject obj) {
		obj.debugInfo
	}
	
	static def dispatch String debugInfoInContext(WParameter it)
		'''«debugInfo» from «eContainer.debugInfoInContext»'''

	static def dispatch String debugInfoInContext(WVariableReference it)
		'''«debugInfo» in «method.debugInfoInContext»'''
}
