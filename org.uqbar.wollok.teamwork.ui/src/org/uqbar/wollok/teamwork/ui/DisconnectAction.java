package org.uqbar.wollok.teamwork.ui;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.team.core.RepositoryProvider;
import org.eclipse.team.core.TeamException;
import org.eclipse.ui.IActionDelegate;

public class DisconnectAction  implements IActionDelegate{

	private IProject project;


	@Override
	public void run(IAction arg0) {
		if(project == null) {
			throw new RuntimeException("You cannot disconnect a non project object");
		}
		try {
			RepositoryProvider.unmap(project);
		} catch (TeamException e) {
			throw new RuntimeException("I cant unmap the project from repository", e);
		}
	}

	@Override
	public void selectionChanged(IAction arg0, ISelection currentSelection) {
		if (currentSelection instanceof StructuredSelection) {

			Object firstElement = ((StructuredSelection) currentSelection)
					.getFirstElement();
			if (firstElement instanceof IAdaptable) {
				project = (IProject) ((IAdaptable) firstElement)
						.getAdapter(IProject.class);
				
			} 
		}
		
	}

}
