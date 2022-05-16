`Charmer` is a minimal, somewhat configurable library for creating and 
interacting with a pool of Python processes in Elixir. While this package was used
in a production environment for well over a year, it has not been exercised
beyond its initial specific use case.

## Usage example

The following small example adds 1 to each element of a list of numbers by
fanning the work over 4 Python worker processes:

```elixir
Charmer.start_link(python_path: @python_path)

1..5
|> Task.async_stream(&Charmer.call(@python_test_module, "inc", [&1]))
|> Enum.map(fn {:ok, x} -> x end)

Charmer.stop()
```

This returns the expected result `[2, 3, 4, 5, 6]`.

## Foundation

This package uses `Poolboy` to create and interact with an OTP process pool, and
`Export` to interact with each of the Python runtimes.
