load 'movie_test.rb'
class MovieData
	def initialize(*args)
	  @user_table=Hash.new
      @movie_table=Hash.new
      @test_list=[] # for MovieTest
      if args.size<2
        filename=args[0]+'/'+'u.data'
        load_data(filename,100000)
      else 
        filename1=args[0]+'/'+args[1].to_s+'.base'
        load_data(filename1,80000)
        filename2=args[0]+'/'+args[1].to_s+'.test'
        File.foreach(filename2).with_index do |line, line_num|
          break if line_num==20000
          lineData=line.split
          @test_list.push(lineData)
        end
      end
	end

	def load_data(filename,lines)
		File.foreach(filename).with_index do |line, line_num|
            break if line_num==lines 
			lineData=line.split
			if @user_table.include?(lineData[0])
				@user_table[lineData[0]][lineData[1]]=lineData[2]
			else
				@user_table[lineData[0]]=Hash.new
				@user_table[lineData[0]][lineData[1]]=lineData[2]
			end
            if @movie_table.include?(lineData[1])
                @movie_table[lineData[1]][lineData[0]]=lineData[2]
            else
                @movie_table[lineData[1]]=Hash.new
                @movie_table[lineData[1]][lineData[0]]=lineData[2]
            end
		end
	end

	def popularity(movie_id)
		return @movie_table[movie_id].size()
	end

	def popularity_list
		popu_list=[]
		movie_list=@movie_table.sort_by{|_,v| v.size()}.reverse
		movie_list.each do |i|
			popu_list.push(i[0])
		end
		return popu_list
	end
	
	def similarity(user1, user2)
		user1_table=@user_table[user1]
		user2_table=@user_table[user2]
		user1_movies=user1_table.size()
		user2_movies=user2_table.size()
		common_movies=0
		similar_value=0
		user1_table.each do |k,v|
			if user2_table.include?(k)
				common_movies+=1
				differ=(v.to_i-user2_table[k].to_i).abs
                similar_value+=1-0.2*differ #Map differ to similarity score: 4->0.2, 3->0.4, ... , 0->1
			end
		end	
		if common_movies==0
			return 0
		else
			if user1_movies<=user2_movies
				result=similar_value/user1_movies
			else
				result=similar_value/user2_movies
			end
			return result
		end
	end
	
	def most_similar(u)
		list=Hash.new
		temp=0
		@user_table.keys.each do |k|
			if k!=u
				similar=similarity(u,k)
				if similar>=temp 
					if list.include?(similar)
						list[similar].push(k)
					else
						list[similar]=[]
						list[similar].push(k)
					end
					temp=similar
				end 
			end
		end
		return list[temp]
	end

    def rating(u,m)
      movie_hash=@user_table[u]
      if movie_hash.include?(m)
        return Float(movie_hash[m])
      else
        return 0.0
      end
    end

    def predict(u,m)
      similarity_list=[]
      return 3.0 if !@movie_table.include?(m) || !@user_table.include?(u)
      usr_ratings=@movie_table[m]
      usr_ratings.each do |k,v|
        if k!=u
          similarity_list.push([k,similarity(u,k),v])
        end
      end
      similarity_list.sort_by {|e| -e[1]}
      result=0
      count=(similarity_list.size()*0.1).round #Top 10% similar users
      count+=1 if count==0
      (0..count-1).each do |i|
        result+=similarity_list[i][2].to_i
      end
      return result/Float(count)
    end

    def movies(u)
      return @user_table[u].keys
    end

    def viewers(m)
      return @movie_table[m].keys
    end

    def run_test(*args)
      result_list=[]
      if args.size <1
        @test_list.each do |line|
          result_list.push([line[0],line[1],line[2],predict(line[0],line[1])])
        end
      else
        @test_list.first(args[0]).each do |line|
          result_list.push([line[0],line[1],line[2],predict(line[0],line[1])])
        end
      end
      return MovieTest.new(result_list)
    end

end
