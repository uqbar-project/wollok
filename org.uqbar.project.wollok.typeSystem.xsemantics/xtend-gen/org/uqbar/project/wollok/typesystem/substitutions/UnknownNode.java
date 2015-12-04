package org.uqbar.project.wollok.typesystem.substitutions;

import com.google.common.base.Objects;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.substitutions.CheckTypeRule;
import org.uqbar.project.wollok.typesystem.substitutions.EqualityNode;
import org.uqbar.project.wollok.typesystem.substitutions.ResolvedTypeNode;
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem;
import org.uqbar.project.wollok.utils.XTextExtensions;

/**
 * An unknown model's type.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class UnknownNode extends EqualityNode {
  public UnknownNode(final EObject object) {
    super(object);
  }
  
  public boolean tryToResolve(final SubstitutionBasedTypeSystem system, final CheckTypeRule rule) {
    boolean _xblockexpression = false;
    {
      EObject _model = this.getModel();
      final WollokType type = system.typeForExcept(_model, rule);
      boolean _xifexpression = false;
      boolean _notEquals = (!Objects.equal(type, null));
      if (_notEquals) {
        boolean _xblockexpression_1 = false;
        {
          EObject _model_1 = this.getModel();
          ResolvedTypeNode _resolvedTypeNode = new ResolvedTypeNode(_model_1, type);
          rule.changeNode(this, _resolvedTypeNode);
          _xblockexpression_1 = true;
        }
        _xifexpression = _xblockexpression_1;
      } else {
        _xifexpression = false;
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  public boolean isNonTerminalFor(final Object obj) {
    EObject _model = this.getModel();
    return Objects.equal(_model, obj);
  }
  
  public String toString() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("t(");
    EObject _model = this.getModel();
    String _sourceCode = XTextExtensions.sourceCode(_model);
    String _trim = _sourceCode.trim();
    _builder.append(_trim, "");
    _builder.append(")");
    return _builder.toString();
  }
  
  public boolean equals(final Object obj) {
    boolean _and = false;
    if (!(obj instanceof UnknownNode)) {
      _and = false;
    } else {
      EObject _model = this.getModel();
      EObject _model_1 = ((UnknownNode) obj).getModel();
      boolean _equals = Objects.equal(_model, _model_1);
      _and = _equals;
    }
    return _and;
  }
}
