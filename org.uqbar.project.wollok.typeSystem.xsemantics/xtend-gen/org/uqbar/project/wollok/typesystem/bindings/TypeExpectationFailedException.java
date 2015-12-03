package org.uqbar.project.wollok.typesystem.bindings;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class TypeExpectationFailedException extends RuntimeException {
  /**
   * The semantic model (ast) which had this issue
   */
  /* @Property
   */private /* EObject */Object model;
  
  public TypeExpectationFailedException(final String message) {
    super(message);
  }
  
  public TypeExpectationFailedException(final /* EObject */Object m, final String message) {
    super(message);
    this.model = m;
  }
}
