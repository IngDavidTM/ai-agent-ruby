module ApplicationHelper
  class CodeBlockRenderer < Redcarpet::Render::HTML
    def block_code(code, language)
      <<-HTML.html_safe
        <div class="code-block-wrapper">
          <div class="code-header">
            <span class="code-lang">#{language}</span>
            <button class="copy-code-btn" onclick="copyCode(this)">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 17.929H6c-1.105 0-2-.912-2-2.036V5.036C4 3.91 4.895 3 6 3h8c1.105 0 2 .911 2 2.036v1.866m-6 .17h8c1.105 0 2 .91 2 2.035v10.857C20 21.09 19.105 22 18 22h-8c-1.105 0-2-.911-2-2.036V9.107c0-1.124.895-2.036 2-2.036z"></path></svg>
              Copy code
            </button>
          </div>
          <pre><code class="#{language}">#{ERB::Util.html_escape(code)}</code></pre>
        </div>
      HTML
    end
  end

  def markdown(text)
    return "" if text.blank?
    
    renderer = CodeBlockRenderer.new(
      filter_html: true,
      hard_wrap: true,
      link_attributes: { rel: 'nofollow', target: "_blank" }
    )
    
    options = {
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      no_intra_emphasis: true,
      strikethrough: true,
      lax_spacing: true
    }
    
    markdown = Redcarpet::Markdown.new(renderer, options)
    markdown.render(text).html_safe
  end
end
