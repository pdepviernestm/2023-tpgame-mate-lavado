import wollok.game.*

object musica {
	
	const cancion = game.sound("Life Is A Highway.mp3")
	var volumen = 0.1
	
	method reproducir() {
		self.actualizarVolumen()
		cancion.play()
		cancion.shouldLoop(true)
	}
	
	method pausar() {
		if (volumen > 0) {
			var volumenProvisorio = volumen
			
			game.onTick(100, "Fade out", {
				volumenProvisorio = volumenProvisorio - volumen / 10
				cancion.volume(volumenProvisorio) })
				
			game.schedule(1000, {
				game.removeTickEvent("Fade out")
				cancion.pause()})
		}
		else
			cancion.pause()
	}
	
	method reanudar() {
		if (volumen > 0) {
			var volumenProvisorio = 0
			
			cancion.volume(volumenProvisorio)
			cancion.resume()
			
			game.onTick(100, "Fade in", {
				volumenProvisorio = volumenProvisorio + volumen / 10
				cancion.volume(volumenProvisorio) })
				
			game.schedule(1000, {
				game.removeTickEvent("Fade in")
			})
		}
		else
			cancion.resume()
	}
	
	method bajarVolumen() {
		if (volumen > 0) {
			volumen = volumen - 0.1
			self.actualizarVolumen()
		}
	}
	
	method subirVolumen() {
		if (volumen < 0.5) {
			volumen = volumen + 0.1
			self.actualizarVolumen()
		}
	}
	
	method actualizarVolumen() {
		cancion.volume(volumen)
	}
}

object bocina {
	const sonido = game.sound("Horn.mp3")
	var property sonando = false
	
	method iniciar() {
		sonido.volume(0)
		sonido.play()
		sonido.shouldLoop(true)
		game.schedule(1900, {sonido.pause() sonido.volume(0.5)})
	}
	
	method tocar() {
		if (not sonando) {
			sonando = true
			sonido.resume()
			game.schedule(1800, {
				sonido.pause()
				sonando = false
			})
		}
	}
}