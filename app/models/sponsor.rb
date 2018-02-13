class Sponsor
  class << self
    def data
      load_data = -> {
        YAML.load_file(Rails.root.join('db/sponsors.yml'))
      }
      return load_data.call if Rails.env.development?
      @data ||= load_data.call
    end

    def title_sponsor
      new(data['title_sponsor'])
    end

    def other_sponsors
      data['other_sponsors'].map { |attrs| new(attrs) }
    end

    def all
      %i[title_sponsor other_sponsors]
        .map { |m| Array(send(m)) }
        .reduce { |all, sponsors| all + sponsors }
    end
  end

  include ActiveModel::Model

  attr_accessor :slug, :name, :main_url, :logo_image, :description,
    :additional_links, :hashtags

  def additional_links
    @additional_links ||= {}
  end

  def hashtags
    @hashtags ||= []
  end
end
