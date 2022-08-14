package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var stageSuffix:String = "";

	var lePlayState:PlayState;

	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';
	var deathAnim:FlxSprite;
	var gameOver:FlxSprite;

	public static function resetVariables() {
		characterName = 'bf';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float, state:PlayState)
	{
		lePlayState = state;
		state.setOnLuas('inGameOver', true);
		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, characterName);

		camFollow = new FlxPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y);

		FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;



		deathAnim = new FlxSprite().loadGraphic(Paths.image('deathBF'));
		deathAnim.frames = Paths.getSparrowAtlas('deathBF');
		deathAnim.width *= 2;
		deathAnim.height *= 2;
		deathAnim.setGraphicSize(Std.int(deathAnim.width));
		deathAnim.animation.addByPrefix('deathBF', "deathBF", 24,false);
		add(deathAnim);
		deathAnim.screenCenter();
		deathAnim.animation.play('deathBF');
		deathAnim.x += 100;
		deathAnim.y += 100;

		gameOver = new FlxSprite().loadGraphic(Paths.image('gameOver'));
		gameOver.alpha = 0;
		gameOver.screenCenter();
		gameOver.x += 0;
		add(gameOver);
		switch(ClientPrefs.soulColor)
			{
				case 0:
					deathAnim.color = FlxColor.fromRGB(255,0,0);
				case 1:
					deathAnim.color = FlxColor.fromRGB(0,0,255);
				case 2:
					deathAnim.color = FlxColor.fromRGB(0,255,255);
				case 3:
					deathAnim.color = FlxColor.fromRGB(0,255,0);
				case 4:
					deathAnim.color = FlxColor.fromRGB(255,0,255);
				case 5:
					deathAnim.color = FlxColor.fromRGB(255,125,0);
				case 6:
					deathAnim.color = FlxColor.fromRGB(255,255,0);
				case 7:
					deathAnim.color = FlxColor.fromRGB(125,125,125);
				default:
					deathAnim.color = FlxColor.fromRGB(255,0,0);
				
			}
		var exclude:Array<Int> = [];

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);

		FlxTween.tween(deathAnim, {alpha: 1}, 2.5, 
		{onComplete: function (twn:FlxTween) 
			{
				coolStartDeath();
				bf.startedDeath = true;
				FlxTween.tween(gameOver, {alpha: 1}, 1);
			}
		}
		);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		lePlayState.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (bf.animation.curAnim.name == 'firstDeath')
		{
			if(bf.animation.curAnim.curFrame == 12)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
			}

			if (deathAnim.animation.curAnim.finished)
			{
				coolStartDeath();
				bf.startedDeath = true;
				FlxTween.tween(gameOver, {alpha: 1}, 1);
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		lePlayState.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;


			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			lePlayState.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}
