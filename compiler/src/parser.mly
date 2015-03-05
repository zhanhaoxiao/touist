%{
  open Ast
%}

%token AND OR XOR IMPLIES EQUIV NOT
%token TOP BOTTOM
%token <string> TERM
%token <bool> BOOL
%token EQUAL NOTEQUAL LT GT LE GE
%token EMPTY IN SUBSET

%token <int> INT
%token <float> FLOAT
%token <string> VAR
%token <string> STRING
%token ADD SUB MUL DIV MOD SQRT
%token TOINT TOFLOAT

%token UNION INTER DIFF
%token RANGE DOT CARD

%token AFFECT IF THEN ELSE BIGAND BIGOR WHEN

%token BEGIN SETS FORMULA END DO EOF
%token LPAREN RPAREN LBRACK RBRACK COMMA

%start <Ast.prog> prog

%left IMPLIES EQUIV
%left OR
%left AND
%left XOR
%left NOT
%left ADD SUB
%left MUL DIV
%left MOD
%left LT GT LE GE
%left EQUAL NOTEQUAL

%nonassoc neg

%%

prog:
  | BEGIN SETS s = nonempty_list(affect) END SETS BEGIN FORMULA e = nonempty_list(exp) END FORMULA EOF { Begin (Some s, e) }
  | BEGIN FORMULA e = nonempty_list(exp) END FORMULA EOF { Begin (None, e) }

affect:
  | v = VAR AFFECT e = exp { Affect (v, e) }
  | v = VAR AFFECT s = set_exp DOT LPAREN e = exp RPAREN { Affect (v, Dot (s, e)) }

exp:
  | LPAREN e = exp RPAREN { e }
  | v = VAR        { Var       v }
  | s = set_exp    { SetExp    s }
  | i = int_exp    { IntExp    i }
  | f = float_exp  { FloatExp  f }
  | b = bool_exp   { BoolExp   b }
  | c = clause_exp { ClauseExp c }
  | IF b = bool_exp THEN e1 = exp ELSE e2 = exp END { If (b, e1, e2) }

int_exp:
  | v  = VAR { Var v }
  | i  = INT { Int i }
  | SUB i = int_exp { Neg i } %prec neg
  | i1 = int_exp ADD i2 = int_exp { Add (i1, i2) }
  | i1 = int_exp SUB i2 = int_exp { Sub (i1, i2) }
  | i1 = int_exp MUL i2 = int_exp { Mul (i1, i2) }
  | i1 = int_exp DIV i2 = int_exp { Div (i1, i2) }
  | i1 = int_exp MOD i2 = int_exp { Mod (i1, i2) }
  | TOINT LPAREN f = float_exp RPAREN { To_int f }
  | CARD  LPAREN s = set_exp   RPAREN { Card   s }

float_exp:
  | v  = VAR   { Var   v }
  | f  = FLOAT { Float f }
  | SUB f = float_exp { Neg f } %prec neg
  | f1 = float_exp ADD  f2 = float_exp { Add  (f1, f2) }
  | f1 = float_exp SUB  f2 = float_exp { Sub  (f1, f2) }
  | f1 = float_exp MUL  f2 = float_exp { Mul  (f1, f2) }
  | f1 = float_exp DIV  f2 = float_exp { Div  (f1, f2) }
  | SQRT    LPAREN f = float_exp RPAREN { Sqrt     f }
  | TOFLOAT LPAREN i = int_exp   RPAREN { To_float i }

bool_exp:
  | v = VAR  { Var  v }
  | b = BOOL { Bool b }
  | NOT b = bool_exp { Not b }
  | b1 = bool_exp AND     b2 = bool_exp { And     (b1, b2) }
  | b1 = bool_exp OR      b2 = bool_exp { Or      (b1, b2) }
  | b1 = bool_exp XOR     b2 = bool_exp { Xor     (b1, b2) }
  | b1 = bool_exp IMPLIES b2 = bool_exp { Implies (b1, b2) }
  | b1 = bool_exp EQUIV   b2 = bool_exp { Equiv   (b1, b2) }
  | i1 = int_exp EQUAL    i2 = int_exp { Equal            (i1, i2) }
  | i1 = int_exp NOTEQUAL i2 = int_exp { Not_equal        (i1, i2) }
  | i1 = int_exp LT       i2 = int_exp { Lesser_than      (i1, i2) }
  | i1 = int_exp LE       i2 = int_exp { Lesser_or_equal  (i1, i2) }
  | i1 = int_exp GT       i2 = int_exp { Greater_than     (i1, i2) }
  | i1 = int_exp GE       i2 = int_exp { Greater_or_equal (i1, i2) }
  | f1 = float_exp EQUAL    f2 = float_exp { FEqual            (f1, f2) }
  | f1 = float_exp NOTEQUAL f2 = float_exp { FNot_equal        (f1, f2) }
  | f1 = float_exp LT       f2 = float_exp { FLesser_than      (f1, f2) }
  | f1 = float_exp LE       f2 = float_exp { FLesser_or_equal  (f1, f2) }
  | f1 = float_exp GT       f2 = float_exp { FGreater_than     (f1, f2) }
  | f1 = float_exp GE       f2 = float_exp { FGreater_or_equal (f1, f2) }
  | s1 = set_exp EQUAL  s2 = set_exp { SEqual (s1, s2) }
  | e  = exp     IN     s  = set_exp { In     (e, s)   }
  | SUBSET LPAREN s1 = set_exp COMMA s2 = set_exp RPAREN { Subset (s1, s2) }
  | EMPTY LPAREN s = set_exp RPAREN { Empty s }

set_exp:
  | v  = VAR      { Var v }
  | s  = set_decl { Set s }
  | UNION LPAREN s1 = set_exp COMMA s2 = set_exp RPAREN { Union (s1, s2) }
  | INTER LPAREN s1 = set_exp COMMA s2 = set_exp RPAREN { Inter (s1, s2) }
  | DIFF  LPAREN s1 = set_exp COMMA s2 = set_exp RPAREN { Diff  (s1, s2) }
  | LBRACK i1 = int_exp RANGE i2 = int_exp RBRACK { Range (i1, i2) }

set_decl:
  | LBRACK i = separated_nonempty_list(COMMA, INT)    RBRACK { GenSet.IS (IntSet.of_list i)    }
  | LBRACK f = separated_nonempty_list(COMMA, FLOAT)  RBRACK { GenSet.FS (FloatSet.of_list f)  }
  | LBRACK s = separated_nonempty_list(COMMA, STRING) RBRACK { GenSet.SS (StringSet.of_list s) }

clause_exp:
  | TOP    { Top    }
  | BOTTOM { Bottom }
  | t = TERM { Term (t, None) }
  | t = TERM LPAREN opt = term_option RPAREN { Term (t, Some opt) }
  | NOT c = clause_exp { Not c }
  | c1 = clause_exp AND     c2 = clause_exp { And     (c1, c2) }
  | c1 = clause_exp OR      c2 = clause_exp { Or      (c1, c2) }
  | c1 = clause_exp XOR     c2 = clause_exp { Xor     (c1, c2) }
  | c1 = clause_exp IMPLIES c2 = clause_exp { Implies (c1, c2) }
  | c1 = clause_exp EQUIV   c2 = clause_exp { Equiv   (c1, c2) }
  | BIGAND v = STRING IN s = set_exp                   DO e = exp END { Bigand (v, s, None, e)   }
  | BIGAND v = STRING IN s = set_exp WHEN b = bool_exp DO e = exp END { Bigand (v, s, Some b, e) }
  | BIGOR  v = STRING IN s = set_exp                   DO e = exp END { Bigor  (v, s, None, e)   }
  | BIGOR  v = STRING IN s = set_exp WHEN b = bool_exp DO e = exp END { Bigor  (v, s, Some b, e) }

term_option:
  | i = int_exp { Num i }
  | s = STRING  { Str s }

