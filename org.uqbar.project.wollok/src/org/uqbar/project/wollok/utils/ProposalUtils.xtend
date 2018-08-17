package org.uqbar.project.wollok.utils

import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.uqbar.project.wollok.wollokDsl.WClass

import static extension org.uqbar.project.wollok.utils.ReflectionExtensions.*

class ProposalUtils {

	def static className(ConfigurableCompletionProposal proposal) {
		val class = proposal.getFieldValue("additionalProposalInfo")
		class.className(proposal)
	}
	
	// Dirty alternative way: parsing "Cuenta - example.Cuenta"
	def static dispatch className(Object o, ConfigurableCompletionProposal proposal) {
		try {
			return proposal.displayString.split(" - ").get(0)
		} catch (Exception e) {
			// we don't want an error to be thrown in the middle of autocomplete process
			return ""
		}
	}
	
	def static dispatch className(WClass c, ConfigurableCompletionProposal proposal) {
		return c.name
	}

}
