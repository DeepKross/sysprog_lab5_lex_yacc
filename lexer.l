%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%%

[0-9]+(\.[0-9]+)? {
    yylval.num.str = strdup(yytext);
    asprintf(&yylval.num.ast, "{\"type\":\"number\", \"value\":%s}", yytext);
    yylval.num.val = atof(yytext);
    return NUMBER;
}


"-"                   { return MINUS; }
"+"                   { return PLUS; }
"*"                   { return TIMES; }
"/"                   { return DIVIDE; }
"^"                   { return POWER; }
"("                   { return LPAREN; }
")"                   { return RPAREN; }
"\n"                  { return EOL; } // Додано правило для кінця рядка

[ \t\n]+              /* ignore white space */;
.                     { printf("Unexpected character: %s\n", yytext); }

%%

int yywrap(void) { return 1; }