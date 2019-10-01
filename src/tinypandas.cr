require "gzip"
require "./DataFrame"

class Tinypandas
  alias DFhash = Hash(String, Array(Int32|Int64|Float32|Float64|String))
  alias HeaderType = Int32|Int64|Array(String)|Nil # when Nil mean no header in file, so set 0..xx to columns
  alias IndexColType  = HeaderType # when Nil mean no index in file, so set 0..xx to index
  alias SkiprowsType = Int32|Array(Int32)|Bool
  alias VTYPE = Float32|Float64|Int32|Int64|String
  property comment = /^#/
  property row_num : Int32|Int64 = 0
  #property wait_header = true
  property got_header = false
  property header : HeaderType = 0
  property sep : String = "\t"
  property index_col : IndexColType = 0
  property skiprows : SkiprowsType = false
  property skip_blank_lines : Bool = true
  def initialize()
  end
  def read_table(filepath_or_buffer : String, sep = "\t", t : Int32|Bool = 0, delimiter : String = "\n", header : HeaderType = 0, index_col : IndexColType = 0, comment : String|Regex = "#", skiprows : SkiprowsType = false, skip_blank_lines : Bool = true)
	  if filepath_or_buffer.is_a?(String)
		#todo: check filepath_or_buffer file if exists
		raise "error: only support header = Int yet\n" unless header.is_a?(Int32)
		raise "error: only support skiprows = Bool yet\n" unless skiprows.is_a?(Bool)
		raise "error: only support index_col = Int yet\n" unless index_col.is_a?(Int32)
		
		buffer = DFhash.new # for DataFrame
		comment = /^#{comment}/ if comment.is_a?(String)
	
	
		#global variable
		@comment = comment
		@header = header
		@sep = sep
		@index_col = index_col
		@skiprows = skiprows
		@skip_blank_lines = skip_blank_lines
		
		df_index = Array(String).new
		# read table file 
		if filepath_or_buffer.match(/\.gz$/) # *.gz file
			Gzip::Reader.open(filepath_or_buffer) do |io|
				while line = io.gets(delimiter, chomp=true)
					next if self.check_if_next(line)
					buffer, df_index = self.read_line(line, buffer, df_index)
				end
			end
		else # flat file
			io = File.open(filepath_or_buffer)
			while line = io.gets(delimiter, chomp=true)
				next if self.check_if_next(line)
				buffer, df_index = self.read_line(line, buffer, df_index)
			end
		end
		#puts "row_num #{@row_num}"
	end
	
	unless df_index.is_a?(Array)
		df_index = [] of String
		raise "error: don't get index of table\n" 
	end

	puts "buffer is #{buffer}, df_index is #{df_index}"
	return DataFrame.new(buffer, index: df_index)
  end
  
  def read_line(line : String, buffer : DFhash, df_index : Array(String))
	#@row_num += 1
	arr = line.split(/#{@sep}/)
	if (index_col_instance = @index_col).is_a?(Number) && @got_header && (header_instance = @header).is_a?(Array)
		arr.each_with_index do |value, index|
			next if index < index_col_instance
			if index == index_col_instance
				df_index << value.to_s 
				next
			end
			buffer[header_instance[index-1]] = Array(VTYPE).new unless buffer.has_key?(header_instance[index-1])
			buffer[header_instance[index-1]] << self.guess_type(value)
		end
	else
		raise "error: only support index_col is Int32 yet, is #{index_col}\n"
	end
	return buffer, df_index
  end
  
  def check_if_next(line : String)
	return true if comment.match(line)
	return true if /^\s*$/.match(line) && skip_blank_lines # skip null lines
    next_flag = false
	@row_num +=1
	return true if comment.match(line)
	if(header_instance = @header).is_a?(Number) # thanks https://forum.crystal-lang.org/t/cant-infer-the-type-of-instance-variable-in-class/1181/8
		#if @wait_header
		#	if @row_num <= header_instance  # ignore line before header
		#		@wait_header = false
		#		return true
		#	end
		#end
		if !@got_header && @row_num == header_instance + 1 # get header
			if (index_col_instance = @index_col).is_a?(Number)
				@header = line.split(/#{sep}/)[index_col_instance+1..]
			else
				raise "error: only support index_col is Int yet\n"
			end
			@got_header = true
			return true
		end
	else
		@got_header = true
		return false
		#raise "error: nor support head is not Int\n"
	end
	return next_flag  
  end
  
  def guess_type(value : String)
	  #if value.match(/^\d+\.?\d+$/)
	  return value.to_i if value.to_i? #int
	  return value.to_f if value.to_f? #float
	  return value
  end


end



def tinypandas_test
	raise "usage:./xx yy.xls\n" if ARGV.size == 0
	ifile = ARGV[0]
	puts "intpu file #{ifile}"
	pd = Tinypandas.new
	df = pd.read_table(ifile)
	puts "df is #{df}"
	puts "df.to_str is\n#{df.to_str}"
end
