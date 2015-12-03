package org.uqbar.project.wollok.typesystem.substitutions;

import com.google.common.base.Objects;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend.lib.Property;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Pure;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem;
import org.uqbar.project.wollok.typesystem.substitutions.TypeRule;
import org.uqbar.project.wollok.utils.XTextExtensions;

/**
 * A terminal rule.
 * A rule which is already types/defined from startup.
 * For example a literal.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class FactTypeRule extends TypeRule {
  @Property
  private EObject _model;
  
  @Property
  private WollokType _type;
  
  public FactTypeRule(final EObject source, final EObject obj, final WollokType type) {
    super(source);
    this.setModel(obj);
    this.setType(type);
  }
  
  public boolean resolve(final SubstitutionBasedTypeSystem system) {
    return false;
  }
  
  public WollokType typeOf(final EObject object) {
    WollokType _xifexpression = null;
    EObject _model = this.getModel();
    boolean _equals = Objects.equal(object, _model);
    if (_equals) {
      _xifexpression = this.getType();
    } else {
      _xifexpression = null;
    }
    return _xifexpression;
  }
  
  public String toString() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("t(");
    EObject _model = this.getModel();
    String _sourceCode = XTextExtensions.sourceCode(_model);
    String _trim = _sourceCode.trim();
    String _replaceAll = _trim.replaceAll("\n", " ");
    _builder.append(_replaceAll, "");
    _builder.append(") = ");
    WollokType _type = this.getType();
    _builder.append(_type, "");
    String _plus = (_builder.toString() + "\t\t\t\t(");
    int _lineNumber = XTextExtensions.lineNumber(this.source);
    String _plus_1 = (_plus + Integer.valueOf(_lineNumber));
    String _plus_2 = (_plus_1 + ": ");
    String _sourceCode_1 = XTextExtensions.sourceCode(this.source);
    String _trim_1 = _sourceCode_1.trim();
    String _replaceAll_1 = _trim_1.replaceAll("\n", " ");
    String _plus_3 = (_plus_2 + _replaceAll_1);
    return (_plus_3 + ")");
  }
  
  public boolean equals(final Object obj) {
    boolean _and = false;
    boolean _and_1 = false;
    if (!(obj instanceof FactTypeRule)) {
      _and_1 = false;
    } else {
      EObject _model = this.getModel();
      EObject _model_1 = ((FactTypeRule) obj).getModel();
      boolean _equals = Objects.equal(_model, _model_1);
      _and_1 = _equals;
    }
    if (!_and_1) {
      _and = false;
    } else {
      WollokType _type = this.getType();
      WollokType _type_1 = ((FactTypeRule) obj).getType();
      boolean _equals_1 = Objects.equal(_type, _type_1);
      _and = _equals_1;
    }
    return _and;
  }
  
  public int hashCode() {
    EObject _model = this.getModel();
    int _hashCode = _model.hashCode();
    WollokType _type = this.getType();
    int _hashCode_1 = _type.hashCode();
    return (_hashCode / _hashCode_1);
  }
  
  @Pure
  public EObject getModel() {
    return this._model;
  }
  
  public void setModel(final EObject model) {
    this._model = model;
  }
  
  @Pure
  public WollokType getType() {
    return this._type;
  }
  
  public void setType(final WollokType type) {
    this._type = type;
  }
}
