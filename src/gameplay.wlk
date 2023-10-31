import visuals.*
import wollok.game.*
import intro.*
import music.*

object juego inherits Pantalla (
	codigo = 3,
	objetos = fondoJ + obstaculos + [auto, cartelContador, contador] ){
	
	override method mostrar() {
		super()
		self.inicializar()
		self.empezarEventos()
	}
	
	method inicializar() {[contador, fondoJuego, generador, auto].forEach{obj => obj.reiniciar()}}
	
	override method ocultar(){
		super()
		self.terminarEventos()
	}
	
	method empezarEventos() {
		game.onTick(auto.velocidad(), "Avanza auto", {auto.avanza() fondoJuego.actualizar()})
		game.onTick(auto.velocidad()/10, "Avanza contador", {contador.avanza()})
		game.onTick(auto.velocidad() * 4, "Generar obstaculos", {generador.generarObstaculos()})
		game.onTick(10000, "Aumentar velocidad", {auto.aumentarVelocidad()})
	}
	
	method terminarEventos() {
		const eventos = ["Avanza auto", "Avanza contador", "Generar obstaculos", "Aumentar velocidad"]
		eventos.forEach{evento => game.removeTickEvent(evento)}
	}
	
	// Teclado
	override method up() {}
	override method down() {}
	override method left() {auto.izquierda()}
	override method right() {auto.derecha()}
	override method enter() {}
	override method r() {}
	override method num1() {}
	override method num2() {}
	override method space() {auto.tocarBocina()}
}

object fondoJuego {
	method actualizar() {
		fondoJ.forEach{f => if (f.position().y() <= -11) f.position(game.at(0,9))}
	}
	
	method reiniciar() {
		ruta1.position(game.at(0,-1))
		ruta2.position(game.at(0,9))
	}
}

const fondoJ = [ruta1, ruta2]
const ruta1 = new Visual (position = game.at(0,-1), image = "ruta.png")
const ruta2 = new Visual (position = game.at(0,9), image = "ruta.png")

object auto {
	var property position = game.at(15,10)
	var property image = "auto.png"
	
	var property carril
	var agilidad = 1
	var property velocidad
	var vidas = 1
	var property vidasEnPartida
	var property luces = false
	var doblando = false
	
	method configurar() {
  		game.addVisual(self)
		game.onCollideDo(self, {obstaculo => obstaculo.chocar()})
		game.removeVisual(self)
	}
	
	method reiniciar() {
		position = game.at(7,1)
		carril = 2
		velocidad = 250
		vidasEnPartida = vidas
	}
	
	method izquierda() {
		if (carril > 1 && not doblando) {
			doblando = true
			position = position.left(1)
			game.schedule(250 / agilidad, {
				position = position.left(1)
				carril = carril - 1
				doblando = false
			})
		}
	}
	
	method derecha() {
		if (carril < 3 && not doblando) {
			doblando = true
			position = position.right(1)
			game.schedule(250 / agilidad, {
				position = position.right(1)
				carril = carril + 1
				doblando = false
			})
		}
	}
	
	method tocarBocina() {
		bocina.tocar()
		vacas.forEach{v => v.correrse()}
	}
	
	method aumentaAgilidad() {agilidad = 2}
	
	method vidaExtra() {vidas = 2}
	
	method aumentarVelocidad() {
		if (velocidad > 60) {
			velocidad = velocidad - 20
			juego.terminarEventos()
			juego.empezarEventos()
		}
	}
	
	method avanza() {(fondoJ + obstaculos).forEach{obj => obj.position(obj.position().down(1))}}
}

class Obstaculo {
	var property image
	var property position = game.at(15, 10)
	const property posicionesPosibles
	var property ultimaPosicion = 15
	
	method aparecer() {
		ultimaPosicion = posicionesPosibles.anyOne()
		position = game.at(ultimaPosicion, 10)
	}
	
	method aparecer(posicion) {
		ultimaPosicion = posicion
		position = game.at(ultimaPosicion, 10)
	}
	
	method chocar() {
		auto.vidasEnPartida(auto.vidasEnPartida() - 1)
		if (auto.vidasEnPartida() == 0) {cambio.aMenu()}
	}
}

class Inanimado inherits Obstaculo (
	image = "celda.png",
	posicionesPosibles = [5,6,7,8,9]
) {}

class Vaca inherits Obstaculo (
	image = "vaca.png",
	posicionesPosibles = [5,7,9] ) {
	
	var property carril = 0
	
	override method aparecer() {
		const libre = generador.lugaresLibres().filter{num => posicionesPosibles.contains(num)}
		ultimaPosicion = libre.anyOne()
		position = game.at(ultimaPosicion, 10)
		carril = (ultimaPosicion - 3) / 2
	}
	
	override method aparecer(posicion) {
		super(posicion)
		carril = (ultimaPosicion - 3) / 2
	}
	
	method correrse() {
		if (carril == auto.carril()) {
			position = position.down(1)
			if (carril == 3) {position = position.left(1)}
			else {position = position.right(1)}
			carril = 0
		}
	}
}

const obstaculosInanimados = [new Inanimado(), new Inanimado(), new Inanimado(), new Inanimado(), new Inanimado()]
const vacas = [new Vaca(), new Vaca()]
const obstaculos = obstaculosInanimados + vacas

object generador {
	var contador = 0
	var ciclos = 0
	var lugarOcupado
	var property lugaresLibres
	
	method generarObstaculos() {
		obstaculosInanimados.get(contador).aparecer()
		contador++
		if (contador == obstaculosInanimados.size() - 1) {
			lugaresLibres = [5,6,7,8,9]
			self.actualizarLugares(contador - 1)
			obstaculosInanimados.get(contador).aparecer(lugaresLibres.anyOne())
			self.actualizarLugares(contador)
			vacas.get(ciclos%vacas.size()).aparecer()
			contador = 0
			ciclos++
		}
	}
	
	method actualizarLugares(_contador) {
		lugarOcupado = obstaculosInanimados.get(_contador).ultimaPosicion()
		lugaresLibres.remove(lugarOcupado)
	}
	
	method reiniciar() {
		contador = 0
		obstaculos.forEach{obst => obst.position(game.at(15,10))}
	}
}

const cartelContador = new Visual (position = game.at(11,9), image = "contador.png")

object contador {
	var property position = game.at(13,9)
	var property metros = 0
	
	method text() = metros.toString()
	method textColor() = "FFFFFF"
	method avanza() {metros++}
	method reiniciar() {metros = 0}
}

