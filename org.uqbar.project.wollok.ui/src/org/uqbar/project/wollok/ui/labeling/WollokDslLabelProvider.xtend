package org.uqbar.project.wollok.ui.labeling

import com.google.inject.Inject
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WFixture
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
import org.uqbar.project.wollok.wollokDsl.WSuite
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.XTextExtensions.*
import static extension org.uqbar.project.wollok.WollokConstants.*

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

	def text(WFile it) {
		eResource.URI.segmentsList.last	
	}

	def image(WFile it) {
		switch (eResource.URI.fileExtension) {
			case TEST_EXTENSION: "file_wtest.png"
			case PROGRAM_EXTENSION: "file_wpgm.png"
			default: "w.png"
		}
	}

	def image(WPackage it) { 'package.png' }

	def image(WProgram it) { 'program.png' }

	def image(WClass it) { 'wollok-icon-class_16.png' }
	
	def image(WMixin it) { 'wollok-icon-mixin_16.png' }

	def image(WTest it) { 'test.png' }

	def image(WSuite it) { 'describe.png' }

	def image(WFixture it) { 'fixture.png' }

	def image(WNamedObject it) { 'wollok-icon-object_16.png' }

	def image(WObjectLiteral it) { 'wollok-icon-object_16.png' }

	def text(WObjectLiteral it) { 'object' }

	def text(WFixture it) { 'fixture' }

	def text(WNamedObject it) { name ?: "<...>" }

	def synchronized concatResolvedType(String separator, EObject obj) {
		if (!labelExtensionResolved) {
			labelExtension = resolveLabelExtension
			labelExtensionResolved = true
		}

		if (labelExtension !== null) {
			val type = labelExtension.resolvedType(obj)
			if(type !== null) (separator + type) else ""
		} else
			""
	}

	def resolveLabelExtension() {
		val configPoints = Platform.getExtensionRegistry.getConfigurationElementsFor(
			"org.uqbar.project.wollok.ui.wollokTypeSystemLabelExtension")

		if (configPoints.empty)
			null
		else
			configPoints.get(0).createExecutableExtension("class") as WollokTypeSystemLabelExtension
	}

	def text(WVariableDeclaration it) {
		variable.name +	concatResolvedType(": ", variable)
	}

	def image(WVariableDeclaration it) { 
		if (property) {
			if (writeable) 
				'property-small.png'
			else
				'property-const-small.png'
		} else {
			if (writeable)
				'variable-small.png'
			else 
				'constant-small.png'
		} 
	}

	def text(WVariable it) { name + concatResolvedType(": ", it) }

	def image(WVariable ele) { 'variable.gif' }

	def text(WParameter it) { textForParam }

	def image(WParameter ele) { 'variable.gif' }

	def textForParam(WReferenciable it) { // solo para wparam y wclosureparam
		name + concatResolvedType(": ", it)
	}

	def text(WMethodDeclaration m) {
		(m.name ?: "<...>") + '(' + m.parameters.map[(name) + concatResolvedType(": ", it)].join(', ') + ')' +
			if(m.supposedToReturnValue) (" → " + concatResolvedType("", m)) else ""
	}

	def text(WConstructor c) {
		c.declaringContext?.name + '(' +
			c.parameters.map[name + concatResolvedType(": ", it)].join(', ') + ')'
	}

	def image(WMethodDeclaration method) {
		if(method.actuallyOverrides) 'annotation_override.gif' else 'wollok-icon-method_16.png'
	}

	def text(WMemberFeatureCall ele) { ele.feature + '(' + ele.memberCallArguments.map[ astNode.text ].join(',') + ')' }

	def image(WMemberFeatureCall ele) { 'wollok-icon-message_16.png' }

	def image(WVariableReference ele) { 'pointer.jpg' }

	def image(WAssignment a) { 'assignment.jpg' }

	def image(WNumberLiteral l) { 'number.png' }

	def image(WStringLiteral l) { 'string.png' }

}
