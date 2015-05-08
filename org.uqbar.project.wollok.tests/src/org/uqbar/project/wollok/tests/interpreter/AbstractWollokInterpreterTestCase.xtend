package org.uqbar.project.wollok.tests.interpreter

import com.google.inject.Inject
import java.io.File
import java.io.FileInputStream
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.eclipse.xtext.resource.XtextResourceSet
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.runner.RunWith
import org.uqbar.project.wollok.WollokDslInjectorProvider
import org.uqbar.project.wollok.interpreter.WollokInterpreter

/**
 * Abstract base class for all interpreter tests cases.
 * Already has all the necessary behavior and objects 
 * for subclasses just to write the test methods.
 * 
 * @author jfernandes
 */
@RunWith(XtextRunner)
@InjectWith(WollokDslInjectorProvider)
abstract class AbstractWollokInterpreterTestCase extends Assert {
	@Inject protected extension WollokParseHelper
	@Inject protected extension ValidationTestHelper
	@Inject protected XtextResourceSet resourceSet;
	@Inject
	protected extension WollokInterpreter interpreter
	public static val EXAMPLES_PROJECT_PATH = "../wollok-tests"

	@Before
	def void setUp() {
	}

	@After
	def void tearDown() {
		interpreter = null
	}

	def interpret(CharSequence... programAsString) {
		this.interpret(false, programAsString)
	}
	
	def interpretPropagatingErrors(CharSequence programAsString) {
		interpretPropagatingErrors(#[programAsString])
	}
	
	def interpretPropagatingErrors(CharSequence... programAsString) {
		this.interpret(true, programAsString)
	}

	def interpretPropagatingErrors(File fileToRead) {
		new FileInputStream(fileToRead).parse(URI.createFileURI(fileToRead.path), null, resourceSet) => [
			assertNoErrors
			interpret(true)
		]
	}

	def interpret(Boolean propagatingErrors, CharSequence... programAsString) {
		(programAsString.map[parse(resourceSet)].clone => [
			forEach[assertNoErrors]
			forEach[it.interpret(propagatingErrors)]
		]).last
	}

	def evaluate(String expression) {
		'''
			program evaluateExpression {
				val __expression__ = «expression» 
			}
		'''.interpretPropagatingErrors
		
		interpreter.currentContext.resolve("__expression__")
	}
}
