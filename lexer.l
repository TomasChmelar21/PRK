%option noyywrap

%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
%}

DIGIT       [0-9]
LETTER      [a-zA-Z_]
ID_PAT      {LETTER}({LETTER}|{DIGIT})*
HEX_PAT     0x[0-9a-fA-F]+
NUM_PAT     {DIGIT}+
STR_PAT     \"([^\\\"]|\\.)*\"

%%

"kolikmamjestelet"    { return KW_INT; }
"jetoparada"          { return KW_BOOLEAN; }
"kdovijestli"         { return KW_IF; }
"tisk"                { return KW_PRINT; }

"true"|"false"        {
                        yylval.booleanVal = (strcmp(yytext,"true")==0);
                        return BOOLEAN;
                      }

{HEX_PAT}             {
                        yylval.intVal = strtol(yytext,NULL,16);
                        return INT;
                      }
{NUM_PAT}             {
                        yylval.intVal = atoi(yytext);
                        return INT;
                      }

{STR_PAT}             {
                        /* odstraníme uvozovky */
                        char *p = strdup(yytext);
                        p[strlen(p)-1]=0; memmove(p,p+1,strlen(p));
                        yylval.strVal = p;
                        return STRING;
                      }

"=="                  { return EQ; }
"!="                  { return NEQ; }
"<="                  { return LE; }
">="                  { return GE; }
"<"                   { return LT; }
">"                   { return GT; }

"="                   { return ASSIGN; }
";"                   { return SEMI; }
"\("                  { return LPAREN; }
"\)"                  { return RPAREN; }
"\{"                  { return LBRACE; }
"\}"                  { return RBRACE; }

"+"                   { return ADD; }
"-"                   { return SUB; }
"*"                   { return MUL; }
"/"                   { return DIV; }

"nenene"              { return NOT; }

"blizkonas"           { return ROUND; }

"spolu"               { return AND; }
"janeboty"            { return OR; }
"jsempozitivni"     { return NOT; }


"bezdal"              { printf("LEXER: Vracím KW_WHILE\n"); return KW_WHILE; }
"jinak"        { return KW_ELSE; }  // Přidání tokenu pro ELSE

{ID_PAT}              { printf("LEXER: Vracím ID: %s\n", yytext); yylval.strVal = strdup(yytext); return ID; }

[ \t\r\n]+            { /* ignoruj */ }
.                     { printf("Neznámý znak: %s\n", yytext); }

%%