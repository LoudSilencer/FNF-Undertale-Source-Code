package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
using StringTools;

class RPGState extends MusicBeatState
{

	//keywords for people who need help with RPGing to help them find this better! :) tutorial, rpg, hitbox, wall, door, boss, enemy,

	//Welcome to the RPG section of the Undertale FNF mod! If you're here, you probably want to incorperate an RPG mechanic in your own mod. Well, this should hopefully help you.
	//In order to add a world, add a variable to the switch(area) function. In there, you'll see coordinates for all the hitboxes, player spawns, ETC. 
	//There are three arrays that you should be aware of: collisionList, obbyList, and interactList. interactList is your dialogue interactions, boss interactions, ETC. obbyList is your custom hitboxes for objets, such as chairs.
	//collisionList is the default list for the Background. It will automatically place a border around your background.
	//Hope this helps somewhat! It's a bit confusing and really really messy. Alot of the stuff I just brute forced and it's hard to apply to other mods. Hopefully, some better coder comes around and cleans up this mess. Good luck, game dev!

	public static var triggerMusic:Bool;

	public static var progression:String = "Yep";
	public static var progress:Float = 0;


	public static var area:String;
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public var stunned:Bool	= false;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	var optionShit:Array<String> = ['story_mode', 'freeplay', #if ACHIEVEMENTS_ALLOWED 'awards', #end 'credits', #if !switch 'donate', #end 'options'];
	var collisionList:Array<FlxSprite> = [];
	var obbyList:Array<FlxSprite> = [];
	var textList:Array<FlxSprite> = [];
	var interactList:Array<FlxSprite> = [];
	var magenta:FlxSprite;
	var overBF:FlxSprite;
	var exit1:FlxSprite = new FlxSprite(-80);
	var exit2:FlxSprite = new FlxSprite(-80);
	var isInteracting:Bool = false;
	var leftHeld:Bool = false;
	var rightHeld:Bool = false;
	var upHeld:Bool = false;
	var downHeld:Bool = false;


	function findMiddle(len:Float,position:Float)
	{
		return (position - (len/4));
	}
	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80);
		if (triggerMusic)
		{
			FlxG.sound.playMusic(Paths.music('upbeatTown'));
			triggerMusic = false;
		}
		switch(area)
		{
		case("SaveM" | "SaveE" | "SaveOptions"):
				var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
				bg = new FlxSprite(-80).loadGraphic(Paths.image('saveRoom'));
				bg.setGraphicSize(Std.int(bg.width * 1.1));
				bg.x = 0;
				bg.y = 0;

				overBF = new FlxSprite(-80).loadGraphic(Paths.image('boyfriendrpg'));

				if (area == "SaveM")
				{
					overBF.x = bg.x + (bg.width/2);
					overBF.y = bg.width - 300;
					area = "Save";
				}
				if (area == "SaveOptions")
				{
					overBF.x = bg.x + (bg.width/2);
					overBF.y = bg.width - 300;
					area = "Save";
				}
				if (area == "SaveE")
				{
					overBF.x = bg.x + (bg.width/2) - 500;
					overBF.y = bg.width - 1300;
					area = "Save";
				}
				overBF.setGraphicSize(Std.int(overBF.width * 0.775));
				overBF.frames = Paths.getSparrowAtlas('boyfriendrpg');
				overBF.animation.addByPrefix('down', "boyfriend_down", 6);
				overBF.animation.addByPrefix('up', "boyfriend_up", 6);
				overBF.animation.addByPrefix('right', "boyfriend_right", 6);
				overBF.animation.addByPrefix('left', "boyfriend_left", 6);
				overBF.animation.addByPrefix('downE', "boyfriend_down0000", 6);
				overBF.animation.addByPrefix('upE', "boyfriend_up0000", 6);
				overBF.animation.addByPrefix('rightE', "boyfriend_right0000", 6);
				overBF.animation.addByPrefix('leftE', "boyfriend_left0000", 6);
				overBF.animation.play('upE');
			
				var shading:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('saveRoomShade'));
				shading.setGraphicSize(Std.int(shading.width * 1.105));

				shading.x = bg.x + 80;
				shading.y = bg.y - 440;

				add(bg);
				add(overBF);
				add(shading);

				var hitBox1:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				hitBox1.width = 300;
				hitBox1.height = 200;
				hitBox1.setGraphicSize(Std.int(hitBox1.width));
				hitBox1.x = bg.x + (bg.width/2) - 350;
				hitBox1.y = bg.width - 1050;
				hitBox1.visible = false;
				add(hitBox1);
				obbyList.push(hitBox1);

				var money:Alphabet = new Alphabet(0, 0, "OPTIONS AND DIFFICULTY", true, false,0.05,.6);
				money.x = (1110/2) - 150;
				money.y = 1110 - 575;
				money.visible = false;
				add(money);
				textList.push(money);
				
				var interact:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				interact.width = 400;
				interact.height = 400;
				interact.setGraphicSize(Std.int(interact.width));
				interact.x = bg.x + (bg.width/2) - 400;
				interact.y = bg.width - 1075;
				interact.visible = false;
				add(interact);
				interactList.push(interact);

				var hitBox2:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				hitBox2.width = 3300;
				hitBox2.height = 300;
				hitBox2.setGraphicSize(Std.int(hitBox1.height));
				hitBox2.x = bg.x + (bg.width/2) - 850;
				hitBox2.y = bg.width - 1900;
				hitBox2.visible = false;
				add(hitBox2);
				obbyList.push(hitBox2);


				exit1 = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				exit1.width = 400;
				exit1.height = 400;
				exit1.setGraphicSize(Std.int(exit1.width));
				exit1.x = hitBox2.x;
				exit1.y = hitBox2.y + 50;
				exit1.visible = false;
				add(exit1);
				obbyList.push(exit1);


			case("HomeM" | "HomeE"):
				var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
				bg = new FlxSprite(-80).loadGraphic(Paths.image('newHome'));
				bg.setGraphicSize(Std.int(bg.width * 1.3));
				bg.x = 0;
				bg.y = 0;

				overBF = new FlxSprite(-80).loadGraphic(Paths.image('boyfriendrpg'));
				if (area == "HomeM")
				{
				overBF.x = bg.x - 2075;
				overBF.y = bg.y + 500;
				area = "Home";		
				}
				else
				{
					overBF.x = bg.x + 3050;
					overBF.y = bg.y + 500;
					area = "Home";					
				}
				overBF.setGraphicSize(Std.int(overBF.width * 0.775));
				overBF.frames = Paths.getSparrowAtlas('boyfriendrpg');
				overBF.animation.addByPrefix('down', "boyfriend_down", 6);
				overBF.animation.addByPrefix('up', "boyfriend_up", 6);
				overBF.animation.addByPrefix('right', "boyfriend_right", 6);
				overBF.animation.addByPrefix('left', "boyfriend_left", 6);
				overBF.animation.addByPrefix('downE', "boyfriend_down0000", 6);
				overBF.animation.addByPrefix('upE', "boyfriend_up0000", 6);
				overBF.animation.addByPrefix('rightE', "boyfriend_right0000", 6);
				overBF.animation.addByPrefix('leftE', "boyfriend_left0000", 6);
				overBF.animation.play('downE');
			
				var shading:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('newHomeShade'));
				shading.setGraphicSize(Std.int(shading.width * 1.3));

				shading.x = -1550;
				shading.y = 5;

				add(bg);
				add(overBF);
				add(shading);


				var hitBox1:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				hitBox1.width = bg.width*2;
				hitBox1.height = 800;
				hitBox1.x = -3650;
				hitBox1.y = -650;
				hitBox1.visible = false;
				add(hitBox1);
				obbyList.push(hitBox1);

				exit1 = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				exit1.width = 1000;
				exit1.height = 800;
				exit1.x = 2800;
				exit1.y = 500;
				exit1.visible = false;
				add(exit1);
				obbyList.push(exit1);

				
				exit2 = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				exit2.width = 1000;
				exit2.height = 800;
				exit2.x = -2900;
				exit2.y = 500;
				exit2.visible = false;
				add(exit2);
				obbyList.push(exit2);


			case("JudgementM" | "JudgementE"):
				var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
				bg = new FlxSprite(-80).loadGraphic(Paths.image('JudgementHall'));
				bg.setGraphicSize(Std.int(bg.width * 1.3));
				bg.x = 0;
				bg.y = 0;

				overBF = new FlxSprite(-80).loadGraphic(Paths.image('boyfriendrpg'));
				if (area == "JudgementM")
				{
				overBF.x = bg.x - 2075;
				overBF.y = bg.y + 450;
				area = "Judgement";		
				}
				else
				{
					overBF.x = bg.x + 3050;
					overBF.y = bg.y + 450;
					area = "Judgement";					
				}
				overBF.setGraphicSize(Std.int(overBF.width * 0.775));
				overBF.frames = Paths.getSparrowAtlas('boyfriendrpg');
				overBF.animation.addByPrefix('down', "boyfriend_down", 6);
				overBF.animation.addByPrefix('up', "boyfriend_up", 6);
				overBF.animation.addByPrefix('right', "boyfriend_right", 6);
				overBF.animation.addByPrefix('left', "boyfriend_left", 6);
				overBF.animation.addByPrefix('downE', "boyfriend_down0000", 6);
				overBF.animation.addByPrefix('upE', "boyfriend_up0000", 6);
				overBF.animation.addByPrefix('rightE', "boyfriend_right0000", 6);
				overBF.animation.addByPrefix('leftE', "boyfriend_left0000", 6);
				overBF.animation.play('downE');
			
				var shading:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('JudgementLighting'));
				shading.setGraphicSize(Std.int(shading.width * 1.3));

				shading.x = -1550;
				shading.y = 5;

				var pillars:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('JudgementPillars'));
				pillars.setGraphicSize(Std.int(pillars.width * 1.3));
				pillars.scrollFactor.set(1.2, 1.2);
				pillars.x = -1550;
				pillars.y = 200;

				add(bg);
				add(overBF);
				add(shading);
				add(pillars);	


				var hitBox1:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				hitBox1.width = bg.width*1.5;
				hitBox1.height = 800;
				hitBox1.x = -3650;
				hitBox1.y = -650;
				hitBox1.visible = false;
				add(hitBox1);
				obbyList.push(hitBox1);

				exit1 = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				exit1.width = 1000;
				exit1.height = 800;
				exit1.x = 2900;
				exit1.y = -750;
				exit1.visible = false;
				add(exit1);
				obbyList.push(exit1);
				if (FlxG.save.data.progression > 1)
				{
				var interact = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				interact.width = 1000;
				interact.height = 800;
				interact.x = 1500;
				interact.y =  0;
				interact.visible = false;
				add(interact);
				interactList.push(interact);	
				}


				if (FlxG.save.data.progression > 1)
				{
				var money:Alphabet = new Alphabet(0, 0, "Sans", true, false,0.05,.6);
				money.x = 2000;
				money.y = 600;
				money.visible = false;
				add(money);
				
				textList.push(money);
	
				var money2:Alphabet = new Alphabet(0, 0, "DIFFICULTY VERY HARD", true, false,0.05,.6);
				money2.x = 2000;
				money2.y = 700;
				money2.visible = false;
				add(money2);
				textList.push(money2);
				}
				else
				{

				var money:Alphabet = new Alphabet(0, 0, "Locked", true, false,0.05,.6);
				money.x = 2000;
				money.y = 600;
				money.visible = true;
				add(money);
				textList.push(money);
				var money2:Alphabet = new Alphabet(0, 0, "DEFEAT FLOWEY", true, false,0.05,.6);
				money2.x = 2000;
				money2.y = 700;
				money2.visible = true;
				add(money2);
				textList.push(money2);
				}

				
				exit2 = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				exit2.width = 1000;
				exit2.height = 800;
				exit2.x = -2500;
				exit2.y = -625;
				exit2.visible = false;
				add(exit2);
				obbyList.push(exit2);


			case("ThroneM" | "ThroneE"):
				var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
				bg = new FlxSprite(-80).loadGraphic(Paths.image('throneRoom'));
				bg.setGraphicSize(Std.int(bg.width * 1.1));
				bg.x = 0;
				bg.y = 0;

				overBF = new FlxSprite(-80).loadGraphic(Paths.image('boyfriendrpg'));

				if (area == "ThroneM")
				{
					overBF.x = bg.x + (bg.width/2);
					overBF.y = bg.width - 300;
					area = "Throne";
				}
				if (area == "ThroneE")
				{
					overBF.x = bg.x + (bg.width/2) - 500;
					overBF.y = bg.width - 1300;
					area = "Throne";
				}
				overBF.setGraphicSize(Std.int(overBF.width * 0.775));
				overBF.frames = Paths.getSparrowAtlas('boyfriendrpg');
				overBF.animation.addByPrefix('down', "boyfriend_down", 6);
				overBF.animation.addByPrefix('up', "boyfriend_up", 6);
				overBF.animation.addByPrefix('right', "boyfriend_right", 6);
				overBF.animation.addByPrefix('left', "boyfriend_left", 6);
				overBF.animation.addByPrefix('downE', "boyfriend_down0000", 6);
				overBF.animation.addByPrefix('upE', "boyfriend_up0000", 6);
				overBF.animation.addByPrefix('rightE', "boyfriend_right0000", 6);
				overBF.animation.addByPrefix('leftE', "boyfriend_left0000", 6);
				overBF.animation.play('upE');
			
				var shading:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('throneShade'));
				shading.setGraphicSize(Std.int(shading.width * 1.105));

				shading.x = bg.x + 80;
				shading.y = bg.y - 440;

				add(bg);
				add(overBF);
				add(shading);


				var hitBox1:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				hitBox1.width = 300;
				hitBox1.height = 300;
				hitBox1.setGraphicSize(Std.int(hitBox1.width));
				hitBox1.x = bg.x + (bg.width/2) - 350;
				hitBox1.y = bg.width - 1450;
				hitBox1.visible = false;
				add(hitBox1);
				obbyList.push(hitBox1);

				var money:Alphabet = new Alphabet(0, 0, "ASGORE", true, false,0.05,.6);
				money.x = (1110/2);
				money.y = 1110 - 975;
				money.visible = false;
				//add(money);
				//textList.push(money);
				
				var interact:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				interact.width = 400;
				interact.height = 400;
				interact.setGraphicSize(Std.int(interact.width));
				interact.x = bg.x + (bg.width/2) - 400;
				interact.y = bg.width - 1425;
				interact.visible = false;
				//add(interact);
				//interactList.push(interact);


				var interact2:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				interact2.width = 2000;
				interact2.height = 400;
				interact2.setGraphicSize(Std.int(interact2.width));
				interact2.x = bg.x + (bg.width/2) - 400;
				interact2.y = bg.width - 1425;
				interact2.visible = false;
				//add(interact2);
				//interactList.push(interact2);

				var hitBox2:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				hitBox2.width = 3300;
				hitBox2.height = 300;
				hitBox2.setGraphicSize(Std.int(hitBox1.height));
				hitBox2.x = bg.x + (bg.width/2) - 850;
				hitBox2.y = bg.width - 1900;
				hitBox2.visible = false;
				add(hitBox2);
				obbyList.push(hitBox2);


				exit2 = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				exit2.width = 400;
				exit2.height = 400;
				exit2.setGraphicSize(Std.int(exit2.width));
				exit2.x = bg.x + (bg.width/2) - 400;
				exit2.y = bg.width - 300;
				exit2.visible = false;
				add(exit2);
				obbyList.push(exit2);
				

				exit1 = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				exit1.width = 400;
				exit1.height = 400;
				exit1.setGraphicSize(Std.int(exit1.width));
				exit1.x = hitBox2.x;
				exit1.y = hitBox2.y + 50;
				exit1.visible = false;
				add(exit1);
				obbyList.push(exit1);
		case("BarrierM"):
				var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
				bg = new FlxSprite(-80).loadGraphic(Paths.image('barrier'));
				bg.setGraphicSize(Std.int(bg.width * 1.1));
				bg.x = 0;
				bg.y = 0;

				overBF = new FlxSprite(-80).loadGraphic(Paths.image('boyfriendrpg'));

				if (area == "BarrierM")
				{
					overBF.x = bg.x + (bg.width/2) - 200;
					overBF.y = bg.width + 1400;
					area = "Barrier";
				}
				overBF.setGraphicSize(Std.int(overBF.width * 0.775));
				overBF.frames = Paths.getSparrowAtlas('boyfriendrpg');
				overBF.animation.addByPrefix('down', "boyfriend_down", 6);
				overBF.animation.addByPrefix('up', "boyfriend_up", 6);
				overBF.animation.addByPrefix('right', "boyfriend_right", 6);
				overBF.animation.addByPrefix('left', "boyfriend_left", 6);
				overBF.animation.addByPrefix('downE', "boyfriend_down0000", 6);
				overBF.animation.addByPrefix('upE', "boyfriend_up0000", 6);
				overBF.animation.addByPrefix('rightE', "boyfriend_right0000", 6);
				overBF.animation.addByPrefix('leftE', "boyfriend_left0000", 6);
				overBF.animation.play('upE');
			
				var shading:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('barrierShade'));
				shading.setGraphicSize(Std.int(shading.width * 1.25));

				shading.x = bg.x - 100;
				shading.y = bg.y - 1540;

				add(bg);
				add(overBF);
				add(shading);

				var hitBox1:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				hitBox1.width = 350;
				hitBox1.height = 250;
				hitBox1.setGraphicSize(Std.int(hitBox1.width));
				hitBox1.x = bg.x + (bg.width/2) - 450;
				hitBox1.y = bg.width - 1450 + 1500;
				hitBox1.visible = false;
				add(hitBox1);
				obbyList.push(hitBox1);
				if (FlxG.save.data.progression > 0)
				{
				var money:Alphabet = new Alphabet(0, 0, "OMEGA FLOWEY", true, false,0.05,.6);
				money.x = bg.x + (bg.width/2) - 175;
				money.y = 1110 - 975 + 1620;
				money.visible = false;
				add(money);
				textList.push(money);

				var money:Alphabet = new Alphabet(0, 0, "DIFFICULTY HARD", true, false,0.05,.6);
				money.x = bg.x + (bg.width/2) - 175;
				money.y = 1110 - 975 + 1720;
				money.visible = false;
				add(money);
				textList.push(money);
				
				var interact:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				interact.width = 500;
				interact.height = 400;
				interact.setGraphicSize(Std.int(interact.width));
				interact.x = bg.x + (bg.width/2) - 500;
				interact.y = bg.width - 1425 + 1450;
				interact.visible = false;
				add(interact);
				interactList.push(interact);
				}
				else
				{
				var money:Alphabet = new Alphabet(0, 0, "LOCKED", true, false,0.05,.6);
				money.x = bg.x + (bg.width/2) - 175;
				money.y = 1110 - 975 + 1620;
				money.visible = true;
				add(money);
				textList.push(money);

				var money:Alphabet = new Alphabet(0, 0, "DEFEAT ASRIEL", true, false,0.05,.6);
				money.x = bg.x + (bg.width/2) - 175;
				money.y = 1110 - 975 + 1720;
				money.visible = true;
				add(money);
				textList.push(money);
				
				}


				var money2:Alphabet = new Alphabet(0, 0, "ASRIEL DREEMURR", true, false,0.05,.9);
				money2.x = bg.x + (bg.width/2) - 175;
				money2.y = 1110 - 975 + 1620 - 1500;
				money2.visible = false;
				add(money2);
				textList.push(money2);
				
				var money3:Alphabet = new Alphabet(0, 0, "DIFFICULTY MEDIUM", true, false,0.05,.9);
				money3.x = bg.x + (bg.width/2) - 175;
				money3.y = 1110 - 975 + 1620 - 1400;
				money3.visible = false;
				add(money3);
				textList.push(money3);

				var interact2:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				interact2.width = 2500;
				interact2.height = 400;
				interact2.setGraphicSize(Std.int(interact2.width));
				interact2.x = bg.x + (bg.width/2) - 500;
				interact2.y = bg.width - 1425 + 1450 - 1500;
				interact2.visible = false;
				add(interact2);
				interactList.push(interact2);

				var hitBox2:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				hitBox2.width = 3300;
				hitBox2.height = 300;
				hitBox2.setGraphicSize(Std.int(300));
				hitBox2.x = bg.x + (bg.width/2) - 825;
				hitBox2.y = bg.width - 3900;
				hitBox2.visible = false;
				add(hitBox2);
				obbyList.push(hitBox2);

				exit2 = new FlxSprite(-80).loadGraphic(Paths.image('hitbox'));
				exit2.width = 400;
				exit2.height = 400;
				exit2.setGraphicSize(Std.int(exit2.width));
				exit2.x = bg.x + (bg.width/2) - 500;
				exit2.y = bg.width + 1450;
				exit2.visible = false;
				add(exit2);
				obbyList.push(exit2);
		}
		
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		collisionList.push(bg);
		var scoreText:FlxText = new FlxText(10, 10, 0, progression, 36);
		scoreText.setFormat("VCR OSD Mono", 32);



		camGame.minScrollX = bg.x;
		camGame.minScrollY = bg.y;
		camGame.maxScrollX = bg.x + bg.width;
		camGame.maxScrollY = bg.y + bg.height;


		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		//magenta.scrollFactor.set(.99, .99);
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
	function nextArea(name:FlxSprite)
	{
		if (area == "Judgement" && name == exit1)
		{
			RPGState.area = "ThroneM";
			MusicBeatState.switchState(new RPGState());
		}
		if (area == "Judgement" && name == exit2)
		{
			RPGState.area = "HomeE";
			MusicBeatState.switchState(new RPGState());
		}
		if (area == "Home" && name == exit1)
		{
			RPGState.area = "JudgementM";
			MusicBeatState.switchState(new RPGState());
		}
		if (area == "Home" && name == exit2)
		{
			RPGState.area = "SaveE";
			MusicBeatState.switchState(new RPGState());
		}
		if (area == "Save" && name == exit1)
		{
			RPGState.area = "HomeM";
			MusicBeatState.switchState(new RPGState());
		}
		else if (area == "Throne" && name == exit2)
		{
			RPGState.area = "JudgementE";
			MusicBeatState.switchState(new RPGState());
		}
		else if (area == "Throne" && name == exit1)
		{
			RPGState.area = "BarrierM";
			MusicBeatState.switchState(new RPGState());
		}
		else if (area == "Barrier" && name == exit2)
		{
			RPGState.area = "ThroneE";
			MusicBeatState.switchState(new RPGState());
		}
		
	}
	function addInteractText()
	{
		for (i in 0...textList.length)
			textList[i].visible = true;
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
					trace("Ended interaction.");
				}
				else
					addInteractText();
				isInteracting = false;
			}
			else
			{
				addInteractText();
				trace("Started interaction.");
				isInteracting = true;
			}

		}
	}
	function checkCollision(xCoord:Float,yCoord:Float)
	{
		var minX:Float;
		var minY:Float;
		var maxX:Float;
		var maxY:Float;
		for (i in 0...obbyList.length) 
		{
			minX = obbyList[i].x + 150;
			minY = obbyList[i].y + 50;
			maxX = obbyList[i].x  + obbyList[i].width +150;
			maxY = obbyList[i].y + obbyList[i].height +150;

			if (overBF.y + yCoord < minY || overBF.y + yCoord > maxY || overBF.x + xCoord < minX || overBF.x + xCoord > maxX)
			{
				//nothing
			}
			else
			{
				if (obbyList[i] == exit1 || obbyList[i] == exit2)
				{
					nextArea(obbyList[i]);
				}
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
			overBF.animation.play('down');
			return true;
		}
		else if (upHeld)
		{
			overBF.animation.play('up');
			return true;
		}
		else if (rightHeld)
		{
			overBF.animation.play('right');
			return true;
		}
		else if (leftHeld)
		{
			overBF.animation.play('left');
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

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		FlxG.camera.follow(overBF,FlxCameraFollowStyle.LOCKON);
		if (!selectedSomethin)
		{
			if (controls.UI_UP)
			{
				if (checkCollision(0,-10))
				{
					overBF.y -= 10 * (60/ClientPrefs.framerate);
				}
				checkInteractables(0,0);
			}

			if (controls.UI_DOWN)
			{
				if (checkCollision(0,10))
				{
					overBF.y += 10 * (60/ClientPrefs.framerate);
				}
				checkInteractables(0,0);
			}

			if (controls.UI_LEFT)
			{
				if (checkCollision(-10,0))
				{
					overBF.x -= 10 * (60/ClientPrefs.framerate);
				}
				checkInteractables(0,0);
			}

			if (controls.UI_RIGHT)
			{
				if (checkCollision(10,0))
				{
					overBF.x += 10 * (60/ClientPrefs.framerate);
				}
				checkInteractables(0,0);

			}

			if (controls.UI_UP_P)
			{
				upHeld = true;
				overBF.animation.play('up');
			}

			if (controls.UI_DOWN_P)
			{
				downHeld = true;
				overBF.animation.play('down');
			}

			if (controls.UI_LEFT_P)
			{
				leftHeld = true;
				overBF.animation.play('left');
			}

			if (controls.UI_RIGHT_P)
			{
				rightHeld = true;
				overBF.animation.play('right');
			}
			if (controls.UI_UP_R)
			{
				upHeld = false;
				if (!checkHeld())
				{
				overBF.animation.play('upE');
				}
			}

			if (controls.UI_DOWN_R)
			{
				downHeld = false;
				if (!checkHeld())
				{
				overBF.animation.play('downE');
				}
			}

			if (controls.UI_LEFT_R)
			{
				leftHeld = false;
				if (!checkHeld())
				{
				overBF.animation.play('leftE');
				}
			}

			if (controls.UI_RIGHT_R)
			{
				rightHeld = false;
				if (!checkHeld())
				{
				overBF.animation.play('rightE');
				}
			}
			if (controls.ACCEPT)
			{
				if(area == "Save" && isInteracting)
				{
					MusicBeatState.switchState(new OptionsState());
				}
				if(area == "Judgement" && isInteracting)
				{
					PlayState.isStoryMode = true;
					PlayState.SONG = Song.loadFromJson("megalovania", "megalovania");
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = 2;
					LoadingState.loadAndSwitchState(new PlayState(), true);
				}
				else if(area == "Barrier" && isInteracting)
				{
					if (overBF.y > 1000)
					{
					PlayState.isStoryMode = true;
					PlayState.SONG = Song.loadFromJson("your-worst-nightmare", "your-worst-nightmare");
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = 2;
					LoadingState.loadAndSwitchState(new PlayState(), true);
					}
					else
					{
						PlayState.isStoryMode = true;
						PlayState.SONG = Song.loadFromJson("hopes-and-dreams", "hopes-and-dreams");
						PlayState.isStoryMode = false;
						PlayState.storyDifficulty = 2;
						LoadingState.loadAndSwitchState(new PlayState(), true);
					}
				}
			}
		}

		super.update(elapsed);

	}

}
