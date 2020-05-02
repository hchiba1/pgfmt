#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const parser = require('../lib/ttl_parser.js');

const commander = require('commander')
      .arguments('<TTL_FILE>')
      .option('-d, --debug', 'output parsed synatax tree')
      .parse(process.argv);

let inputText;
if(commander.args[0]) {
  const inputFile = commander.args[0];
  inputText = fs.readFileSync(inputFile, "utf8").toString();
} else if (process.stdin.isTTY) {
  commander.help();
} else {
  inputText = fs.readFileSync(process.stdin.fd).toString();
}

let objectTree;
try {
  objectTree = parser.parse(inputText);
} catch (err) {
  if (err.location.start) {
    printError(err);
  } else {
    console.error(err.message);
  }
  process.exit(1);
}

if (commander.debug) {
  // console.log(objectTree);
  console.log(JSON.stringify(objectTree, null, 2));
} else {
  objectTree.triples.forEach((line) => {
    if (line.hasOwnProperty('prefix')) {
      // console.log(line);
    } else {
      console.log(JSON.stringify(line, null, 2));
    }
  });
}

function printError(err) {
  const startLine = err.location.start.line;
  const endLine = err.location.end.line;
  const startCol = err.location.start.column;
  const endCol = err.location.end.column;
  if (startLine == endLine) {
    console.error(`ERROR line:${startLine}(col:${startCol}-${endCol})`);
  } else {
    console.error(`ERROR line:${startLine}(col:${startCol})-${endLine}(col:${endCol})`);
  }
  console.error(err.message);
  console.error('--');
  const lines = inputText.split('\n').slice(startLine-1, endLine);
  lines.forEach((line, i) => {
    if (i == 0) {
      console.error(makeRed(line.substring(0, startCol - 1)) + line.substring(startCol - 1));
    } else if (i < lines.length - 1) {
      console.error(makeRed(line));
    } else {
      console.error(makeRed(line.substring(0, endCol)) + line.substring(endCol));
    }
  });
}

function makeRed(text) {
  // const red = '\u001b[31m'; // foreground
  const red = '\u001b[41m'; // backgrond
  const reset = '\u001b[0m';
  return red + text + reset;
}
