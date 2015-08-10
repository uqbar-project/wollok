package org.uqbar.project.wollok.typesystem.substitutions;

import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.substitutions.SameTypeCheck;
import org.uqbar.project.wollok.typesystem.substitutions.SuperTypeCheck;

/**
 * An object that checks a relation between two types.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public interface TypeCheck {
  public abstract void check(final WollokType a, final WollokType b);
  
  public final static SameTypeCheck SAME_AS = new SameTypeCheck();
  
  public final static SuperTypeCheck SUPER_OF = new SuperTypeCheck();
  
  public abstract String getOperandString();
}
