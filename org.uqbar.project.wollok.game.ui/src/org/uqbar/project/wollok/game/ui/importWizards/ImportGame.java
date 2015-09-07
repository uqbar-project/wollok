/*******************************************************************************
 * Copyright (c) 2006 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
package org.uqbar.project.wollok.game.ui.importWizards;

import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchWizard;

public class ImportGame extends Wizard implements IWorkbenchWizard{
	
	  protected ImportGamePage one;

	  public ImportGame() {
	    super();
	    setNeedsProgressMonitor(true);
	  }

	  @Override
	  public String getWindowTitle() {
	    return "EImport Wollok Game";
	  }

	  @Override
	  public void addPages() {
	    one = new ImportGamePage();
	    addPage(one);
	  }

	  @Override
	  public boolean performFinish() {
	    // Print the result to the console
	    System.out.println(one.getText1());
	    return true;
	  }

	@Override
	public void init(IWorkbench arg0, IStructuredSelection arg1) {
		// TODO Auto-generated method stub
		
	}

}
