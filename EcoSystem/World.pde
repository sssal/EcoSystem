class World {
  ArrayList<Flea> fleas;
  ArrayList<Plant> plants;
  ArrayList<Fish> fishes;

  World(int plantsNum, int fleasNum, int fishNum) {
    plants = new ArrayList<Plant>();
    for (int i=0; i<plantsNum; i++) {
      PVector pos = new PVector(random(width), random(height));
      plants.add(new Plant(pos, new DNA()));
    }

    fleas = new ArrayList<Flea>();
    for (int i=0; i<fleasNum; i++) {
      PVector pos = new PVector(random(width), random(height));
      fleas.add(new Flea(pos, new DNA()));
    }

    fishes = new ArrayList<Fish>();
    for (int i=0; i<fishNum; i++) {
      PVector pos = new PVector(random(width), random(height));
      fishes.add(new Fish(pos, new DNA()));
    }
  }

  void update() {
    for (int i = plants.size()-1; i >= 0; i--) {
      Plant p = plants.get(i);
      p.update();
      if (p.dead()) {
        plants.remove(i);
      }
      Plant newP = p.breed();
      if (newP!=null) {
        plants.add(newP);
      }
    }


    for (Flea f : fleas) {
      f.flock(fleas);
      f.moveElude(fishes);
    }
    for (int i = fleas.size()-1; i >= 0; i--) {
      // All bloops run and eat
      Flea f = fleas.get(i);
      f.update();
      f.eat(plants);
      if (f.dead()) {
        fleas.remove(i);
      }
      Flea newP = f.breed();
      if (newP!=null) {
        fleas.add(newP);
      }
    }

    for (Fish f : fishes) {
      f.flock(fishes);
      f.moveForaging(fleas);
    }
    for (int i = fishes.size()-1; i >= 0; i--) {
      // All bloops run and eat
      Fish f = fishes.get(i);
      f.update();
      f.eat(fleas);
      if (f.dead()) {
        fishes.remove(i);
      }
      Fish newP = f.breed();
      if (newP!=null) {
        fishes.add(newP);
      }
    }
  }

  float getFishNum() {
    return fishes.size();
  }

  float getFleaNum() {
    return fleas.size();
  }

  float getPlantNum() {
    return plants.size();
  }

  void addFish(PVector pvector) {
    fishes.add(new Fish(pvector, new DNA()));
  }

  void addFlea(PVector pvector) {
    fleas.add(new Flea(pvector, new DNA()));
  }

  void addPlant(PVector pvector) {
    plants.add(new Plant(pvector, new DNA()));
  }

  void reduceFish() {
    fishes.remove(0);
  }
  void reducePlant() {
    plants.remove(0);
  }
  void reduceFlea() {
    fleas.remove(0);
  }
}
