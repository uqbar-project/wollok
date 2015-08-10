package org.uqbar.project.wollok.tests.interpreter

import com.google.inject.Inject
import java.io.File
import java.io.FileInputStream
import java.util.HashMap
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.eclipse.xtext.resource.XtextResourceSet
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.runner.RunWith
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.tests.interpreter.repl.WollokReplInjector

/**
 * Abstract base class for all interpreter tests cases.
 * Already has all the necessary behavior and objects 
 * for subclasses just to write the test methods.
 * 
 * @author jfernandes
 */
@RunWith(XtextRunner)
@InjectWith(WollokReplInjector)
abstract class AbstractWollokInterpreterTestCase extends Assert {
	@Inject protected extension WollokParseHelper
	@Inject protected extension ValidationTestHelper
	@Inject protected XtextResourceSet resourceSet;
	@Inject
	protected extension WollokInterpreter interpreter
	public static val EXAMPLES_PROJECT_PATH = "../wollok-tests"

	@Before
	def void setUp() {
		interpreter.classLoader = AbstractWollokInterpreterTestCase.classLoader

	//		val resource = resourceSet.createResource(URI.createURI("../org.uqbar.project.wollok.lib/src/wollok.wlk", true))
	//		resource.load(new HashMap())
	//		resourceSet.getResources().add(resource);
	}

	@After
	def void tearDown() {
		interpreter = null
	}

	def interpret(String... programAsString) {
		this.interpret(false, programAsString.map[null -> it])
	}

	def interpretPropagatingErrors(CharSequence programAsString) {
		interpretPropagatingErrors(newArrayList(null as String -> programAsString.toString))
	}

	def interpretPropagatingErrors(String... programAsString) {
		interpretPropagatingErrors(programAsString.map[null -> it])
	}

	def interpretPropagatingErrors(Pair<String, String>... programAsString) {
		this.interpret(true, programAsString)
	}

	def interpretPropagatingErrorsWithoutStaticChecks(String... programAsString) {
		interpretPropagatingErrorsWithoutStaticChecks(programAsString.map[new Pair(null, it)])
	}

	def interpretPropagatingErrorsWithoutStaticChecks(Pair<String, String>... programAsString) {
		this.interpret(true, true, programAsString)
	}

	def interpretPropagatingErrors(File fileToRead) {
		new FileInputStream(fileToRead).parse(URI.createFileURI(fileToRead.path), null, resourceSet) => [
			assertNoErrors
			interpret(true)
		]
	}

	def interpret(Boolean propagatingErrors, Pair<String, String>... programAsString) {
		interpret(propagatingErrors, false, programAsString)
	}

	def interpret(Boolean propagatingErrors, boolean ignoreStaticErrors, Pair<String, String>... programAsString) {
		(programAsString.map[parse(resourceSet)].clone => [
			if (!ignoreStaticErrors)
				forEach[assertNoErrors]
			forEach[it.interpret(propagatingErrors)]
		]).last
	}

	def evaluate(String expression) {
		'''
			program evaluateExpression {
				val __expression__ = «expression» 
			}
		'''.toString.interpretPropagatingErrors

		interpreter.currentContext.resolve("__expression__")
	}

	def void assertIsException(Throwable exception, Class<? extends Throwable> clazz) {
		if(!clazz.isInstance(exception)){
			if(exception.cause == null){
				exception.printStackTrace
				fail('''Expecting exception «clazz.name» but found «exception.class.name»''')
			}else{
				assertIsException(exception.cause, clazz)
			}
		}
		
	}
	
	def getMessageOf(Throwable exception, Class<? extends Throwable> clazz) {
		if(clazz.isInstance(exception)){
			exception.message
		}else{
			if(exception.cause == null)
				fail('''Expecting exception «clazz.name» but found «exception.class.name»''')
			else{
				getMessageOf(exception.cause, clazz)
			}
		}
		
	}
}
