package backend.game;

import flixel.FlxSprite;
import flixel.util.FlxGradient;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup;
import backend.game.MusicBeatData.MusicBeatSubState;

class GameTransition extends MusicBeatSubState
{	
	var fadeOut:Bool = false;
	var transition:String = 'funkin';
	
	public var finishCallback:Void->Void;

	var sprBlack:FlxSprite;
	var sprGrad:FlxSprite;
	// Grupo para organizar os cubos
	var cubeGroup:FlxTypedGroup<FlxSprite>;
	
	public function new(fadeOut:Bool = true, transition:String = "funkin")
	{
		super();
		this.fadeOut = fadeOut;
		this.transition = transition;

		switch(transition) {
			case 'cubes':
				cubeGroup = new FlxTypedGroup<FlxSprite>();
				add(cubeGroup);

				var size:Int = 120; // Tamanho de cada cubo
				var cols:Int = Math.ceil(FlxG.width / size) + 1;
				var rows:Int = Math.ceil(FlxG.height / size);
				
				for (row in 0...rows) {
					for (col in 0...cols) {
						// Lógica de Varredura:
						// Se for entrada (fadeOut=false): vem da Direita (Width) para sua posição (col*size)
						// Se for saída (fadeOut=true): sai da sua posição para a Esquerda (-Width)
						var targetX:Float = col * size;
						var startX:Float = fadeOut ? targetX : FlxG.width + size;
						var endX:Float = fadeOut ? -FlxG.width - (size * 2) : targetX;
						
						var cube:FlxSprite = new FlxSprite(startX, row * size).makeGraphic(size, size, 0xFF000000);
						cubeGroup.add(cube);
						
						// Delay baseado na coluna para criar o efeito de "onda" da direita para esquerda
						var delay:Float = (fadeOut ? (cols - col) : col) * 0.04;
						
						FlxTween.tween(cube, {x: endX}, 0.7, {
							ease: FlxEase.cubeInOut,
							startDelay: delay,
							onComplete: function(twn:FlxTween) {
								// Finaliza quando o último cubo terminar o movimento
								if (row == rows - 1 && (fadeOut ? col == 0 : col == cols - 1)) {
									endTransition();
								}
							}
						});
					}
				}

			case 'funkin':
				// Código original do funkin...
				sprBlack = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
				sprBlack.screenCenter(X);
				add(sprBlack);
				
				sprGrad = FlxGradient.createGradientFlxSprite(FlxG.width, Math.floor(FlxG.height / 2), [0xFF000000, 0x00], 1, 90);
				sprGrad.screenCenter(X);
				sprGrad.flipY = fadeOut;
				add(sprGrad);
				
				var yPos:Array<Float> = [
					-sprBlack.height - sprGrad.height - 40,
					FlxG.height / 2 - sprBlack.height / 2,
					FlxG.height + sprGrad.height + 40
				];
				var curY:Int = (fadeOut ? 1 : 0);
				
				sprBlack.y = yPos[curY];
				updateGradPos();

				FlxTween.tween(sprBlack, {y: yPos[curY + 1]}, fadeOut ? 0.6 : 0.8, {
					onComplete: function(twn:FlxTween) {
						endTransition();
					}
				});

			default:
				sprBlack = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
				sprBlack.screenCenter();
				add(sprBlack);
				
				sprBlack.alpha = (fadeOut ? 1 : 0);
				FlxTween.tween(sprBlack, {alpha: fadeOut ? 0 : 1}, 0.32, {
					onComplete: function(twn:FlxTween) {
						endTransition();
					}
				});
		}
	}

	function endTransition()
	{
		if(finishCallback != null)
			finishCallback();
		else
			close();
	}
	
	function updateGradPos():Void {
		if (sprGrad != null && sprBlack != null)
			sprGrad.y = sprBlack.y + (fadeOut ? -sprGrad.height : sprBlack.height);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		this.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		if (transition == 'funkin') updateGradPos();
	}
}

