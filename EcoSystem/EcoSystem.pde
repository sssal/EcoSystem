World world; //<>//

Boolean isOpenIntroduce;
void setup() {
  size(800, 600);
  frameRate(60);

  world = new World(150, 50, 10);
  textFont(createFont("KaiTi-48.vlw", 48));
  isOpenIntroduce = true;
}

void draw() {
  background(200);

  world.update();

  textSize(15);
  fill(50);
  text("Plants:" + (int)world.getPlantNum(), 20, 20);
  text("Fishes:" + (int)world.getFishNum(), 20, 40);
  text("Fleas:" + (int)world.getFleaNum(), 20, 60);
  rect(100, 7, 20, 12);
  rect(100, 27, 20, 12);
  rect(100, 47, 20, 12);
  fill(250);
  rect(105, 12, 10, 3);
  rect(105, 32, 10, 3);
  rect(105, 52, 10, 3);

  //说明界面
  if (isOpenIntroduce) {
    fill(0, 200);
    rect(width/4, height/4, width/2, height/2, 20);
    textSize(30);
    fill(250);
    text("说明", width/2-50, height/4+40);
    textSize(20);
    text("按 “ i ” 退出/显示说明界面", width/4+20, height/4+70);
    text("左上角表示示植物、水蚤、鱼数量", width/4+20, height/4+100);
    text("鼠标单击左键生成鱼，右键水蚤，中键植物", width/4+20, height/4+130);
    text("鼠标拖拽持续生成",width/4+20,height/4+160);
    text("鼠标单击左上角“-”减少",width/4+20,height/4+190);
    text("鼠标在左上角“-”处拖拽持续减少",width/4+20,height/4+220);
}
}

void mouseDragged() {
  //print(0);
  if (mouseX>100&&mouseX<120&&mouseY>7&&mouseY<19) {
    world.reducePlant();
  } else if (mouseX>100&&mouseX<120&&mouseY>27&&mouseY<39) {
    world.reduceFish();
  } else if (mouseX>100&&mouseX<120&&mouseY>47&&mouseY<59) {
    world.reduceFlea();
  } else {
    if (mouseButton == LEFT) {
      print(1);
      world.addFish(new PVector(mouseX, mouseY));
    } else if (mouseButton == RIGHT) {
      world.addFlea(new PVector(mouseX, mouseY));
    } else if (mouseButton == CENTER) {
      world.addPlant(new PVector(mouseX, mouseY));
    }
  }
}

void mouseClicked() {
  //print(0);
  if (mouseX>100&&mouseX<120&&mouseY>7&&mouseY<19) {
    world.reducePlant();
  } else if (mouseX>100&&mouseX<120&&mouseY>27&&mouseY<39) {
    world.reduceFish();
  } else if (mouseX>100&&mouseX<120&&mouseY>47&&mouseY<59) {
    world.reduceFlea();
  } else {
    if (mouseButton == LEFT) {
      print(1);
      world.addFish(new PVector(mouseX, mouseY));
    } else if (mouseButton == RIGHT) {
      world.addFlea(new PVector(mouseX, mouseY));
    } else if (mouseButton == CENTER) {
      world.addPlant(new PVector(mouseX, mouseY));
    }
  }
}

void keyPressed() {
  if (key == 'i') {
    if (isOpenIntroduce) {
      isOpenIntroduce = false;
    } else {
      isOpenIntroduce = true;
    }
  }
}
