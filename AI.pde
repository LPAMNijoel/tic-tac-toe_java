AI globalAI;
int timeLimit;
long moveEnd = 0l;
int globalMinDepth = 3;

//int[] moveSpace = {12,6,18,7,17,8,16,11,13,1,23,3,21,5,19,9,15,0,24,2,22,4,20,10,14};

class MoveCandidate{
  
  Board currentState; //Cloned from parent (or global board if no parent)
  int thisMove = -1;
  Board bestState = null;
  int bestDepth = -1;
  int bestMove = -1;
  Board parentBest = null;
  int startingMoves = 25;
  int movesToCheck = 25;
  int maxDepth = 25;
  int preferOld = 1; //Used for random selection...
  
  
  MoveCandidate currentMove;
  MoveCandidate bestMC = null;
  
  MoveCandidate(MoveCandidate parent, int toMove){
    if(parent != null){
      thisMove = toMove;
      parentBest = parent.getBest();
      currentState = new Board(parent.getState());
      currentState.move(thisMove);
      maxDepth = parent.getMaxDepth()-1;
    }else{
      currentState = new Board(globalBoard);
      maxDepth = toMove; //Genesis move inherits max depth.
    }
    
  }
  
  int getMaxDepth(){
    return maxDepth;
  }
  
  Board getBest(){
    return bestState;
  }
  int getBestDepth(){
    return bestDepth + 1;
  }
  int getBestMove(){
    return bestMove;
  }
  Board getState(){
    return currentState;
  }
  MoveCandidate getBestMC(){
    return bestMC;
  }
  
  void evaluateTree(){
    if(bestState != null) //Short-circuit multiple evals.
      return;
    
    if(currentState.getWinner() != -1 || maxDepth < 1 || (moveEnd - millis()) < 0l){ //Do not evaluate if a move cannot be made. Abort if move time is up.
      startingMoves = 0;
      movesToCheck = 0;
      bestState = currentState;
      bestDepth = 0;
      return;
    }
    
    for(int i=0;i<25;i++){
      if(currentState.getCell(i) != 0){
        startingMoves--;
      }
    }
    movesToCheck = startingMoves;
    int[] qMoveSpace = currentState.heatList();
    for(int q=0;q<25;q++){
      int i = qMoveSpace[q];
      if(currentState.getCell(i) == 0){
        currentMove = new MoveCandidate(this,i);
        currentMove.evaluateTree();
        Board result = currentMove.getBest();
        int cmDepth = currentMove.getBestDepth();
        int newRank = compareBoards(result,bestState);
        if(newRank > 0){ //update with new best candidate
          //println(maxDepth+": New best set: "+i);
          bestState = result;
          bestMove = i;
          bestMC = currentMove;
          bestDepth = cmDepth;
          preferOld = 1;
        }else if(newRank == 0 && result != null){ //End-state is equal to current, compare based on depth.
          if(cmDepth == bestDepth){
            preferOld++;
            if(bestDepth < 7 && int(random(preferOld)) == 0){ //Stick to the hot spots when the move tree is deep.
              bestState = result;
              bestMove = i;
              bestMC = currentMove;
              bestDepth = cmDepth;
            }
          }else if(result.getWinner() == currentState.getPlayer()){ //Favor quick wins, less time to make mistakes.
            if(cmDepth < bestDepth){
              //println(maxDepth+": New best set (TB).");
              bestState = result;
              bestMove = i;
              bestMC = currentMove;
              bestDepth = cmDepth;
              preferOld = 1;
            }
          }else{ //Favor slow losses, more time for the enemy to make mistakes.
            if(cmDepth > bestDepth){
              //println(maxDepth+": New best set (TB).");
              bestState = result;
              bestMove = i;
              bestMC = currentMove;
              bestDepth = cmDepth;
              preferOld = 1;
            }
          }
        }
        if(compareBoards(bestState,parentBest) > 0 && parentBest != null){ //Neural pruning in effect. Discard entire branch.
          //println(maxDepth+": Branch rejected.");
          bestMove = -1; //This branch is a dead end. Update to reflect it.
          movesToCheck = 0;
          return;
        }
        if(bestState.getWinner() == currentState.getPlayer() && bestDepth < 2){
          movesToCheck = 0;
          return; 
        }
        movesToCheck--;
      }
    }
    //println(maxDepth+": Found "+bestMove);
  }
  
  float getCompletion(){
    if(startingMoves < 1)
      return 1.0;
    float complete = (startingMoves - movesToCheck);
    if(currentMove != null)
      complete += currentMove.getCompletion();
    return complete / (float)startingMoves;
  }
  
  void thoughtPath(int[] out, int marker){
    if(out == null || marker >= out.length)
      return;
    if(thisMove > -1){
      out[marker] = thisMove;
      marker++;
    }
    if(movesToCheck > 0 && currentMove != null){
      currentMove.thoughtPath(out,marker);
    }
  }
  
  void bestPath(int[] out){
    int marker = 0;
    MoveCandidate next = this;
    while(marker < out.length && next != null){
      out[marker] = next.getBestMove();
      next = next.getBestMC();
      marker++;
    }
  }
  
  int compareBoards(Board a, Board b){
    if(a == null){
      if(b == null)
        return 0; //two nonexistent boards are tied.
      return -1; //Board that exists is better than one that doesn't.
    }else if(b == null){
      return 1;
    }
    //Compares based on current player's turn...
    int thisPlayer = currentState.getPlayer();
    if(thisPlayer != 1 && thisPlayer != 2){ //Current game state is invalid!
      println("INVALID GAME STATE IN AI ROUTINE.");
      return 0;
    }
    
    //A win is better than any other outcome.
    if(a.getWinner() == thisPlayer){
      if(b.getWinner() == thisPlayer){
        return 0; //Both win, therefore both are equal.
      }
      return 1; //A wins, B does not, therefore A is better.
    }else if(b.getWinner() == thisPlayer){
      return -1; //B wins, A does not, therefore B is better.
    }
    
    int opponent = 1;
    if(thisPlayer == 1)
      opponent = 2;
    
    //A loss is worse than any other outcome.
    if(a.getWinner() == opponent){
      if(b.getWinner() == opponent){
        return 0; //Both tie, therefore both are equal.
      }
      return -1; //A loses, B does not, therefore B is better.
    }else if(b.getWinner() == opponent){
      return 1; //B loses, A does not, therefore A is better.
    }
    
    //No win OR loss means both boards are tied or undecided.
    return 0;
  }
}

class AI implements Runnable{
  Thread AIThread;
  int minDepth = 3;
  int maxDepth = 10;
  int currentDepth;
  int workingMove;
  int workingWin;
  MoveCandidate moveRoot;
  TauntEngine te;
  
  AI(){
    te = new TauntEngine();
    setDepth(2*globalMinDepth);
  }
  
  void setDepth(int newDepth){
    while(moveRoot != null); //In case of arseholes, break glass.
    maxDepth = constrain(newDepth,globalMinDepth,25);
    minDepth = constrain(minDepth,globalMinDepth,maxDepth);
    //bestMoves = new int[maxDepth + 1];
  }
  
  int getMaxDepth(){
    return maxDepth;
  }
  
  int getMinDepth(){
    return minDepth;
  }
  
  int getWorkingDepth(){
    if(moveRoot != null)
      return currentDepth;
    return minDepth;
  }
  
  void reset(){
    minDepth = globalMinDepth;
    te.greet();
  }
  
  int[] getCurrentPath(){
    if(moveRoot == null){
      return new int[0];
    }
    int[] out = new int[25];
    for(int i=0;i<25;i++){
      out[i] = -1;
    }
    moveRoot.thoughtPath(out,0);
    int i;
    for(i=0;i<out.length;i++){
      if(out[i] == -1)
        break;
    }
    int[] newOut = new int[i];
    for(int j=0;j<i;j++){
      newOut[j] = out[j];
    }
    return newOut;
  }
  
  int[] getBestPath(){
    if(moveRoot == null){
      return new int[0];
    }
    int[] out = new int[26];
    for(int i=0;i<25;i++){
      out[i] = -1;
    }
    moveRoot.bestPath(out);
    int i;
    for(i=0;i<out.length;i++){
      if(out[i] == -1)
        break;
    }
    int[] newOut = new int[i];
    for(int j=0;j<i;j++){
      newOut[j] = out[j];
    }
    return newOut;
  }
  int getBestWinner(){
    if(moveRoot == null)
      return -1;
    Board bb = moveRoot.getBest();
    if(bb == null)
      return -1;
    return bb.getWinner();
  }
  
  float getCompletion(){
    if(moveRoot == null)
      return 0.0;
    return moveRoot.getCompletion();
  }
  
  void start(){
    if(AIThread != null){
      println("Thread duplication error.");
      return;
    }
    AIThread = new Thread(this);
    AIThread.start();
  }
  
  int getWorkingMove(){
    return workingMove;
  }
  int getWorkingWin(){
    return workingWin;
  }
  
  void run(){
    int predictedWin = -1;
    long lmc = millis();
    int lml = 0;
    int sml = 25;
    for(int i=0;i<25;i++){
      if(globalBoard.getCell(i) != 0)
        sml--;
    }
    println("Moves remaining: "+sml);
    currentDepth = minDepth;
    //int toMove = -1;
    moveEnd = millis() + timeLimit;
    workingMove = globalBoard.heatList()[0];
    workingWin = -1;
    do{
      moveRoot = new MoveCandidate(null,currentDepth);
      //treeCut = 1;
      moveRoot.evaluateTree();
      currentDepth++;
      if(millis() < moveEnd - 500l){
        if(calibrationMode) //reset timer at each candidate.
          moveEnd = millis() + timeLimit;
        lml = int(millis() - lmc);
        float ms = lml/1000.0;
        println("Move depth "+(currentDepth-1)+" in "+ms+" sec.");
        lmc = millis();
        workingMove = moveRoot.getBestMove();
        workingWin = moveRoot.getBest().getWinner();
        if(workingWin > -1)
          predictedWin = workingWin;
      }
    }while(millis() < (moveEnd - max(0,lml-1000)) && currentDepth <= min(maxDepth,sml));
    //Move cannot take less than 0.5s...
    while(millis() < (moveEnd - timeLimit + 500l));
    if(!calibrationMode)  //Do not tick minimum depth up when calibrating
      minDepth = max(minDepth,currentDepth-2);
    
    if(debugMode && !calibrationMode){
      globalTicker.pushMessage("AI: " + char((workingMove%5)+'A') + (workingMove/5+1),globalBoard.getPlayer()*-1);
    }
    globalBoard.move(workingMove);
    
    if(globalBoard.getWinner() != -1){
      te.update(globalBoard.getWinner(),true);
    }else{
      te.update(predictedWin,false);
    }
    currentDepth = 0;
    moveRoot = null;
    AIThread = null;
    endTurn();
  }
}