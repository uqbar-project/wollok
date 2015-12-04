package org.uqbar.project.wollok.typesystem.bindings;

import com.google.common.base.Objects;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.BoundsBasedTypeSystem;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;
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
  
  public ValueTypedNode(final EObject object, final WollokType type, final BoundsBasedTypeSystem s) {
    super(object, s);
    this.fixedType = type;
  }
  
  public WollokType getType() {
    return this.fixedType;
  }
  
  public void assignType(final WollokType type) {
    boolean _notEquals = (!Objects.equal(type, this.fixedType));
    if (_notEquals) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("Expected <<");
      _builder.append(this.fixedType, "");
      _builder.append(">> but found <<");
      _builder.append(type, "");
      _builder.append(">>");
      throw new TypeExpectationFailedException(_builder.toString());
    }
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
