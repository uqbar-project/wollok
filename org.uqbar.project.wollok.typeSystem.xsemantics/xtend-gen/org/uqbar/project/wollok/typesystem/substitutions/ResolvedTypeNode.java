package org.uqbar.project.wollok.typesystem.substitutions;

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
  
  public ResolvedTypeNode(final /* EObject */Object model, final WollokType type) {
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
    throw new Error("Unresolved compilation problems:"
      + "\n&& cannot be resolved."
      + "\n== cannot be resolved."
      + "\nThe field model is not visible"
      + "\nThe field model is not visible"
      + "\n== cannot be resolved"
      + "\n&& cannot be resolved");
  }
  
  public int hashCode() {
    throw new Error("Unresolved compilation problems:"
      + "\n/ cannot be resolved.");
  }
}
