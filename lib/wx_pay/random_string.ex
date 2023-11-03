defmodule RandomString do
  @charset "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

  def generate_random_string(length) do
    generate_random_string(length, "")
  end

  defp generate_random_string(0, acc), do: acc
  defp generate_random_string(length, acc) do
    random_char = get_random_char()
    generate_random_string(length - 1, "#{acc}#{random_char}")
  end

  defp get_random_char do
    char_index = :rand.uniform(String.length(@charset))
    String.at(@charset, char_index)
  end
end


