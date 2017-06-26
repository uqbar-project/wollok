package org.uqbar.project.wollok.tests.xpect

import org.eclipse.xtext.testing.InjectWith
import org.junit.runner.RunWith
import org.uqbar.project.wollok.tests.injectors.WollokTestInjector
import org.xpect.runner.XpectRunner
import org.xpect.xtext.lib.tests.XtextTests

/**
 * @author jfernandes
 */
@RunWith(XpectRunner)
@InjectWith(WollokTestInjector)
class WollokXPectTest extends XtextTests{
}
