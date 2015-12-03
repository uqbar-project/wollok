package org.uqbar.project.wollok.typesystem.validations;

import org.uqbar.project.wollok.semantics.WollokDslTypeSystem;
import org.uqbar.project.wollok.validation.DecoratedValidationMessageAcceptor;
import org.uqbar.project.wollok.validation.WollokDslValidator;
import org.uqbar.project.wollok.validation.WollokValidatorExtension;
import org.uqbar.project.wollok.wollokDsl.WFile;

/**
 * @author jfernandes
 * @author tesonep
 */
@SuppressWarnings("all")
public class XSemanticsWollokValidationExtension extends WollokDslTypeSystem implements WollokValidatorExtension {
  /* @Inject
   */private /* IPreferenceStoreAccess */Object preferenceStoreAccess;
  
  /* @Inject
   */private /* XsemanticsValidatorErrorGenerator */Object errorGenerator;
  
  public final static String TYPE_SYSTEM_CHECKS_ENABLED = "TYPE_SYSTEM_CHECKS_ENABLED";
  
  public void check(final WFile file, final WollokDslValidator validator) {
    throw new Error("Unresolved compilation problems:"
      + "\nAssertionFailedException cannot be resolved to a type."
      + "\nRuleEnvironment cannot be resolved to a type."
      + "\nThe method emptyEnvironment is undefined for the type XSemanticsWollokValidationExtension"
      + "\nInvalid number of arguments. The method inferTypes(Object) is not applicable for the arguments (RuleEnvironment,WProgram)"
      + "\nUnreachable code: The catch block can never match. It is already handled by a previous condition."
      + "\ngetBoolean cannot be resolved"
      + "\n! cannot be resolved"
      + "\ngenerateErrors cannot be resolved");
  }
  
  public Object preferences(final /* EObject */Object obj) {
    throw new Error("Unresolved compilation problems:"
      + "\ngetContextPreferenceStore cannot be resolved"
      + "\nIFile cannot be resolved"
      + "\nproject cannot be resolved");
  }
  
  public DecoratedValidationMessageAcceptor decorateErrorAcceptor(final /* ValidationMessageAcceptor */Object a, final String defaultCode) {
    return new DecoratedValidationMessageAcceptor(a, defaultCode);
  }
}
