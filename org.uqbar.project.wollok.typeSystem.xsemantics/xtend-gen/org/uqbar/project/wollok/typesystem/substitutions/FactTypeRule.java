package org.uqbar.project.wollok.typesystem.substitutions;

import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem;
import org.uqbar.project.wollok.typesystem.substitutions.TypeRule;

/**
 * A terminal rule.
 * A rule which is already types/defined from startup.
 * For example a literal.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class FactTypeRule extends TypeRule {
  /* @Property
   */private /* EObject */Object model;
  
  /* @Property
   */private WollokType type;
  
  public FactTypeRule(final /* EObject */Object source, final /* EObject */Object obj, final WollokType type) {
    super(source);
    this.model = obj;
    this.type = type;
  }
  
  public boolean resolve(final SubstitutionBasedTypeSystem system) {
    return false;
  }
  
  public WollokType typeOf(final /* EObject */Object object) {
    throw new Error("Unresolved compilation problems:"
      + "\n== cannot be resolved");
  }
  
  public String toString() {
    throw new Error("Unresolved compilation problems:"
      + "\n+ cannot be resolved."
      + "\nsourceCode cannot be resolved"
      + "\ntrim cannot be resolved"
      + "\nreplaceAll cannot be resolved"
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
      + "\n&& cannot be resolved."
      + "\n== cannot be resolved."
      + "\n== cannot be resolved"
      + "\n&& cannot be resolved");
  }
  
  public int hashCode() {
    throw new Error("Unresolved compilation problems:"
      + "\nhashCode cannot be resolved"
      + "\n/ cannot be resolved");
  }
}
