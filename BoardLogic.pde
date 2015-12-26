Board globalBoard; //global for game in progress

class Board{
  int currentPlayer = 0; //0, 1, or 2. Zero is no move available.
  int currentWinner = 0; //-1, 0, 1, or 2. -1 is game-in-progress.
  int[] boardState;
  final int[][] testPattern = {{ 0, 1, 2, 3},{ 1, 2, 3, 4}, //top row
                               { 5, 6, 7, 8},{ 6, 7, 8, 9},
                               {10,11,12,13},{11,12,13,14},
                               {15,16,17,18},{16,17,18,19},
                               {20,21,22,23},{21,22,23,24}, //bottom row
                               { 0, 5,10,15},{ 5,10,15,20}, //left column
                               { 1, 6,11,16},{ 6,11,16,21},
                               { 2, 7,12,17},{ 7,12,17,22},
                               { 3, 8,13,18},{ 8,13,18,23},
                               { 4, 9,14,19},{ 9,14,19,24}, //right column
                               { 0, 6,12,18},{ 6,12,18,24}, //NW diagonal
                               { 1, 7,13,19},{ 5,11,17,23}, //NW offsets
                               { 4, 8,12,16},{ 8,12,16,20}, //NE diagonal
                               { 3, 7,11,15},{ 9,13,17,21}}; //NE offsets
  
  public Board(){
    boardState = new int[25]; //hardcoded
    clearBoard();
    currentWinner = -1;
    currentPlayer = 1;
  }
  public Board(Board toClone){
    if(toClone == null){
      toClone = new Board(); //clone a blank. Ugly, but functional.
      return;
    }
    currentPlayer = toClone.currentPlayer;
    currentWinner = toClone.currentWinner;
    boardState = new int[25];
    for(int i=0;i<boardState.length;i++)
      boardState[i] = toClone.boardState[i];
  }
  void clearBoard(){
    for(int i=0;i<boardState.length;i++)
      boardState[i] = 0;
  }
  
  void move(int position){
    if(currentPlayer == 0 || currentWinner != -1) //ignore orders to move when game is inactive.
      return;
    if(position < 0 || position >= boardState.length) //ignore orders to mark a cell that doesn't exist.
      return;
    if(boardState[position] != 0) //ignore orders to mark a cell that's already in use.
      return;
    boardState[position] = currentPlayer;
    checkWin();
    if(currentWinner == -1){
      if(currentPlayer == 1){
        currentPlayer = 2;
      }else{
        currentPlayer = 1;
      }
    }else{
      currentPlayer = 0;
    }
  }
  
  int getPlayer(){
    return currentPlayer;
  }
  int getWinner(){
    return currentWinner;
  }
  int getCell(int position){
    if(position < 0 || position >= boardState.length)
      return -1;
    return boardState[position];
  }
  
  void checkWin(){
    boolean hasHope = false;
    for(int i=0;i<testPattern.length;i++){
      int thisMove = winnerOf(testPattern[i]);
      if(thisMove > 0){ //The game is won!
        currentWinner = thisMove;
        return;
      }
      if(thisMove < 0)
        hasHope = true; //There is at least one relevant move left.
    }
    if(hasHope){
      currentWinner = -1; //Game is still undecided.
    }else{
      currentWinner = 0; //No moves left, tie game.
    }
  }
  
  int[] heatMap(){
    int[] out = new int[25];
    for(int k=0;k<25;k++){
      out[k] = 0;
    }
    for(int i=0;i<testPattern.length;i++){
      if(winnerOf(testPattern[i]) == -1){
        for(int j=0;j<testPattern[i].length;j++){
          if(boardState[testPattern[i][j]] == 0)
            out[testPattern[i][j]]++;
        }
      }
    }
    return out;
  }
  int[] heatList(){
    int[] start = heatMap();
    int[] out = new int[25];
    int bigOne = 9999;
    int notSoBig = -1;
    int marker = 0;
    while(marker < 25){
      for(int i=0;i<25;i++){
        if(start[i] == bigOne){
          out[marker] = i;
          start[i] = -1;
          marker++;
        }else if(start[i] > notSoBig){
          notSoBig = start[i];
        }
      }
      bigOne = notSoBig;
      notSoBig = -1;
    }
    return out;
  }
  

  int winnerOf(int[] testCells){ //Array of cells that make up a straight line
    boolean hasOne = false;
    boolean hasTwo = false;
    boolean hasBlank = false;
    for(int i=0;i<testCells.length;i++){
      switch(boardState[testCells[i]]){
        case 0:
          hasBlank = true;
          break;
        case 1:
          hasOne = true;
          break;
        case 2:
          hasTwo = true;
          break;
      }
    }
    if(hasOne && hasTwo) //Neither side can take this line.
      return 0;
    if(hasBlank) //At least one player could take this line.
      return -1;
    if(hasOne) //No blanks, no twos, must be player 1 win.
      return 1;
    return 2; //process of elimination, player 2 win.
  }
  
  
}