require 'dag'

module Nameable
  attr_accessor :name
end

module Workable
  attr_accessor :time_remaining
  def work(seconds)
    @time_remaining -= seconds
  end
end

class DAG::Vertex
  include Nameable
  include Workable
end


class MyDag < DAG
  attr_accessor :vertices_by_name
  attr_accessor :base_work_time

  def initialize
    super
    @vertices_by_name = {}
    @time_elapsed = 0
    @base_work_time = 0
  end

  def find_or_add(vertex_name)
    return vertices_by_name[vertex_name] if vertices_by_name[vertex_name]

    vertex = self.add_vertex
    vertex.name = vertex_name
    vertex.time_remaining = 60 + ('A'..'Z').to_a.index(vertex_name) + 1
    vertices_by_name[vertex_name] = vertex
    vertex
  end




  def self.from_lines(lines, base_work_time=0)
    dag = new
    lines.each do |line|
      matches = line.match(%r{Step (?<v1>\w+) must be finished before step (?<v2>\w+) can begin})
      v1 = dag.find_or_add(matches[:v1])
      v2 = dag.find_or_add(matches[:v2])

      # puts "adding #{v1.name} -> #{v2.name}"
      dag.add_edge from: v1, to: v2
    end

    dag
  end

  def self.from_file(file, base_work_time)
    from_lines(File.readlines(file).map(&:chomp))
  end

  def origins
    origins = self.vertices.select {|vertex| vertex.ancestors.size == 0}
    # if origins.size != 1
    #   raise "multiple or zero origins? sup with that?"
    # end
    origins
  end

  def terminus
    terminii = self.vertices.select {|vertex| vertex.descendants.size == 0}
    if terminii.size != 1
      raise "multiple or zero terminii? sup with that?"
    end
    terminii.first
  end

  def path
    path = []
    done = Set.new
    next_steps = Set.new(origins)
    while !next_steps.empty?
      next_step = next_steps.sort_by(&:name).first
      # puts "#{next_step.name} #{next_steps.map(&:name).join("")}"
      if (next_step.ancestors - done).empty?
        path << next_step
        done << next_step
        next_steps.merge(next_step.descendants - done)
      end
      next_steps.delete(next_step)
    end
    path.map(&:name).join("")
  end

  def find_ready(done, workers)
    vertices.select {|vertex| (vertex.ancestors - done).empty? } - done.to_a - workers.to_a
  end

  def time_parallel(num_workers)
    time_elapsed = 0
    done = Set.new
    workers = Set.new.merge(find_ready(done, workers))

    puts "second\t1\t2\t3\t4\t5\tdone"
    while !(vertices - done.to_a).empty?
      done_workers = workers.select {|worker| worker.time_remaining == 0}
      workers.subtract(done_workers)
      done.merge(done_workers)

      next_steps = find_ready(done,workers).sort_by(&:name)
      puts next_steps.map(&:name).sort.join(", ")
      (num_workers - workers.count).times do
        next_step = next_steps.shift
        workers << next_step if next_step
      end

      print "#{time_elapsed}\t"
      print "#{workers.sort_by(&:name)[0] ? workers.sort_by(&:name)[0].name : ''}\t"
      print "#{workers.sort_by(&:name)[1] ? workers.sort_by(&:name)[1].name : ''}\t"
      print "#{workers.sort_by(&:name)[2] ? workers.sort_by(&:name)[2].name : ''}\t"
      print "#{workers.sort_by(&:name)[3] ? workers.sort_by(&:name)[3].name : ''}\t"
      print "#{workers.sort_by(&:name)[4] ? workers.sort_by(&:name)[4].name : ''}\t"

      print "#{done.map(&:name).sort.join('')}\n"

      break if workers.length == 0

      # work_interval = workers.map(&:time_remaining).min
      work_interval = 1
      workers.each do |worker|
        worker.work(work_interval)
      end
      time_elapsed += work_interval
    end
    time_elapsed
  end
end
