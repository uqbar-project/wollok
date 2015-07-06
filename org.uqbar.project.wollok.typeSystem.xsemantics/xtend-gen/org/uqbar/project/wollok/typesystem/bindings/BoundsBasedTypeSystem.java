package org.uqbar.project.wollok.typesystem.bindings;

import com.google.common.base.Objects;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Pair;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.uqbar.project.wollok.model.WMethodContainerExtensions;
import org.uqbar.project.wollok.model.WollokModelExtensions;
import org.uqbar.project.wollok.semantics.BasicType;
import org.uqbar.project.wollok.semantics.ClassBasedWollokType;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.TypeSystem;
import org.uqbar.project.wollok.typesystem.TypeSystemUtils;
import org.uqbar.project.wollok.typesystem.bindings.ExactTypeBound;
import org.uqbar.project.wollok.typesystem.bindings.ExpectationBuilder;
import org.uqbar.project.wollok.typesystem.bindings.SuperTypeBound;
import org.uqbar.project.wollok.typesystem.bindings.TypeBound;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;
import org.uqbar.project.wollok.typesystem.bindings.TypeInferedNode;
import org.uqbar.project.wollok.typesystem.bindings.TypedNode;
import org.uqbar.project.wollok.typesystem.bindings.ValueTypedNode;
import org.uqbar.project.wollok.wollokDsl.WAssignment;
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation;
import org.uqbar.project.wollok.wollokDsl.WBlockExpression;
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral;
import org.uqbar.project.wollok.wollokDsl.WClass;
import org.uqbar.project.wollok.wollokDsl.WExpression;
import org.uqbar.project.wollok.wollokDsl.WIfExpression;
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall;
import org.uqbar.project.wollok.wollokDsl.WMethodContainer;
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration;
import org.uqbar.project.wollok.wollokDsl.WNullLiteral;
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral;
import org.uqbar.project.wollok.wollokDsl.WParameter;
import org.uqbar.project.wollok.wollokDsl.WProgram;
import org.uqbar.project.wollok.wollokDsl.WReferenciable;
import org.uqbar.project.wollok.wollokDsl.WStringLiteral;
import org.uqbar.project.wollok.wollokDsl.WThis;
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
  private Map<EObject, TypedNode> nodes = CollectionLiterals.<EObject, TypedNode>newHashMap();
  
  private List<TypeBound> bounds = CollectionLiterals.<TypeBound>newArrayList();
  
  public ValueTypedNode fixedNode(final WollokType fixedType, final EObject obj) {
    ValueTypedNode _valueTypedNode = new ValueTypedNode(obj, fixedType, this);
    final Procedure1<ValueTypedNode> _function = new Procedure1<ValueTypedNode>() {
      public void apply(final ValueTypedNode it) {
        BoundsBasedTypeSystem.this.nodes.put(obj, it);
      }
    };
    return ObjectExtensions.<ValueTypedNode>operator_doubleArrow(_valueTypedNode, _function);
  }
  
  public TypedNode fixedNode(final WollokType fixedType, final EObject obj, final Procedure1<? super ExpectationBuilder> expectationsBuilder) {
    ValueTypedNode _fixedNode = this.fixedNode(fixedType, obj);
    return this.setupExpectations(_fixedNode, expectationsBuilder);
  }
  
  public TypeInferedNode inferredNode(final EObject obj) {
    TypeInferedNode _typeInferedNode = new TypeInferedNode(obj, this);
    final Procedure1<TypeInferedNode> _function = new Procedure1<TypeInferedNode>() {
      public void apply(final TypeInferedNode it) {
        BoundsBasedTypeSystem.this.nodes.put(obj, it);
      }
    };
    return ObjectExtensions.<TypeInferedNode>operator_doubleArrow(_typeInferedNode, _function);
  }
  
  public TypedNode inferredNode(final EObject obj, final Procedure1<? super ExpectationBuilder> expectationsBuilder) {
    TypeInferedNode _inferredNode = this.inferredNode(obj);
    return this.setupExpectations(_inferredNode, expectationsBuilder);
  }
  
  public TypedNode setupExpectations(final TypedNode n, final Procedure1<? super ExpectationBuilder> expectationsBuilder) {
    TypedNode _xblockexpression = null;
    {
      ExpectationBuilder _expectationBuilder = new ExpectationBuilder(this, n);
      expectationsBuilder.apply(_expectationBuilder);
      _xblockexpression = n;
    }
    return _xblockexpression;
  }
  
  public TypedNode getNode(final EObject obj) {
    TypedNode _xblockexpression = null;
    {
      boolean _containsKey = this.nodes.containsKey(obj);
      boolean _not = (!_containsKey);
      if (_not) {
        this.bind(obj);
      }
      _xblockexpression = this.nodes.get(obj);
    }
    return _xblockexpression;
  }
  
  /**
   * # 2
   * Second step. Goes through all the bindings and tries to infer types.
   */
  public void inferTypes() {
    final Procedure1<TypeBound> _function = new Procedure1<TypeBound>() {
      public void apply(final TypeBound it) {
        it.inferTypes();
      }
    };
    IterableExtensions.<TypeBound>forEach(this.bounds, _function);
  }
  
  /**
   * # 3
   * Third step. Asks each node individually for errors (type expectation violations).
   */
  public Iterable<TypeExpectationFailedException> issues(final EObject obj) {
    TypedNode _node = this.getNode(obj);
    return _node.issues();
  }
  
  /**
   * Returns the resolved type for the given object.
   * This must be called after "inferTypes" step.
   */
  public WollokType type(final EObject obj) {
    TypedNode _node = this.getNode(obj);
    return _node.getType();
  }
  
  public void analyse(final EObject o) {
    this.bind(o);
  }
  
  protected void _bind(final WProgram p) {
    this.inferredNode(p);
    EList<WExpression> _elements = p.getElements();
    final Procedure1<WExpression> _function = new Procedure1<WExpression>() {
      public void apply(final WExpression it) {
        BoundsBasedTypeSystem.this.bind(it);
      }
    };
    IterableExtensions.<WExpression>forEach(_elements, _function);
    EList<WExpression> _elements_1 = p.getElements();
    WExpression _last = IterableExtensions.<WExpression>last(_elements_1);
    this.operator_spaceship(p, _last);
  }
  
  protected void _bind(final WClass c) {
    ClassBasedWollokType _classBasedWollokType = new ClassBasedWollokType(c, null, null);
    this.fixedNode(_classBasedWollokType, c);
    Iterable<WVariableDeclaration> _variableDeclarations = WMethodContainerExtensions.variableDeclarations(c);
    final Procedure1<WVariableDeclaration> _function = new Procedure1<WVariableDeclaration>() {
      public void apply(final WVariableDeclaration it) {
        BoundsBasedTypeSystem.this.bind(it);
      }
    };
    IterableExtensions.<WVariableDeclaration>forEach(_variableDeclarations, _function);
    Iterable<WMethodDeclaration> _methods = WMethodContainerExtensions.methods(c);
    final Procedure1<WMethodDeclaration> _function_1 = new Procedure1<WMethodDeclaration>() {
      public void apply(final WMethodDeclaration it) {
        BoundsBasedTypeSystem.this.bind(it);
      }
    };
    IterableExtensions.<WMethodDeclaration>forEach(_methods, _function_1);
  }
  
  protected void _bind(final WBlockExpression e) {
    this.inferredNode(e);
    EList<WExpression> _expressions = e.getExpressions();
    final Procedure1<WExpression> _function = new Procedure1<WExpression>() {
      public void apply(final WExpression it) {
        BoundsBasedTypeSystem.this.bind(it);
      }
    };
    IterableExtensions.<WExpression>forEach(_expressions, _function);
    EList<WExpression> _expressions_1 = e.getExpressions();
    WExpression _last = IterableExtensions.<WExpression>last(_expressions_1);
    this.operator_spaceship(e, _last);
  }
  
  protected void _bind(final WVariableDeclaration v) {
    final Procedure1<ExpectationBuilder> _function = new Procedure1<ExpectationBuilder>() {
      public void apply(@Extension final ExpectationBuilder b) {
        WExpression _right = v.getRight();
        boolean _notEquals = (!Objects.equal(_right, null));
        if (_notEquals) {
          WExpression _right_1 = v.getRight();
          b.operator_greaterEqualsThan(v, _right_1);
        }
      }
    };
    this.inferredNode(v, _function);
  }
  
  protected void _bind(final WVariableReference v) {
    this.inferredNode(v);
    WReferenciable _ref = v.getRef();
    this.operator_spaceship(v, _ref);
  }
  
  protected void _bind(final WAssignment a) {
    final Procedure1<ExpectationBuilder> _function = new Procedure1<ExpectationBuilder>() {
      public void apply(@Extension final ExpectationBuilder b) {
        WVariableReference _feature = a.getFeature();
        WExpression _value = a.getValue();
        b.operator_greaterEqualsThan(_feature, _value);
      }
    };
    this.fixedNode(WollokType.WVoid, a, _function);
  }
  
  protected void _bind(final WBinaryOperation op) {
    String _feature = op.getFeature();
    final Pair<? extends List<? extends BasicType>, ? extends BasicType> opType = TypeSystemUtils.typeOfOperation(_feature);
    BasicType _value = opType.getValue();
    final Procedure1<ExpectationBuilder> _function = new Procedure1<ExpectationBuilder>() {
      public void apply(@Extension final ExpectationBuilder b) {
        WExpression _leftOperand = op.getLeftOperand();
        List<? extends BasicType> _key = opType.getKey();
        BasicType _get = _key.get(0);
        BoundsBasedTypeSystem.this.operator_tripleLessThan(_leftOperand, _get);
        WExpression _rightOperand = op.getRightOperand();
        List<? extends BasicType> _key_1 = opType.getKey();
        BasicType _get_1 = _key_1.get(1);
        BoundsBasedTypeSystem.this.operator_tripleLessThan(_rightOperand, _get_1);
        WExpression _leftOperand_1 = op.getLeftOperand();
        WExpression _rightOperand_1 = op.getRightOperand();
        BoundsBasedTypeSystem.this.operator_spaceship(_leftOperand_1, _rightOperand_1);
      }
    };
    this.fixedNode(_value, op, _function);
  }
  
  protected void _bind(final WIfExpression ef) {
    final Procedure1<ExpectationBuilder> _function = new Procedure1<ExpectationBuilder>() {
      public void apply(@Extension final ExpectationBuilder b) {
        WExpression _condition = ef.getCondition();
        BoundsBasedTypeSystem.this.operator_tripleLessThan(_condition, WollokType.WBoolean);
        WExpression _then = ef.getThen();
        BoundsBasedTypeSystem.this.operator_spaceship(ef, _then);
        WExpression _else = ef.getElse();
        BoundsBasedTypeSystem.this.operator_spaceship(ef, _else);
      }
    };
    this.inferredNode(ef, _function);
  }
  
  protected void _bind(final WMethodDeclaration m) {
    final Procedure1<ExpectationBuilder> _function = new Procedure1<ExpectationBuilder>() {
      public void apply(@Extension final ExpectationBuilder b) {
        boolean _isOverrides = m.isOverrides();
        if (_isOverrides) {
          WMethodDeclaration _overridenMethod = WMethodContainerExtensions.overridenMethod(m);
          b.operator_greaterEqualsThan(_overridenMethod, m);
        }
        WExpression _expression = m.getExpression();
        BoundsBasedTypeSystem.this.operator_spaceship(m, _expression);
      }
    };
    this.inferredNode(m, _function);
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
    this.inferredNode(call);
    WExpression _memberCallTarget = call.getMemberCallTarget();
    if ((_memberCallTarget instanceof WThis)) {
      WMethodDeclaration _method = WollokModelExtensions.method(call);
      WMethodContainer _declaringContext = WollokModelExtensions.declaringContext(_method);
      String _feature = call.getFeature();
      final WMethodDeclaration referencedMethod = WMethodContainerExtensions.lookupMethod(_declaringContext, _feature);
      this.operator_spaceship(call, referencedMethod);
    }
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
  
  public boolean operator_spaceship(final EObject from, final EObject to) {
    TypedNode _node = this.getNode(from);
    TypedNode _node_1 = this.getNode(to);
    return this.bindExactlyTo(_node, _node_1);
  }
  
  public void operator_tripleLessThan(final EObject obj, final WollokType expected) {
    TypedNode _node = this.getNode(obj);
    _node.expectType(expected);
  }
  
  public Iterable<TypeBound> getBounds(final TypedNode node) {
    final Function1<TypeBound, Boolean> _function = new Function1<TypeBound, Boolean>() {
      public Boolean apply(final TypeBound b) {
        return Boolean.valueOf(b.isFor(node));
      }
    };
    return IterableExtensions.<TypeBound>filter(this.bounds, _function);
  }
  
  public void bind(final EObject a) {
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
