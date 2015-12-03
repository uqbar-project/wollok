package org.uqbar.project.wollok.typesystem.bindings;

import org.eclipse.xtend2.lib.StringConcatenation;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.TypeBound;
import org.uqbar.project.wollok.typesystem.bindings.TypedNode;

/**
 * type(from) == type(to)
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class ExactTypeBound extends TypeBound {
  public ExactTypeBound(final TypedNode from, final TypedNode to) {
    super(from, to);
  }
  
  public void fromTypeChanged(final WollokType newType) {
    final Object _function = new Object() {
    };
    this.propagate(_function);
  }
  
  public void toTypeChanged(final WollokType newType) {
    final Object _function = new Object() {
    };
    this.propagate(_function);
  }
  
  public String toString() {
    StringConcatenation _builder = new StringConcatenation();
    TypedNode _from = this.getFrom();
    _builder.append(_from, "");
    _builder.append(" == ");
    TypedNode _to = this.getTo();
    _builder.append(_to, "");
    return _builder.toString();
  }
}
