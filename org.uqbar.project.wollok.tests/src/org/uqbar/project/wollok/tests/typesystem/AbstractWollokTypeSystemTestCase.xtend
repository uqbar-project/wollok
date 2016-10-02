package org.uqbar.project.wollok.tests.typesystem

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.junit.Before
import org.junit.runners.Parameterized.Parameter
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.tests.base.AbstractWollokParameterizedInterpreterTest
import org.uqbar.project.wollok.typesystem.ClassBasedWollokType
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WFile

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.typesystem.TypeSystemUtils.*

/**
 * Abstract base class for all type system test cases.
 * Provides utility methods for parsing, type checking
 * and asserting program types.
 * 
 * @author jfernandes
 */
abstract class AbstractWollokTypeSystemTestCase extends AbstractWollokParameterizedInterpreterTest {
	@Parameter
	public extension TypeSystem tsystem
	
	@Before
	def void setupTypeSystem() {
		injector.injectMembers(tsystem)
	}
	
	// Utility
	
	def parseAndInfer(CharSequence file) {
		parseAndInfer(#[file])
	}
	
	def parseAndInfer(CharSequence... files) {
		(files.map[parse(resourceSet)].clone => [
			forEach[validate]
			forEach[analyse]
			inferTypes
		]).last
	}
	
	def asserting(WFile f, (WFile)=>void assertions) {
		assertions.apply(f)
	}
	
	// ********************
	// ** assertions
	// ********************
	
	@Inject WollokClassFinder finder
	
	def classTypeFor(EObject context, String className) {
		new ClassBasedWollokType(finder.getCachedClass(context, className), tsystem)
	} 
	
	def assertTypeOf(EObject program, WollokType expectedType, String programToken) {
		assertEquals("Unmatched type for '" + programToken + "'", expectedType, program.findByText(programToken).type)
	}
	
	def assertTypeOfAsString(EObject program, String expectedType, String token) {
		assertEquals("Unmatched type for '" + token + "'", expectedType, program.findByText(token).type.name)
	}
	
	def assertConstructorType(EObject program, String className, String paramsSignature) {
		val nrOfParams = paramsSignature.split(',').length;
		assertEquals(paramsSignature, "(" + findConstructor(className, nrOfParams).parameters.map[type?.name].join(", ") + ")")
	}
	
	def assertMethodSignature(EObject program, String expectedSignature, String methodFQN) {
		assertEquals(expectedSignature, findMethod(methodFQN).functionType(tsystem))
	}
	
	def assertInstanceVarType(EObject program, WollokType expectedType, String instVarFQN) {
		assertEquals(expectedType, findInstanceVar(instVarFQN).type)
	}
	
	def noIssues(EObject program) {
		val issues = program.eAllContents.map[issues].toList.flatten
		val errorMessage = issues.map['''[«model?.class?.simpleName» - «NodeModelUtils.getNode(model)?.text»]: «message»''']
		assertTrue("Expecting no errors but found: " + errorMessage, issues == null || issues.isEmpty)
	}
	
	def assertIssues(EObject program, String programToken, String... expectedIssues) {
		val element = program.findByText(programToken)
		val issues = element.issues.toList
		
		val nonCompliant = expectedIssues.filter[expected| !issues.exists[message == expected]]
		if (!nonCompliant.empty)
			fail("Expecting the following issues on '" +  programToken + "' but they were not present: " + nonCompliant + System.lineSeparator + "Although there were the following errors: " + issues)
		
		val unexpecteds = issues.filter[i| !expectedIssues.contains(i.message)]
		if (!unexpecteds.empty)
			fail("Unexpected issues: " + issues)
	}
	
	// FINDS
	
	def static findByText(EObject model, String token) {
		val found = NodeModelUtils.findActualNodeFor(model).asTreeIterable //
			.findFirst[n| 
				escapeNodeTextToCompare(n.text.trim) == token && n.hasDirectSemanticElement 
			]
		assertNotNull("Could NOT find program token '" + token + "'", found)
		found.semanticElement
	}
	
	def static String escapeNodeTextToCompare(String nodeText) {
		if (nodeText.startsWith(System.lineSeparator))
			nodeText.substring(1).escapeNodeTextToCompare
		else if (nodeText.startsWith("\t"))
			nodeText.substring(1).escapeNodeTextToCompare
		else
			nodeText
	}
	
	def findConstructor(String className, int nrOfParams) {
		findClass(className).constructors.findFirst[ matches(nrOfParams) ]
	}
	
	def findMethod(String methodFQN) {
		val fqn = methodFQN.split('\\.') 
		val m = findClass(fqn.get(0)).methods.findFirst[name == fqn.get(1)]
		if (m == null) 
			throw new RuntimeException("Could NOT find method " + methodFQN)
		m
	}
	
	def findInstanceVar(String instVarFQN) {
		val fqn = instVarFQN.split('\\.') 
		findClass(fqn.get(0)).variableDeclarations.findFirst[variable.name == fqn.get(1)]
	}
	
	def findClass(String className) {
		val c = resourceSet.allContents.filter(WClass).findFirst[name == className]
		if (c == null) throw new RuntimeException(
			'''Could NOT find class [«className»] in: «resourceSet.allContents.filter(WClass).map[name].toList»''')
		c
	}
}