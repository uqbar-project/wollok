package org.uqbar.project.wollok.ui.wizard.tests

import java.io.ByteArrayInputStream
import org.eclipse.ui.INewWizard
import org.uqbar.project.wollok.ui.wizard.abstractWizards.AbstractNewWollokFileWizard

/**
 * New Wollok Test & Suite Wizard
 * 
 * @author tesonep
 * @author dodain
 * 
 */
class NewWollokTestWizard extends AbstractNewWollokFileWizard implements INewWizard {
	public static final String ID = "org.uqbar.project.wollok.ui.wizard.tests.NewWollokTestWizard";
	
	override addPages() {
		page = getWizardPage
		addPage(page)
	}
	
	def NewWollokTestWizardPage getWizardPage() {
		new NewWollokTestWizardPage(selection)
	}
	
	override openContentStream() {
		val String contents = defaultContent
		return new ByteArrayInputStream(contents.bytes)
	}

	def defaultContent() {	defaultContent(0) }

	def newLine() { System.lineSeparator }
	
	def tab(int level) {
		if (level <= 0) return "" 
		(1..level).fold("", [ acum, i | acum + "\t" ])
	}
	
	def defaultContent(int indentLevel) {
		newLine + 
		tab(indentLevel) + "test \"testX\" {" +	newLine +
		newLine +
		tab(indentLevel) + "\tassert.that(true)" +	newLine +
		newLine +
		tab(indentLevel) + "}"
	}
}

class NewWollokDescribeWizard extends NewWollokTestWizard implements INewWizard {

	public static final String ID = "org.uqbar.project.wollok.ui.wizard.tests.NewWollokDescribeWizard"
	
	override getWizardPage() {
		new NewWollokDescribeWizardPage(selection)
	}
	
	override defaultContent() {
		newLine +
		"describe \"group of tests\" {" + newLine +
		this.defaultContent(1) +
		newLine +
		"}"
	}
	
}