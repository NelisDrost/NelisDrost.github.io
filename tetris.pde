PVector[] block;
ArrayList<PVector> static_blocks;

int w, h;
float block_size;

int score = 0;

boolean dropping = false;

boolean lost = false;

void setup() {
  size(400, 700);
  
  w = 8;
  h = 14;
  block_size = width/(w+2);
  
  spawnBlock();
  static_blocks = new ArrayList<PVector>();
  for (int i = 0; i < w - 1; i++) 
    static_blocks.add(new PVector(i, h - 1));
}

int frame = 0;
void draw() {
    background(100);
   frame++;
   
   stroke(0,255);
   strokeWeight(1);
   for (int i = 0; i < 4; i++)
     rect(block_size + block[i].x * block_size, block[i].y * block_size, block_size, block_size);
     
   if (lost) fill(255,0,0,200);
   for (PVector b : static_blocks)
     rect(block_size + b.x * block_size, b.y * block_size, block_size, block_size);
   
   int per_frame = dropping ? 3 : 30;
   
   if (frame % per_frame == 0 && !lost) {
      for (int i = 0; i < 4; i++) 
        block[i].y ++;
        checkBlockStopped();
   } 
   if (lost) {
     textAlign(CENTER, CENTER);
     fill(0,255);
     text("GAME OVER", width/2, height/2);
     textAlign(LEFT, BOTTOM);
   }  
  
   stroke(255,255);
   strokeWeight(2);
   line(block_size, block_size, block_size, (h) * block_size);
   line(block_size, (h) * block_size, (w+1) * block_size, (h) * block_size);
   line((w+1) * block_size, block_size, (w+1) * block_size, (h) * block_size);
   
   //for(int y = 0; y < h; y++)
   //  text(y, 0, (y+1) * block_size);
   
   //for(int x = 0; x < w; x++)
   //  text(x, (x+1) * block_size, (h+1) * block_size);
   
   textSize(32);
   text("Score : " + score, block_size, (h + 2) * block_size);
   text("Q, E, A, S, D to control", block_size, (h+3) * block_size);
}

void rotateBlock(int dir) {
   PVector[] relative = new PVector[4];
   int i = 0;
   for (PVector b : block) {
      relative[i] = PVector.sub(b, block[1]);
      relative[i++].rotate(float(dir) * HALF_PI);
   }
   for (i = 0; i < 4; i++) { //<>//
     block[i] = PVector.add(block[1], (relative[i])); //<>//
   }

   sanitiseBlock();
   boolean in_bounds = true;
   for (PVector b : block) {
      if (b.x < 0) in_bounds = false;
      if (b.x > w) in_bounds = false;
   }
   if (!in_bounds) rotateBlock(-dir);
}

void checkLinesComplete() {
   for(int i = 0; i < h; i++) {
     int line_count = 0;
     for(int j = 0; j < w; j++) {
       if (blockAt(j, i))
         line_count++;
     }
     
     if (line_count == w)
     {
        score += 100;
        for (int j = 0; j < w; j++)
          static_blocks.remove(getBlockAt(j, i));
        dropBlocks(i);
        return;
     }
   }
}

void dropBlocks(int line) {
   for (int y = line - 1; y >= 0; y--) { //<>//
     for (int x = 0; x < w; x++) {
       PVector b = getBlockAt(x, y);
       if (b != null) {
         b.y++;
       }
   }}
}

boolean blockAt(int x, int y) {
   for (PVector b : static_blocks) {
      if(round(b.x) == x && round(b.y) == y)
        return true;
   }
   return false;
}

PVector getBlockAt(int x, int y) {
   for (PVector b : static_blocks) {
      if(round(b.x) == x && round(b.y) == y)
        return b;
   }
   return null;
}

void checkBlockStopped() {
  boolean has_stopped = false;
  for (int i = 0; i < 4; i++) {
     if (block[i].y == h - 1) {
       has_stopped = true;
     }
     for (PVector b : static_blocks) {
        if (b.x == block[i].x && b.y - 1 == block[i].y)
          has_stopped = true;
        }
     }
  if (has_stopped) {
    sanitiseBlock();
    for (int j = 0; j < 4; j++)
    {
      static_blocks.add(block[j]);
    }
    score += 5;
    checkLinesComplete();
    if (checkLost()) {
       return;
    }
    else
    {
      spawnBlock();
    }
  }
}

void sanitiseBlock() {
   for (PVector b : block) {
      b.x = round(b.x);
      b.y = round(b.y);
   }
}

void keyPressed() {
   if (lost) return;
   boolean can_move_right = true; boolean can_move_left = true;
   
   for (PVector b : block) {
     if (b.x <= 0) can_move_left = false;
     if (b.x >= w -1) can_move_right = false;
   }
  
   if (key == 'a' && can_move_left) {
     for (int i = 0; i < 4; i++) {
       block[i].x--;
     }}
     
   if (key == 'd' && can_move_right) {
     for (int i = 0; i < 4; i++) {
       block[i].x++;
     }}
     
   if (key == 'q') {
     rotateBlock(-1);
   }
   
   if (key == 'e') {
     rotateBlock(1);
   }
     
   if (key == 's')
     dropping = true;
}

boolean checkLost() {
   for (int x = 0; x < w; x++)
   {
     if (blockAt(x, 2)) {
       lost = true;
       return true;
   }}
   return false;
}

void spawnBlock() {
  dropping = false;
  block = new PVector[4];
  float r = random(1.4);
  if (r < .2) { // left squigle
    block[0] = new PVector(1, 1);
    block[1] = new PVector(1, 2);
    block[2] = new PVector(2, 2);
    block[3] = new PVector(2, 3);
  }
  else if (r < .4) { // right squigle
    block[0] = new PVector(2, 1);
    block[1] = new PVector(2, 2);
    block[2] = new PVector(1, 2);
    block[3] = new PVector(1, 3);
  }
  else if (r < .6) {
    block[0] = new PVector(1, 1);
    block[1] = new PVector(1, 2);
    block[2] = new PVector(2, 1);
    block[3] = new PVector(2, 2);
  }
  else if (r < .8) {
    block[0] = new PVector(2, 1);
    block[1] = new PVector(2, 2);
    block[2] = new PVector(2, 3);
    block[3] = new PVector(2, 4);
  }
  else if (r < 1) { // T
    block[0] = new PVector(2, 1);
    block[1] = new PVector(1, 2);
    block[2] = new PVector(2, 2);
    block[3] = new PVector(3, 2);
  }
  else if (r < 1.2) { // L
    block[0] = new PVector(1, 1);
    block[1] = new PVector(1, 2);
    block[2] = new PVector(1, 3);
    block[3] = new PVector(2, 3);
  }
  else { // right L
    block[0] = new PVector(2, 1);
    block[1] = new PVector(2, 2);
    block[2] = new PVector(2, 3);
    block[3] = new PVector(1, 3);
  }
}
