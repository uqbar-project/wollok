package org.uqbar.project.wollok.semantics.validation;

import com.google.inject.Inject;
import it.xsemantics.runtime.validation.XsemanticsValidatorErrorGenerator;
import org.uqbar.project.wollok.semantics.WollokDslTypeSystem;
import org.uqbar.project.wollok.validation.AbstractWollokDslValidator;

@SuppressWarnings("all")
public class WollokDslTypeSystemValidator extends AbstractWollokDslValidator {
  @Inject
  protected XsemanticsValidatorErrorGenerator errorGenerator;
  
  @Inject
  protected WollokDslTypeSystem xsemanticsSystem;
  
  protected WollokDslTypeSystem getXsemanticsSystem() {
    return this.xsemanticsSystem;
  }
}
