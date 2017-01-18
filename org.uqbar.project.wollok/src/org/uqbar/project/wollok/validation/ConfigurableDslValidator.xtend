package org.uqbar.project.wollok.validation

import org.eclipse.emf.ecore.EObject

interface ConfigurableDslValidator {
	
	def void report(String string, EObject object)
	
}