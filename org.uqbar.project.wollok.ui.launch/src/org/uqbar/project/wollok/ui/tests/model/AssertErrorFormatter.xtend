package org.uqbar.project.wollok.ui.tests.model

import wollok.lib.AssertionException

/**
 * @author tesonep
 */
class AssertErrorFormatter {

	def dispatch format(AssertionException e) {
		return e.message
	}
}