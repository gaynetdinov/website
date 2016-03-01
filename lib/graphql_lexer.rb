# -*- coding: utf-8 -*- #

require "rouge"

module Rouge
  module Lexers
    # Direct port of pygments Lexer.
    # See: https://bitbucket.org/birkenfeld/pygments-main/src/7304e4759ae65343d89a51359ca538912519cc31/pygments/lexers/functional.py?at=default#cl-2362
    class GraphQL < RegexLexer
      title "GraphQL"
      desc "GraphQL language (https://facebook.github.io/graphql)"

      tag 'graphql'
      aliases 'graphql'

      filenames '*.graphql'

      mimetypes 'application/graphql'

      BRACES = [
        ['\{', '\}', 'cb'],
        ['\[', '\]', 'sb'],
        ['\(', '\)', 'pa'],
        ['\<', '\>', 'lt']
      ]

      state :root do
        rule /\s+/m, Text
        rule /#.*$/, Comment::Single
        rule %r{\b(query|mutation|fragment|on|implements|interface|union|scalar|enum|input|extend|null|\.{3})\b}x, Keyword
        rule /\b(import|require|use|recur|quote|unquote|super|refer)\b(?![?!])/, Keyword::Namespace
        rule %r{%=|\*=|\*\*=|\+=|\-=|\^=|\|\|=|
             <=>|<(?!<|=)|>(?!<|=|>)|<=|>=|===|==|=~|!=|!~|(?=[\s\t])\?|
             (?<=[\s\t])!+|&(&&?|(?!\d))|\|\||\^|\*|\+|\-|/|
             \||\+\+|\-\-|\*\*|\/\/|\<\-|\<\>|<<|>>|=|\.|~~~}x, Operator
        rule %r{(?<!:)(:)([a-zA-Z_]\w*([?!]|=(?![>=]))?|\<\>|===?|>=?|<=?|
             <=>|&&?|%\(\)|%\[\]|%\{\}|\+\+?|\-\-?|\|\|?|\!|//|[%&`/\|]|
             \*\*?|=?~|<\-)|([a-zA-Z_]\w*([?!])?)(:)(?!:)}, Str::Symbol
        rule /[a-zA-Z_!][\w_]*[!\?]?/, Name
        rule /$[a-zA-Z_]\w*/, Name::Variable
        rule %r{\b(0[xX][0-9A-Fa-f]+|\d(_?\d)*(\.(?![^\d\s])
             (_?\d)*)?([eE][-+]?\d(_?\d)*)?|0[bB][01]+)\b}x, Num

        mixin :strings
      end

      state :strings do
        rule /"/, Str::Doc, :dqs
        rule /'.*?'/, Str::Single

        BRACES.each do |_, _, name|
          mixin :"braces_#{name}"
        end
      end

      BRACES.each do |lbrace, rbrace, name|
        state :"braces_#{name}" do
          rule /%[a-z]#{lbrace}/, Str::Double, :"braces_#{name}_intp"
          rule /%[A-Z]#{lbrace}/, Str::Double, :"braces_#{name}_no_intp"
        end

        state :"braces_#{name}_intp" do
          rule /#{rbrace}[a-z]*/, Str::Double, :pop!
          mixin :enddoublestr
        end

        state :"braces_#{name}_no_intp" do
          rule /.*#{rbrace}[a-z]*/, Str::Double, :pop!
        end
      end

      state :dqs do
        rule /"/, Str::Double, :pop!
        mixin :enddoublestr
      end

      state :interpoling do
        rule /#\{/, Str::Interpol, :interpoling_string
      end

      state :interpoling_string do
        rule /\}/, Str::Interpol, :pop!
        mixin :root
      end

      state :interpoling_symbol do
        rule /"/, Str::Symbol, :pop!
        mixin :interpoling
        rule /[^#"]+/, Str::Symbol
      end

      state :enddoublestr do
        mixin :interpoling
        rule /[^#"]+/, Str::Double
      end
    end
  end
end
