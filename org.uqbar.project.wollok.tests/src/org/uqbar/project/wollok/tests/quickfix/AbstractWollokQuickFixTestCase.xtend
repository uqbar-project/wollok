package org.uqbar.project.wollok.tests.quickfix

import com.google.inject.Inject
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.resource.OutdatedStateManager
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.model.DocumentTokenSource
import org.eclipse.xtext.ui.editor.model.XtextDocument
import org.eclipse.xtext.ui.editor.model.edit.ITextEditComposer
import org.eclipse.xtext.ui.editor.model.edit.IssueModificationContext
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor
import org.eclipse.xtext.validation.Issue
import org.mockito.stubbing.Answer
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.uqbar.project.wollok.ui.quickfix.WollokDslQuickfixProvider
import org.uqbar.project.wollok.wollokDsl.WFile

import static org.mockito.Matchers.*
import static org.mockito.Mockito.*

abstract class AbstractWollokQuickFixTestCase extends AbstractWollokInterpreterTestCase {
	
	WollokDslQuickfixProvider issueResolutionProvider

	@Inject DocumentTokenSource tokenSource
	@Inject ITextEditComposer composer
	@Inject OutdatedStateManager outdatedStateManager;

	/**
	 * Used to test the quickfix, receives two lists of files.
	 * To allow easy includes the "virtual" files are named fileX.wlk, where X is the order (of course starting in 0)
	 * @see MethodOnWKODoesntExistQuickFixTest for an example
	 */
	def void assertQuickfix(List<String> initial, List<String> result, String quickFixDescription) {
		val sources = <QuickFixTestSource>newArrayList()
		val issues = <Issue>newArrayList()

		(0 .. (initial.size - 1)).forEach [ index |
			sources.add(new QuickFixTestSource => [
				initialCode = initial.get(index)
				expectedCode = result.get(index)
				model = (("file" + index ) -> initialCode).parse(resourceSet, false)

				xtextDocument = new XtextDocument(tokenSource, composer, outdatedStateManager, null)
				xtextDocument.set(initialCode)
				xtextDocument.input = model.eResource as XtextResource

				issues.addAll(model.validate)
			])
		]

		assertEquals("The number of issues should be exactly 1: " + issues, issues.size, 1)
		val testedIssue = issues.get(0)

		val Answer<XtextDocument> answerXtextDocument = [ call |
			val uri = if(call.arguments.size == 0) testedIssue.uriToProblem else (call.arguments.get(0) as URI)
			val value = uri.trimFragment.toString
			sources.findFirst[model.eResource.URI.toString == value]?.xtextDocument
		]

		val issueModificationContext = mock(IssueModificationContext) => [
			when(getXtextDocument()).then(answerXtextDocument)
			when(getXtextDocument(any(URI))).then(answerXtextDocument)
		]

		val IssueModificationContext.Factory issueFactory = mock(IssueModificationContext.Factory) => [ 
			when(createModificationContext(any(Issue))).thenReturn(issueModificationContext)
		] 

		issueResolutionProvider = new WollokDslQuickfixProvider => [
			issueResolutionAcceptorProvider = [new IssueResolutionAcceptor[issueModificationContext]]
			modificationContextFactory = issueFactory
		]
		
		assertTrue("There is no solution for the issue: " + testedIssue, issueResolutionProvider.hasResolutionFor(testedIssue.code))

//		issueResolutionProvider => [
//			when(getContextFactory).thenReturn(issueFactory)
//		]
		
		val resolutions = issueResolutionProvider.getResolutions(testedIssue)
	
		println(resolutions)
				
		val resolution = resolutions.findFirst[it.label == quickFixDescription]
		
		assertNotNull("Could not find a quickFix with the description " + quickFixDescription,resolution)

		resolution.apply
		
		println("Expected code")
		println("*************")
		println(sources.map [ expectedCode.toString ])
		println("vs.")
		println(sources.map [ xtextDocument.get.toString ])
		println("====================")
		sources.forEach [ assertEquals(expectedCode.toString, xtextDocument.get.toString)  ]
	}
}

@Accessors
class QuickFixTestSource {
	String initialCode
	WFile model
	String expectedCode
	XtextDocument xtextDocument
}