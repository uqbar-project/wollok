package org.uqbar.project.wollok.tests.proposals

import com.google.inject.Inject
import com.google.inject.Injector
import com.google.inject.Provider
import java.io.InputStream
import java.util.ArrayList
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.jface.text.contentassist.ICompletionProposal
import org.eclipse.xpect.expectation.CommaSeparatedValuesExpectation
import org.eclipse.xpect.expectation.ICommaSeparatedValuesExpectation
import org.eclipse.xpect.parameter.ParameterParser
import org.eclipse.xpect.runner.Xpect
import org.eclipse.xpect.runner.XpectRunner
import org.eclipse.xpect.xtext.lib.setup.ThisModel
import org.eclipse.xpect.xtext.lib.setup.ThisOffset
import org.eclipse.xpect.xtext.lib.setup.ThisResource
import org.eclipse.xtext.ISetup
import org.eclipse.xtext.junit4.ui.AbstractContentAssistProcessorTest
import org.eclipse.xtext.junit4.ui.ContentAssistProcessorTestBuilder
import org.eclipse.xtext.junit4.util.ResourceLoadHelper
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.junit.Ignore
import org.junit.runner.RunWith
import org.uqbar.project.wollok.ui.tests.WollokDslUiInjectorProvider

/**
 * Test class for extending X PECT to have tests on static proposals (content assist)
 * 
 * @author jfernandes
 */
@SuppressWarnings("restriction")
@RunWith(XpectRunner)
class WollokContentAssistTest extends AbstractContentAssistProcessorTest {
	@Inject
	protected Provider<XtextResourceSet> resourceSetProvider
	@Inject
	protected Injector injector;
	
	@Xpect
	@Ignore
	@ParameterParser(syntax = "'at' arg1=OFFSET")
	def void proposals( //
			@CommaSeparatedValuesExpectation ICommaSeparatedValuesExpectation expectation, //
			int arg1, @ThisResource XtextResource resource, @ThisOffset int offset, @ThisModel EObject theModel) {
		try {
			setUp()
		} catch (Exception e1) {
			throw new RuntimeException("Error while setting up", e1)
		}
		var uri = URI.createURI(theModel.eResource.URI.toString, false)
		if ("xt" == uri.fileExtension) {
			uri = uri.trimFileExtension
		}
		val modelString = resource.serializer.serialize(theModel)
		var ICompletionProposal[] proposals = null
		try {
			proposals = newBuilder(uri).append(modelString.replace("org.example.spec.MySpec", "org.example.spec.MySpec"))
					.computeCompletionProposals(arg1)
		} catch (Exception e) {
			throw new RuntimeException("Error while computing proposals", e)
		}
		val actualProposals = new ArrayList<String>()
		for (ICompletionProposal iCompletionProposal : proposals) {
			if (iCompletionProposal instanceof ConfigurableCompletionProposal) {
				actualProposals.add((iCompletionProposal as ConfigurableCompletionProposal).replacementString)
			} else {
				actualProposals.add(iCompletionProposal.getDisplayString());
			}
		}

		expectation.assertEquals(actualProposals)
	}
	
	def protected ContentAssistProcessorTestBuilder newBuilder(URI uri) throws Exception {
		return new ContentAssistProcessorTestBuilder(this.injector, new ResourceLoadHelper() {
			override getResourceFor(InputStream stream) {
				try {
					val XtextResourceSet set = WollokContentAssistTest.this.resourceSetProvider.get
					val Resource result = set.createResource(uri)
					result.load(stream, null)
					result as XtextResource
				} catch (Throwable e) {
					throw Exceptions.sneakyThrow(e)
				}
			}
		});
	}
	
	override protected doGetSetup() {
		return new ISetup() {
			override createInjectorAndDoEMFRegistration() {
				new WollokDslUiInjectorProvider().injector
			}

			def register(Injector injector) {
			}
		}
	}
	
}
