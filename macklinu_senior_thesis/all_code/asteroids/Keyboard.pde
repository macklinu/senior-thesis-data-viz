class Keyboard {

  final static int NORTH = 1;
  final static int EAST = 2;
  final static int SOUTH = 4;
  final static int WEST = 8;
  final static int L = 16;
  final static int R = 32;
  int result;
  int amt;

  Keyboard() {
    result = 0;
    amt = 2;
  }

  void check(Gun gun) {
    switch(result) {
      case NORTH: 
      gun.moveY(-amt); 
      break;
      case EAST: 
      gun.moveX(amt); 
      break;
      case SOUTH: 
      gun.moveY(amt); 
      break;
      case WEST: 
      gun.moveX(-amt); 
      break;
      case NORTH|EAST: 
      gun.moveY(-amt); 
      gun.moveX(amt); 
      break;
      case NORTH|WEST: 
      gun.moveY(-amt); 
      gun.moveX(-amt); 
      break;
      case SOUTH|EAST: 
      gun.moveY(amt); 
      gun.moveX(amt); 
      break;
      case SOUTH|WEST: 
      gun.moveY(amt); 
      gun.moveX(-amt); 
      break;
      case L: 
      gun.rot(-PI); 
      break;
      case R: 
      gun.rot(PI); 
      break;
    }
  }

  void pressed() {
    switch(key) {
      case('w'):
      case('W'):
      result |=NORTH;
      break;
      case('d'):
      case('D'):
      result |=EAST;
      break;
      case('s'):
      case('S'):
      result |=SOUTH;
      break;
      case('a'):
      case('A'):
      result |=WEST;
      break;
      case('j'):
      case('J'):
      result |=L;
      break;
      case('k'):
      case('K'):
      result |=R;
      break;
    }
  }

  void released() {
    switch(key) {
      case('w'):
      case('W'):
      result ^=NORTH;
      break;
      case('d'):
      case('D'):
      result ^=EAST;
      break;
      case('s'):
      case('S'):
      result ^=SOUTH;
      break;
      case('a'):
      case('A'):
      result ^=WEST;
      break;
      case('j'):
      case('J'):
      result ^=L;
      break;
      case('k'):
      case('K'):
      result ^=R;
      break;
    }
  }
  
}
