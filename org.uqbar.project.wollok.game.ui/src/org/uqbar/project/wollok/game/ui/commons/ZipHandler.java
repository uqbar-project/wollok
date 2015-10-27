package org.uqbar.project.wollok.game.ui.commons;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.core.runtime.IPath;
import org.eclipse.jdt.core.IClasspathEntry;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.IPackageFragmentRoot;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;

public class ZipHandler {
	List<File> fileList;

	public ZipHandler() {
		this.fileList = new ArrayList<File>();
	}

	public void addFileToZip(File aFile) {
		this.fileList.add(aFile);
	}

	public String getProjectPath() {
		return ResourcesPlugin.getWorkspace().getRoot()
				.findMember(this.getProjectName()).getLocation().toString();
	}

	public IPath getProjectIPath() {
		return ResourcesPlugin.getWorkspace().getRoot()
				.findMember(this.getProjectName()).getLocation();
	}

	public void makeZipFile(String fileOutput) throws FileNotFoundException,
			IOException {
		FileOutputStream fos = new FileOutputStream(fileOutput);
		ZipOutputStream zos = new ZipOutputStream(fos);
		for (int i = 0; i < fileList.size(); i++) {
			File fileToAdd = fileList.get(i);
			if (fileToAdd.getName().contains(".json"))
				addToZipFile("", fileToAdd, zos);
			else if (fileToAdd.getName().contains(".wlk")
					|| fileToAdd.getName().contains(".wpgm"))
				addToZipFile("src", fileToAdd, zos);
			else if (fileToAdd.getName().contains(".png"))
				addToZipFile("assets", fileToAdd, zos);
		}

		zos.close();
		fos.close();
	}

	private void addToZipFile(String folder, File aFile, ZipOutputStream zos)
			throws FileNotFoundException, IOException {

		System.out.println("Escribiendo '" + aFile.getName()
				+ "' al archivo zip");

		// System.out.println("\n Path " + aFile.getParentFile().getName());
		FileInputStream fis = new FileInputStream(aFile);
		ZipEntry zipEntry;
		if (folder != "")
			zipEntry = new ZipEntry(folder + "/" + aFile.getName());
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

	public void extractFromZipFile(String zipFilePath, String destDirectory)
			throws IOException, CoreException {
		File destDir = new File(destDirectory);
		if (!destDir.exists()) {
			destDir.mkdir();
		}
		new File(destDirectory + "/assets").mkdir();

		IJavaProject javaProject = JavaCore.create(ResourcesPlugin
				.getWorkspace().getRoot().findMember(this.getProjectName())
				.getProject());
		IProject project = ResourcesPlugin.getWorkspace().getRoot()
				.findMember(this.getProjectName()).getProject();
		IFolder sourceFolder = project.getFolder("assets");
		IPackageFragmentRoot root = javaProject
				.getPackageFragmentRoot(sourceFolder);
		IClasspathEntry[] oldEntries = javaProject.getRawClasspath();
		IClasspathEntry[] newEntries = new IClasspathEntry[oldEntries.length + 1];
		System.arraycopy(oldEntries, 0, newEntries, 0, oldEntries.length);
		newEntries[oldEntries.length] = JavaCore.newSourceEntry(root.getPath());
		javaProject.setRawClasspath(newEntries, null);

		ZipInputStream zipIn = new ZipInputStream(new FileInputStream(
				zipFilePath));
		ZipEntry entry = zipIn.getNextEntry();
		// iterates over entries in the zip file
		while (entry != null) {
			String filePath = destDirectory + File.separator + entry.getName();
			if (!entry.isDirectory()) {
				// if the entry is a file, extracts it
				extractFile(zipIn, filePath);
			} else {
				// if the entry is a directory, make the directory
				File dir = new File(filePath);
				dir.mkdir();
			}
			zipIn.closeEntry();
			entry = zipIn.getNextEntry();
		}
		zipIn.close();

		project.refreshLocal(IResource.DEPTH_INFINITE, null);
	}

	/**
	 * Extracts a zip entry (file entry)
	 * 
	 * @param zipIn
	 * @param filePath
	 * @throws IOException
	 */
	private void extractFile(ZipInputStream zipIn, String filePath)
			throws IOException {
		BufferedOutputStream bos = new BufferedOutputStream(
				new FileOutputStream(filePath));
		byte[] bytesIn = new byte[1024];
		int read = 0;
		while ((read = zipIn.read(bytesIn)) != -1) {
			bos.write(bytesIn, 0, read);
		}
		bos.close();
	}

	private IPath getProjectName() {
		IWorkbenchWindow window = PlatformUI.getWorkbench()
				.getActiveWorkbenchWindow();
		if (window != null) {
			IStructuredSelection selection = (IStructuredSelection) window
					.getSelectionService().getSelection();
			Object firstElement = selection.getFirstElement();
			if (firstElement instanceof IAdaptable) {
				IProject project = (IProject) ((IAdaptable) firstElement)
						.getAdapter(IProject.class);
				return project.getFullPath();
			}
		}
		return null;
	}

}
