def format_date(date)
  date.strftime('%B %d, %Y')
end

def site_title_logo
  data.settings.site_title_logo_image
  rescue NameError
    nil
end

def title(title)
  @page_title = title
end

def format_title
  separator = ' | '
  if data.settings.reverse_title
    if current_article
      current_article.title
    elsif @page_title
      @page_title
    else
      data.settings.site_title
    end
  else
    if current_article
      current_article.title
    elsif @page_title
      @page_title
    else
      data.settings.site_title
    end
  end
end

def page_description
  if current_article && current_article.summary(100)
    description = current_article.summary
  elsif @page_title
    description = @page_title + ' page of ' + data.settings.site_title
  else
    description = data.settings.site_description
  end
  # remove html tags
  description.gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, '').gsub(/[\r\n]/, ' ')
end

def page_meta
  if current_article && current_article.data.meta
    meta = current_article.data.meta
  else
    page_description[0...160]
  end
end

def strip_images(html)
  doc = Nokogiri::HTML(html)
  doc.search('img').each { |i| i.parent.remove }
  doc.to_html
end

def analytics_account
  google_analytics_account
  rescue NameError
    nil
end
