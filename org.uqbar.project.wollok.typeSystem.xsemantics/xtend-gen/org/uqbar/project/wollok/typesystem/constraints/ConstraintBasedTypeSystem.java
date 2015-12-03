package org.uqbar.project.wollok.typesystem.constraints;

import java.util.Arrays;
import java.util.Collections;
import java.util.Map;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.TypeSystem;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;
import org.uqbar.project.wollok.typesystem.constraints.TypeVariable;
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral;
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral;
import org.uqbar.project.wollok.wollokDsl.WProgram;
import org.uqbar.project.wollok.wollokDsl.WStringLiteral;

/**
 * @author npasserini
 */
@SuppressWarnings("all")
public class ConstraintBasedTypeSystem implements TypeSystem {
  private final /* Map<EObject, TypeVariable> */Object typeVariables /* Skipped initializer because of errors */;
  
  public void analyse(final /* EObject */Object p) {
    throw new Error("Unresolved compilation problems:"
      + "\neContents cannot be resolved"
      + "\nforEach cannot be resolved");
  }
  
  protected void _generateVariables(final WProgram p) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method elements is undefined for the type ConstraintBasedTypeSystem"
      + "\nforEach cannot be resolved");
  }
  
  protected void _generateVariables(final /* EObject */Object node) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method println is undefined for the type ConstraintBasedTypeSystem");
  }
  
  protected void _generateVariables(final WNumberLiteral num) {
    throw new Error("Unresolved compilation problems:"
      + "\nType mismatch: cannot convert from Object to TypeVariable");
  }
  
  protected void _generateVariables(final WStringLiteral string) {
    throw new Error("Unresolved compilation problems:"
      + "\nType mismatch: cannot convert from Object to TypeVariable");
  }
  
  protected void _generateVariables(final WBooleanLiteral bool) {
    throw new Error("Unresolved compilation problems:"
      + "\nType mismatch: cannot convert from Object to TypeVariable");
  }
  
  public void inferTypes() {
  }
  
  public WollokType type(final /* EObject */Object obj) {
    throw new Error("Unresolved compilation problems:"
      + "\n== cannot be resolved."
      + "\n+ cannot be resolved.");
  }
  
  public Iterable<TypeExpectationFailedException> issues(final /* EObject */Object obj) {
    return Collections.<TypeExpectationFailedException>unmodifiableList(org.eclipse.xtext.xbase.lib.CollectionLiterals.<TypeExpectationFailedException>newArrayList());
  }
  
  public void generateVariables(final EObject bool) {
    if (bool != null) {
      _generateVariables(bool);
      return;
    } else if (bool != null) {
      _generateVariables(bool);
      return;
    } else if (bool != null) {
      _generateVariables(bool);
      return;
    } else if (bool != null) {
      _generateVariables(bool);
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
