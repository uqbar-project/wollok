package org.uqbar.project.wollok.typesystem.bindings;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend.lib.Property;
import org.eclipse.xtext.xbase.lib.Pure;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class TypeExpectationFailedException extends RuntimeException {
  /**
   * The semantic model (ast) which had this issue
   */
  @Property
  private EObject _model;
  
  public TypeExpectationFailedException(final String message) {
    super(message);
  }
  
  public TypeExpectationFailedException(final EObject m, final String message) {
    super(message);
    this.setModel(m);
  }
  
  @Pure
  public EObject getModel() {
    return this._model;
  }
  
  public void setModel(final EObject model) {
    this._model = model;
  }
}
