package org.uqbar.project.wollok.typesystem.substitutions;

import com.google.common.base.Objects;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Pair;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.uqbar.project.wollok.model.WMethodContainerExtensions;
import org.uqbar.project.wollok.model.WollokModelExtensions;
import org.uqbar.project.wollok.semantics.BasicType;
import org.uqbar.project.wollok.semantics.ClassBasedWollokType;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.TypeSystem;
import org.uqbar.project.wollok.typesystem.TypeSystemUtils;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;
import org.uqbar.project.wollok.typesystem.substitutions.CheckTypeRule;
import org.uqbar.project.wollok.typesystem.substitutions.FactTypeRule;
import org.uqbar.project.wollok.typesystem.substitutions.TypeCheck;
import org.uqbar.project.wollok.typesystem.substitutions.TypeRule;
import org.uqbar.project.wollok.wollokDsl.WAssignment;
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation;
import org.uqbar.project.wollok.wollokDsl.WBlockExpression;
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral;
import org.uqbar.project.wollok.wollokDsl.WClass;
import org.uqbar.project.wollok.wollokDsl.WConstructorCall;
import org.uqbar.project.wollok.wollokDsl.WExpression;
import org.uqbar.project.wollok.wollokDsl.WIfExpression;
import org.uqbar.project.wollok.wollokDsl.WMember;
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall;
import org.uqbar.project.wollok.wollokDsl.WMethodContainer;
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration;
import org.uqbar.project.wollok.wollokDsl.WNullLiteral;
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral;
import org.uqbar.project.wollok.wollokDsl.WParameter;
import org.uqbar.project.wollok.wollokDsl.WProgram;
import org.uqbar.project.wollok.wollokDsl.WReferenciable;
import org.uqbar.project.wollok.wollokDsl.WStringLiteral;
import org.uqbar.project.wollok.wollokDsl.WTest;
import org.uqbar.project.wollok.wollokDsl.WThis;
import org.uqbar.project.wollok.wollokDsl.WVariable;
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration;
import org.uqbar.project.wollok.wollokDsl.WVariableReference;

/**
 * Implementation that builds up rules
 * and the goes through several steps substituting types.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class SubstitutionBasedTypeSystem implements TypeSystem {
  private List<TypeRule> rules = CollectionLiterals.<TypeRule>newArrayList();
  
  private Set<EObject> analyzed = CollectionLiterals.<EObject>newHashSet();
  
  public void analyse(final EObject p) {
    EList<EObject> _eContents = p.eContents();
    final Procedure1<EObject> _function = new Procedure1<EObject>() {
      public void apply(final EObject it) {
        SubstitutionBasedTypeSystem.this.analyze(it);
      }
    };
    IterableExtensions.<EObject>forEach(_eContents, _function);
  }
  
  public void analyze(final EObject node) {
    boolean _contains = this.analyzed.contains(node);
    boolean _not = (!_contains);
    if (_not) {
      this.analyzed.add(node);
      this.doAnalyse(node);
    }
  }
  
  public void analyze(final Iterable<? extends EObject> objects) {
    final Procedure1<EObject> _function = new Procedure1<EObject>() {
      public void apply(final EObject it) {
        SubstitutionBasedTypeSystem.this.analyze(it);
      }
    };
    IterableExtensions.forEach(objects, _function);
  }
  
  protected void _doAnalyse(final WProgram it) {
    EList<WExpression> _elements = it.getElements();
    this.analyze(_elements);
  }
  
  protected void _doAnalyse(final WTest it) {
    EList<WExpression> _elements = it.getElements();
    this.analyze(_elements);
  }
  
  protected void _doAnalyse(final WClass it) {
    EList<WMember> _members = it.getMembers();
    boolean _notEquals = (!Objects.equal(_members, null));
    if (_notEquals) {
      EList<WMember> _members_1 = it.getMembers();
      final Procedure1<WMember> _function = new Procedure1<WMember>() {
        public void apply(final WMember it) {
          SubstitutionBasedTypeSystem.this.analyze(it);
        }
      };
      IterableExtensions.<WMember>forEach(_members_1, _function);
    }
  }
  
  protected void _doAnalyse(final WMethodDeclaration it) {
    EList<WParameter> _parameters = it.getParameters();
    this.analyze(_parameters);
    boolean _isOverrides = it.isOverrides();
    if (_isOverrides) {
      final WMethodDeclaration overriden = WMethodContainerExtensions.overridenMethod(it);
      this.addCheck(it, overriden, TypeCheck.SUPER_OF, it);
      int i = 0;
      EList<WParameter> _parameters_1 = overriden.getParameters();
      for (final WParameter overParam : _parameters_1) {
        EList<WParameter> _parameters_2 = it.getParameters();
        int _plusPlus = i++;
        WParameter _get = _parameters_2.get(_plusPlus);
        this.addCheck(it, _get, TypeCheck.SAME_AS, overParam);
      }
    }
    boolean _isAbstract = WMethodContainerExtensions.isAbstract(it);
    if (_isAbstract) {
      this.isA(it, WollokType.WAny);
    } else {
      WExpression _expression = it.getExpression();
      this.addCheck(it, it, TypeCheck.SUPER_OF, _expression);
    }
  }
  
  protected void _doAnalyse(final WVariableDeclaration it) {
    WVariable _variable = it.getVariable();
    this.addCheck(it, it, TypeCheck.SAME_AS, _variable);
    WExpression _right = it.getRight();
    boolean _notEquals = (!Objects.equal(_right, null));
    if (_notEquals) {
      WVariable _variable_1 = it.getVariable();
      WExpression _right_1 = it.getRight();
      this.addCheck(it, _variable_1, TypeCheck.SUPER_OF, _right_1);
    }
  }
  
  protected void _doAnalyse(final WVariable v) {
  }
  
  protected void _doAnalyse(final WMemberFeatureCall it) {
    WExpression _memberCallTarget = it.getMemberCallTarget();
    if ((_memberCallTarget instanceof WThis)) {
      WMethodDeclaration _method = WollokModelExtensions.method(it);
      WMethodContainer _declaringContext = WollokModelExtensions.declaringContext(_method);
      String _feature = it.getFeature();
      EList<WExpression> _memberCallArguments = it.getMemberCallArguments();
      WMethodDeclaration _lookupMethod = WMethodContainerExtensions.lookupMethod(_declaringContext, _feature, _memberCallArguments);
      this.addCheck(it, it, TypeCheck.SAME_AS, _lookupMethod);
    }
  }
  
  protected void _doAnalyse(final WConstructorCall it) {
    WClass _classRef = it.getClassRef();
    ClassBasedWollokType _classBasedWollokType = new ClassBasedWollokType(_classRef, null, null);
    this.isA(it, _classBasedWollokType);
  }
  
  protected void _doAnalyse(final WNumberLiteral it) {
    this.isAn(it, WollokType.WInt);
  }
  
  protected void _doAnalyse(final WStringLiteral it) {
    this.isA(it, WollokType.WString);
  }
  
  protected void _doAnalyse(final WBooleanLiteral it) {
    this.isA(it, WollokType.WBoolean);
  }
  
  protected void _doAnalyse(final WNullLiteral it) {
  }
  
  protected void _doAnalyse(final WParameter it) {
  }
  
  protected void _doAnalyse(final WAssignment it) {
    this.isA(it, WollokType.WVoid);
    WVariableReference _feature = it.getFeature();
    WExpression _value = it.getValue();
    this.addCheck(it, _feature, TypeCheck.SUPER_OF, _value);
  }
  
  protected void _doAnalyse(final WBinaryOperation it) {
    String _feature = it.getFeature();
    final Pair<? extends List<? extends BasicType>, ? extends BasicType> opType = TypeSystemUtils.typeOfOperation(_feature);
    BasicType _value = opType.getValue();
    this.addFact(it, it, _value);
    WExpression _leftOperand = it.getLeftOperand();
    List<? extends BasicType> _key = opType.getKey();
    BasicType _get = _key.get(0);
    this.addFact(it, _leftOperand, _get);
    WExpression _rightOperand = it.getRightOperand();
    List<? extends BasicType> _key_1 = opType.getKey();
    BasicType _get_1 = _key_1.get(1);
    this.addFact(it, _rightOperand, _get_1);
  }
  
  protected void _doAnalyse(final WVariableReference it) {
    WReferenciable _ref = it.getRef();
    this.addCheck(it, it, TypeCheck.SAME_AS, _ref);
  }
  
  protected void _doAnalyse(final WIfExpression it) {
    WExpression _condition = it.getCondition();
    this.addFact(it, _condition, WollokType.WBoolean);
    WExpression _then = it.getThen();
    this.addCheck(it, it, TypeCheck.SUPER_OF, _then);
    WExpression _else = it.getElse();
    boolean _notEquals = (!Objects.equal(_else, null));
    if (_notEquals) {
      WExpression _else_1 = it.getElse();
      this.addCheck(it, it, TypeCheck.SUPER_OF, _else_1);
    }
  }
  
  protected void _doAnalyse(final WBlockExpression it) {
    EList<WExpression> _expressions = it.getExpressions();
    boolean _isEmpty = _expressions.isEmpty();
    boolean _not = (!_isEmpty);
    if (_not) {
      EList<WExpression> _expressions_1 = it.getExpressions();
      this.analyze(_expressions_1);
      EList<WExpression> _expressions_2 = it.getExpressions();
      WExpression _last = IterableExtensions.<WExpression>last(_expressions_2);
      this.addCheck(it, it, TypeCheck.SAME_AS, _last);
    }
  }
  
  public void inferTypes() {
    this.resolveRules();
    this.unifyConstraints();
  }
  
  protected void resolveRules() {
    int nrSteps = 0;
    boolean resolved = true;
    while (resolved) {
      TypeRule[] _clone = ((TypeRule[])Conversions.unwrapArray(this.rules, TypeRule.class)).clone();
      final Function2<Boolean, TypeRule, Boolean> _function = new Function2<Boolean, TypeRule, Boolean>() {
        public Boolean apply(final Boolean r, final TypeRule rule) {
          boolean _xblockexpression = false;
          {
            final boolean ruleValue = rule.resolve(SubstitutionBasedTypeSystem.this);
            boolean _or = false;
            if ((r).booleanValue()) {
              _or = true;
            } else {
              _or = ruleValue;
            }
            _xblockexpression = _or;
          }
          return Boolean.valueOf(_xblockexpression);
        }
      };
      Boolean _fold = IterableExtensions.<TypeRule, Boolean>fold(((Iterable<TypeRule>)Conversions.doWrapArray(_clone)), Boolean.valueOf(false), _function);
      resolved = (_fold).booleanValue();
    }
  }
  
  protected Object unifyConstraints() {
    return null;
  }
  
  public WollokType type(final EObject obj) {
    WollokType _xblockexpression = null;
    {
      final WollokType t = this.typeForExcept(obj, null);
      WollokType _xifexpression = null;
      boolean _equals = Objects.equal(t, null);
      if (_equals) {
        _xifexpression = WollokType.WAny;
      } else {
        _xifexpression = t;
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  public Iterable<TypeExpectationFailedException> issues(final EObject obj) {
    Iterable<TypeExpectationFailedException> _xblockexpression = null;
    {
      ArrayList<TypeExpectationFailedException> _newArrayList = CollectionLiterals.<TypeExpectationFailedException>newArrayList();
      final Function2<ArrayList<TypeExpectationFailedException>, TypeRule, ArrayList<TypeExpectationFailedException>> _function = new Function2<ArrayList<TypeExpectationFailedException>, TypeRule, ArrayList<TypeExpectationFailedException>>() {
        public ArrayList<TypeExpectationFailedException> apply(final ArrayList<TypeExpectationFailedException> l, final TypeRule r) {
          ArrayList<TypeExpectationFailedException> _xblockexpression = null;
          {
            try {
              r.check();
            } catch (final Throwable _t) {
              if (_t instanceof TypeExpectationFailedException) {
                final TypeExpectationFailedException e = (TypeExpectationFailedException)_t;
                l.add(e);
              } else {
                throw Exceptions.sneakyThrow(_t);
              }
            }
            _xblockexpression = l;
          }
          return _xblockexpression;
        }
      };
      final ArrayList<TypeExpectationFailedException> allIssues = IterableExtensions.<TypeRule, ArrayList<TypeExpectationFailedException>>fold(this.rules, _newArrayList, _function);
      final Function1<TypeExpectationFailedException, Boolean> _function_1 = new Function1<TypeExpectationFailedException, Boolean>() {
        public Boolean apply(final TypeExpectationFailedException i) {
          EObject _model = i.getModel();
          return Boolean.valueOf(Objects.equal(_model, obj));
        }
      };
      _xblockexpression = IterableExtensions.<TypeExpectationFailedException>filter(allIssues, _function_1);
    }
    return _xblockexpression;
  }
  
  /**
   * Returns the resolved type for the given object.
   * Unless there are multiple resolved types.
   * To resolve the type it asks all the rules (but the one passed as args).
   * This is because probably from one rule you want to ask the type of one of its
   * object but you don't want to the system to ask your rule back.
   */
  public WollokType typeForExcept(final EObject object, final TypeRule unwantedRule) {
    WollokType _xblockexpression = null;
    {
      ArrayList<WollokType> _newArrayList = CollectionLiterals.<WollokType>newArrayList();
      final Function2<ArrayList<WollokType>, TypeRule, ArrayList<WollokType>> _function = new Function2<ArrayList<WollokType>, TypeRule, ArrayList<WollokType>>() {
        public ArrayList<WollokType> apply(final ArrayList<WollokType> l, final TypeRule r) {
          ArrayList<WollokType> _xblockexpression = null;
          {
            boolean _notEquals = (!Objects.equal(r, unwantedRule));
            if (_notEquals) {
              final WollokType type = r.typeOf(object);
              boolean _notEquals_1 = (!Objects.equal(type, null));
              if (_notEquals_1) {
                l.add(type);
              }
            }
            _xblockexpression = l;
          }
          return _xblockexpression;
        }
      };
      final ArrayList<WollokType> types = IterableExtensions.<TypeRule, ArrayList<WollokType>>fold(this.rules, _newArrayList, _function);
      WollokType _xifexpression = null;
      int _size = types.size();
      boolean _equals = (_size == 1);
      if (_equals) {
        _xifexpression = IterableExtensions.<WollokType>head(types);
      } else {
        _xifexpression = null;
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  public boolean addRule(final TypeRule rule) {
    boolean _xifexpression = false;
    boolean _contains = this.rules.contains(rule);
    boolean _not = (!_contains);
    if (_not) {
      _xifexpression = this.rules.add(rule);
    }
    return _xifexpression;
  }
  
  public boolean addFact(final EObject source, final EObject model, final WollokType knownType) {
    boolean _xblockexpression = false;
    {
      this.analyze(model);
      FactTypeRule _factTypeRule = new FactTypeRule(source, model, knownType);
      _xblockexpression = this.addRule(_factTypeRule);
    }
    return _xblockexpression;
  }
  
  public boolean isAn(final EObject model, final WollokType knownType) {
    return this.isA(model, knownType);
  }
  
  public boolean isA(final EObject model, final WollokType knownType) {
    return this.addFact(model, model, knownType);
  }
  
  public boolean addCheck(final EObject source, final EObject a, final TypeCheck check, final EObject b) {
    boolean _xblockexpression = false;
    {
      this.analyze(a);
      this.analyze(b);
      CheckTypeRule _checkTypeRule = new CheckTypeRule(source, a, check, b);
      _xblockexpression = this.addRule(_checkTypeRule);
    }
    return _xblockexpression;
  }
  
  public String toString() {
    String _join = IterableExtensions.join(this.rules, "\n\t");
    String _plus = ("{\n\t" + _join);
    return (_plus + "\n}");
  }
  
  public void doAnalyse(final EObject it) {
    if (it instanceof WAssignment) {
      _doAnalyse((WAssignment)it);
      return;
    } else if (it instanceof WBinaryOperation) {
      _doAnalyse((WBinaryOperation)it);
      return;
    } else if (it instanceof WBlockExpression) {
      _doAnalyse((WBlockExpression)it);
      return;
    } else if (it instanceof WBooleanLiteral) {
      _doAnalyse((WBooleanLiteral)it);
      return;
    } else if (it instanceof WConstructorCall) {
      _doAnalyse((WConstructorCall)it);
      return;
    } else if (it instanceof WIfExpression) {
      _doAnalyse((WIfExpression)it);
      return;
    } else if (it instanceof WMemberFeatureCall) {
      _doAnalyse((WMemberFeatureCall)it);
      return;
    } else if (it instanceof WNullLiteral) {
      _doAnalyse((WNullLiteral)it);
      return;
    } else if (it instanceof WNumberLiteral) {
      _doAnalyse((WNumberLiteral)it);
      return;
    } else if (it instanceof WParameter) {
      _doAnalyse((WParameter)it);
      return;
    } else if (it instanceof WStringLiteral) {
      _doAnalyse((WStringLiteral)it);
      return;
    } else if (it instanceof WVariable) {
      _doAnalyse((WVariable)it);
      return;
    } else if (it instanceof WVariableDeclaration) {
      _doAnalyse((WVariableDeclaration)it);
      return;
    } else if (it instanceof WVariableReference) {
      _doAnalyse((WVariableReference)it);
      return;
    } else if (it instanceof WClass) {
      _doAnalyse((WClass)it);
      return;
    } else if (it instanceof WMethodDeclaration) {
      _doAnalyse((WMethodDeclaration)it);
      return;
    } else if (it instanceof WProgram) {
      _doAnalyse((WProgram)it);
      return;
    } else if (it instanceof WTest) {
      _doAnalyse((WTest)it);
      return;
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
