#!/home/engon/.julia/juliaup/julia-nightly/bin/julia
using Markdown

function getfilestoconvert()::Channel{String}
  Channel{String}() do channel
    for (parent, internal, files) in walkdir(".")
      length(internal) > 0 && continue
      for file in files
        if endswith(file, ".md")
          push!(channel, joinpath(parent, file))
        end
      end
    end
  end
end
function replaceext(path::String, newext::String)::String
  first(splitext(path)) * "." * newext
end
function convertfiles()::Channel{String}
  Channel{String}() do channel
    for file in getfilestoconvert()
      try
        markdown = Markdown.parse_file(file)
        println(markdown)

        open(replaceext(file, "html"), "w") do f
          print(f, Markdown.html(markdown))
        end
        open(replaceext(file, "txt"), "w") do f
          print(f, Markdown.plain(markdown))
        end
        push!(channel, file)
      catch e
        @error "Error processing file: $file" exception = e
      end
    end
  end
end

function (@main)(args::Vector{String})
  if length(args) > 0
    @warn "Ignoring command line arguments: $args"
  end

  @info "Starting conversion of Markdown files to HTML..."
  for file in convertfiles()
    @info "Converted file: $file"
  end
  @info "Conversion completed."
end
