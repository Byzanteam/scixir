defmodule Scixir.Util do
  def repush_working_messages(list_name, working_list_name) do
    do_rpoplpush(working_list_name, list_name)
  end

  defp do_rpoplpush(working_list_name, list_name) do
    do_rpoplpush(working_list_name, list_name, {:ok, :intial})
  end

  defp do_rpoplpush(_working_list_name, _list_name, {:ok, nil}) do
    :ok
  end

  defp do_rpoplpush(working_list_name, list_name, {:ok, _val}) do
    do_rpoplpush(
      working_list_name,
      list_name,
      Redix.command(:redix, ["RPOPLPUSH", working_list_name, list_name])
    )
  end
end
