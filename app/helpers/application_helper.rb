module ApplicationHelper
  # Sets the page title and stores it in a content_for :page_title
  def title(page_title)
    content_for(:page_title) { page_title.to_s }
  end

  # Sets the page description and stores it in a content_for :page_description
  def description(page_description)
    content_for(:page_description) { page_description.to_s }
  end

  # Sets the Open Graph image URL and stores it in a content_for :og_image
  def og_image(image_url)
    content_for(:og_image) { image_url.to_s }
  end

  # Generates a structured data (JSON-LD) script for the page
  def structured_data(type = 'WebSite', **options)
    data = {
      '@context': 'https://schema.org',
      '@type': type
    }.merge(options)

    content_for(:structured_data) do
      content_tag(:script, data.to_json.html_safe, type: 'application/ld+json')
    end
  end

  # Generates meta tags for social sharing
  def social_meta_tags(title: nil, description: nil, image: nil, url: nil)
    title ||= content_for(:page_title) || 'LocalServiceHub'
    description ||= content_for(:page_description) || 'Find and book trusted local service providers'
    image ||= content_for(:og_image) || asset_url('og-default.jpg')
    url ||= request.original_url

    safe_join([
      tag.meta(property: 'og:title', content: title),
      tag.meta(property: 'og:description', content: description),
      tag.meta(property: 'og:image', content: image),
      tag.meta(property: 'og:url', content: url),
      tag.meta(name: 'twitter:card', content: 'summary_large_image'),
      tag.meta(name: 'twitter:title', content: title),
      tag.meta(name: 'twitter:description', content: description),
      tag.meta(name: 'twitter:image', content: image)
    ], "\n")
  end

  # Generates breadcrumbs for the current page
  def breadcrumbs(*items)
    content_tag :nav, class: 'flex items-center text-sm text-gray-600', 'aria-label': 'Breadcrumb' do
      content_tag :ol, class: 'flex items-center space-x-2' do
        safe_join(items.map.with_index do |item, index|
          content_tag :li, class: 'flex items-center' do
            concat(link_to(item[:title], item[:url], class: 'text-indigo-600 hover:text-indigo-800 transition-colors duration-200'))
            if index < items.length - 1
              concat(content_tag(:span, '/', class: 'mx-2 text-gray-400'))
            end
          end
        end)
      end
    end
  end

  # Returns the current year for copyright notices
  def current_year
    Time.current.year
  end

  # Adds active class to the current navigation link
  def nav_link_to(name, path, options = {})
    options[:class] ||= ''
    options[:class] += ' active' if current_page?(path)
    link_to name, path, options
  end
end
