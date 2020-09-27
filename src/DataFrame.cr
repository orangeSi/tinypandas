require "./Series"

struct DataFrame
	alias Index2ArrayType = Array(String)|Array(Float64)|Array(Float32)|Array(Int32)|Array(Int64)|Array(Float64|Int64)|Array(Int64|String)|Array(Float32|Int32)|Array(Float32|Float64)|Array(Int32|String)|Array(Int32|Int64)|Array(Float32|String)|Array(Float64|Int32)|Array(Float64|String)|Array(Float32|Int64)|Array(Float64|Int32|String)|Array(Float64|Int32|Int64)|Array(Int32|Int64|String)|Array(Float32|Float64|Int32)|Array(Float32|Int64|String)|Array(Float32|Float64|String)|Array(Float32|Int32|Int64)|Array(Float64|Int64|String)|Array(Float32|Int32|String)|Array(Float32|Float64|Int64)|Array(Float32|Float64|Int32|Int64)|Array(Float32|Float64|Int64|String)|Array(Float64|Int32|Int64|String)|Array(Float32|Float64|Int32|String)|Array(Float32|Int32|Int64|String)|Array(Float32|Float64|Int32|Int64|String)
	alias ColumnType = Int64|Float32|Float64|String|Int32|(Int64|String)|(Float32|Int64)|(Int32|String)|(Float32|Float64)|(Float32|String)|(Float32|Int32)|(Int32|Int64)|(Float64|Int64)|(Float64|String)|(Float64|Int32)|(Float32|Float64|Int64)|(Float64|Int32|Int64)|(Float32|Int32|String)|(Float32|Int32|Int64)|(Float32|Float64|String)|(Float32|Int64|String)|(Float32|Float64|Int32)|(Float64|Int64|String)|(Float64|Int32|String)|(Int32|Int64|String)|(Float32|Float64|Int32|Int64)|(Float32|Int32|Int64|String)|(Float32|Float64|Int64|String)|(Float64|Int32|Int64|String)|(Float32|Float64|Int32|String)|(Float32|Float64|Int32|Int64|String)
	alias KType = String
	property dict = Hash(KType, Series).new
	property index, columns # index/columns only support String
	def initialize(data, @index  = [] of KType, @columns  = [] of KType, read_array_by_row : Bool = true)
		t0 = Time.utc
		if data.is_a?(Hash) # copy data to dict
			## check data.key and data.value
			data.values.each do |e|
				raise "error: DataFrame support Hash(String, Array(Int32|Int64|String|Float32|Float64)) yet, instead of Hash(String, #{typeof(e)})\n" unless e.is_a?(Array)
			end

			# check and get index
			if data.keys.size != 0
				nrow_number = data.first_value.size
				if index.size == 0
					(0...nrow_number).each {|e| index << e.to_s}
				elsif index.size != nrow_number
					raise "error: data have #{nrow_number} lines, but you give index size is #{index.size}\n" 
				end
			end

			# check and get columns
			if columns.size == 0
				data.keys.each {|e| columns << e.to_s}
			elsif columns.size != data.keys.size
				raise "error: data have #{data.keys.size} columns, but columns: size #{columns.size}\n"
			end

			## copy data to dict with new index and columns
			data.keys.each_with_index do |key, i| 
				column = columns[i].to_s
				dict[column] = Series.new unless dict.has_key?(column)
				data[key].each_with_index do |e, j| 
					dict[column].add index[j], e
				end
				#data.delete(key)
			end

		elsif data.is_a?(Array) #
			data.each do |e|
				raise "error: DataFrame support Array(Array(Int32|Int64|String|Float32|Float64)) yet, instead of Array(#{typeof(e)})\n" unless e.is_a?(Array)
			end
			if read_array_by_row # element of Array is one row of dataframe
				# check and get index
				if index.size == 0
					(0...data.size).each {|e| index << e.to_s}
				elsif index.size != data.size
					raise "error: data have #{data.size} lines, but you give index size is #{index.size}\n"
				end

				# check and get columns
				if data.size != 0 && data[0].size != 0
					if columns.size == 0
						(0...data[0].size).each {|e| columns << e.to_s}
					elsif columns.size != data[0].size
						raise "error: data have #{data[0].size} columns, but columns: size #{columns.size}\n"
					end
				end

				# copy data to dict with new index and columns
				data.each_with_index do |row, i| 
					row.each_with_index do |e, j|
						dict[columns[j]] = Series.new unless dict.has_key?(columns[j])
						dict[columns[j]].add index[i], e
					end
				end
				
			else # element of Array is one column of dataframe
				# check and get index
				if data.size != 0 && data[0].size != 0
					if index.size == 0
						(0...data[0].size).each {|e| index << e.to_s}
					elsif index.size != data[0].size
						raise "error: data have #{data[0].size} lines, but you give index size is #{index.size}\n"
					end
				end

				# check and get columns
				if columns.size == 0
					(0...data.size).each {|e| columns << e.to_s}
				elsif columns.size != data.size
					raise "error: data have #{data.size} columns, but columns: size #{columns.size}\n"
				end

				# copy data to dict with new index and columns
				data.each_with_index do |col, i| 
					the_column = columns[i]
					dict[the_column] = Series.new unless dict.has_key?(the_column)
					col.each_with_index do |e, j|
						dict[the_column].add index[j], e
					end
			  end	
			end
			#raise "warn: Array support is to do for DataFrame\n"
		else
			raise "error: only support Hash or Array yet\n"
		end
	  	puts "init DataFrame cost time: " + (Time.utc - t0).to_s
	end
	def head(nrow = 3)
		data_head = Hash(KType, Array(ColumnType)).new
		dict.keys.each do |e|
			dict[e][0...nrow].to_a.each do |ee|
				data_head[e] = Array(ColumnType).new unless data_head.has_key?(e)
				data_head[e] << ee
			end
		end
		return DataFrame.new(data_head, index: index[...nrow], columns: columns)
	end


	def [](column_name : String)
		if dict.has_key?(column_name)
			return dict[column_name]
		else
			puts "keys is #{dict.keys}"
			raise "error: DataFrame have no column #{column_name}\n"
		end
	end
	def [](col_number : Int32|Int64)
		return dict[dict.keys[col_number]]
	end
	def [](range : Range)
		puts "error: not support range:#{range} yet"
	end
	def [](series : Series)
		new_index = series.index
		new_columns = columns
		data_series = Hash(KType, Array(ColumnType)).new
		series.index.each do |i|
			new_columns.each do |c|
				data_series[c] = Array(ColumnType).new unless data_series.has_key?(c)
				data_series[c] << dict[c][i]
			end
		end
		return DataFrame.new(data_series, index: new_index, columns: new_columns)
	end
	def loc
		return self.t
	end
	def t
		t0 = Time.utc
		new_index = [] of KType
		new_columns = [] of KType
		index.each {|e| new_columns << e}
		columns.each {|e| new_index << e}

		data_t = Hash(KType, Array(ColumnType)).new
		a0 = Time.utc
		key_size = dict.keys.size
		keys = dict.keys
		index.each_with_index do |value, i|
			#if i % 10 == 0
			#	puts "i=#{i} cost time:"
			#	puts Time.utc - a0
			#	a0 = Time.utc
			#end
			#value = value.to_s
			keys.each do |key|
				data_t[value] = Array(ColumnType).new(key_size) unless data_t.has_key?(value)
				data_t[value] << dict[key][value]
			end
		end
		#puts "t index is #{new_index}, new_columns is #{new_columns}"
		puts "DataFrame.t cost time:"
		puts Time.utc - t0
		return DataFrame.new(data_t, index: new_index, columns: new_columns)
		# Transpose index and columns
	end
	def to_str(outfile : String|Nil = nil, sep = "\t", header : Bool|Array(String) = true, index_col : Bool = true, mode : String = "w") # chunksize : Int or None, Rows to write at a time
		str = ""
		if header.is_a?(Bool) 
			if header == true
				str = sep
				columns.each {|e| str +="#{e}#{sep}"}
				str = str.gsub(/#{sep}$/, "\n")
			end
		else
			raise "error: not support header = Array in to_str yet\n"
		end

		if outfile.is_a?(String)
			out = File.open(outfile, mode)
			if header.is_a?(Bool) && header == true
				out.puts(str.gsub(/\n$/, ""))
				str = ""
			end
		end

		
		(0...index.size).to_a.each do |i|
			str += "#{index[i]}#{sep}"
			dict.keys.each do |key|
				str = "#{str}#{dict[key][i]}#{sep}"
			end
			str = str.gsub(/#{sep}$/, "\n")
			if !out.nil?
				out.puts(str.gsub(/\n$/, ""))
				str = ""
			end

		end
		if !out.nil?
			out.close
			return 0
		else
			return str
		end
	end

	def to_s(sep : String = "\t")
		return self.to_str(sep: sep)
	end

	def to_table(outfile : String|Nil = nil, sep = "\t", header : Bool|Array(String) = true, index_col : Bool = true, mode : String = "w")
		self.to_str(outfile, sep, header, index_col, mode)
	end
end


def dataframe_test
	t = {"C4" => [1,2,"4","C"], "B3" => ["A", "B", 3,"D"]}
	puts typeof(t)
	puts "t is #{t}"
	y = DataFrame.new(t)
	puts "y.index #{y.index}"
	puts "y.columns #{y.columns}"
	puts "y[C4][0] is "
	puts y["C4"][0]
	puts y[1][1]

	puts "y.head().to_str() is \n#{y.head().to_str()}"

	puts "dict is #{y.dict}"

	puts "y.t.to_str() is #{y.t.to_str()}"

	puts "y.loc[0][C4] is "
	puts y.loc.index
	puts y.loc.columns
	puts y.loc["0"]["C4"]
	puts y.loc[1][1]
	y.to_table("y.out.xls")
end

#dataframe_test
