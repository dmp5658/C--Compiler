import jdk.swing.interop.SwingInterOpUtils;

import java.io.ObjectStreamException;
import java.util.*;
import java.util.concurrent.ExecutionException;

public class ParserImpl {
    int x = 0;
    Env env = new Env(null);
    boolean returnstmt = false;
    boolean foundmain = false;
    Hashtable<String,String[]> funcparams = new Hashtable<>();
    Hashtable<String, Integer> calledfuncts = new Hashtable<>();
    boolean undefined = false;
    String undefinedstr;
    Hashtable<String, String[]> calledparams = new Hashtable<>();
    Hashtable<String, String> functiontable = new Hashtable<>();
    int returnlineno = 0;
    int funclineno = 0;
    String typespec = "";
    String currscopefunc = "";
    String currfunction = "";
    String currfunctionname = "";


    public Object returnstmt____RETURN_INTLIT_SEMI(Object p2) throws Exception {
        return null;
    }

    public Object returnstmt____RETURN_FLOATLIT_SEMI(Object p2) throws Exception {
        throw new Exception("My custom error message.");
    }

    class Param {

    }

    public Object params_paramlist(Object paramlist) {
        return null;
    }
    public void checknewarr(Object p4,int lineno) throws Exception{
        if(!p4.equals("int")){
            throw new Exception("Error at line "+lineno+" : size of an array must be an int value, to create an array using new operator.");
        }
    }

    public String getarrtype(Object p1){
        String p1type = (String)env.Get((String)p1);
        if(p1type.equals("int[]")){
            return "int";
        }
        if(p1type.equals("float[]")){
            return "float";
        }
        if(p1type.equals("bool[]")){
            return "bool";
        }
        else return null;
    }

    public void newvar(Object p1, Object p2, int lineno) throws Exception{
        Hashtable table = env.currscope();
        if(table.get(p2) != null){
            throw new Exception("Error at line "+lineno+" : the variable "+p2+" is already defined in this scope.");
        }
        env.Put((String)p2,p1);
    }

    public void whilestmt(Object p3, int lineno) throws Exception{
        if(!p3.equals("bool")){
            throw new Exception("Error at line "+lineno+" : while does not use \""+p3+"\" value to check condition. Use bool value in while loop.");
        }

        env.printenv();

    }
    public void ifstmt(Object p3, int lineno) throws Exception{
        if(!p3.equals("bool")){
            throw new Exception("Error at line "+lineno+" : if does not use \""+p3+"\" value to check condition. Use bool value in if statement.");
        }
    }

    public void checkarrstmt(Object p1, Object p3, Object p6, int lineno) throws Exception{
        String p1type = (String)env.Get((String)p1);
        if(!p1type.equals("int[]")&&!p1type.equals("bool[]")&&!p1type.equals("float[]")){
            throw new Exception("Error at line " + lineno + " : "+p1+" must be an array type to use operator []");
        }
        if(!p3.equals("int")){
            throw new Exception("Error at line " + lineno + " : index of "+p1+"[] must be an int value.");
        }
        if(p1type.equals("int[]") && !p6.equals("int")){
            throw new Exception("Error at line " + lineno + " : \""+p1type+"\" value is tried to assign to \"int\" variable "+p1+"[].");
        }
        if(p1type.equals("float[]") && !p6.equals("float")){
            throw new Exception("Error at line " + lineno + " : \""+p1type+"\" value is tried to assign to \"float\" variable "+p1+"[].");
        }
        if(p1type.equals("bool[]") && !p6.equals("bool")){
            throw new Exception("Error at line " + lineno + " : \""+p1type+"\" value is tried to assign to \"bool\" variable "+p1+"[].");
        }

    }
    public void checkarrreturn(Object p1, Object p3, int lineno) throws Exception{
        String p1type = (String)env.Get((String)p1);
        if(!p1type.equals("int[]")&&!p1type.equals("float[]")&&!p1type.equals("bool[]")){
            throw new Exception("Error at line " + lineno + " : "+p1+" must be an array type to use operator []");

        }
        if(!p3.equals("int")){
            throw new Exception("Error at line " + lineno + " : index of "+p1+"[] must be an int value.");

        }

    }


    public void checkarrsize(Object p1, int lineno) throws Exception{
        String p1type = (String)env.Get((String)p1);
        if(!p1type.equals("int[]")&&!p1type.equals("bool[]")&&!p1type.equals("float[]")){
            throw new Exception("Error at line " + lineno + " : "+p1+" must be an array type to use \".size\".");
        }

    }


    public void checkstmt(Object p1, Object p3, int lineno) throws Exception{
        if(!p3.toString().contains("new")) {
            String p1type = (String) env.Get((String) p1);

            if (!p1type.equals(p3)) {
                throw new Exception("Error at line " + lineno + " : \"" + p3 + "\" value is tried to assign to \"" + p1type + "\" variable " + p1 + ".");
            }
        }
    }

    public void cmpstart(){
        currscopefunc = "";
        env = new Env(env);
        env.printenv();

    }
    public void cmpend(){
        env.printenv();
        env = env.delete();
    }

    public void checkexpr(Object p1, Object expr, Object p3, int lineno) throws Exception{


       if( expr.equals("+") || expr.equals("-") || expr.equals("*") || expr.equals("/") ||expr.equals("/") || expr.equals("<=") || expr.equals(">=") || expr.equals("<") || expr.equals(">")  ){
           if(!p1.equals(p3)){
               throw new Exception("Error at line "+lineno+" : operation of \""+p1+"\" "+expr+" \""+p3+"\" is not allowed.");
           }
           else if(p1.equals("bool") || p3.equals("bool")){
               throw new Exception("Error at line "+lineno+" : operation of \""+p1+"\" "+expr+" \""+p3+"\" is not allowed.");
           }
       }

       if( expr.equals("==") || expr.equals("!=")){
           if(!p1.equals(p3)){
               throw new Exception("Error at line "+lineno+" : operation of \""+p1+"\" "+expr+" \""+p3+"\" is not allowed.");
           }
       }

       else if( expr.equals("and") || expr.equals("or")){
            if(!(p1.equals("bool") && (p3.equals("bool")))){
                throw new Exception("Error at line "+lineno+" : operation of \""+p1+"\" "+expr+" \""+p3+"\" is not allowed.");
            }
        }
        else if( expr.equals("not")){
            if(!p1.equals("bool")){
                throw new Exception("Error at line "+lineno+" : unary operation of not \""+p1+"\" is not allowed.");

            }
       }
    }

    public Object getvartype(Object ident, int lineno) throws Exception{
        if(funcparams.get(ident) != null && !currscopefunc.equals(ident) && env.Get((String)ident) == null){
            throw new Exception("Error at line "+lineno+" : a function "+ident+"() cannot be used as a variable.");
        }
        if(env.Get((String)ident) == null){
            throw new Exception("Error at line "+lineno+" : undefine variable "+ident+" is used.");
        }
        else{
            return env.Get((String)ident);
        }
    }
    public String getfuncreturn(Object p1){
        return functiontable.get((String)p1);
    }

    public void checkfunc(Object p1, Object p2,  int lineno) throws Exception {
        functiontable.put((String)p2,(String)p1);
        if (p2.equals("main")) {
            foundmain=true;
            if (!p1.equals("int")) {
                throw new Exception("Error in program: The return type of main function must be int.");
            }
        }
        currfunction = (String) p1;
        currfunctionname = (String) p2;

        /*
        if(funcparams.get((String)p2) == null && calledfuncts.get((String)p2) == null){
            throw new Exception("Error at line "+lineno+" : a function "+p2+"() is not defined.");
        }
*/


    }

    public void checkreturn(Object p2, int lineno) throws Exception {
        if(!currfunction.equals(p2)){
            throw new Exception("Error at line "+lineno+" : return type of "+currfunctionname+"() is \""+currfunction+"\", not \""+p2+"\".");
        }
    }

    public void checkfunc2(Object p2, Object p3, int lineno) throws Exception {
        if(returnstmt == false){
            throw new Exception("Error at function "+currfunctionname+"() defined in line "+funclineno+" : at least one return statement must be used to return \""+p2+"\" value.");
        }

        env.printenv();
        env = env.delete();

    }

    public void checkprog() throws Exception{
        if(!foundmain){
            throw new Exception("Error in program: The program must have one main function.");
        }
    }

    public void newenv(){
        env = new Env(env);
    }

    public void setparams(Object p2,Object p4){
        currscopefunc = (String)p2;
        ArrayList<String> list = new ArrayList<>();
        String strp4 = (String)p4;
        String[] strarr = strp4.split(",");
        functiontable.put((String)p2,typespec);
        funcparams.put((String)p2,strarr);


    }



    public void getparams(Object p2, Object p3, int lineno) throws Exception{
        if(env.Get((String)p2) != null){
            throw new Exception("Error at line "+lineno+" : "+p2+" is a \""+env.Get((String)p2)+"\" variable, not a function.");
        }

        if(funcparams.get((String)p2) == null){
            throw new Exception("Error at line "+lineno+" : a function "+p2+"() is not defined.");
        }




        String strp3 = (String)p3;
        String[] strarr = strp3.split(",");

        String[] paramarr = funcparams.get((String)p2);
        if(paramarr!=null) {
            if (strarr.length > paramarr.length) {

                throw new Exception("Error at line " + lineno + " : only " + paramarr.length + " arguments must be passed to " + p2 + "().");
            }
            for (int i = 0; i < strarr.length; i++) {
                if (!strarr[i].equals(paramarr[i])) {
                    throw new Exception("Error at line " + lineno + " : " + (i + 1) + "th parameter of function " + p2 + "() must be " + paramarr[i] + " type.");
                }
            }
        }
        else{
            calledparams.put((String)p2,strarr);

        }
    }




}