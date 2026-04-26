package backend.game;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxGradient;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup;
import backend.game.MusicBeatData.MusicBeatSubState;

class GameTransition extends MusicBeatSubState
{	
	var fadeOut:Bool = false;
	var transition:String = 'cubes'; // Forçamos o padrão para 'cubes'
	
	public var finishCallback:Void->Void;
	var cubeGroup:FlxTypedGroup<FlxSprite>;
	
	public function new(fadeOut:Bool = true, transition:String = "cubes")
	{
		super();
		this.fadeOut = fadeOut;
		// Mesmo que venha outro nome, vamos usar 'cubes' para testar
		this.transition = 'cubes'; 

		switch(this.transition) {
			case 'cubes':
				cubeGroup = new FlxTypedGroup<FlxSprite>();
				add(cubeGroup);

				var size:Int = 120; 
				var cols:Int = Math.ceil(FlxG.width / size) + 1;
				var rows:Int = Math.ceil(FlxG.height / size);
				
				for (row in 0...rows) {
					for (col in 0...cols) {
						// Posições para varredura (Sweep)
						var targetX:Float = col * size;
						// Se for Entrada: vem da direita. Se for Saída: começa na posição e vai para esquerda.
						var startX:Float = fadeOut ? targetX : FlxG.width + size;
						var endX:Float = fadeOut ? -FlxG.width - (size * 2) : targetX;
						
						var cube:FlxSprite = new FlxSprite(startX, row * size).makeGraphic(size, size, 0xFF000000);
						cubeGroup.add(cube);
						
						// O delay cria o efeito de onda
						var delay:Float = (fadeOut ? (cols - col) : col) * 0.04;
						
						FlxTween.tween(cube, {x: endX}, 0.6, {
							ease: FlxEase.cubeInOut,
							startDelay: delay,
							onComplete: function(twn:FlxTween) {
								// Verifica se é o último cubo para fechar
								if (row == rows - 1 && (fadeOut ? col == 0 : col == cols - 1)) {
									endTransition();
								}
							}
						});
					}
				}
			default:
				// Caso queira manter o fade simples como backup
				var sprBlack = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
				sprBlack.screenCenter();
				add(sprBlack);
				sprBlack.alpha = (fadeOut ? 1 : 0);
				FlxTween.tween(sprBlack, {alpha: fadeOut ? 0 : 1}, 0.32, {onComplete: function(twn:FlxTween) { endTransition(); }});
		}
	}

	function endTransition() {
		if(finishCallback != null) finishCallback();
		else close();
	}
	
	override function update(elapsed:Float) {
		super.update(elapsed);
		if (FlxG.cameras.list.length > 0)
			this.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}
}

