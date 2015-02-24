package org.uqbar.project.wollok.typeSystem.xsemantics.ui.preferences;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import com.google.inject.name.Named;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.jface.preference.IPreferencePageContainer;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.IWorkbenchPropertyPage;
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer;
import org.eclipse.xtext.Constants;
import org.eclipse.xtext.ui.XtextProjectHelper;
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess;
import org.eclipse.xtext.ui.preferences.IStatusChangeListener;
import org.eclipse.xtext.ui.preferences.PropertyAndPreferencePage;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.uqbar.project.wollok.typeSystem.xsemantics.ui.preferences.TypeSystemConfigurationBlock;
import org.uqbar.project.wollok.utils.WEclipseUtils;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class TypeSystemPreferencePage extends PropertyAndPreferencePage implements IWorkbenchPropertyPage {
  @Inject
  @Named(Constants.LANGUAGE_NAME)
  private String languageName;
  
  @Inject
  private IPreferenceStoreAccess preferenceStoreAccess;
  
  private TypeSystemConfigurationBlock builderConfigurationBlock;
  
  protected String getPreferencePageID() {
    return (this.languageName + "typeSystem.preferencePage");
  }
  
  protected String getPropertyPageID() {
    return (this.languageName + "typeSystem.propertyPage");
  }
  
  public void createControl(final Composite parent) {
    IPreferencePageContainer _container = this.getContainer();
    final IWorkbenchPreferenceContainer container = ((IWorkbenchPreferenceContainer) _container);
    IProject _project = this.getProject();
    final IPreferenceStore preferenceStore = this.preferenceStoreAccess.getWritablePreferenceStore(_project);
    IProject _project_1 = this.getProject();
    TypeSystemConfigurationBlock _typeSystemConfigurationBlock = new TypeSystemConfigurationBlock(_project_1, preferenceStore, container);
    this.builderConfigurationBlock = _typeSystemConfigurationBlock;
    IStatusChangeListener _newStatusChangedListener = this.getNewStatusChangedListener();
    this.builderConfigurationBlock.setStatusChangeListener(_newStatusChangedListener);
    super.createControl(parent);
  }
  
  protected Control createPreferenceContent(final Composite composite, final IPreferencePageContainer preferencePageContainer) {
    return this.builderConfigurationBlock.createContents(composite);
  }
  
  protected boolean hasProjectSpecificOptions(final IProject project) {
    return this.builderConfigurationBlock.hasProjectSpecificOptions(project);
  }
  
  public void dispose() {
    boolean _notEquals = (!Objects.equal(this.builderConfigurationBlock, null));
    if (_notEquals) {
      this.builderConfigurationBlock.dispose();
    }
    super.dispose();
  }
  
  public void enableProjectSpecificSettings(final boolean useProjectSpecificSettings) {
    super.enableProjectSpecificSettings(useProjectSpecificSettings);
    boolean _notEquals = (!Objects.equal(this.builderConfigurationBlock, null));
    if (_notEquals) {
      this.builderConfigurationBlock.useProjectSpecificSettings(useProjectSpecificSettings);
    }
  }
  
  public void performDefaults() {
    super.performDefaults();
    boolean _notEquals = (!Objects.equal(this.builderConfigurationBlock, null));
    if (_notEquals) {
      this.builderConfigurationBlock.performDefaults();
    }
  }
  
  public boolean performOk() {
    boolean _xblockexpression = false;
    {
      boolean _notEquals = (!Objects.equal(this.builderConfigurationBlock, null));
      if (_notEquals) {
        IPreferencePageContainer _container = this.getContainer();
        this.scheduleCleanerJobIfNecessary(_container);
        boolean _performOk = this.builderConfigurationBlock.performOk();
        boolean _not = (!_performOk);
        if (_not) {
          return false;
        }
      }
      _xblockexpression = super.performOk();
    }
    return _xblockexpression;
  }
  
  public void performApply() {
    boolean _notEquals = (!Objects.equal(this.builderConfigurationBlock, null));
    if (_notEquals) {
      this.scheduleCleanerJobIfNecessary(null);
      this.builderConfigurationBlock.performApply();
    }
  }
  
  public void scheduleCleanerJobIfNecessary(final IPreferencePageContainer preferencePageContainer) {
    IPreferencePageContainer _container = this.getContainer();
    final IWorkbenchPreferenceContainer c = ((IWorkbenchPreferenceContainer) _container);
    c.registerUpdateJob(new Job("Rebuilding project") {
      protected IStatus run(final IProgressMonitor monitor) {
        IStatus _xblockexpression = null;
        {
          TypeSystemPreferencePage.this.rebuild(monitor);
          _xblockexpression = Status.OK_STATUS;
        }
        return _xblockexpression;
      }
    });
  }
  
  protected void rebuild(final IProgressMonitor monitor) {
    boolean _isProjectPreferencePage = this.isProjectPreferencePage();
    if (_isProjectPreferencePage) {
      IProject _project = this.getProject();
      WEclipseUtils.fullBuild(_project, monitor);
    } else {
      IProject[] _allProjects = WEclipseUtils.allProjects();
      final Function1<IProject, Boolean> _function = new Function1<IProject, Boolean>() {
        public Boolean apply(final IProject p) {
          return Boolean.valueOf(XtextProjectHelper.hasNature(p));
        }
      };
      Iterable<IProject> _filter = IterableExtensions.<IProject>filter(((Iterable<IProject>)Conversions.doWrapArray(_allProjects)), _function);
      final Procedure1<IProject> _function_1 = new Procedure1<IProject>() {
        public void apply(final IProject p) {
          WEclipseUtils.fullBuild(p, monitor);
        }
      };
      IterableExtensions.<IProject>forEach(_filter, _function_1);
    }
  }
  
  public void setElement(final IAdaptable element) {
    super.setElement(element);
    this.setDescription(null);
  }
}
