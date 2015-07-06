package org.uqbar.project.wollok.typesystem.substitutions;

import com.google.common.base.Objects;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.uqbar.project.wollok.semantics.TypeSystemException;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;
import org.uqbar.project.wollok.typesystem.substitutions.EqualityNode;
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem;
import org.uqbar.project.wollok.typesystem.substitutions.TypeCheck;
import org.uqbar.project.wollok.typesystem.substitutions.TypeRule;
import org.uqbar.project.wollok.typesystem.substitutions.UnknownNode;
import org.uqbar.project.wollok.utils.XTextExtensions;

/**
 * t(a) = t(b)
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class CheckTypeRule extends TypeRule {
  private EqualityNode a;
  
  private EqualityNode b;
  
  private TypeCheck check;
  
  public CheckTypeRule(final EObject source, final EObject a, final TypeCheck check, final EObject b) {
    super(source);
    UnknownNode _unknownNode = new UnknownNode(a);
    this.a = _unknownNode;
    this.check = check;
    UnknownNode _unknownNode_1 = new UnknownNode(b);
    this.b = _unknownNode_1;
  }
  
  public boolean resolve(final SubstitutionBasedTypeSystem system) {
    boolean _xblockexpression = false;
    {
      final boolean aR = this.a.tryToResolve(system, this);
      final boolean bR = this.b.tryToResolve(system, this);
      boolean _or = false;
      if (aR) {
        _or = true;
      } else {
        _or = bR;
      }
      _xblockexpression = _or;
    }
    return _xblockexpression;
  }
  
  public WollokType typeOf(final EObject object) {
    WollokType _xifexpression = null;
    boolean _isNonTerminalFor = this.a.isNonTerminalFor(object);
    if (_isNonTerminalFor) {
      _xifexpression = this.b.getType();
    } else {
      WollokType _xifexpression_1 = null;
      boolean _isNonTerminalFor_1 = this.b.isNonTerminalFor(object);
      if (_isNonTerminalFor_1) {
        _xifexpression_1 = this.a.getType();
      } else {
        _xifexpression_1 = null;
      }
      _xifexpression = _xifexpression_1;
    }
    return _xifexpression;
  }
  
  public void check() {
    try {
      boolean _and = false;
      WollokType _type = this.a.getType();
      boolean _notEquals = (!Objects.equal(_type, null));
      if (!_notEquals) {
        _and = false;
      } else {
        WollokType _type_1 = this.b.getType();
        boolean _notEquals_1 = (!Objects.equal(_type_1, null));
        _and = _notEquals_1;
      }
      if (_and) {
        WollokType _type_2 = this.a.getType();
        WollokType _type_3 = this.b.getType();
        this.check.check(_type_2, _type_3);
      }
    } catch (final Throwable _t) {
      if (_t instanceof TypeExpectationFailedException) {
        final TypeExpectationFailedException e = (TypeExpectationFailedException)_t;
        e.setModel(this.source);
        throw e;
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
  
  public EqualityNode changeNode(final EqualityNode node, final EqualityNode newNode) {
    EqualityNode _xifexpression = null;
    boolean _equals = Objects.equal(this.a, node);
    if (_equals) {
      _xifexpression = this.a = newNode;
    } else {
      EqualityNode _xifexpression_1 = null;
      boolean _equals_1 = Objects.equal(this.b, node);
      if (_equals_1) {
        _xifexpression_1 = this.b = newNode;
      } else {
        throw new TypeSystemException("Cannot substitute unknown node!");
      }
      _xifexpression = _xifexpression_1;
    }
    return _xifexpression;
  }
  
  public String toString() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(this.a, "");
    _builder.append(" ");
    String _operandString = this.check.getOperandString();
    _builder.append(_operandString, "");
    _builder.append(" ");
    _builder.append(this.b, "");
    _builder.append(" ");
    String _plus = (_builder.toString() + "\t\t\t\t(");
    int _lineNumber = XTextExtensions.lineNumber(this.source);
    String _plus_1 = (_plus + Integer.valueOf(_lineNumber));
    String _plus_2 = (_plus_1 + ": ");
    String _sourceCode = XTextExtensions.sourceCode(this.source);
    String _trim = _sourceCode.trim();
    String _replaceAll = _trim.replaceAll("\n", " ");
    String _plus_3 = (_plus_2 + _replaceAll);
    return (_plus_3 + ")");
  }
  
  public boolean equals(final Object obj) {
    boolean _xifexpression = false;
    if ((obj instanceof CheckTypeRule)) {
      boolean _and = false;
      boolean _equals = Objects.equal(this.a, ((CheckTypeRule)obj).a);
      if (!_equals) {
        _and = false;
      } else {
        boolean _equals_1 = Objects.equal(this.b, ((CheckTypeRule)obj).b);
        _and = _equals_1;
      }
      _xifexpression = _and;
    } else {
      _xifexpression = false;
    }
    return _xifexpression;
  }
  
  public int hashCode() {
    int _hashCode = this.a.hashCode();
    int _hashCode_1 = this.b.hashCode();
    return (_hashCode / _hashCode_1);
  }
}
