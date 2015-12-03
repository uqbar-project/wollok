package org.uqbar.project.wollok.semantics;

import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import org.uqbar.project.wollok.semantics.MessageType;
import org.uqbar.project.wollok.semantics.TypeSystemException;
import org.uqbar.project.wollok.semantics.WollokDslTypeSystem;
import org.uqbar.project.wollok.semantics.WollokType;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class StructuralType implements /* MinimalEObjectImpl.Container */WollokType {
  private List<MessageType> messages;
  
  public StructuralType(final Iterator<MessageType> messagesTypes) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method toList is undefined for the type StructuralType");
  }
  
  public String getName() {
    throw new Error("Unresolved compilation problems:"
      + "\n+ cannot be resolved."
      + "\nThe method join is undefined for the type StructuralType"
      + "\n+ cannot be resolved");
  }
  
  public Iterable<MessageType> getAllMessages() {
    return this.messages;
  }
  
  public void acceptAssignment(final WollokType other) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method filter is undefined for the type StructuralType"
      + "\n! cannot be resolved."
      + "\n+ cannot be resolved."
      + "\nsize cannot be resolved"
      + "\n> cannot be resolved"
      + "\n+ cannot be resolved"
      + "\n+ cannot be resolved");
  }
  
  public WollokType refine(final WollokType previous, final /* RuleEnvironment */Object g) {
    return this.doRefine(previous, g);
  }
  
  protected StructuralType _doRefine(final StructuralType previouslyInferred, final /* RuleEnvironment */Object g) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method filter is undefined for the type StructuralType"
      + "\niterator cannot be resolved");
  }
  
  protected StructuralType _doRefine(final WollokType previouslyInferred, final /* RuleEnvironment */Object g) {
    throw new TypeSystemException("Incompatible types");
  }
  
  public boolean understandsMessage(final MessageType message) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method exists is undefined for the type StructuralType");
  }
  
  public WollokType resolveReturnType(final MessageType message, final WollokDslTypeSystem system, final /* RuleEnvironment */Object g) {
    return WollokType.WAny;
  }
  
  public String toString() {
    return this.getName();
  }
  
  public StructuralType doRefine(final WollokType previouslyInferred, final RuleEnvironment g) {
    if (previouslyInferred instanceof StructuralType
         && g != null) {
      return _doRefine((StructuralType)previouslyInferred, g);
    } else if (previouslyInferred != null
         && g != null) {
      return _doRefine(previouslyInferred, g);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(previouslyInferred, g).toString());
    }
  }
}
