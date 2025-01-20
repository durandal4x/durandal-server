defmodule Mix.Tasks.Durandal.Task.NewObject.Docs do
  @moduledoc false

  def short_doc do
    "A short description of your task"
  end

  def example do
    "mix durandal.task.new_object --example arg"
  end

  def long_doc do
    """
    #{short_doc()}

    Longer explanation of your task

    ## Example

    ```bash
    #{example()}
    ```

    ## Options

    * `--example-option` or `-e` - Docs for your option
    """
  end
end

if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.Durandal.Task.NewObject do
    @shortdoc "#{__MODULE__.Docs.short_doc()}"

    @moduledoc __MODULE__.Docs.long_doc()

    use Igniter.Mix.Task

    @impl Igniter.Mix.Task
    def info(_argv, _composing_task) do
      %Igniter.Mix.Task.Info{
        # Groups allow for overlapping arguments for tasks by the same author
        # See the generators guide for more.
        group: :durandal,
        # dependencies to add
        adds_deps: [],
        # dependencies to add and call their associated installers, if they exist
        installs: [],
        # An example invocation
        example: __MODULE__.Docs.example(),
        # a list of positional arguments, i.e `[:file]`
        positional: [],
        # Other tasks your task composes using `Igniter.compose_task`, passing in the CLI argv
        # This ensures your option schema includes options from nested tasks
        composes: [],
        # `OptionParser` schema
        schema: [],
        # Default values for the options in the `schema`
        defaults: [],
        # CLI aliases
        aliases: [],
        # A list of options in the schema that are required
        required: []
      }
    end

    defp library_file(igniter) do
      template_data = File.open!("priv/static/templates/library.exs")
        |> File.read!()
        |> String.replace("Application", "Durandal")
        # |> String.replace("Context", "")
        # |> String.replace("Object", "")
        # |> String.replace("object", "")

      Igniter.create_new_elixir_file(igniter, path, template_data)
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      IO.puts ""
      IO.inspect igniter, label: "#{__MODULE__}:#{__ENV__.line}"
      IO.puts ""

      # Do your work here and return an updated igniter
      igniter
      |> library_file()
    end
  end
else
  defmodule Mix.Tasks.Durandal.Task.NewObject do
    @shortdoc "#{__MODULE__.Docs.short_doc()} | Install `igniter` to use"

    @moduledoc __MODULE__.Docs.long_doc()

    use Mix.Task

    def run(_argv) do
      Mix.shell().error("""
      The task 'durandal.task.new_object' requires igniter. Please install igniter and try again.

      For more information, see: https://hexdocs.pm/igniter/readme.html#installation
      """)

      exit({:shutdown, 1})
    end
  end
end
