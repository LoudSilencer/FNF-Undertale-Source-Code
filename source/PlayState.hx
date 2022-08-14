package;

#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;

#if sys
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState

{
	public static var STRUM_X = 42;
	public static var choice:String = "";
	public static var STRUM_X_MIDDLESCROLL = -278;
	public var soul:FlxSprite;
	var torielDeath:FlxSprite;
	var torielGeno:FlxSprite;
	public var soulAppear:FlxSprite;
	public var curLight:Int = 0;
	public var curLightEvent:Int = 0;
	public var soulBoard:FlxSprite;
	public var didAllDialogue:Bool = false;
	public var slashAttackk:FlxSprite;
	private var vignetteCamera:FlxCamera;
	public static var soulCamera:FlxCamera;
	public var isSoul:Bool = false;
	public var projectileArray:Array<FlxSprite> = [];
	public var blueArray:Array<FlxSprite> = [];	
	public var orangeArray:Array<FlxSprite> = [];	
	public var healArray:Array<FlxSprite> = [];
	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Full Clear!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];
	
	#if (haxe >= "4.0.0")
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	#else
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, Dynamic>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	#end
	public var bg:FlxSprite;
	public var hellTime:Float = 3;
	public var phase1:Bool = false;
	public var phase2:Bool = false;
	public var phase3:Bool = false;
	public var phase4:Bool = false;

	public var bgVigniette:FlxSprite;
	public var lines:FlxSprite;
	public var fire:FlxSprite;
	public var bg2:FlxSprite;

	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;
	public var gotHit:Int = 0;
	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	var wFlash:FlxSprite;

	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var isRPG:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var songName:String = "";

	public var vocals:FlxSound;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;


	var minXProjectile:Float = 0;
	var maxXProjectile:Float = 0;
	var minYProjectile:Float = 0;
	var maxYProjectile:Float = 0;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<Dynamic> = [];

	private var strumLine:FlxSprite;
	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;
	private static var resetSpriteCache:Bool = false;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 2;
	public var enemyhealth:Float = 25;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;

	private var enemyhealthBarBG:AttachedSprite;
	public var enemyhealthBar:FlxBar;

	public var HPText:FlxText;
	public var HealthText:FlxText;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	private var startingSong:Bool = false;
	private var updateTime:Bool = false;
	public static var practiceMode:Bool = false;
	public static var usedPractice:Bool = false;
	public static var changedDifficulty:Bool = false;
	public static var cpuControlled:Bool = false;

	var botplaySine:Float = 0;
	var botplayTxt:FlxText;
	var spawnedsoul = false;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyCityLights:FlxTypedGroup<BGSprite>;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:ModchartSprite;
	var blammedLightsBlackTween:FlxTween;
	var phillyCityLightsEvent:FlxTypedGroup<BGSprite>;
	var phillyCityLightsEventTween:FlxTween;
	var trainSound:FlxSound;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;
	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var songSoul:Int = 0;
	public var ghostMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;
	var healthBarTween:FlxTween;
	public var pauseMusic = new FlxSound().loadEmbedded(Paths.music('scaryLoop'), true, true);

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;
	public static var savedTime:Float = 0;
	public static var savedBeat:Int = 0;
	public static var savedStep:Int = 0;
	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	public var jumping:Bool = false;
	public var inCutscene:Bool = false;
	var songLength:Float = 0;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public static var luaArray:Array<FunkinLua> = [];

	//Achievement shit
	var keysPressed:Array<Bool> = [false, false, false, false];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';



	var heartNote:Int = 1;

	var lightningSlow:Bool = false;
	var lightningSequence:Bool = false;
	var lightningFast:Bool = false;
	var lightningTriple:Bool = false;
	var lightningTripleBreakbeat:Bool = false;
	var lightningAll:Bool = false;
	var lightningUnfair:Bool = false;
	var warningFirst:Bool = false;

	public function changeHeartNote(direction) 
	{
		heartNote = direction;

	}
	var trailShit:FlxTrail;

	var fstatic:FlxSprite = new FlxSprite();
	var originalY:Float;

	override public function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages(resetSpriteCache);
		#end
		resetSpriteCache = false;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		practiceMode = false;
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		soulCamera = new FlxCamera();
		soulCamera.bgColor.alpha = 0;
		vignetteCamera = new FlxCamera();
		vignetteCamera.bgColor.alpha = 0;
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(soulCamera);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		FlxG.cameras.add(vignetteCamera);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = '' + CoolUtil.difficultyStuff[storyDifficulty][0];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode";
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		songName = Paths.formatToSongPath(SONG.song);
		curStage = PlayState.SONG.stage;
		trace('stage is: ' + curStage);
		if(PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1) {
			switch (songName)
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				default:
					curStage = 'stage';
			}
		}

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,
			
				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100]
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'stage': //Week 1
				bg = new FlxSprite().loadGraphic(Paths.image('stageback'));
				bg.width = 900;
				bg.height = 300;
				bg.x = -3000;
				bg.y = -1700;
				bg.color = FlxColor.fromRGB(0,0,0);
				add(bg);
				if((Paths.formatToSongPath(curSong) == "tutorial")){
					bg.color = FlxColor.fromRGB(50,0,120);
				}




				
			case 'ruins':
				bg = new FlxSprite().loadGraphic(Paths.image('Ruins'));
				bg.screenCenter();
				bg.setGraphicSize(Std.int(bg.width * 0.6));
				bg.y -= 50;
				add(bg);
			case 'empty':
				bg = new FlxSprite().loadGraphic(Paths.image('empty'));
				bg.screenCenter();
				bg.setGraphicSize(Std.int(bg.width * 0.6));
				bg.y -= 50;
				add(bg);
			case 'hell':
				bg = new FlxSprite().loadGraphic(Paths.image('ruinsOutside'));
				bg.screenCenter();
				bg.setGraphicSize(Std.int(bg.width * 0.6));
				add(bg);

				bgVigniette = new FlxSprite().loadGraphic(Paths.image('vignette'));
				bgVigniette.screenCenter();
				bgVigniette.alpha = 0;
				bgVigniette.cameras = [camHUD];
				add(bgVigniette);
				fire = new FlxSprite().loadGraphic(Paths.image('firewall'));
				fire.frames = Paths.getSparrowAtlas('firewall');
				fire.animation.addByPrefix('fire', 'fire', 24, true);
				fire.setGraphicSize(Std.int(fire.width * 1));
				fire.updateHitbox();
				fire.screenCenter();
				fire.alpha = 0;
				fire.y -= 100;
				add(fire);
				fire.animation.play('fire',true);
	
				bg2 = new FlxSprite().loadGraphic(Paths.image('ruinsOutsideFloor'));
				bg2.screenCenter();
				bg2.setGraphicSize(Std.int(bg2.width * 0.6));
				add(bg2);


				bg = new FlxSprite().loadGraphic(Paths.image('RuinsDoor'));
				bg.screenCenter();
				bg.setGraphicSize(Std.int(bg.width * 0.55));
				bg.alpha = 0;
				add(bg);
			case 'ruinsdoor':

				lines = new FlxSprite().loadGraphic(Paths.image('lines'));
				lines.frames = Paths.getSparrowAtlas('lines');
				lines.animation.addByPrefix('lines', 'lines', 36, true);
				lines.setGraphicSize(Std.int(lines.width * 1.10));
				lines.updateHitbox();
				lines.screenCenter();
				lines.color = FlxColor.fromRGB(0,90,0);
				add(lines);
				if (ClientPrefs.flashing)
					lines.animation.play('lines',true);

				fire = new FlxSprite().loadGraphic(Paths.image('firewall'));
				fire.frames = Paths.getSparrowAtlas('firewall');
				fire.animation.addByPrefix('fire', 'fire', 24, true);
				fire.setGraphicSize(Std.int(fire.width * 1));
				fire.updateHitbox();
				fire.screenCenter();
				fire.y += 500;
				add(fire);
				fire.animation.play('fire',true);

				bg = new FlxSprite().loadGraphic(Paths.image('RuinsDoor'));
				bg.screenCenter();
				bg.setGraphicSize(Std.int(bg.width * 0.55));
				add(bg);
			case 'hall':
				bg = new FlxSprite().loadGraphic(Paths.image('hall'));
				bg.screenCenter();
				bg.setGraphicSize(Std.int(bg.width * 0.85));
				add(bg);
			case 'spooky': //Week 2
				if(!ClientPrefs.lowQuality) {
					halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
				} else {
					halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
				}
				add(halloweenBG);

				halloweenWhite = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;

				//PRECACHE SOUNDS
				CoolUtil.precacheSound('thunder_1');
				CoolUtil.precacheSound('thunder_2');

			case 'philly': //Week 3
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
					add(bg);
				}

				var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyCityLights = new FlxTypedGroup<BGSprite>();
				add(phillyCityLights);

				for (i in 0...5)
				{
					var light:BGSprite = new BGSprite('philly/win' + i, city.x, city.y, 0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					phillyCityLights.add(light);
				}

				if(!ClientPrefs.lowQuality) {
					var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
					add(streetBehind);
				}

				phillyTrain = new BGSprite('philly/train', 2000, 360);
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				CoolUtil.precacheSound('train_passes');
				FlxG.sound.list.add(trainSound);

				var street:BGSprite = new BGSprite('philly/street', -40, 50);
				add(street);

			case 'limo': //Week 4
				var skyBG:BGSprite = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
				add(skyBG);

				if(!ClientPrefs.lowQuality) {
					limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
					add(limoMetalPole);

					bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
					add(bgLimo);

					limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BGSprite>();
					add(grpLimoParticles);

					//PRECACHE BLOOD
					var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					//PRECACHE SOUND
					CoolUtil.precacheSound('dancerdeath');
				}

				limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);

				fastCar = new BGSprite('limo/fastCarLol', -300, 160);
				fastCar.active = true;
				limoKillingState = 0;

			case 'mall': //Week 5 - Cocoa, Eggnog
				var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if(!ClientPrefs.lowQuality) {
					upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}

				var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
				add(tree);

				bottomBoppers = new BGSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers Idle']);
				bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
				add(fgSnow);

				santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
				add(santa);
				CoolUtil.precacheSound('Lights_Shut_off');

			case 'mallEvil': //Week 5 - Winter Horrorland
				var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
				add(evilTree);

				var evilSnow:BGSprite = new BGSprite('christmas/evilSnow', -200, 700);
				add(evilSnow);

			case 'school': //Week 6 - Senpai, Roses
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
				add(bgSky);
				bgSky.antialiasing = false;

				var repositionShit = -200;

				var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
				add(bgSchool);
				bgSchool.antialiasing = false;

				var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
				add(bgStreet);
				bgStreet.antialiasing = false;

				var widShit = Std.int(bgSky.width * 6);
				if(!ClientPrefs.lowQuality) {
					var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);
					fgTrees.antialiasing = false;
				}

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);
				bgTrees.antialiasing = false;

				if(!ClientPrefs.lowQuality) {
					var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					add(treeLeaves);
					treeLeaves.antialiasing = false;
				}

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));

				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();

				if(!ClientPrefs.lowQuality) {
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}

			case 'schoolEvil': //Week 6 - Thorns
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				/*if(!ClientPrefs.lowQuality) { //Does this even do something?
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
				}*/

				var posX = 400;
				var posY = 200;
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);

					bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					add(bgGhouls);
				} else {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);
				}
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dadGroup);
		add(boyfriendGroup);

		
		if(curStage == 'spooky') {
			add(halloweenWhite);
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(curStage == 'philly') {
			phillyCityLightsEvent = new FlxTypedGroup<BGSprite>();
			for (i in 0...5)
			{
				var light:BGSprite = new BGSprite('philly/win' + i, -10, 0, 0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				phillyCityLightsEvent.add(light);
			}
		}
		
		if(doPush) 
			luaArray.push(new FunkinLua(luaFile));

		if(!modchartSprites.exists('blammedLightsBlack')) { //Creates blammed light black fade in case you didn't make your own
			blammedLightsBlack = new ModchartSprite(FlxG.width * -0.5, FlxG.height * -0.5);
			blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
			var position:Int = members.indexOf(gfGroup);
			if(members.indexOf(boyfriendGroup) < position) {
				position = members.indexOf(boyfriendGroup);
			} else if(members.indexOf(dadGroup) < position) {
				position = members.indexOf(dadGroup);
			}
			insert(position, blammedLightsBlack);

			blammedLightsBlack.wasAdded = true;
			modchartSprites.set('blammedLightsBlack', blammedLightsBlack);
		}
		if(curStage == 'philly') insert(members.indexOf(blammedLightsBlack) + 1, phillyCityLightsEvent);
		blammedLightsBlack = modchartSprites.get('blammedLightsBlack');
		blammedLightsBlack.alpha = 0.0;
		#end

		var gfVersion:String = SONG.player3;
		if(gfVersion == null || gfVersion.length < 1) {
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				default:
					gfVersion = 'gf';
			}
			SONG.player3 = gfVersion; //Fix for the Chart Editor
		}

		gf = new Character(0, 0, gfVersion);
		gf.alpha = 0;
		startCharacterPos(gf);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(0, 0, SONG.player2);
		if (SONG.player2 == "derpToriel")
		{
			dad.color = FlxColor.fromRGB(0,0,0);
		} 
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		gfGroup.add(gf);

		fstatic = new FlxSprite().loadGraphic(Paths.image('FloweyStatic'));
		fstatic.width = 900;
		fstatic.height = 300;
		fstatic.scrollFactor.set(0,0);
		fstatic.setGraphicSize(Std.int(fstatic.width * 8.3));
		fstatic.alpha = 0;
		originalY = fstatic.y;
		add(fstatic);

		wFlash = new FlxSprite().loadGraphic(Paths.image('flashWhite'));
		wFlash.cameras = [camHUD];
		wFlash.width *= 20;
		wFlash.height *= 20;
		wFlash.setGraphicSize(Std.int(wFlash.width));
		wFlash.updateHitbox();
		wFlash.scrollFactor.set(0,0);
		wFlash.alpha = 0;
		add(wFlash);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		if (Paths.formatToSongPath(curSong) == 'challenge1')
		{
			dad.alpha = 0;
			boyfriend.alpha = 0;
		}
		var camPos:FlxPoint = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		camPos.x += gf.cameraPosition[0];
		camPos.y += gf.cameraPosition[1];

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			gf.visible = false;
		}

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				insert(members.indexOf(gfGroup) - 1, fastCar);
			
			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				insert(members.indexOf(dadGroup) - 1, evilTrail);
		}
		var typeCount = "";
		switch(deathCounter)
		{
			case 0:
				typeCount = "1";
			case 1:
				typeCount = "2";
			case 2:
				typeCount = "3";
			case 3:
				typeCount = "4";
			case 4:
				typeCount = "5";
			default:
				typeCount = "6";
		}
		var file:String = Paths.json(songName + '/dialogue' + typeCount); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}
		var counter = deathCounter;
		if (counter > 6)
			counter = 6;
		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue' + counter); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();




		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 20, 400, "", 32);
		timeTxt.setFormat(Paths.font("undertale.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = !ClientPrefs.hideTime;



		
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 45;
		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = !ClientPrefs.hideTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = !ClientPrefs.hideTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys()) {
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad)) {
				luaArray.push(new FunkinLua(luaToLoad));
			}
		}
		for (event in eventPushedMap.keys()) {
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad)) {
				luaArray.push(new FunkinLua(luaToLoad));
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		if (Paths.formatToSongPath(curSong) == 'hopes-and-dreams' || Paths.formatToSongPath(curSong) == 'your-worst-nightmare')
		{
			FlxG.camera.zoom = .35;
		}
		else
		{
			FlxG.camera.zoom = .9;
		}
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);


		enemyhealthBarBG = new AttachedSprite('healthBar');
		enemyhealthBarBG.y = FlxG.height * 0.89;
		enemyhealthBarBG.screenCenter();
		enemyhealthBarBG.scrollFactor.set();
		enemyhealthBarBG.visible = true;
		enemyhealthBarBG.xAdd = -4;
		enemyhealthBarBG.yAdd = -4;

		add(enemyhealthBarBG);


		enemyhealthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y - 300, LEFT_TO_RIGHT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height + 30), this,
		'enemyhealth', 0, 25);
		enemyhealthBar.scrollFactor.set();
		enemyhealthBar.visible = true;
		add(enemyhealthBar);
		enemyhealthBarBG.sprTracker = enemyhealthBar;

		enemyhealthBarBG.alpha = 0;
		enemyhealthBar.alpha = 0;

		

		HPText = new FlxText(0, healthBarBG.y + 36, FlxG.width, "HP", 20);
		HPText.setFormat(Paths.font("undertale.ttf"), 35, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		HPText.y = FlxG.height * 0.89;
		HPText.screenCenter(X);
		HPText.x -= (healthBarBG.width/2) + 30;
		HPText.y -= 13;
		add(HPText);


		HealthText = new FlxText(0, healthBarBG.y + 36, FlxG.width, "20/20", 20);
		HealthText.setFormat(Paths.font("undertale.ttf"), 35, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		HealthText.y = FlxG.height * 0.89;
		HealthText.screenCenter(X);
		HealthText.x += (healthBarBG.width/2) + 50;
		HealthText.y -= 13;
		add(HealthText);

		if(ClientPrefs.downScroll) {
			healthBarBG.y = 0.11 * FlxG.height;
			HealthText.y = healthBarBG.y;
			HPText.y = healthBarBG.y;
		}

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, LEFT_TO_RIGHT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.visible = !ClientPrefs.hideHud;
		//add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.visible = !ClientPrefs.hideHud;
		//add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("undertale.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("undertale.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		HPText.cameras = [camHUD];
		HealthText.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		updateTime = true;

		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'data/' + Paths.formatToSongPath(SONG.song) + '/script.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		
		if(doPush) 
			luaArray.push(new FunkinLua(luaFile));
		#end
		
		var daSong:String = Paths.formatToSongPath(curSong);
		if (true)
		{
			switch (daSong)
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							remove(blackScreen);
						}
					});
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					snapCamFollowToPos(400, -2050);
					FlxG.camera.focusOn(camFollow);
					FlxG.camera.zoom = .35;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				case 'hopes-and-dreams':
					startDialogue(dialogueJson);
					trace("Started Dialogue!");

				case 'senpai' | 'tutoriel' | 'howdy' | 'spooky-shuffle' | 'dummy':
					startDialogue(dialogueJson);
					trace("Started Dialogue!");
				default:
				{
					startCountdown();
				}
			}
			if (deathCounter > 6)
			{
				seenCutscene = true;
			}
		} else {
			startCountdown();
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3');

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
		super.create();
	}


	function doStar()
	{
		var daSign:FlxSprite =  new FlxSprite().loadGraphic(Paths.image('star'));
		var starSize = FlxG.random.float(.5, 1.5);
		var time = FlxG.random.float(2.1,3.1);
		daSign.setGraphicSize(Std.int(daSign.width * starSize));
		daSign.cameras = [camHUD];
		add(daSign);
		var randomX = FlxG.random.float(-500,500);
		var randomY = FlxG.random.float(-500,500);
		daSign.x = 3000 + randomX;
		daSign.y = -500 + randomY;
		FlxTween.angle(daSign, 0, 720, time, {ease: FlxEase.quintOut});
		FlxTween.tween(daSign, {y: 1000+ randomX,x: -3000 + randomY}, time, {
			onComplete: function(twn:FlxTween)
			{
				remove(daSign);
			}
		});
	}

	
	function doStarSmall()
	{
		var daSign:FlxSprite =  new FlxSprite().loadGraphic(Paths.image('star'));
		var starSize = FlxG.random.float(.2, .4);
		daSign.alpha = .5;
		var time = FlxG.random.float(1.1,2.1);
		daSign.setGraphicSize(Std.int(daSign.width * starSize));
		daSign.cameras = [camGame];
		add(daSign);
		var randomX = FlxG.random.float(-500,500);
		var randomY = FlxG.random.float(-500,500);
		daSign.x = 3000 + randomX;
		daSign.y = -500 + randomY;
		FlxTween.angle(daSign, 0, 720, time, {ease: FlxEase.quintOut});
		FlxTween.tween(daSign, {y: 1000+ randomX,x: -3000 + randomY}, time, {
			onComplete: function(twn:FlxTween)
			{
				remove(daSign);
			}
		});
	}

	function doPellet()
	{
		var daSign:FlxSprite =  new FlxSprite().loadGraphic(Paths.image('pellet'));
		var starSize = FlxG.random.float(.2, .4);
		daSign.alpha = .5;
		var time = FlxG.random.float(1.1,2.1);
		daSign.setGraphicSize(Std.int(daSign.width * starSize));
		daSign.cameras = [camGame];
		add(daSign);
		var randomX = FlxG.random.float(-500,500);
		var randomY = FlxG.random.float(-500,500);
		daSign.x = 3000 + randomX;
		daSign.y = -500 + randomY;
		FlxTween.tween(daSign, {y: 1000+ randomX,x: -3000 + randomY}, time, {
			onComplete: function(twn:FlxTween)
			{
				remove(daSign);
			}
		});
	}
	function doThunder()
	{
		var daSign:FlxSprite =  new FlxSprite().loadGraphic(Paths.image('thunder'));
		var starSize = FlxG.random.float(4.1, 8.1);
		daSign.alpha = .5;
		var time = FlxG.random.float(.1,.5);
		daSign.setGraphicSize(Std.int(daSign.width * starSize));
		daSign.cameras = [camGame];
		add(daSign);
		var randomX = FlxG.random.float(-3000,3000);
		var randomY = FlxG.random.float(-1000,1000);
		daSign.x = 0 + randomX;
		FlxTween.tween(daSign, {alpha: 0,width: 1}, time, {
			onComplete: function(twn:FlxTween)
			{
				remove(daSign);
			}
		});
	}

		function doVine()
	{
		var daSign:FlxSprite =  new FlxSprite().loadGraphic(Paths.image('avine'));
		var starSize = FlxG.random.float(4.1, 8.1);
		daSign.alpha = .5;
		var time = FlxG.random.float(.1,.5);
		daSign.setGraphicSize(Std.int(daSign.width * starSize));
		daSign.cameras = [camGame];
		add(daSign);
		var randomX = FlxG.random.float(-3000,3000);
		var randomY = FlxG.random.float(-1000,1000);
		daSign.x = 0 + randomX;
		FlxTween.tween(daSign, {alpha: 0,width: 1}, time, {
			onComplete: function(twn:FlxTween)
			{
				remove(daSign);
			}
		});
	}
	function doBullet()
	{
		var daSign:FlxSprite =  new FlxSprite().loadGraphic(Paths.image('bullet'));
		var starSize = FlxG.random.float(.31, .51);
		daSign.alpha = .7;
		var time = FlxG.random.float(.51,.71);
		daSign.setGraphicSize(Std.int(daSign.width * starSize));
		daSign.cameras = [camGame];
		add(daSign);
		daSign.x = 0;
		daSign.y =0;
		var rotateRat = curStep;
		var randomY = 0 + -Math.sin(rotateRat * 2) * 600;
		var randomX = 0 -Math.cos(rotateRat) * 600;
		FlxTween.angle(daSign, 0, 720, time, {ease: FlxEase.quintOut});
		FlxTween.tween(daSign, {y: 0+ randomX * 5,x: 0 + randomY * 5}, time, {
			onComplete: function(twn:FlxTween)
			{
				remove(daSign);
			}
		});
	}
		function doBullet2()
	{
		var daSign:FlxSprite =  new FlxSprite().loadGraphic(Paths.image('bullet'));
		var starSize = FlxG.random.float(.31, .41);
		daSign.alpha = .7;
		var time = FlxG.random.float(.51,.71);
		daSign.setGraphicSize(Std.int(daSign.width * starSize));
		daSign.cameras = [camGame];
		add(daSign);
		daSign.x = 0;
		daSign.y =0;
		var rotateRat = curStep;
		var randomY = 0 + -Math.sin(rotateRat * 2) * 600;
		var randomX = 0 -Math.cos(rotateRat) * 600;
		FlxTween.angle(daSign, 0, 720, time, {ease: FlxEase.quintOut});
		FlxTween.tween(daSign, {y: 0+ -randomX * 5,x: 0 + -randomY * 5}, time, {
			onComplete: function(twn:FlxTween)
			{
				remove(daSign);
			}
		});
	}
	function doBone()
	{
		var daSign:FlxSprite =  new FlxSprite().loadGraphic(Paths.image('bonewall'));
		var time = 4;
		var starSize = 1;
		daSign.setGraphicSize(Std.int(daSign.width * starSize));
		daSign.cameras = [camHUD];
		add(daSign);
		daSign.x = 2000;
		var randomY = 0;
		if (curStep % 16 < 8)
		{
			randomY = 100 * (curStep % 16);
		}
		else
		{
			randomY = 800 - (100 * (curStep % 8)); 
		}
		daSign.y = randomY - 600;
		FlxTween.tween(daSign, {x: -3000}, time, {
			onComplete: function(twn:FlxTween)
			{
				remove(daSign);
			}
		});
	}
	public function hitNumbers(){
		var seperatedScore:Array<Int> = [];

		var damage = FlxG.random.int(30, 150);
		seperatedScore.push(Math.floor(damage / 100) % 10);
		seperatedScore.push(Math.floor(damage / 10) % 10);
		seperatedScore.push(damage % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
			numScore.screenCenter();
			numScore.x += (100 * daLoop) - 90;
			numScore.y += 80;
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.hideHud;
			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
	}
	public function enemyShake(){
		hitNumbers();
		shakeEnemy = false;
		FlxG.sound.play(Paths.sound('knifeHit'));
		FlxG.camera.shake(0.01, .2);
		slashAttackk.alpha = 0;
		enemyhealthBar.alpha = 1;
		
		if(healthBarTween != null) {
				healthBarTween.cancel();
			}
			healthBarTween = FlxTween.tween(enemyhealthBar, {alpha: 1}, .1, {
			onComplete: function(twn:FlxTween) {
				FlxTween.tween(enemyhealthBar, {alpha: 0}, .5);
				}
				});
		
	}
	public function fightNote() {
		shakeEnemy = true;
		FlxG.sound.play(Paths.sound('knifeSlash'));
		slashAttackk.alpha = 1;
		slashAttackk.animation.play('Slash');	
	}
	public function addTextToDebug(text:String) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});
		luaDebugGroup.add(new DebugLuaText(text, luaDebugGroup));
		#end
	}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(255, 0, 0),
			FlxColor.fromRGB(255, 255, 0));
		healthBar.updateBar();

		enemyhealthBar.createFilledBar(FlxColor.fromRGB(100, 100, 100),
			FlxColor.fromRGB(0, 255, 0));
		enemyhealthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					newBoyfriend.alreadyLoaded = false;
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					newDad.alreadyLoaded = false;
				}

			case 2:
				if(!gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					newGf.alreadyLoaded = false;
				}
		}
	}
	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String):Void {
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
		#if sys
		if(FileSystem.exists(fileName)) {
			foundFile = true;
		}
		#end

		if(!foundFile) {
			fileName = Paths.video(name);
			#if sys
			if(FileSystem.exists(fileName)) {
			#else
			if(OpenFlAssets.exists(fileName)) {
			#end
				foundFile = true;
			}
		}

		if(foundFile) {
			inCutscene = true;
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				remove(bg);
				if(endingSong) {
					endSong();
				} else {
					startCountdown();
				}
			}
			return;
		} else {
			FlxG.log.warn('Couldnt find video file: ' + fileName);
		}
		#end
		if(endingSong) {
			endSong();
		} else {
			startCountdown();
		}
	}

	var dialogueCount:Int = 0;

	public function backToOver(){
		MusicBeatState.switchState(new RPGState());
	}
	public function torielThenOver(){
		flashWhite(); 
		dad.color = FlxColor.fromRGB(255,255,255);
		FlxTween.tween(dad, {alpha: 0}, 1, {
		startDelay: 0.1,ease: FlxEase.linear,
							onComplete: function(twn:FlxTween)
							{
								MusicBeatState.switchState(new RPGState());
							}});
	}
	public function unlockFreeplaySong(song:String = null)
	{
		switch(song)
		{
			case("howdy"):
				FlxG.save.data.didHowdy = true; 
			case("tutoriel"):
				FlxG.save.data.didTutoriel = true; 
			case("whimsum"):
				FlxG.save.data.didWhimsum = true; 
			case("froggit"):
				FlxG.save.data.didFroggit = true; 
			case("dummy"):
				FlxG.save.data.didDummy = true; 
			case("mychild"):
				FlxG.save.data.didMyChild = true; 
			case("ruins1"):
				FlxG.save.data.didRuins1 = true; 
			case("spooky-shuffle"):
				FlxG.save.data.didSpookyShuffle = true; 
			case("heartache"):
				FlxG.save.data.didHeartache = true; 
			case("soulbreak"):
				FlxG.save.data.didSoulbreak = true; 
			default:
				trace("Nah");
		}

	}
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(dialogueFile.dialogue.length > 0) {
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			var doof:DialogueBoxPsych = new DialogueBoxPsych(dialogueFile, song);
			doof.scrollFactor.set();
			if(endingSong) {
				doof.finishThing = endSong;
			} else {
				doof.finishThing = startCountdown;
			}
			doof.nextDialogueThing = startNextDialogue;
			doof.skipDialogueThing = skipDialogue;
			doof.cameras = [camHUD];
			add(doof);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}
	public function beginDerp()
	{
		pauseMusic.stop();
		var name:String = "mychild";
		var poop = Highscore.formatSong("mychild", 1);

		PlayState.SONG = Song.loadFromJson(poop, name);
		PlayState.isRPG = true;
		PlayState.storyDifficulty = 1;
		LoadingState.loadAndSwitchState(new PlayState());
		
	}
	public function startEndDialogue(dialogueFile:DialogueFile, ?song:String = ""):Void
	{
		if(dialogueFile.dialogue.length > 0) {
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			var doof:DialogueBoxPsych = new DialogueBoxPsych(dialogueFile, song);
			doof.scrollFactor.set();
			if (Paths.formatToSongPath(curSong) == "heartacheGeno")
			{
				doof.finishThing = torielThenOver;
			}
			else
			{
				doof.finishThing = backToOver;
			}
			doof.nextDialogueThing = startNextDialogue;
			doof.skipDialogueThing = skipDialogue;
			doof.cameras = [camHUD];
			add(doof);
		}
	}
	public function startDerpDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		if(dialogueFile.dialogue.length > 0) {
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			var doof:DialogueBoxPsych = new DialogueBoxPsych(dialogueFile, song);
			doof.scrollFactor.set();
			doof.finishThing = beginDerp;
			doof.nextDialogueThing = startNextDialogue;
			doof.skipDialogueThing = skipDialogue;
			doof.cameras = [camHUD];
			add(doof);
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countDownSprites:Array<FlxSprite> = [];

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop) {
			generateStaticArrows(0);
			generateStaticArrows(1);
			soulBoard = new FlxSprite().loadGraphic(Paths.image('fightBorder'));
			soulBoard.width = 631;
			soulBoard.height = 631;
			soulBoard.setGraphicSize(Std.int(soulBoard.width));
			soulBoard.screenCenter();
			soulBoard.updateHitbox();
			soulBoard.cameras = [soulCamera];
			soulBoard.alpha = 0;
			add(soulBoard);

			torielDeath = new FlxSprite().loadGraphic(Paths.image('torielDeath'));
			torielGeno = new FlxSprite().loadGraphic(Paths.image('torielGeno'));

			torielDeath.frames = Paths.getSparrowAtlas('torielDeath');
			torielDeath.setGraphicSize(Std.int(torielDeath.width*.7));
			torielDeath.animation.addByPrefix('deathSeq', "deathSeq", 24,false);



			torielGeno.frames = Paths.getSparrowAtlas('torielGeno');
			torielGeno.animation.addByPrefix('Injured', "Injured", 24,false);
			torielGeno.setGraphicSize(Std.int(torielGeno.width*.7));
			torielGeno.animation.addByPrefix('Shatter', "Shatter", 24,false);
			torielGeno.animation.addByPrefix('Shocked', "Shocked", 24,false);
			torielGeno.animation.addByPrefix('Slashed', "Slashed", 24,false);
			soul = new FlxSprite().loadGraphic(Paths.image('soulAnimated'));

			soul.frames = Paths.getSparrowAtlas('soulAnimated');
			soul.animation.addByPrefix('damage', "SoulDamage", 24,false);
			soul.animation.addByPrefix('normal', "SoulNormal", 24,false);
			soul.animation.play('normal',false);

			soulAppear = new FlxSprite().loadGraphic(Paths.image('soulAppear'));
			soulAppear.frames = Paths.getSparrowAtlas('soulAppear');
			soulAppear.animation.addByPrefix('appear', "SoulAppear", 24,false);
			soulAppear.cameras = [soulCamera];
			add(soulAppear);
			soulAppear.alpha = 0;

			soul.x = 0;
			soul.y = 0;
			
			soul.width = 51;
			soul.height = 51;
			soul.setGraphicSize(Std.int(soul.width));

			soul.screenCenter();
			soul.y += 200;
			soul.updateHitbox();
			add(soul);
			soul.cameras = [soulCamera];
			soul.alpha = 0;

			soul.width -= 34;
			soul.height -= 34;
			soul.offset.x += 17;
			soul.offset.y += 17;

			//["RED","BLUE","CYAN","GREEN","PURPLE","ORANGE","YELLOW","GRAY"]
			switch(ClientPrefs.soulColor)
			{
				case 0:
					soul.color = FlxColor.fromRGB(255,0,0);
					soulAppear.color = FlxColor.fromRGB(255,0,0);
				case 1:
					soul.color = FlxColor.fromRGB(0,0,255);
					soulAppear.color = FlxColor.fromRGB(0,0,255);
				case 2:
					soul.color = FlxColor.fromRGB(0,255,255);
					soulAppear.color = FlxColor.fromRGB(0,255,255);
				case 3:
					soul.color = FlxColor.fromRGB(0,255,0);
					soulAppear.color = FlxColor.fromRGB(0,255,0);
				case 4:
					soul.color = FlxColor.fromRGB(255,0,255);
					soulAppear.color = FlxColor.fromRGB(255,0,255);
				case 5:
					soul.color = FlxColor.fromRGB(255,125,0);
					soulAppear.color = FlxColor.fromRGB(255,125,0);
				case 6:
					soul.color = FlxColor.fromRGB(255,255,0);
					soulAppear.color = FlxColor.fromRGB(255,255,0);
				case 7:
					soul.color = FlxColor.fromRGB(125,125,125);
					soulAppear.color = FlxColor.fromRGB(125,125,125);
				default:
					soul.color = FlxColor.fromRGB(255,0,0);
					soulAppear.color = FlxColor.fromRGB(255,0,0);
					soul.flipY = true;
				
			}


			slashAttackk = new FlxSprite().loadGraphic(Paths.image('slashAttack'));
			slashAttackk.frames = Paths.getSparrowAtlas('slashAttack');
			slashAttackk.screenCenter();
			slashAttackk.animation.addByPrefix('Slash', 'Slash', 12, false);
			slashAttackk.animation.play('Slash');
			slashAttackk.alpha = 0;
			slashAttackk.cameras = [soulCamera];
			add(slashAttackk);


			minXProjectile = soulBoard.x;
			maxXProjectile = soulBoard.x + soulBoard.width + 50;
			minYProjectile = soulBoard.y;
			maxYProjectile = soulBoard.y + soulBoard.height + 200;

			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				if(ClientPrefs.middleScroll || Paths.formatToSongPath(curSong) == 'challenge1') opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			FlxG.sound.music.time = Conductor.songPosition;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);

			var swagCounter:Int = 0;

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (tmr.loopsLeft % gfSpeed == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing"))
				{
					gf.dance();
				}
				if(tmr.loopsLeft % 2 == 0) {
					if (boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing'))
					{
						boyfriend.dance();
					}
					if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
					{
						dad.dance();
					}
				}
				else if(dad.danceIdle && dad.animation.curAnim != null && !dad.stunned && !dad.curCharacter.startsWith('gf') && !dad.animation.curAnim.name.startsWith("sing"))
				{
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);
	
					bottomBoppers.dance(true);
					santa.dance(true);
				}

				switch (swagCounter)
				{
					case 0:
						if(!(Paths.formatToSongPath(curSong) == "tutorial")){
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
						}


					case 1:
						if(!(Paths.formatToSongPath(curSong) == "tutorial")){
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						ready.scrollFactor.set();
						ready.updateHitbox();

						if (PlayState.isPixelStage)
							ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

						ready.screenCenter();
						ready.antialiasing = antialias;
						add(ready);
						countDownSprites.push(ready);
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(ready);
								remove(ready);
								ready.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
						}
					case 2:
						if(!(Paths.formatToSongPath(curSong) == "tutorial")){
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						set.scrollFactor.set();

						if (PlayState.isPixelStage)
							set.setGraphicSize(Std.int(set.width * daPixelZoom));

						set.screenCenter();
						set.antialiasing = antialias;
						add(set);
						countDownSprites.push(set);
						FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(set);
								remove(set);
								set.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
						}
					case 3:
						if(!(Paths.formatToSongPath(curSong) == "tutorial")){
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						go.scrollFactor.set();

						if (PlayState.isPixelStage)
							go.setGraphicSize(Std.int(go.width * daPixelZoom));

						go.updateHitbox();

						go.screenCenter();
						go.antialiasing = antialias;
						add(go);
						countDownSprites.push(go);
						FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(go);
								remove(go);
								go.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
						}
					case 4:


				}

				notes.forEachAlive(function(note:Note) {
					note.copyAlpha = false;
					note.alpha = 1 * note.multAlpha;
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				if (generatedMusic)
				{
					notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
				}

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = finishSong;
		vocals.play();
		if(Paths.formatToSongPath(curSong) == "hopes-and-dreams")
		{
			FlxG.sound.music.pause();
							vocals.pause();
							Conductor.songPosition += savedTime;
							trace("Saved Time:");
							trace(savedTime);
							createLoadText("FILE 1 LOADED");
							notes.forEachAlive(function(daNote:Note)
							{
								if(daNote.strumTime > Conductor.songPosition-1000 && daNote.strumTime < Conductor.songPosition+1000) {
									daNote.active = false;
									daNote.visible = false;

									daNote.kill();
									notes.remove(daNote, true);
									daNote.destroy();
								}
							});
							for (i in 0...unspawnNotes.length) {
								var daNote:Note = unspawnNotes[0];
								if(daNote.strumTime + 800 >= Conductor.songPosition) {
									break;
								}

								daNote.active = false;
								daNote.visible = false;

								daNote.kill();
								unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
								daNote.destroy();
							}

							FlxG.sound.music.time = Conductor.songPosition;
							FlxG.sound.music.play();

							vocals.time = Conductor.songPosition;
							vocals.play();
		}
		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);
		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<SwagSection> = Song.loadFromJson('events', songName).notes;
			for (section in eventsData)
			{
				for (songNotes in section.sectionNotes)
				{
					if(songNotes[1] < 0) {
						eventNotes.push([songNotes[0], songNotes[1], songNotes[2], songNotes[3], songNotes[4]]);
						eventPushed(songNotes);
					}
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				if(songNotes[1] > -1) { //Real notes
					var daStrumTime:Float = songNotes[0];
					var daNoteData:Int = Std.int(songNotes[1] % 4);

					var gottaHitNote:Bool = section.mustHitSection;

					if (songNotes[1] > 3)
					{
						gottaHitNote = !section.mustHitSection;
					}

					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.mustPress = gottaHitNote;
					swagNote.sustainLength = songNotes[2];
					swagNote.noteType = songNotes[3];
					if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
					swagNote.scrollFactor.set();

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);

					var floorSus:Int = Math.floor(susLength);
					if(floorSus > 0) {
						for (susNote in 0...floorSus+1)
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

							var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(SONG.speed, 2)), daNoteData, oldNote, true);
							sustainNote.mustPress = gottaHitNote;
							sustainNote.noteType = swagNote.noteType;
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);

							if (sustainNote.mustPress)
							{
								sustainNote.x += FlxG.width / 2; // general offset
							}
						}
					}

					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2; // general offset
					}
					else {}

					if(!noteTypeMap.exists(swagNote.noteType)) {
						noteTypeMap.set(swagNote.noteType, true);
					}
				} else { //Event Notes
					eventNotes.push([songNotes[0], songNotes[1], songNotes[2], songNotes[3], songNotes[4]]);
					eventPushed(songNotes);
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:Array<Dynamic>) {
		switch(event[2]) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event[3].toLowerCase()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(event[3]);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event[4];
				addCharacterToList(newCharacter, charType);
		}

		if(!eventPushedMap.exists(event[2])) {
			eventPushedMap.set(event[2], true);
		}
	}

	function eventNoteEarlyTrigger(event:Array<Dynamic>):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event[2]]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event[2]) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		var earlyTime1:Float = eventNoteEarlyTrigger(Obj1);
		var earlyTime2:Float = eventNoteEarlyTrigger(Obj2);
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0] - earlyTime1, Obj2[0] - earlyTime2);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;

			if(blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = false;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;

			if(blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = true;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = true;
			
			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = true;
				}
			}
			
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;
	var spookyText:FlxText;
	var spookyRendered:Bool = false;
	var spookySteps:Int = 0;
	var alternate:Int = 0;
	var circAlternate:Int = 0;
	var bulletHellAlternate:Int = 0;
	public function spawnDamageArea(projectileName:String = "1",direction:String = "Up",speed:Float = 4)
	{
		var warning = new FlxSprite().loadGraphic(Paths.image("damageBorder"));
		var midpointX = FlxG.random.float(minXProjectile, maxXProjectile);
		var midpointY = FlxG.random.float(minYProjectile, maxYProjectile);
		var middleX = -50;
		var middleY = soulBoard.x + (soulBoard.width/2);
		warning.cameras = [soulCamera];
		projectileArray.push(warning);
		switch(projectileName)
		{
			case '1':
				warning.x = soulBoard.x + (soulBoard.width/2);
				warning.y = minYProjectile;
				add(warning);
				FlxTween.tween(warning, {alpha: 0}, .5, {
							onComplete: function(twn:FlxTween) {
								remove(warning);
								projectileArray.remove(warning);
							}
				});
			case '2':
				warning.x = minXProjectile;
				warning.y = minYProjectile;
				add(warning);
				FlxTween.tween(warning, {alpha: 0}, .5, {
							onComplete: function(twn:FlxTween) {
								remove(warning);
								projectileArray.remove(warning);
							}
				});
			case '3':
				warning.x = minXProjectile;
				warning.y = soulBoard.y + (soulBoard.height/2);
				add(warning);
				FlxTween.tween(warning, {alpha: 0}, .5, {
							onComplete: function(twn:FlxTween) {
								remove(warning);
								projectileArray.remove(warning);
							}
				});
			case '4':
				warning.x = soulBoard.x + (soulBoard.width/2);
				warning.y = soulBoard.y + (soulBoard.height/2);
				add(warning);
				FlxTween.tween(warning, {alpha: 0}, .5, {
							onComplete: function(twn:FlxTween) {
								remove(warning);
								projectileArray.remove(warning);
							}
				});
	}
	}

	public function spawnWarning(projectileName:String = "1",direction:String = "Up",speed:Float = 4)
	{
		var warning = new FlxSprite().loadGraphic(Paths.image("warningBorder"));
		var midpointX = FlxG.random.float(minXProjectile, maxXProjectile);
		var midpointY = FlxG.random.float(minYProjectile, maxYProjectile);
		var middleX = -50;
		var middleY = soulBoard.x + (soulBoard.width/2);
		warning.cameras = [soulCamera];
		switch(projectileName)
		{
			case '1':
				warning.x = soulBoard.x + (soulBoard.width/2);
				warning.y = minYProjectile;
				add(warning);
				FlxTween.tween(warning, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween) {
								remove(warning);
							}
				});
			case '2':
				warning.x = minXProjectile;
				warning.y = minYProjectile;
				add(warning);
				FlxTween.tween(warning, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween) {
								remove(warning);
							}
				});
			case '3':
				warning.x = minXProjectile;
				warning.y = soulBoard.y + (soulBoard.height/2);
				add(warning);
				FlxTween.tween(warning, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween) {
								remove(warning);
							}
				});
			case '4':
				warning.x = soulBoard.x + (soulBoard.width/2);
				warning.y = soulBoard.y + (soulBoard.height/2);
				add(warning);
				FlxTween.tween(warning, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween) {
								remove(warning);
							}
				});
	}
	}
	public function placeInCircle(projectile:FlxSprite,radius:Float,startX:Float = 0,startY:Float = 0,iterations:Float = 17,placement:Float = 0)
	{

		projectile.x = startX + (Math.cos(360*(placement%iterations))*radius);
		projectile.y = startY + (Math.sin(360*(placement%iterations))*radius)
		;
	}
	public static function accelerateFromAngle(source:FlxSprite, radians:Float, acceleration:Float, maxSpeed:Float, resetVelocity:Bool = true):Void
	{
		var sinA = Math.sin(radians);
		var cosA = Math.cos(radians);

		if (resetVelocity)
			source.velocity.set(0, 0);

		source.acceleration.set(cosA * acceleration, sinA * acceleration);
		source.maxVelocity.set(Math.abs(cosA * maxSpeed), Math.abs(sinA * maxSpeed));
	}
	public function blueHell(projectileName:String = "defaultProjectile",spawnPoints:String = "3")
	{
		var absMidX = soulBoard.x + (soulBoard.width/2);
		var absMidY = soulBoard.y + (soulBoard.height/2);
		var spawnPointsInt = Std.parseInt(spawnPoints);
		for (i in 0...(spawnPointsInt))
		{
			
			var projectile = new FlxSprite().loadGraphic(Paths.image(projectileName));
			var whichSpawn:Float = i*((2*Math.PI)/spawnPointsInt);
			projectile.cameras = [soulCamera];
			projectile.x = absMidX;
			if (FlxG.save.data.colorBlind == true)
			{
				projectile.color = FlxColor.fromRGB(0,68,255);
			}
			else
			{
				projectile.color = FlxColor.fromRGB(0,255,255);
			}
			projectile.y = absMidY;
			add(projectile);
			projectile.alpha = 1;
			var projectileAngle = ((360/34)*bulletHellAlternate)+(360/spawnPointsInt)*i;
			var projectileRadians = (projectileAngle*Math.PI)/180;

			blueArray.push(projectile);
			accelerateFromAngle(projectile,projectileRadians,1000,400,true);
			FlxTween.tween(projectile, {alpha: 0}, .5, {startDelay: 3.5,
							onComplete: function(twn:FlxTween) {
								blueArray.remove(projectile);
								remove(projectile);
							}
				});	
			bulletHellAlternate++;
		}
	}	
	public function orangeHell(projectileName:String = "defaultProjectile",spawnPoints:String = "3")
	{
		var absMidX = soulBoard.x + (soulBoard.width/2);
		var absMidY = soulBoard.y + (soulBoard.height/2);
		var spawnPointsInt = Std.parseInt(spawnPoints);
		for (i in 0...(spawnPointsInt))
		{
			
			var projectile = new FlxSprite().loadGraphic(Paths.image(projectileName));
			var whichSpawn:Float = i*((2*Math.PI)/spawnPointsInt);
			projectile.cameras = [soulCamera];
			projectile.x = absMidX;
			if (FlxG.save.data.colorBlind == true)
			{
				projectile.color = FlxColor.fromRGB(255,80,0);
			}
			else
			{
				projectile.color = FlxColor.fromRGB(255,150,0);		
			}	
			projectile.y = absMidY;
			add(projectile);
			projectile.alpha = 1;
			var projectileAngle = ((360/34)*bulletHellAlternate)+(360/spawnPointsInt)*i;
			var projectileRadians = (projectileAngle*Math.PI)/180;

			orangeArray.push(projectile);
			accelerateFromAngle(projectile,projectileRadians,1000,400,true);
			FlxTween.tween(projectile, {alpha: 0}, .5, {startDelay: 3.5,
							onComplete: function(twn:FlxTween) {
								orangeArray.remove(projectile);
								remove(projectile);
							}
				});	
			
			bulletHellAlternate++;
		}
	}	
	public function bulletHell(projectileName:String = "defaultProjectile",spawnPoints:String = "3")
	{
		var absMidX = soulBoard.x + (soulBoard.width/2);
		var absMidY = soulBoard.y + (soulBoard.height/2);
		var spawnPointsInt = Std.parseInt(spawnPoints);
		for (i in 0...(spawnPointsInt))
		{
			
			var projectile = new FlxSprite().loadGraphic(Paths.image(projectileName));
			var whichSpawn:Float = i*((2*Math.PI)/spawnPointsInt);
			projectile.cameras = [soulCamera];
			projectile.x = absMidX;
			projectile.y = absMidY;
			add(projectile);
			projectile.alpha = 1;
			var projectileAngle = ((360/34)*bulletHellAlternate)+(360/spawnPointsInt)*i;
			var projectileRadians = (projectileAngle*Math.PI)/180;

			projectileArray.push(projectile);
			accelerateFromAngle(projectile,projectileRadians,1000,400,true);
			FlxTween.tween(projectile, {alpha: 0}, .5, {startDelay: 3.5,
							onComplete: function(twn:FlxTween) {
								projectileArray.remove(projectile);
								remove(projectile);
							}
				});	
			bulletHellAlternate++;
		}
	}
	public function spawnHeal()
	{
		var absMidX = soulBoard.x + (soulBoard.width/2);
		var absMidY = soulBoard.y + (soulBoard.height/2);
		var projectile = new FlxSprite().loadGraphic(Paths.image("healBullet"));
		var midpointX = FlxG.random.float(minXProjectile + 100, maxXProjectile-100);
		var midpointY = FlxG.random.float(minYProjectile + 100, maxYProjectile-100);
		var middleX = -50;
		var middleY = soulBoard.x + (soulBoard.width/2);
		projectile.cameras = [soulCamera];
		projectile.x = midpointX;
		projectile.y = -50;
		add(projectile);
		healArray.push(projectile);
		FlxTween.tween(projectile, {y: midpointY + 700, x: midpointX + FlxG.random.float(-100,100)}, 4, {
					onComplete: function(twn:FlxTween) {
						healArray.remove(projectile);
						remove(projectile);
					}
		});
	}

	public function blueProjectile(projectileName:String = "defaultProjectile",direction:String = "Up",speed:Float = 4,isHeal:Bool = false)
	{
		var absMidX = soulBoard.x + (soulBoard.width/2);
		var absMidY = soulBoard.y + (soulBoard.height/2);
		var midpointX = FlxG.random.float(minXProjectile, maxXProjectile);
		var midpointY = FlxG.random.float(minYProjectile, maxYProjectile);
		var middleX = -50;
		var middleY = soulBoard.x + (soulBoard.width/2);

		switch(direction)
		{
			case "Spiral":
				for (i in 0...16)
				{
					var projectile = new FlxSprite().loadGraphic(Paths.image(projectileName));
					projectile.cameras = [soulCamera];
					projectile.color = FlxColor.fromRGB(0,255,255);
					add(projectile);
					blueArray.push(projectile);
				FlxTween.circularMotion(projectile,soulBoard.x + (soulBoard.width/2),soulBoard.y + (soulBoard.height/2),((i%17)+1)*30,359,true,1,true,{
				type: FlxTweenType.LOOPING
				});
				FlxTween.tween(projectile, {alpha: 0}, .2, {startDelay: 3.5,
					onComplete: function(twn:FlxTween) {
						blueArray.remove(projectile);
						remove(projectile);
						}
				});	
				}

		}
	}
	public function spawnProjectile(projectileName:String = "defaultProjectile",direction:String = "Up",speed:Float = 4,isHeal:Bool = false)
	{
		var absMidX = soulBoard.x + (soulBoard.width/2);
		var absMidY = soulBoard.y + (soulBoard.height/2);
		var projectile = new FlxSprite().loadGraphic(Paths.image(projectileName));
		var midpointX = FlxG.random.float(minXProjectile, maxXProjectile);
		var midpointY = FlxG.random.float(minYProjectile, maxYProjectile);
		var middleX = -50;
		var middleY = soulBoard.x + (soulBoard.width/2);
		projectile.cameras = [soulCamera];
		if (isHeal)
		{
			projectile.alpha = .975;
		}
		switch(direction)
		{
			case 'Up':
				projectile.x = midpointX;
				projectile.y = -50;
				add(projectile);
				projectileArray.push(projectile);
				FlxTween.tween(projectile, {y: midpointY + 700, x: midpointX + FlxG.random.float(-100,100)}, speed, {
							onComplete: function(twn:FlxTween) {
								projectileArray.remove(projectile);
								remove(projectile);
							}
				});
			case 'Swirl':
			 midpointX = FlxG.random.float(minXProjectile + 100, maxXProjectile - 100);
				projectile.x = midpointX;
				projectile.y = -50;
				add(projectile);
				alternate++;
				if (alternate % 2 == 0)
				{
				projectileArray.push(projectile);
				FlxTween.tween(projectile, {y: midpointY - midpointY + 100, x: midpointX + 100}, speed/6, {ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween) {
							FlxTween.tween(projectile, {y: midpointY - midpointY/2 + 300, x: midpointX - 100}, speed/4, {ease: FlxEase.quadIn,
							onComplete: function(twn:FlxTween) {
							FlxTween.tween(projectile, {y: midpointY - midpointY/2 + 500, x: midpointX + 100}, speed/6, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
							FlxTween.tween(projectile, {y: midpointY - midpointY/2 + 700, x: midpointX - 100}, speed/6, {ease: FlxEase.quadIn,
							onComplete: function(twn:FlxTween) {
								projectileArray.remove(projectile);
								remove(projectile);
							}
				});
							}
				});
							}
				});
							}
				});
				}
				else
				{
				projectileArray.push(projectile);
				FlxTween.tween(projectile, {y: midpointY - midpointY + 100, x: midpointX - 100}, speed/6, {ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween) {
							FlxTween.tween(projectile, {y: midpointY - midpointY/2 + 300, x: midpointX + 100}, speed/4, {ease: FlxEase.quadIn,
							onComplete: function(twn:FlxTween) {
							FlxTween.tween(projectile, {y: midpointY - midpointY/2 + 500, x: midpointX - 100}, speed/6, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
							FlxTween.tween(projectile, {y: midpointY - midpointY/2 + 700, x: midpointX + 100}, speed/6, {ease: FlxEase.quadIn,
							onComplete: function(twn:FlxTween) {
								projectileArray.remove(projectile);
								remove(projectile);
							}
				});
							}
				});
							}
				});
							}
				});
				}
				
			case 'Left':
			
				projectile.x = 200;
				projectile.y = midpointY;
				add(projectile);
				projectileArray.push(projectile);
				FlxTween.tween(projectile, {y: midpointY, x: midpointX + 700}, speed, {
							onComplete: function(twn:FlxTween) {
								projectileArray.remove(projectile);
								remove(projectile);
							}
				});
			case 'Right':
				projectile.x = maxXProjectile + 50;
				projectile.y = midpointY;
				add(projectile);
				projectileArray.push(projectile);
				FlxTween.tween(projectile, {y: midpointY, x: midpointX - 700}, speed, {
							onComplete: function(twn:FlxTween) {
								projectileArray.remove(projectile);
								remove(projectile);
							}
				});
			case "Spiral":
				alternate++;
				add(projectile);
				projectileArray.push(projectile);
				FlxTween.circularMotion(projectile,soulBoard.x + (soulBoard.width/2),soulBoard.y + (soulBoard.height/2),((alternate%17)+1)*30,359,false,1.5,true,{
				type: FlxTweenType.LOOPING
			});
				FlxTween.tween(projectile, {alpha: 0}, .2, {startDelay: 3.5,
							onComplete: function(twn:FlxTween) {
								projectileArray.remove(projectile);
								remove(projectile);
							}
				});	
			case "Closein":
				circAlternate++;
				var radius = 650;
				placeInCircle(projectile,radius,absMidX,absMidY,17,circAlternate);
				add(projectile);
				projectileArray.push(projectile);
				var tweenX = absMidX;
				var tweenY = absMidY;
				FlxTween.tween(projectile, {x: tweenX,y: tweenY}, 1, {
							onComplete: function(twn:FlxTween) {
								projectileArray.remove(projectile);
								remove(projectile);
							}
				});	
			case 'Circle':
				var xMult:Float = 1;
				var yMult:Float = 1;
				var from:Float = 0;
				var to:Float = 0;

				switch(alternate % 12)
				{
					case 0:
						xMult = 0;
						yMult = 1;
						to = 180;
					case 1:
						xMult = .78;
						yMult = .6;
						to = 140;
					case 2:
						xMult = .66;
						yMult = .75;
						to = 150;
					case 3:
						xMult = .45;
						yMult = .8;
						to = 160;
					case 4:
						xMult = .35;
						yMult = .9;
						to = 165;
					case 5:
						xMult = .25;
						yMult = .95;
						to = 170;
					case 6:
						xMult = 0;
						yMult = 1;
						to = 180;
					case 7:
						xMult = -.25;
						yMult = .95;
						to = 190;
					case 8:
						xMult = -.35;
						yMult = .9;
						to = 200;
					case 9:
						xMult = -.45;
						yMult = .8;
						to = 205;					
					case 10:
						xMult = -.66;
						yMult = .75;
						to = 210;
					case 11:
						xMult = -.78;
						yMult = .6;
						to = 240;
									
				}
				to += 90;
				alternate++;
				xMult += FlxG.random.float(0, .2);
				yMult += FlxG.random.float(0, .2);
				xMult *= 5;
				yMult *= 5;
				projectile.x = middleY + xMult;
				projectile.y = middleX + yMult;
				add(projectile);
				projectileArray.push(projectile);
				if (projectileName == "pellet")
				{
					FlxTween.angle(projectile, from, to, .1, {ease: FlxEase.expoIn});
				}
				FlxTween.tween(projectile, {y: projectile.y + (yMult*200), x: projectile.x + (xMult*200)}, speed, {
							onComplete: function(twn:FlxTween) {
								projectileArray.remove(projectile);
								remove(projectile);
							}
				});
			default:
				projectile.x = midpointX;
				projectile.y = maxYProjectile - 200;
				add(projectile);
				projectileArray.push(projectile);
				FlxTween.tween(projectile, {y: midpointY - 700, x: midpointX + FlxG.random.float(-100,100)}, speed, {
							onComplete: function(twn:FlxTween) {
								projectileArray.remove(projectile);
								remove(projectile);
							}
				});

		}

	
	}

	function checkIfHit()
	{
		var leniancy = 0;
		var offset = 0;
		if (isSoul)
		{
			for (projectile in healArray)
			{
				if (FlxG.overlap(soul, projectile))
				{	
						if (FlxG.save.data.moreSoul == true)
						{
							health += .3;
						}
						else
						{
							health += .4;
						}
						FlxG.sound.play(Paths.sound('heal'));
						remove(projectile);
						healArray.remove(projectile);
				}
			}
			for (projectile in projectileArray)
			{
				if (gotHit < 1)
				{
					if (FlxG.overlap(soul, projectile))
					{	
							if (FlxG.save.data.moreSoul == true)
							{
								gotHit += 1;
							}
							else
							{
								gotHit += 2;
							}
							soul.alpha = .4;
							health -= .2;
							FlxG.sound.play(Paths.sound('damage'));
							soul.animation.play('damage');
							songSoul++;
					}
				}

			}
		}
	}

	function checkIfBlueHit()
	{
		var leniancy = 0;
		var offset = 0;
			for (projectile in blueArray)
			{
				if (gotHit < 1)
				{
					if (FlxG.overlap(soul, projectile))
					{	
							if (FlxG.save.data.moreSoul == true)
							{
								gotHit += 1;
								health -= .125;
							}
							else
							{
								gotHit += 2;
								health -= .2;
							}
							soul.alpha = .4;
							FlxG.sound.play(Paths.sound('damage'));
							soul.animation.play('damage');
							songSoul++;
					}
				}
			}
	}

function checkIfOrangeHit()
	{
		var leniancy = 0;
		var offset = 0;
			for (projectile in orangeArray)
			{
				if (gotHit < 1)
				{
					if (FlxG.overlap(soul, projectile) && !isMoving)
					{	
							if (FlxG.save.data.moreSoul == true)
							{
								gotHit += 1;
								health -= .15;
							}
							else
							{
								gotHit += 2;
								health -= .2;
							}
							soul.alpha = .4;
							FlxG.sound.play(Paths.sound('damage'));
							soul.animation.play('damage');
							songSoul++;
					}
				}
			}
	}

	function checkCollision(xCoord:Float,yCoord:Float)
	{
		if (xCoord < soulBoard.x || xCoord > soulBoard.x + soulBoard.width - soul.width || yCoord < soulBoard.y || yCoord > soulBoard.y + soulBoard.height - soul.height)
		{
			return false;
		}
		else
		{
			return true;
		}
	}


	override public function update(elapsed:Float)
	{	
		if (isSoul)
		{
			isMoving = false;
			checkIfHit();

		}
		
		if (isSoul)
		{
			if (controls.UI_UP)
			{
				if (checkCollision(soul.x, soul.y -ClientPrefs.soulSpeed))
				{
					isMoving = true;
					soul.y -= ClientPrefs.soulSpeed * (60/ClientPrefs.framerate);
					checkIfBlueHit();
				}
			}

			if (controls.UI_DOWN)
			{
				if (checkCollision(soul.x,soul.y + ClientPrefs.soulSpeed))
				{
					isMoving = true;
					soul.y += ClientPrefs.soulSpeed * (60/ClientPrefs.framerate);
					checkIfBlueHit();					
				}
			}

			if (controls.UI_LEFT)
			{
				if (checkCollision(soul.x -ClientPrefs.soulSpeed,soul.y))
				{
					isMoving = true;
					soul.x -= ClientPrefs.soulSpeed * (60/ClientPrefs.framerate);
					checkIfBlueHit();					
				}
			}

			if (controls.UI_RIGHT)
			{
				if (checkCollision(soul.x + ClientPrefs.soulSpeed,soul.y))
				{
					isMoving = true;
					soul.x += ClientPrefs.soulSpeed * (60/ClientPrefs.framerate);
					checkIfBlueHit();					
				}

			}
		}
		if (isSoul)
		{
			checkIfOrangeHit();
		}
		/*if (FlxG.keys.justPressed.NINE && !isRPG)
		{
			iconP1.swapOldIcon();
		}*/

		callOnLuas('onUpdate', [elapsed]);

		switch (curStage)
		{
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 130) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		if(ratingString == '?') {
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Hits: ' + songSoul + ' | Rating: ' + ratingString;
		} else {
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Hits: ' + songSoul + ' | Rating: ' + ratingString + ' (' + Math.floor(ratingPercent * 100) + '%)';
		}
			HealthText.text = Std.int(health*10) + "/" + 20; 
		if(cpuControlled) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}
		botplayTxt.visible = cpuControlled;
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause  && !isSoul)
		{
			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				if (FlxG.random.bool(0.1))
				{
					// gitaroo man easter egg
					cancelFadeTween();
					CustomFadeTransition.nextCamera = camOther;
					MusicBeatState.switchState(new GitarooPause());
				}
				else {
					if(FlxG.sound.music != null) {
						FlxG.sound.music.pause();
						vocals.pause();
					}
					PauseSubState.transCamera = camOther;
					openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
			
				#if desktop
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
			}
		}

		if (FlxG.keys.justPressed.SEVEN && !endingSong && !inCutscene && !isRPG)
		{
			persistentUpdate = false;
			paused = true;
			cancelFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;



		if (FlxG.keys.justPressed.EIGHT && !endingSong && !inCutscene && !isRPG) {
			persistentUpdate = false;
			paused = true;
			cancelFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var secondsTotal:Int = Math.floor((songLength - curTime) / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
		if (Paths.formatToSongPath(curSong) == 'hopes-and-dreams' || Paths.formatToSongPath(curSong) == 'your-worst-nightmare')
		{
			FlxG.camera.zoom = .35;
		}
		else
		{
			FlxG.camera.zoom = .9;
		}
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		var roundedSpeed:Float = FlxMath.roundDecimal(SONG.speed, 2);
		if (unspawnNotes[0] != null)
		{
			var time:Float = 1500;
			if(roundedSpeed < 1) time /= roundedSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				if(!daNote.mustPress && ClientPrefs.middleScroll)
				{
					daNote.active = true;
					daNote.visible = false;
				}
				else if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				// i am so fucking sorry for this if condition
				var strumX:Float = 0;
				var strumY:Float = 0;
				var strumAngle:Float = 0;
				var strumAlpha:Float = 0;
				if(daNote.mustPress) {
					strumX = playerStrums.members[daNote.noteData].x;
					strumY = playerStrums.members[daNote.noteData].y;
					strumAngle = playerStrums.members[daNote.noteData].angle;
					strumAlpha = playerStrums.members[daNote.noteData].alpha;
				} else {
					strumX = opponentStrums.members[daNote.noteData].x;
					strumY = opponentStrums.members[daNote.noteData].y;
					strumAngle = opponentStrums.members[daNote.noteData].angle;
					strumAlpha = opponentStrums.members[daNote.noteData].alpha;
				}

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;
				var center:Float = strumY + Note.swagWidth / 2;

				if(daNote.copyX) {
					daNote.x = strumX;
				}
				if(daNote.copyAngle) {
					daNote.angle = strumAngle;
				}
				if(daNote.copyAlpha) {
					daNote.alpha = strumAlpha;
				}
				if(daNote.copyY) {
					if (ClientPrefs.downScroll) {
						daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
						if (daNote.isSustainNote) {
							//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * roundedSpeed + (46 * (roundedSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * roundedSpeed;
								if(PlayState.isPixelStage) {
									daNote.y += 8;
								} else {
									daNote.y -= 19;
								}
							} 
							daNote.y += (Note.swagWidth / 2) - (60.5 * (roundedSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (roundedSpeed - 1);

							if(daNote.mustPress || !daNote.ignoreNote)
							{
								if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
									&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
								{
									var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
									swagRect.height = (center - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
						}
					} else {
						daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);

						if(daNote.mustPress || !daNote.ignoreNote)
						{
							if (daNote.isSustainNote
								&& daNote.y + daNote.offset.y * daNote.scale.y <= center
								&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{

					if (Paths.formatToSongPath(SONG.song) != 'tutorial')
						camZooming = true;

					if(daNote.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
						dad.playAnim('hey', true);
						dad.specialAnim = true;
						dad.heyTimer = 0.6;
					} else if(!daNote.noAnimation) {
						var altAnim:String = "";

						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim || daNote.noteType == 'Alt Animation') {
								altAnim = '-alt';
							}
						}

						var animToPlay:String = '';
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								animToPlay = 'singLEFT';
							case 1:
								animToPlay = 'singDOWN';
							case 2:
								animToPlay = 'singUP';
							case 3:
								animToPlay = 'singRIGHT';
						}
						if(daNote.noteType == 'GF Sing') {
							gf.playAnim(animToPlay + altAnim, true);
							gf.holdTimer = 0;
						} else {
							dad.playAnim(animToPlay + altAnim, true);
							if(Paths.formatToSongPath(curSong) == "your-worst-nightmare")
							{
								FlxG.camera.shake(0.03, .2);
							}
							dad.holdTimer = 0;
						}
					}

					if (SONG.needsVoices)
						vocals.volume = 1;

					var time:Float = 0.15;
					if(daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end')) {
						time += 0.15;
					}
					StrumPlayAnim(true, Std.int(Math.abs(daNote.noteData)) % 4, time);
					daNote.hitByOpponent = true;

					callOnLuas('opponentNoteHit', [notes.members.indexOf(daNote), Math.abs(daNote.noteData), daNote.noteType, daNote.isSustainNote]);

					if (!daNote.isSustainNote)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}

				if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				var doKill:Bool = daNote.y < -daNote.height;
				if(ClientPrefs.downScroll) doKill = daNote.y > FlxG.height;

				if (doKill)
				{
					if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();

		if (!inCutscene) {
			if(!cpuControlled) {
				keyShit();
			} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
			}
		}
		
		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				FlxG.sound.music.pause();
				vocals.pause();
				trace('FastForward');
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime + 800 < Conductor.songPosition) {
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length) {
					var daNote:Note = unspawnNotes[0];
					if(daNote.strumTime + 800 >= Conductor.songPosition) {
						break;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					daNote.destroy();
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', PlayState.cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
		#end
	}

	var isDead:Bool = false;
		function doDeathCheck() {
		if (health <= 0 && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, camFollowPos.x, camFollowPos.y, this));
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				
				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var early:Float = eventNoteEarlyTrigger(eventNotes[0]);
			var leStrumTime:Float = eventNotes[0][0];
			if(Conductor.songPosition < leStrumTime - early) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0][3] != null)
				value1 = eventNotes[0][3];

			var value2:String = '';
			if(eventNotes[0][4] != null)
				value2 = eventNotes[0][4];

			triggerEventNote(eventNotes[0][2], value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'MOREBlue':
				if (FlxG.save.data.moreSoul == true)
				{
					blueProjectile(value1,value2);
				}
			case 'HELLBlueHardmode':
				if (FlxG.save.data.moreSoul == true)
				{
					blueHell(value1,value2);
				}	
			case 'HELLOrangeHardmode':
				if (FlxG.save.data.moreSoul == true)
				{
					orangeHell(value1,value2);
				}				
			case 'Flash':
				flashWhite();
			case 'Slash':
			if (shakeEnemy)
			{
				enemyShake();
			}
			case 'HealProjectile':
				trace("Healing!");
				spawnHeal();
				FlxG.sound.play(Paths.sound('projectileSpawn'));
			case 'Cause BHell':
				bulletHell(value1,value2);
				FlxG.sound.play(Paths.sound('projectileSpawn'));
			case 'Spawn Bullet':
				spawnProjectile(value1,value2,4);
				FlxG.sound.play(Paths.sound('projectileSpawn'));
			case 'Spawn Warning':
				spawnWarning(value1,value2,4);
				if (value2 == "0")
				{
					
					FlxG.sound.play(Paths.sound('warning'));
					spawnWarning(value1,value2,4);
				}
				else
				{
					spawnDamageArea(value1,value2,4);
					FlxG.sound.play(Paths.sound('lightning'));
				}
			case 'Change Soulstate':
				if (value1 == "0")
				{
					soulCamera.alpha = 1;
					gotHit = 3;
					soul.alpha = .4;					
					bulletHellAlternate = 0;
					alternate = 0;
					circAlternate = 0;
					soulAppear.x = soul.x - 40;
					soulAppear.y = soul.y - 40;
					soulAppear.alpha = 1;
					soulAppear.animation.play('appear');
					FlxTween.tween(soulBoard, {alpha: .9}, 0.5, {ease: FlxEase.circOut});
					FlxTween.tween(soulAppear, {alpha: 0}, 1, {ease: FlxEase.circOut});
					FlxG.sound.play(Paths.sound('soulAppearSound'));
					FlxTween.tween(camHUD, {alpha: 0.2}, 0.5, {ease: FlxEase.circOut});

					isSoul = true;
				}
				else if (value1 == "1")
				{
					for (projectile in projectileArray)
					{
						projectileArray.remove(projectile);
						remove(projectile);
					}
					FlxTween.tween(soul, {alpha: 0}, 0.2, {ease: FlxEase.circOut});
					FlxTween.tween(soulBoard, {alpha: 0}, 0.2, {ease: FlxEase.circOut});
					FlxTween.tween(camHUD, {alpha: 1}, 0.2, {ease: FlxEase.circOut});
					FlxTween.tween(soulCamera, {alpha: 0}, 0.2, {ease: FlxEase.circOut});
					isSoul = false;
				}
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {

				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value)) value = 1;
				gfSpeed = value;

			case 'Blammed Lights':
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				if(lightId > 0 && curLightEvent != lightId) {
					if(lightId > 5) lightId = FlxG.random.int(1, 5, [curLightEvent]);

					var color:Int = 0xffffffff;
					switch(lightId) {
						case 1: //Blue
							color = 0xff31a2fd;
						case 2: //Green
							color = 0xff31fd8c;
						case 3: //Pink
							color = 0xfff794f7;
						case 4: //Red
							color = 0xfff96d63;
						case 5: //Orange
							color = 0xfffba633;
						default:
							color = 0xfff96d63;
					}
					curLightEvent = lightId;

					if(blammedLightsBlack.alpha == 0) {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								blammedLightsBlackTween = null;
							}
						});

						var chars:Array<Character> = [boyfriend, gf, dad];
						for (i in 0...chars.length) {
							if(chars[i].colorTween != null) {
								chars[i].colorTween.cancel();
							}
							chars[i].colorTween = FlxTween.color(chars[i], 1, FlxColor.WHITE, color, {onComplete: function(twn:FlxTween) {
								chars[i].colorTween = null;
							}, ease: FlxEase.quadInOut});
						}
					} else {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = null;
						blammedLightsBlack.alpha = 1;

						var chars:Array<Character> = [boyfriend, gf, dad];
						for (i in 0...chars.length) {
							if(chars[i].colorTween != null) {
								chars[i].colorTween.cancel();
							}
							chars[i].colorTween = null;
						}
						boyfriend.color = color;
						gf.color = color;
					}
					
					if(curStage == 'philly') {
						if(phillyCityLightsEvent != null) {
							phillyCityLightsEvent.forEach(function(spr:BGSprite) {
								spr.visible = false;
							});
							phillyCityLightsEvent.members[lightId - 1].visible = true;
							phillyCityLightsEvent.members[lightId - 1].alpha = 1;
						}
					}
				} else {
					if(blammedLightsBlack.alpha != 0) {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								blammedLightsBlackTween = null;
							}
						});
					}

					if(curStage == 'philly') {
						phillyCityLights.forEach(function(spr:BGSprite) {
							spr.visible = false;
						});
						phillyCityLightsEvent.forEach(function(spr:BGSprite) {
							spr.visible = false;
						});

						var memb:FlxSprite = phillyCityLightsEvent.members[curLightEvent - 1];
						if(memb != null) {
							memb.visible = true;
							memb.alpha = 1;
							if(phillyCityLightsEventTween != null)
								phillyCityLightsEventTween.cancel();

							phillyCityLightsEventTween = FlxTween.tween(memb, {alpha: 0}, 1, {onComplete: function(twn:FlxTween) {
								phillyCityLightsEventTween = null;
							}, ease: FlxEase.quadInOut});
						}
					}

					var chars:Array<Character> = [boyfriend, gf, dad];
					for (i in 0...chars.length) {
						if(chars[i].colorTween != null) {
							chars[i].colorTween.cancel();
						}
						chars[i].colorTween = FlxTween.color(chars[i], 1, chars[i].color, FlxColor.WHITE, {onComplete: function(twn:FlxTween) {
							chars[i].colorTween = null;
						}, ease: FlxEase.quadInOut});
					}

					curLight = 0;
					curLightEvent = 0;
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					if (Paths.formatToSongPath(curSong) == 'hopes-and-dreams' || Paths.formatToSongPath(curSong) == 'your-worst-nightmare')
					{
						FlxG.camera.zoom = .35;
					}
					else
					{
						FlxG.camera.zoom = .9;
					}
					camHUD.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;
		
						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.playAnim(value1, true);
				char.specialAnim = true;

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.idleSuffix = value2;
				char.recalculateDanceIdle();

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value1];
				var targetsArray:Array<FlxCamera> = [soulCamera, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = Std.parseFloat(split[0].trim());
					var intensity:Float = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity/4, duration);
						camGame.shake(intensity/4, duration);
					}
				}
			case 'Change Background':

				if (value1 == "1")
					bg.alpha = 1;
				else
					bg.alpha = 0;
			case 'Create Tip':

				var tip = new FlxSprite().loadGraphic(Paths.image(value1));
				tip.setGraphicSize(Std.int(tip.width));
				tip.cameras = [camOther];
				tip.screenCenter();
				var middleTip = tip.y;
				tip.y = -500;
				tip.updateHitbox();
				add(tip);
				FlxTween.tween(tip, {y: middleTip}, 1, {ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween) {
							FlxTween.tween(tip, {y: middleTip}, 2, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
							FlxTween.tween(tip, {y: 3000}, 1, {ease: FlxEase.quadIn,
							onComplete: function(twn:FlxTween) {
								remove(tip);
							}
				});
							}
				});
							}
				});
					
			case 'Change Character':
				var charType:Int = 0;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							boyfriend.visible = false;
							boyfriend = boyfriendMap.get(value2);
							if(!boyfriend.alreadyLoaded) {
								boyfriend.alpha = 1;
								boyfriend.alreadyLoaded = true;
							}
							boyfriend.visible = true;
							iconP1.changeIcon(boyfriend.healthIcon);
						}

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							dad.visible = false;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf) {
									gf.visible = true;
								}
							} else {
								gf.visible = false;
							}
							if(!dad.alreadyLoaded) {
								dad.alpha = 1;
								dad.alreadyLoaded = true;
							}
							dad.visible = true;
							iconP2.changeIcon(dad.healthIcon);
						}

					case 2:
						if(gf.curCharacter != value2) {
							if(!gfMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							gf.visible = false;
							gf = gfMap.get(value2);
							if(!gf.alreadyLoaded) {
								gf.alpha = 1;
								gf.alreadyLoaded = true;
							}
						}
				}
				reloadHealthBarColors();
			
			case 'BG Freaks Expression':
				if(bgGirls != null) bgGirls.swapDanceType();
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function changeDad(value2,charType){
		if(!dadMap.exists(value2)) {
			addCharacterToList(value2, charType);
		}

		var wasGf:Bool = dad.curCharacter.startsWith('gf');
		dad.visible = false;
		dad = dadMap.get(value2);
		if(!dad.curCharacter.startsWith('gf')) {
		if(wasGf) {
			gf.visible = true;
			}
		} else {
		gf.visible = false;
		}
			if(!dad.alreadyLoaded) {
			dad.alpha = 1;
			dad.alreadyLoaded = true;
		}
		dad.visible = true;
		iconP2.changeIcon(dad.healthIcon);
	}
	function moveCameraSection(?id:Int = 0):Void {
		if(SONG.notes[id] == null) return;

		if (!SONG.notes[id].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool) {
		if(isDad) {
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0];
			camFollow.y += dad.cameraPosition[1];
			tweenCamIn();
		} else {
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (curStage)
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school' | 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}
			camFollow.x -= boyfriend.cameraPosition[0];
			camFollow.y += boyfriend.cameraPosition[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1) {
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween) {
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	function finishSong():Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	var transitioning = false;


	function createSpookyText(text:String, x:Float = -1111111111111, y:Float = -1111111111111):Void
	{
		FlxG.sound.play(Paths.sound('summon'),2);
		spookyRendered = true;
		spookyText = new FlxText((x == -1111111111111 ? FlxG.random.float(gf.x - 20,gf.x + 20) : x), (y == -1111111111111 ? FlxG.random.float(gf.y - 200, gf.y - 200) : y));
		spookyText.setFormat(Paths.font("undertale.ttf"), 128, FlxColor.YELLOW);
		spookyText.size = 170;
		spookyText.x -= 1000;
		spookyText.bold = true;
		spookyText.text = text;
		add(spookyText);
		FlxTween.tween(spookyText, {alpha: 0}, 2, {
				onComplete: function(twn:FlxTween) {
					remove(spookyText);
				}
			});
	}
	function createSaveText(text:String, x:Float = -1111111111111, y:Float = -1111111111111):Void
	{
		spookyRendered = true;
		spookyText = new FlxText((x == -1111111111111 ? FlxG.random.float(gf.x - 20,gf.x + 20) : x), (y == -1111111111111 ? FlxG.random.float(gf.y - 400, gf.y - 400) : y));
		spookyText.setFormat(Paths.font("undertale.ttf"), 128, FlxColor.WHITE);
		spookyText.size = 170;
		spookyText.x -= 1000;
		spookyText.bold = true;
		spookyText.text = text;
		add(spookyText);
		FlxTween.tween(spookyText, {alpha: 0}, 2, {
				onComplete: function(twn:FlxTween) {
					remove(spookyText);
				}
			});
	}
	function createLoadText(text:String, x:Float = -1111111111111, y:Float = -1111111111111):Void
	{
		spookyRendered = true;
		spookyText = new FlxText((x == -1111111111111 ? FlxG.random.float(gf.x - 20,gf.x + 20) : x), (y == -1111111111111 ? FlxG.random.float(gf.y - 600, gf.y - 600) : y));
		spookyText.setFormat(Paths.font("undertale.ttf"), 128, FlxColor.WHITE);
		spookyText.size = 170;
		spookyText.x -= 1000;
		spookyText.bold = true;
		spookyText.text = text;
		add(spookyText);
		FlxTween.tween(spookyText, {alpha: 0}, 2, {
				onComplete: function(twn:FlxTween) {
					remove(spookyText);
				}
			});
	}
	public function endSong():Void
	{
		didAllDialogue = true;
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.0475;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.0475;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}
		
		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		savedTime = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:Int = checkForAchievement([1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 13, 14, 15]);
			if(achieve > -1) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		
		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				
				if (Paths.formatToSongPath(curSong) == 'spooky-shuffle')
				{
					RPGState.didBlooky = true;
					trace("Blooky Done!");
				}
				trace("Song Done!");
				if (Paths.formatToSongPath(curSong) == 'hopes-and-dreams' && FlxG.save.data.progression == 0)
				{
					FlxG.save.data.progression = 1;
					ClientPrefs.progression = 1;
				}
				else if (Paths.formatToSongPath(curSong) == 'your-worst-nightmare' && FlxG.save.data.progression == 1)
				{
					FlxG.save.data.progression = 2;
					ClientPrefs.progression = 2;
				}
				else if (Paths.formatToSongPath(curSong) == 'megalovania' && FlxG.save.data.progression == 2)
				{
					FlxG.save.data.progression = 3;
					ClientPrefs.progression = 3;
				}
				ClientPrefs.saveSettings();
				#end
			}


			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{

					cancelFadeTween();
					CustomFadeTransition.nextCamera = camOther;
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					FlxG.sound.music.stop();
					RPGState.triggerMusic = true;


					// if ()
					if(!usedPractice) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						
							if (Paths.formatToSongPath(curSong) == 'spooky-shuffle')
							{
								RPGState.didBlooky = true;
								trace("Blooky Done!");
							}
							trace("Song Done!");
							ClientPrefs.saveSettings();			
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;

					}
					usedPractice = false;
					changedDifficulty = false;
					cpuControlled = false;
				}
				else
				{
					var difficulty:String = '' + CoolUtil.difficultyStuff[storyDifficulty][1];

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelFadeTween();
							//resetSpriteCache = true;
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelFadeTween();
						//resetSpriteCache = true;
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				cancelFadeTween();
				CustomFadeTransition.nextCamera = camOther;
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}


				FlxG.sound.music.stop();
				RPGState.triggerMusic = true;
				trace(isRPG);
				if ((Paths.formatToSongPath(curSong) == "mychild"))
				{
					unlockFreeplaySong(Paths.formatToSongPath(curSong));
				}
				if (isRPG)
				{
					soulCamera.alpha = 1;
					unlockFreeplaySong(Paths.formatToSongPath(curSong));
					if (Paths.formatToSongPath(curSong) == "howdy")
					{
						var name:String = "tutoriel";
						var poop = Highscore.formatSong("tutoriel", 1);

						PlayState.SONG = Song.loadFromJson(poop, name);
						PlayState.isRPG = true;
						PlayState.storyDifficulty = 1;
						LoadingState.loadAndSwitchState(new PlayState());
					}
					else if ((Paths.formatToSongPath(curSong) == "tutoriel"))
					{
						RPGState.didFlowey = true;
						RPGState.followToriel = true;
						RPGState.afterToriel = true;
						MusicBeatState.switchState(new RPGState());
					}
					else if ((Paths.formatToSongPath(curSong) == "whimsum") || (Paths.formatToSongPath(curSong) == "froggit"))
					{
						openSubState(new ChooseFate());
					}

					else if ((Paths.formatToSongPath(curSong) == "soulbreak"))
					{
						if (enemyhealth < 1)
							RPGState.fights += 1;
						else
							RPGState.spares += 1;
						RPGState.didToriel = true;
						MusicBeatState.switchState(new RPGState());
					}
					else if ((Paths.formatToSongPath(curSong) == "heartache"))
					{
						RPGState.didToriel = true;
						openSubState(new ChooseFate());
					}
					else if ((Paths.formatToSongPath(curSong) == "mychild"))
					{
						RPGState.didDummy = true;
						MusicBeatState.switchState(new RPGState());
					}
					else if ((Paths.formatToSongPath(curSong) == "dummy"))
					{
						if (songHits > 0 && songMisses > 10)
						{

							pauseMusic.volume = .3;
							pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
							var file:String = Paths.json(songName + '/mechile'); //Checks for json/Psych Engine dialogue
							if (OpenFlAssets.exists(file)) 
							{
								dialogueJson = DialogueBoxPsych.parseDialogue(file);
							}
						startDerpDialogue(dialogueJson);
						}
						else
						{
						RPGState.didDummy = true;
						openSubState(new ChooseFate());
						}
					}
					else
					{
					if (Paths.formatToSongPath(curSong) == 'spooky-shuffle')
						{
							RPGState.didBlooky = true;
							trace("Blooky Done!");
						}
					openSubState(new ChooseFate());
				}
				}
				else{
					MusicBeatState.switchState(new RPGState());
				}
				deathCounter = 0;
				savedTime = 0;
				usedPractice = false;
				changedDifficulty = false;
				cpuControlled = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:Int) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + 8); 

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.5)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.25)
		{
			daRating = 'good';
			score = 200;
		}

		if(daRating == 'sick' && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			songHits++;
			RecalculateRating();
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.1;
			scoreTxt.scale.y = 1.1;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = !ClientPrefs.hideHud;

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.visible = !ClientPrefs.hideHud;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.alpha = 0;
			numScore.x = coolText.x + (43 * 1.3) - 90;
			numScore.y -= 80;

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(295, 300);
			numScore.velocity.y -= FlxG.random.int(155, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.hideHud;
			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				}
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;

		var upP = controls.NOTE_UP_P;
		var rightP = controls.NOTE_RIGHT_P;
		var downP = controls.NOTE_DOWN_P;
		var leftP = controls.NOTE_LEFT_P;

		var upR = controls.NOTE_UP_R;
		var rightR = controls.NOTE_RIGHT_R;
		var downR = controls.NOTE_DOWN_R;
		var leftR = controls.NOTE_LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
		var controlReleaseArray:Array<Bool> = [leftR, downR, upR, rightR];
		var controlHoldArray:Array<Bool> = [left, down, up, right];

		// FlxG.watch.addQuick('asdfa', upP);
		if (!boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit 
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});

			if ((controlHoldArray.contains(true) || controlArray.contains(true)) && !endingSong) {
				var canMiss:Bool = !ClientPrefs.ghostTapping;
				if (controlArray.contains(true)) {
					for (i in 0...controlArray.length) {
						// heavily based on my own code LOL if it aint broke dont fix it
						var pressNotes:Array<Note> = [];
						var notesDatas:Array<Int> = [];
						var notesStopped:Bool = false;

						var sortedNotesList:Array<Note> = [];
						notes.forEachAlive(function(daNote:Note)
						{
							if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate 
							&& !daNote.wasGoodHit && daNote.noteData == i) {
								sortedNotesList.push(daNote);
								notesDatas.push(daNote.noteData);
								canMiss = true;
							}
						});
						sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

						if (sortedNotesList.length > 0) {
							for (epicNote in sortedNotesList)
							{
								for (doubleNote in pressNotes) {
									if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 10) {
										doubleNote.kill();
										notes.remove(doubleNote, true);
										doubleNote.destroy();
									} else
										notesStopped = true;
								}
									
								// eee jack detection before was not super good
								if (controlArray[epicNote.noteData] && !notesStopped) {
									goodNoteHit(epicNote);
									pressNotes.push(epicNote);

								}
								
							}
						}
						else if (canMiss) 
						{
							ghostMiss(controlArray[i], i, true);
						
						}
						// I dunno what you need this for but here you go
						//									- Shubs

						// Shubs, this is for the "Just the Two of Us" achievement lol
						//									- Shadow Mario
						if (!keysPressed[i] && controlArray[i]) 
							keysPressed[i] = true;
					}
				}

				#if ACHIEVEMENTS_ALLOWED
				var achieve:Int = checkForAchievement([11]);
				if (achieve > -1) {
					startAchievement(achieve);
				}
				#end
			} else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();
		}
		playerStrums.forEach(function(spr:StrumNote)
		{
			if(controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm') {

				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			if(controlReleaseArray[spr.ID]) {
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
		});
	}

	function ghostMiss(statement:Bool = false, direction:Int = 0, ?ghostMiss:Bool = false) {
		if (statement) {
			noteMissPress(direction, ghostMiss);
			callOnLuas('noteMissPress', [direction]);
		}
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 10) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});

		health -= daNote.missHealth; //For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		RecalculateRating();

		var animToPlay:String = '';
		switch (Math.abs(daNote.noteData) % 4)
		{
			case 0:
				animToPlay = 'singLEFTmiss';
			case 1:
				animToPlay = 'singDOWNmiss';
			case 2:
				animToPlay = 'singUPmiss';
			case 3:
				animToPlay = 'singRIGHTmiss';
		}

		if(daNote.noteType == 'GF Sing') {
			gf.playAnim(animToPlay, true);
		} else {
			var daAlt = '';
			if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

			boyfriend.playAnim(animToPlay + daAlt, true);
		}
		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1, ?ghostMiss:Bool = false):Void //You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				if(ghostMiss) ghostMisses++;
				songMisses++;
			}
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
			vocals.volume = 0;
		}
	}

	function goodNoteHit(note:Note):Void
	{

		
		
		if (note.noteType == "Fight Note"){
			fightNote();
			enemyhealth -= 1;
		}

		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
					
				}

				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
					case 'Sans Note': //Hurt note
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
					case 'Fight Note':
						trace("Yep");
						fightNote();
				}
				
				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				popUpScore(note);
				combo += 1;
				if(combo > 9999) combo = 9999;
			}
			if(Paths.formatToSongPath(curSong) == "mychild" && !didAllDialogue)
			{
				if (FlxG.save.data.moreSoul == true)
				{
					health += note.hitHealth/2.5;
				}
				else
				{
					health += note.hitHealth/1.75;
				}
			}
			else
			{
				if (FlxG.save.data.moreSoul == true)
				{
					health += note.hitHealth/1.25;
				}
				else
				{
					health += note.hitHealth;
				}
			}

			if(!note.noAnimation) {
				var daAlt = '';
				if(note.noteType == 'Alt Animation') daAlt = '-alt';
	
				var animToPlay:String = '';
				switch (Std.int(Math.abs(note.noteData)))
				{
					case 0:
						animToPlay = 'singLEFT';
					case 1:
						animToPlay = 'singDOWN';
					case 2:
						animToPlay = 'singUP';
					case 3:
						animToPlay = 'singRIGHT';
				}

				if(note.noteType == 'GF Sing') {
					gf.playAnim(animToPlay + daAlt, true);
					gf.holdTimer = 0;
				} else {
					boyfriend.playAnim(animToPlay + daAlt, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {

					}
	
					if(gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}
	function flashWhite() 
	{
		if (ClientPrefs.flashing)
		{
			wFlash.alpha = 1;
			FlxTween.tween(wFlash, {alpha: 0}, 0.25, {startDelay: 0.1});
		}
	}
	function spawnWarningOnNote(direction) {
		var skin:String = 'warning';
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		var offset:Int = 0;
		switch(direction)
		{
		case (0):
			offset = 0;
		case(1):
			offset = 110;
		case(2):
			offset = 220;
		case(3):
			offset = 330;
		}

		splash.setupNoteSplash(strumLine.x + 800 + offset, strumLine.y + 115, direction, skin, 1, 1, 1);
		grpNoteSplashes.add(splash);
	}
	function spawnBoxOnNote(direction) {
		var skin:String = 'box';
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		var offset:Int = 0;
		if (direction == 1)
		{
			if (!ClientPrefs.downScroll)
				offset = 100;
			else
				offset = -100;
		}
		splash.setupNoteSplash(strumLine.x + 700, strumLine.y + 75 + offset, direction, skin, 1, 1, 1);
		grpNoteSplashes.add(splash);
	}
	function spawnSlashOnNote(direction) {
		var skin:String = 'Slash';
		if (Paths.formatToSongPath(curSong) == 'megalovania')
			{
				skin = 'bone';
			}
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		var offset:Int = 0;
		if (direction == 1)
		{
			if (!ClientPrefs.downScroll)
				offset = 100;
			else
				offset = -100;
		}
		splash.setupNoteSplash(strumLine.x + 500, strumLine.y + 75 + offset, direction, skin, 1, 1, 1);
		grpNoteSplashes.add(splash);
	}

		function spawnLightningOnNote(direction) {
			var skin:String = 'lightning';
			if (Paths.formatToSongPath(curSong) == 'megalovania' || Paths.formatToSongPath(curSong) == 'tutorial')
			{
				skin = 'blaster';
			}
			if (Paths.formatToSongPath(curSong) == 'your-worst-nightmare')
			{
				skin = 'vine';
			}
			if (Paths.formatToSongPath(curSong) == 'hopes-and-dreams')
			{
				FlxG.camera.shake(0.03,0.3);
			}
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		var offset:Int = 0;
		switch(direction)
		{
		case (0):
			offset = 0;
		case(1):
			offset = 110;
		case(2):
			offset = 220;
		case(3):
			offset = 330;
		}
		splash.setupNoteSplash(strumLine.x + 820 + offset, -50, direction, skin, 1, 1, 1);
		grpNoteSplashes.add(splash);
	}
	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}
		public function spawnLightning(x:Float, y:Float, data:Int, ?note:Note = null) 
		{
		var skin:String = 'lightning';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}
	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
			gf.specialAnim = true;
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.danced = false; //Sets head to the correct position once the animation ends
		gf.playAnim('hairFall');
		gf.specialAnim = true;
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}
		if(gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				var achieve:Int = checkForAchievement([10]);
				if(achieve > -1) {
					startAchievement(achieve);
				} else {
					FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	private var preventLuaRemove:Bool = false;
	override function destroy() {
		preventLuaRemove = true;
		for (i in 0...luaArray.length) {
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];
		super.destroy();
	}

	public function cancelFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua) {
		if(luaArray != null && !preventLuaRemove) {
			luaArray.remove(lua);
		}
	}
	var lastStepHit:Int = -1;
	override function stepHit()
	{

		if (choice == "spare"){
			trace("CHOICE!!!!!");
			choice = "";
			var file:String = Paths.json(songName + '/spare'); //Checks for json/Psych Engine dialogue
			if (OpenFlAssets.exists(file)) {
				dialogueJson = DialogueBoxPsych.parseDialogue(file);
			}
			startEndDialogue(dialogueJson);
		}
		if (choice == "fight"){
			FlxG.sound.play(Paths.sound('slashHit'));
			slashAttackk.alpha = 1;
			slashAttackk.animation.play('Slash');
			choice = "";
			var file:String = Paths.json(songName + '/fight'); //Checks for json/Psych Engine dialogue
			if (OpenFlAssets.exists(file)) {
				dialogueJson = DialogueBoxPsych.parseDialogue(file);
			}
			if (Paths.formatToSongPath(curSong) == "heartache")
			{
				startEndDialogue(dialogueJson,"heartacheGeno");
			}
			else if (Paths.formatToSongPath(curSong) == "spooky-shuffle")
				startEndDialogue(dialogueJson,"spooky-shuffle");
			else
			{
				dad.color = FlxColor.fromRGB(255,255,255);
				FlxTween.tween(dad, {alpha: 0}, 1, {
				startDelay: 0.1,
				ease: FlxEase.linear});
				startEndDialogue(dialogueJson,Paths.formatToSongPath(curSong));
			}
		}
		if(Paths.formatToSongPath(curSong) == "your-worst-nightmare")
		{
			fstatic.y = originalY + FlxG.random.int(-900,900);
		if (starBlaze)
		{
			doPellet();
		}

		if (curStep % 2 ==0 && (lightningAll || lightningFast || lightningSequence || lightningUnfair || lightningTriple || lightningSlow))
		{
			doVine();
		}
		if (curBeat < 48)
		{
			if (curBeat%8 <= 3)
				bg.color = bg.color + FlxColor.fromRGB(15,0,0);
			else if (curBeat%8 <= 7)
				bg.color = bg.color - FlxColor.fromRGB(15,0,0);
		}
		if (curBeat > 648)
		{
			if (curBeat%32 <= 3)
				bg.color = bg.color + FlxColor.fromRGB(15,15,0); //255 255 0
			else if (curBeat%32 <= 7)
				bg.color = bg.color - FlxColor.fromRGB(0,15,0); //255 0 255
			else if (curBeat%32 <= 11)
				bg.color = bg.color + FlxColor.fromRGB(0,0,15); //255 0 255
			else if (curBeat%32 <= 15)
				bg.color = bg.color - FlxColor.fromRGB(15,0,0); //0 0 255
			else if (curBeat%32 <= 19)
				bg.color = bg.color + FlxColor.fromRGB(0,15,0); //0 255 255
			else if (curBeat%32 <= 23)
				bg.color = bg.color - FlxColor.fromRGB(0,0,15); // 0 255 0
			else if (curBeat%32 <= 27)
				bg.color = bg.color + FlxColor.fromRGB(15,0,0); // 255 255 0
			else if (curBeat%32 <= 31)
				bg.color = bg.color - FlxColor.fromRGB(15,15,0); // 0 0 0
		}
		}
		if(Paths.formatToSongPath(curSong) == "megalovania")
		{
			if (curStep % 2 == 0 && starBlaze)
			{
				doBone();
			}
		}
		if(Paths.formatToSongPath(curSong) == "hopes-and-dreams")
		{
			var rotateRate = curStep/ 5.5;
			var rateMove:Float = 1100;
			var goToy = -200 + -Math.sin(rotateRate * 2) * rateMove * 0.45;
			var goTox = -330 -Math.cos(rotateRate) * rateMove;
			dad.x += (goTox - dad.x) / 12;
			dad.y += (goToy - dad.y) / 12;

		if (curStep % 2 ==0 && (slashAttack || slashExtra))
		{
			doBullet();
			doBullet2();
		}
		if (starBlaze)
		{
			doStarSmall();
		}
		if (curStep % 2 ==0 && (lightningAll || lightningFast || lightningSequence || lightningUnfair || lightningTriple || lightningSlow))
		{
			doThunder();
		}
		if (curStep % 2 ==0 && starBlaze)
		{
			doStar();
		}
		if (curBeat == 64)
		{
			bg.color = FlxColor.fromRGB(0,0,0);	
		}
		if (curBeat > 63)
		{
			if (curBeat%32 <= 3)
				bg.color = bg.color + FlxColor.fromRGB(15,15,0); //255 255 0
			else if (curBeat%32 <= 7)
				bg.color = bg.color - FlxColor.fromRGB(0,15,0); //255 0 255
			else if (curBeat%32 <= 11)
				bg.color = bg.color + FlxColor.fromRGB(0,0,15); //255 0 255
			else if (curBeat%32 <= 15)
				bg.color = bg.color - FlxColor.fromRGB(15,0,0); //0 0 255
			else if (curBeat%32 <= 19)
				bg.color = bg.color + FlxColor.fromRGB(0,15,0); //0 255 255
			else if (curBeat%32 <= 23)
				bg.color = bg.color - FlxColor.fromRGB(0,0,15); // 0 255 0
			else if (curBeat%32 <= 27)
				bg.color = bg.color + FlxColor.fromRGB(15,0,0); // 255 255 0
			else if (curBeat%32 <= 31)
				bg.color = bg.color - FlxColor.fromRGB(15,15,0); // 0 0 0
		}
		if (curBeat > 56 && curBeat < 64)
		{
			
			bg.color = bg.color + FlxColor.fromRGB(8,8,8);
		}
		}
		if(Paths.formatToSongPath(curSong) == "spooky-shuffle")
		{
			var rotateRate = curStep/15;
			var rateMove:Float = 150;
			var goToy = -50 + -Math.sin(rotateRate * 2) * rateMove * 0.45;
			var goTox = -2 -Math.cos(rotateRate) * rateMove;
			dad.x += (goTox - dad.x) / 100;
			dad.y += (goToy - dad.y) / 20;
		}
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var lastBeatHit:Int = -1;
	var selection = 1;
	var selection2 = 2;
	var selection3 = 3;
	var upOrDown = 0;
	var shakeEnemy = false;
	var slashAttack:Bool = false;
	var isMoving:Bool = false;	
	var slashUpOrDown:Bool = false;
	var slashExtra:Bool = false;	
	var starBlaze:Bool = false;


	override function beatHit()
	{
		super.beatHit();
		if (gotHit > 0)
		{
			gotHit -= 1;
			if (gotHit == 0)
			{
				soul.alpha = 1;
			}
		}
		else
		{

		}
		if(Paths.formatToSongPath(curSong) == "mychild" && !didAllDialogue)
		{
			if (phase1)
			{
				doSmoke();
				doSpeedLine();
			}
			if (phase2)
			{
				doSmallRock();
				doSpeedLine();
			}
			if (phase3)
			{
				doBigRock();
				doSpeedLine();
			}
			if (phase4)
			{
				doBigRock();
				doSmallRock();			
				doSpeedLine();	
			}							
			if (curBeat == 32)
			{
				dad.color = FlxColor.fromRGB(255,255,255);
			}
			if (curBeat == 104)
			{
				//phase 1
				phase1 = true;
			}
			if (curBeat == 232)
			{
				//phase 2
				hellTime = 2;
				phase2 = true;
				fire.alpha = 1;
				var color = FlxColor.fromRGB(255,196,151);
				dad.color = color;
				boyfriend.color = color;
				gf.color = color;
				bg.color = color;
				bg2.color = color;
			}			
			if (curBeat == 328)
			{				
				hellTime = 1.8;
				//vigniete 0.2 alpha
				bgVigniette.alpha = 0.4;
			}			
			if (curBeat == 396)
			{			
				hellTime = 1.5;	
				phase3 = true;
				//phase 3
			}			
			if (curBeat == 520)
			{				
				phase4 = true;
				hellTime = .9;	
				//vigniete 0.4 alpha				
				bgVigniette.alpha = 0.7;
			}
		}

		if(Paths.formatToSongPath(curSong) == "soulbreak" && !didAllDialogue)
		{
			if (curBeat == 15)
			{
				var file:String = Paths.json('soulbreak' + '/1'); 
				if (OpenFlAssets.exists(file)) {
					dialogueJson = DialogueBoxPsych.parseDialogue(file);
				}
			startDialogue(dialogueJson);
			}

			if (curBeat == 684 && enemyhealth < 1)
			{
				changeDad("torielgeno",1);
				dad.playAnim('Shocked', false);
			}
			if (curBeat == 690 && enemyhealth < 1)
			{
				dad.playAnim('Slashed', false);
			}
			if (curBeat == 696 && enemyhealth < 1)
			{
				dad.playAnim('Injured', false);
				var file:String = Paths.json('soulbreak' + '/byeGoat'); 
				if (OpenFlAssets.exists(file)) {
					dialogueJson = DialogueBoxPsych.parseDialogue(file);
				}
			startDialogue(dialogueJson);
			}
			if (curBeat == 740 && enemyhealth < 1)
			{
				changeDad("torieldeath",1);
				dad.playAnim('deathSeq', false);
			}

		}
		
		if(Paths.formatToSongPath(curSong) == "howdy" && !didAllDialogue)
		{
			if (curBeat == 1)
			{
				var file:String = Paths.json('howdy' + '/1'); 
				if (OpenFlAssets.exists(file)) {
					dialogueJson = DialogueBoxPsych.parseDialogue(file);
			}
			startDialogue(dialogueJson);
			}
			if (curBeat == 48)
			{
				var file:String = Paths.json('howdy' + '/2'); 
				if (OpenFlAssets.exists(file)) {
					dialogueJson = DialogueBoxPsych.parseDialogue(file);
			}
			startDialogue(dialogueJson);
			}
			if (curBeat == 160)
			{
				FlxTween.angle(dad, 0, -90, 1, {ease: FlxEase.quintOut});
				FlxTween.tween(dad, {x: -2000}, 2);
			}



		}
		if(lastBeatHit >= curBeat) {
			trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}
		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				//FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}
		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing"))
		{
			gf.dance();
		}

		if(curBeat % 2 == 0) {
			if (boyfriend.animation.curAnim.name != null && !boyfriend.animation.curAnim.name.startsWith("sing"))
			{
				boyfriend.dance();
			}
			if (dad.animation.curAnim.name != null && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned)
			{
				dad.dance();
			}
		} else if(dad.danceIdle && dad.animation.curAnim.name != null && !dad.curCharacter.startsWith('gf') && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned) {
			dad.dance();
		}

		switch (curStage)
		{
			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:BGSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1, [curLight]);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat);
		callOnLuas('onBeatHit', []);
	}
	public function doSpeedLine()
	{
		var smoke = new FlxSprite().loadGraphic(Paths.image('hell/speedlines'));
		smoke.x = FlxG.random.float(-400, 2300);
		smoke.y = 1200;				
		smoke.setGraphicSize(Std.int(smoke.width*1.2));
		smoke.alpha = 0.3;					
		FlxTween.tween(smoke, {y: -1700}, hellTime/1.8, {
			startDelay: 0.1,
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				remove(smoke);
			}
		});
		add(smoke);
	}
	public function doSmoke()
	{
		var smoke = new FlxSprite().loadGraphic(Paths.image('hell/smoke'));
		smoke.x = FlxG.random.float(-400, 2300);
		smoke.y = 1200;				
		smoke.setGraphicSize(Std.int(smoke.width*1.7));
		smoke.alpha = FlxG.random.float(0.2, 0.4);		
		FlxTween.angle(smoke, 0, FlxG.random.int(-90, 90), .1, {ease: FlxEase.quintOut});					
		FlxTween.tween(smoke, {y: -1700}, hellTime, {
			startDelay: 0.1,
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				remove(smoke);
			}
		});
		add(smoke);
	}
	public function doSmallRock()
	{
		var rand = Std.string(FlxG.random.int(1, 2));
		var smoke = new FlxSprite().loadGraphic(Paths.image('hell/rubbleSmall' + rand));
		smoke.x = FlxG.random.float(-400, 2300);
		smoke.y = 1200;			
		smoke.setGraphicSize(Std.int(smoke.width*1.7));	
		FlxTween.angle(smoke, 0, FlxG.random.int(-90, 90), .1, {ease: FlxEase.quintOut});			
		FlxTween.tween(smoke, {y: -1700}, hellTime, {
			startDelay: 0.1,
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				remove(smoke);
			}
		});
		add(smoke);
	}
	public function doBigRock()
	{
		var rand = Std.string(FlxG.random.int(1, 3));
		var smoke = new FlxSprite().loadGraphic(Paths.image('hell/rubbleBig' + rand));
		smoke.x = FlxG.random.float(-400, 2300);
		smoke.y = 1200;	
		smoke.setGraphicSize(Std.int(smoke.width*1.7));					
		FlxTween.angle(smoke, 0, FlxG.random.int(-90, 90), .1, {ease: FlxEase.quintOut});			
		FlxTween.tween(smoke, {y: -1700}, hellTime, {
			startDelay: 0.1,
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				remove(smoke);
			}
		});
		add(smoke);
	}
	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret != FunkinLua.Function_Continue) {
				returnVal = ret;
			}
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingString:String;
	public var ratingPercent:Float;
	public function RecalculateRating() {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('ghostMisses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if(ret != FunkinLua.Function_Stop) {
			ratingPercent = songScore / ((songHits + songMisses - ghostMisses) * 350);
			if(!Math.isNaN(ratingPercent) && ratingPercent < 0) ratingPercent = 0;

			if(Math.isNaN(ratingPercent)) {
				ratingString = '?';
			} else if(songMisses <= 0) {
				ratingPercent = 1;
				ratingString = ratingStuff[ratingStuff.length-1][0]; //Uses last string
			} else {
				for (i in 0...ratingStuff.length-1) {
					if(ratingPercent < ratingStuff[i][1]) {
						ratingString = ratingStuff[i][0];
						break;
					}
				}
			}

			setOnLuas('rating', ratingPercent);
			setOnLuas('ratingName', ratingString);
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(arrayIDs:Array<Int>):Int {
		for (i in 0...arrayIDs.length) {
			if(!Achievements.achievementsUnlocked[arrayIDs[i]][1]) {
				switch(arrayIDs[i]) {
					case 1 | 2 | 3 | 4 | 5 | 6 | 7:
						if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD' &&
						storyPlaylist.length <= 1 && WeekData.getWeekFileName() == ('week' + arrayIDs[i]) && !changedDifficulty && !usedPractice) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 8:
						if(ratingPercent < 0.2 && !practiceMode && !cpuControlled) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 9:
						if(ratingPercent >= 1 && !usedPractice && !cpuControlled) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 10:
						if(Achievements.henchmenDeath >= 100) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 11:
						if(boyfriend.holdTimer >= 20 && !usedPractice) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 12:
						if(!boyfriendIdled && !usedPractice) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 13:
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								Achievements.unlockAchievement(arrayIDs[i]);
								return arrayIDs[i];
							}
						}
					case 14:
						if(/*ClientPrefs.framerate <= 60 &&*/ ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing && !ClientPrefs.imagesPersist) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 15:
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
				}
			}
		}
		return -1;
	}
	#end

}


class ChooseFate extends MusicBeatSubstate
{
	private var grpBorder:FlxTypedGroup<FlxSprite>;
	private static var curSelected:Int = 0;
	public var switched:Bool = false;
	static var options:Array<String> = [
		'SPARE',
		'FIGHT'
	];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var grpTexts:FlxTypedGroup<AttachedText>;
	private var textNumber:Array<Int> = [];

	private var showCharacter:Character = null;
	private var descText:FlxText;

	public function new()
	{
		super();
		grpOptions = new FlxTypedGroup<Alphabet>();
		grpBorder = new FlxTypedGroup<FlxSprite>();

		for (i in 0...options.length)
		{
			var border:FlxSprite = new FlxSprite().loadGraphic(Paths.image('resetBorder'));
			border.screenCenter();
			border.setGraphicSize(Std.int(border.width*1.4));
			border.cameras = [PlayState.soulCamera];
			border.y += 200;
			border.x += (700 * (i - (options.length / 2))) + 350;
			grpBorder.add(border);

			var optionText:Alphabet = new Alphabet(0, 0, options[i], true, false);
			optionText.screenCenter();
			optionText.cameras = [PlayState.soulCamera];
			optionText.y += 200;
			optionText.x += (700 * (i - (options.length / 2))) + 350;
			grpOptions.add(optionText);
		}
		add(grpBorder);
		add(grpOptions);
		changeSelection();

	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	override function update(elapsed:Float) {

		if (controls.UI_LEFT_P) {
			changeSelection(-1);
		}
		if (controls.UI_RIGHT_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new RPGState());
		}

		if (controls.ACCEPT) {
			for (item in grpOptions.members) {
				item.alpha = 0;
			}
			for (item in grpBorder.members) {
				item.alpha = 0;
			}

			switch(options[curSelected]) {
				case 'SPARE':
					spare();
					close();

				case 'FIGHT':
					fight();
					close();
			}
		}
	}

	var dialogueCount:Int = 0;


	public function spare(){
		PlayState.choice = "spare";
		RPGState.spares += 1;
	}
	public function fight(){
		PlayState.choice = "fight";
		RPGState.fights += 1;
	}
	
	function changeSelection(change:Int = 0) 
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;
		for (item in grpBorder.members) {
			item.alpha = 1;
		}
		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.2;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}
	}
}