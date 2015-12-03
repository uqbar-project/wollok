package org.uqbar.project.wollok.semantics;

import org.uqbar.project.wollok.semantics.WollokDslTypeSystem;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.TypeSystem;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;

/**
 * Type system implementation based on xsemantics
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class XSemanticsTypeSystem implements TypeSystem {
  /* @Inject
   */protected WollokDslTypeSystem xsemanticsSystem;
  
  private /* RuleEnvironment */Object env;
  
  public void analyse(final /* EObject */Object p) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method emptyEnvironment is undefined for the type XSemanticsTypeSystem"
      + "\nInvalid number of arguments. The method inferTypes(Object) is not applicable for the arguments (RuleEnvironment,Object)"
      + "\neContents cannot be resolved"
      + "\nforEach cannot be resolved");
  }
  
  public Object resolvedType(final /* EObject */Object o) {
    throw new Error("Unresolved compilation problems:"
      + "\nRuleFailedException cannot be resolved to a type."
      + "\nThe method env is undefined for the type XSemanticsTypeSystem"
      + "\nThe method or field NodeModelUtils is undefined for the type XSemanticsTypeSystem"
      + "\nThe method println is undefined for the type XSemanticsTypeSystem"
      + "\n+ cannot be resolved."
      + "\nThe method println is undefined for the type XSemanticsTypeSystem"
      + "\n+ cannot be resolved."
      + "\ngetNode cannot be resolved"
      + "\neResource cannot be resolved"
      + "\nURI cannot be resolved"
      + "\n+ cannot be resolved"
      + "\n+ cannot be resolved"
      + "\ntextRegionWithLineInformation cannot be resolved"
      + "\nlineNumber cannot be resolved"
      + "\n+ cannot be resolved"
      + "\n+ cannot be resolved"
      + "\ntext cannot be resolved"
      + "\nmessage cannot be resolved");
  }
  
  public WollokType type(final /* EObject */Object obj) {
    return this.resolvedType(obj);
  }
  
  public void inferTypes() {
    throw new UnsupportedOperationException("TODO: auto-generated method stub");
  }
  
  public Iterable<TypeExpectationFailedException> issues(final /* EObject */Object obj) {
    throw new UnsupportedOperationException("TODO: auto-generated method stub");
  }
}
