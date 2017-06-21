package org.uqbar.project.wollok.tests.typesystem.xpect

import com.google.common.collect.Multimap
import com.google.inject.Inject
import com.google.inject.Injector
import com.google.inject.Provider
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.validation.Issue
import org.junit.runner.RunWith
import org.uqbar.project.wollok.tests.typesystem.AbstractWollokTypeSystemTestCase
import org.xpect.expectation.IStringExpectation
import org.xpect.expectation.StringExpectation
import org.xpect.parameter.ParameterParser
import org.xpect.runner.LiveExecutionType
import org.xpect.runner.Xpect
import org.xpect.runner.XpectRunner
import org.xpect.runner.XpectSuiteClasses
import org.xpect.text.IRegion
import org.xpect.xtext.lib.tests.JvmModelInferrerTest
import org.xpect.xtext.lib.tests.LinkingTest
import org.xpect.xtext.lib.tests.ResourceDescriptionTest
import org.xpect.xtext.lib.tests.ScopingTest
import org.xpect.xtext.lib.tests.ValidationTest
import org.xpect.xtext.lib.tests.ValidationTestConfig
import org.xpect.xtext.lib.tests.ValidationTestModuleSetup.ConsumedIssues
import org.xpect.xtext.lib.tests.ValidationTestModuleSetup.IssuesByLine
import org.xpect.xtext.lib.util.NextLine

/**
 * Test class for extending XPECT to have tests on static proposals (content assist)
 * 
 * @author npasserini
 */
@SuppressWarnings("restriction")
@XpectSuiteClasses(#[
	JvmModelInferrerTest, //
	LinkingTest, //
	ResourceDescriptionTest, //
	ScopingTest, //
	ValidationTest
])
@RunWith(XpectRunner)
class TypeSystemXpectTestCase extends AbstractWollokTypeSystemTestCase {
	@Inject
	protected Provider<XtextResourceSet> resourceSetProvider
	@Inject
	protected Injector injector;

//	@Parameters(name="{index}: {0}")
//	static def Class<? extends TypeSystem>[] typeSystems() {
//		#[SubstitutionBasedTypeSystem]
//	}
//
//	@Xpect
	@ParameterParser(syntax="'at' node=OFFSET")
	@Xpect(liveExecution = LiveExecutionType.FAST)
	@ConsumedIssues(#[ Severity.INFO, Severity.ERROR, Severity.WARNING ])
	def void type( //
		@StringExpectation IStringExpectation expectation,
//	ILinesExpectation expectation, 
	@IssuesByLine Multimap<IRegion, Issue> line2issue, 
	@NextLine IRegion line, 
	ValidationTestConfig cfg
	
//		@ThisOffset ICrossEReferenceAndEObject arg1
//	@CommaSeparatedValuesExpectation ICommaSeparatedValuesExpectation expectation, //
//	int arg1, //
//	@ThisResource XtextResource resource, //
//	@ThisOffset int offset, //
//	@ThisModel EObject theModel
	) {
		expectation.assertEquals("() => String")
//		try {
//			setUp()
//		} catch (Exception e1) {
//			throw new RuntimeException("Error while setting up", e1)
//		}
//		var uri = URI.createURI(theModel.eResource.URI.toString, false)
//		if ("xt" == uri.fileExtension) {
//			uri = uri.trimFileExtension
//		}
//		val modelString = resource.serializer.serialize(theModel)
//		var ICompletionProposal[] proposals = null
//		try {
//			proposals = newBuilder(uri).append(
//				modelString.replace("org.example.spec.MySpec", "org.example.spec.MySpec")).
//				computeCompletionProposals(arg1)
//		} catch (Exception e) {
//			throw new RuntimeException("Error while computing proposals", e)
//		}
//		val actualProposals = new ArrayList<String>()
//		for (ICompletionProposal iCompletionProposal : proposals) {
//			if (iCompletionProposal instanceof ConfigurableCompletionProposal) {
//				actualProposals.add((iCompletionProposal as ConfigurableCompletionProposal).replacementString)
//			} else {
//				actualProposals.add(iCompletionProposal.getDisplayString());
//			}
//		}
//
//		expectation.assertEquals(actualProposals)
	}
//
//	def protected ContentAssistProcessorTestBuilder newBuilder(URI uri) throws Exception {
//		return new ContentAssistProcessorTestBuilder(this.injector, new ResourceLoadHelper() {
//			override getResourceFor(InputStream stream) {
//				try {
//					val XtextResourceSet set = WollokContentAssistTest.this.resourceSetProvider.get
//					val Resource result = set.createResource(uri)
//					result.load(stream, null)
//					result as XtextResource
//				} catch (Throwable e) {
//					throw Exceptions.sneakyThrow(e)
//				}
//			}
//		});
//	}
//	
}
