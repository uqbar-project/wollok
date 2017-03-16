package org.uqbar.project.wollok.ui.view;

import java.util.Arrays;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.internal.ui.packageview.ClassPathContainer;
import org.eclipse.jdt.internal.ui.packageview.LibraryContainer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerFilter;

/**
 * Filters content to avoid showing java specific low-level files and elements like:
 * - Libraries (JDK)
 * - Classpath Elements
 * - properties files and OSGI related.
 * 
 * It is also hiding the empty project, needed to run the REPL without open project.
 * 
 * @author jfernandes
 * @author tesonep
 */
public class WollokViewerFilter extends ViewerFilter {
	private List<String> hiddenFiles = Arrays.asList("build.properties", "log4j.properties", "WOLLOK.ROOT");
	private List<String> hiddenFolders = Arrays.asList("META-INF", "OSGI-INF");
	private List<String> hiddenProjects = Arrays.asList("__EMPTY__");
	private List<Class<?>> hiddenClasses = Arrays.<Class<?>>asList(LibraryContainer.class, ClassPathContainer.class);
	
	@Override
	public boolean select(Viewer viewer, Object parentElement, Object element) {
		if (element instanceof IFile)
			return !hiddenFiles.contains(((IFile) element).getName());
		if (element instanceof IFolder)
			return !hiddenFolders.contains(((IFolder) element).getName());
		if (element instanceof IProject)
			return !hiddenProjects.contains(((IProject) element).getName());
		if (element instanceof IJavaProject)
			return !hiddenProjects.contains(((IJavaProject) element).getElementName());

		
		return !hiddenClasses.contains(element.getClass());
	}

}
