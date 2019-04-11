=begin
parser = {
	'name' => [/pattern/, {subparser}
	...
	]
}

# token
parsed
	text, name, [breakdown]
=end

require 'basic/basic'

class Token < Array
	attr_accessor :text, :name

	def initialize n = nil, t = nil
		check_args [n, t], [[String, NilClass], [String, NilClass]]

		@name, @text, @@tab = n, t, 0

		update
	end

	def print_verbose
		print true
	end

	def print verbose = false
		out = ''

		if name || verbose
			val = @@tab
			if !verbose then val -= 1 end
			out += "\t" * val
			out += "#{name} |#{text}|\n"
		end

		@@tab += 1
		each { |s|
			out += s.print verbose
		}
		@@tab -= 1

		out
	end

	def to_s
		update
	end

	def update
		if length == 0
			return text
		end

		text = ''

		each { |t|
			text += t.update
		}

		text
	end

	def write filename = nil
		write_file( filename ){ to_s }
	end
end

class Rule
	attr_reader :name, :subrule, :pattern

	def initialize n, pa = /.*/, s = {}
		check_args [n, pa], [String, Regexp]

		@pattern = pa
		@name = n

		if block_given?
			s = yield
		end
		s.assert_type Hash

		@subrule = RuleSet.new( s )
	end

	def to_s
		out = "Rule: #{name}, pattern: #{pattern}, subrules: #{subrule.length}\n"
		subrule.each { |name, s|
			out += s.to_s
		}
		out
	end

	def apply token
		token.assert_type Token

		result = token.dup.clear

		if token.length == 0
			token << Token.new( nil, token.text )
		end

		token.each { |subtoken|
			if subtoken.name
				result << subtoken
			else
				cursor = 0
				subtoken.text.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
				r = subtoken.text.scan pattern

				r.each { |match|
					if match.kind_of? Array
						match = match[0]
					end

					offset = subtoken.text.index match, cursor
					if offset != cursor
						text = subtoken.text.slice(cursor .. offset-1)
						result << Token.new( nil, text )
						cursor = offset
					end

					offset = cursor + match.length
					text = subtoken.text.slice(cursor .. offset-1)
					new_subtoken = Token.new( name, text )

					if subrule
						new_subtoken = subrule.apply( new_subtoken )
					end

					result << new_subtoken
					cursor = offset
				}

				if cursor < subtoken.text.length
					text = subtoken.text.slice(cursor .. -1)
					result << Token.new( nil, text )
				end
			end
		}

		result
	end
end

class RuleSet < Hash
	def initialize rules = {}
		if block_given?
			rules = yield
		end

		rules.assert_type Hash

		rules.each { |name, rule|
			pattern, subrule = rule
			if !subrule
				subrule = {}
		  end
			self[name] = Rule.new( name, pattern, subrule )
		}
	end

	def to_s
		out = ''
		each { |name, rule|
			out += "#{rule}\n"
		}
		out
	end

	def apply token
		if token.kind_of? String
			token = Token.new( token )
		end

		token.assert_type Token

		each { |name, rule|
			token = rule.apply token
		}

		token
	end

	def parse text: '', file: nil
		Parser.parse text, file
	end

	def RuleSet.parse text: '', file: nil
		check_args [text, file], [String, [String, NilClass]]

		if file
			text = File.read( file )
		end

		apply Token.new( nil, text.force_encoding('UTF-8') )
	end
end

class Parser < RuleSet
end

class Document < Token
	@@parser = nil

	def initialize text: '', file: nil
		check_args [text, file], [String, [String, NilClass]]

		assert @@parser, 'Parser must be assigned'

		result = @@parser.parse( text: text, file: file )
		concat result
		super result.name, result.text
	end
end
