class DNA {

  private HashMap<String, Float> genes=new HashMap<String,Float>();

  DNA() {
    genes.put("lifetime", random(0, 1.0));
    genes.put("speed", random(0, 1.0));
    genes.put("size", random(0, 1.0));
    //genes.put("growth",random(0,1.0));//成长速度，可合并到size中
  }

  DNA(HashMap newgenes) {
    genes=newgenes;
  }

  //复制
  public DNA dnaCopy() {
    HashMap<String, Float> childGenes = (HashMap<String,Float>)genes.clone();
    
    return new DNA(childGenes);
  }
  
  //交叉
  public DNA dnaCross(DNA fatherDNA){
    HashMap<String, Float> childGenes = (HashMap<String,Float>)genes.clone();
    HashMap<String, Float> fatherGenes = fatherDNA.genes;
    float lifetime = (fatherGenes.get("lifetime") + genes.get("lifetime"))/2;
    childGenes.put("lifetime",lifetime);
    float speed = (fatherGenes.get("speed") + genes.get("speed"))/2;
    childGenes.put("speed",speed);
    float size = (fatherGenes.get("size") + genes.get("size"))/2;
    childGenes.put("size",size);
    
    return new DNA(childGenes);
  }
  
  //变异
  public void mutate(float m) {
    for (String key : genes.keySet()) {
      if (random(1)<m) {
        genes.put(key, random(0, 1));
      }
    }
  }
}
