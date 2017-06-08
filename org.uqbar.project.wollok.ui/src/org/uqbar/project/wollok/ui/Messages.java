package org.uqbar.project.wollok.ui;

import java.util.Properties;

import org.eclipse.osgi.util.NLS;
import org.uqbar.project.wollok.utils.WNLS;

public class Messages extends NLS {
	private static final String BUNDLE_NAME = "org.uqbar.project.wollok.ui.messages"; //$NON-NLS-1$
	public static String AbstractNewWollokFileWizard_containerDoesNotExistPost;
	public static String AbstractNewWollokFileWizard_containerDoesNotExistPre;
	public static String AbstractNewWollokFileWizard_creating;
	public static String AbstractNewWollokFileWizard_errorTitle;
	public static String AbstractNewWollokFileWizard_openingFile;
	public static String AbstractNewWollokFileWizardPage_0;
	public static String AbstractNewWollokFileWizardPage_browse;
	public static String AbstractNewWollokFileWizardPage_container;
	public static String AbstractNewWollokFileWizardPage_fileContainerDoesNotExists;
	public static String AbstractNewWollokFileWizardPage_fileContainerRequired;
	public static String AbstractNewWollokFileWizardPage_fileExtensionMustBe;
	public static String AbstractNewWollokFileWizardPage_fileNameAlreadyExists;
	public static String AbstractNewWollokFileWizardPage_fileName;
	public static String AbstractNewWollokFileWizardPage_fileNameMustBeSpecified;
	public static String AbstractNewWollokFileWizardPage_fileNameMustBeValid;
	public static String AbstractNewWollokFileWizardPage_projectMustBeWritable;
	public static String AbstractNewWollokFileWizardPage_selectContainer;
	public static String NewWollokObjectsWizardPage_description;
	public static String NewWollokObjectsWizardPage_title;
	public static String NewWollokObjectsWizardPage_elementName;
	public static String NewWollokObjectsWizardPage_classLabel;
	public static String NewWollokObjectsWizardPage_objectLabel;
	
	public static String NewWollokProgramWizardPage_description;
	public static String NewWollokProgramWizardPage_title;
	public static String NewWollokTestWizardPage_description;
	public static String NewWollokTestWizardPage_title;
	public static String NewWollokDescribeWizardPage_description;
	public static String NewWollokDescribeWizardPage_title;
	public static String WollokDslNewProjectWizard_pageDescription;
	public static String WollokDslNewProjectWizard_pageTitle;
	public static String WollokDslNewProjectWizard_windowTitle;
	public static String WollokTemplateProposalProvider_WProgram_name;
	public static String WollokTemplateProposalProvider_WProgram_description;
	
	public static String WollokTemplateProposalProvider_WPackage_name;
	public static String WollokTemplateProposalProvider_WPackage_description;
	
	public static String WollokTemplateProposalProvider_WClass_name;
	public static String WollokTemplateProposalProvider_WClass_description;
	
	public static String WollokTemplateProposalProvider_WNamedObject_name;
	public static String WollokTemplateProposalProvider_WNamedObject_description;
	
	public static String WollokTemplateProposalProvider_WObjectLiteral_name;
	public static String WollokTemplateProposalProvider_WObjectLiteral_description;
	
	public static String WollokTemplateProposalProvider_WVariableDeclaration_name;
	public static String WollokTemplateProposalProvider_WVariableDeclaration_description;
	public static String WollokTemplateProposalProvider_WMethodDeclaration_name;
	public static String WollokTemplateProposalProvider_WMethodDeclaration_description;
	
	public static String WollokTemplateProposalProvider_WConstructorCall_name;
	public static String WollokTemplateProposalProvider_WConstructorCall_description;
	
	public static String WollokTemplateProposalProvider_WIfExpression_name;
	public static String WollokTemplateProposalProvider_WIfExpression_description;
	
	public static String WollokTemplateProposalProvider_WCollectionLiteral_name;
	public static String WollokTemplateProposalProvider_WCollectionLiteral_description;
	
	public static String WollokTemplateProposalProvider_WSetLiteral_name;
	public static String WollokTemplateProposalProvider_WSetLiteral_description;
	
	public static String WollokTemplateProposalProvider_WClosure_name;
	public static String WollokTemplateProposalProvider_WClosure_description;
	
	public static String WollokTemplateProposalProvider_WTry_name;
	public static String WollokTemplateProposalProvider_WTry_description;
	
	public static String WollokDslQuickfixProvider_capitalize_name;
	public static String WollokDslQuickfixProvider_capitalize_description;
	public static String WollokDslQuickfixProvider_lowercase_name;
	public static String WollokDslQuickfixProvider_lowercase_description;
	public static String WollokDslQuickfixProvider_changeToVar_name;
	public static String WollokDslQuickfixProvider_changeToVar_description;
	public static String WollokDslQuickfixProvider_createMethod_name;
	public static String WollokDslQuickfixProvider_createMethod_description;
	public static String WollokDslQuickfixProvider_createMethod_stub;	
	public static String WollokDslQuickfixProvider_return_variable_name;
	public static String WollokDslQuickfixProvider_return_variable_description;
	public static String WollokDslQuickfixProvider_return_last_expression_name;
	public static String WollokDslQuickfixProvider_return_last_expression_description;
	
	public static String WollokRootPreferencePage_autoformat_description;
	public static String WollokRootPreferencePage_debuggerWaitTimeForConnect;
	
	public static String ExtractMethodUserInputPage_methodName;
	public static String ExtractMethodUserInputPage_methodSignaturePreview;
	public static String ExtractMethodUserInputPage_provideMethodName;
	public static String ExtractMethodUserInputPage_extractMethodTitle;

	public static String LaunchReplWithoutFileHandler_notHavingWollokProject;
	
	public static String WollokTestResultView_runAgain;
	public static String WollokTestResultView_showOnlyFailuresAndErrors;
	public static String WollokTestResultView_debugAgain;
	
	public static String WollokProposal_form_class;
	public static String WollokProposal_form_object;
	public static String WollokProposal_form_mixin;
	public static String WollokProposal_cannot_instantiate;
	
	static {
		// initialize resource bundle
		NLS.initializeMessages(BUNDLE_NAME, Messages.class);
	}
	
	public static Properties loadProperties() { return WNLS.load(BUNDLE_NAME, Messages.class); }

	private Messages() {
	}

}
