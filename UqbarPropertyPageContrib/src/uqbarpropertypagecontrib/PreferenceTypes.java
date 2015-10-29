package uqbarpropertypagecontrib;

import org.eclipse.core.runtime.preferences.IEclipsePreferences;

public enum PreferenceTypes implements PreferenceType {
	STRING  {

		@Override
		public void toPreference(IEclipsePreferences prefereces,
				String preferenceName, Object value) {
			prefereces.put(preferenceName, (String) value);
		}

		@Override
		public Object fromPreference(IEclipsePreferences prefereces,
				String preferenceName, Object defaultValue) {
			
			return prefereces.get(preferenceName, (String) defaultValue);
		}

		@Override
		public Object getValueType() {
			return String.class;
		}
		
	}, BOOLEAN {

		@Override
		public void toPreference(IEclipsePreferences preferences,
				String preferenceName, Object value) {
			preferences.putBoolean(preferenceName,(Boolean) value);
		}

		@Override
		public Object fromPreference(IEclipsePreferences preferences,
				String preferenceName, Object defaultValue) {
			return preferences.getBoolean(preferenceName, (Boolean)defaultValue);
		}

		@Override
		public Object getValueType() {
			return Boolean.class;
		}
		
	} 

}
