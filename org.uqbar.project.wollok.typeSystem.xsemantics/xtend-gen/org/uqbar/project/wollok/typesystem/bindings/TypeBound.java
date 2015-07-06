package org.uqbar.project.wollok.typesystem.bindings;

import com.google.common.base.Objects;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.TypedNode;
import org.uqbar.project.wollok.typesystem.bindings.TypingListener;

/**
 * Represents a type binding between two ast nodes.
 * 
 * Meaning that element types are related in some way.
 * The exact relation depends on the type of bound.
 * 
 * This objects allow to assemble a nodes graph relating
 * type information.
 * This allows to calculate types later.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public abstract class TypeBound {
  private final TypedNode from;
  
  private final TypedNode to;
  
  private boolean propagating;
  
  public TypeBound(final TypedNode from, final TypedNode to) {
    this.from = from;
    this.to = to;
    final TypingListener _function = new TypingListener() {
      public void notifyTypeSet(final WollokType newType) {
        TypeBound.this.fromTypeChanged(newType);
      }
    };
    from.addListener(_function);
    final TypingListener _function_1 = new TypingListener() {
      public void notifyTypeSet(final WollokType newType) {
        TypeBound.this.toTypeChanged(newType);
      }
    };
    to.addListener(_function_1);
  }
  
  public TypedNode getFrom() {
    return this.from;
  }
  
  public TypedNode getTo() {
    return this.to;
  }
  
  public void inferTypes() {
    this.from.inferTypes();
    this.to.inferTypes();
  }
  
  public void fromTypeChanged(final WollokType newType) {
  }
  
  public void toTypeChanged(final WollokType newType) {
  }
  
  protected boolean propagate(final Procedure1<? super Object> block) {
    boolean _xifexpression = false;
    if ((!this.propagating)) {
      boolean _xblockexpression = false;
      {
        this.propagating = true;
        block.apply(null);
        _xblockexpression = this.propagating = false;
      }
      _xifexpression = _xblockexpression;
    }
    return _xifexpression;
  }
  
  public boolean isFor(final TypedNode node) {
    boolean _or = false;
    boolean _equals = Objects.equal(node, this.from);
    if (_equals) {
      _or = true;
    } else {
      boolean _equals_1 = Objects.equal(node, this.to);
      _or = _equals_1;
    }
    return _or;
  }
}
