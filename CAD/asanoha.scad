patternScale = 5.0875;
patternThickness = 0.6;
patternDepth = 2;
repeatX = 4;
repeatY = 2;

module drawLine(a=0,b=0,xStart=0,xEnd=0)
{ 
    lineLength = sqrt(pow(a*(xEnd-xStart),2)+pow(xEnd-xStart,2))+patternThickness;
    translate([xStart,a*xStart+b,0])
    rotate([0,0,atan(a)]) translate ([-patternThickness/2,-patternThickness/2,-patternDepth/2]) cube([lineLength,patternThickness,patternDepth]);  
}

module drawYLine(xOrig=0,yOrig=0,length=0)
{ 
    lineLength = length+patternThickness;
    translate([xOrig,yOrig,0])
    rotate([0,0,90]) translate ([-patternThickness/2,-patternThickness/2,-patternDepth/2]) cube([lineLength,patternThickness,patternDepth]);  
}


module asanoha(){

    interXT = patternScale/(1+tan(67.5));

    drawLine(0,0,0,patternScale);
    drawLine(-1,0,0,interXT);
    drawLine(tan(67.5),-patternScale,0,interXT);
    drawLine(tan(22.5),-patternScale*tan(22.5),interXT,patternScale);
    
    
    interXB = patternScale/(1+tan(22.5));
    
    drawLine(0,-patternScale,0,patternScale);
    drawLine(-1,0,interXB,patternScale);
    drawLine(tan(22.5),-patternScale,0,interXB);
    drawLine(tan(67.5),-patternScale*tan(67.5),interXB,patternScale);
    
    
    drawLine(1,-patternScale,0,patternScale);
    drawYLine(0,-patternScale,patternScale);
    drawYLine(patternScale,-patternScale,patternScale);
}

module movePattern(repeatXN=0,repeatYN=0){
    translate([patternScale*2*repeatXN,patternScale*2*repeatYN,0]) children();
}

module fullAsanoha(){
    asanoha();
    rotate([0,0,90]) translate([-patternScale,-patternScale,0]) asanoha();
    rotate([0,0,90]) asanoha();
    translate([patternScale,patternScale,0]) asanoha();
}

module drawAsanoha(){
    translate([0,patternScale,patternDepth/2])
// Actually start drawing things
for(repeatXN = [0 : repeatX-1]){
    for(repeatYN = [0 : repeatY-1]){
        movePattern(repeatXN,repeatYN) fullAsanoha();
    }
}

}
