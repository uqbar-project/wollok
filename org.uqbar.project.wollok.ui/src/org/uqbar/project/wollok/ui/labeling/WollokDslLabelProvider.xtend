package org.uqbar.project.wollok.ui.labeling

import com.google.inject.Inject
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import org.uqbar.project.wollok.services.WollokDslGrammarAccess

/**
 * Provides labels for EObjects.
 * 
 * @author jfernandes
 */
class WollokDslLabelProvider extends DefaultEObjectLabelProvider {
	WollokTypeSystemLabelExtension labelExtension = null
	@Inject
	WollokDslGrammarAccess grammar
	var labelExtensionResolved = false

	@Inject
	new(AdapterFactoryLabelProvider delegate) {
		super(delegate)
	}
		
	def image(WPackage it) { 'package.png' }
	def image(WProgram it) { 'wollok-icon-program_16.png' }
	def image(WClass it) {	'wollok-icon-class_16.png' }
	def image(WMixin it) {	'wollok-icon-mixin_16.png' }
	def image(WTest it) { 'wollok-icon-test_16.png' }
	
	def text(WObjectLiteral it) { 'object' }
	def image(WObjectLiteral it) {	'wollok-icon-object_16.png' }
	
	def text(WNamedObject it) { name }
	def image(WNamedObject it) { 'wollok-icon-object_16.png' }
	
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
		(if (writeable)
			// var 
			grammar.WVariableDeclarationAccess.writeableVarKeyword_1_0_0.value
			else
			// const 
			grammar.WVariableDeclarationAccess.constKeyword_1_1.value) + " " + variable.name + concatResolvedType(": ", variable)
	}
	def image(WVariableDeclaration ele) { 'wollok-icon-variable_16.png' }

	def text(WVariable it) { name + concatResolvedType(": ", it) }
	def image(WVariable ele) 	{ 'variable.gif' }
	
	def text(WParameter it) { textForParam }
	def image(WParameter ele) { 'variable.gif' }
	
	def textForParam(WReferenciable it) { // solo para wparam y wclosureparam
		name + concatResolvedType(": ", it)
	}
	
	def text(WMethodDeclaration m) {
		m.name + '(' + m.parameters.map[name + concatResolvedType(" ",it) ].join(',') + ')' 
				+ if (m.supposedToReturnValue) (" → " + concatResolvedType("",m)) else ""
	}
	def text(WConstructor m) {
		
		grammar.WConstructorAccess.constructorKeyword_1 + '(' + m.parameters.map[name + concatResolvedType(" ",it)].join(',') + ')'
	}
	
	def image(WMethodDeclaration ele) { 'wollok-icon-method_16.png' }
	
	def text(WMemberFeatureCall ele) { ele.feature + '(' + ele.memberCallArguments.map[doGetText(it)].join(',') + ')' }
	def image(WMemberFeatureCall ele) { 'wollok-icon-message_16.png' }
	
	def image(WVariableReference ele) { 'pointer.jpg' }
	def image(WAssignment a) { 'assignment.jpg' }
	
	def image(WNumberLiteral l) { 'number.png' }
	def image(WStringLiteral l) { 'string.png' }
	
}
