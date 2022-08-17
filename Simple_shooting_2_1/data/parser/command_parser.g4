parser grammar command_parser;

options{tokenVocab=command_lexer;}

commandfrag:(settime';'|setlevel';'|exit';')*;

settime:TIME SET NUM|TIME ADD NUM|TIME SUB NUM;

setlevel:LEVEL SET NUM (BOOL)|LEVEL ADD NUM (BOOL)|LEVEL SUB NUM (BOOL);

exit:EXIT;