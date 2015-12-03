package org.uqbar.project.wollok.typesystem.substitutions;

import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.substitutions.CheckTypeRule;
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem;

/**
 * Model wrapper.
 * Kind of a "state" pattern for each side of an EqualsTypeRule.
 * Because the rule tries to solve types then sometimes a rule starts
 * as an unknown type and then gets resolved based on another rule.
 * Example
 * 
 * 		t(a) == t(b)      	>     UnknownType(a) == UnknownType(b)
 * 
 * 	Plus other rule:   "var a = 23" = Int, then:
 * 
 * 		Int == t(b)			>		Fact(a = Int) == UnknownType(b)
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public abstract class EqualityNode {
  /* @Property
   */private /* EObject */Object model;
  
  public EqualityNode(final /* EObject */Object object) {
    this.model = object;
  }
  
  public abstract boolean tryToResolve(final SubstitutionBasedTypeSystem system, final CheckTypeRule rule);
  
  public WollokType getType() {
    return null;
  }
  
  public abstract boolean isNonTerminalFor(final Object obj);
  
  public int hashCode() {
    throw new Error("Unresolved compilation problems:"
      + "\nhashCode cannot be resolved");
  }
}
