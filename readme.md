# Snip

Add code snippets to your code directly from the web.

## Installation

### Dependencies

- `curl` to download snippets

### Bash

```bash
# download script and place it in your initialization file
curl --fail "https://raw.githubusercontent.com/whoan/snip/master/snip.sh" > snip.sh &&
  echo "[ -f \"$PWD/\"snip.sh ] && source \"$PWD/\"snip.sh" >> .bashrc
# start a new session to take changes
bash
```

## Usage

- Add `snip("<url|path>")` (a.k.a. *the snip line*) anywhere in your code (usually as a comment) and the retrieved content will be placed after that line.
- Prefix any command with `snip` (eg: `snip bash script.sh`) and the *snip lines* (if any) will be replaced with the content retrieved from the url provided.

> Adding your *snip line* as a comment avoids your linter to complain about syntax (it works the same).

### Optional Parameters

- You can provide the `-f/--force` flag to force downloading the content regardless of it being present in the cache (*~/.cache/snip*). The cache will be updated with new content.

### Settings

You can set the following in `~/.config/snip/settings.ini`:

- `base_url`: Specify a url to shorten the *snip line* in your code.


    Example:

    ```bash
    $ cat ~/.config/snip/settings.ini

    ```
    ```
    base_url=https://raw.githubusercontent.com/whoan/snippets/master/cpp/
    ```

    Now, you can write this snip line in your code:

    ```cpp
    //snip("print.hpp")
    ```

    Instead of this:

    ```cpp
    //snip("https://raw.githubusercontent.com/whoan/snippets/master/cpp/print.hpp")
    ```

## Examples

### C++

Let's compile *main.cpp* prefixed with `snip`:

```bash
$ cat examples/main.cpp
```
```cpp
//snip("https://raw.githubusercontent.com/whoan/snip/master/examples/snippet.hpp")
int main() {
  say_hello();
  return 0;
}
```

```bash
$ snip g++ examples/main.cpp && ./a.out
> Hello World
```

### Bash

```bash
$ cat examples/main.sh
```
```bash
#snip("https://raw.githubusercontent.com/whoan/snip/master/examples/snippet.sh")
say_hello
```

```bash
$ snip bash examples/main.sh
> Hello World
```

### Python

```bash
$ cat examples/main.py
```
```python
#snip("https://raw.githubusercontent.com/whoan/snip/master/examples/snippet.py")
say_hello()
```

```bash
$ snip python examples/main.py
> Hello World
```

### Docker

```bash
$ cat examples/Dockerfile
```
```
FROM alpine
#snip("https://raw.githubusercontent.com/whoan/snip/master/examples/snippet.dockerfile")
CMD sh say_hello.sh
```

```bash
$ snip docker build -q -t snip-docker -f examples/Dockerfile . && docker run snip-docker
> Hello World
```

## TODO

- ~Add cache to avoid downloading same code over again~ (Thanks [@sapgan](https://github.com/sapgan) and [@danstewart](https://github.com/danstewart))
- ~Allow setting base_url in a file to shorten snip line~

## Final notes

I created this script to reuse code with ease. It is not production ready... unless you know what you are doing.

## License

[MIT](https://github.com/whoan/snip/blob/master/LICENSE)
