package org.uqbar.project.wollok

/**
 * Contains language keywords defined in the grammar
 * but then used by the interpreter or any other processing (like quickfixes).
 * 
 * Avoids hardcoding strings all over the places.
 * So that if we decide to change the grammar syntax we can just change here.
 * 
 * There's probably a way to get this via xtext but I'm not sure how
 * 
 * @author jfernandes
 */
class WollokConstants {
	public static String CLASSPATH = "classpath:/"
	
	public static val SOURCE_FOLDER = "src"
	
	public static val NATURE_ID = "org.uqbar.project.wollok.wollokNature"
	public static val WOLLOK_DEFINITION_EXTENSION = "wlk"
	public static val PROGRAM_EXTENSION = "wpgm"
	public static val TEST_EXTENSION = "wtest"
	public static val STATIC_DIAGRAM_EXTENSION = "wsdi"
	
	public static val DIAGRAMS_FOLDER = ".diagrams"
	public static val SETTINGS_FOLDER = ".settings"
	public static val BIN_FOLDER = "bin"
	public static val METAINF_FOLDER = "META-INF"
	public static val HIDDEN_FOLDERS = #[DIAGRAMS_FOLDER, SETTINGS_FOLDER, BIN_FOLDER, METAINF_FOLDER]
	
	public static val REPL_FILE = "wollokREPL.wlk"
	public static val REPL_PROMPT = ">>> " 
	public static val SYNTHETIC_FILE = "__synthetic"
	
	public static val PATH_SEPARATOR = "/"
	public static val STACKELEMENT_SEPARATOR = ":"
	public static val WINDOWS_FILE_PREFIX_SIZE = 6
	public static val DEFAULT_FILE_PREFIX_SIZE = 5 

	public static val LIBRARY_FOLDER = "org.uqbar.project.wollok.lib"
		
	// grammar elements here for being used in quickfixes, validators, and
	// any code that generates wollok code
	
	public static val OPMULTIASSIGN = #['+=', '-=', '*=', '/=', '%=', '<<=', '>>=']
	public static val OP_EQUALITY = #['==', '!=', '===', '!==']
	public static val ASIGNATION = '='
		
	public static val OP_BOOLEAN_AND = #['and', "&&"]
	public static val OP_BOOLEAN_OR = #["or", "||"]
	
	public static val OP_BOOLEAN = #['and', "&&", "or", "||"]
	public static val OP_UNARY_BOOLEAN = #['!', "not"]
	
	public static val SELF = "self"
	public static val SUPER = "super"
	public static val NULL = "null"
	public static val METHOD = "method"
	public static val CONSTRUCTOR = "constructor"
	public static val VAR = "var"
	public static val PROPERTY = "property"
	public static val CONST = "const"
	public static val OVERRIDE = "override"
	public static val NATIVE = "native"
	public static val RETURN = "return"
	public static val IMPORT = "import"
	public static val SUITE = "describe"
	public static val TEST = "test"
	public static val MIXIN = "mixin"
	public static val CLASS = "class"
	public static val INHERITS = "inherits"
	public static val MIXED_WITH = "mixed with"
	public static val WKO = "object"
	public static val FIXTURE = "fixture"
	public static val PROGRAM = "program"
	public static val PACKAGE = "package" 
	
	public static val ASSIGNMENT = "="
	public static val BEGIN_EXPRESSION = "{"
	public static val END_EXPRESSION = "}"
	public static val BEGIN_LIST_LITERAL = "["
	public static val END_LIST_LITERAL = "]"
	public static val BEGIN_SET_LITERAL = "#{"
	public static val END_SET_LITERAL = "}"
	public static val BEGIN_PARAMETER_LIST = "("
	public static val END_PARAMETER_LIST = ")"
	public static val INSTANTIATION = "new"
	public static val TRY = "try"

	public static val ROOT_CLASS = "Object"
	public static val FQN_ROOT_CLASS = "wollok.lang.Object"
	
	public static val MULTIOPS_REGEXP = "[+\\-*/%]="
	
	public static val TO_STRING = "toString"
	public static val TO_STRING_PRINTABLE = "printString"
	public static val TO_STRING_SHORT = "shortDescription"

}