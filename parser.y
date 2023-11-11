%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

extern int yylex();
extern void yyerror(const char *s);
extern FILE *yyin;

int yylineno;

char* generateASTJson(const char* left, const char* right, const char* operator) {
    char* json;
    asprintf(&json, "{\"type\":\"%s\", \"left\":%s, \"right\":%s}", operator, left ? left : "null", right ? right : "null");
    return json;
}

%}

%token PLUS MINUS TIMES DIVIDE POWER LPAREN RPAREN EOL

%left PLUS MINUS
%left TIMES DIVIDE
%right POWER
%nonassoc UMINUS

%union {
    struct {
        double val; // Числове значення для обчислення
        char* str;  // Строка для генерації коду
        char* ast;  // JSON представлення AST
    } num;
}

%type <num> expression
%token <num> NUMBER

%%

calculations:
    | calculations expression EOL {
        printf("Python expression: %s\n", $2.str);
        printf("Result: %f\n", $2.val);
        printf("AST: %s\n", $2.ast);
        free($2.str);
        free($2.ast);
    }
;


expression:
    expression PLUS expression {
        $$.ast = generateASTJson($1.ast, $3.ast, "plus");
        asprintf(&$$.str, "(%s + %s)", $1.str, $3.str);
        $$.val = $1.val + $3.val;
        free($1.str); free($3.str);
        free($1.ast); free($3.ast);
    }
  | expression MINUS expression {
        $$.ast = generateASTJson($1.ast, $3.ast, "minus");
        asprintf(&$$.str, "(%s - %s)", $1.str, $3.str);
        $$.val = $1.val - $3.val;
        free($1.str); free($3.str);
        free($1.ast); free($3.ast);
    }
  | expression TIMES expression {
        $$.ast = generateASTJson($1.ast, $3.ast, "times");
        asprintf(&$$.str, "(%s * %s)", $1.str, $3.str);
        $$.val = $1.val * $3.val;
        free($1.str); free($3.str);
        free($1.ast); free($3.ast);
    }
  | expression DIVIDE expression {
        $$.ast = generateASTJson($1.ast, $3.ast, "divide");
        asprintf(&$$.str, "(%s / %s)", $1.str, $3.str);
        $$.val = $1.val / $3.val;
        free($1.str); free($3.str);
        free($1.ast); free($3.ast);
    }
  | expression POWER expression {
        $$.ast = generateASTJson($1.ast, $3.ast, "power");
        asprintf(&$$.str, "pow(%s, %s)", $1.str, $3.str);
        $$.val = pow($1.val, $3.val);
        free($1.str); free($3.str);
        free($1.ast); free($3.ast);
    }
  | LPAREN expression RPAREN {
        $$.ast = strdup($2.ast);
        asprintf(&$$.str, "(%s)", $2.str);
        $$.val = $2.val;
        free($2.str);
        free($2.ast);
    }
  | MINUS expression %prec UMINUS {
        $$.ast = generateASTJson(NULL, $2.ast, "negate");
        asprintf(&$$.str, "(-%s)", $2.str);
        $$.val = -$2.val;
        free($2.str);
        free($2.ast);
    }
  | NUMBER {
        $$.ast = strdup($1.ast); // JSON вже сформований у лексері
        $$.str = strdup($1.str); // Значення вже у текстовому форматі
        $$.val = $1.val;         // Числове значення
    }
  ;


%%

void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
}

int main(void) {
    yyin = fopen("input.txt", "r");
    if (!yyin) yyin = stdin;

    yyparse();

    fclose(yyin);
    return 0;
}