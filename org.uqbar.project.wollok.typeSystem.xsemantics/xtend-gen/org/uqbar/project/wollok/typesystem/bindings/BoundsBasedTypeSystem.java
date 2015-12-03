package org.uqbar.project.wollok.typesystem.bindings;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.TypeSystem;
import org.uqbar.project.wollok.typesystem.bindings.ExactTypeBound;
import org.uqbar.project.wollok.typesystem.bindings.SuperTypeBound;
import org.uqbar.project.wollok.typesystem.bindings.TypeBound;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;
import org.uqbar.project.wollok.typesystem.bindings.TypedNode;
import org.uqbar.project.wollok.wollokDsl.WAssignment;
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation;
import org.uqbar.project.wollok.wollokDsl.WBlockExpression;
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral;
import org.uqbar.project.wollok.wollokDsl.WClass;
import org.uqbar.project.wollok.wollokDsl.WIfExpression;
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall;
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration;
import org.uqbar.project.wollok.wollokDsl.WNullLiteral;
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral;
import org.uqbar.project.wollok.wollokDsl.WParameter;
import org.uqbar.project.wollok.wollokDsl.WProgram;
import org.uqbar.project.wollok.wollokDsl.WReferenciable;
import org.uqbar.project.wollok.wollokDsl.WStringLiteral;
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration;
import org.uqbar.project.wollok.wollokDsl.WVariableReference;

/**
 * An attempt to avoid directly manipulating xsemantics environment
 * map.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class BoundsBasedTypeSystem implements TypeSystem {
  private /* Map<EObject, TypedNode> */Object nodes /* Skipped initializer because of errors */;
  
  private List<TypeBound> bounds /* Skipped initializer because of errors */;
  
  public Object fixedNode(final WollokType fixedType, final /* EObject */Object obj) {
    throw new Error("Unresolved compilation problems:"
      + "\n=> cannot be resolved.");
  }
  
  public Object fixedNode(final WollokType fixedType, final /* EObject */Object obj, final /*  */Object expectationsBuilder) {
    throw new Error("Unresolved compilation problems:"
      + "\nsetupExpectations cannot be resolved");
  }
  
  public Object inferredNode(final /* EObject */Object obj) {
    throw new Error("Unresolved compilation problems:"
      + "\n=> cannot be resolved.");
  }
  
  public Object inferredNode(final /* EObject */Object obj, final /*  */Object expectationsBuilder) {
    throw new Error("Unresolved compilation problems:"
      + "\nsetupExpectations cannot be resolved");
  }
  
  public TypedNode setupExpectations(final TypedNode n, final /*  */Object expectationsBuilder) {
    throw new Error("Unresolved compilation problems:"
      + "\napply cannot be resolved");
  }
  
  public TypedNode getNode(final /* EObject */Object obj) {
    throw new Error("Unresolved compilation problems:"
      + "\n! cannot be resolved."
      + "\nbind cannot be resolved");
  }
  
  /**
   * # 2
   * Second step. Goes through all the bindings and tries to infer types.
   */
  public void inferTypes() {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method forEach is undefined for the type BoundsBasedTypeSystem");
  }
  
  /**
   * # 3
   * Third step. Asks each node individually for errors (type expectation violations).
   */
  public Iterable<TypeExpectationFailedException> issues(final /* EObject */Object obj) {
    throw new Error("Unresolved compilation problems:"
      + "\nnode cannot be resolved"
      + "\nissues cannot be resolved");
  }
  
  /**
   * Returns the resolved type for the given object.
   * This must be called after "inferTypes" step.
   */
  public WollokType type(final /* EObject */Object obj) {
    throw new Error("Unresolved compilation problems:"
      + "\nnode cannot be resolved"
      + "\ntype cannot be resolved");
  }
  
  public void analyse(final /* EObject */Object o) {
    this.bind(o);
  }
  
  protected void _bind(final WProgram p) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method elements is undefined for the type BoundsBasedTypeSystem"
      + "\nThe method elements is undefined for the type BoundsBasedTypeSystem"
      + "\nforEach cannot be resolved"
      + "\nlast cannot be resolved");
  }
  
  protected void _bind(final WClass c) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method forEach is undefined for the type BoundsBasedTypeSystem"
      + "\nThe method forEach is undefined for the type BoundsBasedTypeSystem");
  }
  
  protected void _bind(final WBlockExpression e) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method expressions is undefined for the type BoundsBasedTypeSystem"
      + "\nThe method expressions is undefined for the type BoundsBasedTypeSystem"
      + "\nforEach cannot be resolved"
      + "\nlast cannot be resolved");
  }
  
  protected void _bind(final WVariableDeclaration v) {
    throw new Error("Unresolved compilation problems:"
      + "\n!= cannot be resolved."
      + "\n>= cannot be resolved."
      + "\nInvalid number of arguments. The method inferredNode(EObject) is not applicable for the arguments (WVariableDeclaration,Object)");
  }
  
  protected void _bind(final WVariableReference v) {
    this.inferredNode(v);
    WReferenciable _ref = v.getRef();
    this.operator_spaceship(v, _ref);
  }
  
  protected void _bind(final WAssignment a) {
    throw new Error("Unresolved compilation problems:"
      + "\n>= cannot be resolved."
      + "\nInvalid number of arguments. The method fixedNode(WollokType, EObject) is not applicable for the arguments (VoidType,WAssignment,Object)");
  }
  
  protected void _bind(final WBinaryOperation op) {
    throw new Error("Unresolved compilation problems:"
      + "\nvalue cannot be resolved"
      + "\nfixedNode cannot be resolved"
      + "\nkey cannot be resolved"
      + "\nget cannot be resolved"
      + "\nkey cannot be resolved"
      + "\nget cannot be resolved");
  }
  
  protected void _bind(final WIfExpression ef) {
    throw new Error("Unresolved compilation problems:"
      + "\nInvalid number of arguments. The method inferredNode(EObject) is not applicable for the arguments (WIfExpression,Object)");
  }
  
  protected void _bind(final WMethodDeclaration m) {
    throw new Error("Unresolved compilation problems:"
      + "\n>= cannot be resolved."
      + "\nInvalid number of arguments. The method inferredNode(EObject) is not applicable for the arguments (WMethodDeclaration,Object)");
  }
  
  protected void _bind(final WParameter p) {
    this.inferredNode(p);
  }
  
  protected void _bind(final WNullLiteral p) {
    this.inferredNode(p);
  }
  
  protected void _bind(final WNumberLiteral l) {
    this.fixedNode(WollokType.WInt, l);
  }
  
  protected void _bind(final WStringLiteral l) {
    this.fixedNode(WollokType.WString, l);
  }
  
  protected void _bind(final WBooleanLiteral l) {
    this.fixedNode(WollokType.WBoolean, l);
  }
  
  protected void _bind(final WMemberFeatureCall call) {
    throw new Error("Unresolved compilation problems:"
      + "\nType mismatch: cannot convert from Object to List");
  }
  
  public boolean bindExactlyTo(final TypedNode from, final TypedNode to) {
    ExactTypeBound _exactTypeBound = new ExactTypeBound(from, to);
    return this.bounds.add(_exactTypeBound);
  }
  
  public boolean bindAsSuperTypeOf(final TypedNode bindSource, final TypedNode from, final TypedNode to) {
    SuperTypeBound _superTypeBound = new SuperTypeBound(bindSource, from, to);
    return this.bounds.add(_superTypeBound);
  }
  
  public boolean bindAsSuperTypeOf(final TypedNode from, final TypedNode to) {
    SuperTypeBound _superTypeBound = new SuperTypeBound(from, to);
    return this.bounds.add(_superTypeBound);
  }
  
  public Object operator_spaceship(final /* EObject */Object from, final /* EObject */Object to) {
    throw new Error("Unresolved compilation problems:"
      + "\nnode cannot be resolved"
      + "\nbindExactlyTo cannot be resolved"
      + "\nnode cannot be resolved");
  }
  
  public Object operator_tripleLessThan(final /* EObject */Object obj, final WollokType expected) {
    throw new Error("Unresolved compilation problems:"
      + "\nnode cannot be resolved"
      + "\nexpectType cannot be resolved");
  }
  
  public Object getBounds(final TypedNode node) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method filter is undefined for the type BoundsBasedTypeSystem"
      + "\nisFor cannot be resolved");
  }
  
  public void bind(final Object a) {
    if (a instanceof WAssignment) {
      _bind((WAssignment)a);
      return;
    } else if (a instanceof WBinaryOperation) {
      _bind((WBinaryOperation)a);
      return;
    } else if (a instanceof WBlockExpression) {
      _bind((WBlockExpression)a);
      return;
    } else if (a instanceof WBooleanLiteral) {
      _bind((WBooleanLiteral)a);
      return;
    } else if (a instanceof WIfExpression) {
      _bind((WIfExpression)a);
      return;
    } else if (a instanceof WMemberFeatureCall) {
      _bind((WMemberFeatureCall)a);
      return;
    } else if (a instanceof WNullLiteral) {
      _bind((WNullLiteral)a);
      return;
    } else if (a instanceof WNumberLiteral) {
      _bind((WNumberLiteral)a);
      return;
    } else if (a instanceof WParameter) {
      _bind((WParameter)a);
      return;
    } else if (a instanceof WStringLiteral) {
      _bind((WStringLiteral)a);
      return;
    } else if (a instanceof WVariableDeclaration) {
      _bind((WVariableDeclaration)a);
      return;
    } else if (a instanceof WVariableReference) {
      _bind((WVariableReference)a);
      return;
    } else if (a instanceof WClass) {
      _bind((WClass)a);
      return;
    } else if (a instanceof WMethodDeclaration) {
      _bind((WMethodDeclaration)a);
      return;
    } else if (a instanceof WProgram) {
      _bind((WProgram)a);
      return;
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(a).toString());
    }
  }
}
