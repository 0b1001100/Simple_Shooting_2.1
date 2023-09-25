lexer grammar command_lexer;

@header {
package com.parser.command;
}

SPACE:' '+;

NUM:[0-9]+;

FLOAT:(Digits '.' Digits? | '.' Digits);

STRING:'"'(~["\\\r\n]|EscapeSequence)*'"';

PLAYER:'@p';

BOOL:'true'|'false';

ADD:'add';

SUB:'sub';

SET:'set';

TIME:'time';

TIMESCALE:'timescale';

LEVEL:'level';

GIVE:'give';

KILL:'kill';

WEAPON:'weapon';

FUNCTION:'function';

EXIT:'exit';

OPTIONAL:'--';

SEMICOLON:';';

PARAM:'parameter';

PROJECTILE:'projectile';

SCALE:'scale';

POWER:'power';

SPEED:'speed';

DURATION:'duration';

COOLTIME:'cooltime';

INVINCIBLE:'invincible';

SUMMON:'summon';

ABSOLUTE:'absolute';

RELATIVE:'relative';

fragment Digits:[0-9] ([0-9_]* [0-9])?;

fragment EscapeSequence:'\\'[btnfr"'\\]|'\\'([0-3]? [0-7])? [0-7]|'\\''u'+ HexDigit HexDigit HexDigit HexDigit;

fragment HexDigit:[0-9a-fA-F];

ErrorChar:.;