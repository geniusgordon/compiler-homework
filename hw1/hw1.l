%{
  #include <stdio.h>
  #include <string.h>
  int lineCount = 1;
  void print(char* tokenType) {
    printf("%s(%s) ", yytext, tokenType);
  }
  void newLine() {
    lineCount++;
    printf("\n#%d: ", lineCount);
  }
%}

ANY .*
SEMICOLON ";"
NEWLINE "\n"

INCLUDE "#include"

BLOCK_COMMENT_START "/*"
BLOCK_COMMENT_END "*/"
ONELINE_COMMENT "//"

DATATYPE int|double|char
VOID void

NAME [a-zA-Z_][0-9a-zA-Z_]*
SPACE [ \r\t\f\v]
NUMBER [+\-]?[0-9]+(\.[0-9]+)?
CHAR '.'
STRING \".*\"

ARITHMETIC [+\-*/]|"%"|"++"|"--"
RELATIONAL "=="|"!="|">"|"<"|">="|"<="
LOGICAL "&&"|"||"|"!"
BITWISE [&|^~]|">>"|"<<"
ASSIGNMENT ([+\-*/&^|]|">>"|"<<")?=

%x HEADER
%x BLOCK_COMMENT

%%

{SPACE}* {}
{SEMICOLON} {}
[({})] {}
, {}
{NEWLINE} { newLine(); }

{INCLUDE} { BEGIN HEADER; }

<HEADER>{
  {SPACE} {}
  ["<]{NAME}\.h[">] {
    print("header");
    BEGIN 0;
  }
}

{BLOCK_COMMENT_START} { 
  print("comment");
  BEGIN BLOCK_COMMENT; 
}

<BLOCK_COMMENT>{
  {BLOCK_COMMENT_END} {
    printf("*/");
    BEGIN 0;
  }
  .
  {NEWLINE} {
    newLine();
    printf("(comment)");
  }
}

{ONELINE_COMMENT}{ANY} {
  printf("//(comment)");
}

return { print("keyword"); }
if/{SPACE}*\( { print("keyword"); }
else { print("keyword"); } 
for/{SPACE}*\( { print("keyword"); } 
while/{SPACE}*\( { print("keyword"); } 

{DATATYPE} { print("datatype"); }
{VOID} { print("void"); }

{NAME}/{SPACE}*\( { print("function"); }
{NAME} { print("variable"); }
{NUMBER} { print("number"); }
{CHAR} { print("character"); }
{STRING} { print("string"); }

{ARITHMETIC}|{RELATIONAL}|{LOGICAL}|{BITWISE} { print("operator"); }
{ASSIGNMENT} { print("assignment"); }

%%

int main() {
  printf("#1: ");
  yylex();
  return 0;
}

