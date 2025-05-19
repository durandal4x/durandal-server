defmodule Mix.Tasks.Durandal.Task.NewObject.Docs do
  @moduledoc false

  def short_doc do
    "Create a set of helper files around contextual objects"
  end

  def example do
    "mix durandal.task.new_object Player TeamMember team_members roles:array:string team:references:player_teams user:references:account_users"
  end

  def long_doc do
    """
    #{short_doc()}

    Create a set of helper files around contextual objects. Intended to follow similar syntax as https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Schema.html

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

    defp camel_case(s) do
      Regex.replace(~r/([a-z])([A-Z])/, s, "\\1_\\2")
      |> String.downcase()
    end

    defp find_module_by_table_name(table_name) do
      path =
        Path.wildcard("lib/**/*.ex")
        |> Enum.find(fn file ->
          File.read!(file)
          |> String.contains?("schema \"#{table_name}\" do")
        end)

      if path do
        [_, module_name] = Regex.run(~r/defmodule\s+([\w\.]+)\s+do/, File.read!(path))
        module_name
      else
        table_name
      end
    end

    defp do_template(template_string, argv) do
      [context, singular, plural | _fields] = argv

      template_string
      |> String.replace("$Application", @application)
      |> String.replace("$Context", context)
      |> String.replace("$context", camel_case(context))
      |> String.replace("$objects", plural)
      |> String.replace("$Object", singular)
      |> String.replace("$object", camel_case(singular))
      |> String.replace("$uuid1", "005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      |> String.replace("$uuid2", "c11a487b-16a2-4806-bd7a-dcf110d16b61")
    end

    defp library_file(igniter) do
      [context, singular, _plural | _fields] = igniter.args.argv

      path =
        "lib/#{camel_case(@application)}/#{camel_case(context)}/libs/#{camel_case(singular)}_lib.ex"

      file_output =
        File.read!("priv/templates/library.eex")
        |> do_template(igniter.args.argv)

      Igniter.create_new_file(igniter, path, file_output, on_exists: :warning)
    end

    defp context_file(igniter) do
      [context, _singular, _plural | _fields] = igniter.args.argv

      path = "lib/#{camel_case(@application)}/#{camel_case(context)}.ex"

      if Igniter.exists?(igniter, path) do
        existing_content = File.read!(path)

        # TODO: this doesn't correctly check for the presence of this code if the name is long
        # enough it will be wrapped by a format command
        file_output =
          File.read!("priv/templates/context.eex")
          |> do_template(igniter.args.argv)

        # If we're redoing the file the content will already exist
        new_source =
          if String.contains?(existing_content, file_output) do
            existing_content
          else
            formatted_file_output =
              file_output
              |> String.replace("\\", "\\\\")

            Regex.replace(
              ~r/\nend$/,
              String.trim(existing_content),
              "\n\n#{formatted_file_output}\nend"
            )
          end

        Igniter.create_new_file(igniter, path, new_source, on_exists: :warning)
      else
        pre = """
          defmodule #{@application}.#{context} do
            @moduledoc \"""

            \"""
        """

        post = "end"

        file_output =
          File.read!("priv/templates/context.eex")
          |> do_template(igniter.args.argv)

        Igniter.create_new_file(igniter, path, "#{pre}\n#{file_output}\n#{post}",
          on_exists: :warning
        )
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
        "lib/#{camel_case(@application)}/#{camel_case(context)}/schemas/#{camel_case(singular)}.ex"

      doc_fields =
        fields
        |> Enum.map_join("\n", fn
          [name, "references", table] ->
            "* `:#{name}_id` - #{table} field description"

          [name | _] ->
            "* `:#{name}` - field description"
        end)

      schema_fields =
        fields
        |> Enum.map_join("\n", fn
          [name, "references", table] ->
            "belongs_to(:#{name}, #{find_module_by_table_name(table)}, type: Ecto.UUID)"

          [name, "datetime"] ->
            "field(:#{name}, :utc_datetime)"

          [name, "uuid"] ->
            "field(:#{name}, Ecto.UUID)"

          [name, type] ->
            "field(:#{name}, :#{type})"

          [name, "array", sub_type] ->
            "field(:#{name}, {:array, :#{sub_type}})"
        end)

      schema_type_fields =
        fields
        |> Enum.map_join("\n", fn
          [name, "references", table] ->
            "  #         #{name}_id: #{find_module_by_table_name(table)}.id(),"

          [name, "string"] ->
            "  #         #{name}: String.t(),"

          [name, "datetime"] ->
            "  #         #{name}: DateTime.t(),"

          [name, "date"] ->
            "  #        #{name}: Date.t(),"

          [name, "uuid"] ->
            "  #        #{name}: Ecto.UUID.t(),"

          [name, type] ->
            "  #         #{name}: #{type}(),"

          [name, "array", sub_type] ->
            "  #         #{name}: [#{String.capitalize(sub_type)}.t()],"
        end)

      required_fields =
        fields
        |> Enum.map_join(" ", fn
          [name, "references", _table] -> "#{name}_id"
          [name | _] -> name
        end)

      file_output =
        File.read!("priv/templates/schema.eex")
        |> String.replace("# SCHEMA DOC FIELDS", doc_fields)
        |> String.replace("# SCHEMA FIELDS", schema_fields)
        |> String.replace("# SCHEMA TYPE FIELDS", schema_type_fields)
        |> String.replace("@required_fields ~w()a", "@required_fields ~w(#{required_fields})a")
        |> do_template(igniter.args.argv)

      Igniter.create_new_file(igniter, path, file_output, on_exists: :warning)
    end

    defp queries_file(igniter) do
      [context, singular, _plural | fields] = igniter.args.argv

      fields =
        fields
        |> Enum.map(fn fstr ->
          String.split(fstr, ":")
        end)

      path =
        "lib/#{camel_case(@application)}/#{camel_case(context)}/queries/#{camel_case(singular)}_queries.ex"

      where_functions =
        fields
        |> Enum.map(fn
          [name, _type] ->
            """
            def _where(query, :#{name}, #{name}) do
              from $objects in query,
                where: $objects.#{name} in ^List.wrap(#{name})
            end
            """

          [name, "references", _table] ->
            """
            def _where(query, :#{name}_id, :not_nil) do
              from $objects in query,
                where: not is_nil($objects.#{name}_id)
            end

            def _where(query, :#{name}_id, :is_nil) do
              from $objects in query,
                where: is_nil($objects.#{name}_id)
            end

            def _where(query, :#{name}_id, #{name}_id) do
              from $objects in query,
                where: $objects.#{name}_id in ^List.wrap(#{name}_id)
            end
            """

          [name, "array", _sub_type] ->
            """
            def _where(query, :has_#{name}, #{name}) do
              from($objects in query,
                where: ^#{name} in $objects.#{name}
              )
            end

            def _where(query, :not_has_#{name}, #{name}) do
              from($objects in query,
                where: ^#{name} not in $objects.#{name}
              )
            end
            """

          _ ->
            nil
        end)
        |> Enum.reject(&is_nil(&1))
        |> Enum.join("\n\n")

      order_by_functions =
        fields
        |> Enum.map(fn
          ["name", _type] ->
            """
            def _order_by(query, "Name (A-Z)") do
              from($objects in query,
                order_by: [asc: $objects.name]
              )
            end

            def _order_by(query, "Name (Z-A)") do
              from($objects in query,
                order_by: [desc: $objects.name]
              )
            end
            """

          _ ->
            nil
        end)
        |> Enum.reject(&is_nil(&1))
        |> Enum.join("\n\n")

      preload_functions =
        fields
        |> Enum.filter(fn
          [_, "references", _] -> true
          _ -> false
        end)
        |> Enum.map_join("\n\n", fn [name, "references", target] ->
          """
            def _preload(query, :#{name}) do
              from $objects in query,
                left_join: #{target} in assoc($objects, :#{name}),
                preload: [#{name}: #{target}]
            end
          """
        end)

      preload_output =
        if preload_functions == "" do
          """
          defp do_preload(query, _), do: query
          # defp do_preload(query, preloads) do
          #   preloads
          #   |> List.wrap
          #   |> Enum.reduce(query, fn key, query_acc ->
          #     _preload(query_acc, key)
          #   end)
          # end

          # @spec _preload(Ecto.Query.t(), any) :: Ecto.Query.t()
          # def _preload(query, :relation) do
          #   from $object in query,
          #     left_join: relations in assoc($object, :relation),
          #     preload: [relation: relations]
          # end
          """
        else
          """
          defp do_preload(query, preloads) do
            preloads
            |> List.wrap
            |> Enum.reduce(query, fn key, query_acc ->
              _preload(query_acc, key)
            end)
          end

          #{preload_functions}
          """
        end

      file_output =
        File.read!("priv/templates/queries.eex")
        |> String.replace("# WHERE FUNCTIONS", where_functions)
        |> String.replace("# ORDER BY FUNCTIONS", order_by_functions)
        |> String.replace("# PRELOAD FUNCTIONS", preload_output)
        |> do_template(igniter.args.argv)

      Igniter.create_new_file(igniter, path, file_output, on_exists: :warning)
    end

    defp library_test_file(igniter) do
      [context, singular, _plural | fields] = igniter.args.argv

      path =
        "test/#{camel_case(@application)}/#{camel_case(context)}/libs/#{camel_case(singular)}_lib_test.exs"

      fields =
        fields
        |> Enum.map(fn fstr ->
          String.split(fstr, ":")
        end)

      valid_attrs =
        fields
        |> Enum.map_join(",\n", fn
          [name, "string"] ->
            "#{name}: \"some #{name}\""

          [name, "uuid"] ->
            "#{name}: \"f93c0484-8e12-49ef-bc8c-1055090e94e7\""

          [name, "integer"] ->
            "#{name}: 123"

          [name, "boolean"] ->
            "#{name}: true"

          [name, "map"] ->
            "#{name}: %{\"key1\" => 123, \"key2\" => \"value\"}"

          [name, "references", _table] ->
            id_name = name <> "_id"
            "#{id_name}: #{name}_fixture().id"

          [name, "array", "string"] ->
            "#{name}: [\"String one\", \"String two\"]"

          [name, "array", "uuid"] ->
            "#{name}: [\"9438c3a0-2dd1-4ba3-aae9-bab7f2f7c931\", \"b8bd8449-b15d-4df2-a8e2-d1a71051555a\"]"

          [name, "array", "integer"] ->
            "#{name}: [123, 456]"
        end)

      update_attrs =
        fields
        |> Enum.map_join(",\n", fn
          [name, "string"] ->
            "#{name}: \"some updated #{name}\""

          [name, "uuid"] ->
            "#{name}: \"2c77b935-4b83-491a-92ab-a35045803609\""

          [name, "integer"] ->
            "#{name}: 456"

          [name, "boolean"] ->
            "#{name}: false"

          [name, "references", _table] ->
            "#{name}_id: #{name}_fixture().id"

          [name, "map"] ->
            "#{name}: %{\"key1\" => 123, \"key3\" => \"value\"}"

          [name, "array", "string"] ->
            "#{name}: [\"String one\", \"String two\", \"String three\"]"

          [name, "array", "uuid"] ->
            "#{name}: [\"6fbaf9d1-7705-46db-a4b1-ab200b2b570a\", \"aead8e5d-bdf3-4cdd-816f-1b282c7a33fc\"]"

          [name, "array", "integer"] ->
            "#{name}: [123, 456, 789]"
        end)

      invalid_attrs =
        fields
        |> Enum.map_join(",\n", fn
          [name, _] -> "#{name}: nil"
          [name, "array", _] -> "#{name}: nil"
          [name, "references", _] -> "#{name}_id: nil"
        end)

      create_validate =
        fields
        |> Enum.map(fn
          [name, "string"] ->
            "assert $object.#{name} == \"some #{name}\""

          [name, "integer"] ->
            "assert $object.#{name} == 123"

          [name, "array", "string"] ->
            "assert $object.#{name} == [\"String one\", \"String two\"]"

          [name, "array", "integer"] ->
            "assert $object.#{name} == [123, 456]"

          [name, "map"] ->
            "assert $object.#{name} == %{\"key1\" => 123, \"key2\" => \"value\"}"

          _ ->
            nil
        end)
        |> Enum.reject(&is_nil(&1))
        |> Enum.join("\n")

      update_validate =
        fields
        |> Enum.map(fn
          [name, "string"] ->
            "assert $object.#{name} == \"some updated #{name}\""

          [name, "integer"] ->
            "assert $object.#{name} == 456"

          [name, "array", "string"] ->
            "assert $object.#{name} == [\"String one\", \"String two\", \"String three\"]"

          [name, "array", "integer"] ->
            "assert $object.#{name} == [123, 456, 789]"

          [name, "map"] ->
            "assert $object.#{name} == %{\"key1\" => 123, \"key3\" => \"value\"}"

          _ ->
            nil
        end)
        |> Enum.reject(&is_nil(&1))
        |> Enum.join("\n")

      file_output =
        File.read!("priv/templates/library_test.eex")
        |> String.replace("# VALID ATTRS", valid_attrs)
        |> String.replace("# UPDATE ATTRS", update_attrs)
        |> String.replace("# INVALID ATTRS", invalid_attrs)
        |> String.replace("# VALIDATE CREATE VALUES", create_validate)
        |> String.replace("# VALIDATE UPDATE VALUES", update_validate)
        |> do_template(igniter.args.argv)

      Igniter.create_new_file(igniter, path, file_output, on_exists: :warning)
    end

    defp queries_test_file(igniter) do
      [context, singular, _plural | fields] = igniter.args.argv

      path =
        "test/#{camel_case(@application)}/#{camel_case(context)}/queries/#{camel_case(singular)}_queries_test.exs"

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
              "#{name}: [\"Some string\", \"Another string\"]",
              "#{name}: \"Some string\""
            ]

          [name, "integer"] ->
            [
              "#{name}: [123, 456]",
              "#{name}: 789"
            ]

          [name, "boolean"] ->
            [
              "#{name}: [true, false]",
              "#{name}: true"
            ]

          [name, "uuid"] ->
            [
              "#{name}: [\"92a26447-572e-4e3e-893c-42008287a9aa\", \"5bed6cfe-0ffd-40bf-ad49-4e82ca65c9be\"]",
              "#{name}: \"fc7cd2d5-004a-4799-8cec-0d198016e292\""
            ]

          [name, "references", _] ->
            [
              "#{name}_id: [\"92a26447-572e-4e3e-893c-42008287a9aa\", \"5bed6cfe-0ffd-40bf-ad49-4e82ca65c9be\"]",
              "#{name}_id: \"fc7cd2d5-004a-4799-8cec-0d198016e292\"",
              "#{name}_id: :is_nil",
              "#{name}_id: :not_nil"
            ]

          [name, "array", "string"] ->
            [
              "has_#{name}: \"Some string\"",
              "not_has_#{name}: \"Some string\""
            ]

          [name, "array", "integer"] ->
            [
              "has_#{name}: 123",
              "not_has_#{name}: 456"
            ]

          _ ->
            []
        end)
        |> List.flatten()
        |> Enum.join(",\n")

      order_by_test =
        fields
        |> Enum.map(fn
          ["name", _type] ->
            [
              "\"Name (A-Z)\",",
              "\"Name (Z-A)\","
            ]

          _ ->
            []
        end)
        |> List.flatten()
        |> Enum.join("\n")

      preload_tests =
        fields
        |> Enum.filter(fn
          [_, "references", _] -> true
          _ -> false
        end)
        |> Enum.map_join(", ", fn [name, "references", _target] ->
          ":#{name}"
        end)

      file_output =
        File.read!("priv/templates/queries_test.eex")
        |> String.replace("# FIELD TEST", field_test)
        |> String.replace("# ORDER BY TEST", order_by_test)
        |> String.replace("# PRELOAD TESTS", preload_tests)
        |> do_template(igniter.args.argv)

      Igniter.create_new_file(igniter, path, file_output, on_exists: :warning)
    end

    def create_migration(igniter) do
      [context, _singular, plural | fields] = igniter.args.argv

      migration_name = "create_#{camel_case(context)}_#{plural}_table"

      fields =
        fields
        |> Enum.map(fn fstr ->
          String.split(fstr, ":")
        end)

      field_defs =
        fields
        |> Enum.map_join("\n", fn
          [name, "string"] ->
            "add(:#{name}, :string)"

          [name, "integer"] ->
            "add(:#{name}, :integer)"

          [name, "boolean"] ->
            "add(:#{name}, :boolean)"

          [name, "uuid"] ->
            "add(:#{name}, :uuid)"

          [name, "datetime"] ->
            "add(:#{name}, :utc_datetime)"

          [name, "date"] ->
            "add(:#{name}, :date)"

          [name, "map"] ->
            "add(:#{name}, :jsonb)"

          [name, "array", "string"] ->
            "add(:#{name}, {:array, :string})"

          [name, "array", "uuid"] ->
            "add(:#{name}, {:array, Ecto.UUID})"

          [name, "array", "integer"] ->
            "add(:#{name}, {:array, :integer})"

          [name, "references", table] ->
            "add(:#{name}_id, references(:#{table}, on_delete: :nothing, type: :uuid), type: :uuid)"
        end)

      body = """
      def change do
        create_if_not_exists table(:#{camel_case(context)}_#{plural}, primary_key: false) do
          add(:id, :uuid, primary_key: true, null: false)

          #{field_defs}

          timestamps(type: :utc_datetime_usec)
        end
      end
      """

      Igniter.Libs.Ecto.gen_migration(igniter, Durandal.Repo, migration_name,
        body: body,
        on_exists: :overwrite
      )
    end

    defp test_fixtures_file(igniter) do
      [context, _singular, _plural | fields] = igniter.args.argv

      path = "test/support/fixtures/#{camel_case(context)}_fixtures.ex"

      fields =
        fields
        |> Enum.map(fn fstr ->
          String.split(fstr, ":")
        end)

      fixture_fields =
        fields
        |> Enum.map_join(",\n", fn
          [name, "references", _table] ->
            func_name = name |> String.replace("_id", "")
            "#{name}_id: data[\"#{name}_id\"] || #{func_name}_fixture().id"

          [name, "string"] ->
            "#{name}: data[\"#{name}\"] || \"$object_#{name}_\#{r}\""

          [name, "integer"] ->
            "#{name}: data[\"#{name}\"] || r"

          [name, "boolean"] ->
            "#{name}: data[\"#{name}\"] || false"

          [name, "datetime"] ->
            "#{name}: data[\"#{name}\"] || ~U[2024-04-25 00:01:00.00Z]"

          [name, "date"] ->
            "#{name}: data[\"#{name}\"] || ~D[2024-04-25]"

          [name, "uuid"] ->
            "#{name}: data[\"#{name}\"] || \"9b8c9217-72ec-40cb-9951-798e916288af\""

          [name, "map"] ->
            "#{name}: data[\"#{name}\"] || %{}"

          [name, "array", "string"] ->
            "#{name}: data[\"#{name}\"] || [\"$object_#{name}_\#{r}_1\", \"$object_#{name}_\#{r}_2\"]"

          [name, "array", "uuid"] ->
            "#{name}: data[\"#{name}\"] || [\"65e90589-5dbe-4b4c-a3e4-5f2fd889bead\", \"006dd7a9-a4b9-40a0-a80f-5f197620d2cb\"]"

          [name, "array", "integer"] ->
            "#{name}: data[\"#{name}\"] || [r, r + 1]"
        end)

      if Igniter.exists?(igniter, path) do
        existing_content = File.read!(path)

        file_output =
          File.read!("priv/templates/test_fixtures.eex")
          |> String.replace("# OBJECT FIELDS", fixture_fields)
          |> do_template(igniter.args.argv)
          |> String.replace("\\", "\\\\")

        new_source =
          Regex.replace(~r/\nend$/, String.trim(existing_content), "\n\n#{file_output}\nend")

        Igniter.create_new_file(igniter, path, new_source, on_exists: :warning)
      else
        pre = """
          defmodule #{@application}.#{context}Fixtures do
            @moduledoc false
        """

        post = "end"

        file_output =
          File.read!("priv/templates/test_fixtures.eex")
          |> String.replace("# OBJECT FIELDS", fixture_fields)
          |> do_template(igniter.args.argv)

        Igniter.create_new_file(igniter, path, "#{pre}\n#{file_output}\n#{post}",
          on_exists: :warning
        )
      end
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
      |> test_fixtures_file()
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
