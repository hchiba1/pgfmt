{
  let nodeCount = 0;
  let edgeCount = 0;
  let nodePropHash = {};
  let edgePropHash = {};
}

PG = lines:NodeOrEdge+
{
  return {
    nodes: lines.map(l => l.node).filter(v => v),
    edges: lines.map(l => l.edge).filter(v => v),
    nodeCount: nodeCount,
    edgeCount: edgeCount,
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

Node = COMMENT_LINE* WS* id:Value l:Label* p:Property* INLINE_COMMENT? NEWLINE COMMENT_LINE*
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

  return {
    id: id,
    labels: l,
    properties: propObj
  }
}

Edge = COMMENT_LINE* WS* f:Value WS+ d:Direction WS+ t:Value l:Label* p:Property* INLINE_COMMENT? NEWLINE COMMENT_LINE*
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

  return {
    from: f,
    to: t,
    direction: d,
    labels: l,
    properties: propObj
  }
}

Label = WS+ ':' WS* l:Value
{
  return l
}

Property = WS+ k:Value WS* ':' WS* v:Value
{
  return {
    key: k,
    value: v
  }
}

Direction = '--' / '->'

Value = '-'? Integer
{
  return {
    datatype: 'integer'
    value: text();
  }
}
/ '-'? Integer '.' [0-9]+
{
  return {
    datatype: 'decimal'
    value: text();
  }
}
/ '"' chars:DoubleStringCharacter* '"'
{
  return {
    datatype: string,
    subtype: double,
    value: chars.join('');
  }
}
/ "'" chars:SingleStringCharacter* "'"
{
  return {
    datatype: string,
    subtype: single,
    value: chars.join('');
  }
}
/ chars:BARE_CHAR+
{
  return {
    datatype: string,
    subtype: bare,
    value: chars.join('');
  }
}

Integer = '0' / [1-9] [0-9]*

DoubleStringCharacter = !('"' / "\\") char:.
{
  return char;
}
/ "\\" sequence:EscapeSequence
{
  return sequence;
}

SingleStringCharacter = !("'" / "\\") char:.
{
  return char;
}
/ "\\" sequence:EscapeSequence
{
  return sequence;
}

EscapeSequence = "'" / '"' / "\\"
/ "b"  { return "\b";   }
/ "f"  { return "\f";   }
/ "n"  { return "\n";   }
/ "r"  { return "\r";   }
/ "t"  { return "\t";   }
/ "v"  { return "\x0B"; }

BARE_CHAR = [^:\u0020\u0009\u000D\u000A]

// space or tab
WS = [\u0020\u0009]

// CR or LF
NEWLINE = [\u000D\u000A]

NON_NEWLINE = [^\u000D\u000A]

COMMENT_LINE = WS* ('#' NON_NEWLINE*)? NEWLINE
{
    return;
}

INLINE_COMMENT = WS+ '#' WS+ NON_NEWLINE*
