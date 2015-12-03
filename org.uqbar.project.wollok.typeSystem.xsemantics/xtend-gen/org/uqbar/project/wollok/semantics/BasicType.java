package org.uqbar.project.wollok.semantics;

import java.util.Collections;
import org.uqbar.project.wollok.semantics.MessageType;
import org.uqbar.project.wollok.semantics.WollokDslTypeSystem;
import org.uqbar.project.wollok.semantics.WollokType;

/**
 * Base class for all types
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public abstract class BasicType implements WollokType {
  /* @Property
   */private String name;
  
  public BasicType(final String name) {
    this.name = name;
  }
  
  public void acceptAssignment(final WollokType other) {
    throw new Error("Unresolved compilation problems:"
      + "\n!= cannot be resolved.");
  }
  
  public boolean understandsMessage(final MessageType message) {
    return true;
  }
  
  public WollokType resolveReturnType(final MessageType message, final WollokDslTypeSystem system, final /* RuleEnvironment */Object g) {
    return WollokType.WAny;
  }
  
  public WollokType refine(final WollokType previouslyInferred, final /* RuleEnvironment */Object g) {
    throw new Error("Unresolved compilation problems:"
      + "\n!= cannot be resolved."
      + "\n+ cannot be resolved."
      + "\n+ cannot be resolved"
      + "\n+ cannot be resolved");
  }
  
  public Iterable<MessageType> getAllMessages() {
    return Collections.<MessageType>unmodifiableList(org.eclipse.xtext.xbase.lib.CollectionLiterals.<MessageType>newArrayList());
  }
  
  public String toString() {
    return this.name;
  }
}
