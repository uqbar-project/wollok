package org.uqbar.wollok.teamwork;

import org.eclipse.core.runtime.CoreException;

public class RepositoryProvider extends org.eclipse.team.core.RepositoryProvider{


	@Override
	public void configureProject() throws CoreException {
		System.out.println("Configurando un proyecto");

	}

	@Override
	public void deconfigure() throws CoreException {
		System.out.println("Desconfigurando un proyecto");
		
	}
	
	@Override
	public String getID() {
		return getId();
	}
	
	public static String getId() {
		return RepositoryProvider.class.getName();
	}
	

}
