package org.uqbar.project.wollok.utils;

import java.util.HashSet;
import java.util.Set;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.xbase.jvmmodel.IJvmModelAssociations;

/**
 * I need this to use some intern behavior of the extract method refactoring
 * 
 * @author jfernandes
 */
public class DummyJvmModelAssociations implements IJvmModelAssociations {

	@Override
	public Set<EObject> getSourceElements(EObject jvmElement) {
		return new HashSet<>();
	}

	@Override
	public Set<EObject> getJvmElements(EObject sourceElement) {
		return new HashSet<>();
	}

	@Override
	public EObject getPrimarySourceElement(EObject jvmElement) {
		return null;
	}

	@Override
	public EObject getPrimaryJvmElement(EObject sourceElement) {
		return null;
	}

	@Override
	public boolean isPrimaryJvmElement(EObject jvmElement) {
		return false;
	}

}
