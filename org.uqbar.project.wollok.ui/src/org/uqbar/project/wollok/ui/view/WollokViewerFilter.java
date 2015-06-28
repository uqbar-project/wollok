package org.uqbar.project.wollok.ui.view;

import java.util.Arrays;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
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
 * @author jfernandes
 */
public class WollokViewerFilter extends ViewerFilter {
	private List<String> hiddenFiles = Arrays.asList("build.properties", "log4j.properties");
	private List<String> hiddenFolders = Arrays.asList("META-INF", "OSGI-INF");
	private List<Class> hiddenClasses = Arrays.<Class>asList(LibraryContainer.class, ClassPathContainer.class);
	
	@Override
	public boolean select(Viewer viewer, Object parentElement, Object element) {
		if (element instanceof IFile)
			return !hiddenFiles.contains(((IFile) element).getName());
		if (element instanceof IFolder)
			return !hiddenFolders.contains(((IFolder) element).getName());
		
		return !hiddenClasses.contains(element.getClass());
	}

}
