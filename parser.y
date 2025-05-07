%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>

void yyerror(const char* s);
int yylex(void);

void executeStatements(void);

#define MAX_VARS 100
#define MAX_EXEC_DEPTH 100

bool execStack[MAX_EXEC_DEPTH];
int  execTop = 0;

bool currentExec() {
    return execTop == 0 ? true : execStack[execTop-1];
}

void pushExec(bool cond) {
    bool parent = currentExec();
    execStack[execTop++] = parent && cond;
}

void popExec() {
    if(execTop > 0) execTop--;
}


typedef enum { TYPE_INT, TYPE_BOOL } VarType;

typedef struct {
    char* name;
    VarType type;
    union {
        int intValue;
        bool boolValue;
    } value;
} Variable;


Variable varTable[MAX_VARS];
int varCount = 0;

void setVariable(const char* name, int value, VarType type) {
    for (int i = 0; i < varCount; i++) {
        if (strcmp(varTable[i].name, name) == 0) {
            varTable[i].type = type;
            if (type == TYPE_INT)
                varTable[i].value.intValue = value;
            else
                varTable[i].value.boolValue = value;
            return;
        }
    }
    varTable[varCount].name = strdup(name);
    varTable[varCount].type = type;
    if (type == TYPE_INT)
        varTable[varCount].value.intValue = value;
    else
        varTable[varCount].value.boolValue = value;
    varCount++;
}


int getIntVariable(const char* name) {
    for (int i = 0; i < varCount; i++) {
        if (strcmp(varTable[i].name, name) == 0 && varTable[i].type == TYPE_INT)
            return varTable[i].value.intValue;
    }
    fprintf(stderr, "Neznámá proměnná nebo není typu int: %s\n", name);
    return 0;
}

bool getBoolVariable(const char* name) {
    for (int i = 0; i < varCount; i++) {
        if (strcmp(varTable[i].name, name) == 0 && varTable[i].type == TYPE_BOOL)
            return varTable[i].value.boolValue;
    }
    fprintf(stderr, "Neznámá proměnná nebo není typu bool: %s\n", name);
    return false;
}

%}

%union {
    int intVal;
    int booleanVal;
    char* strVal;
    char charVal;
}

%token <intVal> INT
%token <booleanVal> BOOLEAN
%token <strVal> STRING
%token <charVal> CHAR
%token <strVal> ID

%token KW_INT      /* kolikmamjestelet */
%token KW_BOOLEAN  /* jetoparada */
%token KW_IF       /* kdovijestli */
%token KW_ELSE  /* Přidej toto pro klíčové slovo 'else' */
%token KW_WHILE    /* bezdal */
%token KW_PRINT    /* tisk */

%token ASSIGN LPAREN RPAREN LBRACE RBRACE SEMI

/* Relační operátory */
%token EQ  /* == */
%token LT  /* <  */
%token GT  /* >  */
%token LE  /* <= */
%token GE  /* >= */
%token NEQ /* != */

%debug


%token ADD SUB MUL DIV NEGATE ROUND AND OR NOT

%type <intVal> expression term factor hexExpression

%left OR
%left AND
%left EQ NEQ
%left LT LE GT GE
%left ADD SUB
%left MUL DIV
%right NEGATE ROUND

%%

program:
    statements
    ;

statements:
    | statements statement
    ;

statement:
      varDecl SEMI
    | printStatement SEMI
    | ifStatement
    | whileStatement
    | ID ASSIGN expression SEMI {
    if (currentExec()) {
        for (int i = 0; i < varCount; i++) {
            if (strcmp(varTable[i].name, $1) == 0) {
                setVariable($1, $3, varTable[i].type);
                break;
            }
        }
    }
}


    ;

varDecl:
     KW_INT ID ASSIGN expression {
        if (currentExec()) {
            setVariable($2, $4, TYPE_INT);
            printf("Deklarace: int %s = %d\n", $2, $4);
        }
    }

    | KW_BOOLEAN ID ASSIGN expression {
        if (currentExec()) {
            setVariable($2, $4, TYPE_BOOL);
            printf("Deklarace: bool %s = %s\n", $2, $4 ? "true" : "false");
        }
    }
    ;



    | KW_BOOLEAN ID ASSIGN BOOLEAN {
    if (currentExec()) {
        setVariable($2, $4, TYPE_BOOL);
        printf("Deklarace: bool %s = %s\n", $2, $4 ? "true" : "false");
    }
}

    ;

printStatement:
    KW_PRINT STRING {
    if (currentExec()) {
        printf("Tisk: %s\n", $2);
        free($2);
    }
}

  | KW_PRINT ID {
    for (int i = 0; i < varCount; i++) {
        if (strcmp(varTable[i].name, $2) == 0) {
            if (varTable[i].type == TYPE_INT)
                printf("Tisk: %d\n", varTable[i].value.intValue);
            else
                printf("Tisk: %s\n", varTable[i].value.boolValue ? "true" : "false");
            break;
        }
    }
}


    ;


ifStatement:
    KW_IF LPAREN expression RPAREN {
        pushExec($3);
    }
    LBRACE
        statements
    RBRACE {
        bool thenExecuted = currentExec();
        popExec();

        pushExec(!thenExecuted);
    }
    elseClause
    {
        popExec();
    }
    ;

elseClause:
    | KW_ELSE LBRACE statements RBRACE
    ;


whileStatement:
    KW_WHILE LPAREN expression RPAREN LBRACE statements RBRACE {
        while ($3) {
            executeStatements();
            $3 = getIntVariable("vek") < 50;

        }
    }


expression:
      term { printf("Expresion: term = %d\n", $1); }
    | expression ADD term { $$ = $1 + $3; printf("Expresion: ADD %d + %d = %d\n", $1, $3, $$); }
    | expression SUB term { $$ = $1 - $3; printf("Expresion: SUB %d - %d = %d\n", $1, $3, $$); }
    | expression AND term { $$ = $1 && $3; printf("Expresion: AND %d && %d = %d\n", $1, $3, $$); }
    | expression OR  term { $$ = $1 || $3; printf("Expresion: OR %d || %d = %d\n", $1, $3, $$); }
    | expression EQ  term { $$ = $1 == $3; printf("Expresion: EQ %d == %d = %d\n", $1, $3, $$); }
    | expression NEQ term { $$ = $1 != $3; printf("Expresion: NEQ %d != %d = %d\n", $1, $3, $$); }
    | expression LT  term { $$ = $1 <  $3; printf("Expresion: LT %d < %d = %d\n", $1, $3, $$); }
    | expression LE  term { $$ = $1 <= $3; printf("Expresion: LE %d <= %d = %d\n", $1, $3, $$); }
    | expression GT  term { $$ = $1 >  $3; printf("Expresion: GT %d > %d = %d\n", $1, $3, $$); }
    | expression GE  term { $$ = $1 >= $3; printf("Expresion: GE %d >= %d = %d\n", $1, $3, $$); }
    | NOT factor             { $$ = !$2; printf("Expression: NOT !%d = %d\n", $2, $$); }


    ;


term:
    factor
    | term MUL factor       { $$ = $1 * $3; }
    | term DIV factor       {
        if ($3 == 0) {
            yyerror("Dělení nulou!");
            YYABORT;
        } else {
            $$ = $1 / $3;
        }
    }
    ;

factor:
      INT                    { $$ = $1; }
    | STRING                 { $$ = 0; }
    | CHAR                   { $$ = $1; }
    | BOOLEAN                { $$ = $1; }
  | ID {
        int found = 0;
        for (int i = 0; i < varCount; i++) {
            if (strcmp(varTable[i].name, $1) == 0) {
                if (varTable[i].type == TYPE_INT)
                    $$ = varTable[i].value.intValue;
                else
                    $$ = varTable[i].value.boolValue ? 1 : 0;
                found = 1;
                break;
            }
        }
        if (!found) {
            fprintf(stderr, "Neznámá proměnná: %s\n", $1);
            $$ = 0;
        }
    }


    | LPAREN expression RPAREN { $$ = $2; }
    | NEGATE factor          { $$ = -$2; }
    | ROUND factor           { $$ = (int)round((double)$2); }
    | NOT factor             { $$ = !$2; printf("Expression: NOT !%d = %d\n", $2, $$); }



    ;

hexExpression:
    INT { $$ = $1; }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Chyba syntaxe: %s\n", s);
}

void executeStatements() {
    printf("Tisk: Aktuální věk:\n");
    printf("Tisk: %d\n", getIntVariable("vek"));
    setVariable("vek", getIntVariable("vek") + 1, TYPE_INT);

}


int main(void){
    execTop = 0;
    printf("Zadej program:\n");
    if(yyparse()==0)
        printf("Parsing was successful!\n");
    return 0;
}