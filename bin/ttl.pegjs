{
  var flattenString = function(arrs) {
    var acum ="";
    for(var i=0; i< arrs.length; i++) {
      if(typeof(arrs[i])==='string') {
        acum = acum + arrs[i];
      } else {
        acum = acum + arrs[i].join('');
      }
    }

    return acum;
  }
}

// Turtle Grammer
// ref. https://www.w3.org/TR/turtle/#sec-grammar-grammar

// [1]	turtleDoc	::=	statement*
turtleDoc = statement*

// [2]	statement	::=	directive | triples '.'
statement = d:directive WS*
{
  return d;
}
/ t:triples '.' WS*
{
  return t;
}

// [3]	directive	::=	prefixID | base | sparqlPrefix | sparqlBase
directive = prefix / base / sparqlPrefix / sparqlBase

// [4]	prefixID	::=	'@prefix' PNAME_NS IRIREF '.'
prefix = '@prefix' WS* p:PNAME_NS WS* i:IRIREF WS* '.'
{
  return {prefix:p, iri:i};
}

// [5]	base	::=	'@base' IRIREF '.'
base = '@base' WS* i:IRIREF '.'
{
  return {base:'@base', iri:i};
}

// [5s]	sparqlBase	::=	"BASE" IRIREF
sparqlBase = 'BASE' WS* i:IRIREF
{
  return {base:'BASE', iri:i};
}

// [6s]	sparqlPrefix	::=	"PREFIX" PNAME_NS IRIREF
sparqlPrefix = 'PREFIX' p:PNAME_NS i:IRIREF
{
  return {PREFIX:p, iri:i};
}

// [6]	triples	::=	subject predicateObjectList | blankNodePropertyList predicateObjectList?
triples = s:subject po:predicateObjectList WS*
{
  return {
    subj: s,
    po: po
  }
}
/ blankNodePropertyList predicateObjectList?

// [7]	predicateObjectList	::=	verb objectList (';' (verb objectList)?)*
predicateObjectList = WS* p:verb os:objectList pos:followingPredicateObjects* WS*
{
  return [ {p:p, os:os} ].concat(pos);
}

followingPredicateObjects = WS* ';' WS* p:verb os:objectList
{
  return {p:p, os:os};
}

// [8]	objectList	::=	object (',' object)*
// objectList = WS* o1:object WS* o2:(',' WS* object)* WS*
objectList = WS* o:object os:followingObject*
{
  return [o].concat(os);
}

followingObject = WS* ',' WS* o:object
{
  return o;
}

// [9]	verb	::=	predicate | 'a'
verb = predicate / 'a'

// [10]	subject	::=	iri | BlankNode | collection
subject = iri / BlankNode / collection

//[11]	predicate	::=	iri
predicate = iri

// [12]	object	::=	iri | BlankNode | collection | blankNodePropertyList | literal
// object = iri / blankNode / collection / blankNodePropertyList / Literal
object = iri / literal

// [13]	literal	::=	RDFLiteral | NumericLiteral | BooleanLiteral
literal = RDFLiteral / NumericLiteral / BooleanLiteral

// [14]	blankNodePropertyList	::=	'[' predicateObjectList ']'
blankNodePropertyList = '[' predicateObjectList ']'

// [15]	collection	::=	'(' object* ')'
collection = '(' object* ')'

// [16]	NumericLiteral	::=	INTEGER | DECIMAL | DOUBLE
NumericLiteral = INTEGER / DECIMAL / DOUBLE

// [17]	String	::=	STRING_LITERAL_QUOTE | STRING_LITERAL_SINGLE_QUOTE | STRING_LITERAL_LONG_SINGLE_QUOTE | STRING_LITERAL_LONG_QUOTE
String = STRING_LITERAL_QUOTE
/ STRING_LITERAL_SINGLE_QUOTE
/ STRING_LITERAL_LONG_SINGLE_QUOTE
/ STRING_LITERAL_LONG_QUOTE

// [18]	IRIREF	::=	'<' ([^#x00-#x20<>"{}|^`\] | UCHAR)* '>'
// #x00=NULL #01-#x1F=control codes #x20=space
// IRIREF = '<' iriref:([^\u0000-\u0020<>\"\{\}|^`\] / UCHAR)* '>'
// { return return iri_ref.join('') }
IRIREF = '<' iri_ref:[^<>\"\{\}|^`\\]* '>'
{ return iri_ref.join('') }

// [19]	INTEGER	::=	[+-]? [0-9]+
INTEGER = [+-]? [0-9]+

// [20]	DECIMAL	::=	[+-]? [0-9]* '.' [0-9]+
DECIMAL = [+-]? [0-9]* '.' [0-9]+

// [21]	DOUBLE	::=	[+-]? ([0-9]+ '.' [0-9]* EXPONENT | '.' [0-9]+ EXPONENT | [0-9]+ EXPONENT)
DOUBLE = [+-]? ([0-9]+ '.' [0-9]* EXPONENT / '.' [0-9]+ EXPONENT / [0-9]+ EXPONENT)

// [22]	STRING_LITERAL_QUOTE	::=	'"' ([^#x22#x5C#xA#xD] | ECHAR | UCHAR)* '"'
// #x22=" #x5C=\ #xA=new line #xD=carriage return
// STRING_LITERAL_QUOTE = '"' content:([^\u0022\u005C\u000A\u000D] / ECHAR / UCHAR)* '"'
// { return flattenString(content) }
STRING_LITERAL_QUOTE = '"' content:([^\u0022\u005C\u000A\u000D] / ECHAR)* '"'
{ return flattenString(content) }

// [23]	STRING_LITERAL_SINGLE_QUOTE	::=	"'" ([^#x27#x5C#xA#xD] | ECHAR | UCHAR)* "'"
// #x27=' #x5C=\ #xA=new line #xD=carriage return
// STRING_LITERAL_SINGLE_QUOTE = "'" content:([^\u0027\u0005C\u000A\u000D] / ECHAR / UCHAR)* "'"
// { return flattenString(content) }
STRING_LITERAL_SINGLE_QUOTE = "'" content:([^\u0027\u005C\u000A\u000D] / ECHAR)* "'"
{ return flattenString(content) }

// [24]	STRING_LITERAL_LONG_SINGLE_QUOTE	::=	"'''" (("'" | "''")? ([^'\] | ECHAR | UCHAR))* "'''"
// STRING_LITERAL_LONG_SINGLE_QUOTE = "'''" content:(("'" / "''")? ([^'\] / ECHAR / UCHAR))* "'''"
// { return flattenString(content) }
STRING_LITERAL_LONG_SINGLE_QUOTE = "'''" content:([^\'\\] / ECHAR)* "'''"
{ return flattenString(content) }

// [25]	STRING_LITERAL_LONG_QUOTE	::=	'"""' (('"' | '""')? ([^"\] | ECHAR | UCHAR))* '"""'
// STRING_LITERAL_LONG_QUOTE = '"""' content:(('"' / '""')? ([^"\] / ECHAR / UCHAR))* '"""'
// { return flattenString(content) }
STRING_LITERAL_LONG_QUOTE = '"""' content:([^\"\\] / ECHAR)* '"""'
{ return flattenString(content) }

// [26]	UCHAR	::=	'\u' HEX HEX HEX HEX | '\U' HEX HEX HEX HEX HEX HEX HEX HEX
// UCHAR = '\u' HEX HEX HEX HEX / '\U' HEX HEX HEX HEX HEX HEX HEX HEX

// [128s]	RDFLiteral	::=	String (LANGTAG | '^^' iri)?
RDFLiteral = s:String e:(LANGTAG / '^^' iri)?
{
  if(typeof(e) === "string" && e.length > 0) {
    return {token:'literal', value:s.value, lang:e.slice(1), type:null}
  } else {
    if(e != null && typeof(e) === "object") {
      e.shift(); // remove the '^^' char
      return {token:'literal', value:s.value, lang:null, type:e[0]}
    } else {
      return { token:'literal', value:s.value, lang:null, type:null}
    }
  }
}

// [133s]	BooleanLiteral	::=	'true' | 'false'
BooleanLiteral = 'true'
{
  var lit = {};
  lit.token = "literal";
  lit.lang = null;
  lit.type = "http://www.w3.org/2001/XMLSchema#boolean";
  lit.value = true;
  return lit;
}
/ 'false'
{
  var lit = {};
  lit.token = "literal";
  lit.lang = null;
  lit.type = "http://www.w3.org/2001/XMLSchema#boolean";
  lit.value = false;
  return lit;
}

// [135s]	iri	::=	IRIREF | PrefixedName
iri = iri:IRIREF
{
  return {token: 'uri', prefix:null, suffix:null, value:iri}
}
/ p:PrefixedName
{
  return p
}

// [136s]	PrefixedName	::=	PNAME_LN | PNAME_NS
PrefixedName = PNAME_LN / PNAME_NS

// [137s]	BlankNode	::=	BLANK_NODE_LABEL | ANON
BlankNode = BLANK_NODE_LABEL / ANON

// [139s]	PNAME_NS	::=	PN_PREFIX? ':'
// PNAME_NS = p:PN_PREFIX? ':'
PNAME_NS = p:[a-z]* ':'
{
  return p.join('')
}

// [140s]	PNAME_LN	::=	PNAME_NS PN_LOCAL
PNAME_LN = p:PNAME_NS s:PN_LOCAL
{
  // return [p, s]
  return text();
}

// [141s]	BLANK_NODE_LABEL	::=	'_:' (PN_CHARS_U | [0-9]) ((PN_CHARS | '.')* PN_CHARS)?
// BLANK_NODE_LABEL = '_:' (PN_CHARS_U / [0-9]) ((PN_CHARS / '.')* PN_CHARS)?
BLANK_NODE_LABEL = '_:' l:PN_LOCAL 
{
  return l
}

// [144s]	LANGTAG	::=	'@' [a-zA-Z]+ ('-' [a-zA-Z0-9]+)*
LANGTAG = '@' a:[a-zA-Z]+ b:('-' [a-zA-Z0-9]+)*
{
  if(b.length===0) {
    return ("@"+a.join('')).toLowerCase();
  } else {
    return ("@"+a.join('')+"-"+b[0][1].join('')).toLowerCase();
  }
}

// [154s]	EXPONENT	::=	[eE] [+-]? [0-9]+
EXPONENT = a:[eE] b:[+-]? c:[0-9]+
{ return flattenString([a,b,c]) }

// [159s]	ECHAR	::=	'\' [tbnrf"'\]
ECHAR = '\\' [tbnrf\"\']

// [161s]	WS	::=	#x20 | #x9 | #xD | #xA
// #x20=space #x9=character tabulation #xD=carriage return #xA=new line
WS = [\u0020\u0009\u000D\u000A]

// [162s]	ANON	::=	'[' WS* ']'
ANON = '[' WS* ']'

// [163s]	PN_CHARS_BASE	::=	[A-Z] | [a-z] | [#x00C0-#x00D6] | [#x00D8-#x00F6] | [#x00F8-#x02FF] | [#x0370-#x037D] | [#x037F-#x1FFF] | [#x200C-#x200D] | [#x2070-#x218F] | [#x2C00-#x2FEF] | [#x3001-#xD7FF] | [#xF900-#xFDCF] | [#xFDF0-#xFFFD] | [#x10000-#xEFFFF]
PN_CHARS_BASE = [A-Z] / [a-z] / [\u00C0-\u00D6] / [\u00D8-\u00F6] / [\u00F8-\u02FF] / [\u0370-\u037D] / [\u037F-\u1FFF] / [\u200C-\u200D] / [\u2070-\u218F] / [\u2C00-\u2FEF] / [\u3001-\uD7FF] / [\uF900-\uFDCF] / [\uFDF0-\uFFFD] / [\u10000-\uEFFFF]

// [164s]	PN_CHARS_U	::=	PN_CHARS_BASE | '_'
PN_CHARS_U = PN_CHARS_BASE / '_'

// [166s]	PN_CHARS	::=	PN_CHARS_U | '-' | [0-9] | #x00B7 | [#x0300-#x036F] | [#x203F-#x2040]
PN_CHARS = PN_CHARS_U / '-' / [0-9] / [\u00B7] / [\u0300-\u036F] / [\u203F-\u2040]

// [167s]	PN_PREFIX	::=	PN_CHARS_BASE ((PN_CHARS | '.')* PN_CHARS)?
PN_PREFIX = base:PN_CHARS_BASE rest:((PN_CHARS / '.')* PN_CHARS)?
// { 
//   if(rest[rest.length-1] == '.'){
//     throw new Error("Wrong PN_PREFIX, cannot finish with '.'")
//   } else {
//     return base + rest.join('');
//   }
// }

// [168s]	PN_LOCAL	::=	(PN_CHARS_U | ':' | [0-9] | PLX) ((PN_CHARS | '.' | ':' | PLX)* (PN_CHARS | ':' | PLX))?
// PN_LOCAL = base:(PN_CHARS_U / ':' / [0-9] / PLX) rest:((PN_CHARS / '.' / ':' / PLX)* (PN_CHARS / ':' / PLX))?
// {
//   return base + (rest||[]).join('');
// }
PN_LOCAL = l:[_a-zA-Z0-9]+
{
  return l.join('');
}

// [169s]	PLX	::=	PERCENT | PN_LOCAL_ESC
PLX = PERCENT / PN_LOCAL_ESC

// [170s]	PERCENT	::=	'%' HEX HEX
PERCENT = h:('%' HEX HEX)
{
  return h.join('');
}

// [171s]	HEX	::=	[0-9] | [A-F] | [a-f]
HEX = [0-9] / [A-F] / [a-f]

// [172s]	PN_LOCAL_ESC	::=	'\' ('_' | '~' | '.' | '-' | '!' | '$' | '&' | "'" | '(' | ')' | '*' | '+' | ',' | ';' | '=' | '/' | '?' | '#' | '@' | '%')
PN_LOCAL_ESC = '\\' c:('_' / '~' / '.' / '-' / '!' / '$' / '&' / "'" / '(' / ')' / '*' / '+' / ',' / ';' / '=' / '/' / '?' / '#' / '@' / '%')
{
  return '//' + c;
}
