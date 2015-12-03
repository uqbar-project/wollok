package org.uqbar.project.wollok.typesystem.bindings;

import java.util.List;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.BoundsBasedTypeSystem;
import org.uqbar.project.wollok.typesystem.bindings.ExactTypeExpectation;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectation;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;
import org.uqbar.project.wollok.typesystem.bindings.TypingListener;

/**
 * An AST node complemented with typing information.
 * There are two different nodes:
 *  those that already come from the AST with type information (FixedTypeNode)
 *  and those that don't and therefore should be inferred.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public abstract class TypedNode {
  private List<TypingListener> listeners /* Skipped initializer because of errors */;
  
  protected /* EObject */Object model;
  
  private BoundsBasedTypeSystem system;
  
  private List<TypeExpectation> expectations /* Skipped initializer because of errors */;
  
  public TypedNode(final /* EObject */Object object, final BoundsBasedTypeSystem typeSystem) {
    this.model = object;
    this.system = typeSystem;
  }
  
  public void inferTypes() {
  }
  
  public void assignType(final WollokType type) {
  }
  
  public abstract WollokType getType();
  
  public EObject getModel() {
    return this.model;
  }
  
  private List<TypeExpectationFailedException> errors /* Skipped initializer because of errors */;
  
  public Object issues() {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method fold is undefined for the type TypedNode"
      + "\nThe method or field newArrayList is undefined for the type TypedNode"
      + "\nThe method setModel is undefined for the type TypedNode"
      + "\ncheck cannot be resolved"
      + "\n+= cannot be resolved"
      + "\n+ cannot be resolved");
  }
  
  public Object addError(final TypeExpectationFailedException e) {
    throw new Error("Unresolved compilation problems:"
      + "\n+= cannot be resolved.");
  }
  
  public void addExpectation(final TypeExpectation expectation) {
    throw new Error("Unresolved compilation problems:"
      + "\n+= cannot be resolved.");
  }
  
  public void expectType(final WollokType type) {
    ExactTypeExpectation _exactTypeExpectation = new ExactTypeExpectation(type);
    this.addExpectation(_exactTypeExpectation);
  }
  
  public void addListener(final TypingListener listener) {
    throw new Error("Unresolved compilation problems:"
      + "\n+= cannot be resolved.");
  }
  
  public void removeListener(final TypingListener listener) {
    throw new Error("Unresolved compilation problems:"
      + "\n-= cannot be resolved.");
  }
  
  public Object fireTypeChanged() {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method forEach is undefined for the type TypedNode"
      + "\nThe method notifyTypeSet is undefined for the type TypedNode"
      + "\nThe method clone() is not visible");
  }
}
