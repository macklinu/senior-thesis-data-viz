class Keyboard {

  final static int NORTH = 1;
  final static int EAST = 2;
  final static int SOUTH = 4;
  final static int WEST = 8;
  final static int L = 16;
  final static int R = 32;
  int result;

  Keyboard() {
    result = 0;
  }

  void check(Gun gun) {
    switch(result) {
    case NORTH: 
      gun.moveY(-1); 
      break;
    case EAST: 
      gun.moveX(1); 
      break;
    case SOUTH: 
      gun.moveY(1); 
      break;
    case WEST: 
      gun.moveX(-1); 
      break;
    case NORTH|EAST: 
      gun.moveY(-1); 
      gun.moveX(1); 
      break;
    case NORTH|WEST: 
      gun.moveY(-1); 
      gun.moveX(-1); 
      break;
    case SOUTH|EAST: 
      gun.moveY(1); 
      gun.moveX(1); 
      break;
    case SOUTH|WEST: 
      gun.moveY(1); 
      gun.moveX(-1); 
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

