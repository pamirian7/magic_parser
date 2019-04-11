require 'date'
require 'bigdecimal'
require 'bigdecimal/util'

def assert cond, msg = 'Error!'
	if !cond then raise msg end
end

def error msg = 'Error!'
	assert false, msg
end

def check_args var, type
	if var.class != Array then var = [var] end
	if type.class != Array then type = [type] end

	assert (var.length == type.length), 'array lengths must match'

	ctr = 0
	while ctr < var.length
		var[ctr].assert_type type[ctr]
		ctr += 1
	end
end

class Integer
  def factorial_recursive
    self <= 1 ? 1 : self * (self - 1).factorial
  end

  def factorial_iterative
    f = 1; for i in 1..self; f *= i; end; f
  end

  alias :factorial :factorial_iterative
  alias :fact :factorial
end

class Object
	def assert_type clas, msg = nil
		msg ||= "Bad type: expected #{clas}, got #{self.class}"
		if !clas.kind_of? Array then clas = [clas] end
		clas.each { |c|
			if self.kind_of?( c ) then return; end
		}
		assert false, "Bad type: expected #{clas}, got #{self.class}"
	end

	def stringable?
		respond_to? 'to_s'
	end
end

class String
	def pad size, char
		size -= length
		if size > 0 then replace self+(char*size) end
	end

	def addslashes
		gsub(/['"\\\x0]/,'\\\\\0')
	end

	def addslashes!
		replace addslashes
	end

	def write filename = nil
		write_file( filename ){ self }
	end
end

def write_file filename = nil
	file = filename ? File.open( filename, 'w' ) : Tempfile.new( filename )

	file.print yield
	file.close
end

class Array
	def find
		ctr = 0
		each { |e|
			if yield( e )
				return ctr
			end
		}

		nil
	end

	def prep_insert table
		set = []

		each { |line|
			set = "( #{line.join ','} )"
		}

		set = "insert into #{table} values ( #{set.join ','} ),"
	end

	def assert_all_types clas, msg = nil
		each { |x|
			x.assert_type clas, msg
		}
	end

	def contains? *elements
		elements.each { |element|
			if !include?( element ) then return false end
		}
		true
	end

	# buggy Ruby is supposed to do this already...
	def to_s
		collect { |x|
			x.to_s
		}.join
	end
end

class Stack < Array
	def push x
	end

	def pop
	end
end

#class Queue < Array
#	def nxt
#	end

#	def add x
#	end
#end

class Hash
	def defaults defs
		defs.assert_type Hash

		keyset = keys
		defs.each { |k, v|
			if !keyset.include? k then self[k] = v end
		}
	end

	def prep_insert table
		set = []

		each { |k, v|
			set = "( #{k}, #{v} )"
		}

		set = "insert into #{table} values ( #{set.join ','} ),"
	end

	def select *items
		r = {}

		items.each { |item|
			r[item] = self[item]
		}

		r
	end

	def create_path *path
		entry = self
		endcap = path.pop
		final = path.pop

		path.each { |e|
			if !entry[e] then entry[e] = {} end
			entry = entry[e]
		}

		if !entry[final] then entry[final] = endcap end
	end

	def required *elements
		elements.each { |element|
			assert has_key?( element ), "required key missing: #{element}"
		}
	end
end

class Value
	attr_accessor :value

	def initialize v = 0
		set v
	end

	def set x
		x.assert_type Numeric
		@value = Float.new x
	end

	def to_i
		@value.to_i
	end

	def to_f
		@value
	end
end

class Date
	def american sep = '/'
		"%02d#{sep}%02d#{sep}%02d" % [month, day, year]
	end
end

class Time
	def Time.stamp
		n = Time.now
		"%d%02d%02d-%02d%02d%02d" % [n.year, n.month, n.day, n.hour, n.min, n.sec]
	end
end

class FileName < String
end
