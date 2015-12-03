package org.uqbar.project.wollok.typesystem.bindings;

import org.uqbar.project.wollok.typesystem.bindings.BoundsBasedTypeSystem;
import org.uqbar.project.wollok.typesystem.bindings.TypedNode;

/**
 * Extension provider to add all expectations to a TypedNode
 * while keeping the interface as DSL methods (operator overloading)
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class ExpectationBuilder {
  private BoundsBasedTypeSystem t;
  
  private TypedNode node;
  
  public ExpectationBuilder(final BoundsBasedTypeSystem system, final TypedNode node) {
    this.t = system;
    this.node = node;
  }
  
  public void operator_greaterEqualsThan(final /* EObject */Object o1, final /* EObject */Object o2) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method bindAsSuperTypeOf is undefined for the type ExpectationBuilder"
      + "\nnode cannot be resolved"
      + "\nnode cannot be resolved");
  }
}
