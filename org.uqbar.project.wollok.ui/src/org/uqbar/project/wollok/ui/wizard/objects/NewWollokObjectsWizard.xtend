package org.uqbar.project.wollok.ui.wizard.objects

import java.io.ByteArrayInputStream
import java.util.List
import org.eclipse.ui.INewWizard
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.ui.wizard.abstractWizards.AbstractNewWollokFileWizard
import org.uqbar.project.wollok.ui.wizard.objects.NewWollokObjectsWizardPage

class NewWollokObjectsWizard extends AbstractNewWollokFileWizard implements INewWizard {
	
	public static final String ID = "org.uqbar.project.wollok.ui.wizard.objects.NewWollokObjectsWizard"

	val List<NameCaseStrategy> adjustCaseStrategy = #[new MinCase(), new UpCase(), new MinCase()]
	val List<String> types = #[WollokConstants.WKO, WollokConstants.CLASS, WollokConstants.MIXIN] 
		
	override addPages() {
		page = new NewWollokObjectsWizardPage(selection)
		addPage(page)
	}

	override protected openContentStream() {
		new ByteArrayInputStream('''
		«type» «objectName.adjustCase» {
			
			
		}
		'''.toString.bytes)
	}
	
	def getObjectName() {
		val objectName = objectPage.elementName 
		if (objectName === null || objectName.trim().equals("")) "abc" else objectName
	}
	
	def adjustCase(String objectName) {
		adjustCaseStrategy.get(typeIndex).adjustCase(objectName)
	}
	
	def type() {
		types.get(typeIndex)			
	}
	
	def getTypeIndex() {
		objectPage.elementIndex
	}
	
	def objectPage() {
		page as NewWollokObjectsWizardPage
	}
	
}

abstract class NameCaseStrategy {
	def String adjustCase(String name) {
		name.charAt(0).adjustInitialLetter + name.substring(1)
	}
	def String adjustInitialLetter(char initial)
}

class MinCase extends NameCaseStrategy {
	override adjustInitialLetter(char initial) {
		("" + initial).toLowerCase
	}
}

class UpCase extends NameCaseStrategy {
	override adjustInitialLetter(char initial) {
		("" + initial).toUpperCase
	}
}