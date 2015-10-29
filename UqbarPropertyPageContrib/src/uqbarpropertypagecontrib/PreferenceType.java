package uqbarpropertypagecontrib;

import org.eclipse.core.runtime.preferences.IEclipsePreferences;

public interface PreferenceType {

	void toPreference(IEclipsePreferences preferences,String preferenceName, Object value);
	Object fromPreference(IEclipsePreferences preferences, String preferenceName, Object defaultValue);
	Object getValueType();
}
