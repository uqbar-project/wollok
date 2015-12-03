package org.uqbar.project.wollok.typesystem.substitutions;

import java.util.Arrays;
import java.util.List;
import java.util.Set;
import org.uqbar.project.wollok.semantics.ClassBasedWollokType;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.TypeSystem;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;
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
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall;
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration;
import org.uqbar.project.wollok.wollokDsl.WNullLiteral;
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral;
import org.uqbar.project.wollok.wollokDsl.WParameter;
import org.uqbar.project.wollok.wollokDsl.WProgram;
import org.uqbar.project.wollok.wollokDsl.WReferenciable;
import org.uqbar.project.wollok.wollokDsl.WStringLiteral;
import org.uqbar.project.wollok.wollokDsl.WTest;
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
  private List<TypeRule> rules /* Skipped initializer because of errors */;
  
  private /* Set<EObject> */Object analyzed /* Skipped initializer because of errors */;
  
  public void analyse(final /* EObject */Object p) {
    throw new Error("Unresolved compilation problems:"
      + "\neContents cannot be resolved"
      + "\nforEach cannot be resolved");
  }
  
  public Object analyze(final /* EObject */Object node) {
    throw new Error("Unresolved compilation problems:"
      + "\n! cannot be resolved."
      + "\ndoAnalyse cannot be resolved");
  }
  
  public Object analyze(final /* Iterable<? extends EObject> */Object objects) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method forEach is undefined for the type SubstitutionBasedTypeSystem");
  }
  
  protected void _doAnalyse(final WProgram it) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method or field elements is undefined for the type SubstitutionBasedTypeSystem"
      + "\nanalyze cannot be resolved");
  }
  
  protected void _doAnalyse(final WTest it) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method or field elements is undefined for the type SubstitutionBasedTypeSystem"
      + "\nanalyze cannot be resolved");
  }
  
  protected void _doAnalyse(final WClass it) {
    throw new Error("Unresolved compilation problems:"
      + "\n!= cannot be resolved."
      + "\nThe method forEach is undefined for the type SubstitutionBasedTypeSystem");
  }
  
  protected void _doAnalyse(final WMethodDeclaration it) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method get is undefined for the type SubstitutionBasedTypeSystem"
      + "\n++ cannot be resolved."
      + "\nType mismatch: cannot convert from Object to Iterable<?>");
  }
  
  protected void _doAnalyse(final WVariableDeclaration it) {
    throw new Error("Unresolved compilation problems:"
      + "\n!= cannot be resolved.");
  }
  
  protected void _doAnalyse(final WVariable v) {
  }
  
  protected void _doAnalyse(final WMemberFeatureCall it) {
    throw new Error("Unresolved compilation problems:"
      + "\nType mismatch: cannot convert from Object to List");
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
    throw new Error("Unresolved compilation problems:"
      + "\nvalue cannot be resolved"
      + "\nkey cannot be resolved"
      + "\nget cannot be resolved"
      + "\nkey cannot be resolved"
      + "\nget cannot be resolved");
  }
  
  protected void _doAnalyse(final WVariableReference it) {
    WReferenciable _ref = it.getRef();
    this.addCheck(it, it, TypeCheck.SAME_AS, _ref);
  }
  
  protected void _doAnalyse(final WIfExpression it) {
    throw new Error("Unresolved compilation problems:"
      + "\n!= cannot be resolved.");
  }
  
  protected void _doAnalyse(final WBlockExpression it) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method or field expressions is undefined for the type SubstitutionBasedTypeSystem"
      + "\nThe method or field expressions is undefined for the type SubstitutionBasedTypeSystem"
      + "\nThe method or field expressions is undefined for the type SubstitutionBasedTypeSystem"
      + "\nempty cannot be resolved"
      + "\n! cannot be resolved"
      + "\nanalyze cannot be resolved"
      + "\nlast cannot be resolved");
  }
  
  public void inferTypes() {
    this.resolveRules();
    this.unifyConstraints();
  }
  
  protected void resolveRules() {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method fold is undefined for the type SubstitutionBasedTypeSystem"
      + "\nThe method clone() is not visible"
      + "\nresolve cannot be resolved"
      + "\n|| cannot be resolved");
  }
  
  protected Object unifyConstraints() {
    return null;
  }
  
  public WollokType type(final /* EObject */Object obj) {
    throw new Error("Unresolved compilation problems:"
      + "\n== cannot be resolved");
  }
  
  public Iterable<TypeExpectationFailedException> issues(final /* EObject */Object obj) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method fold is undefined for the type SubstitutionBasedTypeSystem"
      + "\nThe method or field newArrayList is undefined for the type SubstitutionBasedTypeSystem"
      + "\ncheck cannot be resolved"
      + "\nadd cannot be resolved"
      + "\nfilter cannot be resolved"
      + "\nmodel cannot be resolved"
      + "\n== cannot be resolved");
  }
  
  /**
   * Returns the resolved type for the given object.
   * Unless there are multiple resolved types.
   * To resolve the type it asks all the rules (but the one passed as args).
   * This is because probably from one rule you want to ask the type of one of its
   * object but you don't want to the system to ask your rule back.
   */
  public Object typeForExcept(final /* EObject */Object object, final TypeRule unwantedRule) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method fold is undefined for the type SubstitutionBasedTypeSystem"
      + "\nThe method or field newArrayList is undefined for the type SubstitutionBasedTypeSystem"
      + "\n!= cannot be resolved"
      + "\ntypeOf cannot be resolved"
      + "\n!= cannot be resolved"
      + "\n+= cannot be resolved"
      + "\nsize cannot be resolved"
      + "\n== cannot be resolved"
      + "\nhead cannot be resolved");
  }
  
  public Object addRule(final TypeRule rule) {
    throw new Error("Unresolved compilation problems:"
      + "\n! cannot be resolved."
      + "\n+= cannot be resolved.");
  }
  
  public Object addFact(final /* EObject */Object source, final /* EObject */Object model, final WollokType knownType) {
    throw new Error("Unresolved compilation problems:"
      + "\nanalyze cannot be resolved");
  }
  
  public Object isAn(final /* EObject */Object model, final WollokType knownType) {
    throw new Error("Unresolved compilation problems:"
      + "\nisA cannot be resolved");
  }
  
  public Object isA(final /* EObject */Object model, final WollokType knownType) {
    throw new Error("Unresolved compilation problems:"
      + "\naddFact cannot be resolved");
  }
  
  public Object addCheck(final /* EObject */Object source, final /* EObject */Object a, final TypeCheck check, final /* EObject */Object b) {
    throw new Error("Unresolved compilation problems:"
      + "\nanalyze cannot be resolved"
      + "\nanalyze cannot be resolved");
  }
  
  public String toString() {
    throw new Error("Unresolved compilation problems:"
      + "\n+ cannot be resolved."
      + "\nThe method join is undefined for the type SubstitutionBasedTypeSystem"
      + "\n+ cannot be resolved");
  }
  
  public void doAnalyse(final Object it) {
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
