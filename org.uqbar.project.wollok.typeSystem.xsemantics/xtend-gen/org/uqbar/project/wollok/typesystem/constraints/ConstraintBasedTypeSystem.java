package org.uqbar.project.wollok.typesystem.constraints;

import com.google.common.base.Objects;
import java.util.Arrays;
import java.util.Collections;
import java.util.Map;
import java.util.function.Consumer;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.TypeSystem;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;
import org.uqbar.project.wollok.typesystem.constraints.TypeVariable;
import org.uqbar.project.wollok.typesystem.constraints.TypeVariablesFactory;
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral;
import org.uqbar.project.wollok.wollokDsl.WExpression;
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral;
import org.uqbar.project.wollok.wollokDsl.WProgram;
import org.uqbar.project.wollok.wollokDsl.WStringLiteral;

/**
 * @author npasserini
 */
@SuppressWarnings("all")
public class ConstraintBasedTypeSystem implements TypeSystem {
  private final Map<EObject, TypeVariable> typeVariables = CollectionLiterals.<EObject, TypeVariable>newHashMap();
  
  public void analyse(final EObject p) {
    EList<EObject> _eContents = p.eContents();
    final Consumer<EObject> _function = new Consumer<EObject>() {
      public void accept(final EObject it) {
        ConstraintBasedTypeSystem.this.generateVariables(it);
      }
    };
    _eContents.forEach(_function);
  }
  
  protected void _generateVariables(final WProgram p) {
    EList<WExpression> _elements = p.getElements();
    final Consumer<WExpression> _function = new Consumer<WExpression>() {
      public void accept(final WExpression it) {
        ConstraintBasedTypeSystem.this.generateVariables(it);
      }
    };
    _elements.forEach(_function);
  }
  
  protected void _generateVariables(final EObject node) {
    InputOutput.<EObject>println(node);
  }
  
  protected void _generateVariables(final WNumberLiteral num) {
    TypeVariable _sealed = TypeVariablesFactory.sealed(WollokType.WInt);
    this.typeVariables.put(num, _sealed);
  }
  
  protected void _generateVariables(final WStringLiteral string) {
    TypeVariable _sealed = TypeVariablesFactory.sealed(WollokType.WString);
    this.typeVariables.put(string, _sealed);
  }
  
  protected void _generateVariables(final WBooleanLiteral bool) {
    TypeVariable _sealed = TypeVariablesFactory.sealed(WollokType.WBoolean);
    this.typeVariables.put(bool, _sealed);
  }
  
  public void inferTypes() {
  }
  
  public WollokType type(final EObject obj) {
    WollokType _xblockexpression = null;
    {
      final TypeVariable typeVar = this.typeVariables.get(obj);
      boolean _equals = Objects.equal(typeVar, null);
      if (_equals) {
        throw new RuntimeException(("I don\'t have type information for " + obj));
      }
      _xblockexpression = typeVar.type();
    }
    return _xblockexpression;
  }
  
  public Iterable<TypeExpectationFailedException> issues(final EObject obj) {
    return Collections.<TypeExpectationFailedException>unmodifiableList(CollectionLiterals.<TypeExpectationFailedException>newArrayList());
  }
  
  public void generateVariables(final EObject bool) {
    if (bool instanceof WBooleanLiteral) {
      _generateVariables((WBooleanLiteral)bool);
      return;
    } else if (bool instanceof WNumberLiteral) {
      _generateVariables((WNumberLiteral)bool);
      return;
    } else if (bool instanceof WStringLiteral) {
      _generateVariables((WStringLiteral)bool);
      return;
    } else if (bool instanceof WProgram) {
      _generateVariables((WProgram)bool);
      return;
    } else if (bool != null) {
      _generateVariables(bool);
      return;
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(bool).toString());
    }
  }
}
