package org.uqbar.project.wollok.semantics;

import com.google.common.base.Objects;
import com.google.inject.Provider;
import it.xsemantics.runtime.ErrorInformation;
import it.xsemantics.runtime.Result;
import it.xsemantics.runtime.RuleApplicationTrace;
import it.xsemantics.runtime.RuleEnvironment;
import it.xsemantics.runtime.RuleFailedException;
import it.xsemantics.runtime.XsemanticsRuntimeSystem;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.function.Consumer;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.xtext.util.PolymorphicDispatcher;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.uqbar.project.wollok.model.WMethodContainerExtensions;
import org.uqbar.project.wollok.model.WollokModelExtensions;
import org.uqbar.project.wollok.semantics.BasicType;
import org.uqbar.project.wollok.semantics.BooleanType;
import org.uqbar.project.wollok.semantics.ClassBasedWollokType;
import org.uqbar.project.wollok.semantics.IntType;
import org.uqbar.project.wollok.semantics.MessageType;
import org.uqbar.project.wollok.semantics.ObjectLiteralWollokType;
import org.uqbar.project.wollok.semantics.StringType;
import org.uqbar.project.wollok.semantics.TypeInferrer;
import org.uqbar.project.wollok.semantics.TypeSystemException;
import org.uqbar.project.wollok.semantics.VoidType;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.wollokDsl.WAssignment;
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation;
import org.uqbar.project.wollok.wollokDsl.WBlockExpression;
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral;
import org.uqbar.project.wollok.wollokDsl.WClass;
import org.uqbar.project.wollok.wollokDsl.WClosure;
import org.uqbar.project.wollok.wollokDsl.WConstructor;
import org.uqbar.project.wollok.wollokDsl.WConstructorCall;
import org.uqbar.project.wollok.wollokDsl.WExpression;
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall;
import org.uqbar.project.wollok.wollokDsl.WMethodContainer;
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration;
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral;
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral;
import org.uqbar.project.wollok.wollokDsl.WParameter;
import org.uqbar.project.wollok.wollokDsl.WProgram;
import org.uqbar.project.wollok.wollokDsl.WReferenciable;
import org.uqbar.project.wollok.wollokDsl.WStringLiteral;
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation;
import org.uqbar.project.wollok.wollokDsl.WThis;
import org.uqbar.project.wollok.wollokDsl.WVariable;
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration;
import org.uqbar.project.wollok.wollokDsl.WVariableReference;
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage;

@SuppressWarnings("all")
public class WollokDslTypeSystem extends XsemanticsRuntimeSystem {
  public final static String INFERDEFAULT = "org.uqbar.project.wollok.semantics.InferDefault";
  
  public final static String INFERWPROGRAM = "org.uqbar.project.wollok.semantics.InferWProgram";
  
  public final static String INFERCLASS = "org.uqbar.project.wollok.semantics.InferClass";
  
  public final static String INFERCONSTRUCTOR = "org.uqbar.project.wollok.semantics.InferConstructor";
  
  public final static String INFERWMETHOD = "org.uqbar.project.wollok.semantics.InferWMethod";
  
  public final static String INFERWCLOSURE = "org.uqbar.project.wollok.semantics.InferWClosure";
  
  public final static String INFEREXPRESSION = "org.uqbar.project.wollok.semantics.InferExpression";
  
  public final static String QUERYTYPEFOR = "org.uqbar.project.wollok.semantics.QueryTypeFor";
  
  public final static String QUERYCLASSTYPE = "org.uqbar.project.wollok.semantics.QueryClassType";
  
  public final static String QUERYMETHODMESSAGETYPE = "org.uqbar.project.wollok.semantics.QueryMethodMessageType";
  
  public final static String NUMBERLITERALTYPE = "org.uqbar.project.wollok.semantics.NumberLiteralType";
  
  public final static String STRINGLITERALTYPE = "org.uqbar.project.wollok.semantics.StringLiteralType";
  
  public final static String BOOLEANLITERALTYPE = "org.uqbar.project.wollok.semantics.BooleanLiteralType";
  
  public final static String VARIABLEREFTYPE = "org.uqbar.project.wollok.semantics.VariableRefType";
  
  public final static String WCONSTRUCTORCALL = "org.uqbar.project.wollok.semantics.WConstructorCall";
  
  public final static String WTHISTYPE = "org.uqbar.project.wollok.semantics.WThisType";
  
  public final static String SUPERCALLTYPE = "org.uqbar.project.wollok.semantics.SuperCallType";
  
  public final static String WBLOCKEXPRESSIONTYPE = "org.uqbar.project.wollok.semantics.WBlockExpressionType";
  
  public final static String ADDITIONTYPE = "org.uqbar.project.wollok.semantics.AdditionType";
  
  public final static String REFINEVARIABLEREF = "org.uqbar.project.wollok.semantics.RefineVariableRef";
  
  public final static String REFINEBLOCKTYPE = "org.uqbar.project.wollok.semantics.RefineBlockType";
  
  public final static String REFINEMETHODRETURNTYPE = "org.uqbar.project.wollok.semantics.RefineMethodReturnType";
  
  public final static String REFINEOTHER = "org.uqbar.project.wollok.semantics.RefineOther";
  
  public final static String VARIABLEDECLARATIONTYPE = "org.uqbar.project.wollok.semantics.VariableDeclarationType";
  
  public final static String ASSIGNMENTTYPE = "org.uqbar.project.wollok.semantics.AssignmentType";
  
  public final static String MEMBERFEATURECALLTYPE = "org.uqbar.project.wollok.semantics.MemberFeatureCallType";
  
  public final static String IGNORE = "org.uqbar.project.wollok.semantics.Ignore";
  
  public final static String EXPECTEDTYPE = "org.uqbar.project.wollok.semantics.ExpectedType";
  
  public final static String OBJECTLITERALTYPE = "org.uqbar.project.wollok.semantics.ObjectLiteralType";
  
  public final static String WPARAMETERSTYPE = "org.uqbar.project.wollok.semantics.WParametersType";
  
  public final static String TYPEOFMESSAGE = "org.uqbar.project.wollok.semantics.TypeOfMessage";
  
  private PolymorphicDispatcher<Result<Boolean>> inferTypesDispatcher;
  
  private PolymorphicDispatcher<Result<WollokType>> typeDispatcher;
  
  private PolymorphicDispatcher<Result<Boolean>> expectedTypeDispatcher;
  
  private PolymorphicDispatcher<Result<WollokType>> typeOfVarDispatcher;
  
  private PolymorphicDispatcher<Result<MessageType>> messageTypeDispatcher;
  
  private PolymorphicDispatcher<Result<Boolean>> refineTypeDispatcher;
  
  private PolymorphicDispatcher<Result<WollokType>> queryTypeForDispatcher;
  
  private PolymorphicDispatcher<Result<MessageType>> queryMessageTypeForMethodDispatcher;
  
  public WollokDslTypeSystem() {
    init();
  }
  
  public void init() {
    inferTypesDispatcher = buildPolymorphicDispatcher1(
    	"inferTypesImpl", 3, "|-");
    typeDispatcher = buildPolymorphicDispatcher1(
    	"typeImpl", 3, "|-", ":");
    expectedTypeDispatcher = buildPolymorphicDispatcher1(
    	"expectedTypeImpl", 4, "|-", "~~");
    typeOfVarDispatcher = buildPolymorphicDispatcher1(
    	"typeOfVarImpl", 3, "|-", "!>");
    messageTypeDispatcher = buildPolymorphicDispatcher1(
    	"messageTypeImpl", 3, "|-", "~>");
    refineTypeDispatcher = buildPolymorphicDispatcher1(
    	"refineTypeImpl", 4, "|-", "<<");
    queryTypeForDispatcher = buildPolymorphicDispatcher1(
    	"queryTypeForImpl", 3, "||-", ">>");
    queryMessageTypeForMethodDispatcher = buildPolymorphicDispatcher1(
    	"queryMessageTypeForMethodImpl", 3, "||-", ":>");
  }
  
  public Result<Boolean> inferTypes(final EObject obj) {
    return inferTypes(new RuleEnvironment(), null, obj);
  }
  
  public Result<Boolean> inferTypes(final RuleEnvironment _environment_, final EObject obj) {
    return inferTypes(_environment_, null, obj);
  }
  
  public Result<Boolean> inferTypes(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final EObject obj) {
    try {
    	return inferTypesInternal(_environment_, _trace_, obj);
    } catch (Exception _e_inferTypes) {
    	return resultForFailure(_e_inferTypes);
    }
  }
  
  public Boolean inferTypesSucceeded(final EObject obj) {
    return inferTypesSucceeded(new RuleEnvironment(), null, obj);
  }
  
  public Boolean inferTypesSucceeded(final RuleEnvironment _environment_, final EObject obj) {
    return inferTypesSucceeded(_environment_, null, obj);
  }
  
  public Boolean inferTypesSucceeded(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final EObject obj) {
    try {
    	inferTypesInternal(_environment_, _trace_, obj);
    	return true;
    } catch (Exception _e_inferTypes) {
    	return false;
    }
  }
  
  public Result<WollokType> type(final WExpression expression) {
    return type(new RuleEnvironment(), null, expression);
  }
  
  public Result<WollokType> type(final RuleEnvironment _environment_, final WExpression expression) {
    return type(_environment_, null, expression);
  }
  
  public Result<WollokType> type(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final WExpression expression) {
    try {
    	return typeInternal(_environment_, _trace_, expression);
    } catch (Exception _e_type) {
    	return resultForFailure(_e_type);
    }
  }
  
  public Result<Boolean> expectedType(final WExpression expression, final WollokType type) {
    return expectedType(new RuleEnvironment(), null, expression, type);
  }
  
  public Result<Boolean> expectedType(final RuleEnvironment _environment_, final WExpression expression, final WollokType type) {
    return expectedType(_environment_, null, expression, type);
  }
  
  public Result<Boolean> expectedType(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final WExpression expression, final WollokType type) {
    try {
    	return expectedTypeInternal(_environment_, _trace_, expression, type);
    } catch (Exception _e_expectedType) {
    	return resultForFailure(_e_expectedType);
    }
  }
  
  public Boolean expectedTypeSucceeded(final WExpression expression, final WollokType type) {
    return expectedTypeSucceeded(new RuleEnvironment(), null, expression, type);
  }
  
  public Boolean expectedTypeSucceeded(final RuleEnvironment _environment_, final WExpression expression, final WollokType type) {
    return expectedTypeSucceeded(_environment_, null, expression, type);
  }
  
  public Boolean expectedTypeSucceeded(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final WExpression expression, final WollokType type) {
    try {
    	expectedTypeInternal(_environment_, _trace_, expression, type);
    	return true;
    } catch (Exception _e_expectedType) {
    	return false;
    }
  }
  
  public Result<WollokType> typeOfVar(final WReferenciable r) {
    return typeOfVar(new RuleEnvironment(), null, r);
  }
  
  public Result<WollokType> typeOfVar(final RuleEnvironment _environment_, final WReferenciable r) {
    return typeOfVar(_environment_, null, r);
  }
  
  public Result<WollokType> typeOfVar(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final WReferenciable r) {
    try {
    	return typeOfVarInternal(_environment_, _trace_, r);
    } catch (Exception _e_typeOfVar) {
    	return resultForFailure(_e_typeOfVar);
    }
  }
  
  public Result<MessageType> messageType(final WMemberFeatureCall call) {
    return messageType(new RuleEnvironment(), null, call);
  }
  
  public Result<MessageType> messageType(final RuleEnvironment _environment_, final WMemberFeatureCall call) {
    return messageType(_environment_, null, call);
  }
  
  public Result<MessageType> messageType(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final WMemberFeatureCall call) {
    try {
    	return messageTypeInternal(_environment_, _trace_, call);
    } catch (Exception _e_messageType) {
    	return resultForFailure(_e_messageType);
    }
  }
  
  public Result<Boolean> refineType(final WExpression e, final WollokType newType) {
    return refineType(new RuleEnvironment(), null, e, newType);
  }
  
  public Result<Boolean> refineType(final RuleEnvironment _environment_, final WExpression e, final WollokType newType) {
    return refineType(_environment_, null, e, newType);
  }
  
  public Result<Boolean> refineType(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final WExpression e, final WollokType newType) {
    try {
    	return refineTypeInternal(_environment_, _trace_, e, newType);
    } catch (Exception _e_refineType) {
    	return resultForFailure(_e_refineType);
    }
  }
  
  public Boolean refineTypeSucceeded(final WExpression e, final WollokType newType) {
    return refineTypeSucceeded(new RuleEnvironment(), null, e, newType);
  }
  
  public Boolean refineTypeSucceeded(final RuleEnvironment _environment_, final WExpression e, final WollokType newType) {
    return refineTypeSucceeded(_environment_, null, e, newType);
  }
  
  public Boolean refineTypeSucceeded(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final WExpression e, final WollokType newType) {
    try {
    	refineTypeInternal(_environment_, _trace_, e, newType);
    	return true;
    } catch (Exception _e_refineType) {
    	return false;
    }
  }
  
  public Result<WollokType> queryTypeFor(final EObject r) {
    return queryTypeFor(new RuleEnvironment(), null, r);
  }
  
  public Result<WollokType> queryTypeFor(final RuleEnvironment _environment_, final EObject r) {
    return queryTypeFor(_environment_, null, r);
  }
  
  public Result<WollokType> queryTypeFor(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final EObject r) {
    try {
    	return queryTypeForInternal(_environment_, _trace_, r);
    } catch (Exception _e_queryTypeFor) {
    	return resultForFailure(_e_queryTypeFor);
    }
  }
  
  public Result<MessageType> queryMessageTypeForMethod(final WMethodDeclaration m) {
    return queryMessageTypeForMethod(new RuleEnvironment(), null, m);
  }
  
  public Result<MessageType> queryMessageTypeForMethod(final RuleEnvironment _environment_, final WMethodDeclaration m) {
    return queryMessageTypeForMethod(_environment_, null, m);
  }
  
  public Result<MessageType> queryMessageTypeForMethod(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final WMethodDeclaration m) {
    try {
    	return queryMessageTypeForMethodInternal(_environment_, _trace_, m);
    } catch (Exception _e_queryMessageTypeForMethod) {
    	return resultForFailure(_e_queryMessageTypeForMethod);
    }
  }
  
  protected Result<Boolean> inferTypesInternal(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final EObject obj) {
    try {
    	checkParamsNotNull(obj);
    	return inferTypesDispatcher.invoke(_environment_, _trace_, obj);
    } catch (Exception _e_inferTypes) {
    	sneakyThrowRuleFailedException(_e_inferTypes);
    	return null;
    }
  }
  
  protected void inferTypesThrowException(final String _error, final String _issue, final Exception _ex, final EObject obj, final ErrorInformation[] _errorInformations) throws RuleFailedException {
    throwRuleFailedException(_error, _issue, _ex, _errorInformations);
  }
  
  protected Result<WollokType> typeInternal(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final WExpression expression) {
    try {
    	checkParamsNotNull(expression);
    	return typeDispatcher.invoke(_environment_, _trace_, expression);
    } catch (Exception _e_type) {
    	sneakyThrowRuleFailedException(_e_type);
    	return null;
    }
  }
  
  protected void typeThrowException(final String _error, final String _issue, final Exception _ex, final WExpression expression, final ErrorInformation[] _errorInformations) throws RuleFailedException {
    throwRuleFailedException(_error, _issue, _ex, _errorInformations);
  }
  
  protected Result<Boolean> expectedTypeInternal(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final WExpression expression, final WollokType type) {
    try {
    	checkParamsNotNull(expression, type);
    	return expectedTypeDispatcher.invoke(_environment_, _trace_, expression, type);
    } catch (Exception _e_expectedType) {
    	sneakyThrowRuleFailedException(_e_expectedType);
    	return null;
    }
  }
  
  protected void expectedTypeThrowException(final String _error, final String _issue, final Exception _ex, final WExpression expression, final WollokType type, final ErrorInformation[] _errorInformations) throws RuleFailedException {
    throwRuleFailedException(_error, _issue, _ex, _errorInformations);
  }
  
  protected Result<WollokType> typeOfVarInternal(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final WReferenciable r) {
    try {
    	checkParamsNotNull(r);
    	return typeOfVarDispatcher.invoke(_environment_, _trace_, r);
    } catch (Exception _e_typeOfVar) {
    	sneakyThrowRuleFailedException(_e_typeOfVar);
    	return null;
    }
  }
  
  protected void typeOfVarThrowException(final String _error, final String _issue, final Exception _ex, final WReferenciable r, final ErrorInformation[] _errorInformations) throws RuleFailedException {
    throwRuleFailedException(_error, _issue, _ex, _errorInformations);
  }
  
  protected Result<MessageType> messageTypeInternal(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final WMemberFeatureCall call) {
    try {
    	checkParamsNotNull(call);
    	return messageTypeDispatcher.invoke(_environment_, _trace_, call);
    } catch (Exception _e_messageType) {
    	sneakyThrowRuleFailedException(_e_messageType);
    	return null;
    }
  }
  
  protected void messageTypeThrowException(final String _error, final String _issue, final Exception _ex, final WMemberFeatureCall call, final ErrorInformation[] _errorInformations) throws RuleFailedException {
    throwRuleFailedException(_error, _issue, _ex, _errorInformations);
  }
  
  protected Result<Boolean> refineTypeInternal(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final WExpression e, final WollokType newType) {
    try {
    	checkParamsNotNull(e, newType);
    	return refineTypeDispatcher.invoke(_environment_, _trace_, e, newType);
    } catch (Exception _e_refineType) {
    	sneakyThrowRuleFailedException(_e_refineType);
    	return null;
    }
  }
  
  protected void refineTypeThrowException(final String _error, final String _issue, final Exception _ex, final WExpression e, final WollokType newType, final ErrorInformation[] _errorInformations) throws RuleFailedException {
    throwRuleFailedException(_error, _issue, _ex, _errorInformations);
  }
  
  protected Result<WollokType> queryTypeForInternal(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final EObject r) {
    try {
    	checkParamsNotNull(r);
    	return queryTypeForDispatcher.invoke(_environment_, _trace_, r);
    } catch (Exception _e_queryTypeFor) {
    	sneakyThrowRuleFailedException(_e_queryTypeFor);
    	return null;
    }
  }
  
  protected void queryTypeForThrowException(final String _error, final String _issue, final Exception _ex, final EObject r, final ErrorInformation[] _errorInformations) throws RuleFailedException {
    throwRuleFailedException(_error, _issue, _ex, _errorInformations);
  }
  
  protected Result<MessageType> queryMessageTypeForMethodInternal(final RuleEnvironment _environment_, final RuleApplicationTrace _trace_, final WMethodDeclaration m) {
    try {
    	checkParamsNotNull(m);
    	return queryMessageTypeForMethodDispatcher.invoke(_environment_, _trace_, m);
    } catch (Exception _e_queryMessageTypeForMethod) {
    	sneakyThrowRuleFailedException(_e_queryMessageTypeForMethod);
    	return null;
    }
  }
  
  protected void queryMessageTypeForMethodThrowException(final String _error, final String _issue, final Exception _ex, final WMethodDeclaration m, final ErrorInformation[] _errorInformations) throws RuleFailedException {
    throwRuleFailedException(_error, _issue, _ex, _errorInformations);
  }
  
  protected Result<Boolean> inferTypesImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final EObject obj) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<Boolean> _result_ = applyRuleInferDefault(G, _subtrace_, obj);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("InferDefault") + stringRepForEnv(G) + " |- " + stringRep(obj);
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleInferDefault) {
    	inferTypesThrowException(ruleName("InferDefault") + stringRepForEnv(G) + " |- " + stringRep(obj),
    		INFERDEFAULT,
    		e_applyRuleInferDefault, obj, new ErrorInformation[] {new ErrorInformation(obj)});
    	return null;
    }
  }
  
  protected Result<Boolean> applyRuleInferDefault(final RuleEnvironment G, final RuleApplicationTrace _trace_, final EObject obj) throws RuleFailedException {
    EList<EObject> _eContents = obj.eContents();
    final Consumer<EObject> _function = new Consumer<EObject>() {
      public void accept(final EObject e) {
        /* G |- e */
        inferTypesInternal(G, _trace_, e);
      }
    };
    _eContents.forEach(_function);
    return new Result<Boolean>(true);
  }
  
  protected Result<Boolean> inferTypesImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WProgram obj) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<Boolean> _result_ = applyRuleInferWProgram(G, _subtrace_, obj);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("InferWProgram") + stringRepForEnv(G) + " |- " + stringRep(obj);
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleInferWProgram) {
    	inferTypesThrowException(ruleName("InferWProgram") + stringRepForEnv(G) + " |- " + stringRep(obj),
    		INFERWPROGRAM,
    		e_applyRuleInferWProgram, obj, new ErrorInformation[] {new ErrorInformation(obj)});
    	return null;
    }
  }
  
  protected Result<Boolean> applyRuleInferWProgram(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WProgram obj) throws RuleFailedException {
    EList<WExpression> _elements = obj.getElements();
    final Consumer<WExpression> _function = new Consumer<WExpression>() {
      public void accept(final WExpression e) {
        /* G |- e */
        inferTypesInternal(G, _trace_, e);
      }
    };
    _elements.forEach(_function);
    return new Result<Boolean>(true);
  }
  
  protected Result<Boolean> inferTypesImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WClass c) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<Boolean> _result_ = applyRuleInferClass(G, _subtrace_, c);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("InferClass") + stringRepForEnv(G) + " |- " + stringRep(c);
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleInferClass) {
    	inferTypesThrowException(ruleName("InferClass") + stringRepForEnv(G) + " |- " + stringRep(c),
    		INFERCLASS,
    		e_applyRuleInferClass, c, new ErrorInformation[] {new ErrorInformation(c)});
    	return null;
    }
  }
  
  protected Result<Boolean> applyRuleInferClass(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WClass c) throws RuleFailedException {
    Map<Object, Object> _environment = G.getEnvironment();
    boolean _containsKey = _environment.containsKey(c);
    boolean _not = (!_containsKey);
    if (_not) {
      WClass _parent = c.getParent();
      boolean _notEquals = (!Objects.equal(_parent, null));
      if (_notEquals) {
        /* G |- c.parent */
        WClass _parent_1 = c.getParent();
        inferTypesInternal(G, _trace_, _parent_1);
      }
      /* G ||- c >> var WollokType classType */
      WollokType classType = null;
      Result<WollokType> result = queryTypeForInternal(G, _trace_, c);
      checkAssignableTo(result.getFirst(), WollokType.class);
      classType = (WollokType) result.getFirst();
      
      Iterable<WVariableDeclaration> _variableDeclarations = WMethodContainerExtensions.variableDeclarations(c);
      for (final WVariableDeclaration p : _variableDeclarations) {
        /* G |- p : var WollokType pType */
        WollokType pType = null;
        Result<WollokType> result_1 = typeInternal(G, _trace_, p);
        checkAssignableTo(result_1.getFirst(), WollokType.class);
        pType = (WollokType) result_1.getFirst();
        
      }
      EList<WConstructor> _constructors = c.getConstructors();
      boolean _notEquals_1 = (!Objects.equal(_constructors, null));
      if (_notEquals_1) {
        EList<WConstructor> _constructors_1 = c.getConstructors();
        final Consumer<WConstructor> _function = new Consumer<WConstructor>() {
          public void accept(final WConstructor cons) {
            /* G |- cons */
            inferTypesInternal(G, _trace_, cons);
          }
        };
        _constructors_1.forEach(_function);
      }
      Iterable<WMethodDeclaration> _methods = WMethodContainerExtensions.methods(c);
      final Procedure1<Iterable<WMethodDeclaration>> _function_1 = new Procedure1<Iterable<WMethodDeclaration>>() {
        public void apply(final Iterable<WMethodDeclaration> it) {
          final Consumer<WMethodDeclaration> _function = new Consumer<WMethodDeclaration>() {
            public void accept(final WMethodDeclaration m) {
              G.add(m, WollokType.WAny);
            }
          };
          it.forEach(_function);
          final Consumer<WMethodDeclaration> _function_1 = new Consumer<WMethodDeclaration>() {
            public void accept(final WMethodDeclaration m) {
              /* G |- m */
              inferTypesInternal(G, _trace_, m);
            }
          };
          it.forEach(_function_1);
        }
      };
      ObjectExtensions.<Iterable<WMethodDeclaration>>operator_doubleArrow(_methods, _function_1);
    }
    return new Result<Boolean>(true);
  }
  
  protected Result<Boolean> inferTypesImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WConstructor c) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<Boolean> _result_ = applyRuleInferConstructor(G, _subtrace_, c);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("InferConstructor") + stringRepForEnv(G) + " |- " + stringRep(c);
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleInferConstructor) {
    	inferTypesThrowException(ruleName("InferConstructor") + stringRepForEnv(G) + " |- " + stringRep(c),
    		INFERCONSTRUCTOR,
    		e_applyRuleInferConstructor, c, new ErrorInformation[] {new ErrorInformation(c)});
    	return null;
    }
  }
  
  protected Result<Boolean> applyRuleInferConstructor(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WConstructor c) throws RuleFailedException {
    EList<WParameter> _parameters = c.getParameters();
    final Consumer<WParameter> _function = new Consumer<WParameter>() {
      public void accept(final WParameter p) {
        G.add(p, WollokType.WAny);
      }
    };
    _parameters.forEach(_function);
    /* G |- c.expression : var WollokType returnType */
    WExpression _expression = c.getExpression();
    WollokType returnType = null;
    Result<WollokType> result = typeInternal(G, _trace_, _expression);
    checkAssignableTo(result.getFirst(), WollokType.class);
    returnType = (WollokType) result.getFirst();
    
    return new Result<Boolean>(true);
  }
  
  protected Result<Boolean> inferTypesImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WMethodDeclaration m) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<Boolean> _result_ = applyRuleInferWMethod(G, _subtrace_, m);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("InferWMethod") + stringRepForEnv(G) + " |- " + stringRep(m);
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleInferWMethod) {
    	inferTypesThrowException(ruleName("InferWMethod") + stringRepForEnv(G) + " |- " + stringRep(m),
    		INFERWMETHOD,
    		e_applyRuleInferWMethod, m, new ErrorInformation[] {new ErrorInformation(m)});
    	return null;
    }
  }
  
  protected Result<Boolean> applyRuleInferWMethod(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WMethodDeclaration m) throws RuleFailedException {
    Map<Object, Object> _environment = G.getEnvironment();
    boolean _containsKey = _environment.containsKey(m);
    boolean _not = (!_containsKey);
    if (_not) {
      WollokType _xifexpression = null;
      boolean _isOverrides = m.isOverrides();
      if (_isOverrides) {
        WollokType _xblockexpression = null;
        {
          final WMethodDeclaration overriden = WMethodContainerExtensions.overridenMethod(m);
          /* G |- overriden */
          inferTypesInternal(G, _trace_, overriden);
          _xblockexpression = (this.<WollokType>env(G, overriden, WollokType.class));
        }
        _xifexpression = _xblockexpression;
      } else {
        _xifexpression = WollokType.WAny;
      }
      final WollokType initialType = _xifexpression;
      /* G.add(m, initialType) */
      if (!G.add(m, initialType)) {
        sneakyThrowRuleFailedException("G.add(m, initialType)");
      }
    }
    EList<WParameter> _parameters = m.getParameters();
    final Consumer<WParameter> _function = new Consumer<WParameter>() {
      public void accept(final WParameter p) {
        G.add(p, WollokType.WAny);
      }
    };
    _parameters.forEach(_function);
    WExpression _expression = m.getExpression();
    boolean _notEquals = (!Objects.equal(_expression, null));
    if (_notEquals) {
      final WollokType currentReturnType = this.<WollokType>env(G, m, WollokType.class);
      boolean _notEquals_1 = (!Objects.equal(currentReturnType, WollokType.WAny));
      if (_notEquals_1) {
        /* G |- m.expression << currentReturnType */
        WExpression _expression_1 = m.getExpression();
        refineTypeInternal(G, _trace_, _expression_1, currentReturnType);
      } else {
        /* G |- m.expression : var WollokType returnType */
        WExpression _expression_2 = m.getExpression();
        WollokType returnType = null;
        Result<WollokType> result = typeInternal(G, _trace_, _expression_2);
        checkAssignableTo(result.getFirst(), WollokType.class);
        returnType = (WollokType) result.getFirst();
        
        /* G.add(m, returnType) */
        if (!G.add(m, returnType)) {
          sneakyThrowRuleFailedException("G.add(m, returnType)");
        }
      }
      EList<WParameter> _parameters_1 = m.getParameters();
      final Function1<WParameter, Boolean> _function_1 = new Function1<WParameter, Boolean>() {
        public Boolean apply(final WParameter p) {
          WollokType _env = WollokDslTypeSystem.this.<WollokType>env(G, p, WollokType.class);
          return Boolean.valueOf(Objects.equal(_env, WollokType.WAny));
        }
      };
      Iterable<WParameter> _filter = IterableExtensions.<WParameter>filter(_parameters_1, _function_1);
      for (final WParameter p : _filter) {
        /* G |- p !> var WollokType paramType */
        WollokType paramType = null;
        Result<WollokType> result_1 = typeOfVarInternal(G, _trace_, p);
        checkAssignableTo(result_1.getFirst(), WollokType.class);
        paramType = (WollokType) result_1.getFirst();
        
        /* G.add(p, paramType) */
        if (!G.add(p, paramType)) {
          sneakyThrowRuleFailedException("G.add(p, paramType)");
        }
      }
    }
    return new Result<Boolean>(true);
  }
  
  protected Result<Boolean> inferTypesImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WClosure c) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<Boolean> _result_ = applyRuleInferWClosure(G, _subtrace_, c);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("InferWClosure") + stringRepForEnv(G) + " |- " + stringRep(c);
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleInferWClosure) {
    	inferTypesThrowException(ruleName("InferWClosure") + stringRepForEnv(G) + " |- " + stringRep(c),
    		INFERWCLOSURE,
    		e_applyRuleInferWClosure, c, new ErrorInformation[] {new ErrorInformation(c)});
    	return null;
    }
  }
  
  protected Result<Boolean> applyRuleInferWClosure(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WClosure c) throws RuleFailedException {
    EList<WParameter> _parameters = c.getParameters();
    final Consumer<WParameter> _function = new Consumer<WParameter>() {
      public void accept(final WParameter p) {
        G.add(p, WollokType.WAny);
      }
    };
    _parameters.forEach(_function);
    WExpression _expression = c.getExpression();
    this.inferTypes(G, _expression);
    return new Result<Boolean>(true);
  }
  
  protected Result<Boolean> inferTypesImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WExpression e) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<Boolean> _result_ = applyRuleInferExpression(G, _subtrace_, e);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("InferExpression") + stringRepForEnv(G) + " |- " + stringRep(e);
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleInferExpression) {
    	inferTypesThrowException(ruleName("InferExpression") + stringRepForEnv(G) + " |- " + stringRep(e),
    		INFEREXPRESSION,
    		e_applyRuleInferExpression, e, new ErrorInformation[] {new ErrorInformation(e)});
    	return null;
    }
  }
  
  protected Result<Boolean> applyRuleInferExpression(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WExpression e) throws RuleFailedException {
    /* G |- e : var WollokType typeOfE */
    WollokType typeOfE = null;
    Result<WollokType> result = typeInternal(G, _trace_, e);
    checkAssignableTo(result.getFirst(), WollokType.class);
    typeOfE = (WollokType) result.getFirst();
    
    return new Result<Boolean>(true);
  }
  
  protected Result<WollokType> queryTypeForImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final EObject e) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<WollokType> _result_ = applyRuleQueryTypeFor(G, _subtrace_, e);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("QueryTypeFor") + stringRepForEnv(G) + " ||- " + stringRep(e) + " >> " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleQueryTypeFor) {
    	queryTypeForThrowException(ruleName("QueryTypeFor") + stringRepForEnv(G) + " ||- " + stringRep(e) + " >> " + "WollokType",
    		QUERYTYPEFOR,
    		e_applyRuleQueryTypeFor, e, new ErrorInformation[] {new ErrorInformation(e)});
    	return null;
    }
  }
  
  protected Result<WollokType> applyRuleQueryTypeFor(final RuleEnvironment G, final RuleApplicationTrace _trace_, final EObject e) throws RuleFailedException {
    
    return new Result<WollokType>(_applyRuleQueryTypeFor_1(G, e));
  }
  
  private WollokType _applyRuleQueryTypeFor_1(final RuleEnvironment G, final EObject e) throws RuleFailedException {
    WollokType _env = this.<WollokType>env(G, e, WollokType.class);
    return _env;
  }
  
  protected Result<WollokType> queryTypeForImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WClass c) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<WollokType> _result_ = applyRuleQueryClassType(G, _subtrace_, c);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("QueryClassType") + stringRepForEnv(G) + " ||- " + stringRep(c) + " >> " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleQueryClassType) {
    	queryTypeForThrowException(ruleName("QueryClassType") + stringRepForEnv(G) + " ||- " + stringRep(c) + " >> " + "WollokType",
    		QUERYCLASSTYPE,
    		e_applyRuleQueryClassType, c, new ErrorInformation[] {new ErrorInformation(c)});
    	return null;
    }
  }
  
  protected Result<WollokType> applyRuleQueryClassType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WClass c) throws RuleFailedException {
    WollokType t = null; // output parameter
    Map<Object, Object> _environment = G.getEnvironment();
    boolean _containsKey = _environment.containsKey(c);
    if (_containsKey) {
      WollokType _env = this.<WollokType>env(G, c, WollokType.class);
      t = _env;
    } else {
      ClassBasedWollokType _classBasedWollokType = new ClassBasedWollokType(c, this, G);
      t = _classBasedWollokType;
      /* G.add(c, t) */
      if (!G.add(c, t)) {
        sneakyThrowRuleFailedException("G.add(c, t)");
      }
    }
    return new Result<WollokType>(t);
  }
  
  protected Result<MessageType> queryMessageTypeForMethodImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WMethodDeclaration m) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<MessageType> _result_ = applyRuleQueryMethodMessageType(G, _subtrace_, m);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("QueryMethodMessageType") + stringRepForEnv(G) + " ||- " + stringRep(m) + " :> " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleQueryMethodMessageType) {
    	queryMessageTypeForMethodThrowException(ruleName("QueryMethodMessageType") + stringRepForEnv(G) + " ||- " + stringRep(m) + " :> " + "MessageType",
    		QUERYMETHODMESSAGETYPE,
    		e_applyRuleQueryMethodMessageType, m, new ErrorInformation[] {new ErrorInformation(m)});
    	return null;
    }
  }
  
  protected Result<MessageType> applyRuleQueryMethodMessageType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WMethodDeclaration m) throws RuleFailedException {
    MessageType message = null; // output parameter
    final ArrayList<WollokType> paramTypes = CollectionLiterals.<WollokType>newArrayList();
    EList<WParameter> _parameters = m.getParameters();
    for (final WParameter p : _parameters) {
      /* G ||- p >> var WollokType paramType */
      WollokType paramType = null;
      Result<WollokType> result = queryTypeForInternal(G, _trace_, p);
      checkAssignableTo(result.getFirst(), WollokType.class);
      paramType = (WollokType) result.getFirst();
      
      /* paramTypes += paramType */
      if (!paramTypes.add(paramType)) {
        sneakyThrowRuleFailedException("paramTypes += paramType");
      }
    }
    /* G ||- m >> var WollokType returnType */
    WollokType returnType = null;
    Result<WollokType> result_1 = queryTypeForInternal(G, _trace_, m);
    checkAssignableTo(result_1.getFirst(), WollokType.class);
    returnType = (WollokType) result_1.getFirst();
    
    String _name = m.getName();
    MessageType _messageType = new MessageType(_name, paramTypes, returnType);
    message = _messageType;
    return new Result<MessageType>(message);
  }
  
  protected Result<WollokType> typeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WNumberLiteral num) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<WollokType> _result_ = applyRuleNumberLiteralType(G, _subtrace_, num);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("NumberLiteralType") + stringRepForEnv(G) + " |- " + stringRep(num) + " : " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleNumberLiteralType) {
    	typeThrowException(ruleName("NumberLiteralType") + stringRepForEnv(G) + " |- " + stringRep(num) + " : " + "IntType",
    		NUMBERLITERALTYPE,
    		e_applyRuleNumberLiteralType, num, new ErrorInformation[] {new ErrorInformation(num)});
    	return null;
    }
  }
  
  protected Result<WollokType> applyRuleNumberLiteralType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WNumberLiteral num) throws RuleFailedException {
    
    return new Result<WollokType>(_applyRuleNumberLiteralType_1(G, num));
  }
  
  private IntType _applyRuleNumberLiteralType_1(final RuleEnvironment G, final WNumberLiteral num) throws RuleFailedException {
    return WollokType.WInt;
  }
  
  protected Result<WollokType> typeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WStringLiteral str) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<WollokType> _result_ = applyRuleStringLiteralType(G, _subtrace_, str);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("StringLiteralType") + stringRepForEnv(G) + " |- " + stringRep(str) + " : " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleStringLiteralType) {
    	typeThrowException(ruleName("StringLiteralType") + stringRepForEnv(G) + " |- " + stringRep(str) + " : " + "StringType",
    		STRINGLITERALTYPE,
    		e_applyRuleStringLiteralType, str, new ErrorInformation[] {new ErrorInformation(str)});
    	return null;
    }
  }
  
  protected Result<WollokType> applyRuleStringLiteralType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WStringLiteral str) throws RuleFailedException {
    
    return new Result<WollokType>(_applyRuleStringLiteralType_1(G, str));
  }
  
  private StringType _applyRuleStringLiteralType_1(final RuleEnvironment G, final WStringLiteral str) throws RuleFailedException {
    return WollokType.WString;
  }
  
  protected Result<WollokType> typeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WBooleanLiteral num) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<WollokType> _result_ = applyRuleBooleanLiteralType(G, _subtrace_, num);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("BooleanLiteralType") + stringRepForEnv(G) + " |- " + stringRep(num) + " : " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleBooleanLiteralType) {
    	typeThrowException(ruleName("BooleanLiteralType") + stringRepForEnv(G) + " |- " + stringRep(num) + " : " + "BooleanType",
    		BOOLEANLITERALTYPE,
    		e_applyRuleBooleanLiteralType, num, new ErrorInformation[] {new ErrorInformation(num)});
    	return null;
    }
  }
  
  protected Result<WollokType> applyRuleBooleanLiteralType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WBooleanLiteral num) throws RuleFailedException {
    
    return new Result<WollokType>(_applyRuleBooleanLiteralType_1(G, num));
  }
  
  private BooleanType _applyRuleBooleanLiteralType_1(final RuleEnvironment G, final WBooleanLiteral num) throws RuleFailedException {
    return WollokType.WBoolean;
  }
  
  protected Result<WollokType> typeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WVariableReference variable) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<WollokType> _result_ = applyRuleVariableRefType(G, _subtrace_, variable);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("VariableRefType") + stringRepForEnv(G) + " |- " + stringRep(variable) + " : " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleVariableRefType) {
    	typeThrowException(ruleName("VariableRefType") + stringRepForEnv(G) + " |- " + stringRep(variable) + " : " + "WollokType",
    		VARIABLEREFTYPE,
    		e_applyRuleVariableRefType, variable, new ErrorInformation[] {new ErrorInformation(variable)});
    	return null;
    }
  }
  
  protected Result<WollokType> applyRuleVariableRefType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WVariableReference variable) throws RuleFailedException {
    
    return new Result<WollokType>(_applyRuleVariableRefType_1(G, variable));
  }
  
  private WollokType _applyRuleVariableRefType_1(final RuleEnvironment G, final WVariableReference variable) throws RuleFailedException {
    WollokType _xtrycatchfinallyexpression = null;
    try {
      WReferenciable _ref = variable.getRef();
      WollokType _env = this.<WollokType>env(G, _ref, WollokType.class);
      _xtrycatchfinallyexpression = _env;
    } catch (final Throwable _t) {
      if (_t instanceof RuleFailedException) {
        final RuleFailedException e = (RuleFailedException)_t;
        _xtrycatchfinallyexpression = WollokType.WAny;
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
    return _xtrycatchfinallyexpression;
  }
  
  protected Result<WollokType> typeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WConstructorCall call) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<WollokType> _result_ = applyRuleWConstructorCall(G, _subtrace_, call);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("WConstructorCall") + stringRepForEnv(G) + " |- " + stringRep(call) + " : " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleWConstructorCall) {
    	typeThrowException(ruleName("WConstructorCall") + stringRepForEnv(G) + " |- " + stringRep(call) + " : " + "WollokType",
    		WCONSTRUCTORCALL,
    		e_applyRuleWConstructorCall, call, new ErrorInformation[] {new ErrorInformation(call)});
    	return null;
    }
  }
  
  protected Result<WollokType> applyRuleWConstructorCall(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WConstructorCall call) throws RuleFailedException {
    WollokType t = null; // output parameter
    /* G |- call.classRef */
    WClass _classRef = call.getClassRef();
    inferTypesInternal(G, _trace_, _classRef);
    /* G ||- call.classRef >> t */
    WClass _classRef_1 = call.getClassRef();
    Result<WollokType> result = queryTypeForInternal(G, _trace_, _classRef_1);
    checkAssignableTo(result.getFirst(), WollokType.class);
    t = (WollokType) result.getFirst();
    
    return new Result<WollokType>(t);
  }
  
  protected Result<WollokType> typeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WThis thiz) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<WollokType> _result_ = applyRuleWThisType(G, _subtrace_, thiz);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("WThisType") + stringRepForEnv(G) + " |- " + stringRep(thiz) + " : " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleWThisType) {
    	typeThrowException(ruleName("WThisType") + stringRepForEnv(G) + " |- " + stringRep(thiz) + " : " + "WollokType",
    		WTHISTYPE,
    		e_applyRuleWThisType, thiz, new ErrorInformation[] {new ErrorInformation(thiz)});
    	return null;
    }
  }
  
  protected Result<WollokType> applyRuleWThisType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WThis thiz) throws RuleFailedException {
    WollokType t = null; // output parameter
    final WMethodDeclaration containingMethod = WollokModelExtensions.method(thiz);
    boolean _equals = Objects.equal(containingMethod, null);
    if (_equals) {
      t = WollokType.WAny;
    } else {
      final WMethodContainer context = WollokModelExtensions.declaringContext(containingMethod);
      if ((context instanceof WClass)) {
        /* G ||- context >> t */
        Result<WollokType> result = queryTypeForInternal(G, _trace_, ((WClass)context));
        checkAssignableTo(result.getFirst(), WollokType.class);
        t = (WollokType) result.getFirst();
        
      } else {
        /* G |- (context as WObjectLiteral) : t */
        Result<WollokType> result_1 = typeInternal(G, _trace_, ((WObjectLiteral) context));
        checkAssignableTo(result_1.getFirst(), WollokType.class);
        t = (WollokType) result_1.getFirst();
        
      }
    }
    return new Result<WollokType>(t);
  }
  
  protected Result<WollokType> typeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WSuperInvocation sup) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<WollokType> _result_ = applyRuleSuperCallType(G, _subtrace_, sup);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("SuperCallType") + stringRepForEnv(G) + " |- " + stringRep(sup) + " : " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleSuperCallType) {
    	typeThrowException(ruleName("SuperCallType") + stringRepForEnv(G) + " |- " + stringRep(sup) + " : " + "WollokType",
    		SUPERCALLTYPE,
    		e_applyRuleSuperCallType, sup, new ErrorInformation[] {new ErrorInformation(sup)});
    	return null;
    }
  }
  
  protected Result<WollokType> applyRuleSuperCallType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WSuperInvocation sup) throws RuleFailedException {
    WollokType t = null; // output parameter
    final WMethodDeclaration overriden = WMethodContainerExtensions.superMethod(sup);
    Map<Object, Object> _environment = G.getEnvironment();
    boolean _containsKey = _environment.containsKey(overriden);
    if (_containsKey) {
      WollokType _env = this.<WollokType>env(G, overriden, WollokType.class);
      t = _env;
    } else {
      /* G |- overriden */
      inferTypesInternal(G, _trace_, overriden);
      WollokType _env_1 = this.<WollokType>env(G, overriden, WollokType.class);
      t = _env_1;
    }
    return new Result<WollokType>(t);
  }
  
  protected Result<WollokType> typeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WBlockExpression exps) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<WollokType> _result_ = applyRuleWBlockExpressionType(G, _subtrace_, exps);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("WBlockExpressionType") + stringRepForEnv(G) + " |- " + stringRep(exps) + " : " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleWBlockExpressionType) {
    	typeThrowException(ruleName("WBlockExpressionType") + stringRepForEnv(G) + " |- " + stringRep(exps) + " : " + "WollokType",
    		WBLOCKEXPRESSIONTYPE,
    		e_applyRuleWBlockExpressionType, exps, new ErrorInformation[] {new ErrorInformation(exps)});
    	return null;
    }
  }
  
  protected Result<WollokType> applyRuleWBlockExpressionType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WBlockExpression exps) throws RuleFailedException {
    WollokType t = null; // output parameter
    WollokType _xifexpression = null;
    EList<WExpression> _expressions = exps.getExpressions();
    boolean _isEmpty = _expressions.isEmpty();
    if (_isEmpty) {
      _xifexpression = WollokType.WVoid;
    } else {
      WollokType _xblockexpression = null;
      {
        WollokType lastType = null;
        EList<WExpression> _expressions_1 = exps.getExpressions();
        for (final WExpression e : _expressions_1) {
          /* G |- e : var WollokType expType */
          WollokType expType = null;
          Result<WollokType> result = typeInternal(G, _trace_, e);
          checkAssignableTo(result.getFirst(), WollokType.class);
          expType = (WollokType) result.getFirst();
          
          lastType = expType;
        }
        _xblockexpression = (lastType);
      }
      _xifexpression = _xblockexpression;
    }
    t = _xifexpression;
    return new Result<WollokType>(t);
  }
  
  protected Result<WollokType> typeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WBinaryOperation op) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<WollokType> _result_ = applyRuleAdditionType(G, _subtrace_, op);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("AdditionType") + stringRepForEnv(G) + " |- " + stringRep(op) + " : " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleAdditionType) {
    	typeThrowException(ruleName("AdditionType") + stringRepForEnv(G) + " |- " + stringRep(op) + " : " + "WollokType",
    		ADDITIONTYPE,
    		e_applyRuleAdditionType, op, new ErrorInformation[] {new ErrorInformation(op)});
    	return null;
    }
  }
  
  protected Result<WollokType> applyRuleAdditionType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WBinaryOperation op) throws RuleFailedException {
    WollokType returnType = null; // output parameter
    WollokType t = null;
    String _feature = op.getFeature();
    boolean _contains = Collections.<String>unmodifiableList(CollectionLiterals.<String>newArrayList("&&", "||")).contains(_feature);
    if (_contains) {
      returnType = WollokType.WBoolean;
      t = WollokType.WBoolean;
    } else {
      String _feature_1 = op.getFeature();
      boolean _contains_1 = Collections.<String>unmodifiableList(CollectionLiterals.<String>newArrayList("==", "!=", "===", "<", "<=", ">", ">=")).contains(_feature_1);
      if (_contains_1) {
        returnType = WollokType.WBoolean;
        t = WollokType.WAny;
      } else {
        returnType = WollokType.WInt;
        t = WollokType.WInt;
      }
    }
    /* G |- op.leftOperand : var WollokType leftType */
    WExpression _leftOperand = op.getLeftOperand();
    WollokType leftType = null;
    Result<WollokType> result = typeInternal(G, _trace_, _leftOperand);
    checkAssignableTo(result.getFirst(), WollokType.class);
    leftType = (WollokType) result.getFirst();
    
    boolean _equals = Objects.equal(leftType, WollokType.WAny);
    if (_equals) {
      /* G |- op.leftOperand << t */
      WExpression _leftOperand_1 = op.getLeftOperand();
      refineTypeInternal(G, _trace_, _leftOperand_1, t);
    } else {
      /* G |- op.leftOperand ~~ t or fail error "Uncompatible operand type: " + type(G, op.leftOperand).first + " but expecting: " + t source op feature WollokDslPackage.Literals.WBINARY_OPERATION__LEFT_OPERAND */
      {
        RuleFailedException previousFailure = null;
        try {
          /* G |- op.leftOperand ~~ t */
          WExpression _leftOperand_2 = op.getLeftOperand();
          expectedTypeInternal(G, _trace_, _leftOperand_2, t);
        } catch (Exception e) {
          previousFailure = extractRuleFailedException(e);
          /* fail error "Uncompatible operand type: " + type(G, op.leftOperand).first + " but expecting: " + t source op feature WollokDslPackage.Literals.WBINARY_OPERATION__LEFT_OPERAND */
          WExpression _leftOperand_3 = op.getLeftOperand();
          Result<WollokType> _type = this.type(G, _leftOperand_3);
          WollokType _first = _type.getFirst();
          String _plus = ("Uncompatible operand type: " + _first);
          String _plus_1 = (_plus + " but expecting: ");
          String _plus_2 = (_plus_1 + t);
          String error = _plus_2;
          EObject source = op;
          EStructuralFeature feature = WollokDslPackage.Literals.WBINARY_OPERATION__LEFT_OPERAND;
          throwForExplicitFail(error, new ErrorInformation(source, feature));
        }
      }
    }
    /* G |- op.rightOperand : var WollokType rightType */
    WExpression _rightOperand = op.getRightOperand();
    WollokType rightType = null;
    Result<WollokType> result_1 = typeInternal(G, _trace_, _rightOperand);
    checkAssignableTo(result_1.getFirst(), WollokType.class);
    rightType = (WollokType) result_1.getFirst();
    
    boolean _equals_1 = Objects.equal(rightType, WollokType.WAny);
    if (_equals_1) {
      /* G |- op.rightOperand << t */
      WExpression _rightOperand_1 = op.getRightOperand();
      refineTypeInternal(G, _trace_, _rightOperand_1, t);
    } else {
      /* G |- op.rightOperand ~~ t or fail error "Uncompatible operand type: " + type(G, op.rightOperand).first + " but expecting: " + t source op feature WollokDslPackage.Literals.WBINARY_OPERATION__RIGHT_OPERAND */
      {
        RuleFailedException previousFailure = null;
        try {
          /* G |- op.rightOperand ~~ t */
          WExpression _rightOperand_2 = op.getRightOperand();
          expectedTypeInternal(G, _trace_, _rightOperand_2, t);
        } catch (Exception e_1) {
          previousFailure = extractRuleFailedException(e_1);
          /* fail error "Uncompatible operand type: " + type(G, op.rightOperand).first + " but expecting: " + t source op feature WollokDslPackage.Literals.WBINARY_OPERATION__RIGHT_OPERAND */
          WExpression _rightOperand_3 = op.getRightOperand();
          Result<WollokType> _type_1 = this.type(G, _rightOperand_3);
          WollokType _first_1 = _type_1.getFirst();
          String _plus_3 = ("Uncompatible operand type: " + _first_1);
          String _plus_4 = (_plus_3 + " but expecting: ");
          String _plus_5 = (_plus_4 + t);
          String error_1 = _plus_5;
          EObject source_1 = op;
          EStructuralFeature feature_1 = WollokDslPackage.Literals.WBINARY_OPERATION__RIGHT_OPERAND;
          throwForExplicitFail(error_1, new ErrorInformation(source_1, feature_1));
        }
      }
    }
    return new Result<WollokType>(returnType);
  }
  
  protected Result<Boolean> refineTypeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WVariableReference ref, final WollokType newType) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<Boolean> _result_ = applyRuleRefineVariableRef(G, _subtrace_, ref, newType);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("RefineVariableRef") + stringRepForEnv(G) + " |- " + stringRep(ref) + " << " + stringRep(newType);
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleRefineVariableRef) {
    	refineTypeThrowException(ruleName("RefineVariableRef") + stringRepForEnv(G) + " |- " + stringRep(ref) + " << " + stringRep(newType),
    		REFINEVARIABLEREF,
    		e_applyRuleRefineVariableRef, ref, newType, new ErrorInformation[] {new ErrorInformation(ref)});
    	return null;
    }
  }
  
  protected Result<Boolean> applyRuleRefineVariableRef(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WVariableReference ref, final WollokType newType) throws RuleFailedException {
    boolean _or = false;
    Map<Object, Object> _environment = G.getEnvironment();
    boolean _containsKey = _environment.containsKey(ref);
    boolean _not = (!_containsKey);
    if (_not) {
      _or = true;
    } else {
      WollokType _env = this.<WollokType>env(G, ref, WollokType.class);
      boolean _equals = Objects.equal(_env, WollokType.WAny);
      _or = _equals;
    }
    if (_or) {
      WReferenciable _ref = ref.getRef();
      /* G.add(ref.ref, newType) */
      if (!G.add(_ref, newType)) {
        sneakyThrowRuleFailedException("G.add(ref.ref, newType)");
      }
    } else {
      /* G |- ref ~~ newType */
      expectedTypeInternal(G, _trace_, ref, newType);
    }
    return new Result<Boolean>(true);
  }
  
  protected Result<Boolean> refineTypeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WBlockExpression b, final WollokType newType) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<Boolean> _result_ = applyRuleRefineBlockType(G, _subtrace_, b, newType);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("RefineBlockType") + stringRepForEnv(G) + " |- " + stringRep(b) + " << " + stringRep(newType);
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleRefineBlockType) {
    	refineTypeThrowException(ruleName("RefineBlockType") + stringRepForEnv(G) + " |- " + stringRep(b) + " << " + stringRep(newType),
    		REFINEBLOCKTYPE,
    		e_applyRuleRefineBlockType, b, newType, new ErrorInformation[] {new ErrorInformation(b)});
    	return null;
    }
  }
  
  protected Result<Boolean> applyRuleRefineBlockType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WBlockExpression b, final WollokType newType) throws RuleFailedException {
    EList<WExpression> _expressions = b.getExpressions();
    boolean _isEmpty = _expressions.isEmpty();
    boolean _not = (!_isEmpty);
    if (_not) {
      /* G |- b.expressions.last << newType */
      EList<WExpression> _expressions_1 = b.getExpressions();
      WExpression _last = IterableExtensions.<WExpression>last(_expressions_1);
      refineTypeInternal(G, _trace_, _last, newType);
    }
    return new Result<Boolean>(true);
  }
  
  protected Result<Boolean> refineTypeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WMemberFeatureCall call, final WollokType newType) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<Boolean> _result_ = applyRuleRefineMethodReturnType(G, _subtrace_, call, newType);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("RefineMethodReturnType") + stringRepForEnv(G) + " |- " + stringRep(call) + " << " + stringRep(newType);
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleRefineMethodReturnType) {
    	refineTypeThrowException(ruleName("RefineMethodReturnType") + stringRepForEnv(G) + " |- " + stringRep(call) + " << " + stringRep(newType),
    		REFINEMETHODRETURNTYPE,
    		e_applyRuleRefineMethodReturnType, call, newType, new ErrorInformation[] {new ErrorInformation(call)});
    	return null;
    }
  }
  
  protected Result<Boolean> applyRuleRefineMethodReturnType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WMemberFeatureCall call, final WollokType newType) throws RuleFailedException {
    WExpression _memberCallTarget = call.getMemberCallTarget();
    if ((_memberCallTarget instanceof WThis)) {
      /* G |- call.memberCallTarget : var WollokType thisType */
      WExpression _memberCallTarget_1 = call.getMemberCallTarget();
      WollokType thisType = null;
      Result<WollokType> result = typeInternal(G, _trace_, _memberCallTarget_1);
      checkAssignableTo(result.getFirst(), WollokType.class);
      thisType = (WollokType) result.getFirst();
      
      if ((thisType instanceof ClassBasedWollokType)) {
        /* G |- call ~> var MessageType typeOfMessage */
        MessageType typeOfMessage = null;
        Result<MessageType> result_1 = messageTypeInternal(G, _trace_, call);
        checkAssignableTo(result_1.getFirst(), MessageType.class);
        typeOfMessage = (MessageType) result_1.getFirst();
        
        WMethodDeclaration method = ((ClassBasedWollokType)thisType).lookupMethod(typeOfMessage);
        boolean _and = false;
        boolean _notEquals = (!Objects.equal(method, null));
        if (!_notEquals) {
          _and = false;
        } else {
          WollokType _resolveReturnType = ((ClassBasedWollokType)thisType).resolveReturnType(typeOfMessage, this, G);
          boolean _equals = Objects.equal(_resolveReturnType, WollokType.WAny);
          _and = _equals;
        }
        if (_and) {
          boolean _add = G.add(method, newType);
          /* G.add(method, newType) */
          if (!_add) {
            sneakyThrowRuleFailedException("G.add(method, newType)");
          }
          /* G |- method */
          inferTypesInternal(G, _trace_, method);
          /* G |- call : var WollokType t */
          WollokType t = null;
          Result<WollokType> result_2 = typeInternal(G, _trace_, call);
          checkAssignableTo(result_2.getFirst(), WollokType.class);
          t = (WollokType) result_2.getFirst();
          
        }
      }
    }
    return new Result<Boolean>(true);
  }
  
  protected Result<Boolean> refineTypeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WExpression e, final WollokType newType) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<Boolean> _result_ = applyRuleRefineOther(G, _subtrace_, e, newType);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("RefineOther") + stringRepForEnv(G) + " |- " + stringRep(e) + " << " + stringRep(newType);
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleRefineOther) {
    	refineTypeThrowException(ruleName("RefineOther") + stringRepForEnv(G) + " |- " + stringRep(e) + " << " + stringRep(newType),
    		REFINEOTHER,
    		e_applyRuleRefineOther, e, newType, new ErrorInformation[] {new ErrorInformation(e)});
    	return null;
    }
  }
  
  protected Result<Boolean> applyRuleRefineOther(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WExpression e, final WollokType newType) throws RuleFailedException {
    /* G.add(e, newType) */
    if (!G.add(e, newType)) {
      sneakyThrowRuleFailedException("G.add(e, newType)");
    }
    return new Result<Boolean>(true);
  }
  
  protected Result<WollokType> typeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WVariableDeclaration decl) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<WollokType> _result_ = applyRuleVariableDeclarationType(G, _subtrace_, decl);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("VariableDeclarationType") + stringRepForEnv(G) + " |- " + stringRep(decl) + " : " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleVariableDeclarationType) {
    	typeThrowException(ruleName("VariableDeclarationType") + stringRepForEnv(G) + " |- " + stringRep(decl) + " : " + "VoidType",
    		VARIABLEDECLARATIONTYPE,
    		e_applyRuleVariableDeclarationType, decl, new ErrorInformation[] {new ErrorInformation(decl)});
    	return null;
    }
  }
  
  protected Result<WollokType> applyRuleVariableDeclarationType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WVariableDeclaration decl) throws RuleFailedException {
    WExpression _right = decl.getRight();
    boolean _notEquals = (!Objects.equal(_right, null));
    if (_notEquals) {
      /* G |- decl.right : var WollokType t */
      WExpression _right_1 = decl.getRight();
      WollokType t = null;
      Result<WollokType> result = typeInternal(G, _trace_, _right_1);
      checkAssignableTo(result.getFirst(), WollokType.class);
      t = (WollokType) result.getFirst();
      
      WVariable _variable = decl.getVariable();
      /* G.add(decl.variable, t) */
      if (!G.add(_variable, t)) {
        sneakyThrowRuleFailedException("G.add(decl.variable, t)");
      }
    } else {
      WVariable _variable_1 = decl.getVariable();
      /* G.add(decl.variable, WAny) */
      if (!G.add(_variable_1, WollokType.WAny)) {
        sneakyThrowRuleFailedException("G.add(decl.variable, WAny)");
      }
    }
    return new Result<WollokType>(_applyRuleVariableDeclarationType_1(G, decl));
  }
  
  private VoidType _applyRuleVariableDeclarationType_1(final RuleEnvironment G, final WVariableDeclaration decl) throws RuleFailedException {
    return WollokType.WVoid;
  }
  
  protected Result<WollokType> typeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WAssignment assignment) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<WollokType> _result_ = applyRuleAssignmentType(G, _subtrace_, assignment);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("AssignmentType") + stringRepForEnv(G) + " |- " + stringRep(assignment) + " : " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleAssignmentType) {
    	typeThrowException(ruleName("AssignmentType") + stringRepForEnv(G) + " |- " + stringRep(assignment) + " : " + "VoidType",
    		ASSIGNMENTTYPE,
    		e_applyRuleAssignmentType, assignment, new ErrorInformation[] {new ErrorInformation(assignment)});
    	return null;
    }
  }
  
  protected Result<WollokType> applyRuleAssignmentType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WAssignment assignment) throws RuleFailedException {
    /* G |- assignment.value : var WollokType valueType */
    WExpression _value = assignment.getValue();
    WollokType valueType = null;
    Result<WollokType> result = typeInternal(G, _trace_, _value);
    checkAssignableTo(result.getFirst(), WollokType.class);
    valueType = (WollokType) result.getFirst();
    
    WVariableReference _feature = assignment.getFeature();
    WReferenciable _ref = _feature.getRef();
    WollokType expectedType = this.<WollokType>env(G, _ref, WollokType.class);
    boolean _equals = Objects.equal(valueType, WollokType.WAny);
    if (_equals) {
      /* G |- assignment.value << expectedType */
      WExpression _value_1 = assignment.getValue();
      refineTypeInternal(G, _trace_, _value_1, expectedType);
    } else {
      try {
        WollokType refinedType = valueType.refine(expectedType, G);
        WVariableReference _feature_1 = assignment.getFeature();
        WReferenciable _ref_1 = _feature_1.getRef();
        /* G.add(assignment.^feature.ref, refinedType) */
        if (!G.add(_ref_1, refinedType)) {
          sneakyThrowRuleFailedException("G.add(assignment.^feature.ref, refinedType)");
        }
      } catch (final Throwable _t) {
        if (_t instanceof TypeSystemException) {
          final TypeSystemException e = (TypeSystemException)_t;
          /* fail error assignment.value.stringRep + " of type " + valueType + " is not a valid value for variable " + assignment.^feature.ref.name + " of type " + expectedType source assignment feature WollokDslPackage.Literals.WASSIGNMENT__VALUE */
          WExpression _value_2 = assignment.getValue();
          String _stringRep = this.stringRep(_value_2);
          String _plus = (_stringRep + " of type ");
          String _plus_1 = (_plus + valueType);
          String _plus_2 = (_plus_1 + " is not a valid value for variable ");
          WVariableReference _feature_2 = assignment.getFeature();
          WReferenciable _ref_2 = _feature_2.getRef();
          String _name = _ref_2.getName();
          String _plus_3 = (_plus_2 + _name);
          String _plus_4 = (_plus_3 + " of type ");
          String _plus_5 = (_plus_4 + expectedType);
          String error = _plus_5;
          EObject source = assignment;
          EStructuralFeature feature = WollokDslPackage.Literals.WASSIGNMENT__VALUE;
          throwForExplicitFail(error, new ErrorInformation(source, feature));
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      }
    }
    return new Result<WollokType>(_applyRuleAssignmentType_1(G, assignment));
  }
  
  private VoidType _applyRuleAssignmentType_1(final RuleEnvironment G, final WAssignment assignment) throws RuleFailedException {
    return WollokType.WVoid;
  }
  
  protected Result<WollokType> typeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WMemberFeatureCall featureCall) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<WollokType> _result_ = applyRuleMemberFeatureCallType(G, _subtrace_, featureCall);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("MemberFeatureCallType") + stringRepForEnv(G) + " |- " + stringRep(featureCall) + " : " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleMemberFeatureCallType) {
    	typeThrowException(ruleName("MemberFeatureCallType") + stringRepForEnv(G) + " |- " + stringRep(featureCall) + " : " + "WollokType",
    		MEMBERFEATURECALLTYPE,
    		e_applyRuleMemberFeatureCallType, featureCall, new ErrorInformation[] {new ErrorInformation(featureCall)});
    	return null;
    }
  }
  
  protected Result<WollokType> applyRuleMemberFeatureCallType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WMemberFeatureCall featureCall) throws RuleFailedException {
    WollokType returnType = null; // output parameter
    /* G |- featureCall.memberCallTarget : var WollokType receiverType */
    WExpression _memberCallTarget = featureCall.getMemberCallTarget();
    WollokType receiverType = null;
    Result<WollokType> result = typeInternal(G, _trace_, _memberCallTarget);
    checkAssignableTo(result.getFirst(), WollokType.class);
    receiverType = (WollokType) result.getFirst();
    
    ArrayList<WollokType> argumentTypes = CollectionLiterals.<WollokType>newArrayList();
    EList<WExpression> _memberCallArguments = featureCall.getMemberCallArguments();
    for (final WExpression arg : _memberCallArguments) {
      /* G |- arg : var WollokType argumentType */
      WollokType argumentType = null;
      Result<WollokType> result_1 = typeInternal(G, _trace_, arg);
      checkAssignableTo(result_1.getFirst(), WollokType.class);
      argumentType = (WollokType) result_1.getFirst();
      
      /* argumentTypes += argumentType */
      if (!argumentTypes.add(argumentType)) {
        sneakyThrowRuleFailedException("argumentTypes += argumentType");
      }
    }
    String _feature = featureCall.getFeature();
    MessageType message = new MessageType(_feature, argumentTypes, WollokType.WAny);
    boolean _understandsMessage = receiverType.understandsMessage(message);
    if (_understandsMessage) {
      if ((receiverType instanceof ClassBasedWollokType)) {
        WMethodDeclaration method = ((ClassBasedWollokType)receiverType).lookupMethod(message);
        /* G |- method.declaringContext */
        WMethodContainer _declaringContext = WollokModelExtensions.declaringContext(method);
        inferTypesInternal(G, _trace_, _declaringContext);
        int i = 0;
        EList<WParameter> _parameters = method.getParameters();
        for (final WParameter param : _parameters) {
          WollokType paramType = this.<WollokType>env(G, param, WollokType.class);
          boolean _notEquals = (!Objects.equal(paramType, WollokType.WAny));
          if (_notEquals) {
            /* G |- featureCall.memberCallArguments.get(i) << paramType */
            EList<WExpression> _memberCallArguments_1 = featureCall.getMemberCallArguments();
            WExpression _get = _memberCallArguments_1.get(i);
            refineTypeInternal(G, _trace_, _get, paramType);
          }
          i++;
        }
      }
      WollokType _resolveReturnType = receiverType.resolveReturnType(message, this, G);
      returnType = _resolveReturnType;
    } else {
      /* fail error "An object of type " + receiverType + " does not understand the message " + featureCall.^feature + "(" + argumentTypes.join(",") + ")" source featureCall */
      String _feature_1 = featureCall.getFeature();
      String _plus = ((("An object of type " + receiverType) + " does not understand the message ") + _feature_1);
      String _plus_1 = (_plus + "(");
      String _join = IterableExtensions.join(argumentTypes, ",");
      String _plus_2 = (_plus_1 + _join);
      String _plus_3 = (_plus_2 + ")");
      String error = _plus_3;
      EObject source = featureCall;
      throwForExplicitFail(error, new ErrorInformation(source, null));
    }
    return new Result<WollokType>(returnType);
  }
  
  protected Result<WollokType> typeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WExpression e) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<WollokType> _result_ = applyRuleIgnore(G, _subtrace_, e);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("Ignore") + stringRepForEnv(G) + " |- " + stringRep(e) + " : " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleIgnore) {
    	typeThrowException(ruleName("Ignore") + stringRepForEnv(G) + " |- " + stringRep(e) + " : " + "VoidType",
    		IGNORE,
    		e_applyRuleIgnore, e, new ErrorInformation[] {new ErrorInformation(e)});
    	return null;
    }
  }
  
  protected Result<WollokType> applyRuleIgnore(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WExpression e) throws RuleFailedException {
    String _stringRep = this.stringRep(e);
    String _plus = ("Ignoring type check for " + _stringRep);
    String _plus_1 = (_plus + " of class ");
    Class<? extends WExpression> _class = e.getClass();
    String _simpleName = _class.getSimpleName();
    String _plus_2 = (_plus_1 + _simpleName);
    System.out.println(_plus_2);
    return new Result<WollokType>(_applyRuleIgnore_1(G, e));
  }
  
  private VoidType _applyRuleIgnore_1(final RuleEnvironment G, final WExpression e) throws RuleFailedException {
    return WollokType.WVoid;
  }
  
  protected Result<Boolean> expectedTypeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WExpression expression, final BasicType expectedType) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<Boolean> _result_ = applyRuleExpectedType(G, _subtrace_, expression, expectedType);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("ExpectedType") + stringRepForEnv(G) + " |- " + stringRep(expression) + " ~~ " + stringRep(expectedType);
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleExpectedType) {
    	expectedTypeThrowException(ruleName("ExpectedType") + stringRepForEnv(G) + " |- " + stringRep(expression) + " ~~ " + stringRep(expectedType),
    		EXPECTEDTYPE,
    		e_applyRuleExpectedType, expression, expectedType, new ErrorInformation[] {new ErrorInformation(expression)});
    	return null;
    }
  }
  
  protected Result<Boolean> applyRuleExpectedType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WExpression expression, final BasicType expectedType) throws RuleFailedException {
    /* G |- expression : var WollokType type */
    WollokType type = null;
    Result<WollokType> result = typeInternal(G, _trace_, expression);
    checkAssignableTo(result.getFirst(), WollokType.class);
    type = (WollokType) result.getFirst();
    
    try {
      expectedType.acceptAssignment(type);
    } catch (final Throwable _t) {
      if (_t instanceof TypeSystemException) {
        final TypeSystemException e = (TypeSystemException)_t;
        /* fail error expectedType.name + " expected but found " + expression.stringRep + " of type " + type source expression */
        String _name = expectedType.getName();
        String _plus = (_name + " expected but found ");
        String _stringRep = this.stringRep(expression);
        String _plus_1 = (_plus + _stringRep);
        String _plus_2 = (_plus_1 + " of type ");
        String _plus_3 = (_plus_2 + type);
        String error = _plus_3;
        EObject source = expression;
        throwForExplicitFail(error, new ErrorInformation(source, null));
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
    return new Result<Boolean>(true);
  }
  
  protected Result<WollokType> typeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WObjectLiteral obj) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<WollokType> _result_ = applyRuleObjectLiteralType(G, _subtrace_, obj);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("ObjectLiteralType") + stringRepForEnv(G) + " |- " + stringRep(obj) + " : " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleObjectLiteralType) {
    	typeThrowException(ruleName("ObjectLiteralType") + stringRepForEnv(G) + " |- " + stringRep(obj) + " : " + "ObjectLiteralWollokType",
    		OBJECTLITERALTYPE,
    		e_applyRuleObjectLiteralType, obj, new ErrorInformation[] {new ErrorInformation(obj)});
    	return null;
    }
  }
  
  protected Result<WollokType> applyRuleObjectLiteralType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WObjectLiteral obj) throws RuleFailedException {
    ObjectLiteralWollokType t = null; // output parameter
    Map<Object, Object> _environment = G.getEnvironment();
    boolean _containsKey = _environment.containsKey(obj);
    if (_containsKey) {
      ObjectLiteralWollokType _env = this.<ObjectLiteralWollokType>env(G, obj, ObjectLiteralWollokType.class);
      t = _env;
    } else {
      ObjectLiteralWollokType newType = new ObjectLiteralWollokType(obj, this, G);
      boolean _add = G.add(obj, newType);
      /* G.add(obj, newType) */
      if (!_add) {
        sneakyThrowRuleFailedException("G.add(obj, newType)");
      }
      Iterable<WVariableDeclaration> _variableDeclarations = WMethodContainerExtensions.variableDeclarations(obj);
      for (final WVariableDeclaration v : _variableDeclarations) {
        /* G |- v : var WollokType varType */
        WollokType varType = null;
        Result<WollokType> result = typeInternal(G, _trace_, v);
        checkAssignableTo(result.getFirst(), WollokType.class);
        varType = (WollokType) result.getFirst();
        
      }
      Iterable<WMethodDeclaration> _methods = WMethodContainerExtensions.methods(obj);
      final Consumer<WMethodDeclaration> _function = new Consumer<WMethodDeclaration>() {
        public void accept(final WMethodDeclaration it) {
          /* G |- it */
          inferTypesInternal(G, _trace_, it);
        }
      };
      _methods.forEach(_function);
      t = newType;
    }
    return new Result<WollokType>(t);
  }
  
  protected Result<WollokType> typeOfVarImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WReferenciable p) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<WollokType> _result_ = applyRuleWParametersType(G, _subtrace_, p);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("WParametersType") + stringRepForEnv(G) + " |- " + stringRep(p) + " !> " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleWParametersType) {
    	typeOfVarThrowException(ruleName("WParametersType") + stringRepForEnv(G) + " |- " + stringRep(p) + " !> " + "WollokType",
    		WPARAMETERSTYPE,
    		e_applyRuleWParametersType, p, new ErrorInformation[] {new ErrorInformation(p)});
    	return null;
    }
  }
  
  protected Result<WollokType> applyRuleWParametersType(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WReferenciable p) throws RuleFailedException {
    WollokType t = null; // output parameter
    final ArrayList<MessageType> messagesTypes = CollectionLiterals.<MessageType>newArrayList();
    Iterable<WMemberFeatureCall> _allMessageSent = WollokModelExtensions.allMessageSent(p);
    List<WMemberFeatureCall> _list = IterableExtensions.<WMemberFeatureCall>toList(_allMessageSent);
    for (final WMemberFeatureCall m : _list) {
      /* G |- m ~> var MessageType messageType */
      MessageType messageType = null;
      Result<MessageType> result = messageTypeInternal(G, _trace_, m);
      checkAssignableTo(result.getFirst(), MessageType.class);
      messageType = (MessageType) result.getFirst();
      
      boolean _contains = messagesTypes.contains(messageType);
      boolean _not = (!_contains);
      if (_not) {
        messagesTypes.add(messageType);
      }
    }
    WollokType _xifexpression = null;
    boolean _isEmpty = messagesTypes.isEmpty();
    if (_isEmpty) {
      _xifexpression = WollokType.WAny;
    } else {
      _xifexpression = TypeInferrer.structuralType(messagesTypes);
    }
    t = _xifexpression;
    return new Result<WollokType>(t);
  }
  
  protected Result<MessageType> messageTypeImpl(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WMemberFeatureCall call) throws RuleFailedException {
    try {
    	final RuleApplicationTrace _subtrace_ = newTrace(_trace_);
    	final Result<MessageType> _result_ = applyRuleTypeOfMessage(G, _subtrace_, call);
    	addToTrace(_trace_, new Provider<Object>() {
    		public Object get() {
    			return ruleName("TypeOfMessage") + stringRepForEnv(G) + " |- " + stringRep(call) + " ~> " + stringRep(_result_.getFirst());
    		}
    	});
    	addAsSubtrace(_trace_, _subtrace_);
    	return _result_;
    } catch (Exception e_applyRuleTypeOfMessage) {
    	messageTypeThrowException(ruleName("TypeOfMessage") + stringRepForEnv(G) + " |- " + stringRep(call) + " ~> " + "MessageType",
    		TYPEOFMESSAGE,
    		e_applyRuleTypeOfMessage, call, new ErrorInformation[] {new ErrorInformation(call)});
    	return null;
    }
  }
  
  protected Result<MessageType> applyRuleTypeOfMessage(final RuleEnvironment G, final RuleApplicationTrace _trace_, final WMemberFeatureCall call) throws RuleFailedException {
    MessageType t = null; // output parameter
    EList<WExpression> _memberCallArguments = call.getMemberCallArguments();
    final Function1<WExpression, WollokType> _function = new Function1<WExpression, WollokType>() {
      public WollokType apply(final WExpression a) {
        WollokType _xtrycatchfinallyexpression = null;
        try {
          WollokType _xblockexpression = null;
          {
            /* G |- a : var WollokType argType */
            WollokType argType = null;
            Result<WollokType> result = typeInternal(G, _trace_, a);
            checkAssignableTo(result.getFirst(), WollokType.class);
            argType = (WollokType) result.getFirst();
            
            _xblockexpression = (argType);
          }
          _xtrycatchfinallyexpression = _xblockexpression;
        } catch (final Throwable _t) {
          if (_t instanceof RuleFailedException) {
            final RuleFailedException e = (RuleFailedException)_t;
            VoidType _voidType = new VoidType();
            _xtrycatchfinallyexpression = _voidType;
          } else {
            throw Exceptions.sneakyThrow(_t);
          }
        }
        return _xtrycatchfinallyexpression;
      }
    };
    final List<WollokType> paramTypes = ListExtensions.<WExpression, WollokType>map(_memberCallArguments, _function);
    String _feature = call.getFeature();
    MessageType _messageType = new MessageType(_feature, paramTypes, WollokType.WAny);
    t = _messageType;
    return new Result<MessageType>(t);
  }
}
