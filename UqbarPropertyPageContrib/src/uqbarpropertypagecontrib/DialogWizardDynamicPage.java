package uqbarpropertypagecontrib;

import org.eclipse.jface.dialogs.IDialogPage;
import org.eclipse.jface.dialogs.IDialogSettings;

public class DialogWizardDynamicPage extends DynamicPropertyPage<IDialogSettings> implements IDialogPage{

	@Override
	protected AttributeType<IDialogSettings> getBooleanType() {
		return DialogTypes.BOOLEAN;
	}

	@Override
	protected AttributeType<IDialogSettings> getStringType() {
		return DialogTypes.STRING;
	}
	

}
