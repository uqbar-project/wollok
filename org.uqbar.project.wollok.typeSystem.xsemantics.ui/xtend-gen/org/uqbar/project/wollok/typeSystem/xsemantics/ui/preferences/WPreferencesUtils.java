package org.uqbar.project.wollok.typeSystem.xsemantics.ui.preferences;

import java.util.Collections;
import java.util.List;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;

/**
 * Preferences utilities
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class WPreferencesUtils {
  public static List<String> booleanPrefValues() {
    return Collections.<String>unmodifiableList(CollectionLiterals.<String>newArrayList(IPreferenceStore.TRUE, IPreferenceStore.FALSE));
  }
}
