Player p1;
Player p2;
Registrar globalRegistrar;



boolean stoneConflict(){
  if(p1 == null || p2 == null)
    return false; //can't be a conflict if nothing is there.
  if(p1.getStone() != p2.getStone())
    return false; //different stones, no conflict;
  return true;
}





class Player{
  int type;  //0 = Anon, 1 = Registered, 2-25 = AI
  String name;
  int stone;
  int[] record; // tie/win/loss, in that order
  public Player(){
    type = 0;
    name = "";
    record = new int[3];
  }
  
  boolean isHuman(){
    return type < 2;
  }
  
  void addWin(){
    record[1]++;
  }
  void addLoss(){
    record[2]++;
  }
  void addTie(){
    record[0]++;
  }
  
  int getWins(){
    return record[1];
  }
  int getLosses(){
    return record[2];
  }
  int getTies(){
    return record[0];
  }
  
  void setRecord(int wins, int losses, int ties){
    record[0] = ties;
    record[1] = wins;
    record[2] = losses;
  }
  
  String getSubheading(){
    if(type < 0){
      return "UNIDENTIFIED PLAYER TYPE!";
    }else if(type < 2){
      String out = "";
      if(record[1] > 0){
        out += record[1];
        out += record[1]==1?" win":" wins";
      }
      if(record[2] > 0){
        if(record[1] > 0)
          out += ", ";
        out += record[2];
        out += record[2]==1?" loss":" losses";
      }
      if(record[0] > 0){
        if(record[1] > 0 || record[2] > 0)
          out += ", ";
        out += record[0];
        out += record[0]==1?" tie":" ties";
      }
      if(record[0] > 0 && record[1] > 0 && record[2] > 0){
        out = record[1]+"W/"+record[2]+"L/"+record[0]+"T";
      }
      if(record[0] < 1 && record[1] < 1 && record[2] < 1){
        out = "No Record";
      }
      return out;
    }else if(type < 4){
      return "AI - Easy";
    }else if(type < 7){
      return "AI - Medium";
    }else if(type < 9){
      return "AI - Difficult";
    }else if(type <= 25){
      return "AI - Expert";
    }else{
      return "UNIDENTIFIED AI TYPE!";
    }
  }
  
  void setPlayerName(String newName){ //setName() reserved by XML processor
    name = newName;
  }
  String getPlayerName(){ //getName() reserved by XML processor
    return name;
  }
  void setType(int newType){
    type = newType;
  }
  int getType(){
    return type;
  }
  void setStone(int stoneType){
    stone = stoneType;
  }
  int getStone(){
    return stone;
  }
  
  color[] getStoneColor(){
    return stoneColors[stone % stoneColors.length];
  }
  
  PImage[] getStoneSymbol(){
    return stoneSymbols[stone/stoneColors.length]; //WARNING: Will error out if invalid stone used
  }
}

class Registrar{
  Player[] records;
  String fileName;
  public Registrar(String infile){
    fileName = infile;
    loadFromFile();
  }
  
  void loadFromFile(){
    String[] recordsFromFile = loadStrings(fileName);
    if(recordsFromFile == null)
      recordsFromFile = new String[0];
    Player[] newRecords = new Player[recordsFromFile.length];
    
    for(int i=0;i<recordsFromFile.length;i++){
      String[] currentRecord = recordsFromFile[i].split("\t");
      Player currentPlayer = new Player();
      currentPlayer.setPlayerName(currentRecord[0]);
      currentPlayer.setType(parseInt(currentRecord[1]));
      currentPlayer.setStone(parseInt(currentRecord[2]));
      currentPlayer.setRecord(parseInt(currentRecord[3]),parseInt(currentRecord[4]),parseInt(currentRecord[5]));
      newRecords[i] = currentPlayer;
    }
    records = newRecords;
  }
  
  void saveToFile(){
    //HACK: Reload AIs from file in order to preserve original attributes.
    Player[] currentRecords = records;
    loadFromFile();
    Player[] AIs = getAIs();
    records = currentRecords;
    String[] out = new String[records.length];
    for(int i=0;i<out.length;i++){
      Player toSave = records[i];
      if(toSave.getType() > 1){ //Search AI list from file to find original AI.
        for(int j=0;j<AIs.length;j++){
          if(AIs[j].getPlayerName().equals(toSave.getPlayerName())){ //AI of the same name goes back to file.
            toSave = AIs[j];
            break;
          }
        }
      } //Fallthrough: An AI *not* listed will be preserved as-is.
      String pData = toSave.getPlayerName()+"\t"+toSave.getType()+"\t"+toSave.getStone()+"\t"
        +toSave.getWins()+"\t"+toSave.getLosses()+"\t"+toSave.getTies();
      out[i] = pData;
    }
    saveStrings(fileName,out);
  }
  
  Player[] searchFor(String toSearch){
    if(records.length < 1)
      return new Player[0];
    Player[] results = new Player[10];
    int marker = 0;
    String lc = toSearch.toLowerCase();
    for(int i=0;i<records.length;i++){
      String plc = records[i].getPlayerName().toLowerCase();
      if(plc.indexOf(lc) == 0 && records[i].getType() == 1){ //registered players 
        results[marker] = records[i];
        if(plc.equals(lc)){ //Move exact matches to the top.
          results[marker] = results[0];
          results[0] = records[i];
        }
        marker++;
        if(marker >= 10)
          break;
      }
    }
    if(marker >= 10)
      return results;
    Player[] out = new Player[marker];
    for(int i=0;i<out.length;i++){
      out[i] = results[i];
    }
    return out;
  }
  
  Player[] getAIs(){
    int AIcount = 0;
    for(int i=0;i<records.length;i++){
      if(records[i].getType() > 1)
        AIcount++;
    }
    Player[] AIs = new Player[AIcount];
    for(int i=records.length-1;i>=0;i--){
      if(records[i].getType() > 1){
        AIcount--;
        AIs[AIcount] = records[i];
        if(AIcount == 0)
          return AIs;
      }
    }
    return new Player[0];
  }
  
  Player[] getHighScores(){
    int numPlayers = 0;
    Player[] topScores = new Player[10];
    for(int i=0;i<records.length;i++){
      if(records[i].getType() == 1){ //Humans only.
        if(numPlayers < 10){ //Any player counts until we have ten of them.
          topScores[numPlayers] = records[i];
          numPlayers++;
        }else if( (records[i].getWins() - records[i].getLosses()) > (topScores[9].getWins() - topScores[9].getLosses()) ){ //Once we have ten, add players that outrank the lowest
          topScores[9] = records[i];
        }
        //simple insertion sort to bring the scores table into proper order.
        int playerIndex = numPlayers - 1;
        while(playerIndex > 0 && ((topScores[playerIndex].getWins() - topScores[playerIndex].getLosses()) > (topScores[playerIndex-1].getWins() - topScores[playerIndex-1].getLosses()))){
          Player temp = topScores[playerIndex];
          topScores[playerIndex] = topScores[playerIndex-1];
          topScores[playerIndex-1] = temp;
        }
      }
    }
    if(numPlayers == 10){
      return topScores;
    }else{
      Player[] out = new Player[numPlayers];
      for(int i=0;i<numPlayers;i++){
        out[i] = topScores[i];
      }
      return out;
    }
  }
  
  void register(Player p){
    if(p == null)
      return;
    Player[] newRec = new Player[records.length+1];
    newRec[records.length]=p;
    p.setType(1);
    for(int i=0;i<records.length;i++){
      if(p.getPlayerName().equalsIgnoreCase(records[i].getPlayerName())) //sanity check: don't register a player that's already there.
        return;
      newRec[i] = records[i];
    }
    records = newRec;
    saveToFile();
  }
  
  
}