package org.uqbar.project.wollok.typesystem.substitutions;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend.lib.Property;
import org.eclipse.xtext.xbase.lib.Pure;
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
  @Property
  private EObject _model;
  
  public EqualityNode(final EObject object) {
    this.setModel(object);
  }
  
  public abstract boolean tryToResolve(final SubstitutionBasedTypeSystem system, final CheckTypeRule rule);
  
  public WollokType getType() {
    return null;
  }
  
  public abstract boolean isNonTerminalFor(final Object obj);
  
  public int hashCode() {
    EObject _model = this.getModel();
    return _model.hashCode();
  }
  
  @Pure
  public EObject getModel() {
    return this._model;
  }
  
  public void setModel(final EObject model) {
    this._model = model;
  }
}
