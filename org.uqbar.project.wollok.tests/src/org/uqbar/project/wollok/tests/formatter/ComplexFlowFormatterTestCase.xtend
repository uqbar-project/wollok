package org.uqbar.project.wollok.tests.formatter

import org.junit.Test

class ComplexFlowFormatterTestCase extends AbstractWollokFormatterTestCase {
	
	@Test
	def void program_ifInline() throws Exception {
		assertFormatting('''program p { 
    		const a = 10 
    		const b = 0
    		
    			   const c = if (a > 0) b                    else 
    			   
    			   
    			   0
    	}''', '''
		program p {
			const a = 10
			const b = 0
			const c = if (a > 0) b else 0
		}
		''')
	}

	@Test
	def void program_ifInlineWithExpressions() throws Exception {
		assertFormatting('''program p { 
    		const a = 10 
    		const b = 0
    		
    		const c = if (a > 0) b+1 else b-1
    	}''', '''
		program p {
			const a = 10
			const b = 0
			const c = if (a > 0) b + 1 else b - 1
		}
		''')
	}

	@Test
	def void issue702_forEachAndIf() throws Exception {
		assertFormatting('''
		object foo {
		    method bar() {
		        [3,              4        ,50,      100 ].forEach({ it => if (it > 4) { console.println(4) } else {console.println(it)
		            }
		        })
		    }
		}
		''',
		'''
		object foo {
		
			method bar() {
				[ 3, 4, 50, 100 ].forEach({
					it =>
						if (it > 4) {
							console.println(4)
						} else {
							console.println(it)
						}
				})
			}
		
		}
		
		''')
	}
	
	@Test
	def void program_maxOneLineBreakBetweenLines() throws Exception {
		assertFormatting('''program p { 
    		const a = 10 
    		const b = 0
    		
    		
    		
    		const c = a + b
    	}''', '''
		program p {
			const a = 10
			const b = 0
			const c = a + b
		}
		''')
	}

	@Test
	def void basicTryCatch() {
		assertFormatting('''
program abc {
    console.println(4)
    try
        {
            5 + 5
        }
            catch e : Exception
            {
                console.println(e)
            }
        }		
		''',
		'''
		program abc {
			console.println(4)
			try {
				5 + 5
			} catch e : Exception {
				console.println(e)
			}
		}
        ''')
	}

	@Test
	def void tryBlockWithSeveralCatchsAndAFinally() {
		assertFormatting('''
program abc {
    console.println(4)
    try{5 + 5}
            catch e : UserException       {
                console.println(e)
            }              catch e2:Exception {console.println("Bad error")       console.println("Do nothing")} 
            
            
            
            
            
            then always { console.println("finally") 
            
            
            }
        }		
		''',
		'''
		program abc {
			console.println(4)
			try {
				5 + 5
			} catch e : UserException {
				console.println(e)
			} catch e2 : Exception {
				console.println("Bad error")
				console.println("Do nothing")
			} then always {
				console.println("finally")
			}
		}
        ''')
	}

	@Test
	def void oneLineTryCatch() {
		assertFormatting('''
program abc {
    console.println(4)
    try
    
    
    
    
            5 + 5
    
    
            catch e : Exception
    
    
                console.println(e)
        }		
		''',
		'''
		program abc {
			console.println(4)
			try
				5 + 5
			catch e : Exception
				console.println(e)
		}
        ''')
	}

	@Test
	def void throwFormattingTest() {
		assertFormatting(
		'''
		object foo {
method attack(target) {
                           var attackers = self.standingMembers()
             if (attackers.isEmpty()) throw
                                new CannotAttackException("No attackers available") attackers.forEach({
                                        aMember => aMember.attack(target) })
}		
}
		''',
		'''
		object foo {
		
			method attack(target) {
				var attackers = self.standingMembers()
				if (attackers.isEmpty()) throw new CannotAttackException("No attackers available")
				attackers.forEach({
					aMember =>
						aMember.attack(target)
				})
			}
		
		}
		
		''')
	}		
}