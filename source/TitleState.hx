package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var logoSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var easterEggEnabled:Bool = true; //Disable this to hide the easter egg
	var easterEggKeyCombination:Array<FlxKey> = [FlxKey.B, FlxKey.B]; //bb stands for bbpanzu cuz he wanted this lmao
	var lastKeysPressed:Array<FlxKey> = [];

	var mustUpdate:Bool = false;
	public static var updateVersion:String = '';

	override public function create():Void
	{
		#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}
		#end
		
		#if CHECK_FOR_UPDATES
		if(!closedState) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/gitVersion.txt");
			
			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}
			
			http.onError = function (error) {
				trace('error: $error');
			}
			
			http.request();
		}
		#end

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();

		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
			#end
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				startIntro();
			});
		}
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			/*var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
				
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;*/

			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 1);

			}
		}

		Conductor.changeBPM(131/4);
		persistentUpdate = true;
		FlxG.camera.zoom = 1.2;
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stageback'));
		bg.setGraphicSize(Std.int(bg.width*.6));
		bg.x -= 650;
		bg.y -= 300;
		bg.color = FlxColor.fromRGB(100,0,200);
		bg.alpha = 0;
		// bg.antialiasing = ClientPrefs.globalAntialiasing;
		// bg.updateHitbox();
		add(bg);
		//FlxTween.tween(bg, {alpha: 1}, 550, {ease: FlxEase.circOut});

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		swagShader = new ColorSwap();
		if(!FlxG.save.data.psykaEasterEgg || !easterEggEnabled) {
			gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
			gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
			gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		}
		else //Psyka easter egg
		{
			gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.04);
			gfDance.frames = Paths.getSparrowAtlas('psykaDanceTitle');
			gfDance.animation.addByIndices('danceLeft', 'psykaDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			gfDance.animation.addByIndices('danceRight', 'psykaDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		}
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		//add(gfDance);
		gfDance.shader = swagShader.shader;
		//add(logoBl);
		//logoBl.shader = swagShader.shader;

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		//add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		//credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		logoSpr = new FlxSprite(0, FlxG.height * 0.4).loadGraphic(Paths.image('titlelogo'));
		//add(logoSpr);
		logoSpr.visible = false;
		logoSpr.setGraphicSize(Std.int(logoSpr.width * 0.55));
		logoSpr.updateHitbox();
		logoSpr.screenCenter(X);
		logoSpr.antialiasing = ClientPrefs.globalAntialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		// EASTER EGG

		if (!transitioning)
		{
			if(pressedEnter)
			{
				if(titleText != null) titleText.animation.play('press');

				transitioning = true;
				new FlxTimer().start(.1, function(tmr:FlxTimer)
				{
					if (mustUpdate) {
						//RPGState.area = "Ruins1";
						//MusicBeatState.switchState(new OutdatedState());
					} else {
						//FlxG.sound.music.stop();
						MusicBeatState.switchState(new RPGLoadingSaveState());
						//MusicBeatState.switchState(new MainMenuState());
					}
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
			else if(easterEggEnabled)
			{
				var finalKey:FlxKey = FlxG.keys.firstJustPressed();
				if(finalKey != FlxKey.NONE) {
					lastKeysPressed.push(finalKey); //Convert int to FlxKey
					if(lastKeysPressed.length > easterEggKeyCombination.length)
					{
						lastKeysPressed.shift();
					}
					
					if(lastKeysPressed.length == easterEggKeyCombination.length)
					{
						var isDifferent:Bool = false;
						for (i in 0...lastKeysPressed.length) {
							if(lastKeysPressed[i] != easterEggKeyCombination[i]) {
								isDifferent = true;
								break;
							}
						}

						if(!isDifferent) {
							trace('Easter egg triggered!');
							FlxG.save.data.psykaEasterEgg = !FlxG.save.data.psykaEasterEgg;
							FlxG.sound.play(Paths.sound('secretSound'));

							var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
							black.alpha = 0;
							//add(black);
							FlxTween.tween(black, {alpha: 1}, 1, {onComplete:
								function(twn:FlxTween) {
									FlxTransitionableState.skipNextTransIn = true;
									FlxTransitionableState.skipNextTransOut = true;
									MusicBeatState.switchState(new TitleState());
								}
							});
							lastKeysPressed = [];
							closedState = true;
							transitioning = true;
						}
					}
				}
			}
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 800)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false,0.05,.4,"dialogue","White");
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset * .4;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String, ?offset:Float = 800)
	{
		if(textGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false,0.05,.4,"dialogue","White");
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset * .4;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	private static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();
		
		if (sickBeats % 2 == 1)
		{
			//FlxTween.tween(bg, {color: FlxColor.fromRGB(200,0,0)}, 0.5, {ease: FlxEase.circOut});
		}
		else
		{
			//FlxTween.tween(bg, {color: FlxColor.fromRGB(0,0,0)}, 0.5, {ease: FlxEase.circOut});
		}
		if(logoBl != null) 
			logoBl.animation.play('bump');

		if(gfDance != null) {
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		var s1:FlxSprite;
		s1 = new FlxSprite(-80).loadGraphic(Paths.image('Scene1'));
		s1.setGraphicSize(Std.int(s1.width/2));
		s1.updateHitbox();
		s1.screenCenter();
		s1.y -= 100;
		s1.visible = false;
		s1.alpha = 1;

		var s2:FlxSprite;
		s2 = new FlxSprite(-80).loadGraphic(Paths.image('Scene2'));
		s2.setGraphicSize(Std.int(s2.width/2));
		s2.updateHitbox();
		s2.screenCenter();
		s2.y -= 100;
		s2.visible = false;
		s2.alpha = 1;

		var s3:FlxSprite;
		s3 = new FlxSprite(-80).loadGraphic(Paths.image('Scene3'));
		s3.setGraphicSize(Std.int(s3.width/2));
		s3.updateHitbox();
		s3.screenCenter();
		s3.y -= 100;
		s3.visible = false;
		s3.alpha = 1;

		var s4:FlxSprite;
		s4 = new FlxSprite(-80).loadGraphic(Paths.image('Scene4'));
		s4.setGraphicSize(Std.int(s4.width/2));
		s4.updateHitbox();
		s4.screenCenter();
		s4.y -= 100;
		s4.visible = false;
		s4.alpha = 1;

		var s5:FlxSprite;
		s5 = new FlxSprite(-80).loadGraphic(Paths.image('Scene5'));
		s5.setGraphicSize(Std.int(s5.width/2));
		s5.updateHitbox();
		s5.screenCenter();
		s5.y -= 100;
		s5.visible = false;
		s5.alpha = 1;	

		var s6:FlxSprite;
		s6 = new FlxSprite(-80).loadGraphic(Paths.image('Scene6'));
		s6.setGraphicSize(Std.int(s6.width/2));
		s6.updateHitbox();
		s6.screenCenter();
		s6.y -= 100;
		s6.visible = false;
		s6.alpha = 1;

		add(s1);
		add(s2);
		add(s3);
		add(s4);
		add(s5);
		add(s6);

		if(!closedState) {
			sickBeats++;
			switch (sickBeats+2)
			{
				case 3:
					s1.visible = true;
					createCoolText(["Long ago... three races ruled over Earth."]);
				case 4:
					addMoreText("HUMANS. MONSTERS. AND DEMONS.");
				case 6:
					s1.visible = false;
					deleteCoolText();
				case 7:
					s2.visible = true;
					createCoolText(["One day... war broke out between the humans and monsters..."]);
				case 8:
					addMoreText("while Demons were neutral.");
				case 10:
					s2.visible = false;
					deleteCoolText();
				case 11:
					s3.visible = true;
					createCoolText(["After a long battle... the humans were victorious."]);
				case 13:
					s3.visible = false;
					deleteCoolText();
				case 14:
					s4.visible = true;
					createCoolText(["They sealed the monsters underground with a magic spell."]);
				case 17:
					s4.visible = false;
					deleteCoolText();
				case 18:
					createCoolText(["Many years later..."]);
				case 21:
					deleteCoolText();
				case 22:
					s5.visible = true;
					createCoolText(["MT.EBOTT 201X."]);
				case 25:
					s5.visible = false;
					deleteCoolText();
				case 26:
					s6.visible = true;
					createCoolText(["Legends say that those who climb the mountain will never return."]);
				case 29:
					s6.visible = false;
					deleteCoolText();
				case 30:

					MusicBeatState.switchState(new RPGLoadingSaveState());
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(logoSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
