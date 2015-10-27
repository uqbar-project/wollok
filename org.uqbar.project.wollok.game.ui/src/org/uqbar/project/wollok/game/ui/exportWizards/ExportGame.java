package org.uqbar.project.wollok.game.ui.exportWizards;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FilenameFilter;
import java.io.IOException;

import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchWizard;
import org.uqbar.project.wollok.game.ui.commons.ZipHandler;

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
		
		ZipHandler compressor = new ZipHandler();
		
		// WLK & WPGM Files
		File f = new File(compressor.getProjectPath() + "/src");
		File[] matchingFiles = f.listFiles(new FilenameFilter() {
			public boolean accept(File dir, String name) {
				return name.endsWith("wlk") || name.endsWith("wpgm");
			}
		});
		for (int i = 0; i < matchingFiles.length; i++)
			compressor.addFileToZip(matchingFiles[i]);

		// JSON
		f = new File(compressor.getProjectPath());
		matchingFiles = f.listFiles(new FilenameFilter() {
			public boolean accept(File dir, String name) {
				return name.endsWith("json");
			}
		});
		for (int i = 0; i < matchingFiles.length; i++)
			compressor.addFileToZip(matchingFiles[i]);
		
		//PNG
		f = new File(compressor.getProjectPath()+ "/assets");
		matchingFiles = f.listFiles(new FilenameFilter() {
			public boolean accept(File dir, String name) {
				return name.endsWith("png");
			}
		});
		for (int i = 0; i < matchingFiles.length; i++)
			compressor.addFileToZip(matchingFiles[i]);			
		
		try {
			compressor.makeZipFile(one.getText1());
		} catch (FileNotFoundException e) {
			one.setErrorMessage(e.getMessage());
			return false;
		} catch (IOException e) {
			one.setErrorMessage(e.getMessage());
			return false;
		}
		return true;
	}

	@Override
	public void init(IWorkbench arg0, IStructuredSelection arg1) {
		// TODO Auto-generated method stub

	}



}
