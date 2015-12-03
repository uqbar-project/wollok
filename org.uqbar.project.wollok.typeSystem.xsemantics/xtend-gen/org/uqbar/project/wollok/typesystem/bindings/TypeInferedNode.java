package org.uqbar.project.wollok.typesystem.bindings;

import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.BoundsBasedTypeSystem;
import org.uqbar.project.wollok.typesystem.bindings.TypedNode;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class TypeInferedNode extends TypedNode {
  private WollokType currentType;
  
  public TypeInferedNode(final /* EObject */Object object, final BoundsBasedTypeSystem s) {
    super(object, s);
  }
  
  public void assignType(final WollokType type) {
    this.currentType = type;
    this.fireTypeChanged();
  }
  
  public WollokType getType() {
    return this.currentType;
  }
  
  public String toString() {
    throw new Error("Unresolved compilation problems:"
      + "\n== cannot be resolved."
      + "\nclass cannot be resolved"
      + "\nsimpleName cannot be resolved");
  }
}
