defmodule Mix.Tasks.Durandal.Task.FakeData do
  @moduledoc """
  Run with mix durandal.task.fake_data

  You can override some of the options with:

  mix durandal.task.fake_data days:7 detail-days:3

  ## `days`
  The number of days of data to generate

  ## `detail-days`
  The number of days with extra detail to generate
  """

  use Mix.Task

  alias Durandal.Account
  require Logger

  @defaults %{
    days: 7,
    detail_days: 3
  }

  @spec parse_args(list()) :: map()
  defp parse_args(args) do
    args
    |> Enum.reduce(@defaults, fn
      "days:" <> day_str, acc ->
        Map.put(acc, :days, String.to_integer(day_str))

      "detail-days:" <> day_str, acc ->
        Map.put(acc, :detail_days, String.to_integer(day_str))
    end)
  end

  @spec run(list()) :: :ok
  def run(args) do
    if Application.get_env(:durandal, :dev_mode) do
      config = parse_args(args)

      # Start by rebuilding the database
      Mix.Task.run("ecto.reset")

      # We have to start Durandal to change the logger config
      Application.ensure_all_started(:durandal)
      Logger.configure(level: :info)
      :timer.sleep(1_000)

      start_time = System.system_time(:second)

      _root_user = add_root_user()

      Durandal.FakeData.FakeAccounts.make_accounts(config)

      make_one_time_code(config)
      output_stats(start_time, config)

      IO.puts(
        "You can now login with the email 'root@localhost' and password 'password'.\nA one-time link has been created: http://localhost:4000/login/fakedata_code\n"
      )
    else
      Logger.error("Enfys mode is not enabled, you cannot run the fakedata task")
    end
  end

  defp add_root_user() do
    {:ok, user} =
      Account.create_user(%{
        name: "root",
        email: "root@localhost",
        password: "password",
        groups: ["admin"],
        permissions: ["admin"]
      })

    user
  end

  defp make_one_time_code(_config) do
    root_user = Account.get_user_by_email("root@localhost")

    {:ok, _code} =
      Durandal.Account.create_user_token(%{
        user_id: root_user.id,
        identifier_code: Durandal.Account.UserTokenLib.generate_code(),
        renewal_code: Durandal.Account.UserTokenLib.generate_code(),
        context: "fake-data-create",
        user_agent: "fake-data",
        ip: "127.0.0.1",
        expires_at: DateTime.utc_now() |> DateTime.shift(hour: 1)
      })
  end

  defp get_table_sizes() do
    query = """
      WITH tbl AS
        (SELECT table_schema,
                TABLE_NAME
        FROM information_schema.tables
        WHERE TABLE_NAME not like 'pg_%'
          AND table_schema in ('public'))
      SELECT TABLE_NAME,
            (xpath('/row/c/text()', query_to_xml(format('select count(*) as c from %I.%I', table_schema, TABLE_NAME), FALSE, TRUE, '')))[1]::text::int AS rows_n
      FROM tbl
      ORDER BY rows_n DESC;
    """

    results =
      case Ecto.Adapters.SQL.query(Durandal.Repo, query, []) do
        {:ok, results} ->
          results.rows
          |> Enum.reject(fn [table, row_count] ->
            row_count <= 0 or
              Enum.member?(
                ~w(oban_peers oban_jobs durandal_cluster_members account_user_tokens schema_migrations),
                table
              )
          end)

        {a, b} ->
          raise "ERR: #{a}, #{b}"
      end

    results
  end

  defp output_stats(start_time, config) do
    elapsed = System.system_time(:second) - start_time
    sizes = get_table_sizes()

    {target_size, total_rows} =
      sizes
      |> Enum.reduce({0, 0}, fn [name, row_count], {size_acc, count_acc} ->
        {
          max(String.length(name), size_acc),
          count_acc + row_count
        }
      end)

    IO.puts("\n\n#{String.pad_trailing("Table", target_size)} | Rows")

    sizes
    |> Enum.each(fn [table, row_count] ->
      padded_name = String.pad_trailing(table, target_size)

      IO.puts("#{padded_name} | #{Durandal.Helper.StringHelper.format_number(row_count)}")
    end)

    IO.puts(
      "\nFake data insertion complete.\nTook #{elapsed} seconds, inserted #{Durandal.Helper.StringHelper.format_number(total_rows)} rows for #{config.days} days of data. "
    )
  end
end
