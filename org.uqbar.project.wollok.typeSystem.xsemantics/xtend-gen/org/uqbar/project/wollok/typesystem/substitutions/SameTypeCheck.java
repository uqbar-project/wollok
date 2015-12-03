package org.uqbar.project.wollok.typesystem.substitutions;

import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.substitutions.TypeCheck;

/**
 * Checks that two types are the same.
 * 		a == b
 * @author jfernandes
 */
@SuppressWarnings("all")
public class SameTypeCheck implements TypeCheck {
  public void check(final WollokType a, final WollokType b) {
    throw new Error("Unresolved compilation problems:"
      + "\n!= cannot be resolved.");
  }
  
  public String getOperandString() {
    return "==";
  }
}
