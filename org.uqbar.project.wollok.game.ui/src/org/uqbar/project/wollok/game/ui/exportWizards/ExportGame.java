package org.uqbar.project.wollok.game.ui.exportWizards;

import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchWizard;

public class ExportGame extends Wizard implements IWorkbenchWizard{
	
	protected ExportGamePage one;
	
	  public ExportGame() {
		    super();
		    setNeedsProgressMonitor(true);
		  }

		  @Override
		  public String getWindowTitle() {
		    return "Export Wollok Game";
		  }

		  @Override
		  public void addPages() {
		    one = new ExportGamePage();
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
