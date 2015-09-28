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

import java.io.IOException;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jdt.core.JavaModelException;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchWizard;
import org.uqbar.project.wollok.game.ui.commons.ZipHandler;

public class ImportGame extends Wizard implements IWorkbenchWizard {

	protected ImportGamePage one;

	public ImportGame() {
		super();
		setNeedsProgressMonitor(true);
	}

	@Override
	public String getWindowTitle() {
		return "Import Wollok Game";
	}

	@Override
	public void addPages() {
		one = new ImportGamePage();
		addPage(one);
	}

	@Override
	public boolean performFinish() {
		// System.out.println(one.getText1());
		ZipHandler compressor = new ZipHandler();
		try {
				compressor.extractFromZipFile(one.getText1(),
						compressor.getProjectPath());
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (JavaModelException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (CoreException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return true;
	}

	@Override
	public void init(IWorkbench arg0, IStructuredSelection arg1) {
		// TODO Auto-generated method stub

	}

}
