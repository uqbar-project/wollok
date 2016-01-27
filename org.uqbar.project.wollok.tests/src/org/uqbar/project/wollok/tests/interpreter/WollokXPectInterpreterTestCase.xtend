package org.uqbar.project.wollok.tests.interpreter

import org.eclipse.emf.ecore.EObject
import org.junit.runner.RunWith
import org.xpect.runner.Xpect
import org.xpect.runner.XpectRunner
import org.xpect.runner.XpectSuiteClasses
import org.xpect.xtext.lib.setup.ThisModel
import org.xpect.xtext.lib.tests.JvmModelInferrerTest
import org.xpect.xtext.lib.tests.LinkingTest
import org.xpect.xtext.lib.tests.ResourceDescriptionTest
import org.xpect.xtext.lib.tests.ScopingTest
import org.xpect.xtext.lib.tests.ValidationTest

/**
 * Xpect tests for wollok, but for testing program execution
 * not just static validations.
 * 
 * @author jfernandes
 */
@XpectSuiteClasses(#[ JvmModelInferrerTest, LinkingTest, ResourceDescriptionTest, ScopingTest, ValidationTest ])
@RunWith(XpectRunner)
class WollokXPectInterpreterTestCase extends AbstractWollokInterpreterTestCase {
	
	@Xpect
	def void interpret(@ThisModel EObject file) {
		file.safeInterpret	
	}
	
}