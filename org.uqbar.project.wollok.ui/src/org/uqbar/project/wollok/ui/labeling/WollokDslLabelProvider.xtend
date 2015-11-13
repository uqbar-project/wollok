package org.uqbar.project.wollok.ui.labeling

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference
import org.eclipse.core.runtime.Platform

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import org.uqbar.project.wollok.wollokDsl.WNamedObject

/**
 * Provides labels for EObjects.
 * 
 * @author jfernandes
 */
class WollokDslLabelProvider extends DefaultEObjectLabelProvider {
	WollokTypeSystemLabelExtension labelExtension = null
	var labelExtensionResolved = false

	@Inject
	new(AdapterFactoryLabelProvider delegate) {
		super(delegate)
	}
		
	def image(WPackage ele) { 'package.png' }
	def image(WProgram ele) { 'wollok-icon-program_16.png' }
	def image(WClass ele) {	'wollok-icon-class_16.png' }
	
	def text(WObjectLiteral ele) { 'object' }
	def image(WObjectLiteral ele) {	'wollok-icon-object_16.png' }
	
	def text(WNamedObject ele) { 'object' }
	def image(WNamedObject ele) { 'wollok-icon-object_16.png' }
	
	def concatResolvedType(String separator, EObject obj) {
		if (!labelExtensionResolved) {
			labelExtension = resolveLabelExtension
			labelExtensionResolved = true
		}
		
		if (labelExtension != null)
			separator + labelExtension.resolvedType(obj)
		else 
			""
	}
	
	def resolveLabelExtension() {
		val configPoints = Platform.getExtensionRegistry.getConfigurationElementsFor("org.uqbar.project.wollok.ui.wollokTypeSystemLabelExtension")

		if (configPoints.empty)
			null
		else
			configPoints.get(0).createExecutableExtension("class") as WollokTypeSystemLabelExtension
	}
	
	def text(WVariableDeclaration it) { 
		(if(writeable) "var " else "val ") + variable.name + concatResolvedType(": ", variable)
	}
	def image(WVariableDeclaration ele) { 'wollok-icon-variable_16.png' }

	def text(WVariable ele) { ele.name + concatResolvedType(": ",ele) }
	def image(WVariable ele) 	{ 'variable.gif' }
	
	def text(WParameter p) { textForParam(p) }
	def image(WParameter ele) { 'variable.gif' }
	
	def textForParam(WReferenciable p) { // solo para wparam y wclosureparam
		p.name + concatResolvedType(": ", p)
	}
	
	def text(WMethodDeclaration m) { 
		m.name + '(' + m.parameters.map[name + concatResolvedType(" ",it) ].join(',') + ')' 
			+ if (m.returnsValue) (" → " + concatResolvedType("",m)) else "" 
	}
	def text(WConstructor m) {
		'new(' + m.parameters.map[name + concatResolvedType(" ",it)].join(',') + ')'
	}
	
	def image(WMethodDeclaration ele) { 'wollok-icon-method_16.png' }
	
	def text(WMemberFeatureCall ele) { ele.feature + '(' + ele.memberCallArguments.map[doGetText(it)].join(',') + ')' }
	def image(WMemberFeatureCall ele) { 'wollok-icon-message_16.png' }
	
	def image(WVariableReference ele) { 'pointer.jpg' }
	def image(WAssignment a) { 'assignment.jpg' }
	
	def image(WNumberLiteral l) { 'number.png' }
	def image(WStringLiteral l) { 'string.png' }
	
}
