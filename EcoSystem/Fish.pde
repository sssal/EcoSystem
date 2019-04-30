class Fish extends Creature {
  //鱼类
  Fish(PVector pos, DNA initDNA) {
    super(pos, initDNA);

    health = 100;
    maxHealth = 100;

    breedProbability = 0.001; //交配概率
    matingProbability = 0.01;  //发情概率

    float lifetime = getLifetime();
    float speed = getMaxspeed();
    float size = getSize();

    lifetime = map(lifetime, 0, 1, 0.5, 1); //避免生命速度尺寸太小
    speed = map(speed, 0, 1, 0.5, 1);
    size = map(size, 0, 1, 0.5, 1);

    //设置寿命
    setLifetime(lifetime*100);
    setMaxspeed(speed*8);
    setSize(size*100);

    maxLifetime=getLifetime();
    maxSize = getSize();

    velocity = new PVector(random(-maxspeed, maxspeed), random(-maxspeed, maxspeed));
    velocity = velocity.limit(maxspeed);
    //设置雄雌
    if (random(1)<0.5) {
      gender = true;
    } else {
      gender = false;
    }
    //雌雄颜色不同
    if (gender) {
      col = color(255, 0, 0);
    } else {
      col = color(0, 255, 0);
    }

    //设置不同行为的权重
    separateWeight = 2;
    alignWeight = 0;
    cohesionWeight = 0;

    //初始设置发情期为否
    isRut = false;
  }

  //更新
  @Override
    void update() {
    rut();
    move();
    //println(position.x);
    borders();
    //eat();
    display();

    health -= 0.1; 
    lifetime-=0.01;
    if (health<maxHealth/2) {
      isRut = false;
    }
  }

  @Override
    void display() {
    r = map(lifetime, maxLifetime, 0, 0, 2*maxSize);
    if (r>=maxSize) {
      r = maxSize;
    }
    float theta = velocity.heading2D() + radians(90);
    float alpha = map(health, 0, maxHealth, 100, 255);//透明度
    fill(col, alpha);
    strokeWeight(1);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    quad(0-r/2, 0, 0, 0-r, 0+r/2, 0, 0, 0+r);
    triangle(0, 0+r, 0+r/2, 0+r+r/2, 0-r/2, 0+r+r/2);
    fill(244);
    ellipse(0, 0-r/2, r/7, r/7);
    popMatrix();
  }



  @Override    //有性繁殖
    Fish breed() {
    if (isPregnancy && random(1) < breedProbability) {
      DNA childDNA = dna.dnaCross(fatherDNA);
      childDNA.mutate(0.01); //变异
      return new Fish(position, childDNA);
      //return null;
    } else {
      return null;
    }
  }

  @Override //加入寻偶行为
    void flock(ArrayList<? extends Creature> Creatures) {
    if (isRut) {
      PVector mat = mating(Creatures);
      PVector sep = separate(Creatures);   // Separation
      PVector ali = align(Creatures);      // Alignment
      PVector coh = cohesion(Creatures);   // Cohesion

      mat.mult(5);
      sep.mult(separateWeight);
      ali.mult(alignWeight);
      coh.mult(cohesionWeight);

      applyForce(mat);
      applyForce(sep);
      applyForce(ali);
      applyForce(coh);
    } else {
      PVector sep = separate(Creatures);   // Separation
      PVector ali = align(Creatures);      // Alignment
      PVector coh = cohesion(Creatures);   // Cohesion

      sep.mult(separateWeight);
      ali.mult(alignWeight);
      coh.mult(cohesionWeight);

      // Add the force vectors to acceleration
      applyForce(sep);
      applyForce(ali);
      applyForce(coh);
    }
  }

  //捕食运动
  void moveForaging(ArrayList<Flea> fleas) {
    PVector fora = foraging(fleas);

    fora.mult(5);

    applyForce(fora);
  }

  //移动
  @Override
    void move() {
    //添加随机运动 ？？

    velocity.add(acceleration); //添加加速度
    velocity.limit(maxspeed);   //限制为最大速度
    //println(velocity);
    position.add(velocity);  //移动

    acceleration.mult(0);    //每次移动结束对加速度归零
    //acceleration = new PVector(random(-maxspeed, maxspeed), random(-maxspeed, maxspeed));
    //acceleration.limit(maxforce);
    ////println(acceleration);
  }

  //吃水蚤
  void eat(ArrayList<Flea> fleas) {
    //ArrayList<Plant> plants = P.getPlants();
    if (health<100) {
      for (Flea f : fleas) {
        float d = PVector.dist(position, f.position);
        if (d<r && r>f.r/2 &&f.r>r/6) {
          f.health-=100;
          health+=5;
          break;
        }
      }
    }
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
