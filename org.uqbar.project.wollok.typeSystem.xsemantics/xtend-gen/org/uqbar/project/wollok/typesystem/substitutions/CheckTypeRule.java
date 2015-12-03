package org.uqbar.project.wollok.typesystem.substitutions;

import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.substitutions.EqualityNode;
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem;
import org.uqbar.project.wollok.typesystem.substitutions.TypeCheck;
import org.uqbar.project.wollok.typesystem.substitutions.TypeRule;
import org.uqbar.project.wollok.typesystem.substitutions.UnknownNode;

/**
 * t(a) = t(b)
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class CheckTypeRule extends TypeRule {
  private EqualityNode a;
  
  private EqualityNode b;
  
  private TypeCheck check;
  
  public CheckTypeRule(final /* EObject */Object source, final /* EObject */Object a, final TypeCheck check, final /* EObject */Object b) {
    super(source);
    UnknownNode _unknownNode = new UnknownNode(a);
    this.a = _unknownNode;
    this.check = check;
    UnknownNode _unknownNode_1 = new UnknownNode(b);
    this.b = _unknownNode_1;
  }
  
  public boolean resolve(final SubstitutionBasedTypeSystem system) {
    throw new Error("Unresolved compilation problems:"
      + "\n|| cannot be resolved.");
  }
  
  public WollokType typeOf(final /* EObject */Object object) {
    WollokType _xifexpression = null;
    boolean _isNonTerminalFor = this.a.isNonTerminalFor(object);
    if (_isNonTerminalFor) {
      _xifexpression = this.b.getType();
    } else {
      WollokType _xifexpression_1 = null;
      boolean _isNonTerminalFor_1 = this.b.isNonTerminalFor(object);
      if (_isNonTerminalFor_1) {
        _xifexpression_1 = this.a.getType();
      } else {
        _xifexpression_1 = null;
      }
      _xifexpression = _xifexpression_1;
    }
    return _xifexpression;
  }
  
  public void check() {
    throw new Error("Unresolved compilation problems:"
      + "\n!= cannot be resolved."
      + "\n!= cannot be resolved."
      + "\nThe field model is not visible"
      + "\n&& cannot be resolved");
  }
  
  public EqualityNode changeNode(final EqualityNode node, final EqualityNode newNode) {
    throw new Error("Unresolved compilation problems:"
      + "\n== cannot be resolved."
      + "\n== cannot be resolved.");
  }
  
  public String toString() {
    throw new Error("Unresolved compilation problems:"
      + "\n+ cannot be resolved."
      + "\n+ cannot be resolved"
      + "\nlineNumber cannot be resolved"
      + "\n+ cannot be resolved"
      + "\n+ cannot be resolved"
      + "\nsourceCode cannot be resolved"
      + "\ntrim cannot be resolved"
      + "\nreplaceAll cannot be resolved"
      + "\n+ cannot be resolved");
  }
  
  public boolean equals(final Object obj) {
    throw new Error("Unresolved compilation problems:"
      + "\n== cannot be resolved."
      + "\n== cannot be resolved."
      + "\n&& cannot be resolved");
  }
  
  public int hashCode() {
    throw new Error("Unresolved compilation problems:"
      + "\n/ cannot be resolved.");
  }
}
