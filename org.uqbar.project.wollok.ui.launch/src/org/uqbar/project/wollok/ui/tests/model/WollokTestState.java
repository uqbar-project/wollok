package org.uqbar.project.wollok.ui.tests.model;

import org.eclipse.emf.common.util.URI;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.resource.ResourceManager;
import org.eclipse.swt.graphics.Image;
import org.uqbar.project.wollok.ui.i18n.WollokLaunchUIMessages;
import org.uqbar.project.wollok.ui.launch.Activator;
import org.uqbar.project.wollok.utils.WEclipseUtils;

public enum WollokTestState {
	PENDING {
		@Override
		public String getImageName() {
			return "icons/test.png";
		}

		@Override
		public String getText() {
			return WollokLaunchUIMessages.WollokTestState_PENDING;
		}

		@Override
		public URI getURI(WollokTestResult result) {
			return result.getTestResource();
		}

		@Override
		public String getOutputText(WollokTestResult result) {
			return getText();
		}
	},
	OK {
		@Override
		public String getImageName() {
			return "icons/test_ok.png";
		}

		@Override
		public String getText() {
			return WollokLaunchUIMessages.WollokTestState_OK;
		}

		@Override
		public URI getURI(WollokTestResult result) {
			return result.getTestResource();
		}

		@Override
		public String getOutputText(WollokTestResult result) {
			return getText() + " - " + result.getTotalTimeElapsed();
		}
	},
	ERROR {
		@Override
		public String getImageName() {
			return "icons/test_error" + WEclipseUtils.themeSuffix() + ".png";
		}

		@Override
		public String getText() {
			return WollokLaunchUIMessages.WollokTestState_ERROR;
		}

		@Override
		public URI getURI(WollokTestResult result) {
			return result.getTestResource();
		}

		@Override
		public String getOutputText(WollokTestResult result) {
			return result.getErrorOutput() + " - " + result.getTotalTimeElapsed();
		}

	},
	RUNNING {
		@Override
		public String getImageName() {
			return "icons/test_run" + WEclipseUtils.themeSuffix() + ".png";
		}

		@Override
		public String getText() {
			return WollokLaunchUIMessages.WollokTestState_RUNNING;
		}

		@Override
		public URI getURI(WollokTestResult result) {
			return result.getTestResource();
		}

		@Override
		public String getOutputText(WollokTestResult result) {
			return this.getText();
		}

	},
	ASSERT {
		@Override
		public String getImageName() {
			return "icons/test_fail" + WEclipseUtils.themeSuffix() + ".png";
		}

		@Override
		public String getText() {
			return WollokLaunchUIMessages.WollokTestState_ASSERT;
		}

		@Override
		public URI getURI(WollokTestResult result) {
			return result.getTestResource();
		}

		@Override
		public String getOutputText(WollokTestResult result) {
			return result.getErrorOutput() + " - " + result.getTotalTimeElapsed();
		}

	};

	public abstract String getImageName();

	public abstract String getText();

	public abstract URI getURI(WollokTestResult result);

	public abstract String getOutputText(WollokTestResult result);

	public Image getImage(ResourceManager resourceManager) {
		ImageDescriptor imageDescriptor = Activator.getDefault().getImageDescriptor(this.getImageName());
		return resourceManager.createImage(imageDescriptor);
	}

}
