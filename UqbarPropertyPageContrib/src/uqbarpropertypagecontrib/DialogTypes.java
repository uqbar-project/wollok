package uqbarpropertypagecontrib;

import org.eclipse.jface.dialogs.IDialogSettings;


public enum DialogTypes implements AttributeType<IDialogSettings> {
	STRING  {

		@Override
		public void toModel(IDialogSettings model,
				String preferenceName, Object value) {
			model.put(preferenceName, (String) value);
		}

		@Override
		public Object fromModel(IDialogSettings prefereces,
				String preferenceName, Object defaultValue) {
			
			String out = prefereces.get(preferenceName);
			return out != null ? out : defaultValue;
		}

		@Override
		public Object getValueType() {
			return String.class;
		}
		
	}, BOOLEAN {

		@Override
		public void toModel(IDialogSettings preferences,
				String preferenceName, Object value) {
			preferences.put(preferenceName,(Boolean) value);
		}

		@Override
		public Object fromModel(IDialogSettings preferences,
				String preferenceName, Object unused) {
			return preferences.getBoolean(preferenceName);
		}

		@Override
		public Object getValueType() {
			return Boolean.class;
		}
		
	} 

}
