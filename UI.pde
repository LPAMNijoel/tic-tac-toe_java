//Global variables and functions for UI handling
UImaster[] globalUI = {}; //List of all UI elements
UImaster keyboardFocus = null;
String[] groupNames = {}; //List of named element groups
int[][] groupElems = {}; //Element matrix
color[][] stoneColors = {{0xFF000000, 0xFF555555, 0xFFAAAAAA, 0xFF777777},
                         {0xFF000055, 0xFF0000AA, 0xFF5555FF, 0xFF5555FF},
                         {0xFF005500, 0xFF00AA00, 0xFF55FF55, 0xFF00FF00},
                         {0xFF005555, 0xFF00AAAA, 0xFF55FFFF, 0xFF00FFFF},
                         {0xFF550000, 0xFFAA0000, 0xFFFF5555, 0xFFFF0000},
                         {0xFF550055, 0xFFAA00AA, 0xFFFF55FF, 0xFFFF00FF},
                         {0xFF550000, 0xFFAA5500, 0xFFFFFF55, 0xFFFFFF00},
                         {0xFF555555, 0xFFAAAAAA, 0xFFFFFFFF, 0xFFFFFFFF}};
PImage[][] stoneSymbols;
TickerUI globalTicker;
PlayerListUI globalRegUI;


void loadSymbols(){ //hardcoded load...
  stoneSymbols = new PImage[6][3];
  for(int i=0;i<stoneSymbols.length;i++){
    stoneSymbols[i][0] = loadImage("sym0"+i+"_a.png");
    stoneSymbols[i][1] = loadImage("sym0"+i+"_b.png");
    stoneSymbols[i][2] = loadImage("sym0"+i+"_c.png");
  }
}

int getMaxStones(){
  return stoneSymbols.length * stoneColors.length;
}

void drawStone(int x,int y,int r,int st){ //stub for now. Will need to be fixed later.
  PImage toDraw = null;
  color toTint = 0xFFFFAAFF; //error color
  if(st < getMaxStones() && st > -1){
    for(int i=0;i<3;i++){
      toTint = stoneColors[st%stoneColors.length][i];
      toDraw = stoneSymbols[st/stoneColors.length][i];
      int pir = min(r,min(toDraw.width,toDraw.height));
      PImage drawBuf = createImage(pir,pir,ARGB);
      drawBuf.copy(toDraw,0,0,toDraw.width,toDraw.height,0,0,pir,pir);
      toDraw = drawBuf;
      tint(toTint);
      image(toDraw,x + (r-toDraw.width)/2,y + (r-toDraw.height)/2);
      noTint();
    }
  }else{
    fill(toTint);
    rect(x+r/4,y+r/4,r/2,r/2);
  }
}

void registerUIElement(UImaster toReg){
  UImaster[] newGlobal = new UImaster[globalUI.length+1];
  newGlobal[globalUI.length] = toReg;
  for(int i=0;i<globalUI.length;i++)
    newGlobal[i] = globalUI[i];
  globalUI = newGlobal;
}

void addToGroup(UImaster elem, String group){
  int elemID = -1; //Index number in master list.
  for(int i=0;i<globalUI.length;i++){
    if(globalUI[i] == elem){
      elemID = i;
      break;
    }
  }
  if(elemID < 0) //Unregistered element, do not group.
    return;
  
  int groupNum = groupNames.length;
  for(int i=0;i<groupNames.length;i++){ //Search for appropriate named group to add element to.
    if(group.equalsIgnoreCase(groupNames[i])){
      groupNum = i;
      break;
    }
  }
  
  if(groupNum == groupNames.length){ //If no group exists, create it.
    String[] newNames = new String[groupNames.length+1];
    int[][] newNums = new int[groupNames.length+1][];
    for(int i=0;i<groupNames.length;i++){
      newNames[i] = groupNames[i];
      newNums[i] = groupElems[i];
    }
    newNames[groupNum] = group;
    groupNames = newNames;
    groupElems = newNums;
  }
  
  int[] currentGroup = groupElems[groupNum];
  if(currentGroup != null){
    int[] newGroup = new int[currentGroup.length+1];
    for(int i=0;i<currentGroup.length;i++){
      if(currentGroup[i] == elemID) //Abort, element already in group.
        return;
      newGroup[i] = currentGroup[i];
    }
    newGroup[currentGroup.length] = elemID;
    groupElems[groupNum] = newGroup;
  }else{
    groupElems[groupNum] = new int[1];
    groupElems[groupNum][0] = elemID;
  }
  

}

void showGroup(String group){
  int[] toShow = groupList(group);
  for(int i=0;i<toShow.length;i++){
    globalUI[toShow[i]].show();
  }
}

void hideGroup(String group){
  int[] toHide = groupList(group);
  for(int i=0;i<toHide.length;i++){
    globalUI[toHide[i]].hide();
  }
}

int[] groupList(String group){
  int groupNum = -1;
  for(int i=0;i<groupNames.length;i++){ //Search for appropriate named group to add element to.
    if(group.equalsIgnoreCase(groupNames[i])){
      groupNum = i;
      break;
    }
  }
  if(groupNum == -1)
    return new int[0];
  return groupElems[groupNum];
}

class UImaster{ //Master UI class for subclassing
  int x;
  int y;
  int w;
  int h;
  boolean canFocusMouse = false;
  boolean visible = false;

  UImaster(){
    this(0,0,0,0);
  }
  
  UImaster(int nx, int ny, int nw, int nh){
    x = nx;
    y = ny;
    w = nw;
    h = nh;
    if(w > 0 && h > 0)
      registerUIElement(this);
  }
  void globalDraw(){ //DO NOT OVERRIDE
    if(visible)
      drawElement();
  }
  void drawElement(){
    //do nothing.
  }
  void handleKey(int whichKey){
    //don't care.
  }
  void handleClick(int rx, int ry){
    //also don't care.
  }
  void hide(){
    visible = false;
  }
  void show(){
    visible = true;
  }
}

//Add additional UI elements here.
class BoardUI extends UImaster{
  BoardUI(int vx, int vy, int vw, int vh){
    super(vx,vy,vw,vh);
    canFocusMouse = true;
  }
  void drawElement(){
    noFill();
    stroke(color(177));
    int hOff = w>h?(w-h)/2:0;
    int vOff = w<h?(h-w)/2:0;
    int grid = min(w,h)/5;
    for(int i=0;i<25;i++){
      int sx = grid*(i%5)+hOff+x;
      int sy = grid*(i/5)+vOff+y;
      noFill();
      stroke(color(152));
      switch(globalBoard.getWinner()){ //Tweak the hell out of this once player colors are implemented.
        case 0:
          stroke(color(17));
          break;
        case 1:
          if(p1 != null)
            stroke(p1.getStoneColor()[3]);
          break;
        case 2:
          if(p2 != null)
            stroke(p2.getStoneColor()[3]);
          break;
      }
      rect(sx,sy,grid,grid);
      int cellType = globalBoard.getCell(i);
      if(cellType != 0){ 
        if(cellType == 1 && p1 != null){
          drawStone(sx,sy,grid,p1.getStone());
        }else if(cellType == 2 && p2 != null){
          drawStone(sx,sy,grid,p2.getStone());
        }else{
          drawStone(sx,sy,grid,-1);
        }
      }
      
    }
  }
  
  void handleClick(int rx, int ry){
    int p = globalBoard.getPlayer();
    if(p != 1 && p != 2)
      return;
    if(p == 1 && p1.type > 1)
      return;
    if(p == 2 && p2.type > 1)
      return;
    int grid = min(w,h)/5;
    int hOff = w>h?(w-h)/2:0;
    int vOff = w<h?(h-w)/2:0;
    int row = (rx-hOff)/grid;
    int col = (ry-vOff)/grid;
    globalBoard.move(col*5+row);
    endTurn();
  }
}

class StoneUI extends UImaster{
  int whatPlayer = -1;
  int btnWide;
  StoneUI(int vx, int vy, int vw, int vh){
    super(vx,vy,vw,vh);
    canFocusMouse = true;
  }
  void setPlayer(int which){
    whatPlayer = which;
  }
  
  void handleClick(int rx, int ry){
   Player whichP = null;
   if(whatPlayer == 1)
     whichP = p1;
   if(whatPlayer == 2)
     whichP = p2;
   if(whichP == null) //Don't handle clicks for players that don't exist...
     return;
   if(rx < btnWide*2 && ry < btnWide){
     int xgs = (ry * 2 / btnWide);
     xgs = xgs * 4 + (rx * 2 / btnWide);
     int sColor = whichP.getStone() % stoneColors.length;
     int sType = (whichP.getStone()/stoneColors.length) % stoneSymbols.length;
     switch(xgs){
       case 4:
         sType += stoneSymbols.length - 1;
         break;
       case 7:
         sType += 1;
         break;
       case 0:
         sColor += stoneColors.length - 1;
         break;
       case 3:
         sColor += 1;
         break;
     }
     sColor %= stoneColors.length;
     sType %= stoneSymbols.length;
     whichP.setStone(sType*stoneColors.length+sColor);
     return;
   } 
   //Add textfield-handling here!
  }
  
  void drawElement(){
    Player whichP = null;
    if(whatPlayer == 1)
      whichP = p1;
    if(whatPlayer == 2)
      whichP = p2;
    if(whichP == null){
      fill(0xFFAA55AA);
      rect(x,y,w,h);
      return;
    }
    btnWide = min(h,w/2);
    int sColor = whichP.getStone() % stoneColors.length;
    int sType = (whichP.getStone()/stoneColors.length) % stoneSymbols.length;
    drawStone(x+btnWide/2,y,btnWide,whichP.getStone()); //Draw stone for player, as specified
    sColor = (sColor + stoneColors.length - 1) % stoneColors.length;
    drawStone(x,y,btnWide/2,sType*stoneColors.length+sColor); //-1 color
    sColor = (sColor + 2) % stoneColors.length;
    drawStone(x+btnWide*3/2,y,btnWide/2,sType*stoneColors.length+sColor); //+1 color
    sColor = whichP.getStone() % stoneColors.length;
    sType = (sType + stoneSymbols.length - 1) % stoneSymbols.length;
    drawStone(x,y+btnWide/2,btnWide/2,sType*stoneColors.length+sColor); //-1 sym
    sType = (sType + 2) % stoneSymbols.length;
    drawStone(x+btnWide*3/2,y+btnWide/2,btnWide/2,sType*stoneColors.length+sColor); //+1 sym
  }
  
    
    
  
  
}

class DebugUI extends UImaster{
  float bx;
  float by;
  color bc;
  
  DebugUI(int vx, int vy, int vw, int vh){
    super(vx,vy,vw,vh);
    canFocusMouse = false;
  }
  
  void drawElement(){
    if(globalAI == null || globalBoard == null)
      return;
    stroke(color(255 * globalAI.getCompletion()));
    noFill();
    rectMode(CORNER);
    rect(x,y,w,h);
    int[] thoughts = globalAI.getCurrentPath();
    int[] plans = globalAI.getBestPath();
    /*if(thoughts.length < 1)
      return;
    */
    
    color cBest = 0xFFAA55AA;
    color cWork = 0xFFAA55AA;
    switch(globalAI.getBestWinner()){
      case -1:
        cBest = playerMid(0.5);
        break;
      case 0:
        cBest = playerMid(0.0);
        break;
      case 1:
        cBest = playerShade(true,1.0);
        break;
      case 2:
        cBest = playerShade(false,1.0);
    }
    switch(globalAI.getWorkingWin()){
      case -1:
        cWork = playerMid(1.0);
        break;
      case 0:
        cWork = playerMid(0.0);
        break;
      case 1:
        cWork = playerShade(true,0.75);
        break;
      case 2:
        cWork = playerShade(false,0.75);
    }
    
    
    
    
    
    int gs = min(w,h);
    int xo = x + (w-gs)/2 + gs/10; //align to square centers
    int yo = y + (h-gs)/2 + gs/10;
    gs /= 5;
    
    
    int wm = globalAI.getWorkingMove();
    float wmx = (wm%5) * gs;
    float wmy = (wm/5) * gs;
    bx = lerp(bx,wmx,0.1);
    by = lerp(by,wmy,0.1);
    bc = lerpColor(bc,cWork,0.1);
    
    
    
    //Heatmap
    int[] hm = globalBoard.heatMap();
    int high = 1;
    for(int i=0;i<25;i++){
      high = max(high,hm[i]);
    }
    rectMode(CENTER);
    noStroke();
    for(int i=0;i<25;i++){
      if(hm[i] > 0){
        fill(playerMid(float(hm[i])/high));
        rect(xo+gs*(i%5),yo+gs*(i/5),gs-5,gs-5);
      }
    }
    rectMode(CORNER);
    ellipseMode(RADIUS);
    
    
    //Best move
    if(globalAI.getCompletion() > 0.0){
      fill(turnShade(0,1));
      stroke(bc);
      ellipse(xo+bx,yo+by,gs/3,gs/3);
    }
    
    //Cached path - lines
    stroke(cBest);
    noFill();
    for(int i=1;i<plans.length;i++){
      int ax = xo + gs * (plans[i-1]%5);
      int ay = yo + gs * (plans[i-1]/5);
      int bx = xo + gs * (plans[i]%5);
      int by = yo + gs * (plans[i]/5);
      line(ax,ay,bx,by);
    }
    
    //Cached path - circles
    for(int i=plans.length-1;i>=0;i--){
      color q = turnShade(i,plans.length);
      int ax = xo + gs * (plans[i]%5);
      int ay = yo + gs * (plans[i]/5);
      fill(q);
      ellipse(ax,ay,gs/4,gs/4);
    }
    
    //Current eval - lines
    for(int i=1;i<thoughts.length;i++){
      color r = playerMid(1.0 - float(i-1)/(thoughts.length-1));
      int ax = xo + gs * (thoughts[i-1]%5);
      int ay = yo + gs * (thoughts[i-1]/5);
      int bx = xo + gs * (thoughts[i]%5);
      int by = yo + gs * (thoughts[i]/5);
      stroke(r);
      line(ax,ay,bx,by);
    }
    //current eval - circles
    for(int i=thoughts.length-1;i>=0;i--){
      color q = turnShade(i,thoughts.length);
      color r = playerMid(1.0 - float(i)/(thoughts.length-1));
      int ax = xo + gs * (thoughts[i]%5);
      int ay = yo + gs * (thoughts[i]/5);
      fill(q);
      stroke(r);
      ellipse(ax,ay,gs/6,gs/6);
    }
    
    
    
    
    
    stroke(0xFFFF0000); //red!
    //line(x,y,x+(w/25)*(min(treeCut,25)-1),y);
    float timeFrac = constrain((moveEnd - millis()) / float(timeLimit),0.0,1.0);
    line(x,y,x+w*timeFrac,y);
    stroke(0xFFFFFF00); //yellow!
    float depthFrac = (globalAI.getWorkingDepth())/10.0;
    line(x,y+h,x+constrain(w*depthFrac,0,w),y+h);
    stroke(0xFF00FF00); //green!
    line(x,y+h,x+constrain(w*(depthFrac-1),0,w),y+h);
    stroke(0xFFFFFFFF); //white!
    line(x,y+h,x+constrain(w*(depthFrac-2),0,w),y+h);
  }
  
  color playerShade(boolean firstPlayer, float bright){
    color[] toLerp;
    if(globalBoard.getPlayer() < 1)
      return 0xFFAA55AA; //error!
    if(firstPlayer){
      toLerp = p1.getStoneColor();
    }else{
      toLerp = p2.getStoneColor();
    }
    if(bright < 0.5)
      return lerpColor(toLerp[0],toLerp[1],bright*2);
    bright -= 0.5;
    return lerpColor(toLerp[1],toLerp[2],bright*2);
  }
  color playerMid(float bright){
    return lerpColor(playerShade(true,bright),playerShade(false,bright),0.5);
  }
  color turnShade(int deep,int max){
    float grade = 0.0;
    if(max > 1)
     grade = float(deep) / (max-1);
    grade = constrain(grade,0.0,1.0);
    if(globalBoard.getPlayer() < 1)
      return 0xFFAA55AA; //error!
    if((deep%2 == 1) ^ (globalBoard.getPlayer() == 1)){
      return playerShade(true,1.0-grade);
    }else{
      return playerShade(false,1.0-grade);
    }
  }
  
}

class ThinkUI extends UImaster{
  color[] currentColor = {0xFFFFAAFF,0xFFFFAAFF,0xFFFFAAFF,0xFFFFAAFF};
  float alpha = 0.0;
  float alphaIncr = 0.05;
  float delta = 0.0;
  float deltaIncr = 0.05;
  float theta = 0.0;
  float thetaIncr = 0.2;
  float thetaMin = 0.1;
  PImage[] layers;
  int xo;
  int yo;
  
  ThinkUI(int vx, int vy, int vw, int vh){
    super(vx,vy,vw,vh);
    layers = new PImage[3];
    layers[0] = loadImage("think_a.png");
    layers[1] = loadImage("think_b.png");
    layers[2] = loadImage("think_c.png");
    layers[2].resize(min(layers[2].width,w),0);
    layers[2].resize(0,min(layers[2].height,h));
    layers[0].resize(layers[2].width,layers[2].height);
    layers[1].resize(layers[2].width,layers[2].height);
    xo = (w-layers[0].width)/2;
    yo = (h-layers[0].height)/2;
  }
  
  void grabColor(){
    if(globalBoard == null)
      return;
    int cp = globalBoard.getPlayer();
    if(cp == 1 && p1 != null){
      currentColor = p1.getStoneColor();
    }else if(cp == 2 && p1 != null){
      currentColor = p2.getStoneColor();
    }
  }
  
  void drawBrain(float[] alphas){
    for(int i=0;i<3;i++){
      float ca = constrain(alphas[i],0.0,0.99);
      color toTint = lerpColor(currentColor[i] & 0x00FFFFFF,currentColor[i],ca);
      tint(toTint);
      image(layers[i],x+xo,y+yo);
    }
    noTint();
  }
  
  void drawElement(){
    float[] alphas = {0.0,0.0,0.0};
    float gc = 0.0;
    if(globalAI != null){
      gc = globalAI.getCompletion();
    }
    float gt = (moveEnd - millis()) / float(timeLimit); //fraction of move time remaining
    gt = constrain(gt,0.0,1.0);
    if(gc > 0.0){
      grabColor();
      alpha = min(1.0,alpha + alphaIncr);
      if(alpha > 0.99){
        delta = constrain(1.0-gt,max(0.0,delta-deltaIncr),min(1.0,delta+deltaIncr)); //NOTE: Will error out if move time is less than 20 frames (667ms)
      }else{
        delta = 0.0;
      }
      if(delta > 0.0){
        theta += max(gc,thetaMin) * thetaIncr;
        while(theta > 6.283185307)
          theta -= 6.283185307;
        while(theta < 0)
          theta += 6.283185307;
      }else{
        theta = 0;
      }
    }else{ //fade brain out.
      if(abs(theta) > 0.01){
        theta = max(0.0,abs(theta)-thetaIncr);
      }else if(delta > 0.0){
        delta = max(0.0,delta-deltaIncr);
      }else if(alpha > 0.0){
        alpha = max(0.0,alpha-alphaIncr);
      }
    }
    
    float beta = delta + (0.5-cos(theta)/2.0) * (1.0 - delta);
    beta = constrain(beta,0.0,1.0);
    alphas[0] = alpha;
    alphas[1] = beta;
    alphas[2] = beta * beta;
    drawBrain(alphas);
  } 
}

class PlayerRegUI extends UImaster{
  String tempString;
  int activePlayer;
  
  PlayerRegUI(int vx, int vy, int vw, int vh){
    super(vx,vy,vw,vh);
    canFocusMouse = true;
    tempString = "";
  }
  
  void setPlayer(int p){
    activePlayer = p;
  }
  
  void handleClick(int vx, int vy){
    if(keyboardFocus != this){
      Player p = getActivePlayer();
      if(p != null && p.isHuman()){
        keyboardFocus = this;
        globalTicker.pushMessage("Enter name for Player "+activePlayer);
      }     
    }
  }
  
  void handleKey(int kh){
    if(kh == ESC){
      tempString = "";
    }else if(kh == ENTER || kh == RETURN){
      tempString = tempString.trim();
      runSearch();
      keyboardFocus = null;
    }else if(isGood(kh)){
      tempString = tempString + char(kh);
    }else if(kh == BACKSPACE){
      tempString = tempString.substring(0,max(0,tempString.length()-1));
    }
  }
  
  boolean isGood(int k){ //letters, numbers, and spaces only.
    if(k >= 'a' && k <= 'z')
      return true;
    if(k >= 'A' && k <= 'Z')
      return true;
    if(k >= '0' && k <= '9')
      return true;
    return (k == ' ');
  }
  
  void runSearch(){
    clearActivePlayer();
    Player p = getActivePlayer();
    p.setPlayerName(tempString);
    globalRegUI.dispSearch(tempString,activePlayer);
  }
  
  Player getActivePlayer(){
    if(activePlayer == 1)
      return p1;
    if(activePlayer == 2)
      return p2;
    return null;
  }
  
  void clearActivePlayer(){
    Player p = getActivePlayer();
    Player np = new Player();
    if(p != null){
      np.setStone(p.getStone());
    }
    if(activePlayer == 1)
      p1 = np;
    if(activePlayer == 2)
      p2 = np;
  }
  
  void drawElement(){
    textSize(h/2);
    int yo = h*2/3;
    int xo = max(0,int(w-textWidth("Name: ABSURD TEST DATA_"))/2);
    String toDisp = "";
    color c = color(157);
    Player ap = getActivePlayer();
    if(keyboardFocus == this){
      toDisp = tempString + "_";
    }else if(ap != null){
      toDisp = ap.getPlayerName();
      tempString = toDisp;
      if(toDisp.length() < 1)
        toDisp = "[Anonymous]";
      c = ap.getStoneColor()[3];
    }else{
      toDisp = "[ERROR]";
    }
    stroke(c);
    fill(c);
    textAlign(LEFT,BASELINE);
    text(toDisp,x+xo,y+yo);
    
  }
  
  
}

class TickerUI extends UImaster{
  String[] toDisplay;
  long[] departTimes;
  int[] colors;
  long delayTime = 10000l;
  int bufferNum;
  int maxLines;
  int fontSize = 15;
  float xo; //float, because reasons
  float yo;
  color sysColor = color(157);
  
  TickerUI(int vx, int vy, int vw, int vh){
    super(vx,vy,vw,vh);
    canFocusMouse = false;
    maxLines = vh/fontSize - 2;
    maxLines = max(maxLines,2);
    toDisplay = new String[maxLines*2];
    departTimes = new long[maxLines*2];
    colors = new int[maxLines*2];
    for(int i=0;i<maxLines*2;i++){
      toDisplay[i] = "";
      departTimes[i] = 0l;
      colors[i] = -3;
    }
  }
  
  void purgeMessage(){
    for(int i=0;i<toDisplay.length-1;i++){
      toDisplay[i] = toDisplay[i+1];
      departTimes[i] = departTimes[i+1];
      colors[i] = colors[i+1];
    }
    bufferNum = max(0,bufferNum - 1);
  }
  
  void fancyPurge(){
    for(int i=0;i<bufferNum;i++){
      departTimes[i] = millis() + 1000l;
    }
  }
  
  void messageTick(){
    while(departTimes[0] < millis() && bufferNum > 0)
      purgeMessage();
  }
  
  void pushMessage(String msg){
    pushMessage(msg,-3);
  }
  
  void pushMessage(String msg, int c){
    while(bufferNum >= toDisplay.length)
      purgeMessage();
    if(bufferNum >= maxLines){
      int marker = 0;
      while(marker < toDisplay.length && departTimes[marker] < millis() + 1000l)
        marker++;
      if(marker < maxLines){
        departTimes[marker] = millis() + 1000l;
      }
    }
    toDisplay[bufferNum] = msg;
    departTimes[bufferNum] = millis() + delayTime;
    if(bufferNum >= maxLines){
      departTimes[bufferNum] = departTimes[bufferNum-maxLines] + delayTime;
      
    }
    colors[bufferNum] = c;
    bufferNum++;
    if(bufferNum == 1)
      xo = int(w - textWidth(toDisplay[0]))/2;
    println(bufferNum+"/"+toDisplay.length+": "+toDisplay[bufferNum-1]);
  }
  
  void drawElement(){
    messageTick();
    if(bufferNum < 1)
      return;
    yo = (h - fontSize*maxLines)/(maxLines+1.0);
    float ll = 0;
    textSize(fontSize);
    textAlign(LEFT,TOP);
    for(int i=0;i<min(bufferNum,maxLines);i++){
      ll = max(ll,textWidth(toDisplay[i]));
    }
    float nxo = max(0.0,(w-ll)/2.0);
    float xos = constrain((xo-nxo)/20.0,0.0,max(2.0,w/300.0));
    xo = constrain(nxo,xo-xos,xo+xos);
    float yv = yo;
    for(int i=0;i<bufferNum;i++){
      color c;
      switch(colors[i]){
        case -1:
          c = (p1!=null)?p1.getStoneColor()[3]:sysColor;
          break;
        case -2:
          c = (p2!=null)?p2.getStoneColor()[3]:sysColor;
          break;
        case -3:
          c = sysColor;
          break;
        default:
          c = stoneColors[colors[i]][3];
      }
      int destroyTime = int(departTimes[i] - millis());
      float destroyFrac = constrain(destroyTime/1000.0,0.0,1.0);
      if(yv + fontSize > h)
        continue;
      float lowTop = yo + (yo + fontSize) * (maxLines-1);
      float lowBottom = h - fontSize;
      float inFrac = 1.0 - constrain((yv-lowTop)/(lowBottom-lowTop),0.0,1.0);
      
      
      c = lerpColor(c & 0x00FFFFFF, c, min(destroyFrac,inFrac));
      stroke(c);
      fill(c);
      text(toDisplay[i],x+int(xo),y+int(yv));
      yv += destroyFrac * (yo + fontSize);
    }
  } 
}

class UIbutton extends UImaster{
  int xo;
  int yo;
  String label;
  boolean isEnabled = false;
  UIbutton(int vx, int vy, int vw, int vh, String l){
    super(vx,vy,vw,vh);
    label = l;
    canFocusMouse = true;
  }
  
  void enable(){
    isEnabled = true;
  }
  
  void disable(){
    isEnabled = false;
  }
  
  void drawElement(){
    stroke(color(153));
    fill(color(51));
    rectMode(CORNER);
    rect(x,y,w,h);
    yo = h*2/3;
    textSize(h/2);
    xo = w/2;
    textAlign(CENTER,BASELINE);
    if(isEnabled){
      stroke(color(255));
      fill(color(255));
    }else{
      stroke(color(102));
      fill(color(102));
    }
    
    text(label,x+xo,y+yo);
  }
  
  
  
}

class SwapButton extends UIbutton{
  SwapButton(int vx, int vy, int vw, int vh){
    super(vx,vy,vw,vh,"Swap Players");
    enable();
  }
  
  void handleClick(int vx, int vy){
    Player t = p1;
    p1 = p2;
    p2 = t;
  }
}


class StartButton extends UIbutton{
  StartButton(int vx, int vy, int vw, int vh){
    super(vx,vy,vw,vh,"Begin!");
    enable();
  }
  
  void drawElement(){
    super.drawElement();
    if(debugMode){
      label = "Begin (debug)";
    }else{
      label = "Begin!";
    }
    enable();
    if(p1 == null || p2 == null){
      disable();
      return;
    }
    if(stoneConflict() && !debugMode) //Disallow identical stones outside of debug mode.
      disable();
    if(p1.getType() > 1 && p2.getType() > 1 && !debugMode) //Disallow 2xAI outside of debug mode.
      disable();
    if(debugMode && calibrationMode && p1.getType() > 1 && p2.getType() > 1 && millis() > gameStartTimer)
          handleClick(0,0);
  }
  
  void handleClick(int vx, int vy){
    if(!isEnabled)
      return;
    hideGroup("pregame");
    gameStartTimer = millis() + 3000l;
  }
}

class PlayerListUI extends UImaster{
  int activePlayer = -1;
  int activeMode = -99;
  int fs;
  String heading = "";
  Player[] opts;
  int numPlayers = 0;
  String searchTerm = "";
  boolean hasExact = false;
  
  //3/4 baseline for 4/3 font size.
  PlayerListUI(int vx, int vy, int vw, int vh){
    super(vx,vy,vw,vh);
    //fs = h / 16; //font is 3/4 of a line, 12 lines total.
    fs = h * 3 / 28; //font is 3/4 of a line, 7 lines total.
    opts = new Player[10];
    canFocusMouse = true;
    clearSelection();
  }
  
  void dispHiScores(){
    activePlayer = 0;
    activeMode = 0; //Displaying scores.
    heading = "High Scores: ";
    Player[] hiScores = globalRegistrar.getHighScores();
    for(int i=0;i<hiScores.length;i++)
      opts[i] = hiScores[i];
    numPlayers = hiScores.length;
  }
  
  void dispAI(int ap){
    activePlayer = ap;
    activeMode = 1; //Displaying AIs.
    heading = "Select an AI for Player "+ap+":";
    Player[] AIs = globalRegistrar.getAIs();
    for(int i=0;i<AIs.length;i++)
      opts[i] = AIs[i];
    numPlayers = AIs.length;
  }
  
  void dispContestants(){
    heading = "Current Players:";
    activeMode = -1;
    numPlayers = 2;
    opts[0] = p1;
    opts[1] = p2;
    
  }
  
  void clearSelection(){
    if(p1 != null && p1.getType() == 1){
      dispContestants();
    }else if(p2 != null && p2.getType() == 1){
      dispContestants();
    }else{
      dispHiScores();
    }
  }
  
  void dispSearch(String toSearch, int ap){
    //globalTicker.pushMessage("Searching database for \""+toSearch+"\"");
    searchTerm = toSearch;
    activePlayer = ap;
    activeMode = 2; //Displaying search.
    heading = "Select Player "+ap+":";
    Player[] res = globalRegistrar.searchFor(toSearch);
    println("Searching "+toSearch+" returned "+res.length+" results.");
    numPlayers = min(res.length,9);
    for(int i=0;i<numPlayers;i++){
      opts[i] = res[i];
    }
    hasExact = (numPlayers>0 && opts[0].getPlayerName().equalsIgnoreCase(toSearch)); //Flag exact match to disable registration.
  }
  
  String playerString(int plr){
    Player p = opts[plr];
    if(p.getType() > 1 || activeMode == -1){
      String s = p.getPlayerName();
      if(s == null || s.length() < 1)
        s = "[Anonymous]";
      return s + " - " + p.getSubheading();
    }else{
      if(activeMode == 0){
        String s = p.getPlayerName();
        int w = p.getWins();
        int l = p.getLosses();
        int t = p.getTies();
        s += " - " + w;
        s += (w==1)?" win,":" wins,";
        s += " " + l;
        s += (l==1)?" loss,":" losses,";
        s += " " + t;
        s += (t==1)?" tie":" ties";

        return s;
      }
      return p.getPlayerName();
    }
  }
  
  void drawElement(){
    if(activeMode < -1)
      return;
    //HACK! Handle hover...
    int td = -1;
    // td = int((mouseY - y)/(h/12));
    if(mouseX >= x && mouseX <= x+w){
      td = int((mouseY - y)*7/h);
      int ti = int((mouseX - x)*2/w);
      if(td <= 0){
        td = -1;
      }else{
        td = td*2 + ti - 1;
      }
    }
      
      
      
      
      
    String[] toDisp = new String[13];
    toDisp[0] = heading;
    for(int i=0;i<12;i++){
      if(i < numPlayers){
        toDisp[i+1] = playerString(i);
      }else{
        toDisp[i+1] = "";
      }
    }
    if(activeMode == 1){
      toDisp[12] = "Cancel";
    }else if(activeMode == 2){
      toDisp[12] = "Continue without registration";
      if(!hasExact && searchTerm.length() > 2){
        toDisp[11] = "Register \""+searchTerm+"\" as new player";
      }
    }
    
    int ls = h/7;
    int lo = ls * 3 / 4;
    int wl = 0;
    for(int i=1;i<13;i++){
      wl = int(max(wl,textWidth(toDisp[i])));
    }
    int xo = max(0,(w/2 - wl)/2);
    
    textSize(fs);
    textAlign(LEFT,BASELINE);
    for(int i=0;i<13;i++){
      if(i == 0 || i == td){
        stroke(color(255));
        fill(color(255));
      }else{
        stroke(color(157));
        fill(color(157));
      }
      int ny = 0;
      if(i > 0){
        ny = (i+1)/2;
      }
      int vxo = 0;
      if(i == 0){
        vxo = int(w - textWidth(toDisp[0]))/2;
      }else{
        vxo = xo + (i-1)%2*(w/2);
      }
      text(toDisp[i],x+vxo,y+ls*ny+lo);
    }
  }
  
  void handleClick(int rx, int ry){
    int row = ry*7/h;
    //println("Clicky row "+row);
    if(row >= 7 || row < 1) //Ignore rows that aren't valid.
      return;
    if(activeMode < 1) //Ignore modes that can't select.
      return;
    row = row * 2 - 1;
    if(rx > w/2)
      row++;
    if(row == 12){ //cancel selection or continue with unregistered.
      clearSelection();
      return;
    }
    if(row == 11 && !hasExact){
      if(activePlayer == 1)
        globalRegistrar.register(p1);
      if(activePlayer == 2)
        globalRegistrar.register(p2);
      clearSelection();
      return;
    }
    
    row--; //row now matches player list number.
    if(row >= numPlayers) //Don't select a player that doesn't exist.
      return;
    if(activePlayer == 1)
      p1 = opts[row];
    if(activePlayer == 2)
      p2 = opts[row];
    clearSelection();
  }
  
}

class PlayerPane extends UImaster{
  PlayerPane(int vx, int vy, int vw, int vh){
    super(vx,vy,vw,vh);
    canFocusMouse = false;
  }
  
  void drawElement(){
    if(globalBoard == null) //Can't show players for a game that isn't there.
      return;
    int currentPlayer = globalBoard.getPlayer();
    if(currentPlayer != 1 && currentPlayer != 2) //Can't show player if the game isn't going.
      return;
    Player p;
    if(currentPlayer == 1){
      p = p1;
    }else{
      p = p2;
    }
    if(p == null) //Can't show player that doesn't exist.
      return;
    //Assume horizontal. We're boned otherwise.
    drawStone(x,y,h,p.getStone());
    textSize(h/3);
    int xto = h * 10 / 9;
    int yto = h * 7 / 18;
    int yts = h * 4 / 9;
    textAlign(LEFT,BASELINE);
    fill(p.getStoneColor()[3]);
    stroke(p.getStoneColor()[3]);
    String pn = p.getPlayerName();
    if(pn == null || pn.length() < 1)
      pn = "[Anonymous]";
    text(pn,x+xto,y+yto);
    text(p.getSubheading(),x+xto,y+yto+yts);
  }
}

class AIbutton extends UIbutton{
  int activePlayer = -1;
  AIbutton(int vx, int vy, int vw, int vh){
    super(vx,vy,vw,vh,"...");
    isEnabled = true;
  }
  
  void setPlayer(int p){
    activePlayer = p;
  }
  
  void drawElement(){
    super.drawElement();
    Player p = null;
    if(activePlayer == 1)
      p = p1;
    if(activePlayer == 2)
      p = p2;
    if(p == null){
      label = "WAT?";
    }
    if(p.getType() < 2){
      label = "[Human] | AI";
    }else{
      label = "Human | [AI]";
    }   
  }
  
  void handleClick(int rx, int ry){
    Player p = null;
    if(activePlayer == 1)
      p = p1;
    if(activePlayer == 2)
      p = p2;
    if(p == null){
      return;
    }
    if(p.getType() < 2){
      globalRegUI.dispAI(activePlayer);
    }else{
      if(activePlayer == 1)
        p1 = new Player();
      if(activePlayer == 2)
        p2 = new Player();
    }   
  }
  
}

class TauntEngine{
  int lastWinner = -1;
  String[][] taunts;
  TauntEngine(){
    String[] fromFile = loadStrings("taunts.txt");
    if(fromFile == null)
      fromFile = new String[0];
    int numLines = 0;
    for(int i=0;i<fromFile.length;i++){
      if(fromFile[i].indexOf("#") != 0)
        numLines++;
    }
    taunts = new String[numLines][];
    numLines = 0;
    for(int i=0;i<fromFile.length;i++){
      if(fromFile[i].indexOf("#") != 0){
        taunts[numLines] = fromFile[i].split("\t");
        numLines++;
      }
    }
  }
  
  String findString(Player p, String t){
    if(p.getType() < 2)
      return null;
    String pn = p.getPlayerName();
    for(int i=0;i<taunts.length;i++){
      if(taunts[i][0].equals(pn) && taunts[i][1].equals(t))
        return taunts[i][2];
    }
    return null;
  }
  
  void greet(){
    String one = findString(p1,"HI");
    String two = findString(p2,"HI");
    if(one != null && one.length() > 0)
      globalTicker.pushMessage(one,-1);
    if(two != null && two.length() > 0)
      globalTicker.pushMessage(two,-2);
  }
  
  void update(int whoWins, boolean gameOver){
    if(whoWins < 0) //Nothing interesting.
      return;
    if(whoWins == lastWinner && !gameOver) //No change.
      return;
    String one = null;
    String two = null;
    if(gameOver){
      switch(whoWins){
        case 0:
          one = findString(p1,"T");
          two = findString(p2,"T");
          break;
        case 1:
          one = findString(p1,"W");
          two = findString(p2,"L");
          break;
        case 2:
          one = findString(p1,"L");
          two = findString(p2,"W");
      }
    }else{
      int winState = lastWinner * 4 + whoWins;
      switch(winState){
        //== P1T P2T
        case -4:
          //-4  XT  XT
          one = findString(p1,"XT");
          two = findString(p2,"XT");
          break;
        case -3:
          //-3  XW  XL
          one = findString(p1,"XW");
          two = findString(p2,"XL");
          break;
        case -2:
          //-2  XL  XW
          one = findString(p1,"XL");
          two = findString(p2,"XW");
          break;
        case 1:
          // 1 NXW NXL
          one = findString(p1,"NXW");
          if(one == null || one.length() < 1)
            one = findString(p1,"XW");
          two = findString(p2,"NXL");
          if(two == null || two.length() < 1)
            two = findString(p2,"XL");
          break;
        case 2:
          // 2 NXL NXW
          one = findString(p1,"NXL");
          if(one == null || one.length() < 1)
            one = findString(p1,"XL");
          two = findString(p2,"NXW");
          if(two == null || two.length() < 1)
            two = findString(p2,"XW");
          break;
        case 4:
          // 4 NXL  XT
          one = findString(p1,"NXL");
          if(one == null || one.length() < 1)
            one = findString(p1,"XL");
          two = findString(p2,"XT");
          break;
        case 6:
          // 6 NXL NXW
          one = findString(p1,"NXL");
          if(one == null || one.length() < 1)
            one = findString(p1,"XL");
          two = findString(p2,"NXW");
          if(two == null || two.length() < 1)
            two = findString(p2,"XW");
          break;
        case 8:
          // 8  XT NXL
          one = findString(p1,"XT");
          two = findString(p2,"NXW");
          if(two == null || two.length() < 1)
            two = findString(p2,"XW");
          break;
        case 9:
          // 9 NXW NXL
          one = findString(p1,"NXW");
          if(one == null || one.length() < 1)
            one = findString(p1,"XW");
          two = findString(p2,"NXL");
          if(two == null || two.length() < 1)
            two = findString(p2,"XL");
      }
    }
    lastWinner = whoWins;
    if(one != null && one.length() > 0)
      globalTicker.pushMessage(one,-1);
    if(two != null && two.length() > 0)
      globalTicker.pushMessage(two,-2);
  } 
}

class CalibrateUI extends UImaster{
  int gs;
  int msec;
  CalibrateUI(int vx, int vy, int vw, int vh){
    super(vx,vy,vw,vh);
    canFocusMouse = true;
    int zh = h - w - 5;
    msec = (zh/15) * 5;
    gs = zh/msec;
  }
  
  void drawElement(){
    int secs = timeLimit/1000;
    noStroke();
    rectMode(CORNER);
    for(int i=1;i<=msec;i++){
      if(i <= secs){
        if(i % 60 == 0){ //10sec selected
          fill(0xFFFF0000);
        }else if(i % 10 == 0){ //5sec selected
          fill(0xFFFFFF00);
        }else if(i % 5 == 0){ //selected
          fill(0xFF00FF00);
        }else{
          fill(0xFF555555);
        }
      }else{
        if(i % 60 == 0){ //10sec selected
          fill(0xFF550000);
        }else if(i % 10 == 0){ //5sec selected
          fill(0xFF555500);
        }else if(i % 5 == 0){ //selected
          fill(0xFF005500);
        }else{
          fill(0xFF111111);
        }
      }
      rect(x,y+h-i*gs,w,gs);
    }
    
    
    if(p1 == null || p2 == null){
      fill(0xFF0000FF);
    }else if(p1.getType() > 1 && p2.getType() > 1){
      if(calibrationMode){
        fill(0xFF550000);
      }else{
        fill(0xFFFF0000);
      }
    }else if(calibrationMode){
      fill(0xFFFFFF00);
    }else{
      fill(0xFF00FF00);
    }
    
    rect(x,y,w,w);
  }
  
  void handleClick(int rx, int ry){
    if(ry < w){
      calibrationMode = !calibrationMode;
      return;
    }
    int bc = (h - ry)/gs + 1;
    if(bc <= msec)
      timeLimit = 1000 * bc;
    
      
  }
  
  
  
}