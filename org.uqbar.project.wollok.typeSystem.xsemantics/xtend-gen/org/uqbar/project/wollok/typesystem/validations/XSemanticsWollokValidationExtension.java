package org.uqbar.project.wollok.typesystem.validations;

import com.google.inject.Inject;
import it.xsemantics.runtime.Result;
import it.xsemantics.runtime.RuleEnvironment;
import it.xsemantics.runtime.validation.XsemanticsValidatorErrorGenerator;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.AssertionFailedException;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess;
import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.uqbar.project.wollok.model.WollokModelExtensions;
import org.uqbar.project.wollok.semantics.WollokDslTypeSystem;
import org.uqbar.project.wollok.validation.DecoratedValidationMessageAcceptor;
import org.uqbar.project.wollok.validation.WollokDslValidator;
import org.uqbar.project.wollok.validation.WollokValidatorExtension;
import org.uqbar.project.wollok.wollokDsl.WFile;
import org.uqbar.project.wollok.wollokDsl.WProgram;

/**
 * @author jfernandes
 * @author tesonep
 */
@SuppressWarnings("all")
public class XSemanticsWollokValidationExtension extends WollokDslTypeSystem implements WollokValidatorExtension {
  @Inject
  private IPreferenceStoreAccess preferenceStoreAccess;
  
  @Inject
  private XsemanticsValidatorErrorGenerator errorGenerator;
  
  public final static String TYPE_SYSTEM_CHECKS_ENABLED = "TYPE_SYSTEM_CHECKS_ENABLED";
  
  public void check(final WFile file, final WollokDslValidator validator) {
    try {
      IPreferenceStore _preferences = this.preferences(file);
      boolean _boolean = _preferences.getBoolean(XSemanticsWollokValidationExtension.TYPE_SYSTEM_CHECKS_ENABLED);
      boolean _not = (!_boolean);
      if (_not) {
        return;
      }
    } catch (final Throwable _t) {
      if (_t instanceof IllegalStateException) {
        final IllegalStateException e = (IllegalStateException)_t;
        return;
      } else if (_t instanceof AssertionFailedException) {
        final AssertionFailedException e_1 = (AssertionFailedException)_t;
        return;
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
    RuleEnvironment env = this.emptyEnvironment();
    DecoratedValidationMessageAcceptor _decorateErrorAcceptor = this.decorateErrorAcceptor(validator, WollokDslValidator.TYPE_SYSTEM_ERROR);
    WProgram _main = file.getMain();
    Result<Boolean> _inferTypes = this.inferTypes(env, _main);
    WProgram _main_1 = file.getMain();
    this.errorGenerator.generateErrors(_decorateErrorAcceptor, _inferTypes, _main_1);
  }
  
  public IPreferenceStore preferences(final EObject obj) {
    IFile _iFile = WollokModelExtensions.getIFile(obj);
    IProject _project = _iFile.getProject();
    return this.preferenceStoreAccess.getContextPreferenceStore(_project);
  }
  
  public DecoratedValidationMessageAcceptor decorateErrorAcceptor(final ValidationMessageAcceptor a, final String defaultCode) {
    return new DecoratedValidationMessageAcceptor(a, defaultCode);
  }
}
