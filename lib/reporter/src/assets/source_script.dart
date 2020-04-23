part of dart_coco.reporter;

final SOURCE_SCRIPT = """
window['PR_SHOULD_USE_CONTINUATION'] = true;
window['PR_TAB_WIDTH'] = 8;
window['PR_normalizedHtml'] = window['PR'] = window['prettyPrintOne'] = window['prettyPrint'] = void 0;
window['_pr_isIE6'] = function () {
    let ieVersion = navigator && navigator.userAgent &&
        navigator.userAgent.match(/\bMSIE ([678])\./);
    ieVersion = ieVersion ? +ieVersion[1] : false;
    window['_pr_isIE6'] = function () {
        return ieVersion;
    };
    return ieVersion;
};

(function () {
    let FLOW_CONTROL_KEYWORDS ="break continue do else for if return while ";
    let C_KEYWORDS = FLOW_CONTROL_KEYWORDS + "auto case char const default " +
        "double enum extern float goto int long register short signed sizeof " +
        "static struct switch typedef union unsigned void volatile ";
    let COMMON_KEYWORDS = C_KEYWORDS + "catch class delete false import " +
        "new operator private protected public this throw true try typeof ";
    let CPP_KEYWORDS = COMMON_KEYWORDS + "alignof align_union asm axiom bool " +
        "concept concept_map const_cast constexpr decltype " +
        "dynamic_cast explicit export friend inline late_check " +
        "mutable namespace nullptr reinterpret_cast static_assert static_cast " +
        "template typeid typename using virtual wchar_t where ";
    let JAVA_KEYWORDS = COMMON_KEYWORDS +
        "abstract boolean byte extends final finally implements import " +
        "instanceof null native package strictfp super synchronized throws " +
        "transient ";
    let CSHARP_KEYWORDS = JAVA_KEYWORDS +
        "as base by checked decimal delegate descending event " +
        "fixed foreach from group implicit in interface internal into is lock " +
        "object out override orderby params partial readonly ref sbyte sealed " +
        "stackalloc string select uint ulong unchecked unsafe ushort let ";
    let DART_KEYWORDS = "assert break case catch class const continue default " +
        "do else enum extends false final finally for it in is new null rethrow " +
        "return super switch this throw true try let void while with async hide " +
        "on shiw sync"
    let JSCRIPT_KEYWORDS = COMMON_KEYWORDS +
        "debugger eval export function get null set undefined let with " +
        "Infinity NaN ";
    let PERL_KEYWORDS = "caller delete die do dump elsif eval exit foreach for " +
        "goto if import last local my next no our print package redo require " +
        "sub undef unless until use wantarray while BEGIN END ";
    let PYTHON_KEYWORDS = FLOW_CONTROL_KEYWORDS + "and as assert class def del " +
        "elif except exec finally from global import in is lambda " +
        "nonlocal not or pass print raise try with yield " +
        "False True None ";
    let RUBY_KEYWORDS = FLOW_CONTROL_KEYWORDS + "alias and begin case class def" +
        " defined elsif end ensure false in module next nil not or redo rescue " +
        "retry self super then true undef unless until when yield BEGIN END ";
    let SH_KEYWORDS = FLOW_CONTROL_KEYWORDS + "case done elif esac eval fi " +
        "function in local set then until ";
    let ALL_KEYWORDS = (
        CPP_KEYWORDS + CSHARP_KEYWORDS + JSCRIPT_KEYWORDS + PERL_KEYWORDS +
        PYTHON_KEYWORDS + RUBY_KEYWORDS + SH_KEYWORDS);
    
        let PR_STRING = 'str';
    let PR_KEYWORD = 'kwd';
    let PR_COMMENT = 'com';
    let PR_TYPE = 'typ';
    let PR_LITERAL = 'lit';
    let PR_PUNCTUATION = 'pun';
    let PR_PLAIN = 'pln';
    let PR_TAG = 'tag';
    let PR_DECLARATION = 'dec';
    let PR_SOURCE = 'src';
    let PR_ATTRIB_NAME = 'atn';
    let PR_ATTRIB_VALUE = 'atv';
    let PR_NOCODE = 'nocode';
    let REGEXP_PRECEDER_PATTERN = function () {
        let preceders = [
            "!", "!=", "!==", "#", "%", "%=", "&", "&&", "&&=",
            "&=", "(", "*", "*=", /* "+", */ "+=", ",", /* "-", */ "-=",
            "->", /*".", "..", "...", handled below */ "/", "/=", ":", "::", ";",
            "<", "<<", "<<=", "<=", "=", "==", "===", ">",
            ">=", ">>", ">>=", ">>>", ">>>=", "?", "@", "[",
            "^", "^=", "^^", "^^=", "{", "|", "|=", "||",
            "||=", "~" /* handles =~ and !~ */,
            "break", "case", "continue", "delete",
            "do", "else", "finally", "instanceof",
            "return", "throw", "try", "typeof"
        ];
        let pattern = '(?:^^|[+-]';
        for (let i = 0; i < preceders.length; ++i) {
            pattern += '|' + preceders[i].replace(/([^=<>:&a-z])/g, '${'\$'}{'\$1'}');
        }
        pattern += ')\\s*';  // matches at end, and matches empty string
        return pattern;
    }();
    
    let pr_amp = /&/g;
    let pr_lt = /</g;
    let pr_gt = />/g;
    let pr_quot = /\"/g;
    function attribToHtml(str) {
        return str.replace(pr_amp, '&amp;')
            .replace(pr_lt, '&lt;')
            .replace(pr_gt, '&gt;')
            .replace(pr_quot, '&quot;');
    }
    function textToHtml(str) {
        return str.replace(pr_amp, '&amp;')
            .replace(pr_lt, '&lt;')
            .replace(pr_gt, '&gt;');
    }


    let pr_ltEnt = /&lt;/g;
    let pr_gtEnt = /&gt;/g;
    let pr_aposEnt = /&apos;/g;
    let pr_quotEnt = /&quot;/g;
    let pr_ampEnt = /&amp;/g;
    let pr_nbspEnt = /&nbsp;/g;
    
    function htmlToText(html) {
        let pos = html.indexOf('&');
        if (pos < 0) {
            return html;
        }
        for (--pos; (pos = html.indexOf('&#', pos + 1)) >= 0;) {
            let end = html.indexOf(';', pos);
            if (end >= 0) {
                let num = html.substring(pos + 3, end);
                let radix = 10;
                if (num && num.charAt(0) === 'x') {
                    num = num.substring(1);
                    radix = 16;
                }
                let codePoint = parseInt(num, radix);
                if (!isNaN(codePoint)) {
                    html = (html.substring(0, pos) + String.fromCharCode(codePoint) +
                        html.substring(end + 1));
                }
            }
        }

        return html.replace(pr_ltEnt, '<')
            .replace(pr_gtEnt, '>')
            .replace(pr_aposEnt, "'")
            .replace(pr_quotEnt, '"')
            .replace(pr_nbspEnt, ' ')
            .replace(pr_ampEnt, '&');
    }
    
    
function isRawContent(node) {
        return 'XMP' === node.tagName;
    }
    let newlineRe = /[\r\n]/g;
    function isPreformatted(node, content) {
        if ('PRE' === node.tagName) {
            return true;
        }
        if (!newlineRe.test(content)) {
            return true;
        }
        let whitespace = '';
        if (node.currentStyle) {
            whitespace = node.currentStyle.whiteSpace;
        } else if (window.getComputedStyle) {
            whitespace = window.getComputedStyle(node, null).whiteSpace;
        }
        return !whitespace || whitespace === 'pre';
    }

    function normalizedHtml(node, out, opt_sortAttrs) {
        switch (node.nodeType) {
            case 1:  // an element
                let name = node.tagName.toLowerCase();

                out.push('<', name);
                let attrs = node.attributes;
                let n = attrs.length;
                if (n) {
                    if (opt_sortAttrs) {
                        let sortedAttrs = [];
                        for (let i = n; --i >= 0;) {
                            sortedAttrs[i] = attrs[i];
                        }
                        sortedAttrs.sort(function (a, b) {
                            return (a.name < b.name) ? -1 : a.name === b.name ? 0 : 1;
                        });
                        attrs = sortedAttrs;
                    }
                    for (let i = 0; i < n; ++i) {
                        let attr = attrs[i];
                        if (!attr.specified) {
                            continue;
                        }
                        out.push(' ', attr.name.toLowerCase(),
                            '="', attribToHtml(attr.value), '"');
                    }
                }
                out.push('>');
                for (let child = node.firstChild; child; child = child.nextSibling) {
                    normalizedHtml(child, out, opt_sortAttrs);
                }
                if (node.firstChild || !/^(?:br|link|img)\$/.test(name)) {
                    out.push('<\/', name, '>');
                }
                break;
            case 3:
            case 4: // text
                out.push(textToHtml(node.nodeValue));
                break;
        }
    }
    function combinePrefixPatterns(regexs) {
        let capturedGroupIndex = 0;

        let needToFoldCase = false;
        let ignoreCase = false;
        for (let i = 0, n = regexs.length; i < n; ++i) {
            let regex = regexs[i];
            if (regex.ignoreCase) {
                ignoreCase = true;
            } else if (/[a-z]/i.test(regex.source.replace(
                /\\u[0-9a-f]{4}|\\x[0-9a-f]{2}|\\[^ux]/gi, ''))) {
                needToFoldCase = true;
                ignoreCase = false;
                break;
            }
        }

        function decodeEscape(charsetPart) {
            if (charsetPart.charAt(0) !== '\\') {
                return charsetPart.charCodeAt(0);
            }
            switch (charsetPart.charAt(1)) {
                case 'b':
                    return 8;
                case 't':
                    return 9;
                case 'n':
                    return 0xa;
                case 'v':
                    return 0xb;
                case 'f':
                    return 0xc;
                case 'r':
                    return 0xd;
                case 'u':
                case 'x':
                    return parseInt(charsetPart.substring(2), 16)
                        || charsetPart.charCodeAt(1);
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                    return parseInt(charsetPart.substring(1), 8);
                default:
                    return charsetPart.charCodeAt(1);
            }
        }

        function encodeEscape(charCode) {
            if (charCode < 0x20) {
                return (charCode < 0x10 ? '\\x0' : '\\x') + charCode.toString(16);
            }
            let ch = String.fromCharCode(charCode);
            if (ch === '\\' || ch === '-' || ch === '[' || ch === ']') {
                ch = '\\' + ch;
            }
            return ch;
        }

        function caseFoldCharset(charSet) {
            let charsetParts = charSet.substring(1, charSet.length - 1).match(
                new RegExp(
                    '\\\\u[0-9A-Fa-f]{4}'
                    + '|\\\\x[0-9A-Fa-f]{2}'
                    + '|\\\\[0-3][0-7]{0,2}'
                    + '|\\\\[0-7]{1,2}'
                    + '|\\\\[\\s\\S]'
                    + '|-'
                    + '|[^-\\\\]',
                    'g'));
            let groups = [];
            let ranges = [];
            let inverse = charsetParts[0] === '^';
            for (let i = inverse ? 1 : 0, n = charsetParts.length; i < n; ++i) {
                let p = charsetParts[i];
                switch (p) {
                    case '\\B':
                    case '\\b':
                    case '\\D':
                    case '\\d':
                    case '\\S':
                    case '\\s':
                    case '\\W':
                    case '\\w':
                        groups.push(p);
                        continue;
                }
                let start = decodeEscape(p);
                let end;
                if (i + 2 < n && '-' === charsetParts[i + 1]) {
                    end = decodeEscape(charsetParts[i + 2]);
                    i += 2;
                } else {
                    end = start;
                }
                ranges.push([start, end]);
                // If the range might intersect letters, then expand it.
                if (!(end < 65 || start > 122)) {
                    if (!(end < 65 || start > 90)) {
                        ranges.push([Math.max(65, start) | 32, Math.min(end, 90) | 32]);
                    }
                    if (!(end < 97 || start > 122)) {
                        ranges.push([Math.max(97, start) & ~32, Math.min(end, 122) & ~32]);
                    }
                }
            }

            // [[1, 10], [3, 4], [8, 12], [14, 14], [16, 16], [17, 17]]
            // -> [[1, 12], [14, 14], [16, 17]]
            ranges.sort(function (a, b) {
                return (a[0] - b[0]) || (b[1] - a[1]);
            });
            let consolidatedRanges = [];
            let lastRange = [NaN, NaN];
            for (let i = 0; i < ranges.length; ++i) {
                let range = ranges[i];
                if (range[0] <= lastRange[1] + 1) {
                    lastRange[1] = Math.max(lastRange[1], range[1]);
                } else {
                    consolidatedRanges.push(lastRange = range);
                }
            }

            let out = ['['];
            if (inverse) {
                out.push('^');
            }
            out.push.apply(out, groups);
            for (let i = 0; i < consolidatedRanges.length; ++i) {
                let range = consolidatedRanges[i];
                out.push(encodeEscape(range[0]));
                if (range[1] > range[0]) {
                    if (range[1] + 1 > range[0]) {
                        out.push('-');
                    }
                    out.push(encodeEscape(range[1]));
                }
            }
            out.push(']');
            return out.join('');
        }
                function allowAnywhereFoldCaseAndRenumberGroups(regex) {
            let parts = regex.source.match(
                new RegExp(
                    '(?:'
                    + '\\[(?:[^\\x5C\\x5D]|\\\\[\\s\\S])*\\]'
                    + '|\\\\u[A-Fa-f0-9]{4}'
                    + '|\\\\x[A-Fa-f0-9]{2}'
                    + '|\\\\[0-9]+'
                    + '|\\\\[^ux0-9]'
                    + '|\\(\\?[:!=]'
                    + '|[\\(\\)\\^]'
                    + '|[^\\x5B\\x5C\\(\\)\\^]+'
                    + ')',
                    'g'));
            let n = parts.length;
            let capturedGroups = [];
            for (let i = 0, groupIndex = 0; i < n; ++i) {
                let p = parts[i];
                if (p === '(') {
                    ++groupIndex;
                } else if ('\\' === p.charAt(0)) {
                    let decimalValue = +p.substring(1);
                    if (decimalValue && decimalValue <= groupIndex) {
                        capturedGroups[decimalValue] = -1;
                    }
                }
            }
            for (let i = 1; i < capturedGroups.length; ++i) {
                if (-1 === capturedGroups[i]) {
                    capturedGroups[i] = ++capturedGroupIndex;
                }
            }
            for (let i = 0, groupIndex = 0; i < n; ++i) {
                let p = parts[i];
                if (p === '(') {
                    ++groupIndex;
                    if (capturedGroups[groupIndex] === undefined) {
                        parts[i] = '(?:';
                    }
                } else if ('\\' === p.charAt(0)) {
                    let decimalValue = +p.substring(1);
                    if (decimalValue && decimalValue <= groupIndex) {
                        parts[i] = '\\' + capturedGroups[groupIndex];
                    }
                }
            }
            for (let i = 0, groupIndex = 0; i < n; ++i) {
                if ('^' === parts[i] && '^' !== parts[i + 1]) {
                    parts[i] = '';
                }
            }

            // Expand letters to groupts to handle mixing of case-sensitive and
            // case-insensitive patterns if necessary.
            if (regex.ignoreCase && needToFoldCase) {
                for (let i = 0; i < n; ++i) {
                    let p = parts[i];
                    let ch0 = p.charAt(0);
                    if (p.length >= 2 && ch0 === '[') {
                        parts[i] = caseFoldCharset(p);
                    } else if (ch0 !== '\\') {
                        // TODO: handle letters in numeric escapes.
                        parts[i] = p.replace(
                            /[a-zA-Z]/g,
                            function (ch) {
                                let cc = ch.charCodeAt(0);
                                return '[' + String.fromCharCode(cc & ~32, cc | 32) + ']';
                            });
                    }
                }
            }

            return parts.join('');
        }

        let rewritten = [];
        for (let i = 0, n = regexs.length; i < n; ++i) {
            let regex = regexs[i];
            if (regex.global || regex.multiline) {
                throw new Error('' + regex);
            }
            rewritten.push(
                '(?:' + allowAnywhereFoldCaseAndRenumberGroups(regex) + ')');
        }

        return new RegExp(rewritten.join('|'), ignoreCase ? 'gi' : 'g');
    }
    let PR_innerHtmlWorks = null;

    function getInnerHtml(node) {
        // inner html is hopelessly broken in Safari 2.0.4 when the content is
        // an html description of well formed XML and the containing tag is a PRE
        // tag, so we detect that case and emulate innerHTML.
        if (null === PR_innerHtmlWorks) {
            let testNode = document.createElement('PRE');
            testNode.appendChild(
                document.createTextNode('<!DOCTYPE foo PUBLIC "foo bar">\n<foo />'));
            PR_innerHtmlWorks = !/</.test(testNode.innerHTML);
        }

        if (PR_innerHtmlWorks) {
            let content = node.innerHTML;
            // XMP tags contain unescaped entities so require special handling.
            if (isRawContent(node)) {
                content = textToHtml(content);
            } else if (!isPreformatted(node, content)) {
                content = content.replace(/(<br\s*\/?>)[\r\n]+/g, '${'\$1'}')
                    .replace(/(?:[\r\n]+[ \t]*)+/g, ' ');
            }
            return content;
        }

        let out = [];
        for (let child = node.firstChild; child; child = child.nextSibling) {
            normalizedHtml(child, out);
        }
        return out.join('');
    }

    function makeTabExpander(tabWidth) {
        let SPACES = '                ';
        let charInLine = 0;

        return function (plainText) {
            // walk over each character looking for tabs and newlines.
            // On tabs, expand them.  On newlines, reset charInLine.
            // Otherwise increment charInLine
            let out = null;
            let pos = 0;
            for (let i = 0, n = plainText.length; i < n; ++i) {
                let ch = plainText.charAt(i);

                switch (ch) {
                    case '\t':
                        if (!out) {
                            out = [];
                        }
                        out.push(plainText.substring(pos, i));
                        let nSpaces = tabWidth - (charInLine % tabWidth);
                        charInLine += nSpaces;
                        for (; nSpaces >= 0; nSpaces -= SPACES.length) {
                            out.push(SPACES.substring(0, nSpaces));
                        }
                        pos = i + 1;
                        break;
                    case '\n':
                        charInLine = 0;
                        break;
                    default:
                        ++charInLine;
                }
            }
            if (!out) {
                return plainText;
            }
            out.push(plainText.substring(pos));
            return out.join('');
        };
    }

    let pr_chunkPattern = new RegExp(
        '[^<]+'  // A run of characters other than '<'
        + '|<\!--[\\s\\S]*?--\>'  // an HTML comment
        + '|<!\\[CDATA\\[[\\s\\S]*?\\]\\]>'  // a CDATA section
        // a probable tag that should not be highlighted
        + '|<\/?[a-zA-Z](?:[^>\"\']|\'[^\']*\'|\"[^\"]*\")*>'
        + '|<',  // A '<' that does not begin a larger chunk
        'g');
    let pr_commentPrefix = /^<\!--/;
    let pr_cdataPrefix = /^<!\[CDATA\[/;
    let pr_brPrefix = /^<br\b/i;
    let pr_tagNameRe = /^<(\/?)([a-zA-Z][a-zA-Z0-9]*)/;

    function extractTags(s) {
        let matches = s.match(pr_chunkPattern);
        let sourceBuf = [];
        let sourceBufLen = 0;
        let extractedTags = [];
        if (matches) {
            for (let i = 0, n = matches.length; i < n; ++i) {
                let match = matches[i];
                if (match.length > 1 && match.charAt(0) === '<') {
                    if (pr_commentPrefix.test(match)) {
                        continue;
                    }
                    if (pr_cdataPrefix.test(match)) {
                        // strip CDATA prefix and suffix.  Don't unescape since it's CDATA
                        sourceBuf.push(match.substring(9, match.length - 3));
                        sourceBufLen += match.length - 12;
                    } else if (pr_brPrefix.test(match)) {
                        // <br> tags are lexically significant so convert them to text.
                        // This is undone later.
                        sourceBuf.push('\n');
                        ++sourceBufLen;
                    } else {
                        if (match.indexOf(PR_NOCODE) >= 0 && isNoCodeTag(match)) {
                            // A <span class="nocode"> will start a section that should be
                            // ignored.  Continue walking the list until we see a matching end
                            // tag.
                            let name = match.match(pr_tagNameRe)[2];
                            let depth = 1;
                            let j;
                            end_tag_loop:
                                for (j = i + 1; j < n; ++j) {
                                    let name2 = matches[j].match(pr_tagNameRe);
                                    if (name2 && name2[2] === name) {
                                        if (name2[1] === '/') {
                                            if (--depth === 0) {
                                                break;
                                            }
                                        } else {
                                            ++depth;
                                        }
                                    }
                                }
                            if (j < n) {
                                extractedTags.push(
                                    sourceBufLen, matches.slice(i, j + 1).join(''));
                                i = j;
                            } else {  // Ignore unclosed sections.
                                extractedTags.push(sourceBufLen, match);
                            }
                        } else {
                            extractedTags.push(sourceBufLen, match);
                        }
                    }
                } else {
                    let literalText = htmlToText(match);
                    sourceBuf.push(literalText);
                    sourceBufLen += literalText.length;
                }
            }
        }
        return {source: sourceBuf.join(''), tags: extractedTags};
    }

    function isNoCodeTag(tag) {
        return !!tag
            // First canonicalize the representation of attributes
            .replace(/\s(\w+)\s*=\s*(?:\"([^\"]*)\"|'([^\']*)'|(\S+))/g,
                ' ${'\$'}1="${'\$'}2${'\$'}3${'\$'}4"')
            // Then look for the attribute we want.
            .match(/[cC][lL][aA][sS][sS]=\"[^\"]*\bnocode\b/);
    }
    
    function appendDecorations(basePos, sourceCode, langHandler, out) {
        if (!sourceCode) {
            return;
        }
        let job = {
            source: sourceCode,
            basePos: basePos
        };
        langHandler(job);
        out.push.apply(out, job.decorations);
    }
    
    function createSimpleLexer(shortcutStylePatterns, fallthroughStylePatterns) {
        let shortcuts = {};
        let tokenizer;
        (function () {
            let allPatterns = shortcutStylePatterns.concat(fallthroughStylePatterns);
            let allRegexs = [];
            let regexKeys = {};
            for (let i = 0, n = allPatterns.length; i < n; ++i) {
                let patternParts = allPatterns[i];
                let shortcutChars = patternParts[3];
                if (shortcutChars) {
                    for (let c = shortcutChars.length; --c >= 0;) {
                        shortcuts[shortcutChars.charAt(c)] = patternParts;
                    }
                }
                let regex = patternParts[1];
                let k = '' + regex;
                if (!regexKeys.hasOwnProperty(k)) {
                    allRegexs.push(regex);
                    regexKeys[k] = null;
                }
            }
            allRegexs.push(/[\0-\uffff]/);
            tokenizer = combinePrefixPatterns(allRegexs);
        })();

        let nPatterns = fallthroughStylePatterns.length;
        let notWs = /\S/;
        
        let decorate = function (job) {
            let sourceCode = job.source, basePos = job.basePos;
            let decorations = [basePos, PR_PLAIN];
            let pos = 0;  // index into sourceCode
            let tokens = sourceCode.match(tokenizer) || [];
            let styleCache = {};

            for (let ti = 0, nTokens = tokens.length; ti < nTokens; ++ti) {
                let token = tokens[ti];
                let style = styleCache[token];
                let match = void 0;

                let isEmbedded;
                if (typeof style === 'string') {
                    isEmbedded = false;
                } else {
                    let patternParts = shortcuts[token.charAt(0)];
                    if (patternParts) {
                        match = token.match(patternParts[1]);
                        style = patternParts[0];
                    } else {
                        for (let i = 0; i < nPatterns; ++i) {
                            patternParts = fallthroughStylePatterns[i];
                            match = token.match(patternParts[1]);
                            if (match) {
                                style = patternParts[0];
                                break;
                            }
                        }

                        if (!match) {  // make sure that we make progress
                            style = PR_PLAIN;
                        }
                    }

                    isEmbedded = style.length >= 5 && 'lang-' === style.substring(0, 5);
                    if (isEmbedded && !(match && typeof match[1] === 'string')) {
                        isEmbedded = false;
                        style = PR_SOURCE;
                    }

                    if (!isEmbedded) {
                        styleCache[token] = style;
                    }
                }

                let tokenStart = pos;
                pos += token.length;

                if (!isEmbedded) {
                    decorations.push(basePos + tokenStart, style);
                } else {
                    let embeddedSource = match[1];
                    let embeddedSourceStart = token.indexOf(embeddedSource);
                    let embeddedSourceEnd = embeddedSourceStart + embeddedSource.length;
                    if (match[2]) {
                        embeddedSourceEnd = token.length - match[2].length;
                        embeddedSourceStart = embeddedSourceEnd - embeddedSource.length;
                    }
                    let lang = style.substring(5);
                    appendDecorations(
                        basePos + tokenStart,
                        token.substring(0, embeddedSourceStart),
                        decorate, decorations);
                    appendDecorations(
                        basePos + tokenStart + embeddedSourceStart,
                        embeddedSource,
                        langHandlerForExtension(lang, embeddedSource),
                        decorations);
                    appendDecorations(
                        basePos + tokenStart + embeddedSourceEnd,
                        token.substring(embeddedSourceEnd),
                        decorate, decorations);
                }
            }
            job.decorations = decorations;
        };
        return decorate;
    }

    function sourceDecorator(options) {
        let shortcutStylePatterns = [], fallthroughStylePatterns = [];
        if (options['tripleQuotedStrings']) {
            shortcutStylePatterns.push(
                [PR_STRING, /^(?:\'\'\'(?:[^\'\\]|\\[\s\S]|\'{1,2}(?=[^\']))*(?:\'\'\'|${'\$'})|\"\"\"(?:[^\"\\]|\\[\s\S]|\"{1,2}(?=[^\"]))*(?:\"\"\"|${'\$'})|\'(?:[^\\\']|\\[\s\S])*(?:\'|${'\$'})|\"(?:[^\\\"]|\\[\s\S])*(?:\"|${'\$'}))/,
                    null, '\'"']);
        } else if (options['multiLineStrings']) {
            shortcutStylePatterns.push(
                [PR_STRING, /^(?:\'(?:[^\\\']|\\[\s\S])*(?:\'|${'\$'})|\"(?:[^\\\"]|\\[\s\S])*(?:\"|${'\$'})|\`(?:[^\\\`]|\\[\s\S])*(?:\`|${'\$'}))/,
                    null, '\'"`']);
        } else {
            shortcutStylePatterns.push(
                [PR_STRING,
                    /^(?:\'(?:[^\\\'\r\n]|\\.)*(?:\'|${'\$'})|\"(?:[^\\\"\r\n]|\\.)*(?:\"|${'\$'}))/,
                    null, '"\'']);
        }
        if (options['verbatimStrings']) {
            fallthroughStylePatterns.push(
                [PR_STRING, /^@\"(?:[^\"]|\"\")*(?:\"|${'\$'})/, null]);
        }
        if (options['hashComments']) {
            if (options['cStyleComments']) {
                shortcutStylePatterns.push(
                    [PR_COMMENT, /^#(?:(?:define|elif|else|endif|error|ifdef|include|ifndef|line|pragma|undef|warning)\b|[^\r\n]*)/,
                        null, '#']);
                fallthroughStylePatterns.push(
                    [PR_STRING,
                        /^<(?:(?:(?:\.\.\/)*|\/?)(?:[\w-]+(?:\/[\w-]+)+)?[\w-]+\.h|[a-z]\w*)>/,
                        null]);
            } else {
                shortcutStylePatterns.push([PR_COMMENT, /^#[^\r\n]*/, null, '#']);
            }
        }
        if (options['cStyleComments']) {
            fallthroughStylePatterns.push([PR_COMMENT, /^\/\/[^\r\n]*/, null]);
            fallthroughStylePatterns.push(
                [PR_COMMENT, /^\/\*[\s\S]*?(?:\*\/|${'\$'})/, null]);
        }
        if (options['regexLiterals']) {
            let REGEX_LITERAL = (
                '/(?=[^/*])'
                + '(?:[^/\\x5B\\x5C]'
                + '|\\x5C[\\s\\S]'
                + '|\\x5B(?:[^\\x5C\\x5D]|\\x5C[\\s\\S])*(?:\\x5D|${'\$'}))+'
                + '/');
            fallthroughStylePatterns.push(
                ['lang-regex',
                    new RegExp('^' + REGEXP_PRECEDER_PATTERN + '(' + REGEX_LITERAL + ')')
                ]);
        }

        let keywords = options['keywords'].replace(/^\s+|\s+${'\$'}/g, '');
        if (keywords.length) {
            fallthroughStylePatterns.push(
                [PR_KEYWORD,
                    new RegExp('^(?:' + keywords.replace(/\s+/g, '|') + ')\\b'), null]);
        }

        shortcutStylePatterns.push([PR_PLAIN, /^\s+/, null, ' \r\n\t\xA0']);
        fallthroughStylePatterns.push(
            [PR_LITERAL, /^@[a-z_${'\$'}][a-z_${'\$'}@0-9]*/i, null],
            [PR_TYPE, /^@?[A-Z]+[a-z][A-Za-z_${'\$'}@0-9]*/, null],
            [PR_PLAIN, /^[a-z_${'\$'}][a-z_${'\$'}@0-9]*/i, null],
            [PR_LITERAL,
                new RegExp(
                    '^(?:'
                    + '0x[a-f0-9]+'
                    + '|(?:\\d(?:_\\d+)*\\d*(?:\\.\\d*)?|\\.\\d\\+)'
                    + '(?:e[+\\-]?\\d+)?'
                    + ')'
                    + '[a-z]*', 'i'),
                null, '0123456789'],
            [PR_PUNCTUATION, /^.[^\s\w\.${'\$'}@\'\"\`\/\#]*/, null]);

        return createSimpleLexer(shortcutStylePatterns, fallthroughStylePatterns);
    }

    let decorateSource = sourceDecorator({
        'keywords': ALL_KEYWORDS,
        'hashComments': true,
        'cStyleComments': true,
        'multiLineStrings': true,
        'regexLiterals': true
    });
    
    function recombineTagsAndDecorations(job) {
        let sourceText = job.source;
        let extractedTags = job.extractedTags;
        let decorations = job.decorations;

        let html = [];
        let outputIdx = 0;

        let openDecoration = null;
        let currentDecoration = null;
        let tagPos = 0;
        let decPos = 0;
        let tabExpander = makeTabExpander(window['PR_TAB_WIDTH']);

        let adjacentSpaceRe = /([\r\n ]) /g;
        let startOrSpaceRe = /(^| ) /gm;
        let newlineRe = /\r\n?|\n/g;
        let trailingSpaceRe = /[ \r\n]${'\$'}/;
        let lastWasSpace = true;
        
        let isIE678 = window['_pr_isIE6']();
        let lineBreakHtml = (
            isIE678
                ? (job.sourceNode.tagName === 'PRE'
                ? (isIE678 === 6 ? '&#160;\r\n' :
                    isIE678 === 7 ? '&#160;<br>\r' : '&#160;\r')
                : '&#160;<br />')
                : '<br />');
        let numberLines = job.sourceNode.className.match(/\blinenums\b(?::(\d+))?/);
        let lineBreaker;
        if (numberLines) {
            let lineBreaks = [];
            for (let i = 0; i < 10; ++i) {
                lineBreaks[i] = lineBreakHtml + '</li><li class="L' + i + '">';
            }
            let lineNum = numberLines[1] && numberLines[1].length
                ? numberLines[1] - 1 : 0;  // Lines are 1-indexed
            html.push('<ol class="linenums"><li class="L', (lineNum) % 10, '"');
            if (lineNum) {
                html.push(' value="', lineNum + 1, '"');
            }
            html.push('>');
            lineBreaker = function () {
                let lb = lineBreaks[++lineNum % 10];
                return openDecoration
                    ? ('</span>' + lb + '<span class="' + openDecoration + '">') : lb;
            };
        } else {
            lineBreaker = lineBreakHtml;
        }
        function emitTextUpTo(sourceIdx) {
            if (sourceIdx > outputIdx) {
                if (openDecoration && openDecoration !== currentDecoration) {
                    html.push('</span>');
                    openDecoration = null;
                }
                if (!openDecoration && currentDecoration) {
                    openDecoration = currentDecoration;
                    html.push('<span class="', openDecoration, '">');
                }
                let htmlChunk = textToHtml(
                    tabExpander(sourceText.substring(outputIdx, sourceIdx)))
                    .replace(lastWasSpace
                        ? startOrSpaceRe
                        : adjacentSpaceRe, '${'\$'}1&#160;');
                lastWasSpace = trailingSpaceRe.test(htmlChunk);
                html.push(htmlChunk.replace(newlineRe, lineBreaker));
                outputIdx = sourceIdx;
            }
        }

        while (true) {
            let outputTag;
            if (tagPos < extractedTags.length) {
                if (decPos < decorations.length) {
                    outputTag = extractedTags[tagPos] <= decorations[decPos];
                } else {
                    outputTag = true;
                }
            } else {
                outputTag = false;
            }
            if (outputTag) {
                emitTextUpTo(extractedTags[tagPos]);
                if (openDecoration) {
                    html.push('</span>');
                    openDecoration = null;
                }
                html.push(extractedTags[tagPos + 1]);
                tagPos += 2;
            } else if (decPos < decorations.length) {
                emitTextUpTo(decorations[decPos]);
                currentDecoration = decorations[decPos + 1];
                decPos += 2;
            } else {
                break;
            }
        }
        emitTextUpTo(sourceText.length);
        if (openDecoration) {
            html.push('</span>');
        }
        if (numberLines) {
            html.push('</li></ol>');
        }
        job.prettyPrintedHtml = html.join('');
    }
    let langHandlerRegistry = {};
    function registerLangHandler(handler, fileExtensions) {
        for (let i = fileExtensions.length; --i >= 0;) {
            let ext = fileExtensions[i];
            if (!langHandlerRegistry.hasOwnProperty(ext)) {
                langHandlerRegistry[ext] = handler;
            } else if ('console' in window) {
                console['warn']('cannot override language handler %s', ext);
            }
        }
    }

    function langHandlerForExtension(extension, source) {
        if (!(extension && langHandlerRegistry.hasOwnProperty(extension))) {
            extension = /^\s*</.test(source)
                ? 'default-markup'
                : 'default-code';
        }
        return langHandlerRegistry[extension];
    }

    registerLangHandler(decorateSource, ['default-code']);
    registerLangHandler(
        createSimpleLexer(
            [],
            [
                [PR_PLAIN, /^[^<?]+/],
                [PR_DECLARATION, /^<!\w[^>]*(?:>|${'\$'})/],
                [PR_COMMENT, /^<\!--[\s\S]*?(?:-\->|${'\$'})/],
                // Unescaped content in an unknown language
                ['lang-', /^<\?([\s\S]+?)(?:\?>|${'\$'})/],
                ['lang-', /^<%([\s\S]+?)(?:%>|${'\$'})/],
                [PR_PUNCTUATION, /^(?:<[%?]|[%?]>)/],
                ['lang-', /^<xmp\b[^>]*>([\s\S]+?)<\/xmp\b[^>]*>/i],
                // Unescaped content in javascript.  (Or possibly vbscript).
                ['lang-js', /^<script\b[^>]*>([\s\S]*?)(<\/script\b[^>]*>)/i],
                // Contains unescaped stylesheet content
                ['lang-css', /^<style\b[^>]*>([\s\S]*?)(<\/style\b[^>]*>)/i],
                ['lang-in.tag', /^(<\/?[a-z][^<>]*>)/i]
            ]),
        ['default-markup', 'htm', 'html', 'mxml', 'xhtml', 'xml', 'xsl']);
    registerLangHandler(
        createSimpleLexer(
            [
                [PR_PLAIN, /^[\s]+/, null, ' \t\r\n'],
                [PR_ATTRIB_VALUE, /^(?:\"[^\"]*\"?|\'[^\']*\'?)/, null, '\"\'']
            ],
            [
                [PR_TAG, /^^<\/?[a-z](?:[\w.:-]*\w)?|\/?>${'\$'}/i],
                [PR_ATTRIB_NAME, /^(?!style[\s=]|on)[a-z](?:[\w:-]*\w)?/i],
                ['lang-uq.val', /^=\s*([^>\'\"\s]*(?:[^>\'\"\s\/]|\/(?=\s)))/],
                [PR_PUNCTUATION, /^[=<>\/]+/],
                ['lang-js', /^on\w+\s*=\s*\"([^\"]+)\"/i],
                ['lang-js', /^on\w+\s*=\s*\'([^\']+)\'/i],
                ['lang-js', /^on\w+\s*=\s*([^\"\'>\s]+)/i],
                ['lang-css', /^style\s*=\s*\"([^\"]+)\"/i],
                ['lang-css', /^style\s*=\s*\'([^\']+)\'/i],
                ['lang-css', /^style\s*=\s*([^\"\'>\s]+)/i]
            ]),
        ['in.tag']);
    registerLangHandler(
        createSimpleLexer([], [[PR_ATTRIB_VALUE, /^[\s\S]+/]]), ['uq.val']);
    registerLangHandler(sourceDecorator({
        'keywords': CPP_KEYWORDS,
        'hashComments': true,
        'cStyleComments': true
    }), ['c', 'cc', 'cpp', 'cxx', 'cyc', 'm']);
    registerLangHandler(sourceDecorator({
        'keywords': 'null true false'
    }), ['json']);
    registerLangHandler(sourceDecorator({
        'keywords': CSHARP_KEYWORDS,
        'hashComments': true,
        'cStyleComments': true,
        'verbatimStrings': true
    }), ['cs']);
    registerLangHandler(sourceDecorator({
        'keywords': JAVA_KEYWORDS,
        'cStyleComments': true
    }), ['java']);
    registerLangHandler(sourceDecorator({
        'keywords': SH_KEYWORDS,
        'hashComments': true,
        'multiLineStrings': true
    }), ['bsh', 'csh', 'sh']);
    registerLangHandler(sourceDecorator({
        'keywords': PYTHON_KEYWORDS,
        'hashComments': true,
        'multiLineStrings': true,
        'tripleQuotedStrings': true
    }), ['cv', 'py']);
    registerLangHandler(sourceDecorator({
        'keywords': PERL_KEYWORDS,
        'hashComments': true,
        'multiLineStrings': true,
        'regexLiterals': true
    }), ['perl', 'pl', 'pm']);
    registerLangHandler(sourceDecorator({
        'keywords': RUBY_KEYWORDS,
        'hashComments': true,
        'multiLineStrings': true,
        'regexLiterals': true
    }), ['rb']);
    registerLangHandler(sourceDecorator({
        'keywords': JSCRIPT_KEYWORDS,
        'cStyleComments': true,
        'regexLiterals': true
    }), ['js']);
    registerLangHandler(sourceDecorator({
        'keywords': DART_KEYWORDS,
        'cStyleComments': true,
        'regexLiterals': true
    }), ['dart']);
    registerLangHandler(
        createSimpleLexer([], [[PR_STRING, /^[\s\S]+/]]), ['regex']);

    function applyDecorator(job) {
        let sourceCodeHtml = job.sourceCodeHtml;
        let opt_langExtension = job.langExtension;
        job.prettyPrintedHtml = sourceCodeHtml;

        try {
            let sourceAndExtractedTags = extractTags(sourceCodeHtml);
            let source = sourceAndExtractedTags.source;
            job.source = source;
            job.basePos = 0;
            job.extractedTags = sourceAndExtractedTags.tags;
            langHandlerForExtension(opt_langExtension, source)(job);
            recombineTagsAndDecorations(job);
        } catch (e) {
            if ('console' in window) {
                console['log'](e && e['stack'] ? e['stack'] : e);
            }
        }
    }

    function prettyPrintOne(sourceCodeHtml, opt_langExtension) {
        let job = {
            sourceCodeHtml: sourceCodeHtml,
            langExtension: opt_langExtension
        };
        applyDecorator(job);
        return job.prettyPrintedHtml;
    }

    function prettyPrint(opt_whenDone) {
        function byTagName(tn) {
            return document.getElementsByTagName(tn);
        }
        let codeSegments = [byTagName('pre'), byTagName('code'), byTagName('xmp')];
        let elements = [];
        for (let i = 0; i < codeSegments.length; ++i) {
            for (let j = 0, n = codeSegments[i].length; j < n; ++j) {
                elements.push(codeSegments[i][j]);
            }
        }
        codeSegments = null;

        let clock = Date;
        if (!clock['now']) {
            clock = {
                'now': function () {
                    return (new Date).getTime();
                }
            };
        }
        let k = 0;
        let prettyPrintingJob;

        function doWork() {
            let endTime = (window['PR_SHOULD_USE_CONTINUATION'] ?
                clock.now() + 250 /* ms */ :
                Infinity);
            for (; k < elements.length && clock.now() < endTime; k++) {
                let cs = elements[k];
                if (cs.className && cs.className.indexOf('source') >= 0) {
                    let langExtension = cs.className.match(/\blang-(\w+)\b/);
                    if (langExtension) {
                        langExtension = langExtension[1];
                    }
                    let nested = false;
                    for (let p = cs.parentNode; p; p = p.parentNode) {
                        if ((p.tagName === 'pre' || p.tagName === 'code' ||
                            p.tagName === 'xmp') &&
                            p.className && p.className.indexOf('source') >= 0) {
                            nested = true;
                            break;
                        }
                    }
                    if (!nested) {
                        let content = getInnerHtml(cs);
                        content = content.replace(/(?:\r\n?|\n)${'\$'}/, '');
                        prettyPrintingJob = {
                            sourceCodeHtml: content,
                            langExtension: langExtension,
                            sourceNode: cs
                        };
                        applyDecorator(prettyPrintingJob);
                        replaceWithPrettyPrintedHtml();
                    }
                }
            }
            if (k < elements.length) {
                setTimeout(doWork, 250);
            } else if (opt_whenDone) {
                opt_whenDone();
            }
        }

        function replaceWithPrettyPrintedHtml() {
            let newContent = prettyPrintingJob.prettyPrintedHtml;
            if (!newContent) {
                return;
            }
            let cs = prettyPrintingJob.sourceNode;
            if (!isRawContent(cs)) {
                cs.innerHTML = newContent;
            } else {
                let pre = document.createElement('PRE');
                for (let i = 0; i < cs.attributes.length; ++i) {
                    let a = cs.attributes[i];
                    if (a.specified) {
                        let aname = a.name.toLowerCase();
                        if (aname === 'class') {
                            pre.className = a.value;  // For IE 6
                        } else {
                            pre.setAttribute(a.name, a.value);
                        }
                    }
                }
                pre.innerHTML = newContent;
                cs.parentNode.replaceChild(pre, cs);
                cs = pre;
            }
        }

        doWork();
    }

    window['PR_normalizedHtml'] = normalizedHtml;
    window['prettyPrintOne'] = prettyPrintOne;
    window['prettyPrint'] = prettyPrint;
    window['PR'] = {
        'combinePrefixPatterns': combinePrefixPatterns,
        'createSimpleLexer': createSimpleLexer,
        'registerLangHandler': registerLangHandler,
        'sourceDecorator': sourceDecorator,
        'PR_ATTRIB_NAME': PR_ATTRIB_NAME,
        'PR_ATTRIB_VALUE': PR_ATTRIB_VALUE,
        'PR_COMMENT': PR_COMMENT,
        'PR_DECLARATION': PR_DECLARATION,
        'PR_KEYWORD': PR_KEYWORD,
        'PR_LITERAL': PR_LITERAL,
        'PR_NOCODE': PR_NOCODE,
        'PR_PLAIN': PR_PLAIN,
        'PR_PUNCTUATION': PR_PUNCTUATION,
        'PR_SOURCE': PR_SOURCE,
        'PR_STRING': PR_STRING,
        'PR_TAG': PR_TAG,
        'PR_TYPE': PR_TYPE
    };    
})();
""";
