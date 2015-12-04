package org.uqbar.project.wollok.typesystem.bindings;

import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
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
    final Procedure1<Object> _function = new Procedure1<Object>() {
      public void apply(final Object it) {
        TypedNode _to = ExactTypeBound.this.getTo();
        _to.assignType(newType);
      }
    };
    this.propagate(_function);
  }
  
  public void toTypeChanged(final WollokType newType) {
    final Procedure1<Object> _function = new Procedure1<Object>() {
      public void apply(final Object it) {
        TypedNode _from = ExactTypeBound.this.getFrom();
        _from.assignType(newType);
      }
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
