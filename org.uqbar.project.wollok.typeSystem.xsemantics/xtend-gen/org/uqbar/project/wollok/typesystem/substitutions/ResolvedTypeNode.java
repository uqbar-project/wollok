package org.uqbar.project.wollok.typesystem.substitutions;

import com.google.common.base.Objects;
import org.eclipse.emf.ecore.EObject;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.substitutions.CheckTypeRule;
import org.uqbar.project.wollok.typesystem.substitutions.EqualityNode;
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem;

/**
 * Already solved model's type.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class ResolvedTypeNode extends EqualityNode {
  private WollokType type;
  
  public ResolvedTypeNode(final EObject model, final WollokType type) {
    super(model);
    this.type = type;
  }
  
  public boolean tryToResolve(final SubstitutionBasedTypeSystem system, final CheckTypeRule rule) {
    return false;
  }
  
  public boolean isNonTerminalFor(final Object obj) {
    return false;
  }
  
  public WollokType getType() {
    return this.type;
  }
  
  public String toString() {
    return this.type.getName();
  }
  
  public boolean equals(final Object obj) {
    boolean _and = false;
    boolean _and_1 = false;
    if (!(obj instanceof ResolvedTypeNode)) {
      _and_1 = false;
    } else {
      EObject _model = this.getModel();
      EObject _model_1 = ((ResolvedTypeNode) obj).getModel();
      boolean _equals = Objects.equal(_model, _model_1);
      _and_1 = _equals;
    }
    if (!_and_1) {
      _and = false;
    } else {
      boolean _equals_1 = Objects.equal(this.type, ((ResolvedTypeNode) obj).type);
      _and = _equals_1;
    }
    return _and;
  }
  
  public int hashCode() {
    int _hashCode = super.hashCode();
    int _hashCode_1 = this.type.hashCode();
    return (_hashCode / _hashCode_1);
  }
}
