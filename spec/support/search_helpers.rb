module SearchHelpers

  def index_changed_instances
    ReindexRun.index_changed_model_instances
    # wait for indexing to complete
    Entity.__elasticsearch__.refresh_index!
    Notice.__elasticsearch__.refresh_index!
  end

  def submit_search(term)
    visit '/'

    fill_in 'search', with: term
    click_on 'submit'
  end

  def search_for(searches)
    query = searches.map { |k,v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')

    visit "/notices/search?#{query}"
  end

  def within_search_results_for(term)
    submit_search(term)
    within('.search-results') do
      yield if block_given?
    end
  end

  def open_dropdown_for_facet(facet)
    find(".dropdown-toggle.#{facet}").click
  end

  def open_and_select_facet(facet, facet_value)
    open_dropdown_for_facet(facet)

    within("ol.#{facet}") do
      # The gsub converts newlines to spaces as they can break the regex.
      # normalize_ws ensures that it doesn't matter if we did this.
      find(
        'a',
        text: /#{facet_value.gsub(/[\r\n]+/, ' ')}/,
        normalize_ws: true,
        visible: false
      ).click
    end
  end

  def submit_faceted_search(term, facet, facet_value)
    visit '/'

    fill_in 'search', with: term
    click_on 'submit'

    open_and_select_facet(facet, facet_value)
  end

  def within_faceted_search_results_for(term, facet, facet_value)
    submit_faceted_search(term, facet, facet_value)

    within('.search-results') do
      yield if block_given?
    end
  end

  def have_n_results(count)
    have_css('.result', count: count)
  end

  def have_active_facet_dropdown(facet_type)
    have_css(".dropdown.#{facet_type}.active")
  end

  def have_active_facet(facet_type, facet)
    find(".dropdown-toggle.#{facet_type}").click
    have_css('.dropdown-menu li.active a', text: /^#{facet}/)
  end

  def with_metadata(notice, options = {})
    metadata = {
      '_type' => "notice",
      '_score' => 0.5,
      '_index' => "development__notices",
      '_version' => nil,
      '_explanation' => nil,
      'sort' => nil,
      'class_name' => notice.class.to_s,
      'highlight' => nil
    }.merge(options)

    notice.as_indexed_json({}).merge(metadata)
  end
end
