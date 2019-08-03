package org.uqbar.project.wollok.tests.interpreter

import com.google.inject.Inject
import java.io.File
import java.io.FileInputStream
import java.time.format.DateTimeFormatter
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.runner.RunWith
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider
import wollok.lang.WDate

/**
 * Abstract base class for all interpreter tests cases.
 * Already has all the necessary behavior and objects 
 * for subclasses just to write the test methods.
 * 
 * @author jfernandes
 */
@RunWith(XtextRunner)
@InjectWith(WollokTestInjectorProvider)
abstract class AbstractWollokInterpreterTestCase extends Assert {
	@Inject protected extension WollokParseHelper
	@Inject protected extension ValidationTestHelper
	@Inject protected XtextResourceSet resourceSet
	@Inject	protected extension WollokInterpreter interpreter
	public static val EXAMPLES_PROJECT_PATH = "../wollok-tests"

	@Before
	def void setUp() {
		interpreter.classLoader = AbstractWollokInterpreterTestCase.classLoader

		// This makes the Date string representation independent of the current user's locale
		WDate.FORMATTER = DateTimeFormatter.ofPattern("d/M/yy")

		new File("target/test-files").mkdirs
		new File("target/test-files/WOLLOK.ROOT").createNewFile
	}

	@After
	def void tearDown() {
		interpreter = null
		new File("target/test-files")
	}

	def interpret(String... programAsString) {
		this.interpret(false, programAsString.map[null -> it])
	}

	def interpretPropagatingErrors(CharSequence programAsString) {
		interpretPropagatingErrors(newArrayList(null as String -> programAsString.toString))
	}
	
	def expectsSyntaxError(CharSequence programAsString, String expectedMessage) {
		expectsSyntaxError(programAsString, expectedMessage, true)
	}
	
	def expectsSyntaxError(CharSequence programAsString, String expectedMessage, boolean onlyOneIssue) {
		expectsSyntaxError(programAsString, expectedMessage, onlyOneIssue, false)	
	}
	
	def expectsSyntaxError(CharSequence programAsString, String expectedMessage, boolean onlyOneIssue, boolean shouldBeSyntaxError) {
		val issues = programAsString.parse.validate
		if (onlyOneIssue && issues.length != 1) {
			fail("1 issue expected, found " + issues.length + ": " + issues) 
		}
		val issue = issues.findFirst [ message == expectedMessage ]
		Assert.assertNotNull("No issue found with message " + expectedMessage + ". Issues were: " + issues, issue)
		if (shouldBeSyntaxError) {
			Assert.assertTrue("Issue " + issue + " is not a syntax error.", issue.isSyntaxError)
		}
	}

	def expectsValidationError(CharSequence programAsString, String expectedMessage, boolean onlyOneIssue) {
		expectsSyntaxError(programAsString, expectedMessage, onlyOneIssue, false)
	}

	def expectsNoSyntaxError(CharSequence programAsString) {
		val issues = programAsString.parse.validate
		Assert.assertEquals("No issues were expected. Issues were: " + issues, 0, issues.length)
	}
	
	def test(CharSequence testCode) {
	    '''
	    import wollok.game.*
	    
	    program a {
    		«testCode»
	    } 
    	'''.interpretPropagatingErrors
	}
	

	def interpretPropagatingErrors(String... programAsString) {
		interpretPropagatingErrors(programAsString.map[null -> it])
	}

	def interpretPropagatingErrors(Pair<String, String>... programAsString) {
		interpret(true, programAsString)
	}

	def interpretPropagatingErrorsWithoutStaticChecks(CharSequence programAsString) {
		interpretPropagatingErrorsWithoutStaticChecks(newArrayList(null as String -> programAsString.toString))
	}

	def interpretPropagatingErrorsWithoutStaticChecks(String... programAsString) {
		interpretPropagatingErrorsWithoutStaticChecks(programAsString.map[new Pair(null, it)])
	}

	def interpretPropagatingErrorsWithoutStaticChecks(Pair<String, String>... programAsString) {
		interpret(true, true, programAsString)
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
		interpret(propagatingErrors, ignoreStaticErrors, false, programAsString)
	}

	def interpret(Boolean propagatingErrors, boolean ignoreStaticErrors, boolean saveFilesToDisk, Pair<String, String>... programAsString) {
		(programAsString.map[parse(resourceSet, saveFilesToDisk)].clone => [
			if (!ignoreStaticErrors)
				forEach[assertNoErrors]
			forEach[
				try {
					it.interpret(propagatingErrors)
				}catch (WollokProgramExceptionWrapper e) {
					if(e.isAssertion)
						throw new WollokComparisonFailure(e)
					else 
						throw e
				}
			]
		]).last
	}
	
	def interpretAsFilesPropagatingErrors(Pair<String, String>... programAsString) {
		interpret(true, false, true, programAsString)
	}

	def evaluate(String expression) {
		'''
			program evaluateExpression {
				const __expression__ = «expression» 
			}
		'''.toString.interpretPropagatingErrors

		interpreter.currentContext.resolve("__expression__")
	}

	def void assertIsException(Throwable exception, Class<? extends Throwable> clazz) {
		if (!clazz.isInstance(exception)) {
			if (exception.cause === null) {
				exception.printStackTrace
				fail('''Expecting exception «clazz.name» but found «exception.class.name»''')
			}
			else{
				assertIsException(exception.cause, clazz)
			}
		}
		
	}
	
	def String getMessageOf(Throwable exception, Class<? extends Throwable> clazz) {
		if (clazz.isInstance(exception)) {
			exception.message
		}
		else{
			if (exception.cause === null)
				fail('''Expecting exception «clazz.name» but found «exception.class.name»''')

			getMessageOf(exception.cause, clazz)
		}
		
	}
}
