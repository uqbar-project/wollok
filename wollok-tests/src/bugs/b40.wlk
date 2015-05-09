package b40 {

object pajarera {
    var energiaMenor = 100 
    var pajaros = #[pepita, pepe]
    method menorValor(){
        pajaros.forEach[a|a.sosMenor(energiaMenor)]
        return energiaMenor
    }      

    method setEnergiaMenor(valor){
        energiaMenor = valor
    }
}

object pepe {
    method sosMenor(energiaMenor){
        pajarera.setEnergiaMenor(10)
    }
}

object pepita {
    method sosMenor(energiaMenor){
        pajarera.setEnergiaMenor(25)
    }
}

class Arturo {
	var energiaMenor = 100 
    var pajaros = #[pepita, pepe]
    method menorValor(){
        pajaros.forEach[a | a.sosMenor(energiaMenor)]
        return energiaMenor
    }      

    method setEnergiaMenor(valor){
        energiaMenor = valor
    }
}

}