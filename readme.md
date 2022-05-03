# Holy Cross

_A macro engine for... uh... something to do with [Tunic](https://www.microsoft.com/en-ms/p/tunic/9nlrt31z4rwm)_

I wrote this because I want to make _something_ simpler. If you don't know _what_, then you don't need this (yet?).

## Requirements

This is a set of Powershell scripts, for Windows, tested with the Gamepass version of the game.

I don't know if it works for other versions of the game, or what would need to be modified.

## Usage

Write the series of input in a `.txt` file, like in this example

```
down
up
left
right
```

Or you can use the recorder script to make this easier

```
> ./holy-cross-recorder.ps1 path.txt
Input path with arrow keys, press Q when done.
```

To "play" a path, have the game open, switch to the Powershell window and run
```
> ./holy-cross.ps1 path.txt
```

You will have 3 seconds to switch back to the game and "be ready". 
The script will play a _beep_ sound, then start sending inputs to the game based on the contents of `path.txt`.
Don't press anything while this happens.
You will hear another _beep_ when the script is done. 

## Do you have examples to share?

No, don't ask. Have fun 😊