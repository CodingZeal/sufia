module Sufia
  module RecordsHelperBehavior
    def add_field(key)
      more_or_less_button(key, 'adder', '+')
    end

    def subtract_field(key)
     more_or_less_button(key, 'remover', '-')
    end

    def help_icon(key)
      link_to '#', id: "generic_file_#{key.to_s}_help", rel: 'popover', 
        'data-content' => metadata_help(key),
        'data-original-title' => get_label(key) do
          content_tag 'i', '', class: "glyphicon glyphicon-question-sign large-icon"
      end
    end

    def metadata_help(key)
      I18n.t("sufia.metadata_help.#{key}", default: key.to_s.humanize)
    end

    def get_label(key)
      I18n.t("sufia.field_label.#{key}", default: key.to_s.humanize)
    end
  
    private

    def more_or_less_button(key, html_class, symbol)
      # TODO, there could be more than one element with this id on the page, but the fuctionality doesn't work without it.
      content_tag('button', class: "#{html_class} btn", id: "additional_#{key}_submit", name: "additional_#{key}") do
        (symbol + content_tag('span', class: 'sr-only') do
          "add another #{key.to_s}"
        end).html_safe
      end
    end
  end
end
