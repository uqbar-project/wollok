package org.uqbar.project.wollok.validation

import org.uqbar.project.wollok.wollokDsl.WFile

/**
 * Extension point for static code checks
 */
interface WollokValidatorExtension {
	def void check(WFile file, WollokDslValidator validator)
}