package org.uqbar.project.wollok.typesystem.constraints

import java.util.regex.Pattern
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference
import org.uqbar.project.wollok.wollokDsl.WollokDslFactory
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.uqbar.project.wollok.wollokDsl.WParameter

class WollokModelPrintForDebug {
	static def dispatch String debugInfo(Void obj) {
		// TODO A variable without an owner is a synthetic var.
		// Syntetetic variables should have their own way of specifying something that allows us to identify where came this variable from.
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

	static def dispatch String debugInfo(WVariableReference it) {
		'''ref «ref.debugInfo»'''
	}

	static def dispatch String debugInfo(WVariableDeclaration it) {
		
		'''«if (writeable) "var" else "const"» «variable.debugInfo»'''
	}

	static def dispatch String debugInfo(WBinaryOperation it) {
		'''«leftOperand.debugInfo» «feature» «rightOperand.debugInfo»'''
	}

	static def dispatch String debugInfo(WMethodDeclaration it) {
		'''«eContainer.name».«name»(«parameters.join(', ')[name]»)'''
	}

	static def dispatch String debugInfo(WParameter it) {
		'''«it.eContainer.debugInfo».param[«name»]'''
	}
}
