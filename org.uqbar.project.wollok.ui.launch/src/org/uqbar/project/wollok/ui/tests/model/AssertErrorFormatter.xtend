package org.uqbar.project.wollok.ui.tests.model

import java.text.MessageFormat
import org.uqbar.project.wollok.ui.i18n.WollokLaunchUIMessages
import wollok.lib.AssertionException
import wollok.lib.ValueWasNotDifferentException
import wollok.lib.ValueWasNotEqualsException
import wollok.lib.ValueWasNotFalseException
import wollok.lib.ValueWasNotTrueException

/**
 * @author tesonep
 */
class AssertErrorFormatter {
	def dispatch format(ValueWasNotTrueException e) {
		WollokLaunchUIMessages.WollokTestState_ASSERT_WAS_NOT_TRUE
	}

	def dispatch format(ValueWasNotFalseException e) {
		WollokLaunchUIMessages.WollokTestState_ASSERT_WAS_NOT_FALSE
	}

	def dispatch format(ValueWasNotEqualsException e) {
		MessageFormat.format(WollokLaunchUIMessages.WollokTestState_ASSERT_WAS_NOT_EQUALS, e.expected, e.actual);
	}

	def dispatch format(ValueWasNotDifferentException e) {
		MessageFormat.format(WollokLaunchUIMessages.WollokTestState_ASSERT_WAS_NOT_DIFFERENT, e.expected, e.actual);
	}

	def dispatch format(AssertionException e) {
		return e.message
	}
}