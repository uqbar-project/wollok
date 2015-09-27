package org.uqbar.project.wollok.game.ui.exportWizards;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IPathVariableManager;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IProjectDescription;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceProxy;
import org.eclipse.core.resources.IResourceProxyVisitor;
import org.eclipse.core.resources.IResourceVisitor;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.ResourceAttributes;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.QualifiedName;
import org.eclipse.core.runtime.jobs.ISchedulingRule;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.IWorkbenchWizard;
import org.eclipse.ui.PlatformUI;

public class ExportGame extends Wizard implements IWorkbenchWizard {

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
		// System.out.println(one.getText1());
		try {
			FileOutputStream fos = new FileOutputStream(one.getText1());
			ZipOutputStream zos = new ZipOutputStream(fos);

			// WLK Files
			String workingDir = ResourcesPlugin.getWorkspace().getRoot().findMember(this.getProjectPath()).getLocation().toString(); //.getLocation().toString() + this.getProjectPath(); 
			File f = new File(workingDir + "/src");
			File[] matchingFiles = f.listFiles(new FilenameFilter() {
				public boolean accept(File dir, String name) {
					return name.endsWith("wlk") || name.endsWith("wpgm");
				}
			});
			for (int i = 0; i < matchingFiles.length; i++)
				addToZipFile("src",  matchingFiles[i], zos);
			// JSON
			f = new File(workingDir);
			matchingFiles = f.listFiles(new FilenameFilter() {
				public boolean accept(File dir, String name) {
					return name.endsWith("json");
				}
			});
			for (int i = 0; i < matchingFiles.length; i++)
				addToZipFile("",  matchingFiles[i], zos);
			
			//PNG
			f = new File(workingDir+ "/assets");
			matchingFiles = f.listFiles(new FilenameFilter() {
				public boolean accept(File dir, String name) {
					return name.endsWith("png");
				}
			});
			for (int i = 0; i < matchingFiles.length; i++)
				addToZipFile("assets",  matchingFiles[i], zos);			
			
			
			zos.close();
			fos.close();

		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return true;
	}

	@Override
	public void init(IWorkbench arg0, IStructuredSelection arg1) {
		// TODO Auto-generated method stub

	}

	public static void addToZipFile(String folder, File aFile, ZipOutputStream zos)
			throws FileNotFoundException, IOException {

		System.out.println("Escribiendo '" + aFile.getName() + "' al archivo zip");

		//System.out.println("\n Path " + aFile.getParentFile().getName());
		FileInputStream fis = new FileInputStream(aFile);
		ZipEntry zipEntry;
		if (folder != "")
			zipEntry = new ZipEntry(folder + "/" +aFile.getName());
		else
			zipEntry = new ZipEntry(aFile.getName());
		zos.putNextEntry(zipEntry);

		byte[] bytes = new byte[1024];
		int length;
		while ((length = fis.read(bytes)) >= 0) {
			zos.write(bytes, 0, length);
		}

		zos.closeEntry();
		fis.close();
	}

	private IPath getProjectPath() {
		IWorkbenchWindow window = PlatformUI.getWorkbench()
				.getActiveWorkbenchWindow();
		if (window != null) {
			IStructuredSelection selection = (IStructuredSelection) window
					.getSelectionService().getSelection();
			Object firstElement = selection.getFirstElement();
			if (firstElement instanceof IAdaptable) {
				IProject project = (IProject) ((IAdaptable) firstElement)
						.getAdapter(IProject.class);
				//IPath path = project.getFullPath();
				return project.getFullPath();
				//return path.toString();
			}
		}
		return null;
	}
}
