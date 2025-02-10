defmodule TextSplitterTest do
  use ExUnit.Case

  alias LangChain.TextSplitter

  describe "CharacterTextSplitter" do
    test "New TextSplitter" do
      expected_splitter = %TextSplitter{
        separator: " ",
        chunk_overlap: 0,
        chunk_size: 2
      }

      assert {:ok, %TextSplitter{} = output_splitter} =
               %{separator: " ", chunk_overlap: 0, chunk_size: 2}
               |> TextSplitter.new()

      assert expected_splitter == output_splitter
    end

    test "New TextSplitter with keep_separator" do
      expected_splitter = %TextSplitter{
        separator: " ",
        chunk_overlap: 0,
        chunk_size: 2,
        keep_separator: :start
      }

      assert {:ok, %TextSplitter{} = output_splitter} =
               %{separator: " ", chunk_overlap: 0, chunk_size: 2, keep_separator: :start}
               |> TextSplitter.new()

      assert expected_splitter == output_splitter
    end

    test "Splitting by character count" do
      text = "foo bar baz 123"
      expected_output = ["foo bar", "bar baz", "baz 123"]

      {:ok, character_splitter} =
        TextSplitter.new(%{separator: " ", chunk_size: 7, chunk_overlap: 3})

      output =
        character_splitter
        |> TextSplitter.split_text(text)

      assert expected_output == output
    end

    test "Splitting character by count doesn't create empty documents" do
      text = "foo  bar"
      expected_output = ["foo", "bar"]

      {:ok, character_splitter} =
        TextSplitter.new(%{separator: " ", chunk_size: 2, chunk_overlap: 0})

      output =
        character_splitter
        |> TextSplitter.split_text(text)

      assert expected_output == output
    end

    test "Edge cases are separators" do
      text = "f b"
      expected_output = ["f", "b"]

      {:ok, character_splitter} =
        TextSplitter.new(%{separator: " ", chunk_size: 2, chunk_overlap: 0})

      output =
        character_splitter
        |> TextSplitter.split_text(text)

      assert expected_output == output
    end

    test "Splitting by character count on long words" do
      text = "foo bar baz a a"
      expected_output = ["foo", "bar", "baz", "a a"]

      {:ok, character_splitter} =
        TextSplitter.new(%{separator: " ", chunk_size: 3, chunk_overlap: 1})

      output =
        character_splitter
        |> TextSplitter.split_text(text)

      assert expected_output == output
    end

    test "Splitting by character count when shorter words are first" do
      text = "a a foo bar baz"
      expected_output = ["a a", "foo", "bar", "baz"]

      {:ok, character_splitter} =
        TextSplitter.new(%{separator: " ", chunk_size: 3, chunk_overlap: 1})

      output =
        character_splitter
        |> TextSplitter.split_text(text)

      assert expected_output == output
    end

    test "Splitting by characters when splits not found easily" do
      text = "foo bar baz 123"
      expected_output = ["foo", "bar", "baz", "123"]

      {:ok, character_splitter} =
        TextSplitter.new(%{separator: " ", chunk_size: 3, chunk_overlap: 1})

      output =
        character_splitter
        |> TextSplitter.split_text(text)

      assert expected_output == output
    end

    test "Splitting by characters and keeping at start separator that is a regex special char" do
      text = "foo.bar.baz.123"
      expected_output = ["foo", ".bar", ".baz", ".123"]

      base_params = %{
        chunk_size: 1,
        chunk_overlap: 0,
        keep_separator: :start
      }

      test_params = [
        %{separator: ".", is_separator_regex: false},
        %{separator: Regex.escape("."), is_separator_regex: true}
      ]

      for tt <- test_params do
        {:ok, character_splitter} =
          TextSplitter.new(Map.merge(base_params, tt))

        output =
          character_splitter
          |> TextSplitter.split_text(text)

        assert expected_output == output
      end
    end

    test "Splitting by characters and keeping at end separator that is a regex special char" do
      text = "foo.bar.baz.123"
      expected_output = ["foo.", "bar.", "baz.", "123"]

      base_params = %{
        chunk_size: 1,
        chunk_overlap: 0,
        keep_separator: :end
      }

      test_params = [
        %{separator: ".", is_separator_regex: false},
        %{separator: Regex.escape("."), is_separator_regex: true}
      ]

      for tt <- test_params do
        {:ok, character_splitter} =
          TextSplitter.new(Map.merge(base_params, tt))

        output =
          character_splitter
          |> TextSplitter.split_text(text)

        assert expected_output == output
      end
    end

    @tag :wip
    test "Splitting by characters and discard separator that is a regex special char" do
      text = "foo.bar.baz.123"
      expected_output = ["foo", "bar", "baz", "123"]

      base_params = %{
        chunk_size: 1,
        chunk_overlap: 0
      }

      test_params = [
        %{separator: ".", is_separator_regex: false},
        %{separator: Regex.escape("."), is_separator_regex: true}
      ]

      for tt <- test_params do
        {:ok, character_splitter} =
          TextSplitter.new(Map.merge(base_params, tt))

        output =
          character_splitter
          |> TextSplitter.split_text(text)

        assert expected_output == output
      end
    end
  end
end
