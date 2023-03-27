# func_vehicle
A drop-in vehicle-physics mod for Quake

    Version     : 0.1
    Date        : March 27th, 2023
    Author      : Marko "Polo" Permanto
    Email       : marko.permanto@gmail.com
    Website     : https://github.com/TLWmarko/func_vehicle
    
    Credits     :
        - Electro for the sick hotrod model
        - Lunaran for Copper, maths.qc in particular which includes clever
          tricks which sparked the idea for this port in the first place
        - LadyHavoc for the math-heavy parts of the original implementation
          of the physics in Twig

## About
This Quake mod is primarily meant for other modders, to function as a drop-in "put vehicles in my mod" add-on, rather than a standalone mod. There is a small test map called "bumpytest" that you can run to just check out the currently included car. Drive forward and backward using the movement keys, turn by aiming around with your mouse, Halo-style. Enter and exit vehicles with "impulse 50".

It is currently quite obviously unfinished, but I decided to package things up and release it as is anyway, because it's been just sitting on my harddrive collecting dust for a year, and the risk of it simply getting lost to time was only increasing.

## Requirements
Requires an engine with increased entity limits, since each physics object eats entities for breakfast. You probably also require a heftier computer than the original requirements were for Quake.
### Engines tested:
- QuakeSpasm (target engine for this mod, works great)
- QuakeSpasm-Spiked (works great)
- DarkPlaces (works great)
- FTEQW (choppy chasecam, not a great experience, might be possible to tweak using some settings)
- Ironwail (slightly choppy chasecam but acceptable, might be possible to tweak using some settings)

## Mapping & Modding
### Modding:
If you want to go ahead and put this stuff into your mod, make sure to check out the tutorials folder included in this release, it has .pdf and .html versions of two example-implementations, using either stock progs106 or Copper by Lunaran as a base (neither of which are included). Hopefully those are enough to help you in figuring out how to put it in your own mod too!

### Mapping:
Currently the only new thing you can do is add a func_vehicle_hotrod to your map (it respects angles for spawning). I don't have a mapping tutorial yet, but the main thing to keep in mind is that the vehicle basically uses a bunch of tracelines to collide with the world, meaning it can drive through and get stuck on geometry that is too thin. So make sure to only use big chunky brushes in areas where the car is. Anything above 16 units should be ok, 32 to be safe!

## TODO
Missing features:

    - Ability to build your own vehicles using brushes
    - Ability to add own models for vehicles without coding
    - Ability to flip vehicles back upright when you fall over
    - Visual effects like tyre-smoke and such
    - Sounds
    - Finished skin for the hotrod
    - More examples for using the physics engine in other ways
    - Technical description for the curious
    
## HQA (Hypothetical Questions and Answers)
Q: Is this like Quake Rally?  
A: Not really, but you could use it to make something like that! See the about section.  

Q: Can I make it turn using the keyboard rather than mouse?  
A: For sure! But then you'd need to live with a choppy camera. The car  attempts to turn towards where you're aiming rather than turn the camera towards where you're going because I wanted to work within the limits of Quake. Continuously setting the player's view angles from QuakeC is very choppy because of aggressive float quantization for smoother online play, which also affects singleplayer mods due to how the engine is set up.  

Q: I found a bug.  
A: Not exactly a question, but I'll let it slide. Feel free to either poke me about it in the Quake Mapping discord (Polo#2792) or even better submit a fix and I'll look at implementing it!  

Q: Can you help me implement the vehicles into my mod?  
A: No promises but I can probably give it a look. Just make sure you have tried following the tutorials I've included for doing just that first.  

Q: This looks like Twig. I thought that was DarkPlaces only?  
A: Yes! This mod was originally released in January 2009 as a DarkPlaces only type deal, while the main feature of this "port" is that it now works in essentially all Quake engines. This is basically Twig but with vehicle support, and all the features which required DarkPlaces removed. When I saw maths.qc in Copper had neat tricks for some math functions which Twig was relying on engine-features for I just knew I had to try and make this mod happen.  

Q: But how does it even work?  
A: I intend to write a technical description sometime, but in short it's a particle physics engine. Those are generally what's used for softbody physics, but because Quake has no way to represent soft-bodies like cloth, water, jello or what have you, I've just made the constraints between the particles (almost) completely rigid. This results in something that feels a bit like a rickety rigidbody. Try typing "developer 2" into the console and restart the level to see the particles on the vehicle, these are the things which actually collide with the world. It also has a bunch of bmodels for pushing monsters around.  

Q: Can I help you finish this mod?  
A: I'd be delighted! Let me know in the Quake Mapping discord (Polo#2792) and let's make it happen.  

Q: Hey isn't func_* a brush based entity, this looks like it should be called info_vehicle >:|  
A: Yes, but it's funnier this way. Also, it's supposed to have brush based vehicles eventually!
