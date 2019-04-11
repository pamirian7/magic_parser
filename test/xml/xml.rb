require 'magic_parser'

class XMLParser < Parser
	def initialize
		# XML definition
		attr_value_w_space = "([\\'\"]?\\s*[\\w\\-\\.\/: ]+\\s*[\\'\"]?)"
		attr_value_no_space = "(\\s*[\\w\\-\\.\/:]+\\s*)"
		attr_name = "([\\w:-]+)"
		tag_name = attr_name
		attr_value = "(#{attr_value_w_space}|#{attr_value_no_space})"
		attribute = "#{attr_name}\\s*\\=\\s*#{attr_value}"

		super() { {
			'tag' => [ /\s*(\<\??\s*#{tag_name}(\s*#{attribute}\s*)*\/?\s*\??\>)\s*/, {
				'name' => /\<\??\s*#{tag_name}/,
				'attribute' => [ /\s*(#{attribute})\s*/, {
					'name' => /(#{attr_name})\s*\=/,
					'value' => /\=\s*#{attr_value}/
				}]
			}],
			'close_tag' => [ /\s*(\<\s*\/#{tag_name}\s*\>)\s*/, {
				'name' => /\<\s*\/#{tag_name}/
			}],
			'content' => /\s*(\w.*)/
		} }
	end
end

class XML < Document
	@@parser = XMLParser.new
end
