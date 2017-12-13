package org.uqbar.project.wollok.semantics.validation;

import org.eclipse.xsemantics.runtime.validation.XsemanticsValidatorErrorGenerator;
import org.uqbar.project.wollok.semantics.WollokDslTypeSystem;
import org.uqbar.project.wollok.validation.AbstractWollokDslValidator;

import com.google.inject.Inject;

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
