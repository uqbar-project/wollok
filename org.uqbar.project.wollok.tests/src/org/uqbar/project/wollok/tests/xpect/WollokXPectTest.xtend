package org.uqbar.project.wollok.tests.xpect

import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.junit.runner.RunWith
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.tests.injectors.WollokTestInjector
import org.xpect.runner.XpectRunner
import org.xpect.xtext.lib.tests.XtextTests

/**
 * @author jfernandes
 */
@RunWith(XpectRunner)
@InjectWith(WollokTestInjector)
class WollokXPectTest extends XtextTests {
	@Inject WollokClassFinder classFinder
}
