package org.uqbar.project.wollok.ui.properties;

import static org.uqbar.project.wollok.ui.properties.WollokLibrariesStore.saveLibs;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.eclipse.core.resources.IProject;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.viewers.ArrayContentProvider;
import org.eclipse.jface.viewers.ColumnLabelProvider;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.TableViewer;
import org.eclipse.jface.viewers.TableViewerColumn;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.layout.RowLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.FileDialog;
import org.eclipse.swt.widgets.Table;
import org.eclipse.ui.IWorkbenchPropertyPage;
import org.eclipse.ui.dialogs.PropertyPage;


@SuppressWarnings("all")
public class WollokProjectPropertyPage extends PropertyPage implements IWorkbenchPropertyPage {

	private TableViewer viewer;
	//this list is initialized on loadLibraries method
	private List<String> libraries;

	@Override
	public IPreferenceStore doGetPreferenceStore() {
		return WollokLibrariesStore.getProjectPreference(this.getProject());
	}

	public IProject getProject() {
		return this.getElement().<IProject>getAdapter(IProject.class);
	}

	@Override
	protected Control createContents(final Composite parent) {
		Composite composite = new Composite(parent, SWT.NONE);
		GridLayout layout = new GridLayout(1, true);
		composite.setLayout(layout);
		composite.setLayoutData(new GridData(SWT.FILL, SWT.BEGINNING, true, false));

		createTable(composite);
		createButtons(composite);
		
		return composite;
	}

	private void createButtons(Composite composite) {
		Composite buttons = new Composite(composite, SWT.NONE);
		RowLayout layout2 = new RowLayout();
		buttons.setLayout(layout2);
				
		createAddButton(buttons);
		createRemoveButton(buttons);
	}
	
	protected void createRemoveButton(Composite composite) {
		Button b = new Button(composite, SWT.NONE);
		b.setText("remove");
		b.addSelectionListener(new SelectionListener() {
			
			@Override
			public void widgetSelected(SelectionEvent arg0) {
				IStructuredSelection selection = (IStructuredSelection) viewer.getSelection();
				Iterator iter = selection.iterator();
				while( iter.hasNext()) {
					libraries.remove(iter.next());
				}
				viewer.refresh();
			}
			
			@Override
			public void widgetDefaultSelected(SelectionEvent arg0) {
				// TODO Auto-generated method stub
				
			}
		});
	}

	protected void createAddButton(Composite composite) {
		Button b = new Button(composite, SWT.NONE);
		b.setText("add");
		b.addSelectionListener(new SelectionListener() {

			@Override
			public void widgetSelected(SelectionEvent arg0) {

				FileDialog fd = new FileDialog(composite.getShell(), SWT.OPEN);
		        fd.setText("Find Wollok Lobraries");
		        String[] filterExt = { "*.jar"};
		        fd.setFilterExtensions(filterExt);
		        fd.setFilterPath(projectPath());
		        String fileSelected = fd.open();
		        if(fileSelected != null) {
			        fileSelected = removeProject(fileSelected);
					getLibs().add(fileSelected);
					viewer.refresh();
		        }
			}

			@Override
			public void widgetDefaultSelected(SelectionEvent arg0) {
				// TODO Auto-generated method stub

			}
		});
		;
	}
	
	private String projectPath() {
		return getProject().getLocation().toOSString();
	}
	
	private String removeProject(String absolutePath) {
		if (absolutePath.startsWith(projectPath())) { 
			String out = absolutePath.substring(projectPath().length());
			return out.startsWith("/") ? out.substring(1) : out;
		}
		return absolutePath;
	}

	private void createTable(Composite composite) {

		viewer = new TableViewer(composite, SWT.MULTI ^ SWT.H_SCROLL | SWT.V_SCROLL | SWT.FULL_SELECTION | SWT.BORDER);
		viewer.setContentProvider(ArrayContentProvider.getInstance());
		this.loadLibs();
		viewer.setInput(getLibs());

		createColumns(viewer);

		// make lines and header visible
		Table table = viewer.getTable();
		table.setHeaderVisible(true);
		table.setLinesVisible(true);

		GridData layoutData = new GridData(SWT.FILL, SWT.FILL, true, true, 1, 1);
		layoutData.minimumWidth = 300;
		layoutData.minimumHeight = 500;
		table.setLayoutData(layoutData);
		
		viewer.refresh();
	}

	protected void createColumns(TableViewer viewer) {
		// create a column for the first name
		TableViewerColumn colName = new TableViewerColumn(viewer, SWT.NONE);
		colName.getColumn().setWidth(200);
		colName.getColumn().setText("Name");
		colName.setLabelProvider(new ColumnLabelProvider() {
			@Override
			public String getText(Object element) {
				String[] parts = ((String) element).split("/");
				return parts[parts.length - 1];
			}
		});

		TableViewerColumn colPath = new TableViewerColumn(viewer, SWT.NONE);
		colPath.getColumn().setWidth(800);
		colPath.getColumn().setText("Path");
		colPath.setLabelProvider(new ColumnLabelProvider() {
			@Override
			public String getText(Object element) {
				return (String) element;
			}
		});

	}

	public boolean performOk() {
		saveLibs(getPreferenceStore(), libraries);
		return super.performOk();
	}

	
	protected void loadLibs() {
		libraries = new ArrayList<String>(WollokLibrariesStore.loadLibs(getPreferenceStore()));
	}

	public List<String> getLibs() {
		return libraries;
	}

	
	public void performDefaults() {
		libraries.clear();
		viewer.refresh();
		super.performDefaults();
	}

}
