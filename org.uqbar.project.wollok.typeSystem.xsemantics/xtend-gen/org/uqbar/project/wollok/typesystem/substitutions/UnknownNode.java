package org.uqbar.project.wollok.typesystem.substitutions;

import org.uqbar.project.wollok.typesystem.substitutions.CheckTypeRule;
import org.uqbar.project.wollok.typesystem.substitutions.EqualityNode;
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem;

/**
 * An unknown model's type.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class UnknownNode extends EqualityNode {
  public UnknownNode(final /* EObject */Object object) {
    super(object);
  }
  
  public boolean tryToResolve(final SubstitutionBasedTypeSystem system, final CheckTypeRule rule) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe field model is not visible"
      + "\nThe field model is not visible"
      + "\n!= cannot be resolved");
  }
  
  public boolean isNonTerminalFor(final Object obj) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe field model is not visible"
      + "\n== cannot be resolved");
  }
  
  public String toString() {
    throw new Error("Unresolved compilation problems:"
      + "\nThe field model is not visible"
      + "\nsourceCode cannot be resolved"
      + "\ntrim cannot be resolved");
  }
  
  public boolean equals(final Object obj) {
    throw new Error("Unresolved compilation problems:"
      + "\n&& cannot be resolved."
      + "\nThe field model is not visible"
      + "\nThe field model is not visible"
      + "\n== cannot be resolved");
  }
}
