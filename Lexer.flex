/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Copyright (C) 2000 Gerwin Klein <lsf@jflex.de>                          *
 * All rights reserved.                                                    *
 *                                                                         *
 * Thanks to Larry Bell and Bob Jamison for suggestions and comments.      *
 *                                                                         *
 * License: BSD                                                            *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

%%

%class Lexer
%byaccj

%{

  public Parser   yyparser;
  public int      lineno = 1;
  public String   curr = "";

  public Lexer(java.io.Reader r, Parser yyparser) {
    this(r);
    this.yyparser = yyparser;
    this.lineno   = 1;
  }

%}

int        = [0-9]+
float      = [0-9]+"."[0-9]+(E[+-]?[0-9]+)?
identifier = [a-zA-Z_][a-zA-Z0-9_]*
newline    = \n
whitespace = [ \t\r]+
comment    = "//".*

%%

"print"                             { yyparser.yylval = new ParserVal((Object)yytext()); return Parser.PRINT    ; }
"bool"                              { yyparser.yylval = new ParserVal((Object)yytext()); return Parser.BOOL     ; }
"int"                               { yyparser.yylval = new ParserVal((Object)yytext()); return Parser.INT      ; }
"float"                             { yyparser.yylval = new ParserVal((Object)yytext()); return Parser.FLOAT    ; }
"record"                            { yyparser.yylval = new ParserVal((Object)yytext()); return Parser.RECORD   ; }
"size"                              { yyparser.yylval = new ParserVal((Object)yytext());return Parser.SIZE     ; }
"new"                               { yyparser.yylval = new ParserVal((Object)yytext());return Parser.NEW      ; }
"while"                             { yyparser.yylval = new ParserVal((Object)yytext());return Parser.WHILE    ; }
"if"                                { yyparser.yylval = new ParserVal((Object)yytext());return Parser.IF       ; }
"else"                              { yyparser.yylval = new ParserVal((Object)yytext());return Parser.ELSE     ; }
"return"                            { yyparser.yylval = new ParserVal((Object)yytext());return Parser.RETURN   ; }
"break"                             { yyparser.yylval = new ParserVal((Object)yytext());return Parser.BREAK    ; }
"continue"                          { yyparser.yylval = new ParserVal((Object)yytext());return Parser.CONTINUE ; }
"and"                               { System.out.println("WE HIT ANDD");yyparser.yylval = new ParserVal((Object)yytext());return Parser.AND      ; }
"or"                                { yyparser.yylval = new ParserVal((Object)yytext());return Parser.OR       ; }
"not"                               { yyparser.yylval = new ParserVal("not"); return Parser.NOT      ; }
"&"                                 { yyparser.yylval = new ParserVal((Object)yytext());return Parser.ADDR     ; }
"{"                                 { yyparser.yylval = new ParserVal((Object)yytext());return Parser.LBRACE   ; }
"}"                                 { yyparser.yylval = new ParserVal((Object)yytext());return Parser.RBRACE   ; }
"("                                 { yyparser.yylval = new ParserVal((Object)yytext());return Parser.LPAREN   ; }
")"                                 { yyparser.yylval = new ParserVal((Object)yytext());return Parser.RPAREN   ; }
"["                                 { yyparser.yylval = new ParserVal((Object)yytext());return Parser.LBRACKET ; }
"]"                                 { yyparser.yylval = new ParserVal((Object)yytext());return Parser.RBRACKET ; }
"="                                 { yyparser.yylval = new ParserVal((Object)yytext());return Parser.ASSIGN   ; }
"<"                                 { yyparser.yylval = new ParserVal((Object)yytext());return Parser.GT       ; }
">"                                 { yyparser.yylval = new ParserVal((Object)yytext());return Parser.LT       ; }
"+"                                 { yyparser.yylval = new ParserVal((Object)yytext()); return Parser.PLUS     ; }
"-"                                 { yyparser.yylval = new ParserVal((Object)yytext()); return Parser.MINUS    ; }
"*"                                 { yyparser.yylval = new ParserVal((Object)yytext()); return Parser.MUL      ; }
"/"                                 { yyparser.yylval = new ParserVal((Object)yytext()); return Parser.DIV      ; }
"%"                                 { yyparser.yylval = new ParserVal((Object)yytext());return Parser.MOD      ; }
";"                                 { yyparser.yylval = new ParserVal((Object)yytext());return Parser.SEMI     ; }
","                                 { yyparser.yylval = new ParserVal((Object)yytext());return Parser.COMMA    ; }
"."                                 { yyparser.yylval = new ParserVal((Object)yytext());return Parser.DOT      ; }
"=="                                { yyparser.yylval = new ParserVal((Object)yytext());return Parser.EQ       ; }
"!="                                { yyparser.yylval = new ParserVal((Object)yytext());return Parser.NE       ; }
"<="                                { yyparser.yylval = new ParserVal((Object)yytext());return Parser.LE       ; }
">="                                { yyparser.yylval = new ParserVal((Object)yytext());return Parser.GE       ; }
"true"|"false"                      { yyparser.yylval = new ParserVal((Object)yytext()); return Parser.BOOL_LIT ; }
{int}                               { yyparser.yylval = new ParserVal(Integer.parseInt(yytext()));  return Parser.INT_LIT  ; }
{float}                             {  yyparser.yylval = new ParserVal(Float.parseFloat(yytext()));  return Parser.FLOAT_LIT; }
{identifier}                        { yyparser.yylval = new ParserVal((Object)yytext());  return Parser.IDENT    ; }
{comment}                           { /* skip */ }
{newline}                           { lineno++; }
{whitespace}                        {  }


\b     { System.err.println("Sorry, backspace doesn't work"); }

/* error fallback */
[^]    { System.err.println("Error: unexpected character '"+yytext()+"'"); return -1; }
