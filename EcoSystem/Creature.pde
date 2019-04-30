class Creature {
  //生物类 所有生物的父类
  PVector position;  //位置
  PVector acceleration; //加速度
  PVector velocity;  //速度

  float lifetime;     //寿命 
  float maxspeed;     //速度
  float maxforce;    //转向力
  float size;         //大小
  float r;            //画图大小

  float maxLifetime; //用来保存生物的最大生命和尺寸
  float maxSize;     
  float health;      //生命值
  float maxHealth;

  DNA dna;          
  DNA fatherDNA;

  //设置不同行为的权重
  float separateWeight;
  float cohesionWeight;
  float alignWeight;

  float breedProbability; //繁殖概率
  float matingProbability; //交配概率

  float xoff;
  float yoff;  //控制随机移动速度

  float periphery = PI/2; //视野角度

  Boolean gender;  //性别
  Boolean isRut;   //是否处于发情期
  Boolean isPregnancy; //怀孕

  color col;      //颜色

  Creature(PVector pos, DNA initDNA) {
    position=pos.copy();
    dna = initDNA;

    lifetime = map(dna.genes.get("lifetime"), 0, 1, 0, 1);
    maxspeed = map(dna.genes.get("speed"), 0, 1, 0, 1);
    size = map(dna.genes.get("size"), 0, 1, 0, 1);

    maxforce = 0.05;
    breedProbability = 0.005;
    alignWeight = 1;
    separateWeight = 1;
    cohesionWeight = 1;

    xoff = random(1000);
    yoff = random(1000);
    float vx = map(noise(xoff), 0, 1, -maxspeed, maxspeed);
    float vy = map(noise(yoff), 0, 1, -maxspeed, maxspeed);
    velocity = new PVector(vx, vy);



    //velocity.limit(maxspeed);
    //velocity = new PVector(random(-1, 1), random(-1, 1));
    //初始加速度
    acceleration = new PVector(0, 0);

    //初始设置发情期为否
    isRut = false;
    isPregnancy = false;
  }

  //更新
  void update() {
    move();
    //println(position.x);
    borders();
    display();

    lifetime-=0.01;
  }

  //移动
  void move() {
    velocity.add(acceleration); //添加加速度
    velocity.limit(maxspeed);   //限制为最大速度
    //println(velocity);
    position.add(velocity);  //移动

    acceleration.mult(0);    //每次移动结束对加速度归零
  }

  //画图
  void display() {
    ellipseMode(CENTER);
    //stroke(0,lifetime);
    stroke(0);
    fill(0, lifetime);

    ellipse(position.x, position.y, r, r);
  }
  
  //添加力改变加速度
  void applyForce(PVector force) {
    acceleration.add(force);
  }

  //三种群集规则
  //分离  避免碰撞
  //对齐  转向力与邻居一致
  //聚集  朝邻居中心转向 （留在群体内）
  void flock(ArrayList<? extends Creature> Creatures) {

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

  //寻找
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);
    //Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  // Cohesion 聚集行为
  PVector cohesion (ArrayList<? extends Creature> creatures) {
    float neighbordist = r * 5; //视野  ？？？？
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Creature other : creatures) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // 将其他对象位置相加
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  //寻找邻居的平均坐标
    } else {
      return new PVector(0, 0);
    }
  }

  //分离行为
  PVector separate (ArrayList<? extends Creature> creatures) {
    float desiredseparation = r*1.5; //分离视野
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Creature other : creatures) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  //对齐行为
  PVector align (ArrayList<? extends Creature> creatures) {
    float neighbordist = r * 3;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Creature other : creatures) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
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

  //设置发情期
  void rut() {
    //if (size == maxSize && !isrut && random(1)<breedProbability) {
    if (r >= maxSize && health>maxHealth/2) {
      //print(0);
      if (!isRut && !isPregnancy) {
        //print(1);
        if (random(1)<matingProbability) {
          //print(2);
          isRut = true;
          if (gender) {
            col = color(100, 0, 0);
            //print(2);
          } else {
            //print(1);
            col = color(0, 100, 0);
          }
        }
      }
    }
  }

  //寻偶
  PVector mating(ArrayList<? extends Creature> creatures) {
    float neighbordist = r * 15;
    if (isRut) {
      for (Creature other : creatures) {
        if (other.isRut && gender != other.gender) {
          //都处于发情期且性别不同
          //PVector comparison = PVector.sub(other.position, position);
          //距离
          float d = PVector.dist(position, other.position);
          //角度
          //float  diff = PVector.angleBetween(comparison, velocity);
          if ( (d < neighbordist) && (d>r)) {
            return seek(other.position);
          } else if (d<r) { //当两者足够靠近
            //print(3);
            isRut = false;
            other.isRut = false;
            if (gender) {
              col = color(255, 0, 0);
              other.col = color(0, 255, 0);

              isPregnancy = true;
              fatherDNA = other.dna;
            } else {
              col = color(0, 255, 0);
              other.col = color(255, 0, 0);

              other.isPregnancy = true;
              other.fatherDNA = dna;
            }
          }
        }
      }
    }
    return new PVector(0, 0);
  }

  //觅食
  PVector foraging(ArrayList<? extends Creature> creatures) {
    float neighbordist = r * 10;
    for (Creature c:creatures) {
      //从一个生物到另一个生物的向量
      PVector comparison = PVector.sub(c.position, position);
      //距离
      float d = PVector.dist(position, c.position);
      //角度
      float  diff = PVector.angleBetween(comparison, velocity);
      if ((diff < periphery) && (d < neighbordist)) {
        return seek(c.position);
      }
    }
    return new PVector(0, 0);
  }


  //繁殖
  public Creature  breed() {
    return null;
  };

  // 避免超出画板范围
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }

  //判断死亡
  boolean dead() {
    if (lifetime<0.0) {
      return true;
    } else {
      return false;
    }
  }


  public float getLifetime() {
    return lifetime;
  }

  public void setLifetime(float lifetime) {
    this.lifetime=lifetime;
  }

  public float getMaxspeed() {
    return maxspeed;
  }

  public void setMaxspeed(float speed) {
    maxspeed=speed;
  }

  public float getSize() {
    return size;
  }

  public void setSize(float size) {
    this.size=size;
  }
}
