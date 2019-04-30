class Plant extends Creature { //<>//
  //水草类
  Plant(PVector pos, DNA initDNA) {
    super(pos, initDNA);

    //设置植物寿命

    float lifetime = getLifetime();
    float speed = getMaxspeed();
    float size = getSize();

    lifetime = map(lifetime, 0, 1, 0.5, 1); //避免生命速度尺寸太小
    speed = map(speed, 0, 1, 0.5, 1);
    size = map(size, 0, 1, 0.5, 1);
    setLifetime(lifetime*7);
    setMaxspeed(speed*0.5);
    setSize(size*100);
    health = 100;

    maxLifetime=getLifetime();
    maxSize = getSize();
    maxHealth = health;


    breedProbability = 0.004;
  }

  @Override
    void display() {
    ellipseMode(CENTER);
    //stroke(0,lifetime);
    //stroke(0);
    noStroke();

    float alpha = map(health, 0, maxHealth, 100, 255);//透明度

    r=map(lifetime, maxLifetime, 0, 0, 2*maxSize);
    if (r>maxSize) {
      r = maxSize;
    }

    fill(0, 0, 180, alpha);
    ellipse(position.x, position.y, r, r);

    fill(0);
    ellipse(position.x, position.y, 5, 5);
  }

  @Override
    Plant breed() {
    if (r==maxSize&&random(1) < breedProbability) {
      DNA childDNA = dna.dnaCopy();
      childDNA.mutate(0.01); //变异
      PVector childPosition = new PVector(random(position.x-100, position.x+100), 
        random(position.y-100, position.y+100));
      return new Plant(childPosition, childDNA);
    } else {
      return null;
    }
  }

  //移动
  @Override
    void move() {
    float vx = map(noise(xoff), 0, 1, -maxspeed, maxspeed);
    float vy = map(noise(yoff), 0, 1, -maxspeed, maxspeed);
    velocity = new PVector(vx, vy); //添加随机速度
    xoff += 0.01;
    yoff += 0.01;

    //velocity.limit(maxspeed);

    //println(velocity);
    velocity.add(acceleration); //添加加速度
    velocity.limit(maxspeed);   //限制为最大速度
    //println(velocity);
    position.add(velocity);  //移动

    acceleration.mult(0);    //每次移动结束对加速度归零
  }

  //判断死亡
  @Override
    boolean dead() {
    if (lifetime<0.0 || health<0.0) {
      return true;
    } else {
      return false;
    }
  }
}
