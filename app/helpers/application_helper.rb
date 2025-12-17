module ApplicationHelper
  def markdown(text)
    return "" if text.blank?
    
    renderer = Redcarpet::Render::HTML.new(
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
    sanitize(markdown.render(text))
  end
end
