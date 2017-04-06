package org.uqbar.project.wollok.tests.xpect

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.junit.runner.RunWith
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.tests.injectors.WollokTestInjector
import org.xpect.runner.XpectRunner

/**
 * @author jfernandes
 */
@RunWith(XpectRunner)
@InjectWith(WollokTestInjector)
class WollokXPectTest {
	@Inject WollokClassFinder classFinder
}
