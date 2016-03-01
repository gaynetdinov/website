require "CGI"

class FencedCodeBlock < Nanoc::Filter
  identifier :fenced_code_block

  CONVERSIONS = {
    "graphql" => "text"
  }

  def run(content, params = {})
    content.gsub(/(^`{3}(\S+)\s*$(?:\s*#\s*(filename|description):\s*(.*?)\s*)?$(.+?)\s*^`{3})+?/m) do |match|
      lang_spec  = $2 || 'text'
      caption_type = $3
      caption_content = $4
      code_block = $5

      if CONVERSIONS[lang_spec]
        lang_spec = CONVERSIONS[lang_spec]
      end

      rest = '">'
      code_block.gsub!("[:backtick:]", "`")
      rest << CGI::escapeHTML(code_block)

      if caption_type
        caption = "<figcaption class='#{caption_type}'>#{caption_content}</figcaption>\n"
      else
        caption = nil
      end

      replacement = "<figure class='codeblock'>"

      if caption_type == 'filename'
        replacement << caption
      end

      replacement << "<pre"

      if lang_spec && lang_spec.length > 0
        if lang_spec == "bash"
          replacement << ' class="terminal'
          replacement << rest
          replacement << "</pre>\n"
        else
          replacement << '><code class="language-'
          replacement << lang_spec
          replacement << rest
          replacement << "</code></pre>\n"
        end
      end

      if caption_type == 'description'
        replacement << caption
      end

      replacement << "</figure>"

    end
  end
end
