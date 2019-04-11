magic_parser
============

The magic_parser ruby gem provides an easy way to do most simple parsing of text files. The grammar for a file format is written as a hierarchy of regular expression/tag pairs. Here is an example taken from the definition of xml:

xml.rb

```ruby
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
```

With this you can parse a simple bit of text:

```ruby
text = '<?xml version="1.0" encoding="UTF-8"?>'

xml = XML.new( text: text )
```

or an entire file. For a file called data.xml:

```
<?xml version="1.0" encoding="UTF-8"?>
<catalog>
  <cd>
    <title>Empire Burlesque</title>
    <artist>Bob Dylan</artist>
    <country>USA</country>
    <company>Columbia</company>
    <price>10.90</price>
    <year>1985</year>
  </cd>
</catalog>
```

your code can look like:

```ruby
require 'xml'

catalog = XML.new 'data.xml'
catalog.print
```

which will output:

```
tag, |<?xml version="1.0" encoding="UTF-8"?>|
	name, |xml|
	attribute, |version="1.0"|
		name, |version|
		value, |"1.0"|
	attribute, |encoding="UTF-8"|
		name, |encoding|
		value, |"UTF-8"|
tag, |<catalog>|
	name, |catalog|
tag, |<cd>|
	name, |cd|
tag, |<title>|
	name, |title|
content, |Empire Burlesque|
close_tag, |</title>|
	name, |title|
tag, |<artist>|
	name, |artist|
content, |Bob Dylan|
close_tag, |</artist>|
	name, |artist|
tag, |<country>|
	name, |country|
content, |USA|
close_tag, |</country>|
	name, |country|
tag, |<company>|
	name, |company|
content, |Columbia|
close_tag, |</company>|
	name, |company|
tag, |<price>|
	name, |price|
content, |10.90|
close_tag, |</price>|
	name, |price|
tag, |<year>|
	name, |year|
content, |1985|
close_tag, |</year>|
	name, |year|
close_tag, |</cd>|
	name, |cd|
close_tag, |</catalog>|
	name, |catalog|
```

The Token class is an Array of Tokens and has 'name' and 'text' attributes. A Document is a kind of Token. You can iterate through the parsed file examining and editing tags and content. Given the prior code:

```ruby
# print a list of titles and artists
catalog.each {|title|
	puts title.name
	puts title.text

	index = 0
	title.each {|field|
		if field.name == 'tag' && field[0].name == 'artist'
			# this should be the artist name
			puts title[index+1].text
		end
		index += 1
	}
}
```

It is important to note that in definitions order matters! The most specific cases must be matched before the more general ones.

Features
--------
- definitions are entirely based on regular expressions
- definitions are stored as hash trees, so they can build on each other (e.g. HTML can be defined as an extension of XML)

Future Expansion
----------------

This will be the basis for further projects such as an xslt processor. A logical next step will be to add XPath features.

Installation
------------

Install parser by running:

	sudo gem install magic_parser

Contribute
----------

- Issue Tracker: https://github.com/pamirian7/magic_parser/issues
- Source Code: https://github.com/pamirian7/magic_parser

License
-------

(The MIT License)

Copyright © Paul Amirian

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
