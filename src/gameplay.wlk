import visuals.*
import wollok.game.*
import intro.*
import music.*

object juego inherits Pantalla (
	codigo = 3,
	objetos = fondoJ + obstaculos + [auto, tormenta, cartelContador, contador] ){
	
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
		self.empezarEventosActualizables()
		game.onTick(15000, "Generar tormenta", {tormenta.aparecer()})
	}
	
	method terminarEventos() {
		self.terminarEventosActualizables()
		game.removeTickEvent("Generar tormenta")
	}
	
	method empezarEventosActualizables() {
		game.onTick(auto.velocidad(), "Avanza auto", {auto.avanza() fondoJuego.actualizar()})
		game.onTick(auto.velocidad()/10, "Avanza contador", {contador.avanza()})
		game.onTick(auto.velocidad() * 4, "Generar obstaculos", {generador.generarObstaculos()})
		game.onTick(10000, "Aumentar velocidad", {auto.aumentarVelocidad()})
	}
	
	method terminarEventosActualizables() {
		const eventos = ["Avanza auto", "Avanza contador", "Generar obstaculos", "Aumentar velocidad"]
		eventos.forEach{evento => game.removeTickEvent(evento)}
	}
	
	method actualizarEventos() {
		self.terminarEventosActualizables()
		self.empezarEventosActualizables()
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
	var property image = "mate.png"
	
	var property carril
	var agilidad = 1
	var property velocidad
	var vidas = 1
	var property vidasEnPartida
	var doblando = false
	
	method configurar() {
  		game.addVisual(self)
		game.onCollideDo(self, {obstaculo => obstaculo.chocar()})
		game.removeVisual(self)
	}
	
	method reiniciar() {
		position = game.at(6,1)
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
			juego.actualizarEventos()
		}
	}
	
	method avanza() {(fondoJ + obstaculos).forEach{obj => obj.position(obj.position().down(1))}}
}

class ObjetoDeCalle {
	var property image
	var property position = game.at(15, 10)
	const property posicionesPosibles = [4,5,6,7,8]
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

class Barril inherits ObjetoDeCalle (image = "barril.png") {}

class Vaca inherits ObjetoDeCalle (
	image = "vaca.png",
	posicionesPosibles = [4,6,8] ) {
	
	var property carril = 0
	
	override method aparecer() {
		const libre = generador.lugaresLibres().filter{num => posicionesPosibles.contains(num)}
		ultimaPosicion = libre.anyOne()
		position = game.at(ultimaPosicion, 10)
		carril = (ultimaPosicion - 2) / 2
	}
	
	override method aparecer(posicion) {
		super(posicion)
		carril = (ultimaPosicion - 2) / 2
	}
	
	method correrse() {
		if (carril == auto.carril()) {
			position = position.up(1)
			if (carril == 3) {position = position.left(1)}
			else {position = position.right(1)}
			carril = 0
		}
	}
}

class Moneda inherits ObjetoDeCalle {}

object tormenta {
	var property position = game.at(0, 10)
	var property image = "tormenta.png"
	
	method aparecer() {
		if (0.randomUpTo(1) < 0.34) {
			position = game.at(0, 10)
			game.onTick(100, "Aparece tormenta", {position = position.down(1)})
			game.schedule(500, {game.removeTickEvent("Aparece tormenta")})
			game.schedule(5500, {self.desaparecer()})
		}
	}
	
	method desaparecer() {
		game.onTick(100, "Desaparece tormenta", {position = position.up(1)})
		game.schedule(500, {game.removeTickEvent("Desaparece tormenta")})
	}
}

const barriles = [new Barril(), new Barril(), new Barril(), new Barril(), new Barril()]
const vacas = [new Vaca(), new Vaca()]
const obstaculos = barriles + vacas

object generador {
	var contador = 0
	var ciclos = 0
	var lugarOcupado
	var property lugaresLibres
	
	method generarObstaculos() {
		barriles.get(contador).aparecer()
		contador++
		if (contador == barriles.size() - 1) {
			lugaresLibres = [4,5,6,7,8]
			self.actualizarLugares(contador - 1)
			barriles.get(contador).aparecer(lugaresLibres.anyOne())
			self.actualizarLugares(contador)
			vacas.get(ciclos%vacas.size()).aparecer()
			contador = 0
			ciclos++
		}
	}
	
	method actualizarLugares(_contador) {
		lugarOcupado = barriles.get(_contador).ultimaPosicion()
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

