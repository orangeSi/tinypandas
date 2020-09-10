require "gzip"
require "csv"
require "./DataFrame"

class Tinypandas
  alias DFhash = Hash(String, Array(Int32|Int64|Float32|Float64|String))
  alias HeaderType = Int32|Int64|Array(String)|Nil # when Nil mean no header in file, so set 0..xx to columns
  alias IndexColType  = HeaderType # when Nil mean no index in file, so set 0..xx to index
  alias SkiprowsType = Int32|Array(Int32)|Bool
  alias VTYPE = Float32|Float64|Int32|Int64|String
  protected property comment = /^#/
  protected property row_num : Int32|Int64 = 0
  protected property got_header = false
  protected property header : HeaderType = 0
  protected property sep : String = "\t"
  protected property index_col : IndexColType = 0
  protected property skiprows : SkiprowsType = false
  protected property skip_blank_lines : Bool = true
  #property data_type : VTYPE
  def initialize()
  end
  def read_table(filepath_or_buffer : String, sep = "\t", delimiter : String = "\n", header : HeaderType = 0, index_col : IndexColType = 0, comment : String|Regex = "#", skiprows : SkiprowsType = false, skip_blank_lines : Bool = true)
	  t0 = Time.utc
	  if filepath_or_buffer.is_a?(String)
		
		puts "reading file #{filepath_or_buffer}, row_num=#{row_num}\n"
		#todo: check filepath_or_buffer file if exists
		raise "error: only support header = Int yet\n" unless header.is_a?(Int32)
		raise "error: only support skiprows = Bool yet\n" unless skiprows.is_a?(Bool)
		
		check_index_col_format(index_col)

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
		#raise "error: don't get index of table\n" 
	end

	#puts "buffer is #{buffer}, df_index is #{df_index}"
	puts "cost time:" + (Time.utc - t0).to_s
	#puts "buffer is #{buffer}, df_index is #{df_index}, header is #{@header}, got_header is #{@got_header}\n"

  	@comment = /^#/
	@row_num  = 0
  	@got_header = false
  	@header  = 0
  	@sep  = "\t"
  	@index_col  = 0
  	@skiprows  = false
  	@skip_blank_lines  = true

	return DataFrame.new(buffer, index: df_index)
  end
  def check_index_col_format(index_col : IndexColType)
	raise "error: only support index_col = Int or Nil yet\n" unless (index_col.is_a?(Int32) || index_col.is_a?(Nil))
	if index_col.is_a?(Int32) && index_col < 0
		raise "error: index_col should >= 0 instead of #{index_col}\n"
	end
  end 
  def read_line(line : String, buffer : DFhash, df_index : Array(String))
	if @got_header && (header_instance = @header).is_a?(Array)
		buffer, df_index = read_line_to_buffer(line, buffer, df_index, header_instance) 
	end
	return buffer, df_index
  end
 
  def read_line_to_buffer(line : String|Array(String), buffer : DFhash, df_index : Array(String), header_instance : Array(String)) 
		row = [] of String
		if line.is_a?(String)
			row = line.split(/#{@sep}/)
		elsif line.is_a?(Array)
			row = line
		end
		if (index_col_instance = @index_col).is_a?(Number)
			row.each_with_index do |value, index|
				if index > index_col_instance
					buffer[header_instance[index-1]] = Array(VTYPE).new unless buffer.has_key?(header_instance[index-1])
					buffer[header_instance[index-1]] << self.guess_type(value)
					#buffer[header_instance[index-1]] << value	
				elsif index < index_col_instance
					buffer[header_instance[index]] = Array(VTYPE).new unless buffer.has_key?(header_instance[index])
					buffer[header_instance[index]] << self.guess_type(value)
					#buffer[header_instance[index-1]] << value	
				elsif index == index_col_instance
					df_index << value	
				end
			end	
		elsif (index_col_instance = @index_col).is_a?(Nil)
			row.each_with_index do |value, index|
				buffer[header_instance[index]] = Array(VTYPE).new unless buffer.has_key?(header_instance[index])
				buffer[header_instance[index]] << self.guess_type(value)
				#buffer[header_instance[index-1]] << value	
			end
		else
			raise "error: only support index_col is Int32 or Nil yet, is #{index_col}\n"
		end
		row = ""
		return buffer, df_index
  end
 
  def check_if_next(line : String)
	return true if comment.match(line)
	return true if /^\s*$/.match(line) && skip_blank_lines # skip null lines
	next_flag = false
	@row_num +=1
	if(header_instance = @header).is_a?(Number) # thanks https://forum.crystal-lang.org/t/cant-infer-the-type-of-instance-variable-in-class/1181/8
		#if @wait_header
		#	if @row_num <= header_instance  # ignore line before header
		#		@wait_header = false
		#		return true
		#	end
		#end
		if !@got_header && @row_num == header_instance + 1 # get header
			if (index_col_instance = @index_col).is_a?(Number)
				@header = line.split(/#{sep}/)[0...index_col_instance] + line.split(/#{sep}/)[index_col_instance+1..]
			elsif (index_col_instance = @index_col).is_a?(Nil)
				@header = line.split(/#{sep}/)
			else
				raise "error: only support index_col is Int32 or Nil yet\n"
			end
			@got_header = true
			return true
		else
			raise "error: got_header=#{@got_header}, row_num=#{@row_num}, header_instance=#{header_instance}\n"		
		end
	else
		@got_header = true
		return false
	end
	return next_flag  
  end
  
  def guess_type(value : String)
	  #if value.match(/^\d+\.?\d+$/)
	  return value.to_i if value.to_i? #int
	  return value.to_f if value.to_f? #float
	  return value
	end
	
	def each_csv_row(filename, headers)
		File.open(filename) do |infile|
			headers_returned = false
			csv_rows = CSV.new(infile, headers: headers)
			csv_rows.each do |parser|
				yield parser
			end
		end
	end
	
  	def load_vcf(filepath_or_buffer : String, sep = "\t", delimiter : String = "\n", header : HeaderType = 0, index_col : IndexColType = nil, comment : String|Regex = "##", skiprows : SkiprowsType = false, skip_blank_lines : Bool = true)
		self.read_table(filepath_or_buffer: filepath_or_buffer, sep: sep, delimiter: delimiter, header: header, index_col: index_col, comment: comment, skiprows: skiprows, skip_blank_lines: skip_blank_lines)
	end
	def load_csv(filename, index_col : IndexColType = nil, index_type="datetime", index_format="%Y-%m-%d %H:%M:%S", headers = true )
		t0 = Time.utc
		pp "Loading CSV File"
		pp "Filename: " + filename
		pp "Index column: " + index_col.to_s
		pp "Index type: " + index_type.to_s
		pp "Index format: " + index_format.to_s

		check_index_col_format(index_col)
		@index_col = index_col

		buffer = DFhash.new # for DataFrame
		df_index = Array(String).new
	    	each_csv_row(filename, headers: headers) do |parser|
			if headers  && (header_instance = parser.headers).is_a?(Array)
				buffer, df_index = read_line_to_buffer(parser.row.to_a, buffer, df_index, header_instance)
			end
		end
		puts "Time spent: " + (Time.utc - t0).to_s 
		return DataFrame.new(buffer, index: df_index )
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
