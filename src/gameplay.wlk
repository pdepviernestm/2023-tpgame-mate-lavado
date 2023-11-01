import visuals.*
import wollok.game.*
import intro.*
import music.*
import store.*

object juego inherits Pantalla (
	codigo = 3,
	objetos = fondoJ + obstaculos + monedasJuego + [hitboxAuto, auto, tormenta, cartelContador, contador] ){
	
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
		game.onTick(10000, "Aumentar velocidad", {auto.aumentarVelocidad()})
		game.onTick(15000, "Generar tormenta", {tormenta.aparecer()})
	}
	
	method terminarEventos() {
		self.terminarEventosActualizables()
		game.removeTickEvent("Aumentar velocidad")
		game.removeTickEvent("Generar tormenta")
	}
	
	method empezarEventosActualizables() {
		game.onTick(auto.velocidad(), "Avanza auto", {auto.avanza() fondoJuego.actualizar()})
		game.onTick(auto.velocidad()/10, "Avanza contador", {contador.avanza()})
		game.onTick(auto.velocidad() * 4, "Generar objetos", {generador.generarObjetos()})
		game.onTick(auto.velocidad() * 5, "Aparecen cactus", {fondoJuego.apareceCactus()})
	}
	
	method terminarEventosActualizables() {
		const eventos = ["Avanza auto", "Avanza contador", "Generar objetos", "Aparecen cactus"]
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
	var contador = 0
	
	method actualizar() {
		[ruta1, ruta2].forEach{f => if (f.position().y() <= -11) f.position(game.at(0,9))}
	}
	
	method reiniciar() {
		ruta1.position(game.at(0,-1))
		ruta2.position(game.at(0,9))
		variosCactus.forEach{c => c.position(game.at(15, 10))}
	}
	
	method apareceCactus() {
		variosCactus.get(contador % variosCactus.size()).aparecer()
		contador++
	}
}

const fondoJ = [ruta1, ruta2] + variosCactus
const variosCactus = [new Cactus(), new Cactus(), new Cactus(), new Cactus()]
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
	var property inmunidad = false
	
	method configurar() {
		[hitboxAuto, self].forEach{obj =>
	  		game.addVisual(obj)
			game.onCollideDo(obj, {obstaculo => obstaculo.chocar()})
			game.removeVisual(obj)
		}
	}
	
	method reiniciar() {
		position = game.at(6,1)
		hitboxAuto.actualizar()
		carril = 2
		velocidad = 250
		vidasEnPartida = vidas
	}
	
	method izquierda() {
		if (carril > 1 && not doblando) {
			doblando = true
			position = position.left(1)
			hitboxAuto.actualizar()
			game.schedule(250 / agilidad, {
				position = position.left(1)
				hitboxAuto.actualizar()
				carril = carril - 1
				doblando = false
			})
		}
	}
	
	method derecha() {
		if (carril < 3 && not doblando) {
			doblando = true
			position = position.right(1)
			hitboxAuto.actualizar()
			game.schedule(250 / agilidad, {
				position = position.right(1)
				hitboxAuto.actualizar()
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
	
	method avanza() {(fondoJ + obstaculos + monedasJuego).forEach{obj => obj.position(obj.position().down(1))}}
}

object hitboxAuto {
	var property position = game.at(15,11)
	
	method actualizar() {
		position = auto.position().up(1)
	}
}

class ObjetoDeJuego {
	var property image
	var property position = game.at(15, 10)
	var property ultimaPosicion = 15
	const property posicionesPosibles
	
	method aparecer(posicion) {
		ultimaPosicion = posicion
		position = game.at(ultimaPosicion, 10)
	}
	
	method aparecer() {self.aparecer(posicionesPosibles.anyOne())}
}

class Obstaculo inherits ObjetoDeJuego {
	method chocar() {
		if (not auto.inmunidad()) {
			auto.inmunidad(true)
			game.schedule(1000, {auto.inmunidad(false)})
			auto.vidasEnPartida(auto.vidasEnPartida() - 1)
			if (auto.vidasEnPartida() == 0) {cambio.aMenu()}
		}
	}
}

class Barril inherits Obstaculo (
	image = "barril.png",
	posicionesPosibles = [4,5,6,7,8]
) {}

class Vaca inherits Obstaculo (
	image = "vaca.png",
	posicionesPosibles = [4,6,8] ) {
	var property carril = 0
	
	override method aparecer(posicion) {
		super(posicion)
		carril = (ultimaPosicion - 2) / 2
	}
	
	override method aparecer() {
		const libre = generador.lugaresLibres().filter{num => posicionesPosibles.contains(num)}
		self.aparecer(libre.anyOne())
	}
	
	method correrse() {
		if (carril == auto.carril()) {
			position = position.up(1)
			if (carril == 1) {position = position.left(1)}
			else {position = position.right(1)}
			carril = 0
		}
	}
}

class Moneda inherits ObjetoDeJuego (
	image = "moneda.png",
	posicionesPosibles = [4,5,6,7,8] ) {
		
	method chocar() {
		position = game.at(20, 10)
		monedas.agregar(1)
	}
}

class Cactus inherits ObjetoDeJuego (
	image = "cactus.png",
	posicionesPosibles = [0, 1, 2, 11, 12, 13] ) {}

const obstaculos = barriles + vacas
const barriles = [new Barril(), new Barril(), new Barril(), new Barril(), new Barril()]
const vacas = [new Vaca(), new Vaca()]
const monedasJuego = [new Moneda(), new Moneda(), new Moneda()]

object generador {
	var contador = 0
	var ciclos = 0
	var lugarOcupado
	var property lugaresLibres
	
	method generarObjetos() {
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
		else {self.generarMonedas()}
	}
	
	method generarMonedas() {
		lugaresLibres = [4,6,8]
		self.actualizarLugares(contador - 1)
		monedasJuego.get(contador - 1).aparecer(lugaresLibres.anyOne())
	}
	
	method actualizarLugares(_contador) {
		lugarOcupado = barriles.get(_contador).ultimaPosicion()
		lugaresLibres.remove(lugarOcupado)
	}
	
	method reiniciar() {
		contador = 0
		(obstaculos + monedasJuego).forEach{obst => obst.position(game.at(15,10))}
	}
}

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

const cartelContador = new Visual (position = game.at(11,9), image = "contador.png")

object contador {
	var property position = game.at(13,9)
	var property metros = 0
	
	method text() = metros.toString()
	method textColor() = "FFFFFF"
	method avanza() {metros++}
	method reiniciar() {metros = 0}
}

