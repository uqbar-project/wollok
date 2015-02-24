package org.uqbar.project.wollok.typeSystem.xsemantics.ui.preferences;

import java.util.List;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResourceRuleFactory;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.jobs.ISchedulingRule;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.jface.dialogs.IDialogSettings;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer;
import org.eclipse.xtext.ui.preferences.OptionsConfigurationBlock;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.uqbar.project.wollok.typeSystem.xsemantics.ui.preferences.WPreferencesUtils;
import org.uqbar.project.wollok.ui.WollokActivator;
import org.uqbar.project.wollok.validation.WollokDslValidator;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class TypeSystemConfigurationBlock extends OptionsConfigurationBlock {
  private final static String SETTINGS_SECTION_NAME = "TypeSystemConfigurationBlock";
  
  public TypeSystemConfigurationBlock(final IProject project, final IPreferenceStore store, final IWorkbenchPreferenceContainer container) {
    super(project, store, container);
    store.setDefault(WollokDslValidator.TYPE_SYSTEM_CHECKS_ENABLED, IPreferenceStore.TRUE);
  }
  
  public Control doCreateContents(final Composite parent) {
    Composite _composite = new Composite(parent, SWT.NONE);
    final Procedure1<Composite> _function = new Procedure1<Composite>() {
      public void apply(final Composite it) {
        GridLayout _gridLayout = new GridLayout();
        final Procedure1<GridLayout> _function = new Procedure1<GridLayout>() {
          public void apply(final GridLayout it) {
            it.marginHeight = 20;
            it.marginWidth = 8;
          }
        };
        GridLayout _doubleArrow = ObjectExtensions.<GridLayout>operator_doubleArrow(_gridLayout, _function);
        it.setLayout(_doubleArrow);
        List<String> _booleanPrefValues = WPreferencesUtils.booleanPrefValues();
        TypeSystemConfigurationBlock.this.addCheckBox(it, "Enable Type System Checks", WollokDslValidator.TYPE_SYSTEM_CHECKS_ENABLED, ((String[])Conversions.unwrapArray(_booleanPrefValues, String.class)), 0);
      }
    };
    return ObjectExtensions.<Composite>operator_doubleArrow(_composite, _function);
  }
  
  protected Job getBuildJob(final IProject project) {
    OptionsConfigurationBlock.BuildJob _buildJob = new OptionsConfigurationBlock.BuildJob("Saving Type system configuration", project);
    final Procedure1<OptionsConfigurationBlock.BuildJob> _function = new Procedure1<OptionsConfigurationBlock.BuildJob>() {
      public void apply(final OptionsConfigurationBlock.BuildJob it) {
        IWorkspace _workspace = ResourcesPlugin.getWorkspace();
        IResourceRuleFactory _ruleFactory = _workspace.getRuleFactory();
        ISchedulingRule _buildRule = _ruleFactory.buildRule();
        it.setRule(_buildRule);
        it.setUser(true);
      }
    };
    return ObjectExtensions.<OptionsConfigurationBlock.BuildJob>operator_doubleArrow(_buildJob, _function);
  }
  
  protected String[] getFullBuildDialogStrings(final boolean workspaceSettings) {
    String _xifexpression = null;
    if (workspaceSettings) {
      _xifexpression = "Apply changed workspace-wide ? All wollok projects will be rebuilt";
    } else {
      _xifexpression = "Apply changes for this project ? It will be rebuilt";
    }
    return new String[] { "TypeSystem settings", _xifexpression };
  }
  
  protected void validateSettings(final String changedKey, final String oldValue, final String newValue) {
  }
  
  public void dispose() {
    WollokActivator _instance = WollokActivator.getInstance();
    IDialogSettings _dialogSettings = _instance.getDialogSettings();
    IDialogSettings _addNewSection = _dialogSettings.addNewSection(TypeSystemConfigurationBlock.SETTINGS_SECTION_NAME);
    this.restoreSectionExpansionStates(_addNewSection);
    super.dispose();
  }
}
