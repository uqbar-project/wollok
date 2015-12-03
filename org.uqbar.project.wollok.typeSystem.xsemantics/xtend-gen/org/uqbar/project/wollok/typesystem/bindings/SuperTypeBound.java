package org.uqbar.project.wollok.typesystem.bindings;

import org.eclipse.xtend2.lib.StringConcatenation;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.TypeBound;
import org.uqbar.project.wollok.typesystem.bindings.TypedNode;

/**
 * The target node is the same or a super type of
 * the bounded node
 * 
 * type(from) >= type(to)
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class SuperTypeBound extends TypeBound {
  private TypedNode bindSource;
  
  public SuperTypeBound(final TypedNode from, final TypedNode to) {
    super(from, to);
  }
  
  public SuperTypeBound(final TypedNode bindSource, final TypedNode from, final TypedNode to) {
    super(from, to);
    this.bindSource = bindSource;
  }
  
  public void toTypeChanged(final WollokType newType) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe field model is not visible");
  }
  
  public void fromTypeChanged(final WollokType newType) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe field model is not visible");
  }
  
  public String toString() {
    StringConcatenation _builder = new StringConcatenation();
    TypedNode _from = this.getFrom();
    _builder.append(_from, "");
    _builder.append(" inherits ");
    TypedNode _to = this.getTo();
    _builder.append(_to, "");
    return _builder.toString();
  }
}
