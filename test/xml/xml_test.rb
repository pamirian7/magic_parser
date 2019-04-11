#! /usr/bin/ruby

$: << '.'

require 'xml'

text = '<?xml version="1.0" encoding="UTF-8"?>'

#xml = XML.new( text: text )
#xml = XML.new( file: 'form.xsl' )
xml = XML.new( file: 'data.xml' )

puts xml.print 
# puts xml.to_s
