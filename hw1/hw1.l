%{
  #include <stdio.h>
  int lineCount = 1;
%}

ANY .*
NEWLINE "\n"
BLOCK_COMMENT_START "/*"
BLOCK_COMMENT_END "*/"
ONELINE_COMMENT "//"

%x BLOCK_COMMENT

%%

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

%%

int main() {
  yylex();
  return 0;
}

