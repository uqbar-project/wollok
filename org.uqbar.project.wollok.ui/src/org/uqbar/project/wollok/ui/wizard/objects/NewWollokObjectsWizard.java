package org.uqbar.project.wollok.ui.wizard.objects;

import java.io.ByteArrayInputStream;
import java.io.InputStream;

import org.eclipse.ui.INewWizard;
import org.uqbar.project.wollok.WollokConstants;
import org.uqbar.project.wollok.ui.wizard.abstractWizards.AbstractNewWollokFileWizard;

/**
 * New Wollok Objects and Classes Wizard
 * 
 * @author tesonep
 */
public class NewWollokObjectsWizard extends AbstractNewWollokFileWizard implements INewWizard {
	public static final String ID = "org.uqbar.project.wollok.ui.wizard.objects.NewWollokObjectsWizard";
	public static final int TYPE_OBJECT = 0;
	public static final int TYPE_CLASS = 1;
	
	public void addPages() {
		page = new NewWollokObjectsWizardPage(selection);
		addPage(page);
	}
	
	@Override
	protected InputStream openContentStream() {
		String contents =
			System.lineSeparator() + 
			getType() + " " + adjustCase(getObjectName()) + " {" + 
					System.lineSeparator() + 
					System.lineSeparator() + 
					System.lineSeparator() + 
					System.lineSeparator() + 
			"}";
		return new ByteArrayInputStream(contents.getBytes());
	}

	private String adjustCase(String objectName) {
		if (getTypeIndex() == TYPE_OBJECT) {
			return ("" + objectName.charAt(0)).toLowerCase()  + objectName.substring(1);
		} else {
			return ("" + objectName.charAt(0)).toUpperCase()  + objectName.substring(1);
		}
	}

	private String getObjectName() {
		String objectName = ((NewWollokObjectsWizardPage) page).getElementName(); 
		if (objectName == null || objectName.trim().equals("")) return "abc"; else return objectName;
	}
	
	private String getType() {
		if (getTypeIndex() == TYPE_OBJECT) { 
			return WollokConstants.WKO;
		} else {
			return WollokConstants.CLASS;
		}
	}

	private int getTypeIndex() {
		return ((NewWollokObjectsWizardPage) page).getElementIndex();
	}
}