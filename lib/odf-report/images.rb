module ODFReport

  module Images

    IMAGE_DIR_NAME = "Pictures"

    def find_image_name_matches(content)

      @images.each_pair do |image_name, path|
        if node = content.xpath("//draw:frame[@draw:name='#{image_name}']/draw:image").first
          placeholder_path = node.attribute('href').value
          @image_names_replacements[path] = ::File.join(IMAGE_DIR_NAME, ::File.basename(placeholder_path))
        end
      end

    end

    def replace_images(file)

      return if @images.empty?

      @image_names_replacements.each_pair do |path, template_image|

        file.output_stream.put_next_entry(template_image)
        file.output_stream.write ::File.read(path)

      end

    end # replace_images

		def replace_images_base64(content)

			return if @images_base64.empty?

			@images_base64.each_pair do |image_name, base64_data|
				if node = content.xpath("//draw:frame[@draw:name='#{image_name}']/draw:image").first
					office_binary_data = Nokogiri::XML::Node.new "office:binary-data", content
					office_binary_data.content = base64_data
					node.add_child(office_binary_data)
					node.xpath("@xlink:href|@xlink:type|@xlink:show|@xlink:actuate").remove
				end
			end

		end # replace_image_base64

    # newer versions of LibreOffice can't open files with duplicates image names
    def avoid_duplicate_image_names(content)

      nodes = content.xpath("//draw:frame[@draw:name]")

      nodes.each_with_index do |node, i|
        node.attribute('name').value = "pic_#{i}"
      end

    end

  end

end
