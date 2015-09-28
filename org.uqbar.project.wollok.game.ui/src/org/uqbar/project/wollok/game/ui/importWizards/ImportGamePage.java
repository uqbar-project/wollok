package org.uqbar.project.wollok.game.ui.importWizards;

import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.KeyEvent;
import org.eclipse.swt.events.KeyListener;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.FileDialog;

public class ImportGamePage extends WizardPage {
	
	 private Text text1;
	  private Composite container;

	  public ImportGamePage() {
	    super("Import Wollok Game");
	    setTitle("Import Wollok Game");
	    setDescription("Import Wizard: Import settings from Wollok Game");
	  }

	  @Override
	  public void createControl(Composite parent) {
		  
	    container = new Composite(parent, SWT.NONE);
	    GridLayout layout = new GridLayout();
	    layout.numColumns = 3;
	    container.setLayout(layout);
	    
	    Label label1 = new Label(container, SWT.NONE);
	    label1.setText("Select a File.");

	    text1 = new Text(container, SWT.BORDER | SWT.SINGLE);
	    text1.setText("");
	    text1.setEditable(false);
	    text1.addKeyListener(new KeyListener() {
			
			@Override
			public void keyReleased(KeyEvent arg0) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void keyPressed(KeyEvent arg0) {
		        if (!text1.getText().isEmpty()) {
		          setPageComplete(true);

		        }				
			}
		});

	    final Shell shell = this.getShell();
	    shell.setText("Browse Wollok Game pack");	    
	    Button button = new Button(container, SWT.PUSH);
	    button.setText("Browse files...");
	    button.addSelectionListener(new SelectionAdapter() {
	      public void widgetSelected(SelectionEvent event) {
	    	  FileDialog dlg = new FileDialog(shell, SWT.OPEN);

	        // Set the initial filter path according
	        // to anything they've selected or typed in
	        dlg.setFilterPath("*.zip");

	        // Change the title bar text
	        dlg.setText("Search Wollok Game pack file ");

	        
	        // Calling open() will open and run the dialog.
	        // It will return the selected directory, or
	        // null if user cancels
	        String dir = dlg.open();
	        if (dir != null) {
	          // Set the text box to the new selection
	          text1.setText(dir);
	          setPageComplete(true);
	        }
	      }
	    });	    
	    GridData gd = new GridData(GridData.FILL_HORIZONTAL);
	    text1.setLayoutData(gd);
	    
	    // required to avoid an error in the system
	    setControl(container);
	    setPageComplete(false);

	  }

	  public String getText1() {
	    return text1.getText();
	  }

}
