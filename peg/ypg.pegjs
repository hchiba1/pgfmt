{
  let nodeCount = 0;
  let edgeCount = 0;
  let nodeLabelHash = {};
  let edgeLabelHash = {};
  let nodePropHash = {};
  let edgePropHash = {};
}

PG = lines:NodeOrEdge* CommentLine*
{
  return {
    nodes: lines.map(l => l.node).filter(v => v),
    edges: lines.map(l => l.edge).filter(v => v),
    nodeCount: nodeCount,
    edgeCount: edgeCount,
    nodeLabels: nodeLabelHash,
    edgeLabels: edgeLabelHash,
    nodeProperties: nodePropHash,
    edgeProperties: edgePropHash
    // nodeProperties: Object.keys(nodePropHash),
    // edgeProperties: Object.keys(edgePropHash)
  }
}

NodeOrEdge = n:Node
{
  return {
    node: n
  }
}
/ e:Edge
{
  return {
    edge: e
  }
}

Node = CommentLine* WS* id:Value '[' l:Label* ']:{' p:Property* '}' InlineComment? EndOfLine
{
  let propObj = {};
  p.forEach(prop => {
    if (propObj[prop.key]) {
      propObj[prop.key].push(prop.value);
    } else {
      propObj[prop.key] = [prop.value];
    }
    // nodePropHash[prop.key] = true;
    if (nodePropHash[prop.key]) {
      nodePropHash[prop.key]++;
    } else {
      nodePropHash[prop.key] = 1;
    }
  });

  nodeCount++;

  l.forEach(label => {
    if (nodeLabelHash[label]) {
      nodeLabelHash[label]++;
    } else {
      nodeLabelHash[label] = 1;
    }
  });

  return {
    id: id,
    labels: l,
    properties: propObj
  }
}

Edge = CommentLine* WS* '(' f:Value ')' '-[' l:Label* p:Property* ']' d:Direction '(' t:Value ')' InlineComment? EndOfLine
{
  let propObj = {};
  p.forEach(prop => {
    if (propObj[prop.key]) {
      propObj[prop.key].push(prop.value);
    } else {
      propObj[prop.key] = [prop.value];
    }
    // edgePropHash[prop.key] = true;
    if (edgePropHash[prop.key]) {
      edgePropHash[prop.key]++;
    } else {
      edgePropHash[prop.key] = 1;
    }
  });

  edgeCount++;

  l.forEach(label => {
    if (edgeLabelHash[label]) {
      edgeLabelHash[label]++;
    } else {
      edgeLabelHash[label] = 1;
    }
  });

  return {
    from: f,
    to: t,
    direction: d,
    labels: l,
    properties: propObj
  }
}

Label = ','? l:NON_SPECIAL_CHAR+
{
  return l.join('');
}

Property = ','? k:Value WS* ':' WS* v:Value
{
  return {
    key: k,
    value: v
  }
}

Direction = '--' / '->'

Number = '-'? Integer ('.' [0-9]+)? Exp?

Integer = '0' / [1-9] [0-9]*

Exp = [eE] ('-' / '+')? [0-9]+

EscapedChar = "'"
/ '"'
/ "\\"
/ "b"
{
  return "\b";
}
/ "f"
{
  return "\f";
}
/ "n"
{
  return "\n";
}
/ "r"
{
  return "\r";
}
/ "t"
{
  return "\t";
}
/ "v"
{
  return "\x0B";
}

DoubleQuotedChar = !('"' / "\\") char:.
{
  return char;
}
/ "\\" esc:EscapedChar
{
  return esc;
}

SingleQuotedChar = !("'" / "\\") char:.
{
  return char;
}
/ "\\" esc:EscapedChar
{
  return esc;
}

Value = Number & SPECIAL_CHAR
{
  return text();
}
/ '"' chars:DoubleQuotedChar* '"'
{
  // return chars.join('');
  return text();
}
/ "'" chars:SingleQuotedChar* "'"
{
  // return chars.join('');
  return text();
}
/ chars:NON_SPECIAL_CHAR+
{
  return chars.join('');
}

// space or tab
WS = [\u0020\u0009]

// sapce tab CR LF () [ ] ,
SPECIAL_CHAR = [:\u0020\u0009\u000D\u000A\u0028\u0029\u005B\u005D\u002C]

NON_SPECIAL_CHAR = [^:\u0020\u0009\u000D\u000A\u0028\u0029\u005B\u005D\u002C]

// CR or LF
NEWLINE = [\u000D\u000A]

NON_NEWLINE = [^\u000D\u000A]

EOF = !.

EndOfLine = EOF / NEWLINE

CommentLine = WS* ('#' NON_NEWLINE*)? NEWLINE

InlineComment = WS+ '#' WS+ NON_NEWLINE*
