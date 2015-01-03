task :environment do
  require_relative './config/application'
  require './api/server'
  require './frontend/server'
end

task console: :environment do
  require 'irb'
  require 'irb/completion'
  ARGV.clear
  IRB.start
end

namespace :documentation do
  def pretty_type_name(name)
    name.to_s.split('::').last
  end

  def generate_markdown_for_route(o, route, last_resource)
    path = route.route_path.sub(/:version/, route.route_version).sub('(.:format)', '')
    resource = route.route_path.match(%r{/.*?/([^/(]+)})[1].titleize

    puts "     #{route.route_method} #{path}"

    if resource != last_resource
      o.puts "## #{resource}"
      last_resource = resource
    end
    o.puts "### #{route.route_method} #{path}"
    o.puts
    o.puts "#{route.route_description}"
    o.puts

    if route.route_params && route.route_params.any?
      o.puts 'Parameter | Type | Required | Description'
      o.puts ':---------|:-----|:---------|:-----------'

      route.route_params.sort_by { |name, _| name }.each do |name, options|
        if options.is_a?(Hash)
          o.puts "`#{name}` | #{pretty_type_name(options[:type])} | #{options[:required] ? 'Yes' : 'No'} | #{options[:desc]}"
        else
          o.puts "`#{name}` | | | (inherited)"
        end
      end

      o.puts
    end

    docs_path = Pathname.new './documentation'
    file_path = path.sub("/#{route.route_version}/", '').chomp('/').gsub('/', '-').gsub(':', '')
    input_file = docs_path.join(route.route_version, 'input', "#{route.route_method}-#{file_path}.json")
    output_file = docs_path.join(route.route_version, 'output', "#{route.route_method}-#{file_path}.json")

    if File.exist?(input_file)
      o.puts '**Example input**'
      o.puts '```'
      o.puts File.read(input_file)
      o.puts '```'
      o.puts
    end

    if File.exist?(output_file)
      o.puts '**Example output**'
      o.puts '```'
      o.puts File.read(output_file)
      o.puts '```'
      o.puts
    end

    o.puts

    # Returns the last resource
    last_resource
  end

  def get_html_from_github(uri, input)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      body = { text: input, mode: 'gfm' }.to_json
      req = Net::HTTP::Post.new(uri.request_uri)
      req['Content-Type'] = 'application/json'
      req.body = body

      response = http.request req

      if response.is_a?(Net::HTTPOK)
        puts '---> OK.'
        response.body
      else
        $stderr.puts "ERROR: #{response.inspect}"
        exit 127
      end
    end
  end

  task markdown: :environment do
    versions = RestInMe::API.routes.sort_by(&:route_path).group_by(&:route_version).reject { |version, _| version.nil? }

    docpath = Pathname.new './documentation'
    docpath.mkpath

    versions.each do |version, routes|
      File.open(docpath.join("#{version}.markdown"), 'w') do |output|
        output.puts

        Dir.glob(docpath.join(version, '*.markdown')).sort.each do |extra_document|
          puts "===> Including documentation file #{extra_document}"
          output.puts File.read(extra_document)
          output.puts
        end

        output.puts '# API Calls'
        output.puts

        puts '===> Generating documentation for route'
        last_resource = nil
        routes.each do |route|
          last_resource = generate_markdown_for_route(output, route, last_resource)
        end
      end
    end

    `which doctoc` # sets $CHILD_STATUS
    if $CHILD_STATUS and $CHILD_STATUS.exitstatus != 0
      $stderr.puts 'WARNING: doctoc not installed. Documentation files will not have tables of contents. Install doctoc with `npm install -g doctoc`.'
    else
      Dir.glob(docpath.join('*.markdown')).each do |file|
        next if file =~ /-toc/

        # `doctoc` will overwrite the files, adding stuff to the begining.
        # We don't want this, but we do want to generate the toc
        original_content = File.open(file, 'r').readlines.join

        # Run `doctoc`
        puts `doctoc #{file}`

        puts
        puts '=================='
        puts

        # Remove annoying cruft from DocToc
        stop = false
        lines = File.open(file, 'r').readlines.reject do |line|
          stop = true if line =~ /^# / # Remove everything after first <h1>
          line =~ /DocToc/ or line =~ /^- / or line == '' or stop
        end

        lines = lines.map { |line| line.sub(/^\t/, '') }.join

        toc_filename = file.gsub(/.markdown/, '-toc.markdown')

        File.open(toc_filename, 'w') do |f|
          f.write(lines)
        end

        File.open(file, 'w') do |f|
          f.write(original_content)
        end
      end
    end
  end

  task html: :markdown do
    puts '===> Rendering to HTML via api.github.com...'

    docs_path = Pathname.new './documentation'
    uri    = URI.parse('https://api.github.com/markdown')
    header = File.read docs_path.join('header.html')
    footer = File.read docs_path.join('footer.html')

    # Lets create the Table of Contents files
    Dir.glob(docs_path.join('*-toc.markdown')).each do |filename|
      if filename =~ /([\w\d]+-toc)\.markdown/
        toc_version = Regexp.last_match[1]

        input = File.read(filename)
        output_filename = docs_path.join("#{toc_version}.html")

        result = get_html_from_github(uri, input)

        puts "---> Writing to #{output_filename}"
        File.open(output_filename, 'w') do |f|
          f.puts('<div class="col-md-3">')
          f.puts('<div class="sidebar affix">')

          f.puts('<h4>Table of Contents</h4>')

          f.puts(result.gsub(/task-list/, 'nav'))

          f.puts('</div><!-- end .sidebar -->')
          f.puts('</div><!-- end .col-md-3 -->')
        end
      end
    end

    Dir.glob(docs_path.join('*.markdown')).each do |filename|
      if filename =~ /([\w\d]+)\.markdown/ and !(filename.include?('toc'))
        version = Regexp.last_match[1]

        input = File.read(filename)
        output_filename = docs_path.join("#{version}.html")
        toc_filename = docs_path.join("#{version}-toc.html")

        result = get_html_from_github(uri, input)

        puts '---> Replace table with Bootstrap table'
        result = result.gsub(/<table>/, '<table class="table table-striped table-condensed table-bordered">')

        puts '---> Replace h-tags with anchored versions'
        result = result.split(/\n/).map do |line|
          if line =~ /<(h\d*?)>(.*?)<\/h\d*?>/
            htag    = Regexp.last_match[1]
            content = Regexp.last_match[2]
            id      = content.downcase.gsub(' ', '-').gsub(/[\/:,.]/, '')
            result  = "<#{htag} id=\"#{id}\">#{content}</#{htag}>"
            line.gsub(/<h\d*?>.*?<\/h\d*?>/, result)
          else
            line
          end
        end.join("\n")

        puts "---> Writing to #{output_filename}"
        File.open(output_filename, 'w') do |f|
          f.puts(header)

          f.puts('<div class="col-md-9">')
          f.puts(result)
          f.puts('</div>')

          f.puts(File.read(toc_filename))

          f.puts(footer)
        end
      end
    end
  end

  task generate: [:html]
end
