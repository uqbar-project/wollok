package org.uqbar.project.wollok.typesystem.bindings;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.xbase.lib.Extension;
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
  @Extension
  private BoundsBasedTypeSystem t;
  
  private TypedNode node;
  
  public ExpectationBuilder(final BoundsBasedTypeSystem system, final TypedNode node) {
    this.t = system;
    this.node = node;
  }
  
  public void operator_greaterEqualsThan(final EObject o1, final EObject o2) {
    TypedNode _node = this.t.getNode(o1);
    TypedNode _node_1 = this.t.getNode(o2);
    this.t.bindAsSuperTypeOf(this.node, _node, _node_1);
  }
}
