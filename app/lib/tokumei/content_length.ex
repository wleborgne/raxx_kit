defmodule Tokumei.ContentLength do
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end
  defmacro __before_compile__(_env) do
    quote location: :keep do
      defoverridable [handle_request: 2]

      def handle_request(request, env) do
        response = super(request, env)
        case response do
          %{body: _} -> # I am a response
            response = case Raxx.ContentLength.fetch(response) do
              {:ok, _} ->
                response
              {:error, :field_value_not_specified} ->
                Raxx.ContentLength.set(response, :erlang.iolist_size(response.body))
            end
          # TODO no chunked in latest
          upgrade = %Raxx.Chunked{} ->
            upgrade
          other ->
            other
        end
      end
    end
  end
end
