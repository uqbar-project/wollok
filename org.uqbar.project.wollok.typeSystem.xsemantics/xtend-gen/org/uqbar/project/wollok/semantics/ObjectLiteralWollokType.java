package org.uqbar.project.wollok.semantics;

import com.google.common.base.Objects;
import it.xsemantics.runtime.Result;
import it.xsemantics.runtime.RuleEnvironment;
import java.util.Iterator;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.uqbar.project.wollok.model.WMethodContainerExtensions;
import org.uqbar.project.wollok.semantics.BasicType;
import org.uqbar.project.wollok.semantics.ConcreteType;
import org.uqbar.project.wollok.semantics.MessageType;
import org.uqbar.project.wollok.semantics.StructuralType;
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
  
  private RuleEnvironment env;
  
  public ObjectLiteralWollokType(final WObjectLiteral obj, final WollokDslTypeSystem system, final RuleEnvironment env) {
    super("<object>");
    this.object = obj;
    this.system = system;
    this.env = env;
  }
  
  public String getName() {
    Iterable<WMethodDeclaration> _methods = WMethodContainerExtensions.methods(this.object);
    final Function1<WMethodDeclaration, String> _function = new Function1<WMethodDeclaration, String>() {
      public String apply(final WMethodDeclaration it) {
        return it.getName();
      }
    };
    Iterable<String> _map = IterableExtensions.<WMethodDeclaration, String>map(_methods, _function);
    String _join = IterableExtensions.join(_map, " ; ");
    String _plus = ("{ " + _join);
    return (_plus + " }");
  }
  
  public String signature(final WMethodDeclaration m) {
    String _name = m.getName();
    String _parametersSignature = this.parametersSignature(m);
    String _plus = (_name + _parametersSignature);
    String _returnTypeSignature = this.returnTypeSignature(m);
    return (_plus + _returnTypeSignature);
  }
  
  public String parametersSignature(final WMethodDeclaration m) {
    String _xifexpression = null;
    EList<WParameter> _parameters = m.getParameters();
    boolean _isEmpty = _parameters.isEmpty();
    if (_isEmpty) {
      _xifexpression = "";
    } else {
      EList<WParameter> _parameters_1 = m.getParameters();
      final Function1<WParameter, String> _function = new Function1<WParameter, String>() {
        public String apply(final WParameter it) {
          WollokType _type = ObjectLiteralWollokType.this.type(it);
          return _type.getName();
        }
      };
      List<String> _map = ListExtensions.<WParameter, String>map(_parameters_1, _function);
      String _join = IterableExtensions.join(_map, ", ");
      String _plus = ("(" + _join);
      _xifexpression = (_plus + ")");
    }
    return _xifexpression;
  }
  
  public String returnTypeSignature(final WMethodDeclaration m) {
    String _xblockexpression = null;
    {
      final Result<WollokType> rType = this.system.queryTypeFor(this.env, m);
      String _xifexpression = null;
      boolean _or = false;
      boolean _failed = rType.failed();
      if (_failed) {
        _or = true;
      } else {
        WollokType _first = rType.getFirst();
        boolean _equals = Objects.equal(_first, WollokType.WVoid);
        _or = _equals;
      }
      if (_or) {
        _xifexpression = "";
      } else {
        WollokType _first_1 = rType.getFirst();
        _xifexpression = (" : " + _first_1);
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  public boolean understandsMessage(final MessageType message) {
    WMethodDeclaration _lookupMethod = this.lookupMethod(message);
    return (!Objects.equal(_lookupMethod, null));
  }
  
  public WMethodDeclaration lookupMethod(final MessageType message) {
    WMethodDeclaration _xblockexpression = null;
    {
      String _name = message.getName();
      List<WollokType> _parameterTypes = message.getParameterTypes();
      final WMethodDeclaration m = WMethodContainerExtensions.lookupMethod(this.object, _name, _parameterTypes);
      WMethodDeclaration _xifexpression = null;
      boolean _notEquals = (!Objects.equal(m, null));
      if (_notEquals) {
        _xifexpression = m;
      } else {
        _xifexpression = null;
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  public WollokType resolveReturnType(final MessageType message, final WollokDslTypeSystem system, final RuleEnvironment g) {
    WollokType _xblockexpression = null;
    {
      final WMethodDeclaration method = this.lookupMethod(message);
      _xblockexpression = system.<WollokType>env(g, method, WollokType.class);
    }
    return _xblockexpression;
  }
  
  public Iterable<MessageType> getAllMessages() {
    Iterable<WMethodDeclaration> _methods = WMethodContainerExtensions.methods(this.object);
    final Function1<WMethodDeclaration, MessageType> _function = new Function1<WMethodDeclaration, MessageType>() {
      public MessageType apply(final WMethodDeclaration it) {
        Result<MessageType> _messageType = ObjectLiteralWollokType.this.messageType(it);
        return _messageType.getFirst();
      }
    };
    return IterableExtensions.<WMethodDeclaration, MessageType>map(_methods, _function);
  }
  
  public WollokType refine(final WollokType previous, final RuleEnvironment g) {
    StructuralType _xblockexpression = null;
    {
      Iterable<MessageType> _allMessages = this.getAllMessages();
      final Function1<MessageType, Boolean> _function = new Function1<MessageType, Boolean>() {
        public Boolean apply(final MessageType it) {
          return Boolean.valueOf(previous.understandsMessage(it));
        }
      };
      final Iterable<MessageType> intersectMessages = IterableExtensions.<MessageType>filter(_allMessages, _function);
      Iterator<MessageType> _iterator = intersectMessages.iterator();
      _xblockexpression = new StructuralType(_iterator);
    }
    return _xblockexpression;
  }
  
  public Result<MessageType> messageType(final WMethodDeclaration m) {
    return this.system.queryMessageTypeForMethod(this.env, m);
  }
  
  public WollokType type(final WParameter p) {
    Result<WollokType> _queryTypeFor = this.system.queryTypeFor(this.env, p);
    return _queryTypeFor.getFirst();
  }
}
