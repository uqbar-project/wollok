package org.uqbar.project.wollok.semantics;

import java.util.Iterator;
import org.uqbar.project.wollok.semantics.MessageType;
import org.uqbar.project.wollok.semantics.StructuralType;

/**
 * Utilities around type system
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class TypeInferrer {
  public static StructuralType structuralType(final Iterable<MessageType> messagesTypes) {
    Iterator<MessageType> _iterator = messagesTypes.iterator();
    return TypeInferrer.structuralType(_iterator);
  }
  
  public static StructuralType structuralType(final Iterator<MessageType> messagesTypes) {
    return new StructuralType(messagesTypes);
  }
}
