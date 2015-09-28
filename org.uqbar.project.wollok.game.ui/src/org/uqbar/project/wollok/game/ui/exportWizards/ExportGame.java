package org.uqbar.project.wollok.game.ui.exportWizards;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FilenameFilter;
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
		// Print the result to the console
		// System.out.println(one.getText1());
		
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
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
//		try {
//			FileOutputStream fos = new FileOutputStream(one.getText1());
//			ZipOutputStream zos = new ZipOutputStream(fos);
//
//			// WLK Files
//			String workingDir = ResourcesPlugin.getWorkspace().getRoot().findMember(this.getProjectPath()).getLocation().toString(); //.getLocation().toString() + this.getProjectPath(); 
//			File f = new File(workingDir + "/src");
//			File[] matchingFiles = f.listFiles(new FilenameFilter() {
//				public boolean accept(File dir, String name) {
//					return name.endsWith("wlk") || name.endsWith("wpgm");
//				}
//			});
//			for (int i = 0; i < matchingFiles.length; i++)
//				addToZipFile("src",  matchingFiles[i], zos);
//			// JSON
//			f = new File(workingDir);
//			matchingFiles = f.listFiles(new FilenameFilter() {
//				public boolean accept(File dir, String name) {
//					return name.endsWith("json");
//				}
//			});
//			for (int i = 0; i < matchingFiles.length; i++)
//				addToZipFile("",  matchingFiles[i], zos);
//			
//			//PNG
//			f = new File(workingDir+ "/assets");
//			matchingFiles = f.listFiles(new FilenameFilter() {
//				public boolean accept(File dir, String name) {
//					return name.endsWith("png");
//				}
//			});
//			for (int i = 0; i < matchingFiles.length; i++)
//				addToZipFile("assets",  matchingFiles[i], zos);			
//			
//			
//			zos.close();
//			fos.close();
//
//		} catch (FileNotFoundException e) {
//			e.printStackTrace();
//		} catch (IOException e) {
//			e.printStackTrace();
//		}
		return true;
	}

	@Override
	public void init(IWorkbench arg0, IStructuredSelection arg1) {
		// TODO Auto-generated method stub

	}



}
