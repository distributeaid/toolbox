defmodule Mix.Tasks.Db.Diagram do
  use Mix.Task

  @default_opts [
    hostname: "localhost",
    port: 5432,
    database: "toolbox",
    username: "toolbox",
    password: "toolbox"
  ]

  @output "./schemaspy"
  @diagram "docs/db/diagram.png"

  @shortdoc "Generate a database diagram"
  @spec run(any) :: {any, non_neg_integer}
  def run(_) do
    with {_, 0} <- generate(),
         {_, 0} <- copy() do
      IO.puts("Written #{@diagram}.")
      IO.puts("Please don't forget to add this file to source control.")
      {"", 0}
    else
      {error, _} = err ->
        IO.puts("Error: #{error}")
        err
    end
  end

  defp generate() do
    db =
      Application.get_env(:ferry, Ferry.Repo)
      |> with_defaults()

    IO.puts(
      "Generating diagram for database #{db[:database]} at #{db[:hostname]}:#{db[:port]}..."
    )

    System.cmd("java", [
      "-jar",
      "java/schemaspy-6.1.0.jar",
      "-t",
      "pgsql",
      "-db",
      "#{db[:database]}",
      "-host",
      "#{db[:hostname]}",
      "-u",
      "#{db[:username]}",
      "-p",
      "#{db[:password]}",
      "-o",
      @output,
      "-dp",
      "java/postgresql-42.2.13.jar",
      "-s",
      "public",
      "-noads"
    ])
  end

  defp copy() do
    System.cmd("cp", [
      "#{@output}/diagrams/summary/relationships.real.compact.png",
      @diagram
    ])
  end

  defp with_defaults(opts) do
    Enum.reduce(@default_opts, [], fn {k, v}, acc ->
      Keyword.put(acc, k, opts[k] || v)
    end)
  end
end
