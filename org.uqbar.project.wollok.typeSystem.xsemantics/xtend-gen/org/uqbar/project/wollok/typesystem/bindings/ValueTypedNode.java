package org.uqbar.project.wollok.typesystem.bindings;

import org.eclipse.xtend2.lib.StringConcatenation;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.BoundsBasedTypeSystem;
import org.uqbar.project.wollok.typesystem.bindings.TypedNode;

/**
 * A Typed node representing a "leaf" node.
 * That's an AST element which has a fixed type.
 * For example, a literal.
 * 
 * If the language supports explicit types then those would also be
 * ValueTypedNode.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class ValueTypedNode extends TypedNode {
  private WollokType fixedType;
  
  public ValueTypedNode(final /* EObject */Object object, final WollokType type, final BoundsBasedTypeSystem s) {
    super(object, s);
    this.fixedType = type;
  }
  
  public WollokType getType() {
    return this.fixedType;
  }
  
  public void assignType(final WollokType type) {
    throw new Error("Unresolved compilation problems:"
      + "\n!= cannot be resolved.");
  }
  
  public void inferTypes() {
    this.fireTypeChanged();
  }
  
  public String toString() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("FixedType(");
    String _name = this.fixedType.getName();
    _builder.append(_name, "");
    _builder.append(")");
    return _builder.toString();
  }
}
