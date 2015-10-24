package org.uqbar.project.wollok.ui.tests.model;

import java.io.PrintWriter;
import java.io.StringWriter;

import org.eclipse.emf.common.util.URI;
import org.eclipse.swt.graphics.Image;
import org.uqbar.project.wollok.ui.i18n.WollokLaunchUIMessages;
import org.uqbar.project.wollok.ui.launch.Activator;

public enum WollokTestState {
	PENDING {
		@Override
		public String getImageName() {
			return "icons/test.gif";
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
			return "icons/testok.gif";
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
			return getText();
		}
	},
	ERROR {
		@Override
		public String getImageName() {
			return "icons/testerr.gif";
		}

		@Override
		public String getText() {
			return WollokLaunchUIMessages.WollokTestState_ERROR;
		}

		@Override
		public URI getURI(WollokTestResult result) {
			return result.getErrorResource();
		}
		
		@Override
		public String getOutputText(WollokTestResult result) {
			StringWriter sw = new StringWriter();
			result.getException().printStackTrace(new PrintWriter(sw));
			return sw.toString();
		}

	},
	RUNNING {
		@Override
		public String getImageName() {
			return "icons/testrun.gif";
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
			return "icons/testfail.gif";
		}

		@Override
		public String getText() {
			return WollokLaunchUIMessages.WollokTestState_ASSERT;
		}

		@Override
		public URI getURI(WollokTestResult result) {
			return result.getErrorResource();
		}

		@Override
		public String getOutputText(WollokTestResult result) {
			return new AssertErrorFormatter().format(result.getAssertException());
		}

	};

	public abstract String getImageName();

	public abstract String getText();

	public abstract URI getURI(WollokTestResult result);

	public abstract String getOutputText(WollokTestResult result);

	public Image getImage() {
		return Activator.getDefault().getImageDescriptor(this.getImageName())
				.createImage();
	}
}
