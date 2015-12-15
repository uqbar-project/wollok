package org.uqbar.project.wollok.tests.typesystem

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.uqbar.project.wollok.typesystem.ClassBasedWollokType
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem
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
abstract class AbstractWollokTypeSystemTestCase extends AbstractWollokInterpreterTestCase {
	public extension TypeSystem ts
	
	new() { ts = createTypeSystem }
	new(TypeSystem system) { ts = system }
	
	def TypeSystem createTypeSystem() {
//		new BoundsBasedTypeSystem
		new SubstitutionBasedTypeSystem
//		new ConstraintBasedTypeSystem
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
	
	def assertTypeOf(EObject program, WollokType expectedType, String programToken) {
		assertEquals(expectedType, program.findByText(programToken).type)
	}
	
	def assertConstructorType(EObject program, String className, String paramsSignature) {
		val nrOfParams = paramsSignature.split(',').length;
		assertEquals(paramsSignature, "(" + findConstructor(className, nrOfParams).parameters.map[type?.name].join(", ") + ")")
	}
	
	def assertMethodSignature(EObject program, String expectedSignature, String methodFQN) {
		assertEquals(expectedSignature, findMethod(methodFQN).functionType(ts))
	}
	
	def assertInstanceVarType(EObject program, WollokType expectedType, String instVarFQN) {
		assertEquals(expectedType, findInstanceVar(instVarFQN).type)
	}
	
	def noIssues(EObject program) {
		val issues = program.eAllContents.map[issues].toList.flatten
		assertTrue("Expecting no errors but found: " +  
			issues.map['''[«model.class.simpleName» - «NodeModelUtils.getNode(model).text»]: «message»'''],
			issues.isEmpty
		)
	}
	
	def assertIssues(EObject program, String programToken, String... expectedIssues) {
		val element = program.findByText(programToken)
		val issues = element.issues.toList
		
		val nonCompliant = expectedIssues.filter[expected| !issues.exists[message == expected]]
		if (!nonCompliant.empty)
			fail("Expecting the following issues on '" +  programToken + "' but they were not present: " + nonCompliant + "\nAlthough there were the following errors: " + issues)
		
		val unexpecteds = issues.filter[i| !expectedIssues.contains(i.message)]
		if (!unexpecteds.empty)
			fail("Unexpected issues: " + issues)
	}
	
	// FINDS
	
	def static findByText(EObject model, String token) {
		val found = NodeModelUtils.findActualNodeFor(model).asTreeIterable //
			.findFirst[n| 
				escapeNodeTextToCompare(n.text) == token && n.hasDirectSemanticElement 
			]
		assertNotNull("Could NOT find program token '" + token + "'", found)
		found.semanticElement
	}
	
	def static String escapeNodeTextToCompare(String nodeText) {
		if (nodeText.startsWith("\n"))
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
		findClass(fqn.get(0)).methods.findFirst[name == fqn.get(1)]
	}
	
	def findInstanceVar(String instVarFQN) {
		val fqn = instVarFQN.split('\\.') 
		findClass(fqn.get(0)).variableDeclarations.findFirst[variable.name == fqn.get(1)]
	}
	
	def findClass(String className) {
		resourceSet.allContents.filter(WClass).findFirst[name == className]
	}
	
	def classType(String className) {
		new ClassBasedWollokType(findClass(className), null)
	}
	
}