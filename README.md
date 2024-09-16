# Calyxium
Calyxium is a split memory safe language

- [Prerequisite](#prerequisite)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)

## Prerequisite
- Visit the Windows SDK Download Page:
Go to the official [Windows SDK download page](https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/).

- Download the Installer:
Select the appropriate version of the SDK for your Windows version (Windows 10 or 11).
Download the installer and run it.

- Install the SDK:
During installation, ensure that the "Windows SDK" is selected.
Follow the on-screen instructions to complete the installation.

- Verify Installation
After installation, verify that the advapi32.lib file is present. It should be located in a directory similar to:
`C:\Program Files (x86)\Windows Kits\10\Lib\<version>\um\x64\advapi32.lib
`

## Installation
To install Calyxium, follow these steps:

1. Ensure you have OCaml installed on your system. You can download it from [Linux](https://ocaml.org/install#linux_mac_bsd), [Windows](https://ocaml.org/install#windows)

2. Clone the Calyxium repository:
`git clone git@github.com:Calyxium/Calyxium.git`

3. Navigate to the cloned directory:
`cd Calyxium`

4. Run the build powershell script on linux `pwsh ./build/build linux dev or release`, on windows `.\build\build.ps1 windows dev or release`

## Getting Started
To start using Calyxium, you need to create a script file with the `.cx` extension. Here's a simple example to get you started:
```
# This is a comment in Calyxium
println("Hello, world");
```
To run your script, use the following command:
`./calyxium main.cx`

## Usage
Calyxium is designed to be easy to learn and use. Here are some basic commands and their usage:

- `println("Hello, world!");`: Prints a message to the standard output.
- `let x: int = 10;` Declares a variable `x` and assigns it the value of `int 10`.
- `if (condition) { ... };`: Executes a block of code if the condition is true.

For a more indepth tutorial, refer to the [official documentation](https://calyxium.cc/docs)

## Examples
Here are some examples to help you get started with Calyxium:

- **Hello, World**:
    ```
    println("Hello, World!");
    ```

- **Variable Declaration and Printing**:
    ```
    let name: string = "Alice";
    print("Hello, " ^ name ^ "!");
    ```

- **Conditional Statements**:
    ```
    let age: int = 25;
    if (age >= 18) {
        println("You are an adult.");
    } else {
        println("You are not an adult.");
    };
    ```

## Contributing

Contributions to Calyxium are welcome! If you find a bug or have a feature request, please open an issue on our [GitHub repository](https://github.com/Calyxium/Calyxium/issues). If you'd like to contribute code, please fork the repository and submit a pull request.

## License

Calyxium is licensed under the BSD 3-Clause License. See the [LICENSE](LICENSE) file for more details.
