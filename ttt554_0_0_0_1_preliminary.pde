long gameEndTimer = -1l;
long gameStartTimer = -1l;
int secsLeft;
boolean gameStarted = false;
boolean debugMode = false;
boolean calibrationMode = false;

void setup(){
  size(800,600);
  smooth();
  timeLimit = 20000;
  globalBoard = new Board();
  globalAI = new AI();
  globalRegistrar = new Registrar("players.txt");
  
  
  p1 = new Player();
  p1.setStone(4);
  p2 = new Player();
  p2.setStone(9);
  
  loadSymbols();
  
  StoneUI oneStone = new StoneUI(25,25,140,70);
  oneStone.setPlayer(1);
  addToGroup(oneStone,"pregame");
  
  PlayerRegUI oneText = new PlayerRegUI(200,25,350,70);
  oneText.setPlayer(1);
  addToGroup(oneText,"pregame");
  
  AIbutton oneAI = new AIbutton(550,25,225,70);
  oneAI.setPlayer(1);
  addToGroup(oneAI,"pregame");
  
  StoneUI twoStone = new StoneUI(25,125,140,70);
  twoStone.setPlayer(2);
  addToGroup(twoStone,"pregame");
  
  PlayerRegUI twoText = new PlayerRegUI(200,125,350,70);
  twoText.setPlayer(2);
  addToGroup(twoText,"pregame");
  
  AIbutton twoAI = new AIbutton(550,125,225,70);
  twoAI.setPlayer(2);
  addToGroup(twoAI,"pregame");

  SwapButton swapper = new SwapButton(25,225,375,50);
  addToGroup(swapper,"pregame");
  StartButton starter = new StartButton(400,225,375,50);
  addToGroup(starter,"pregame");
  
  
  
  globalRegUI = new PlayerListUI(25,300,750,175);
  globalRegUI.clearSelection();
  addToGroup(globalRegUI,"pregame");
  
  globalTicker = new TickerUI(25,500,750,75);
  globalTicker.show(); //Exists on all screens.
  
  showGroup("pregame");

  BoardUI boardView = new BoardUI(350,50,400,400);
  addToGroup(boardView,"game");
  
  ThinkUI thinker = new ThinkUI(50,200,250,250);
  addToGroup(thinker,"game");

  PlayerPane pp = new PlayerPane(50,50,250,70);
  addToGroup(pp,"game");



  DebugUI bugger = new DebugUI(350,50,400,400);
  addToGroup(bugger,"debug");
  
  CalibrateUI calib = new CalibrateUI(780,25,15,550);
  addToGroup(calib,"pgdebug");
  addToGroup(calib,"debug");
  //showGroup("debug");
  //globalTicker.pushMessage("Hello!");
}

void draw(){
  if(gameEndTimer > 0l && millis() > gameEndTimer){ //Timer interrupt for game end.
    endTurn();
  }
  if(gameStartTimer > 0l){ //Timer interrupt for game end.
    if(millis() > gameStartTimer){
      gameStartTimer = -1l;
      gameStarted = true;
      globalTicker.fancyPurge();
      globalAI.reset();
      showGroup("game");
      if(debugMode){
        showGroup("debug");
      }
      endTurn();
    }else{
      int newSecs = int(gameStartTimer - millis())/1000;
      if(newSecs != secsLeft){
        secsLeft = newSecs;
        globalTicker.pushMessage("Game start in "+(secsLeft+1)+"...");
      }
    }
  }
  if(!gameStarted && p1 == p2){
    globalTicker.pushMessage("Error: You cannot play against yourself.");
    p2 = new Player();
  }
  
  background(0);
  for(int i=0;i<globalUI.length;i++){
    if(globalUI[i] != null && globalUI[i].visible)
      globalUI[i].globalDraw();
  }
}

void mouseReleased(){
  boolean shouldBlankKey = true; //Clicking anything clears keyboard focus
  for(int i=0;i<globalUI.length;i++){
    if(globalUI[i] != null && globalUI[i].visible){ //Can be seen
      UImaster e = globalUI[i];
      if(e.canFocusMouse && mouseX >= e.x && mouseY >= e.y && mouseX <= e.x+e.w && mouseY <= e.y+e.h){
        e.handleClick(int(mouseX-e.x),int(mouseY-e.y));
        if(e == keyboardFocus)
          shouldBlankKey = false;
      }
    }
  }
  if(shouldBlankKey && keyboardFocus != null){
    keyboardFocus.handleKey(ESC); //Engine prevents this key from occurring naturally!
    keyboardFocus = null;
  }
}

void keyPressed(){
  if(key == '*'){
    debugMode = !debugMode;
    if(debugMode){
      if(gameStarted){
        showGroup("debug");
      }else{
        showGroup("pgdebug");
      }
    }else{
      if(gameStarted){
        hideGroup("debug");
      }else{
        hideGroup("pgdebug");
      }
    }
    
    /*
    if(debugMode && gameStarted){
      showGroup("debug");
    }else if(!debugMode && gameStarted){
      hideGroup("debug");
    }
    
    */
  }
  if(keyboardFocus != null)
    keyboardFocus.handleKey(key);
}

void endTurn(){
  if(gameEndTimer > 0l){
    gameEndTimer = -1l;
    hideGroup("game");
    hideGroup("debug");
    gameStarted = false;
    globalBoard = new Board();
    if(debugMode){
      showGroup("pgdebug");
    }
    showGroup("pregame");
    return;
  }
  if(globalBoard.getWinner() >= 0){
    gameEndTimer = millis() + 5000l;
    String p1n = p1.getPlayerName();
    if(p1n == null || p1n.length() < 1)
      p1n = "Player 1";
    String p2n = p2.getPlayerName();
    if(p2n == null || p2n.length() < 1)
      p2n = "Player 2";
    //globalTicker.fancyPurge();
    switch(globalBoard.getWinner()){
      case 0:
        p1.addTie();
        p2.addTie();
        globalTicker.pushMessage("Tie game!");
        break;
      case 1:
        p1.addWin();
        p2.addLoss();
        globalTicker.pushMessage("Victory for "+p1n+"!",-1);
        break;
      case 2:
        p1.addLoss();
        p2.addWin();
        globalTicker.pushMessage("Victory for "+p2n+"!",-2);
        break;
      default:
        println("MAJOR MAJOR UGLY ERROR");
    }
    return;
  }
  Player p = null;
  if(globalBoard.getPlayer() == 1){
    p = p1;
  }else if(globalBoard.getPlayer() == 2){
    p = p2;
  }
  if(p == null){
    println("How is it nobody's turn!?");
    return;
  }
  if(p.getType() > 1){
    globalAI.setDepth(p.getType());
    globalAI.start();
    return;
  }
}