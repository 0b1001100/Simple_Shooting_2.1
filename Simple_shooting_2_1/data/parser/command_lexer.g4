parser grammar command_lexer;

SPACE:' '->skip;

NUM:[0-9]+;

FLOAT:(Digits '.' Digits? | '.' Digits);

STRING:'"'(EscapeSequence)*'"';

BOOL:'true'|'false';

ADD:'add';

SUB:'sub';

SET:'set';

TIME:'time';

LEVEL:'level';

EXIT:'exit';

fragment Digits:[0-9] ([0-9_]* [0-9])?;

fragment EscapeSequence:'\\'[btnfr"'\\]|'\\'([0-3]? [0-7])? [0-7]|'\\''u'+ HexDigit HexDigit HexDigit HexDigit;

fragment HexDigit:[0-9a-fA-F];