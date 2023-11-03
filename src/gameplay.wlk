import visuals.*
import wollok.game.*
import intro.*
import music.*
import store.*
import objects.*
import menu.*

object juego inherits Pantalla (
	codigo = 3,
	objetos = rutas + variosCactus + obstaculos + monedasJuego + [hitboxAuto, auto, tormenta, corazon, cartelVidas] + informacion){
	
	override method mostrar() {
		super()
		self.inicializar()
		self.empezarEventos()
	}
	
	override method ocultar() {
		if (contador.metros() > mejorPuntuacion.metros()) mejorPuntuacion.metros(contador.metros())
		super()
	}
	
	override method musicaAlMostrar() {musica.pausar()}
	override method musicaAlOcultar() {musica.reanudar()}
	
	method inicializar() {
		[contador, fondoJuego, generador, auto, corazon, cartelVidas].forEach{obj => obj.reiniciar()}
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
		game.onTick(auto.velocidad(), "Avanza auto", {auto.avanza()})
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
	
	method finalizar() {
		self.terminarEventos()
		enPantalla.hay(estadoIntermedio)
		game.schedule(3000, {cambio.conTransicionEntre(self, menu)})
	}
	
	// Teclado
	override method left() {auto.izquierda()}
	override method right() {auto.derecha()}
	override method space() {auto.tocarBocina()}
}

object fondoJuego {
	var contador = 0
	
	method mover() {
		rutas.forEach{r =>
			if (r.position().y() > -10) r.position(r.position().down(1))
			else r.position(game.at(0, 9))
		}
		variosCactus.forEach{obj => obj.position(obj.position().down(1))}
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

const rutas = [ruta1, ruta2]
const ruta1 = new Visual (position = game.at(0,-1), image = "ruta.png")
const ruta2 = new Visual (position = game.at(0,9), image = "ruta.png")
const variosCactus = [new Cactus(), new Cactus(), new Cactus(), new Cactus()]

object auto {
	var property position = game.at(15,10)
	var property image = "mate.png"
	
	var property carril
	var property agilidad = 1
	var property velocidad
	var property vidas = 1
	var property vidasEnPartida
	var property estadoInmunidad = sinInmunidad
	var property estadoDoblando = noEstaDoblando
	
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
	
	method izquierda() {if (carril > 1) estadoDoblando.doblar(-1)}
	
	method derecha() {if (carril < 3) estadoDoblando.doblar(1)}
	
	method mover(cantidad) {
		position = position.right(cantidad)
		hitboxAuto.actualizar()
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
	
	method avanza() {([fondoJuego] + obstaculos + monedasJuego).forEach{obj => obj.mover()}}
	
	method alChocar() {estadoInmunidad.chocar()}
	
	method seHaceInmune() {
		estadoInmunidad = conInmunidad
		game.schedule(1000, {estadoInmunidad = sinInmunidad})
	}
}

object hitboxAuto {
	var property position = game.at(15,11)
	
	method actualizar() {
		position = auto.position().up(1)
	}
}

object sinInmunidad {
	method chocar() {
		auto.vidasEnPartida(auto.vidasEnPartida()-1)
		auto.seHaceInmune()
		cartelVidas.actualizar()
		corazon.aparece()
		if (auto.vidasEnPartida() == 0) juego.finalizar()
	}
}

object conInmunidad {
	method chocar() {}
}

object noEstaDoblando {
	method doblar(cantidad) {
		auto.estadoDoblando(siEstaDoblando)
		auto.mover(cantidad)
		game.schedule(250 / auto.agilidad(), {
			auto.mover(cantidad)
			auto.carril(auto.carril() + cantidad)
			auto.estadoDoblando(self)
		})
	}
}

object siEstaDoblando {
	method doblar(cantidad) {}
}

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
		lugaresLibres = [4,5,6,7,8]
		barriles.get(contador).aparecer()
		contador++
		self.actualizarLugares(contador - 1)
		if (contador == barriles.size() - 1) {
			barriles.get(contador).aparecer(lugaresLibres)
			self.actualizarLugares(contador)
			vacas.get(ciclos%vacas.size()).aparecer(lugaresLibres)
			contador = 0
			ciclos++
		}
		else {self.generarMonedas()}
	}
	
	method generarMonedas() {
		monedasJuego.get(contador - 1).aparecer(lugaresLibres)
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
			game.schedule(600, {game.removeTickEvent("Aparece tormenta")})
			game.schedule(5500, {self.desaparecer()})
		}
	}
	
	method desaparecer() {
		game.onTick(100, "Desaparece tormenta", {position = position.up(1)})
		game.schedule(600, {game.removeTickEvent("Desaparece tormenta")})
	}
}

const informacion = [cartelContador, contador, mejorPuntuacion, monedasTiendaEnJuego]

const cartelContador = new Visual (position = game.at(11,5), image = "contador.png")

object contador {
	var property position = game.at(13,8)
	var property metros = 0
	
	method text() = metros.toString()
	method textColor() = "744F3A"
	method avanza() {metros++}
	method reiniciar() {metros = 0}
}

object mejorPuntuacion {
	var property position = game.at(13,7)
	var property metros = 0
	method text() = metros.toString()
	method textColor() = "744F3A"
}

object monedasTiendaEnJuego {
	var property position = game.at(13,6)
	method text() = monedasTienda.cantidad().toString()
	method textColor() = monedasTienda.textColor()
}

object corazon {
	var property position
	const property image = "corazon.png"
	
	method reiniciar() {position = game.at(7,10)}
	
	method aparece() {
		self.reiniciar()
		position = position.down(1)
		game.onTick(100, "Aparece corazon", {position = position.down(1)})
		game.schedule(200, {game.removeTickEvent("Aparece corazon")})
		game.schedule(1000, {self.reiniciar()})
	}
}

object cartelVidas {
	const property position = game.at(0,6)
	var property image
	
	method actualizar() {
		image = "cartelVidas" + auto.vidasEnPartida().toString() + ".png"
	}
	
	method reiniciar() {self.actualizar()}
}