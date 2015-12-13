package org.uqbar.project.wollok.product.ui.startup;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtension;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.internal.dialogs.WorkbenchWizardElement;
import org.eclipse.ui.internal.wizards.AbstractExtensionWizardRegistry;
import org.eclipse.ui.wizards.IWizardCategory;
import org.eclipse.ui.wizards.IWizardDescriptor;
import org.eclipse.ui.wizards.IWizardRegistry;
import org.eclipse.xtext.xbase.lib.CollectionExtensions;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.uqbar.project.wollok.ui.WollokUIStartup;

/**
 * Programmatically hacks eclipse workbench to
 * remove unwanted wizards that will confuse users/students.
 * 
 * TODO: maybe we can have this configurable as a preference ?
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class RemoveWizardsStartup implements WollokUIStartup {
  @Override
  public void startup() {
    this.removeEclipseFeatures();
  }
  
  public void removeEclipseFeatures() {
    InputOutput.<String>println(">>>>> Removing Eclipse FEATURES FROM STARTUP!");
    IWorkbench _workbench = PlatformUI.getWorkbench();
    IWizardRegistry _newWizardRegistry = _workbench.getNewWizardRegistry();
    final AbstractExtensionWizardRegistry wizardRegistry = ((AbstractExtensionWizardRegistry) _newWizardRegistry);
    IWorkbench _workbench_1 = PlatformUI.getWorkbench();
    IWizardRegistry _newWizardRegistry_1 = _workbench_1.getNewWizardRegistry();
    IWizardCategory _rootCategory = _newWizardRegistry_1.getRootCategory();
    final IWizardCategory[] categories = _rootCategory.getCategories();
    List<IWizardDescriptor> _allWizards = this.getAllWizards(categories);
    for (final IWizardDescriptor wizard : _allWizards) {
      String _id = wizard.getId();
      boolean _includeWizards = this.includeWizards(_id);
      boolean _not = (!_includeWizards);
      if (_not) {
        final WorkbenchWizardElement wizardElement = ((WorkbenchWizardElement) wizard);
        String _id_1 = wizard.getId();
        String _plus = (">>>>> Removing wizard " + _id_1);
        InputOutput.<String>println(_plus);
        IConfigurationElement _configurationElement = wizardElement.getConfigurationElement();
        IExtension _declaringExtension = _configurationElement.getDeclaringExtension();
        wizardRegistry.removeExtension(_declaringExtension, new Object[] { wizardElement });
      }
    }
  }
  
  private final static List<String> includeWizards = Collections.<String>unmodifiableList(CollectionLiterals.<String>newArrayList("org\\.eclipse\\.ui\\..*", "org\\.uqbar\\.project\\.wollok\\..*"));
  
  public boolean includeWizards(final String id) {
    final Function1<String, Boolean> _function = (String it) -> {
      return Boolean.valueOf(id.matches(it));
    };
    return IterableExtensions.<String>exists(RemoveWizardsStartup.includeWizards, _function);
  }
  
  public List<IWizardDescriptor> getAllWizards(final IWizardCategory[] categories) {
    ArrayList<IWizardDescriptor> _xblockexpression = null;
    {
      final ArrayList<IWizardDescriptor> results = new ArrayList<IWizardDescriptor>();
      for (final IWizardCategory wizardCategory : categories) {
        {
          IWizardDescriptor[] _wizards = wizardCategory.getWizards();
          CollectionExtensions.<IWizardDescriptor>addAll(results, _wizards);
          IWizardCategory[] _categories = wizardCategory.getCategories();
          List<IWizardDescriptor> _allWizards = this.getAllWizards(_categories);
          results.addAll(_allWizards);
        }
      }
      _xblockexpression = results;
    }
    return _xblockexpression;
  }
}
