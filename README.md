`Charmer` is a minimal, somewhat configurable Elixir library for creating and 
interacting with a pool of Python processes. While this package was used
in a production environment for well over a year, it has not been exercised
beyond its initial specific use case.

## Usage example

The following small example adds 1 to each element of a list of numbers by
fanning the work over 4 Python worker processes:

```elixir
Charmer.start_link(python_path: <path to Python code>)

1..5
|> Task.async_stream(&Charmer.call(<relative path to called Python module>, "inc", [&1]))
|> Enum.map(fn {:ok, x} -> x end)

Charmer.stop()
```

This returns the expected result `[2, 3, 4, 5, 6]`.

In the above snippet, `<path to Python code>` is the root directory holding the 
Python code, and `<relative path to called Python module>` is the relative path of 
the module containing the called function--`inc` in this case.

The Python process pool is first started with `Charmer.start_link`, which takes a number
of optional arguments, including `:pool_size` for the number of workers, and 
`:pool_max_overflow` for the number of additional workers that can be added to 
accommodate extra load. `Charmer.stop` terminates the supervisor process and all
of its linked workers.

## Foundation

This package uses `Poolboy` to create and interact with an OTP process pool, and
`Export` to interact with each of the Python runtimes.
