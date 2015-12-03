package org.uqbar.project.wollok.semantics;

import org.uqbar.project.wollok.semantics.BasicType;
import org.uqbar.project.wollok.semantics.ConcreteType;
import org.uqbar.project.wollok.semantics.MessageType;
import org.uqbar.project.wollok.semantics.WollokDslTypeSystem;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration;
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral;
import org.uqbar.project.wollok.wollokDsl.WParameter;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class ObjectLiteralWollokType extends BasicType implements ConcreteType {
  private WObjectLiteral object;
  
  private WollokDslTypeSystem system;
  
  private /* RuleEnvironment */Object env;
  
  public ObjectLiteralWollokType(final WObjectLiteral obj, final WollokDslTypeSystem system, final /* RuleEnvironment */Object env) {
    super("<object>");
    this.object = obj;
    this.system = system;
    this.env = env;
  }
  
  public String getName() {
    throw new Error("Unresolved compilation problems:"
      + "\n+ cannot be resolved."
      + "\nmap cannot be resolved"
      + "\njoin cannot be resolved"
      + "\n+ cannot be resolved");
  }
  
  public Object signature(final WMethodDeclaration m) {
    throw new Error("Unresolved compilation problems:"
      + "\n+ cannot be resolved."
      + "\n+ cannot be resolved");
  }
  
  public String parametersSignature(final WMethodDeclaration m) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method empty is undefined for the type ObjectLiteralWollokType"
      + "\n+ cannot be resolved."
      + "\nThe method map is undefined for the type ObjectLiteralWollokType"
      + "\nType mismatch: cannot convert implicit first argument from ObjectLiteralWollokType to WParameter"
      + "\nname cannot be resolved"
      + "\njoin cannot be resolved"
      + "\n+ cannot be resolved");
  }
  
  public String returnTypeSignature(final WMethodDeclaration m) {
    throw new Error("Unresolved compilation problems:"
      + "\n+ cannot be resolved."
      + "\nInvalid number of arguments. The method queryTypeFor(Object) is not applicable for the arguments (RuleEnvironment,WMethodDeclaration)"
      + "\nfailed cannot be resolved"
      + "\n|| cannot be resolved"
      + "\nfirst cannot be resolved"
      + "\n== cannot be resolved"
      + "\nfirst cannot be resolved");
  }
  
  public boolean understandsMessage(final MessageType message) {
    throw new Error("Unresolved compilation problems:"
      + "\n!= cannot be resolved.");
  }
  
  public WMethodDeclaration lookupMethod(final MessageType message) {
    throw new Error("Unresolved compilation problems:"
      + "\n!= cannot be resolved."
      + "\nThe field name is not visible"
      + "\nThe field parameterTypes is not visible");
  }
  
  public WollokType resolveReturnType(final MessageType message, final WollokDslTypeSystem system, final /* RuleEnvironment */Object g) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method env is undefined for the type ObjectLiteralWollokType");
  }
  
  public Iterable<MessageType> getAllMessages() {
    throw new Error("Unresolved compilation problems:"
      + "\nType mismatch: cannot convert implicit first argument from ObjectLiteralWollokType to WMethodDeclaration"
      + "\nmap cannot be resolved"
      + "\nfirst cannot be resolved");
  }
  
  public WollokType refine(final WollokType previous, final /* RuleEnvironment */Object g) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method filter is undefined for the type ObjectLiteralWollokType"
      + "\niterator cannot be resolved");
  }
  
  public it.xsemantics.runtime.Result messageType(final WMethodDeclaration m) {
    throw new Error("Unresolved compilation problems:"
      + "\nInvalid number of arguments. The method queryMessageTypeForMethod(WMethodDeclaration) is not applicable for the arguments (RuleEnvironment,WMethodDeclaration)");
  }
  
  public Object type(final WParameter p) {
    throw new Error("Unresolved compilation problems:"
      + "\nInvalid number of arguments. The method queryTypeFor(Object) is not applicable for the arguments (RuleEnvironment,WParameter)"
      + "\nfirst cannot be resolved");
  }
}
