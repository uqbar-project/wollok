package org.uqbar.project.wollok.ui.wizard.abstractWizards;

import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.operation.IRunnableWithProgress;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.ide.IDE;

public abstract class AbstractNewWollokFileWizard extends Wizard {

	protected AbstractNewWollokFileWizardPage page;

	protected abstract InputStream openContentStream();

	protected IStructuredSelection selection;

	public AbstractNewWollokFileWizard() {
		setNeedsProgressMonitor(true);
	}
	
	public abstract void addPages();

	public boolean performFinish() {
		final String containerName = page.getContainerName();
		final String fileName = page.getFileName();
		IRunnableWithProgress op = new IRunnableWithProgress() {
			public void run(IProgressMonitor monitor) throws InvocationTargetException {
				try {
					doFinish(containerName, fileName, monitor);
				} catch (CoreException e) {
					throw new InvocationTargetException(e);
				} finally {
					monitor.done();
				}
			}
		};
		try {
			getContainer().run(true, false, op);
		} catch (InterruptedException e) {
			return false;
		} catch (InvocationTargetException e) {
			Throwable realException = e.getTargetException();
			MessageDialog.openError(getShell(), "Error", realException.getMessage());
			return false;
		}
		return true;
	}

	/**
	 * The worker method. It will find the container, create the
	 * file if missing or just replace its contents, and open
	 * the editor on the newly created file.
	 */
	private void doFinish(String containerName, String fileName, IProgressMonitor monitor)
			throws CoreException {
				// create a sample file
				monitor.beginTask("Creating " + fileName, 2);
				IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
				IResource resource = root.findMember(new Path(containerName));
				if (!resource.exists() || !(resource instanceof IContainer)) {
					throwCoreException("Container \"" + containerName + "\" does not exist.");
				}
				IContainer container = (IContainer) resource;
				final IFile file = container.getFile(new Path(fileName));
				try {
					InputStream stream = openContentStream();
					if (file.exists()) {
						file.setContents(stream, true, true, monitor);
					} else {
						file.create(stream, true, monitor);
					}
					stream.close();
				} catch (IOException e) {
				}
				monitor.worked(1);
				monitor.setTaskName("Opening file for editing...");
				getShell().getDisplay().asyncExec(new Runnable() {
					public void run() {
						IWorkbenchPage page =
							PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage();
						try {
							IDE.openEditor(page, file, true);
						} catch (PartInitException e) {
						}
					}
				});
				monitor.worked(1);
			}

	private void throwCoreException(String message) throws CoreException {
		IStatus status =
			new Status(IStatus.ERROR, "org.uqbar.project.wollok.ui", IStatus.OK, message, null);
		throw new CoreException(status);
	}

	public void init(IWorkbench workbench, IStructuredSelection selection) {
		this.selection = selection;
	}

}