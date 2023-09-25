parser grammar command_parser;

@header {
package com.parser.command;
}

options{tokenVocab=command_lexer;}

command:(command_list)+ EOF;

command_list:(SPACE)* (settime|timescale|setlevel|giveitem|kill|paramsetting|function|invincible|summon|exit) (SPACE)* (SEMICOLON)?;

coord_type:(ABSOLUTE|RELATIVE);

settime:TIME SPACE setparamtype SPACE NUM (BOOL)?;

timescale:TIMESCALE SPACE SET SPACE NUM;

setlevel:LEVEL SPACE (STRING|PLAYER) SPACE setparamtype SPACE NUM;

giveitem:GIVE SPACE STRING (SPACE OPTIONAL STRING)*;

setparamtype:ADD|SUB|SET;

kill:KILL SPACE (STRING|PLAYER);

paramsetting:PARAM SPACE param_name SPACE setparamtype SPACE NUM;

param_name:(PROJECTILE|SCALE|POWER|SPEED|DURATION|COOLTIME);

function:FUNCTION SPACE STRING;

invincible:INVINCIBLE SPACE BOOL;

summon:SUMMON SPACE STRING SPACE FLOAT SPACE FLOAT (SPACE OPTIONAL coord_type)*;

exit:EXIT;