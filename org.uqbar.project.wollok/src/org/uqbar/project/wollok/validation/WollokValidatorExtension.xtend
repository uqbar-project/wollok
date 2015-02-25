package org.uqbar.project.wollok.validation

import org.uqbar.project.wollok.wollokDsl.WFile

interface WollokValidatorExtension {
	def void check(WFile file, WollokDslValidator validator)
}