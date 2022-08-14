package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxSort;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import openfl.utils.Assets as OpenFlAssets;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import DialogueBoxPsych;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
using StringTools;

typedef RPGAssets = {

	var type:String;
	var name:String;
	var completion:String;
	var size:Float;
	var width:Float;
	var height:Float;
	var x:Float;
	var y:Float;
	var alpha:Float;
	var animdata:Array<String>;
	var areaname:String;
	var sectionname:String;

	var mainX:Float;
	var mainY:Float;
	var exitX:Float;
	var exitY:Float;
	var thirdX:Float;
	var thirdY:Float;
	var fourthX:Float;
	var fourthY:Float;
	var backgroundName:String;
	var next:String;
	var third:String;
	var fourth:String;
	var previous:String;
}

typedef RPGStage = {

	var assets:Array<RPGAssets>;

}

class RPGState extends MusicBeatState
{
	public var RPGSteps:Int = 0;
	public var prevDirection:String = "None";
	public var positionsArray:Array<Array<String>> = [];
	public static var previousArea:String;
	public static var areaName:String;
	public static var sectionName:String;
	public static var triggerMusic:Bool;
	public var bfSteps:Int = 0;
	public var canInteract:Bool = true;
	var credGroup:FlxGroup;
	var textGroup:FlxGroup;
	var credTextShit:Alphabet;
	public static var didBlooky:Bool;
	public static var didFlowey:Bool;
	public static var didDummy:Bool;
	public static var didToriel:Bool;
	public static var afterToriel:Bool;
	public var canMove:Bool = true;
	public static var progression:String = "Yep";
	public static var progress:Float = 0;

	public static var DEFAULT_TEXT_X = 90;
	public static var DEFAULT_TEXT_Y = 430;
	var scrollSpeed = 4500;
	var daText:Alphabet = null;

	public static var area:String;
	public static var ruinsEnemies:Array<String> = ["whimsum","froggit"];
	public static var saveIndex:Int;
	public static var enterLocation:String;
	public static var followToriel:Bool;
	public static var bfLocationX:Float;
	public var loaded = true;
	public static var bfLocationY:Float;
	public static var spares:Int;
	public static var fights:Int;
	public static var RuinsCompleted:Bool;
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public var stunned:Bool	= false;
	private var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	private var camAchievement:FlxCamera;
	var optionShit:Array<String> = ['story_mode', 'freeplay', #if ACHIEVEMENTS_ALLOWED 'awards', #end 'credits', #if !switch 'donate', #end 'options'];
	var collisionList:Array<FlxSprite> = [];
	var creditsText:Array<FlxSprite> = [];
	var obbyList:Array<FlxSprite> = [];
	var obbyList2:Array<FlxSprite> = [];
	var grpSprites = new FlxTypedGroup<FlxSprite>();
	var glow:String = "";
	var changeAnim:Bool = false;
	var overList:Array<FlxSprite> = [];
	var obbyList3:Array<FlxSprite> = [];
	var animList:Array<FlxSprite> = [];
	var cutsceneList:Array<FlxSprite> = [];
	var textList:Array<FlxSprite> = [];
	var interactList:Array<FlxSprite> = [];
	var interactList2:Array<FlxSprite> = [];
	var buttonList:Array<FlxSprite> = [];
	var buttonList2:Array<FlxSprite> = [];
	var magenta:FlxSprite;
	var overBF:FlxSprite;
	
	var overToriel:FlxSprite;
	var exit1:FlxSprite = new FlxSprite(-80);
	var exit2:FlxSprite = new FlxSprite(-80);
	var exit3:FlxSprite = new FlxSprite(-80);
	var exit4:FlxSprite = new FlxSprite(-80);
	var isInteracting:Bool = false;
	var interactingWith:Float = 0.0;
	var interactingWithTwo:Float = 0.0;
	var leftHeld:Bool = false;
	var rightHeld:Bool = false;
	var upHeld:Bool = false;
	var downHeld:Bool = false;
	public static var justTriggered:Bool = false;
	var json:RPGStage;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;
	var dialogueCount:Int = 0;
	var dialogueName:String = "";

	function findMiddle(len:Float,position:Float)
	{
		return (position - (len/4));
	}
	function torielFollow()
	{
		if (bfSteps > 30 * (ClientPrefs.framerate/60) && followToriel == true)
		{
			var first = positionsArray[0];
			overToriel.x = Std.parseFloat(first[0]) + 35;
			overToriel.y = Std.parseFloat(first[1]) - 130;
			if (first[2] != prevDirection)
			{
			prevDirection = first[2];
			switch(first[2])
			{
				case 'Right':
					overToriel.animation.play('right');
				case 'Left':
					overToriel.animation.play('left');
				case 'Up':
					overToriel.animation.play('up');
				case 'Down':
					overToriel.animation.play('down');
			}
			}
			positionsArray.remove(first);
		}
	}
	function setupCharacter(character:FlxSprite,locationX:Float = 0,locationY:Float = 0)
	{
		character.x = locationX;
		character.y = locationY;

		character.setGraphicSize(Std.int(character.width * 0.775));
		if (character == overBF)
		{
			character.frames = Paths.getSparrowAtlas('boyfriendrpg');
			character.animation.addByPrefix('glowdown', "glowboyfriend_down", 6);
			character.animation.addByPrefix('glowup', "glowboyfriend_up", 6);
			character.animation.addByPrefix('glowright', "glowboyfriend_right", 6);
			character.animation.addByPrefix('glowleft', "glowboyfriend_left", 6);
			character.animation.addByPrefix('glowdownE', "glowboyfriend_down0000", 6);
			character.animation.addByPrefix('glowupE', "glowboyfriend_up0000", 6);
			character.animation.addByPrefix('glowrightE', "glowboyfriend_right0000", 6);
			character.animation.addByPrefix('glowleftE', "glowboyfriend_left0000", 6);
		}
			
		else if (character == overToriel)
		{
			character.frames = Paths.getSparrowAtlas('torielrpg');
		}
		character.animation.addByPrefix('down', "boyfriend_down", 6);
		character.animation.addByPrefix('up', "boyfriend_up", 6);
		character.animation.addByPrefix('right', "boyfriend_right", 6);
		character.animation.addByPrefix('left', "boyfriend_left", 6);
		character.animation.addByPrefix('downE', "boyfriend_down0000", 6);
		character.animation.addByPrefix('upE', "boyfriend_up0000", 6);
		character.animation.addByPrefix('rightE', "boyfriend_right0000", 6);
		character.animation.addByPrefix('leftE', "boyfriend_left0000", 6);
		character.animation.play('upE'+ glow);
	}
	
	public function endDia():Void
	{
		canInteract = true;
	}
	public function endDiaOptions():Void
	{
		canInteract = true;
		MusicBeatState.switchState(new OptionsState());
	}
	public function startGameRuins1():Void
	{
		var name:String = "ruins1";
		var poop = Highscore.formatSong("ruins1", 1);

		PlayState.SONG = Song.loadFromJson(poop, name);
		PlayState.isStoryMode = false;
		PlayState.isRPG = false;
		PlayState.storyDifficulty = 1;
		LoadingState.loadAndSwitchState(new PlayState());
	}
	public function goToNext():Void
	{
		RPGState.area = json.assets[0].next;
		RPGState.enterLocation = "M";
		MusicBeatState.switchState(new RPGState());
	}
	public function blookyStart():Void
	{
		var name:String = "spooky-shuffle";
		var poop = Highscore.formatSong("spooky-shuffle", 1);

		PlayState.SONG = Song.loadFromJson(poop, name);
		PlayState.isRPG = true;
		PlayState.storyDifficulty = 1;
		LoadingState.loadAndSwitchState(new PlayState());
	}

		public function floweyStart():Void
	{
		var name:String = "howdy";
		var poop = Highscore.formatSong("howdy", 1);

		PlayState.SONG = Song.loadFromJson(poop, name);
		PlayState.isRPG = true;
		PlayState.storyDifficulty = 1;
		LoadingState.loadAndSwitchState(new PlayState());
	}
		public function torielStart():Void
	{
		if (spares == 0 && fights > 0)
		{
			var name:String = "soulbreak";
			var poop = Highscore.formatSong("soulbreak", 1);
			PlayState.SONG = Song.loadFromJson(poop, name);
		}
		else
		{
			var name:String = "heartache";
			var poop = Highscore.formatSong("heartache", 1);
			PlayState.SONG = Song.loadFromJson(poop, name);
		}

		PlayState.isRPG = true;
		PlayState.storyDifficulty = 1;
		LoadingState.loadAndSwitchState(new PlayState());
	}
		public function dummyStart():Void
	{
		var name:String = "dummy";
		var poop = Highscore.formatSong("dummy", 1);

		PlayState.SONG = Song.loadFromJson(poop, name);
		PlayState.isRPG = true;
		PlayState.storyDifficulty = 1;
		LoadingState.loadAndSwitchState(new PlayState());
	}

	public function startDialogueRPG(dialogueFile:DialogueFile, ?song:String = null, action:String = ""):Void
	{
		trace("dialogueStarted");
		if(dialogueFile.dialogue.length > 0) {
			var doof:DialogueBoxPsych = new DialogueBoxPsych(dialogueFile, song,1);
			doof.scrollFactor.set();
			doof.nextDialogueThing = startNextDialogue;
			doof.skipDialogueThing = skipDialogue;
			doof.cameras = [camAchievement];
			if (action == "gotoOptions"){
				doof.finishThing = endDiaOptions;
			}
			else if (action == "startGameRuins1"){
				doof.finishThing = startGameRuins1;
			}
			else if (action == "goToNext"){
				doof.finishThing = goToNext;
			}
			else if (action == "blookyStart"){
	
				FlxG.sound.music.stop();
				canMove = false;
				enterLocation = "";
				doof.finishThing = blookyStart;
			}
			else if (action == "dummyStart"){
	
				FlxG.sound.music.stop();
				canMove = false;
				enterLocation = "";
				doof.finishThing = dummyStart;
			}
			else if (action == "floweyStart"){
				bfLocationX = overBF.x;
				bfLocationY = overBF.y;
				FlxG.sound.music.stop();
				canMove = false;
				doof.finishThing = floweyStart;
			}
			else if (action == "torielStart"){
				bfLocationX = overBF.x;
				bfLocationY = overBF.y;
				FlxG.sound.music.stop();
				canMove = false;
				doof.finishThing = torielStart;
			}
			else {
				doof.finishThing = endDia;
			}
			add(doof);

		}
		else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
		}
	}



	private var luaArray:Array<FunkinLua> = [];
	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
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





	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Exploring the Underground", null);
		#end
		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		camHUD = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;


		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		credGroup = new FlxGroup();
		credGroup.cameras = [camHUD];
		textGroup = new FlxGroup();
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80);
		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		function addStageComponent(bg:FlxSprite,width:Float,height:Float,size:Float,x:Float,y:Float,transparent:Bool)
		{
			if (width > 10)
			{
				bg.width = width;
			}
			if (height > 10)
			{
				bg.height = height;
			}
			bg.setGraphicSize(Std.int(bg.width * size));
			bg.x = x;
			bg.y = y;
			bg.visible = transparent;
		}


		PlayState.isRPG = false;
		overBF = new FlxSprite(-80).loadGraphic(Paths.image('boyfriendrpg'));
		loaded = true;
		overBF.height *= 2;
		overBF.antialiasing = true;
		overBF.width *= 2;




		overToriel = new FlxSprite(-80).loadGraphic(Paths.image('torielrpg'));
		overToriel.height *= 2;
		overToriel.antialiasing = true;
		overToriel.width *= 2;

		//New RPGState

		var file:String = Paths.json('rpg/stageData/' + area);
		var rawJson = Assets.getText(file);
		json = cast Json.parse(rawJson);
				areaName = json.assets[0].areaname;
		sectionName = json.assets[0].sectionname;

		trace(sectionName);
		trace(previousArea);
		if (sectionName != previousArea)
		{
			triggerMusic = true;
		}
		previousArea = sectionName;
		if (triggerMusic)
		{
			if (sectionName == "ruins")
				FlxG.sound.playMusic(Paths.music('ruins'));
			else if (sectionName == "house")
				FlxG.sound.playMusic(Paths.music('torielHouse'));
			else
				FlxG.sound.music.stop();
		}
		triggerMusic = false;




		bg = new FlxSprite(-80).loadGraphic(Paths.image('rpg/' + json.assets[0].backgroundName));
		bg.setGraphicSize(Std.int(bg.width));
		bg.x = 0;
		bg.y = 0;

		if (enterLocation == "E")
		{
			setupCharacter(overBF,json.assets[0].exitX,json.assets[0].exitY);
		}
		else if (enterLocation == "3")
		{
			setupCharacter(overBF,json.assets[0].thirdX,json.assets[0].thirdY);
		}
		else if (enterLocation == "4")
		{
			setupCharacter(overBF,json.assets[0].fourthX,json.assets[0].fourthY);
		}
		else if (enterLocation == "M" || area == "Ruins1")
		{
			setupCharacter(overBF,json.assets[0].mainX,json.assets[0].mainY);
		}
		else
		{
			setupCharacter(overBF,bfLocationX,bfLocationY);
		}
		if (followToriel)
		{
			setupCharacter(overToriel,overBF.x,overBF.y);
		}
		add(bg);
		for (i in json.assets)
		{
			switch(i.type){
				case 'data':
					//nothing
				case 'interact':
					var interact = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
					addStageComponent(interact,i.height,i.width,i.size,i.x,i.y,false);
					add(interact);
					interact.alpha = i.alpha;
					interactList.push(interact);	
				case 'interactNoaccept':
				if (i.name == "floweyStartDialogue" && didFlowey == true)
				{
					trace("Nothing at all.");
				}
				else
				{
					var interact2 = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
					addStageComponent(interact2,i.height,i.width,i.size,i.x,i.y,false);
					interact2.alpha = i.alpha;
					interact2.setGraphicSize(Std.int(interact2.width),Std.int(interact2.height));
					add(interact2);
					interactList2.push(interact2);	
				}
				case 'button':
					var button = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
					button.frames = Paths.getSparrowAtlas(i.name);
					button.animation.addByPrefix(i.animdata[0], i.animdata[1], 24,false);
					button.animation.addByPrefix(i.animdata[2], i.animdata[3], 24,false);
					button.animation.play("normal");	
					button.x += i.x;
					button.y += i.y;
					button.setGraphicSize(Std.int(button.width*i.size));
					add(button);
					buttonList.push(button);	
				case 'button2':
					var button2 = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
					button2.frames = Paths.getSparrowAtlas(i.name);
					button2.animation.addByPrefix(i.animdata[0], i.animdata[1], 24,false);
					button2.animation.addByPrefix(i.animdata[2], i.animdata[3], 24,false);
					button2.animation.play("normal");	
					button2.x += i.x;
					button2.y += i.y;
					button2.setGraphicSize(Std.int(button2.width*i.size));
					add(button2);
					buttonList2.push(button2);	
				case 'hitbox':
					var hitbox = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
					addStageComponent(hitbox,i.height,i.width,i.size,i.x,i.y,false);
					hitbox.alpha = i.alpha;
					add(hitbox);
					obbyList.push(hitbox);	
				case 'lockbox':
					var lockbox = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
					addStageComponent(lockbox,i.height,i.width,i.size,i.x,i.y,false);
					lockbox.alpha = i.alpha;
					add(lockbox);
					obbyList3.push(lockbox);	
				case 'lock':
					var lock = new FlxSprite(-80).loadGraphic(Paths.image(i.name));
					lock.frames = Paths.getSparrowAtlas(i.name);
					lock.animation.addByPrefix("locked", i.animdata[0], 30,false);
					lock.animation.addByPrefix("unlocked", i.animdata[1], 30,false);
					lock.x += i.x;
					lock.y += i.y;
					add(lock);
					obbyList2.push(lock);	
					lock.animation.play("locked");	
				case 'animated':
					var animated = new FlxSprite(-80).loadGraphic(Paths.image(i.name));
					animated.frames = Paths.getSparrowAtlas(i.name);
					animated.animation.addByPrefix(i.animdata[0], i.animdata[1], 30);
					animated.x += i.x;
					animated.y += i.y;
					animated.setGraphicSize(Std.int(animated.width*i.size));
					add(animated);

					animList.push(animated);
					animated.animation.play(i.animdata[0]);	
				case 'cutscene':
					var cutscene = new FlxSprite(-80).loadGraphic(Paths.image(i.name));
					cutscene.x += i.x;
					cutscene.y += i.y;
					cutscene.setGraphicSize(Std.int(cutscene.width*i.size));

					if (i.name == "RPGFlowey" && didFlowey == false && RPGState.area == "RuinsSphere")
						add(cutscene);
					if (i.name == "RPGFlowey" && RuinsCompleted == false && RPGState.area == "RuinsFinal")
						add(cutscene);
					if (i.name == "RPGDummy" && didDummy == false)
						add(cutscene);

					cutsceneList.push(cutscene);
				case 'prop':
					var animated = new FlxSprite(-80).loadGraphic(Paths.image(i.name));
					animated.x = i.x;
					animated.y = i.y;
					animated.setGraphicSize(Std.int(animated.width*i.size));
					overList.push(animated);
				case 'exit':
					if (i.name == "1"){
						exit1 = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
						addStageComponent(exit1,i.height,i.width,i.size,i.x,i.y,false);
						add(exit1);
						obbyList.push(exit1);
					}
					else if (i.name == "3"){
						exit3 = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
						addStageComponent(exit3,i.height,i.width,i.size,i.x,i.y,false);
						add(exit3);
						obbyList.push(exit3);
					}
					else if (i.name == "4"){
						exit4 = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
						addStageComponent(exit4,i.height,i.width,i.size,i.x,i.y,false);
						add(exit4);
						obbyList.push(exit4);
					}
					else{
						exit2 = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
						addStageComponent(exit2,i.height,i.width,i.size,i.x,i.y,false);
						add(exit2);
						obbyList.push(exit2);
					}

			}
		}
		if (RPGState.enterLocation == "E")
		{
			for (i in obbyList2)
			{
				i.animation.play("unlocked");
				obbyList2.remove(i);
			}
			for (i in obbyList3)
			{
				obbyList3.remove(i);
			}
		}
		if (followToriel == true)
		{
				
			grpSprites.add(overBF);
			grpSprites.add(overToriel);
			add(grpSprites);
		}
		else
		{
			add(overBF);
		}
		if (afterToriel)
		{
			afterToriel = false;
			var file:String = Paths.json('rpg/afterToriel'); 
			if (OpenFlAssets.exists(file)) {
				trace("File Found!");
				dialogueJson = DialogueBoxPsych.parseDialogue(file);
				startDialogueRPG(dialogueJson,"");
			}
			else
			{
				trace("No file found!");
			}
		}
		bfSteps = 0;
		var bgShadow = new FlxSprite(-80).loadGraphic(Paths.image('rpg/' + json.assets[0].backgroundName + "Shadow"));
		bgShadow.setGraphicSize(Std.int(bgShadow.width));
		bgShadow.x = 0;
		bgShadow.y = 0;
		bgShadow.updateHitbox();
		bgShadow.antialiasing = false;
		add(bgShadow);
		for (i in overList)
		{
			add(i);
		}
		RPGState.enterLocation = "";
		bg.updateHitbox();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		collisionList.push(bg);
		var scoreText:FlxText = new FlxText(10, 10, 0, progression, 36);
		scoreText.setFormat("VCR OSD Mono", 32);



		camGame.minScrollX = bg.x;
		camGame.minScrollY = bg.y;
		camGame.maxScrollX = bg.x + bg.width;
		camGame.maxScrollY = bg.y + bg.height;


		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();




		// NG.core.calls.event.logEvent('swag').send();


		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (!Achievements.achievementsUnlocked[achievementID][1] && leDate.getDay() == 5 && leDate.getHours() >= 18) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
			Achievements.achievementsUnlocked[achievementID][1] = true;
			giveAchievement();
			ClientPrefs.saveSettings();
		}
		#end

		super.create();
	}
	function createCoolText(text:String, ?offset:Float = 800)
	{
		var money:Alphabet = new Alphabet(0, 0, text, true, false,0.05,.6,"dialogue","White");
		money.screenCenter();
		money.y += offset;
		creditsText.push(money);
		money.cameras = [camHUD];
		add(money);
	}
	function toBeContinued()
	{
		var wFlash:FlxSprite = new FlxSprite().loadGraphic(Paths.image('flashWhite'));
		wFlash.width *= 20;
		wFlash.height *= 20;
		wFlash.setGraphicSize(Std.int(wFlash.width));
		wFlash.updateHitbox();
		add(wFlash);
		wFlash.screenCenter();
		wFlash.alpha = 0;
		loaded = false;
		canMove = false;
		var funkay:FlxSprite;
		FlxG.sound.play(Paths.sound('riser'));
		FlxTween.tween(wFlash, {alpha: 1}, 5.7, 
		{onComplete: function (twn:FlxTween) 
			{
				wFlash.color = FlxColor.fromRGB(0,0,0);
				funkay = new FlxSprite(0, 0).loadGraphic(Paths.getPath('images/undertaleLoading.png', IMAGE));
				funkay.height *= 1.4;
				funkay.width *= 1.4;
				funkay.setGraphicSize(0, FlxG.height);
				funkay.updateHitbox();
				funkay.antialiasing = ClientPrefs.globalAntialiasing;
				add(funkay);
				funkay.scrollFactor.set();
				funkay.screenCenter();
				FlxG.sound.play(Paths.sound('boom'));
			}
		}
		);
		FlxTween.tween(overBF, {alpha: 1}, 2, {
			startDelay: 6,
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				add(credGroup);
				createCoolText("TO BE CONTINUED...",200);
				FlxG.sound.playMusic(Paths.music('credits'));
				createCoolText("TOBY FOX: Undertale Creator",500);
				createCoolText("TEMMIE CHANG: Undertale Artist",600);

				createCoolText("BOXOFROCKS: Director - Musician - Charter - Coder",800);
				createCoolText("EEF: Character Artist",900);
				createCoolText("EGG OVERLORD: Character Artist",1000);
				createCoolText("INFERNOSILENTDRAGON: Character Artist",1100);
				createCoolText("LIGHTYWIGHTY: Character Artist",1200);
				createCoolText("YOSHIFAN33: Character Artist",1300);
				createCoolText("XINAOLL: Character Animator",1400);
				createCoolText("NYXTHESHIELD: Overworld BF Sprite",1500);
				createCoolText("JAEL PENAZOLA: Overworld BF Sprite",1550);
				createCoolText("IVIS: Voice Actor",1700);
				createCoolText("VIDZ: Coder",1800);
				createCoolText("BLAIXENU: Charter",1900);
				createCoolText("RAM: Story",2000);
				createCoolText("SIRJ: Charter",2100);
				createCoolText("RENTEI: Artist",2200);
				createCoolText("There are still quite a few secrets you may have missed...",2500);
				createCoolText("Miss 40+ notes on Dummy and get hit by his lone bullet...",2600);
				createCoolText("THANK YOU FOR PLAYING!",3000);
				FlxG.sound.play(Paths.sound('boom'));
				funkay.alpha = 0;
				for (i in creditsText)
				{
					FlxTween.tween(i, {y: i.y - 3100}, 40, {
					startDelay: 3,
					ease: FlxEase.linear});
				}
			}
		});
		FlxTween.tween(overBF, {alpha: 0}, 45, 
		{startDelay: 11,onComplete: function (twn:FlxTween) 
			{
				FlxG.sound.music.stop();
				MusicBeatState.switchState(new RPGLoadingSaveState());	
			}
		}
		);



	}
	function nextArea(name:FlxSprite)
	{
		if (name == exit2)
		{
			RPGState.area = json.assets[0].previous;
			RPGState.enterLocation = "E";
			MusicBeatState.switchState(new RPGState());

		}
		else if (name == exit1)
		{

			if (RPGState.area == "Ruins10" && followToriel && loaded)
			{
				loaded = false;
				var file:String = Paths.json('rpg/torielLeave'); 
				if (OpenFlAssets.exists(file)) {
					trace("File Found!");
					dialogueJson = DialogueBoxPsych.parseDialogue(file);
					startDialogueRPG(dialogueJson,"goToNext");
					followToriel = false;
				}
				else
				{
					trace("No file found!");
				}
			}
			else if (json.assets[0].next == "Snowdin1" && loaded)
			{
				toBeContinued();
			}
			else
			{
				if (loaded)
				{
					loaded = false;
					RPGState.area = json.assets[0].next;
					RPGState.enterLocation = "M";
					MusicBeatState.switchState(new RPGState());
				}
			}
		}
		else if (name == exit3)
		{
			RPGState.area = json.assets[0].third;
			RPGState.enterLocation = "3";
			MusicBeatState.switchState(new RPGState());
		}
		else if (name == exit4)
		{
			RPGState.area = json.assets[0].fourth;
			RPGState.enterLocation = "4";
			MusicBeatState.switchState(new RPGState());
		}				
	}
	function addInteractText()
	{
		for (i in 0...textList.length)
			textList[i].visible = true;
	}
	function unlockThing()
	{
		if (buttonList.length == 0)
		{
			FlxG.sound.play(Paths.sound('solved'));
			for (i in obbyList2)
			{
				i.animation.play("unlocked");
				obbyList2.remove(i);
			}
			for (i in obbyList3)
			{
				obbyList3.remove(i);
			}
		}
	}
	function restartThing()
	{
		FlxG.sound.play(Paths.sound('no'));
		RPGState.enterLocation = "M";
		MusicBeatState.switchState(new RPGState());
	}
	function removeInteractText()
	{
		for (i in 0...textList.length)
			textList[i].visible = false;
	}
	function checkInteractables(xCoord:Float,yCoord:Float)
	{
		var minX:Float;
		var minY:Float;
		var maxX:Float;
		var maxY:Float;
		var checkDetect:Bool = true;
		var checkDetect2:Bool = true;
		var checkDetect3:Bool = true;

		for (i in 0...interactList.length) 
		{
			
			minX = interactList[i].x + 150;
			minY = interactList[i].y + 50;
			maxX = interactList[i].x  + interactList[i].width +150;
			maxY = interactList[i].y + interactList[i].height +150;

			if (overBF.y + yCoord < minY || overBF.y + yCoord > maxY || overBF.x + xCoord < minX || overBF.x + xCoord > maxX)
			{
				if(checkDetect)
				{
					//jack shit
				}
			}
			else
			{
				if (checkDetect)
				{
					checkDetect = false;
				}
			}
			if (checkDetect)
			{
				if (ClientPrefs.progression >= 1)
				{
					removeInteractText();
				}
				else
				addInteractText();
				isInteracting = false;
				interactingWith = 0;
			}
			else
			{
				addInteractText();
				isInteracting = true;
				interactingWith = interactList[i].alpha;
			}
		}
		for (i in 0...interactList2.length) 
		{
			
			minX = interactList2[i].x + 150;
			minY = interactList2[i].y + 50;
			maxX = interactList2[i].x  + interactList2[i].width +150;
			maxY = interactList2[i].y + interactList2[i].height +150;

			if (overBF.y + yCoord < minY || overBF.y + yCoord > maxY || overBF.x + xCoord < minX || overBF.x + xCoord > maxX)
			{
				if(checkDetect2)
				{
					//jack shit
				}
			}
			else
			{
				if (checkDetect2)
				{
					checkDetect2 = false;
				}
			}
			if (!checkDetect2) 
			{
				addInteractText();
				interactingWithTwo = interactList2[i].alpha;
				for (j in json.assets)
				{
					if (j.alpha == interactingWithTwo && canMove == true)
					{
						doDialogue(j);
					}
			}
			}
		}
		for (i in 0...buttonList.length) 
		{
			if (!RPGState.justTriggered)
			{
			minX = buttonList[i].x - 100;
			minY = buttonList[i].y + 220;
			maxX = buttonList[i].x  + buttonList[i].width + 30;
			maxY = buttonList[i].y + buttonList[i].height + 190;

			if (overBF.y + yCoord < minY - 500 || overBF.y + yCoord > maxY - 410 || overBF.x + xCoord < minX - 40 || overBF.x + xCoord > maxX)
			{
				if(checkDetect3)
				{
					//jack shit
				}
			}
			else
			{
				if (checkDetect3)
				{
					checkDetect3 = false;
				}
			}
			if (!checkDetect3) 
			{
				trace("TRIGGERED");
				RPGState.justTriggered = true;
				interactingWithTwo = buttonList[i].alpha;
				buttonList[i].animation.play('press');
				buttonList.remove(buttonList[i]);
				FlxG.sound.play(Paths.sound('projectileSpawn'));
				unlockThing();
			}
			}
		}
		for (i in 0...buttonList2.length) 
		{
			if (!RPGState.justTriggered)
			{
			minX = buttonList2[i].x - 100;
			minY = buttonList2[i].y + 220;
			maxX = buttonList2[i].x  + buttonList2[i].width + 30;
			maxY = buttonList2[i].y + buttonList2[i].height + 190;

			if (overBF.y + yCoord < minY - 500 || overBF.y + yCoord > maxY - 410 || overBF.x + xCoord < minX - 40 || overBF.x + xCoord > maxX)
			{
				if(checkDetect3)
				{
					//jack shit
				}
			}
			else
			{
				if (checkDetect3)
				{
					checkDetect3 = false;
				}
			}
			if (!checkDetect3) 
			{
				trace("TRIGGERED");
				RPGState.justTriggered = true;
				interactingWithTwo = buttonList2[i].alpha;
				buttonList2[i].animation.play('press');
				buttonList2.remove(buttonList2[i]);
				FlxG.sound.play(Paths.sound('projectileSpawn'));
				restartThing();
			}
			}
		}
	}
	function pickRandomEnemy()
	{
		if (sectionName == "ruins")
		{
			var random = FlxG.random.int(0, ruinsEnemies.length-1);
			var poop = Highscore.formatSong(ruinsEnemies[random], 1);

			PlayState.SONG = Song.loadFromJson(poop, ruinsEnemies[random]);
			PlayState.isRPG = true;
			PlayState.storyDifficulty = 1;
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}
	function doEncounter()
	{
		bfLocationX = overBF.x;
		bfLocationY = overBF.y;
		canMove = false;
		canInteract = false;
		var exclamation:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('exclamation'));
		exclamation.setGraphicSize(Std.int(exclamation.width * 0.4));
		exclamation.x = overBF.x + 0;
		exclamation.y = overBF.y - 300;
		add(exclamation);
		FlxG.sound.play(Paths.sound('exclamation'));
		FlxTween.tween(exclamation, {alpha: 1}, 0.5, 
		{onComplete: function (twn:FlxTween) 
			{
				FlxG.sound.play(Paths.sound('enemy'));
				pickRandomEnemy();
			}
		}
		);
		
	}
	function checkEncounter()
	{
		RPGSteps++;
		if (RPGSteps > 1750 && buttonList.length <= 0 && buttonList2.length <= 0 && interactList2.length <= 0)
		{
			if (sectionName == "ruins")
			{
			var random = FlxG.random.int(0, 700);
			trace(random);
			if (random == 99)
			{
				trace("YOU FOUND AN ENEMY SHITHEAD");
				doEncounter();
			}
			}
		}
	}
	function checkCollision(xCoord:Float,yCoord:Float)
	{
		checkEncounter();
		RPGState.justTriggered = false;
		var minX:Float;
		var minY:Float;
		var maxX:Float;
		var maxY:Float;
		for (i in 0...obbyList.length) 
		{
			minX = obbyList[i].x - 150;
			minY = obbyList[i].y - 250;
			maxX = obbyList[i].x  + obbyList[i].width - 150;
			maxY = obbyList[i].y + obbyList[i].height - 250;

			if (overBF.y + yCoord < minY || overBF.y + yCoord > maxY || overBF.x + xCoord < minX || overBF.x + xCoord > maxX)
			{
				//nothing
			}
			else
			{
				if (obbyList[i] == exit1 || obbyList[i] == exit2 || obbyList[i] == exit3 || obbyList[i] == exit4)
				{
					nextArea(obbyList[i]);
				}
				return false;
			}
		}
		for (i in 0...obbyList2.length) 
		{
			minX = obbyList2[i].x - 150;
			minY = obbyList2[i].y - 250;
			maxX = obbyList2[i].x  + obbyList2[i].width - 150;
			maxY = obbyList2[i].y + obbyList2[i].height - 250;

			if (overBF.y + yCoord < minY || overBF.y + yCoord > maxY || overBF.x + xCoord < minX || overBF.x + xCoord > maxX)
			{
				//nothing
			}
			else
			{
				return false;
			}
		}
		for (i in 0...obbyList3.length) 
		{
			minX = obbyList3[i].x - 150;
			minY = obbyList3[i].y - 250;
			maxX = obbyList3[i].x  + obbyList3[i].width - 150;
			maxY = obbyList3[i].y + obbyList3[i].height - 250;

			if (overBF.y + yCoord < minY || overBF.y + yCoord > maxY || overBF.x + xCoord < minX || overBF.x + xCoord > maxX)
			{
				//nothing
			}
			else
			{
				return false;
			}
		}


		for (i in 0...collisionList.length) 
		{
			var minX:Float = collisionList[i].x - 50;
			var minY:Float = collisionList[i].y -50;
			var maxX:Float = collisionList[i].x + collisionList[i].width - 250;
			var maxY:Float = collisionList[i].y + collisionList[i].height -250;

			if (overBF.y + yCoord < minY || overBF.y + yCoord > maxY || overBF.x + xCoord < minX || overBF.x + xCoord > maxX)
			{
				return false;
			}
		}
		return true;
	}
	function checkHeld()
	{
		if (downHeld)
		{
			overBF.animation.play(glow + 'down');
			return true;
		}
		else if (upHeld)
		{
			overBF.animation.play(glow + 'up');
			return true;
		}
		else if (rightHeld)
		{
			overBF.animation.play(glow + 'right');
			return true;
		}
		else if (leftHeld)
		{
			overBF.animation.play(glow + 'left');
			return true;
		}
		else
		{
			return false;
		}
	}
	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	var achievementID:Int = 0;
	function giveAchievement() {
		add(new AchievementObject(achievementID, camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement ' + achievementID);
	}
	#end

	var selectedSomethin:Bool = false;
	
	
	function doDialogue(asset:RPGAssets)
	{
		if (asset.name == "blookyStartDialogue")
		{
			if (!didBlooky)
			{
			trace(didBlooky);
			var file:String = Paths.json('rpg/' + asset.name); 
			if (OpenFlAssets.exists(file)) {
				trace("File Found!");
				dialogueJson = DialogueBoxPsych.parseDialogue(file);
				startDialogueRPG(dialogueJson,"",asset.completion);
			}
			else
			{
				trace("No file found!");
			}
			}
		}
		else if (asset.name == "dummyStartDialogue")
		{
			if (!didDummy)
			{
			var file:String = Paths.json('rpg/' + asset.name); 
			if (OpenFlAssets.exists(file)) {
				trace("File Found!");
				dialogueJson = DialogueBoxPsych.parseDialogue(file);
				startDialogueRPG(dialogueJson,"",asset.completion);
			}
			else
			{
				trace("No file found!");
			}
			}
		}
		else if (asset.name == "floweyStartDialogue")
		{
			if (!didFlowey)
			{
			var file:String = Paths.json('rpg/' + asset.name); 
			if (OpenFlAssets.exists(file)) {
				trace("File Found!");
				dialogueJson = DialogueBoxPsych.parseDialogue(file);
				startDialogueRPG(dialogueJson,"",asset.completion);
			}
			else
			{
				trace("No file found!");
			}
			}
		}
		else if (asset.name == "torielStartDialogue")
		{
			if (!didToriel)
			{
			var file:String = Paths.json('rpg/' + asset.name); 
			if (OpenFlAssets.exists(file)) {
				trace("File Found!");
				dialogueJson = DialogueBoxPsych.parseDialogue(file);
				startDialogueRPG(dialogueJson,"",asset.completion);
			}
			else
			{
				trace("No file found!");
			}
			}
		}
		else if (asset.name == "ruinsFinalDialogue")
		{
			if (!RuinsCompleted)
			{
				RuinsCompleted = true;
			var file:String;
			if (spares > 0 && fights == 0)
				file = Paths.json('rpg/ruinsEndDialoguePaci'); 
			else if (spares == 0 && fights > 0)
				file = Paths.json('rpg/ruinsEndDialogueGeno'); 
			else
				file = Paths.json('rpg/ruinsEndDialogueNeutral'); 
			if (OpenFlAssets.exists(file)) {
				trace("File Found!");
				dialogueJson = DialogueBoxPsych.parseDialogue(file);
				startDialogueRPG(dialogueJson,"","");
			}
			else
			{
				trace("No file found!");
			}
			}
		}
		else
		{
			var file:String = Paths.json('rpg/' + asset.name); 
			if (OpenFlAssets.exists(file)) {
				trace("File Found!");
				dialogueJson = DialogueBoxPsych.parseDialogue(file);
				startDialogueRPG(dialogueJson,"",asset.completion);
			}
			else
			{
				trace("No file found!");
			}
		}
	}



	override function update(elapsed:Float)
	{
		if (isInteracting)
		{
			if (glow == "")
			{
				changeAnim = true;
			}
			glow = "glow";
		}
		else
		{
			if (glow == "glow")
			{
				changeAnim = true;
			}
			glow = "";
			changeAnim = true;
		}
		if (followToriel)
		{
			grpSprites.sort((Order, Obj1, Obj2) ->
 			 {
   				return FlxSort.byValues(Order, Obj1.y + Obj1.height, Obj2.y + Obj2.height);
  			});
		}

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		FlxG.camera.follow(overBF,FlxCameraFollowStyle.LOCKON);
		FlxG.camera.zoom = .5;
		if (!selectedSomethin && canInteract && canMove)
		{
			var loggedPos = false;
			if (controls.UI_UP)
			{
				if (changeAnim)
				{
					changeAnim = false;
					overBF.animation.play(glow + 'up');
				}
				if (checkCollision(0,-10))
				{
					bfSteps++;
					overBF.y -= 20 * (60/ClientPrefs.framerate);
					var BFX = Std.string(overBF.x);
					var BFY = Std.string(overBF.y);
					if (!loggedPos)
					{
						positionsArray.push([BFX,BFY,"Up"]);
						torielFollow();
						loggedPos = true;
					}
				}
				checkInteractables(0,0);
			}

			if (controls.UI_DOWN)
			{
				if (changeAnim)
				{
					changeAnim = false;
					overBF.animation.play(glow + 'down');
				}
				if (checkCollision(0,10))
				{
					bfSteps++;
					overBF.y += 20 * (60/ClientPrefs.framerate);
					var BFX = Std.string(overBF.x);
					var BFY = Std.string(overBF.y);
					if (!loggedPos)
					{
						positionsArray.push([BFX,BFY,"Down"]);
						torielFollow();
						loggedPos = true;
					}
				}
				checkInteractables(0,0);
			}

			if (controls.UI_LEFT)
			{
				if (changeAnim)
				{
					changeAnim = false;
					overBF.animation.play(glow + 'left');
				}
				if (checkCollision(-10,0))
				{
					bfSteps++;
					overBF.x -= 20 * (60/ClientPrefs.framerate);
					var BFX = Std.string(overBF.x);
					var BFY = Std.string(overBF.y);
					if (!loggedPos)
					{
						positionsArray.push([BFX,BFY,"Left"]);
						torielFollow();
						loggedPos = true;
					}
				}
				checkInteractables(0,0);
			}

			if (controls.UI_RIGHT)
			{
				if (changeAnim)
				{
					changeAnim = false;
					overBF.animation.play(glow + 'right');
				}
				if (checkCollision(10,0))
				{
					bfSteps++;
					overBF.x += 20 * (60/ClientPrefs.framerate);
					var BFX = Std.string(overBF.x);
					var BFY = Std.string(overBF.y);
					if (!loggedPos)
					{
						positionsArray.push([BFX,BFY,"Right"]);
						torielFollow();
						loggedPos = true;
					}
				}
				checkInteractables(0,0);

			}

			if (controls.UI_UP_P)
			{
				upHeld = true;
				overBF.animation.play(glow + 'up');
			}

			if (controls.UI_DOWN_P)
			{
				downHeld = true;
				overBF.animation.play(glow + 'down');
			}

			if (controls.UI_LEFT_P)
			{
				leftHeld = true;
				overBF.animation.play(glow + 'left');
			}

			if (controls.UI_RIGHT_P)
			{
				rightHeld = true;
				overBF.animation.play(glow + 'right');
			}
			if (controls.UI_UP_R)
			{
				upHeld = false;
				if (!checkHeld())
				{
				overBF.animation.play(glow + 'upE');
				overToriel.animation.play('upE');
				prevDirection = "None";
				}
			}

			if (controls.UI_DOWN_R)
			{
				downHeld = false;
				if (!checkHeld())
				{
				overBF.animation.play(glow + 'downE');
				overToriel.animation.play('downE');
				prevDirection = "None";
				}
			}

			if (controls.UI_LEFT_R)
			{
				leftHeld = false;
				if (!checkHeld())
				{
				overBF.animation.play(glow + 'leftE');
				overToriel.animation.play('leftE');
				prevDirection = "None";
				}
			}

			if (controls.UI_RIGHT_R)
			{
				rightHeld = false;
				if (!checkHeld())
				{
				overBF.animation.play(glow + 'rightE');
				overToriel.animation.play('rightE');
				prevDirection = "None";
				}
			}
			if (controls.ACCEPT)
			{
				if (isInteracting)
				{
					for (i in interactList)
					{
						if (i.alpha == interactingWith)
						{
							bfLocationX = overBF.x;
							bfLocationY = overBF.y;
							canInteract = false;
							for (i in json.assets)
							{
								if (i.alpha == interactingWith)
								{
									doDialogue(i);
								}
							}
						}
					}
				}

			}
		}

		super.update(elapsed);

	}

}
