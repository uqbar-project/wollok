package org.uqbar.project.wollok.typesystem.bindings;

import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectation;

/**
 * Expect the exact given type.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class ExactTypeExpectation implements TypeExpectation {
  private WollokType expectedType;
  
  public ExactTypeExpectation(final WollokType expected) {
    this.expectedType = expected;
  }
  
  public void check(final WollokType actualType) {
    throw new Error("Unresolved compilation problems:"
      + "\n!= cannot be resolved.");
  }
}
