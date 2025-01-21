defmodule Mix.Tasks.Durandal.Task.NewObject.Docs do
  @moduledoc false

  def short_doc do
    "Create a set of helper files around contextual objects"
  end

  def example do
    "mix durandal.task.new_object Game Universe universes name:string age:integer"
  end

  def long_doc do
    """
    #{short_doc()}

    Create a set of helper files around contextual objects.

    ## Example

    ```bash
    #{example()}
    ```
    """
  end
end

if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.Durandal.Task.NewObject do
    @shortdoc "#{__MODULE__.Docs.short_doc()}"

    @moduledoc __MODULE__.Docs.long_doc()
    @application "Durandal"

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

    defp do_template(template_string, argv) do
      [context, singular, plural | _fields] = argv

      template_string
      |> String.replace("Application", @application)
      |> String.replace("Context", context)
      |> String.replace("context", String.downcase(context))
      |> String.replace("objects", plural)
      |> String.replace("Object", singular)
      |> String.replace("object", String.downcase(singular))
      |> String.replace("uuid1", "005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      |> String.replace("uuid2", "c11a487b-16a2-4806-bd7a-dcf110d16b61")
    end

    defp library_file(igniter) do
      [context, singular, _plural | _fields] = igniter.args.argv

      path =
        "lib/#{String.downcase(@application)}/#{String.downcase(context)}/libs/#{String.downcase(singular)}_lib.ex"

      file_output =
        File.read!("priv/templates/library.exs")
        |> do_template(igniter.args.argv)

      Igniter.create_new_file(igniter, path, file_output)
    end

    defp context_file(igniter) do
      [context, _singular, _plural | _fields] = igniter.args.argv

      path = "lib/#{String.downcase(@application)}/#{String.downcase(context)}.ex"

      if Igniter.exists?(igniter, path) do
        existing_content = File.read!(path)

        file_output =
          File.read!("priv/templates/context.exs")
          |> do_template(igniter.args.argv)
          |> String.replace("\\", "\\\\")

        new_source = Regex.replace(~r/\nend$/, existing_content, "\n\n#{file_output}\nend")

        Igniter.create_new_file(igniter, path, new_source, on_exists: :overwrite)
      else
        pre = "defmodule #{@application}.#{context} do"
        post = "end"

        file_output =
          File.read!("priv/templates/context.exs")
          |> do_template(igniter.args.argv)

        Igniter.create_new_file(igniter, path, "#{pre}\n#{file_output}\n#{post}")
      end
    end

    defp schema_file(igniter) do
      [context, singular, _plural | fields] = igniter.args.argv

      fields =
        fields
        |> Enum.map(fn fstr ->
          String.split(fstr, ":")
        end)

      path =
        "lib/#{String.downcase(@application)}/#{String.downcase(context)}/schemas/#{String.downcase(singular)}.ex"

      doc_fields =
        fields
        |> Enum.map_join("\n", fn [name | _] ->
          "* `:#{name}` - field description"
        end)

      schema_fields =
        fields
        |> Enum.map_join("\n", fn
          [name, "datetime"] -> "    field(#{name}, :utc_datetime)"
          [name, type] -> "    field(#{name}, :#{type})"
          [name, "array", sub_type] -> "    field(#{name}, {:array, :#{sub_type}})"
        end)

      schema_type_fields =
        fields
        |> Enum.map_join(",\n", fn
          [name, "string"] -> "  #         #{name}: String.t(),"
          [name, "datetime"] -> "  #         #{name}: DateTime.t(),"
          [name, "date"] -> "  #         #{name}: Date.t(),"
          [name, "uuid"] -> "  #         #{name}: Ecto.UUID.t(),"
          [name, type] -> "  #         #{name}: #{type}(),"
          [name, "array", sub_type] -> "        #{name}: [#{String.capitalize(sub_type)}.t()],"
        end)

      required_fields =
        fields
        |> Enum.map_join(" ", fn [name | _] -> name end)

      file_output =
        File.read!("priv/templates/schema.exs")
        |> String.replace("# SCHEMA DOC FIELDS", doc_fields)
        |> String.replace("# SCHEMA FIELDS", schema_fields)
        |> String.replace("# SCHEMA TYPE FIELDS", schema_type_fields)
        |> String.replace("@required_fields ~w()a", "@required_fields ~w(#{required_fields})a")
        |> do_template(igniter.args.argv)

      Igniter.create_new_file(igniter, path, file_output)
    end

    defp queries_file(igniter) do
      [context, singular, _plural | fields] = igniter.args.argv

      fields =
        fields
        |> Enum.map(fn fstr ->
          String.split(fstr, ":")
        end)

      path =
        "lib/#{String.downcase(@application)}/#{String.downcase(context)}/queries/#{String.downcase(singular)}_queries.ex"

      where_functions =
        fields
        |> Enum.map_join("\n\n", fn
          [name, _type] ->
            """
            def _where(query, :#{name}, #{name}) do
              from objects in query,
                where: objects.#{name} in List.wrap(^#{name})
            end
            """
        end)

      order_by_functions =
        fields
        |> Enum.map(fn
          ["name", _type] ->
            """
            def _order_by(query, "Name (A-Z)") do
              from(users in query,
                order_by: [asc: users.name]
              )
            end

            def _order_by(query, "Name (Z-A)") do
              from(users in query,
                order_by: [desc: users.name]
              )
            end
            """

          _ ->
            nil
        end)
        |> Enum.reject(&is_nil(&1))
        |> Enum.join("\n\n")

      file_output =
        File.read!("priv/templates/queries.exs")
        |> String.replace("# WHERE FUNCTIONS", where_functions)
        |> String.replace("# ORDER BY FUNCTIONS", order_by_functions)
        |> do_template(igniter.args.argv)

      Igniter.create_new_file(igniter, path, file_output)
    end

    defp library_test_file(igniter) do
      [context, singular, _plural | fields] = igniter.args.argv

      path =
        "test/#{String.downcase(@application)}/#{String.downcase(context)}/libs/#{String.downcase(singular)}_lib_test.exs"

      fields =
        fields
        |> Enum.map(fn fstr ->
          String.split(fstr, ":")
        end)

      first_string_field =
        fields
        |> Enum.find(fn [_, t | _] -> t == "string" end)
        |> hd()

      valid_attrs =
        fields
        |> Enum.map_join(",\n", fn
          [name, "string"] -> "#{name}: \"Some #{name}\""
          [name, "integer"] -> "#{name}: 123"
          [name, "boolean"] -> "#{name}: true"
        end)

      update_attrs =
        fields
        |> Enum.map_join(",\n", fn
          [name, "string"] -> "#{name}: \"Some updated #{name}\""
          [name, "integer"] -> "#{name}: 456"
          [name, "boolean"] -> "#{name}: false"
        end)

      invalid_attrs =
        fields
        |> Enum.map_join(",\n", fn
          [name, _] -> "#{name}: nil"
        end)

      file_output =
        File.read!("priv/templates/library_test.exs")
        |> String.replace("# VALID ATTRS", valid_attrs)
        |> String.replace("# UPDATE ATTRS", update_attrs)
        |> String.replace("# INVALID ATTRS", invalid_attrs)
        |> String.replace("FIRST_STRING_FIELD", first_string_field)
        |> do_template(igniter.args.argv)

      Igniter.create_new_file(igniter, path, file_output)
    end

    defp queries_test_file(igniter) do
      [context, singular, _plural | fields] = igniter.args.argv

      path =
        "test/#{String.downcase(@application)}/#{String.downcase(context)}/queries/#{String.downcase(singular)}_query_test.exs"

      fields =
        fields
        |> Enum.map(fn fstr ->
          String.split(fstr, ":")
        end)

      field_test =
        fields
        |> Enum.map(fn
          [name, "string"] ->
            [
              "#{name}: [\"Some string\", \"Another string\"],",
              "#{name}: \"Some string\","
            ]

          [name, "integer"] ->
            [
              "#{name}: [123, 456],",
              "#{name}: 789,"
            ]

          [name, "boolean"] ->
            [
              "#{name}: [true, false],",
              "#{name}: true,"
            ]

          _ ->
            []
        end)
        |> List.flatten()
        |> Enum.join("\n")

      order_by_test =
        fields
        |> Enum.map(fn
          ["name", _type] ->
            [
              "\"name (A-Z)\",",
              "\"name (Z-A)\","
            ]

          _ ->
            []
        end)
        |> List.flatten()
        |> Enum.join("\n")

      file_output =
        File.read!("priv/templates/queries_test.exs")
        |> String.replace("# FIELD TEST", field_test)
        |> String.replace("# ORDER BY TEST", order_by_test)
        |> do_template(igniter.args.argv)

      Igniter.create_new_file(igniter, path, file_output)
    end

    def create_migration(igniter) do
      [context, _singular, plural | fields] = igniter.args.argv

      migration_name = "create_#{String.downcase(context)}_#{plural}_table"

      fields =
        fields
        |> Enum.map(fn fstr ->
          String.split(fstr, ":")
        end)

      field_defs =
        fields
        |> Enum.map_join("\n", fn
          [name, "string"] -> "add(:#{name}, :string)"
          [name, "integer"] -> "add(:#{name}, :integer)"
          [name, "boolean"] -> "add(:#{name}, :boolean)"
          [name, "uuid"] -> "add(:#{name}, :uuid)"
          [name, "datetime"] -> "add(:#{name}, :utc_datetime)"
          [name, "date"] -> "add(:#{name}, :date)"
          [name, "map"] -> "add(:#{name}, :jsonb)"
          [name, "array", sub_type] -> "add(:#{name}, {:array, :#{sub_type}})"
        end)

      body = """
      create_if_not_exists table(:#{String.downcase(context)}_#{plural}, primary_key: false) do
        add(:id, :uuid, primary_key: true, null: false)

        #{field_defs}

        timestamps(type: :utc_datetime)
      end
      """

      Igniter.Libs.Ecto.gen_migration(igniter, Durandal.Repo, migration_name,
        body: body,
        on_exists: :overwrite
      )
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      igniter
      |> schema_file()
      |> library_file()
      |> context_file()
      |> queries_file()
      |> library_test_file()
      |> queries_test_file()
      |> create_migration()
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
