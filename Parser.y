/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Copyright (C) 2001 Gerwin Klein <lsf@jflex.de>                          *
 * All rights reserved.                                                    *
 *                                                                         *
 * This is a modified version of the example from                          *
 *   http://www.lincom-asg.com/~rjamison/byacc/                            *
 *                                                                         *
 * Thanks to Larry Bell and Bob Jamison for suggestions and comments.      *
 *                                                                         *
 * License: BSD                                                            *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

%{
import java.io.*;
%}

%right  ASSIGN
%left   OR 
%left   AND 
%left   EQ      NE  
%left   LE      LT      GE      GT 
%left   PLUS    MINUS  
%left   MUL     DIV     MOD 
%right  NOT


%token <obj>  BOOL_LIT  IDENT
%token <ival> INT_LIT
%token <dval> FLOAT_LIT

%token <obj> INT      FLOAT      BOOL   
%token       IF  ELSE  NEW  PRINT  WHILE  RETURN  CONTINUE  BREAK
%token       ASSIGN  LPAREN  RPAREN  LBRACE  RBRACE  LBRACKET  RBRACKET  RECORD  SIZE  SEMI  COMMA  DOT  ADDR

%type <obj> program   decl_list  decl
%type <obj> var_decl  fun_decl   local_decls   type_spec
%type <obj> params  param_list param
%type <obj> stmt_list
%type <obj> stmt expr_stmt while_stmt compound_stmt compound_stmt2
%type <obj> local_decl if_stmt break_stmt
%type <obj> continue_stmt print_stmt args arg_list fun_decl2 fun_decl3



%type <obj> return_stmt

%type <obj> expr


%%


program         : decl_list                                     { parserimpl.checkprog(); }
                ;

decl_list       : decl_list decl                                {  }
                |                                               {  }
                ;

decl            : var_decl                                      {  }
                | fun_decl                                      {  }
                ;

var_decl        : type_spec IDENT SEMI                          { parserimpl.newvar($1, $2, lexer.lineno); }
                ;

type_spec       : BOOL                                          { parserimpl.funclineno = lexer.lineno;  $$ = "bool"; }
                | INT                                           { parserimpl.funclineno = lexer.lineno; parserimpl.typespec = "int";$$ = "int" ;}
                | FLOAT                                         { parserimpl.funclineno = lexer.lineno; parserimpl.typespec = "float";$$ = "float";}
                | type_spec  LBRACKET  RBRACKET                 { $$ = $1+"[]";}
                ;

fun_decl        : fun_decl2 fun_decl                  {   parserimpl.returnstmt = false; }
                | LBRACE local_decls stmt_list RBRACE           { parserimpl.checkfunc2($2, $3, lexer.lineno); $$ = $3;}
                ;

fun_decl3       : LPAREN                                            { parserimpl.newenv();}

fun_decl2       : type_spec IDENT fun_decl3 params RPAREN                    { parserimpl.checkfunc($1, $2, lexer.lineno); parserimpl.typespec = (String)$1; parserimpl.setparams($2,$4); $$ = $1; }
                ;

params          : param_list                                    { $$ = $1;  parserimpl.env.printenv();
 }
                |                                               { }
                ;

param_list      : param_list COMMA param                        { $$ = $1 +","+$3;}
                | param                                         { }
                ;

param           : type_spec IDENT                               { parserimpl.newvar($1, $2, lexer.lineno); $$ = $1;}
                ;

stmt_list       : stmt_list stmt                                { $$ = $2;}
                |                                               { }
                ;

stmt            : expr_stmt                                     { $$ = $1;}
                | compound_stmt                                 { }
                | if_stmt                                       { }
                | while_stmt                                    { }
                | return_stmt                                   {  parserimpl.returnlineno = lexer.lineno; $$ = $1 ;}
                | break_stmt                                    { }
                | continue_stmt                                 { }
                | print_stmt                                    { }
                | SEMI                                          { }
                ;

expr_stmt       : IDENT ASSIGN expr_stmt                       { parserimpl.checkstmt($1,$3,lexer.lineno); $$ = $3;}
                | expr SEMI                                    { $$ = $1;}
                |  IDENT  LBRACKET  expr  RBRACKET  ASSIGN  expr_stmt  {  parserimpl.checkarrstmt($1, $3, $6, lexer.lineno); $$ = $6; }
                ;

while_stmt      : while_stmt2 stmt                { }
                ;

while_stmt2     : WHILE LPAREN expr RPAREN                                   {  parserimpl.whilestmt($3,lexer.lineno);}
                ;

compound_stmt   : compound_stmt3 local_decls stmt_list compound_stmt2           { }
                ;

compound_stmt3  : LBRACE                                                    {  parserimpl.cmpstart();}
                ;

compound_stmt2  : RBRACE                                                 { parserimpl.cmpend();}
                ;

local_decls     : local_decls local_decl                       { }
                |                                              { }
                ;

local_decl      : type_spec IDENT SEMI                         { parserimpl.newvar($1,$2, lexer.lineno); }
                ;

if_stmt         : if_stmt2 stmt ELSE stmt         {  $$ = $2; }
                ;

if_stmt2        : IF LPAREN expr RPAREN           {parserimpl.ifstmt($3,lexer.lineno);}
                ;

return_stmt     : RETURN expr SEMI                             { parserimpl.returnstmt = true;$$ = $2; parserimpl.checkreturn($2, lexer.lineno);}
                ;

break_stmt      : BREAK SEMI                                   { }
                ;

continue_stmt   : CONTINUE SEMI                                { }
                ;

print_stmt      : PRINT expr SEMI                              { }
                ;


expr            : expr OR expr                                 { parserimpl.checkexpr($1,"or",$3,lexer.lineno) ; $$ = "bool"; }
                | expr AND expr                                { parserimpl.checkexpr($1,"and",$3,lexer.lineno) ; $$ = "bool"; }
                | NOT expr                                     { parserimpl.checkexpr($2, "not", null, lexer.lineno); $$ = "bool";}
                | expr EQ expr                                 { parserimpl.checkexpr($1,"==",$3,lexer.lineno) ; $$ = "bool"; }
                | expr NE expr                                 { parserimpl.checkexpr($1,"!=",$3,lexer.lineno) ; $$ = "bool";  }
                | expr LE expr                                 { parserimpl.checkexpr($1,"<=",$3,lexer.lineno) ; $$ = "bool"; }
                | expr  LT  expr                               { parserimpl.checkexpr($1,"<",$3,lexer.lineno) ; $$ = "bool"; }
                | expr  GE  expr                               { parserimpl.checkexpr($1,">=",$3,lexer.lineno) ; $$ = "bool"; }
                | expr  GT  expr                               { parserimpl.checkexpr($1,">",$3,lexer.lineno) ; $$ = "bool"; }
                | expr  PLUS  expr                             {   parserimpl.checkexpr($1,"+",$3,lexer.lineno) ; $$ = $1;}
                | expr  MINUS  expr                            {   parserimpl.checkexpr($1,"-",$3,lexer.lineno); $$ = $1;}
                | expr  MUL  expr                              {   parserimpl.checkexpr($1,"*",$3,lexer.lineno); $$ = $1;}
                | expr  DIV  expr                              {   parserimpl.checkexpr($1,"/",$3,lexer.lineno); $$ = $1;}
                | LPAREN  expr  RPAREN                         { $$ = $2; }
                | IDENT                                        { $$ = parserimpl.getvartype($1,lexer.lineno);}
                | BOOL_LIT                                     {  $$ = "bool"; }
                | INT_LIT                                      {  $$ ="int"; }
                | FLOAT_LIT                                    {  $$ ="float"; }
                |  IDENT  LPAREN  args  RPAREN                  { parserimpl.getparams($1, $3, lexer.lineno); $$ = parserimpl.getfuncreturn($1);}
                |  IDENT  LBRACKET  expr  RBRACKET    { parserimpl.checkarrreturn($1,$3,lexer.lineno); $$=parserimpl.getarrtype($1);}
                |  IDENT  DOT  SIZE             { parserimpl.checkarrsize($1,lexer.lineno); $$ = "int";}
                |  NEW  type_spec  LBRACKET  expr  RBRACKET      { parserimpl.checknewarr($4,lexer.lineno);$$ = "new "+$2+"["+$4+"]";}
                ;

args            : arg_list                                     { $$ = $1;}
                |                                              {  }
                ;
arg_list        : arg_list COMMA expr                          { $$ = $1+","+$3; }
                | expr                                         {  $$ = $1;}
                ;

%%
    private Lexer lexer;
    int funccount = 0;
    boolean ismain = false;
    ParserImpl parserimpl = new ParserImpl();
    private int yylex () {
        int yyl_return = -1;
        try {
            yylval = new ParserVal(0);
            yyl_return = lexer.yylex();
        }
        catch (IOException e) {
            System.out.println("IO error :"+e);
        }
        return yyl_return;
    }

    public void yyerror (String error) {
        System.out.println ("Error: " + error);
    }

    public Parser(Reader r) {
        lexer = new Lexer(r, this);
    }
