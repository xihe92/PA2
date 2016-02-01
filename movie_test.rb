class MovieTest
  def initialize(listname)
    @predict_list=[]
    @err_list = []
    @predict_list=listname
    listname.each do |line|
      @err_list.push((line[3]-line[2].to_i).abs)
    end
  end

  def mean()
    return @err_list.inject(:+)/@err_list.size
  end

  def stddev()
    err_deviation = []
    err_mean=mean()
    @err_list.each do |err|
      err_deviation.push(err-err_mean)
    end
    return Math.sqrt(err_deviation.map {|num| num ** 2}.inject(:+)/err_deviation.size)
  end

  def rms()
    squared_err = @err_list.map {|num| num**2}
    return Math.sqrt(squared_err.inject(:+)/squared_err.size)
  end

  def to_a()
    return @predict_list
  end
end
