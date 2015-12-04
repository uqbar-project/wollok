package org.uqbar.project.wollok.typesystem.bindings;

import com.google.common.base.Objects;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.BoundsBasedTypeSystem;
import org.uqbar.project.wollok.typesystem.bindings.TypedNode;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class TypeInferedNode extends TypedNode {
  private WollokType currentType;
  
  public TypeInferedNode(final EObject object, final BoundsBasedTypeSystem s) {
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
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("InferredType(");
    String _xifexpression = null;
    WollokType _type = this.getType();
    boolean _equals = Objects.equal(_type, null);
    if (_equals) {
      _xifexpression = "???";
    } else {
      WollokType _type_1 = this.getType();
      _xifexpression = _type_1.getName();
    }
    _builder.append(_xifexpression, "");
    _builder.append(" <- ");
    Class<? extends EObject> _class = this.model.getClass();
    String _simpleName = _class.getSimpleName();
    _builder.append(_simpleName, "");
    _builder.append(")");
    return _builder.toString();
  }
}
