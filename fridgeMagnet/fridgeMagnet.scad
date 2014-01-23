/*
  	Braille Fridge Magnet
	Spencer Barton

	based on http://www.thingiverse.com/thing:47411 by kitwallace

	Directions: Upload your alphebetic character [A-Z,a-z] to be converted to braille and placed on a tag

  	mods :

	@TODO:
	- Add numbers 
	- more padding on left

*/

use <Write.scad>

/*===================================================
  Global Vars
  =================================================== */

font_charKeys = ["a", "A", "b", "B", "c", "C", "d", "D", "e", "E", "f", "F", "g", "G", "h", "H", "i", "I", "j", "J", "k", "K", "l", "L", "m", "M", "n", "N", "o", "O", "p", "P", "q", "Q", "r", "R", "s", "S", "t", "T", "u", "U", "v", "V", "w", "W", "x", "X", "y", "Y", "z", "Z", ",", ";", ":", ".", "!", "(", ")", "?", "\"", "*", "'", "-"];

font_charValues = [[1], [1], [1, 2], [1, 2], [1, 4], [1, 4], [1, 4, 5], [1, 4, 5], [1, 5], [1, 5], [1, 2, 4], [1, 2, 4], [1, 2, 4, 5], [1, 2, 4, 5], [1, 2, 5], [1, 2, 5], [2, 4], [2, 4], [2, 4, 5], [2, 4, 5], [1, 3], [1, 3], [1, 2, 3], [1, 2, 3], [1, 3, 4], [1, 3, 4], [1, 3, 4, 5], [1, 3, 4, 5], [1, 3, 5], [1, 3, 5], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4, 5], [1, 2, 3, 4, 5], [1, 2, 3, 5], [1, 2, 3, 5], [2, 3, 4], [2, 3, 4], [2, 3, 4, 5], [2, 3, 4, 5], [1, 3, 6], [1, 3, 6], [1, 2, 3, 6], [1, 2, 3, 6], [2, 4, 5, 6], [2, 4, 5, 6], [1, 3, 4, 6], [1, 3, 4, 6], [1, 3, 4, 5, 6], [1, 3, 4, 5, 6], [1, 3, 5, 6], [1, 3, 5, 6], [2], [2, 3], [2, 5], [2, 5, 6], [2, 3, 5], [2, 3, 5, 6], [2, 3, 5, 6], [2, 3, 6], [2, 3, 6], [3, 5], [3], [3, 6]];


/*===================================================
  Functions
  =================================================== */

// dot is not a hemisphere 
function chord_radius(length,height) = ( length * length /(4 * height) + height)/2;

/*===================================================
  Modules
  =================================================== */

module drawDot(location) {	
    translate(location) 
	   translate ([0,0, -font_dotSphereOffset ]) sphere(font_dotSphereRadius);
}

module drawCharacter(charMap) {
     for(i = [0: len(charMap)-1]) 
          assign(dot = charMap[i] - 1)
	     drawDot(   [floor(dot / 3) * font_dotWidth,  -((dot %3) * font_dotWidth),   0],  font_dotRadius  );
}


module drawLine(line) {
	assign( numberPrior = false )
   // search through chars, ignore endline
	for(i = [0: len(line)-1]) 
		assign( alphaFound = false )	
   	translate([font_charWidth*i, 0, 0]) 	
		// match with one from alphabet
	   for(j = [0:len(font_charKeys)-1]) {
			if(font_charKeys[j] == line[i]) {
				assign( numberPrior = false, alphaFound = true )
		    	drawCharacter(font_charValues[j]);
			}
		}
		// not alpha, so try number
		if (alphaFound == false) {
			// draw number
			for(j = [0:len(num_charKeys)-1]) {
				if( num_charKeys[j] == line[i] ) {
					// if first number draw number char
					if( numberPrior == false ) {
						// include number char, add to word len
						assign( maxWordLen = maxWordLen + 1 )
						echo("NUM CHAR");
						echo(str(line[i]));
						echo(str(num_charKeys[j]));
						drawCharacter(num_sym);
					}
					assign( numberPrior = true )
					drawCharacter(num_charValues[j]);
				}
			}
		}
			
				
			                  	
}

module drawText(text) {
    assign(totalHeight = len(text) * font_lineHeight)
      translate([0, 0, 1])	
        for(i = [0: len(text)]) 
	    translate([-len(text[i])*font_charWidth/2, totalHeight/2-font_lineHeight*i, 0])
	        drawLine(text[i]);
}

module label(text, depth=2) {
	  assign( 
					width  = maxWordLen  * font_charWidth,
            	height = len(text)  * font_lineHeight,
					heightOffset = font_lineHeight/3.0,
					holeRadius = len(text)  * font_lineHeight / 4.0
	 )

     difference () {
        
			union() {
           	drawText(text); // updates maxWordLen
     			assign(

			  	)
				// main rectangle
	        	translate([-holeRadius, heightOffset, 0])
	            cube([width + 2*holeRadius,height, depth], true);
				//rounded ends
				translate([width/2, heightOffset, -depth/2])
					cylinder(r=height/2,h=depth);
				translate([-width/2-holeRadius*2, heightOffset, -depth/2])
					cylinder(r=height/2,h=depth);
	        } // end union
		// hole for tag
        translate([-width/2-holeRadius*2, heightOffset,-depth]) cylinder(r=holeRadius,h=depth*2);  
   	}

}

$fa = 0.01; $fs = 0.5; 

// global dimensions from http://www.brailleauthority.org/sizespacingofbraille/sizespacingofbraille.pdf

// these dimensions for letters
font_dotHeight = 0.7;
font_dotBase = 1.6;  
font_dotRadius = font_dotBase /2;
font_dotWidth= 2.54;
font_charWidth = 7.62;
font_lineHeight = 11; 


// inputs
text = ["1234567890ABCDEFGHIJ"]; 
//text = ["All human beings are born", "free and equal in dignity and", "rights. They are endowed with", "reason and conscience and", "should act towards one another", "in a spirit of brotherhood."]; 
tagDepth = 4.0;

// compute the sphere to make the raised dot
font_dotSphereRadius =  chord_radius(font_dotBase,font_dotHeight);
font_dotSphereOffset = -(tagDepth - 2.0)/2.0 + font_dotSphereRadius - font_dotHeight;

// assorted globals
maxWordLen = max_length(text);
alphaFound = false;
numberPrior = false;
i = 0;

label(text, tagDepth);
