defmodule LLMDB.Sources.AnthropicTest do
  use ExUnit.Case, async: true

  alias LLMDB.{Sources.Anthropic, Validate}

  describe "transform/1" do
    test "maps Models API fields into canonical model metadata" do
      input = %{
        "data" => [
          %{
            "id" => "claude-opus-4-8",
            "type" => "model",
            "display_name" => "Claude Opus 4.8",
            "created_at" => "2026-05-28T00:00:00Z",
            "max_input_tokens" => 1_000_000,
            "max_tokens" => 128_000,
            "capabilities" => %{
              "image_input" => %{"supported" => true},
              "pdf_input" => %{"supported" => true},
              "structured_outputs" => %{"supported" => true},
              "thinking" => %{"supported" => true}
            }
          }
        ]
      }

      assert %{"anthropic" => %{models: [model]}} = Anthropic.transform(input)

      assert model.id == "claude-opus-4-8"
      assert model.provider == :anthropic
      assert model.name == "Claude Opus 4.8"
      assert model.release_date == "2026-05-28"
      assert model.limits == %{context: 1_000_000, output: 128_000}
      assert model.modalities == %{input: [:text, :image, :pdf], output: [:text]}
      assert model.capabilities.reasoning.enabled == true
      assert model.capabilities.json.schema == true
      assert model.extra.type == "model"

      assert {:ok, validated} = Validate.validate_model_overlay(model)
      assert validated.limits == model.limits
      assert validated.capabilities == model.capabilities
    end
  end
end
