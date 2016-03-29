%{
  #include <stdio.h>
  #include <string.h>
  int lineCount = 1;
  char dataType[10] = "";
  char variable[50] = "";
  char value[50] = "";
  int initialize = 0;
  void printVariable() {
    if (initialize) {
      printf("#%d: (%s) %s = %s\n", lineCount, dataType, variable, value);
    } else {
      printf("#%d: (%s) %s\n", lineCount, dataType, variable);
    }
  }
%}

ANY .*
NEWLINE "\n"
BLOCK_COMMENT_START "/*"
BLOCK_COMMENT_END "*/"
ONELINE_COMMENT "//"
DATATYPE "int"|"double"|"char"
VARIABLE [a-zA-Z_][0-9a-zA-Z_]*
SPACE [ \r\t\f\v]
NUMBER [+-]?[0-9]+(\.[0-9]+)?
CHAR '.'

%x BLOCK_COMMENT
%x DECLARE

%%

{SPACE}* {}
{NEWLINE} { lineCount++; }

{BLOCK_COMMENT_START} { 
  printf("#%d: block comment start\n", lineCount);
  BEGIN BLOCK_COMMENT; 
}

<BLOCK_COMMENT>{
  {ANY}{BLOCK_COMMENT_END} { 
    printf("#%d: block comment end\n", lineCount);
    BEGIN 0; 
  }
  {ANY}
  {NEWLINE} { lineCount++; }
}

{ONELINE_COMMENT}{ANY} {
  printf("#%d: one line comment\n", lineCount);
}

{DATATYPE} {
  strcpy(dataType, yytext);
  BEGIN DECLARE;
}

<DECLARE>{
  {SPACE} {}
  {NEWLINE} { lineCount++; }
  {VARIABLE} {
    strcpy(variable, yytext);
  }
  "=" {
    initialize = 1;
  }
  "," {
    printVariable();
    initialize = 0;
  }
  ";" {
    printVariable();
    initialize = 0;
    BEGIN 0;
  }
  {NUMBER} {
    strcpy(value, yytext);
  }
  {CHAR} {
    strcpy(value, yytext);
  }
}

%%

int main() {
  yylex();
  return 0;
}

