import jdk.swing.interop.SwingInterOpUtils;

import java.util.HashMap;
import java.util.Hashtable;

public class Env{


  private Hashtable<String,Object> table = new Hashtable<String,Object>();
  private Env prev;
    public Env(Env prev)
    {
       table = new Hashtable<String,Object>();
       this.prev = prev;


    }
    public void Put(String name, Object value)
    {
      table.put(name,value);
    }
    public Object Get(String name)
    {
      if(table.get(name) != null){
        return table.get(name);
      }
      else if(prev != null && prev.Get(name) != null){
        return prev.Get(name);
      }
      else{
        return null;
      }


    }
    public Env delete(){
      return prev;
    }
    public Hashtable currscope(){
      return table;
    }
    public void printenv(){



    }
}
