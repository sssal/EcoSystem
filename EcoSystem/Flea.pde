class Flea extends Creature {
  //水蚤类
  Flea(PVector pos, DNA initDNA) {
    super(pos, initDNA);

    health = 100;
    maxHealth = 100;

    breedProbability = 0.01; //交配概率
    matingProbability = 0.01;  //发情概率

    float lifetime = getLifetime();
    float speed = getMaxspeed();
    float size = getSize();

    lifetime = map(lifetime, 0, 1, 0.5, 1); //避免生命速度尺寸太小
    speed = map(speed, 0, 1, 0.5, 1);
    size = map(size, 0, 1, 0.5, 1);

    //设置寿命
    setLifetime(lifetime*50);
    setMaxspeed(speed*5);
    setSize(size*50);

    maxLifetime=getLifetime();
    maxSize = getSize();


    velocity = new PVector(random(-maxspeed, maxspeed), random(-maxspeed, maxspeed));
    velocity = velocity.limit(maxspeed);

    //设置雄雌
    if (random(0, 1)<= 0.5) {
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
    separateWeight = 1;
    alignWeight = 2;
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

    health -= 0.15; 
    lifetime-=0.03;

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

    println(health);

    ellipseMode(RADIUS);
    fill(col, alpha);
    strokeWeight(r/30);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);

    line(0, 0+0.75*r, 0-r/sqrt(2), 0+0.75*r+r/sqrt(2));
    line(0, 0+0.75*r, 0+r/sqrt(2), 0+0.75*r+r/sqrt(2));
    ellipse(0, 0, r/2, r);
    fill(0);
    ellipse(0, -r/2, r/7, r/7);

    stroke(0);
    strokeWeight(r/10);
    noFill();
    arc(0+r, 0, r*sqrt(2), r*sqrt(2), PI+QUARTER_PI, PI+HALF_PI);
    arc(0-r, 0, r*sqrt(2), r*sqrt(2), PI+HALF_PI, PI+HALF_PI+QUARTER_PI);
    popMatrix();
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

  //躲避动作
  void moveElude(ArrayList<Fish> fishes) {
    PVector elu = elude(fishes);

    elu.mult(10);

    applyForce(elu);
  }

  //躲避
  PVector elude(ArrayList<Fish> fishes) {
    float neighbordist = r * 10;
    for (Fish f:fishes) {
      //从一个生物到另一个生物的向量
      PVector comparison = PVector.sub(f.position, position);
      //距离
      float d = PVector.dist(position, f.position);
      //角度
      float  diff = PVector.angleBetween(comparison, velocity);
      if ((diff < periphery) && (d < neighbordist)) {
        PVector result = seek(f.position);
        result = new PVector(-result.x, -result.y);
        return result;
      }
    }
    return new PVector(0, 0);
  }

  @Override //有性繁殖
    Flea breed() {
    if (isPregnancy && random(1) < breedProbability) {
      DNA childDNA = dna.dnaCross(fatherDNA);
      childDNA.mutate(0.01); //变异
      return new Flea(position, childDNA);
      //return null;
    } else {
      return null;
    }
  }

  //移动
  @Override
    void move() {
    velocity.add(acceleration); //添加加速度
    velocity.limit(maxspeed);   //限制为最大速度
    //println(velocity);
    position.add(velocity);  //移动

    acceleration.mult(0);    //每次移动结束对加速度归零
  }

  //对齐行为
  @Override  //添加视野角度
    PVector align (ArrayList<? extends Creature> creatures) {
    float neighbordist = size * 2;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Creature other : creatures) {
      //从一个生物到另一个生物的向量
      PVector comparison = PVector.sub(other.position, position);
      //距离
      float d = PVector.dist(position, other.position);
      //角度
      float  diff = PVector.angleBetween(comparison, velocity);
      if ((diff < periphery) && (d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  //吃水草
  void eat(ArrayList<Plant> plants) {
    //ArrayList<Plant> plants = P.getPlants();
    if (health<100) {
      for (Plant p : plants) {
        float d = PVector.dist(position, p.position);
        if (d<r) {
          p.health-=5;
          health+=1;
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
