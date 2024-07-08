'use strict';

var _slicedToArray = function () { function sliceIterator(arr, i) { var _arr = []; var _n = true; var _d = false; var _e = undefined; try { for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) { _arr.push(_s.value); if (i && _arr.length === i) break; } } catch (err) { _d = true; _e = err; } finally { try { if (!_n && _i["return"]) _i["return"](); } finally { if (_d) throw _e; } } return _arr; } return function (arr, i) { if (Array.isArray(arr)) { return arr; } else if (Symbol.iterator in Object(arr)) { return sliceIterator(arr, i); } else { throw new TypeError("Invalid attempt to destructure non-iterable instance"); } }; }();

function initCache() {
  var store = [];
  // cache only first element, second is length to jump ahead for the parser
  var cache = function cache(value) {
    store.push(value[0]);
    return value;
  };

  cache.get = function (index) {
    if (index >= store.length) {
      throw RangeError('Can\'t resolve reference ' + (index + 1));
    }

    return store[index];
  };

  return cache;
}

function expectType(str, cache) {
  var types = /^(?:N(?=;)|[bidsSaOCrR](?=:)|[^:]+(?=:))/g;
  var type = (types.exec(str) || [])[0];

  if (!type) {
    throw SyntaxError('Invalid input: ' + str);
  }

  switch (type) {
    case 'N':
      return cache([null, 2]);
    case 'b':
      return cache(expectBool(str));
    case 'i':
      return cache(expectInt(str));
    case 'd':
      return cache(expectFloat(str));
    case 's':
      return cache(expectString(str));
    case 'S':
      return cache(expectEscapedString(str));
    case 'a':
      return expectArray(str, cache);
    case 'O':
      return expectObject(str, cache);
    case 'C':
      return expectClass(str, cache);
    case 'r':
    case 'R':
      return expectReference(str, cache);
    default:
      throw SyntaxError('Invalid or unsupported data type: ' + type);
  }
}

function expectBool(str) {
  var reBool = /^b:([01]);/;

  var _ref = reBool.exec(str) || [],
      _ref2 = _slicedToArray(_ref, 2),
      match = _ref2[0],
      boolMatch = _ref2[1];

  if (!boolMatch) {
    throw SyntaxError('Invalid bool value, expected 0 or 1');
  }

  return [boolMatch === '1', match.length];
}

function expectInt(str) {
  var reInt = /^i:([+-]?\d+);/;

  var _ref3 = reInt.exec(str) || [],
      _ref4 = _slicedToArray(_ref3, 2),
      match = _ref4[0],
      intMatch = _ref4[1];

  if (!intMatch) {
    throw SyntaxError('Expected an integer value');
  }

  return [parseInt(intMatch, 10), match.length];
}

function expectFloat(str) {
  var reFloat = /^d:(NAN|-?INF|(?:\d+\.\d*|\d*\.\d+|\d+)(?:[eE][+-]\d+)?);/;

  var _ref5 = reFloat.exec(str) || [],
      _ref6 = _slicedToArray(_ref5, 2),
      match = _ref6[0],
      floatMatch = _ref6[1];

  if (!floatMatch) {
    throw SyntaxError('Expected a float value');
  }

  var floatValue = void 0;

  switch (floatMatch) {
    case 'NAN':
      floatValue = Number.NaN;
      break;
    case '-INF':
      floatValue = Number.NEGATIVE_INFINITY;
      break;
    case 'INF':
      floatValue = Number.POSITIVE_INFINITY;
      break;
    default:
      floatValue = parseFloat(floatMatch);
      break;
  }

  return [floatValue, match.length];
}

function readBytes(str, len) {
  var escapedString = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : false;

  var bytes = 0;
  var out = '';
  var c = 0;
  var strLen = str.length;
  var wasHighSurrogate = false;
  var escapedChars = 0;

  while (bytes < len && c < strLen) {
    var chr = str.charAt(c);
    var code = chr.charCodeAt(0);
    var isHighSurrogate = code >= 0xd800 && code <= 0xdbff;
    var isLowSurrogate = code >= 0xdc00 && code <= 0xdfff;

    if (escapedString && chr === '\\') {
      chr = String.fromCharCode(parseInt(str.substr(c + 1, 2), 16));
      escapedChars++;

      // each escaped sequence is 3 characters. Go 2 chars ahead.
      // third character will be jumped over a few lines later
      c += 2;
    }

    c++;

    bytes += isHighSurrogate || isLowSurrogate && wasHighSurrogate ? // if high surrogate, count 2 bytes, as expectation is to be followed by low surrogate
    // if low surrogate preceded by high surrogate, add 2 bytes
    2 : code > 0x7ff ? // otherwise low surrogate falls into this part
    3 : code > 0x7f ? 2 : 1;

    // if high surrogate is not followed by low surrogate, add 1 more byte
    bytes += wasHighSurrogate && !isLowSurrogate ? 1 : 0;

    out += chr;
    wasHighSurrogate = isHighSurrogate;
  }

  return [out, bytes, escapedChars];
}

function expectString(str) {
  // PHP strings consist of one-byte characters.
  // JS uses 2 bytes with possible surrogate pairs.
  // Serialized length of 2 is still 1 JS string character
  var reStrLength = /^s:(\d+):"/g; // also match the opening " char

  var _ref7 = reStrLength.exec(str) || [],
      _ref8 = _slicedToArray(_ref7, 2),
      match = _ref8[0],
      byteLenMatch = _ref8[1];

  if (!match) {
    throw SyntaxError('Expected a string value');
  }

  var len = parseInt(byteLenMatch, 10);

  str = str.substr(match.length);

  var _readBytes = readBytes(str, len),
      _readBytes2 = _slicedToArray(_readBytes, 2),
      strMatch = _readBytes2[0],
      bytes = _readBytes2[1];

  if (bytes !== len) {
    throw SyntaxError('Expected string of ' + len + ' bytes, but got ' + bytes);
  }

  str = str.substr(strMatch.length);

  // strict parsing, match closing "; chars
  if (!str.startsWith('";')) {
    throw SyntaxError('Expected ";');
  }

  return [strMatch, match.length + strMatch.length + 2]; // skip last ";
}

function expectEscapedString(str) {
  var reStrLength = /^S:(\d+):"/g; // also match the opening " char

  var _ref9 = reStrLength.exec(str) || [],
      _ref10 = _slicedToArray(_ref9, 2),
      match = _ref10[0],
      strLenMatch = _ref10[1];

  if (!match) {
    throw SyntaxError('Expected an escaped string value');
  }

  var len = parseInt(strLenMatch, 10);

  str = str.substr(match.length);

  var _readBytes3 = readBytes(str, len, true),
      _readBytes4 = _slicedToArray(_readBytes3, 3),
      strMatch = _readBytes4[0],
      bytes = _readBytes4[1],
      escapedChars = _readBytes4[2];

  if (bytes !== len) {
    throw SyntaxError('Expected escaped string of ' + len + ' bytes, but got ' + bytes);
  }

  str = str.substr(strMatch.length + escapedChars * 2);

  // strict parsing, match closing "; chars
  if (!str.startsWith('";')) {
    throw SyntaxError('Expected ";');
  }

  return [strMatch, match.length + strMatch.length + 2]; // skip last ";
}

function expectKeyOrIndex(str) {
  try {
    return expectString(str);
  } catch (err) {}

  try {
    return expectEscapedString(str);
  } catch (err) {}

  try {
    return expectInt(str);
  } catch (err) {
    throw SyntaxError('Expected key or index');
  }
}

function expectObject(str, cache) {
  // O:<class name length>:"class name":<prop count>:{<props and values>}
  // O:8:"stdClass":2:{s:3:"foo";s:3:"bar";s:3:"bar";s:3:"baz";}
  var reObjectLiteral = /^O:(\d+):"([^"]+)":(\d+):\{/;

  var _ref11 = reObjectLiteral.exec(str) || [],
      _ref12 = _slicedToArray(_ref11, 4),
      objectLiteralBeginMatch /* classNameLengthMatch */ = _ref12[0],
      className = _ref12[2],
      propCountMatch = _ref12[3];

  if (!objectLiteralBeginMatch) {
    throw SyntaxError('Invalid input');
  }

  if (className !== 'stdClass') {
    throw SyntaxError('Unsupported object type: ' + className);
  }

  var totalOffset = objectLiteralBeginMatch.length;

  var propCount = parseInt(propCountMatch, 10);
  var obj = {};
  cache([obj]);

  str = str.substr(totalOffset);

  for (var i = 0; i < propCount; i++) {
    var prop = expectKeyOrIndex(str);
    str = str.substr(prop[1]);
    totalOffset += prop[1];

    var value = expectType(str, cache);
    str = str.substr(value[1]);
    totalOffset += value[1];

    obj[prop[0]] = value[0];
  }

  // strict parsing, expect } after object literal
  if (str.charAt(0) !== '}') {
    throw SyntaxError('Expected }');
  }

  return [obj, totalOffset + 1]; // skip final }
}

function expectClass(str, cache) {
  // can't be well supported, because requires calling eval (or similar)
  // in order to call serialized constructor name
  // which is unsafe
  // or assume that constructor is defined in global scope
  // but this is too much limiting
  throw Error('Not yet implemented');
}

function expectReference(str, cache) {
  var reRef = /^[rR]:([1-9]\d*);/;

  var _ref13 = reRef.exec(str) || [],
      _ref14 = _slicedToArray(_ref13, 2),
      match = _ref14[0],
      refIndex = _ref14[1];

  if (!match) {
    throw SyntaxError('Expected reference value');
  }

  return [cache.get(parseInt(refIndex, 10) - 1), match.length];
}

function expectArray(str, cache) {
  var reArrayLength = /^a:(\d+):{/;

  var _ref15 = reArrayLength.exec(str) || [],
      _ref16 = _slicedToArray(_ref15, 2),
      arrayLiteralBeginMatch = _ref16[0],
      arrayLengthMatch = _ref16[1];

  if (!arrayLengthMatch) {
    throw SyntaxError('Expected array length annotation');
  }

  str = str.substr(arrayLiteralBeginMatch.length);

  var array = expectArrayItems(str, parseInt(arrayLengthMatch, 10), cache);

  // strict parsing, expect closing } brace after array literal
  if (str.charAt(array[1]) !== '}') {
    throw SyntaxError('Expected }');
  }

  return [array[0], arrayLiteralBeginMatch.length + array[1] + 1]; // jump over }
}

function expectArrayItems(str) {
  var expectedItems = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : 0;
  var cache = arguments[2];

  var key = void 0;
  var item = void 0;
  var totalOffset = 0;
  var hasContinousIndexes = true;
  var lastIndex = -1;
  var items = {};
  cache([items]);

  for (var i = 0; i < expectedItems; i++) {
    key = expectKeyOrIndex(str);

    hasContinousIndexes = hasContinousIndexes && typeof key[0] === 'number' && key[0] === lastIndex + 1;
    lastIndex = key[0];

    str = str.substr(key[1]);
    totalOffset += key[1];

    // references are resolved immediately, so if duplicate key overwrites previous array index
    // the old value is anyway resolved
    // fixme: but next time the same reference should point to the new value
    item = expectType(str, cache);
    str = str.substr(item[1]);
    totalOffset += item[1];

    items[key[0]] = item[0];
  }

  if (hasContinousIndexes) {
    items = Object.values(items);
  }

  return [items, totalOffset];
}

module.exports = function unserialize(str) {
  //       discuss at: https://locutus.io/php/unserialize/
  //      original by: Arpad Ray (mailto:arpad@php.net)
  //      improved by: Pedro Tainha (https://www.pedrotainha.com)
  //      improved by: Kevin van Zonneveld (https://kvz.io)
  //      improved by: Kevin van Zonneveld (https://kvz.io)
  //      improved by: Chris
  //      improved by: James
  //      improved by: Le Torbi
  //      improved by: Eli Skeggs
  //      bugfixed by: dptr1988
  //      bugfixed by: Kevin van Zonneveld (https://kvz.io)
  //      bugfixed by: Brett Zamir (https://brett-zamir.me)
  //      bugfixed by: philippsimon (https://github.com/philippsimon/)
  //       revised by: d3x
  //         input by: Brett Zamir (https://brett-zamir.me)
  //         input by: Martin (https://www.erlenwiese.de/)
  //         input by: kilops
  //         input by: Jaroslaw Czarniak
  //         input by: lovasoa (https://github.com/lovasoa/)
  //      improved by: Rafał Kukawski
  // reimplemented by: Rafał Kukawski
  //           note 1: We feel the main purpose of this function should be
  //           note 1: to ease the transport of data between php & js
  //           note 1: Aiming for PHP-compatibility, we have to translate objects to arrays
  //        example 1: unserialize('a:3:{i:0;s:5:"Kevin";i:1;s:3:"van";i:2;s:9:"Zonneveld";}')
  //        returns 1: ['Kevin', 'van', 'Zonneveld']
  //        example 2: unserialize('a:2:{s:9:"firstName";s:5:"Kevin";s:7:"midName";s:3:"van";}')
  //        returns 2: {firstName: 'Kevin', midName: 'van'}
  //        example 3: unserialize('a:3:{s:2:"ü";s:2:"ü";s:3:"四";s:3:"四";s:4:"𠜎";s:4:"𠜎";}')
  //        returns 3: {'ü': 'ü', '四': '四', '𠜎': '𠜎'}
  //        example 4: unserialize(undefined)
  //        returns 4: false
  //        example 5: unserialize('O:8:"stdClass":1:{s:3:"foo";b:1;}')
  //        returns 5: { foo: true }
  //        example 6: unserialize('a:2:{i:0;N;i:1;s:0:"";}')
  //        returns 6: [null, ""]
  //        example 7: unserialize('S:7:"\\65\\73\\63\\61\\70\\65\\64";')
  //        returns 7: 'escaped'

  try {
    if (typeof str !== 'string') {
      return false;
    }

    return expectType(str, initCache())[0];
  } catch (err) {
    console.error(err);
    return false;
  }
};
//# sourceMappingURL=unserialize.js.map