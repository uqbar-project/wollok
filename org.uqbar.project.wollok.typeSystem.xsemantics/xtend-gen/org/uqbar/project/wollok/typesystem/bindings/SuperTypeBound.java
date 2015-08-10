package org.uqbar.project.wollok.typesystem.bindings;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.TypeBound;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;
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
    final Procedure1<Object> _function = new Procedure1<Object>() {
      public void apply(final Object it) {
        try {
          TypedNode _from = SuperTypeBound.this.getFrom();
          _from.assignType(newType);
        } catch (final Throwable _t) {
          if (_t instanceof TypeExpectationFailedException) {
            final TypeExpectationFailedException e = (TypeExpectationFailedException)_t;
            EObject _model = SuperTypeBound.this.bindSource.getModel();
            e.setModel(_model);
            SuperTypeBound.this.bindSource.addError(e);
          } else {
            throw Exceptions.sneakyThrow(_t);
          }
        }
      }
    };
    this.propagate(_function);
  }
  
  public void fromTypeChanged(final WollokType newType) {
    final Procedure1<Object> _function = new Procedure1<Object>() {
      public void apply(final Object it) {
        try {
          TypedNode _to = SuperTypeBound.this.getTo();
          _to.assignType(newType);
        } catch (final Throwable _t) {
          if (_t instanceof TypeExpectationFailedException) {
            final TypeExpectationFailedException e = (TypeExpectationFailedException)_t;
            EObject _model = SuperTypeBound.this.bindSource.getModel();
            e.setModel(_model);
            SuperTypeBound.this.bindSource.addError(e);
          } else {
            throw Exceptions.sneakyThrow(_t);
          }
        }
      }
    };
    this.propagate(_function);
  }
  
  public String toString() {
    StringConcatenation _builder = new StringConcatenation();
    TypedNode _from = this.getFrom();
    _builder.append(_from, "");
    _builder.append(" extends ");
    TypedNode _to = this.getTo();
    _builder.append(_to, "");
    return _builder.toString();
  }
}
