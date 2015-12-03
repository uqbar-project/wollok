package org.uqbar.project.wollok.semantics;

import java.util.Arrays;
import org.uqbar.project.wollok.semantics.BasicType;
import org.uqbar.project.wollok.semantics.ConcreteType;
import org.uqbar.project.wollok.semantics.MessageType;
import org.uqbar.project.wollok.semantics.ObjectLiteralWollokType;
import org.uqbar.project.wollok.semantics.WollokDslTypeSystem;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.wollokDsl.WClass;
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class ClassBasedWollokType extends BasicType implements ConcreteType {
  private WClass clazz;
  
  private WollokDslTypeSystem system;
  
  private /* RuleEnvironment */Object env;
  
  public ClassBasedWollokType(final WClass clazz, final WollokDslTypeSystem system, final /* RuleEnvironment */Object env) {
    super(clazz.getName());
    this.clazz = clazz;
    this.system = system;
    this.env = env;
  }
  
  public boolean understandsMessage(final MessageType message) {
    throw new Error("Unresolved compilation problems:"
      + "\n!= cannot be resolved.");
  }
  
  public void acceptAssignment(final WollokType other) {
    throw new Error("Unresolved compilation problems:"
      + "\n== cannot be resolved."
      + "\n&& cannot be resolved."
      + "\n|| cannot be resolved"
      + "\n! cannot be resolved");
  }
  
  public WMethodDeclaration lookupMethod(final MessageType message) {
    throw new Error("Unresolved compilation problems:"
      + "\n!= cannot be resolved."
      + "\nThe method size is undefined for the type ClassBasedWollokType"
      + "\nThe field name is not visible"
      + "\nThe field parameterTypes is not visible"
      + "\nThe field parameterTypes is not visible"
      + "\n&& cannot be resolved"
      + "\n== cannot be resolved");
  }
  
  public WollokType resolveReturnType(final MessageType message, final WollokDslTypeSystem system, final /* RuleEnvironment */Object g) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method env is undefined for the type ClassBasedWollokType");
  }
  
  public WollokType refine(final WollokType previouslyInferred, final /* RuleEnvironment */Object g) {
    return this.doRefine(previouslyInferred, g);
  }
  
  protected WollokType _doRefine(final WollokType previous, final /* RuleEnvironment */Object g) {
    return super.refine(previous, g);
  }
  
  protected WollokType _doRefine(final ClassBasedWollokType previous, final /* RuleEnvironment */Object g) {
    throw new Error("Unresolved compilation problems:"
      + "\n== cannot be resolved."
      + "\n+ cannot be resolved."
      + "\n+ cannot be resolved"
      + "\n+ cannot be resolved");
  }
  
  protected WollokType _doRefine(final ObjectLiteralWollokType previous, final /* RuleEnvironment */Object g) {
    throw new Error("Unresolved compilation problems:"
      + "\nfilter cannot be resolved"
      + "\niterator cannot be resolved");
  }
  
  public WClass commonSuperclass(final WClass a, final WClass b) {
    WClass _xifexpression = null;
    boolean _isSubclassOf = this.isSubclassOf(a, b);
    if (_isSubclassOf) {
      _xifexpression = b;
    } else {
      WClass _xifexpression_1 = null;
      boolean _isSubclassOf_1 = this.isSubclassOf(b, a);
      if (_isSubclassOf_1) {
        _xifexpression_1 = a;
      } else {
        WClass _parent = a.getParent();
        WClass _parent_1 = b.getParent();
        _xifexpression_1 = this.commonSuperclass(_parent, _parent_1);
      }
      _xifexpression = _xifexpression_1;
    }
    return _xifexpression;
  }
  
  public boolean isSubclassOf(final WClass potSub, final WClass potSuper) {
    throw new Error("Unresolved compilation problems:"
      + "\n== cannot be resolved."
      + "\n|| cannot be resolved"
      + "\n&& cannot be resolved");
  }
  
  public Iterable<MessageType> getAllMessages() {
    return this.getAllMessages(this.env);
  }
  
  public Object getAllMessages(final /* RuleEnvironment */Object g) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method map is undefined for the type ClassBasedWollokType"
      + "\nInvalid number of arguments. The method queryMessageTypeForMethod(WMethodDeclaration) is not applicable for the arguments (RuleEnvironment,Object)"
      + "\nfirst cannot be resolved");
  }
  
  public boolean equals(final Object obj) {
    throw new Error("Unresolved compilation problems:"
      + "\n&& cannot be resolved."
      + "\n== cannot be resolved.");
  }
  
  public int hashCode() {
    return this.clazz.hashCode();
  }
  
  public WollokType doRefine(final WollokType previous, final RuleEnvironment g) {
    if (previous instanceof ClassBasedWollokType
         && g != null) {
      return _doRefine((ClassBasedWollokType)previous, g);
    } else if (previous instanceof ObjectLiteralWollokType
         && g != null) {
      return _doRefine((ObjectLiteralWollokType)previous, g);
    } else if (previous != null
         && g != null) {
      return _doRefine(previous, g);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(previous, g).toString());
    }
  }
}
