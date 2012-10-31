#!/usr/bin/env ruby

require 'open3'
require 'rubygems'
require 'json'
require 'net/http'
require 'titleize'
require 'optparse'
require 'ostruct'
require 'open-uri'

class SwaggerToMarkdown
  def self.enhance(options)
    resources = extract_json options.resourcefile
    @parameters = extract_json options.parametersfile

    write_api_to_markdown   options.markdownfile, 
          options.apiname, 
          resources['apiVersion'], 
          resources['basePath'], 
          resources['apis'],
          options.specifications
  end

  def self.write_api_to_markdown(markdown_file, api_name, api_version, base_path, apis, specifications)
    File.open(markdown_file, "w+") do |f|
      write_header f, api_name, api_version, base_path

      apis.each_with_index do |resource, index|
        f.write build_markdown_header(
          (extract_resource_name(resource['path'])+" resource").titleize,
          2
        )
        f.write resource['description'] + "\n\n"
        write_specification(f, base_path, extract_resource_name(resource['path']), specifications[index])
        f.write "\n\n"
      end
    end
  end

  def self.write_specification(f, base_path, resource, specification)
    specification = extract_json specification
    apis = specification['apis']

    apis.map {|method| method['operations'].map {|operation| write_operation f, base_path, resource, operation, method['path'] }}
  end

  def self.write_operation(f, base_path, resource, operation, path)
    if operation['summary'].nil?
      f.write build_markdown_header("[Please add operation summary information to the summary section]\n\n", 3)
    else
      f.write build_markdown_header(operation['summary'] + "\n", 3)
    end

    if operation['notes'].nil?
      f.write "[Please add operation information to the notes section]\n\n"
    else
      f.write operation['notes'] + "\n"
    end

    f.write build_markdown_header("Definition", 4)
    f.write "\n\n"

    write_code_block f, operation['httpMethod'] + " " + path
    f.write "\n\n"

    f.write build_markdown_header("Arguments", 4)
    write_arguments f, operation['parameters']
    f.write "\n\n"

    f.write build_markdown_header("Example Request", 4)
    response = write_example_request f, base_path, operation, path, operation['parameters'], resource
    f.write "\n\n"

    f.write build_markdown_header("Example Response", 4)
    write_code_block(f, response) if !response.nil?
    f.write "\n\n"

    f.write build_markdown_header("Potential Errors", 4)
    write_errors f, operation['errorResponses']
    f.write "\n\n"
  end

  def self.write_example_request(f, base_path, operation, path, arguments, resource)
    path = populate_arguments path, arguments
    case operation["httpMethod"]  
    when "GET"
      command = "curl " + base_path + path
    when "POST"
      data = @parameters[resource.upcase + ".POST"]
      command = "curl -X POST -H \"Content-Type:application/json\" -d '" + data + "' " + base_path + path
    when "PUT"
      data = @parameters[resource.upcase + ".POST"]
      command = "curl -X PUT -H \"Content-Type:application/json\" -d '" + data + "' " + base_path + path
    end

    stdin, stdout, stderr = Open3.popen3(command) 
    write_code_block(f, command)
    response = stdout.read
    begin
      JSON.pretty_generate(JSON.parse(response)).gsub("\n","\n    ")
    rescue
      response
    end
  end

  def self.populate_arguments(path, arguments)
    path = path.sub("{format}", "json")
    return path if arguments.nil?

    arguments.reject {|argument| argument['name'].nil? }.reject {|argument| @parameters[argument["name"]].nil?}.map {|argument| path = path.sub("{#{argument["name"]}}", @parameters[argument["name"]])}

    path
  end

  def self.write_errors(f, errors)
    if errors.nil? || errors.length <= 0
      f.write "* None\n"  
      return
    end

    errors.each do |error|
      f.write "* "
      if error['code'].nil?
        f.write "[Please add a code for error]"
      else
        f.write "**" + error['code'].to_s + "**"
      end
  
      if error['reason'].nil?
        f.write ""
      else
        f.write " - " + error['reason']
      end

      f.write "\n"
    end

  end

  def self.write_arguments(f, arguments)
    if arguments.nil? || arguments.length <= 0
      f.write "* None\n"  
      return
    end

    arguments.each do |argument|
      f.write "* "
      if argument['name'].nil?
        f.write "[Please add a name for argument]"
      else
        f.write "**" + argument['name'] + "**"
      end
  
      if argument['description'].nil?
        f.write ""
      else
        f.write " - " + argument['description']
      end

      f.write "\n"
    end
  end

  def self.write_code_block(f, text)
    f.write "    " + text
  end

  def self.write_header(f, api_name, api_version, base_path)
    f.write build_markdown_header(api_name + " " + api_version + " REST API", 1)
    f.write "Base Path: " + base_path + "\n\n"
    f.write build_input_here
    f.write "\n\n"
    f.write build_markdown_header("General Considerations", 2)
    f.write build_input_here
    f.write "\n\n"
  end

  def self.extract_resource_name(path)
    end_of_resource_name = path.index(".")
    resource_name = path[1,end_of_resource_name-1]
  end

  def self.build_input_here
    input_here = "[Please add API specific content here]\n"
  end

  def self.build_markdown_header(text, level)
    header = "#" * level + text + "\n"
  end

  def self.extract_json(file_name)
    file = open(file_name)
    json = JSON.parse(file.read)
  end

  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: swagger-to-markdown.rb -n API_NAME -r resources.json -o api.md -s x,y,z"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-n", "--name API-name",
        "Provide the API name") do |apiname|
        options.apiname = apiname 
      end

      opts.on("-r", "--resources resources.json",
        "Provide the resources.json to define your API resources filename") do |resourcefile|
        options.resourcefile = resourcefile 
      end

      opts.on("-p", "--parameters parameters.json",
        "Provide the parameters.json to define your API parameters filename") do |parametersfile|
        options.parametersfile = parametersfile 
      end

      opts.on("-o", "--markdown api.md",
        "Provide the api.md to define your output Markdown filename") do |markdownfile|
        options.markdownfile = markdownfile 
      end

      opts.on("-s", "--specification x,y,z", Array, "List of specification files in a json format") do |specifications|
        options.specifications = specifications  
      end

      opts.separator ""
      opts.separator "Common options:"

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      # Another typical switch to print the version.
      opts.on_tail("--version", "Show version") do
        puts "0.1"
        exit
      end
    end

    opts.parse!(args)
    options
  end
end

options = SwaggerToMarkdown.parse(ARGV)
SwaggerToMarkdown.enhance(options)
