module ODFReport
  class ImageBase64

    def initialize(opts, &block)
      @name = opts[:name]
      @data_field = opts[:data_field]

      unless @value = opts[:value]

        if block_given?
          @block = block

        else
          @block = lambda { |item| self.extract_value(item) }
        end

      end

    end

    def replace!(content, data_item = nil)
				if node = content.xpath("//draw:frame[@draw:name='#{@name}']/draw:image").first
					office_binary_data = Nokogiri::XML::Node.new "office:binary-data", get_value(data_item)
					office_binary_data.content = base64_data
					node.add_child(office_binary_data)
					node.xpath("@xlink:href|@xlink:type|@xlink:show|@xlink:actuate").remove
				end
    end

    def get_value(data_item = nil)
      @value || @block.call(data_item) || ''
    end

    def extract_value(data_item)
      return unless data_item

      key = @data_field || @name

      if data_item.is_a?(Hash)
        data_item[key] || data_item[key.to_s.downcase] || data_item[key.to_s.upcase] || data_item[key.to_s.downcase.to_sym]

      elsif data_item.respond_to?(key.to_s.downcase.to_sym)
        data_item.send(key.to_s.downcase.to_sym)

      else
        raise "Can't find field [#{key}] in this #{data_item.class}"

      end

    end

  end
end
