# Plutonium
Plutonium is a interpreted language

- [Installation](#installation)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)

## Installation
To install plutonium, follow these steps:

1. Ensure you have Go installed on your system. You can download it from [here](https://go.dev/dl)

2. Clone the Plutonium repository:
`git clone git@github.com:plutonium-lang/Plutonium.git
`

3. Navigate to the cloned directory:
`cd plutonium`

4. Build the project:
`go build`

5. The executable will be located in the current directory. You can move it to a directory in your PATH for easier access.

## Getting Started
To start using Plutonium, you need to create a script file with the `.ptn` extension. Here's a simple example to get you started:
```
# This is a comment in Plutonium
puts("Hello, world");
```
To run your script, use the following command:
`./main main.ptn`

## Usage
Plutonium is designed to be easy to learn and use. Here are some basic commands and their usage:

- `puts("Hello, world!");`: Prints a message to the standard output.
- `let x: int = 10;` Declares a variable `x` and assigns it the value of `int 10`.
- `if (condition) { ... }`: Executes a block of code if the condition is true.

For a more indepth tutorial, refer to the [official documentation](#)

## Examples
Here are some examples to help you get started with Plutonium:

- **Hello, World**:
    ```
    puts("Hello, World!");
    ```

- **Variable Declaration and Printing**:
    ```
    let name: string = "Alice";
    puts("Hello, " + name + "!");
    ```

- **Conditional Statements**:
    ```
    let age: int = 25;
    if (age >= 18) {
        puts("You are an adult.");
    } else {
        puts("You are not an adult.");
    }
    ```

## Contributing

Contributions to Plutonium are welcome! If you find a bug or have a feature request, please open an issue on our [GitHub repository](https://github.com/Codezz-ops/Plutonium/issues). If you'd like to contribute code, please fork the repository and submit a pull request.

## License

Plutonium is licensed under the BSD 3-Clause License. See the [LICENSE](LICENSE) file for more details.
